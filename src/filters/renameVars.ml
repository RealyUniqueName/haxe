open Globals
open Ast
open Type
open Common
open Typecore
open TyperBase
open Error

module Filter : sig
	type r

	val create : context -> r

	val run : r -> typer -> texpr -> texpr

end = struct
	type r = {
		cfg : scoping;
		mutable reserved_names : unit StringMap.t;
		name_counters : (string,int) Hashtbl.t
	}

	type scope = {
		mutable declares : tvar list; (* bool for in_loop *)
		(* key var - a declared variable, value vars - list of vars used after the key var declaration *)
		overlaps : (int, tvar list) Hashtbl.t;
		captures : (int, tvar) Hashtbl.t;
		mutable loop_count : int;
		(* variables referenced in current loop *)
		loop_vars : tvar list ref;
		parent : scope option;
		mutable children : scope list;
	}

	let get_native_type_name = TypeloadCheck.get_native_name

	let reserve_name r name =
		r.reserved_names <- StringMap.add name () r.reserved_names

	let init_reserved_names com r =
		reserve_name r "this";
		List.iter (fun flag ->
			match flag with
			| ReserveNames names ->
				List.iter (reserve_name r) names
			| ReserveAllClassNames ->
				List.iter (fun mt ->
					let tinfos = t_infos mt in
					let native_name = try fst (get_native_type_name tinfos.mt_meta) with Not_found -> Path.flat_path tinfos.mt_path in
					if native_name = "" then
						match mt with
						| TClassDecl c ->
							List.iter (fun cf ->
								let native_name = try fst (get_native_type_name cf.cf_meta) with Not_found -> cf.cf_name in
								reserve_name r native_name
							) c.cl_ordered_statics;
						| _ -> ()
					else
						reserve_name r native_name
				) com.types
			| _ -> ()
		) r.cfg.sc_flags

	let create com =
		let r = {
			cfg = com.config.pf_scoping;
			reserved_names = StringMap.empty;
			name_counters = Hashtbl.create 10
		} in
		init_reserved_names com r;
		r

	let create_scope parent = {
		declares = [];
		overlaps = Hashtbl.create 10;
		captures = Hashtbl.create 5;
		parent = parent;
		loop_count = Option.map_default (fun p -> p.loop_count) 0 parent;
		loop_vars = Option.map_default (fun p -> p.loop_vars) (ref []) parent;
		children = [];
	}

	let create_child_scope scope =
		let child = create_scope (Some scope) in
		scope.children <- child :: scope.children;
		child

	let maybe_reserve_module_type_name r t =
		match (t_infos t).mt_path with
		| [], name | name :: _, _ -> reserve_name r name

	let maybe_reserve_type_name r t =
		match follow t with
		| TInst (c,_) -> maybe_reserve_module_type_name r (TClassDecl c)
		| TEnum (e,_) -> maybe_reserve_module_type_name r (TEnumDecl e)
		| TType (t,_) -> maybe_reserve_module_type_name r (TTypeDecl t)
		| TAbstract (a,_) -> maybe_reserve_module_type_name r (TAbstractDecl a)
		| TMono _ | TLazy _ | TAnon _ | TDynamic _ | TFun _ -> ()

	let rename r v scope overlaps =
		let name = ref v.v_name in
		let count = ref (try Hashtbl.find r.name_counters v.v_name with Not_found -> 1) in
		let rec step() =
			name := v.v_name ^ (string_of_int !count);
			if
				StringMap.mem !name r.reserved_names
				|| List.exists (fun o -> o.v_name = !name) overlaps
				|| List.exists (fun o -> o != v && o.v_name = !name) !(scope.loop_vars)
			then begin
				incr count;
				step()
			end
		in
		step();
		Hashtbl.replace r.name_counters v.v_name !count;
		if not (Meta.has Meta.RealPath v.v_meta) then
			v.v_meta <- (Meta.RealPath,[EConst (String(v.v_name,SDoubleQuotes)),v.v_pos],v.v_pos) :: v.v_meta;
		v.v_name <- !name

	let trailing_numbers = Str.regexp "[0-9]+$"

	let declare_var r scope v =
		(* chop escape char for all local variables generated *)
		if is_gen_local v then begin
			let name = String.sub v.v_name 1 (String.length v.v_name - 1) in
			v.v_name <- "_g" ^ (Str.replace_first trailing_numbers "" name)
		end;
		scope.declares <- v :: scope.declares;
		Hashtbl.add scope.overlaps v.v_id [];
		if scope.loop_count > 0 then
			scope.loop_vars := v :: !(scope.loop_vars);
		if
			StringMap.mem v.v_name r.reserved_names
			|| (List.exists (fun o -> o != v && o.v_name = v.v_name) !(scope.loop_vars))
		then
			rename r v scope [];
		if v.v_capture then
			reserve_name r v.v_name

	let add_overlap scope v o =
		let overlaps =
			let rec loop scope =
				try
					Hashtbl.find scope.overlaps o.v_id
				with Not_found ->
					match scope.parent with
					| None -> assert false
					| Some p -> loop p
			in
			loop scope
		in
		if not (List.mem v overlaps) then
			Hashtbl.replace scope.overlaps o.v_id (v :: overlaps)

	let rec reference_var r scope v =
		let rec loop declares =
			match declares with
			| [] ->
				(match scope.parent with
				| Some parent -> reference_var r parent v
				| None -> ())
			| d :: rest when d == v -> ()
			| d :: rest ->
				let overlaps =
					let overlaps =
						try Hashtbl.find scope.overlaps d.v_id with Not_found -> assert false
					in
					if List.mem v overlaps then
						overlaps
					else begin
						let new_overlaps = v :: overlaps in
						Hashtbl.replace scope.overlaps d.v_id new_overlaps;
						new_overlaps
					end
				in
				if d.v_name = v.v_name then rename r d scope overlaps;
				loop rest
		in
		loop scope.declares;
		if scope.loop_count > 0 && not (List.mem v !(scope.loop_vars)) then begin
			List.iter (fun v2 -> add_overlap scope v2 v) !(scope.loop_vars);
			scope.loop_vars := v :: !(scope.loop_vars)
		end

	let rec diff_declared new_declared old_declared =
		match new_declared, old_declared with
		| [], _ -> []
		| _, [] -> new_declared
		| n :: _, o :: _ when n == o -> []
		| n :: rest_new, _ -> n :: (diff_declared rest_new old_declared)

	let rec collect_vars r scope e =
		match e.eexpr with
		| TLocal v ->
			reference_var r scope v
		| TVar (v, e_opt) ->
			declare_var r scope v;
			Option.may (collect_vars r scope) e_opt
		| TBlock el when r.cfg.sc_vars = BlockScope ->
			let child = create_child_scope scope in
			List.iter (collect_vars r child) el
		| TWhile (condition,body,NormalWhile) ->
			scope.loop_count <- scope.loop_count + 1;
			collect_vars r scope condition;
			let loop_scope =
				match r.cfg.sc_vars with
				| BlockScope -> create_child_scope scope
				| FunctionScope -> scope
			in
			collect_vars r loop_scope body;
			scope.loop_count <- scope.loop_count - 1;
			if scope.loop_count = 0 then
				scope.loop_vars := []
		| TFor _ | TWhile (_, _, DoWhile) ->
			(* At this point all `for` and `do` loops are expected to be transformed to `while` loops *)
			assert false
		| TFunction fn ->
			let child = create_child_scope scope in
			List.iter (fun (v,_) -> declare_var r child v) fn.tf_args;
			List.iter (fun (v,_) -> reference_var r child v) fn.tf_args;
			collect_vars r child fn.tf_expr
		| TTry (try_body, catches) ->
			collect_vars r scope try_body;
			List.iter (fun (v, catch_body) ->
				let scope =
					match r.cfg.sc_vars with
					| BlockScope -> create_child_scope scope
					| FunctionScope -> scope
				in
				declare_var r scope v;
				collect_vars r scope catch_body
			) catches
		| _ ->
			iter (collect_vars r scope) e

	let run r ctx e =
		let r = { r with name_counters = Hashtbl.copy r.name_counters } in
		if List.mem ReserveTopPackage ctx.com.config.pf_scoping.sc_flags then begin
			match ctx.curclass.cl_path with
			| s :: _,_ | [],s -> reserve_name r s
		end;
		let root_scope = create_scope None in
		collect_vars r root_scope e;
		(* let rec loop scope =
			List.iter (fun v ->
				maybe_rename r v;
				if v.v_capture then reserve_name r v.v_name
			) (List.rev scope.declares);
			List.iter loop (List.rev scope.children)
		in
		loop root_scope; *)
		e
end
