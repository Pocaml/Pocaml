module L = Llvm
open Ir
open Fresh
module StringMap = Map.Make (String)

exception CodegenError of string

let error s = raise (CodegenError s)

let not_implemented () = error "Not implemented"

type env = Env of L.llvalue StringMap.t * env | EnvNone

let rec lookup n = function
  | Env (m, parent_env) -> (
      try StringMap.find n m with Not_found -> lookup n parent_env)
  | EnvNone -> error ("codegen: unbound variable " ^ n)

(* translate : I.program -> Llvm.module *)
let codegen (Program definitions) =
  let context = L.global_context () in
  let the_module = L.create_module context "pocaml" in

  (* Get types from the context *)
  let void_t = L.void_type context in
  let pml_int_t = L.i32_type context in
  let pml_val_t = L.pointer_type void_t in
  let pml_func_t = L.function_type pml_val_t [| L.pointer_type pml_val_t |] in
  let pml_init_t = L.function_type void_t [||] in

  (* Define main function and get the builder *)
  let main_func =
    let ftype = L.function_type pml_int_t [||] in
    L.define_function "main" ftype the_module
  in
  let main_builder =
    let entry_block = L.entry_block main_func in
    L.builder_at_end context entry_block
  in

  (* Declare helpers *)
  let get_arg_f =
    let ftype =
      L.function_type pml_val_t [| L.pointer_type pml_val_t; pml_int_t |]
    in
    L.declare_function "_get_arg" ftype the_module
  in

  let make_int_f =
    let ftype = L.function_type pml_val_t [| pml_int_t |] in
    L.declare_function "_make_int" ftype the_module
  in

  (* Declare the builtins *)
  let builtins : env =
    let builtin_names = [ "_add"; "_minus" ] in
    let builtin m n =
      let f = L.declare_global pml_val_t n the_module in
      StringMap.add n f m
    in
    let builtins' = List.fold_left builtin StringMap.empty builtin_names in
    Env (builtins', EnvNone)
  in

  (* Declare the builtin-init function *)
  let builtins_init : L.llvalue =
    L.declare_function "_init__builtins" pml_init_t the_module
  in

  (* Build call in main for the buildin-init function *)
  let _ = L.build_call builtins_init [||] "" main_builder in

  (* Define top-level values *)
  let toplevels : env =
    let toplevel m (Def (n, _)) =
      let v = L.define_global n (L.const_null pml_val_t) the_module in
      StringMap.add n v m
    in
    let toplevels' = List.fold_left toplevel StringMap.empty definitions in
    Env (toplevels', builtins)
  in

  (* Function that builds the expression evaluation *)
  let build_expr f builder env e =
    ( L.build_call make_int_f
        [| L.const_int pml_int_t 0 |]
        (fresh_name ()) builder,
      builder )
  in

  (* Define top-level lambda's; keep a dictionary (key: top-level name, value: lambda's function definition)*)
  let topfuncs : L.llvalue StringMap.t =
    let topfunc m (Def (n, e)) =
      match e with
      | Lambda (t, _, _) ->
          (* get chaining lambda arguments *)
          let (typed_params, body) : (int * typ * string) list * expr =
            let rec collapsed_lambda' i e =
              match e with
              | Lambda (t, p, body) ->
                  let collapsed_t_p, collapsed_body =
                    collapsed_lambda' (i + 1) body
                  in
                  ((i, t, p) :: collapsed_t_p, collapsed_body)
              | _ -> ([], e)
            in
            collapsed_lambda' 0 e
          in
          (* define the anonymous function *)
          let f = L.define_function (fresh_name ()) pml_func_t the_module in
          let entry_block = L.entry_block f in
          let builder = L.builder_at_end context entry_block in
          let params_ptr = Array.get (L.params f) 0 in
          (* get the parameters into the environment *)
          let params_env =
            let get_param m (i, _, n) =
              let v =
                L.build_call get_arg_f
                  [| params_ptr; L.const_int pml_int_t i |]
                  n builder
              in
              StringMap.add n v m
            in
            let params_env' =
              List.fold_left get_param StringMap.empty typed_params
            in
            Env (params_env', toplevels)
          in
          (* build the expression evaluation *)
          let evaluated_expr, builder = build_expr f builder params_env body in
          (* add the return statement *)
          let _ = L.build_ret evaluated_expr builder in
          (* map the top-level lambda name to the anonymous function *)
          StringMap.add n f m
      | _ -> m
    in
    List.fold_left topfunc StringMap.empty definitions
  in

  (* Define top-level init functions; keep a dictionary (key: top-level name, value: init's function definition)*)

  (* Build calls in main for the top-evel init functions *)

  (* Terminate main with a return *)
  let _ = L.build_ret (L.const_int pml_int_t 0) main_builder in

  (* Return the module *)
  the_module
