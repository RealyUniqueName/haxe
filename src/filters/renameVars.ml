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
		mutable declares : (tvar * bool) list; (* bool for in_loop *)
		(* key var - a declared variable, value vars - list of vars used after the key var declaration *)
		mutable overlaps : (int, tvar list) Hashtbl.t;
		mutable captures : (int, tvar) Hashtbl.t;
		mutable parent : scope option;
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

	let rename r v overlaps =
		let name = ref v.v_name in
		let count = ref (try Hashtbl.find r.name_counters v.v_name with Not_found -> 1) in
		let rec step() =
			name := v.v_name ^ (string_of_int !count);
			if StringMap.mem !name r.reserved_names || List.exists (fun o -> o.v_name = !name) overlaps then begin
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

	let declare_var r scope in_loop v =
		(* chop escape char for all local variables generated *)
		if is_gen_local v then begin
			let name = String.sub v.v_name 1 (String.length v.v_name - 1) in
			v.v_name <- "_g" ^ (Str.replace_first trailing_numbers "" name)
		end;
		scope.declares <- (v, in_loop) :: scope.declares;
		Hashtbl.add scope.overlaps v.v_id [];
		if StringMap.mem v.v_name r.reserved_names then
			rename r v []

	let rec reference_var r scope in_loop v =
		let rec loop declares =
			match declares with
			| [] ->
				(match scope.parent with
				| Some parent -> reference_var r parent in_loop v
				| None -> ())
			| (d,d_loop) :: _ when d == v ->
				if r.cfg.sc_shadowing = FullShadowing || not in_loop then ()
				else if
			| (d,_) :: rest ->
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
				if d.v_name = v.v_name then rename r d overlaps;
				loop rest
		in
		loop scope.declares

	let rec diff_declared new_declared old_declared =
		match new_declared, old_declared with
		| [], _ -> []
		| _, [] -> new_declared
		| n :: _, o :: _ when n == o -> []
		| n :: rest_new, _ -> n :: (diff_declared rest_new old_declared)

	let rec collect_vars r scope in_loop e =
		match e.eexpr with
		| TLocal v ->
			reference_var r scope in_loop v
		| TVar (v, e_opt) ->
			declare_var r scope in_loop v;
			Option.may (collect_vars r scope in_loop) e_opt
		| TBlock el when r.cfg.sc_vars = BlockScope ->
			let child = create_child_scope scope in
			List.iter (collect_vars r child in_loop) el
		| TWhile (condition,body,NormalWhile) ->
			collect_vars r scope in_loop condition;
			let loop_scope =
				match r.cfg.sc_vars with
				| BlockScope -> create_child_scope scope
				| FunctionScope -> scope
			in
			collect_vars r loop_scope true body;
		| TFor _ | TWhile (_, _, DoWhile) ->
			(* At this point all `for` and `do` loops are expected to be transformed to `while` loops *)
			assert false
		| TFunction fn ->
			let child = create_child_scope scope in
			List.iter (fun (v,_) -> declare_var r child in_loop v) fn.tf_args;
			List.iter (fun (v,_) -> reference_var r child in_loop v) fn.tf_args;
			collect_vars r child false fn.tf_expr
		| TTry (try_body, catches) ->
			collect_vars r scope in_loop try_body;
			List.iter (fun (v, catch_body) ->
				let scope =
					match r.cfg.sc_vars with
					| BlockScope -> create_child_scope scope
					| FunctionScope -> scope
				in
				declare_var r scope in_loop v;
				collect_vars r scope in_loop catch_body
			) catches
		| _ ->
			iter (collect_vars r scope in_loop) e

	let run r ctx e =
		let r = { r with name_counters = Hashtbl.copy r.name_counters } in
		if List.mem ReserveTopPackage ctx.com.config.pf_scoping.sc_flags then begin
			match ctx.curclass.cl_path with
			| s :: _,_ | [],s -> reserve_name r s
		end;
		let root_scope = create_scope None in
		collect_vars r root_scope false e;
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
