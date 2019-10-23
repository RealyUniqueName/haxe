open EvalValue
open Type

class plugin =
	object (self)
		method run basic_types field e =
			match e.eexpr with
			| TFunction fn ->
				let add_loop = ref false in
				let rec transform e =
					match e.eexpr with
					(* instance methods *)
					| TReturn (Some { eexpr = TCall ({ eexpr = TField ({ eexpr = TConst TThis }, FInstance (_, _, f)) }, args) })
					(* static methods *)
					| TReturn (Some { eexpr = TCall ({ eexpr = TField (_, FStatic (_, f)) }, args) }) when f == field ->
						add_loop := true;
						let rec assign_args vars exprs =
							match vars, exprs with
							| [], [] -> []
							| (v, _) :: rest_vars, e :: rest_exprs
							| (v, Some e) :: rest_vars, rest_exprs ->
								let arg = { e with eexpr = TLocal v } in
								{ e with eexpr = TBinop (OpAssign, arg, e) } :: assign_args rest_vars rest_exprs
							| _ -> assert false
						in
						{
							eexpr = TBlock (assign_args fn.tf_args args);
							etype = basic_types.tvoid;
							epos = e.epos;
						}
					| _ -> map_expr transform e
				in
				let body = transform fn.tf_expr in
				if !add_loop then
					let cond = mk (TConst (TBool true)) basic_types.tbool Globals.null_pos in
					{ e with
						eexpr = TFunction { fn with
							tf_expr = { body with eexpr = TWhile (cond, body, Ast.NormalWhile) }
						}
					}
				else e
			| _ -> e

		method register () : value =
			let compiler = (EvalContext.get_ctx()).curapi in
			let basic_types = (compiler.get_com()).basic in
			let handle_field field =
				match field.cf_expr with
				| Some e ->
					field.cf_expr <- Some (self#run basic_types field e)
				| None -> ()
			in
			(**
				Add a callback like `haxe.macro.Context.onAfterTyping`
			*)
			compiler.after_typing (fun haxe_types ->
				List.iter
					(fun hx_type ->
						match hx_type with
							| TClassDecl cls ->
								List.iter handle_field cls.cl_ordered_statics;
								List.iter handle_field cls.cl_ordered_fields
							| _ -> ()
					)
					haxe_types
			);
			vnull
	end
;;

let api = new plugin in

EvalStdLib.StdContext.register [
	("register", EvalEncode.vfun0 api#register);
]