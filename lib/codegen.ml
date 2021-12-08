module L = Llvm
open Ir
open Fresh
module StringMap = Map.Make (String)

exception CodegenError of string

let error s = raise (CodegenError s)

let not_implemented () = error "Not implemented"

type env = Env of L.llvalue StringMap.t * env | EnvNone

let print_lltype_of_llvalue llval =
  print_endline (L.string_of_lltype (L.type_of llval))

(* translate : I.program -> Llvm.module *)
let codegen (Program definitions) =
  let context = L.global_context () in
  let the_module = L.create_module context "pocaml" in

  (* Get types from the context *)
  let void_t = L.void_type context in
  let pml_char_t = L.i8_type context in
  let pml_bool_t = L.i1_type context in
  let pml_unit_t = L.i8_type context in
  let pml_int_t = L.i32_type context in
  let pml_string_t = L.pointer_type (L.i8_type context) in
  let pml_val_t = L.pointer_type (L.i8_type context) in
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

  let pml_error_nonexhaustive_pattern_matching =
    let ftype = L.function_type void_t [||] in
    L.declare_function "_pml_error_nonexhaustive_pattern_matching" ftype
      the_module
  in

  let match_pat_cons_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t |] in
    L.declare_function "_match_pat_cons" ftype the_module
  in

  let match_pat_cons_end_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t |] in
    L.declare_function "_match_pat_cons_end" ftype the_module
  in

  let match_pat_lit_int_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t; pml_int_t |] in
    L.declare_function "_match_pat_lit_int" ftype the_module
  in

  let match_pat_lit_char_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t; pml_char_t |] in
    L.declare_function "_match_pat_lit_char" ftype the_module
  in

  let match_pat_lit_bool_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t; pml_bool_t |] in
    L.declare_function "_match_pat_lit_bool" ftype the_module
  in

  let match_pat_lit_string_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t; pml_string_t |] in
    L.declare_function "_match_pat_lit_string" ftype the_module
  in

  let match_pat_lit_unit_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t; pml_unit_t |] in
    L.declare_function "_match_pat_lit_unit" ftype the_module
  in


  let match_pat_lit_list_end_f =
    let ftype = L.function_type pml_bool_t [| pml_val_t |] in
    L.declare_function "_match_pat_lit_list_end" ftype the_module
  in

  let list_get_head_f =
    let ftype = L.function_type pml_val_t [| pml_val_t |] in
    L.declare_function "_list_get_head" ftype the_module
  in

  let list_get_tail_f =
    let ftype = L.function_type pml_val_t [| pml_val_t |] in
    L.declare_function "_list_get_tail" ftype the_module
  in

  let make_int_f =
    let ftype = L.function_type pml_val_t [| pml_int_t |] in
    L.declare_function "_make_int" ftype the_module
  in

  let make_bool_f =
    let ftype = L.function_type pml_val_t [| pml_bool_t |] in
    L.declare_function "_make_bool" ftype the_module
  in

  let make_char_f =
    let ftype = L.function_type pml_val_t [| pml_char_t |] in
    L.declare_function "_make_char" ftype the_module
  in

  let make_string_f =
    let ftype = L.function_type pml_val_t [| pml_string_t |] in
    L.declare_function "_make_string" ftype the_module
  in

  let make_unit_f =
    let ftype = L.function_type pml_val_t [||] in
    L.declare_function "_make_unit" ftype the_module
  in

  let make_closure_f =
    let ftype =
      L.function_type pml_val_t [| L.pointer_type pml_func_t; pml_int_t |]
    in
    L.declare_function "_make_closure" ftype the_module
  in

  let apply_closure_f =
    let ftype = L.function_type pml_val_t [| pml_val_t; pml_val_t |] in
    L.declare_function "_apply_closure" ftype the_module
  in

  (* Declare the builtins *)
  let pml_empty_list =
    L.declare_global pml_val_t "_pml_empty_list" the_module
  in

  let builtins : L.llvalue StringMap.t =
    let builtin m n =
      let f = L.declare_global pml_val_t n the_module in
      StringMap.add n f m
    in
    List.fold_left builtin StringMap.empty Builtins.builtin_names
  in

  let builtins_env : env = Env (builtins, EnvNone) in

  (* Declare the builtin-init function *)
  let builtins_init : L.llvalue =
    L.declare_function "_init__builtins" pml_init_t the_module
  in

  (* Build call in main for the buildin-init function *)
  let _ = L.build_call builtins_init [||] "" main_builder in

  (* Define top-level values *)
  let toplevels : L.llvalue StringMap.t =
    let toplevel m (Def (n, _)) =
      let v = L.define_global n (L.const_null pml_val_t) the_module in
      StringMap.add n v m
    in
    List.fold_left toplevel StringMap.empty definitions
  in
  let toplevels_env : env = Env (toplevels, builtins_env) in

  (* This `lookup` is actually more complicated than just looking up the llvalue.
     Since LLVM globals are actually pointers to the values, we have to first load
     the globals into a local variable, and then use it accordingly. However,
     the current hacky approach actually loads it everytime it is being looked up,
     so there could be multiple locals variables that point to the same global variable.
     It works, but we should probably think of something better. *)
  let lookup n builder env =
    let rec lookup' n f = function
      | Env (m, parent_env) -> (
          try StringMap.find n m with Not_found -> lookup' n f parent_env)
      | EnvNone -> f ()
    in
    let lookup_toplevel () =
      let unfound () = error ("codegen: unbound variable " ^ n) in
      let global = lookup' n unfound toplevels_env in
      L.build_load global n builder
    in
    lookup' n lookup_toplevel env
  in

  let add_var_to_scope k v env =
    let m = StringMap.singleton k v in
    Env (m, env)
  in

  (* Function that builds the expression evaluation *)
  let rec build_expr f builder env = function
    | Lambda (t, vid, e) ->
        error "codegen: should not have non-top-level lambdas expr"
    | Lit (_, lit) -> build_expr_lit builder lit
    | Var (t, vid) -> (lookup vid builder env, builder)
    | Letin (t, vid, e1, e2) ->
        let llval1, builder = build_expr f builder env e1 in
        let env = add_var_to_scope vid llval1 env in
        build_expr f builder env e2
    | Apply (t, e1, e2) ->
        let llval1, builder = build_expr f builder env e1 in
        let llval2, builder = build_expr f builder env e2 in
        let llval =
          L.build_call apply_closure_f [| llval1; llval2 |] (fresh_name ())
            builder
        in
        (llval, builder)
    | Match (t, e, arms) ->
        (* evaluate e first *)
        let e', builder = build_expr f builder env e in
        (* allocate a result variable (build_alloca): pointer to pml_val_t *)
        let match_val_ptr = L.build_alloca pml_val_t "match_val" builder in
        (* make a end_match block that load result var into an llvalue and return it with new builder *)
        let end_match_block = L.append_block context "end_match" f in
        (* recursively make match blocks with append_block *)
        let rec build_match_arms = function
          | [] ->
              (* no match: non-exhaustive pattern matching *)
              let block = L.append_block context "no_match" f in
              let builder = L.builder_at_end context block in
              let _ =
                L.build_call pml_error_nonexhaustive_pattern_matching [||] ""
                  builder
              in
              let _ = L.build_br end_match_block builder in
              block
          | (pat, arm_e) :: arms ->
              let next_match_block = build_match_arms arms in
              let match_block = L.append_block context "match" f in
              let match_builder = L.builder_at_end context match_block in
              let arm_block = L.append_block context "arm" f in
              let arm_builder = L.builder_at_end context arm_block in
              (* build match *)
              let match_result =
                match pat with
                | PatLit (_, lit) -> (
                    match lit with
                    | LitInt n ->
                        let llval = L.const_int pml_int_t n in
                        L.build_call match_pat_lit_int_f [| e'; llval |]
                          "match_result" match_builder
                    | LitChar c ->
                        let llval = L.const_int pml_char_t (Char.code c) in
                        L.build_call match_pat_lit_char_f [| e'; llval |]
                          "match_result" match_builder
                    | LitString s ->
                        let llval = L.build_global_stringptr s "" builder in
                        L.build_call match_pat_lit_string_f [| e'; llval |]
                          "match_result" match_builder
                    | LitBool b ->
                        let llval = L.const_int pml_bool_t (Bool.to_int b) in
                        L.build_call match_pat_lit_bool_f [| e'; llval |]
                          "match_result" match_builder
                    | LitUnit ->
                        let llval = L.const_int pml_unit_t 69 in
                        L.build_call match_pat_lit_unit_f [| e'; llval |]
                          "match_result" match_builder
                    | LitListEnd ->
                        L.build_call match_pat_lit_list_end_f [| e' |]
                          "match_result" match_builder)
                | PatDefault _ -> L.const_int pml_bool_t (Bool.to_int true)
                | PatCons _ ->
                    L.build_call match_pat_cons_f [| e' |] "match_result"
                      match_builder
                | PatConsEnd _ ->
                    L.build_call match_pat_cons_end_f [| e' |] "match_result"
                      match_builder
              in
              (* conditional jump to arm_block *)
              let _ =
                L.build_cond_br match_result arm_block next_match_block
                  match_builder
              in
              (* build arm *)
              let env =
                match pat with
                | PatLit _ -> env
                | PatDefault (_, vid) -> add_var_to_scope vid e' env
                | PatCons (_, vid1, vid2) ->
                    let e1 =
                      L.build_call list_get_head_f [| e' |] "" arm_builder
                    in
                    let e2 =
                      L.build_call list_get_tail_f [| e' |] "" arm_builder
                    in
                    let env1 = add_var_to_scope vid1 e1 env in
                    let env2 = add_var_to_scope vid2 e2 env1 in
                    env2
                | PatConsEnd (_, vid1) ->
                    let e1 =
                      L.build_call list_get_head_f [| e' |] "" arm_builder
                    in
                    let env1 = add_var_to_scope vid1 e1 env in
                    env1
              in
              let arm_val, arm_builder = build_expr f arm_builder env arm_e in
              let _ = L.build_store arm_val match_val_ptr arm_builder in
              let _ = L.build_br end_match_block arm_builder in
              match_block
        in
        (* jump to the first match block *)
        let first_match_block = build_match_arms arms in
        let _ = L.build_br first_match_block builder in
        let end_match_builder = L.builder_at_end context end_match_block in
        let match_val =
          L.build_load match_val_ptr "match_val" end_match_builder
        in
        (match_val, end_match_builder)
  (* build arm *)
  and build_expr_lit builder = function
    | LitInt n ->
        let llval =
          L.build_call make_int_f
            [| L.const_int pml_int_t n |]
            (fresh_name ()) builder
        in
        (llval, builder)
    | LitChar c ->
        let llval =
          L.build_call make_char_f
            [| L.const_int pml_char_t (Char.code c) |]
            (fresh_name ()) builder
        in
        (llval, builder)
    | LitString s ->
        let llval = L.build_global_stringptr s (fresh_string_name ()) builder in
        let llval =
          L.build_call make_string_f [| llval |] (fresh_name ()) builder
        in
        (llval, builder)
    | LitBool b ->
        let llval =
          L.build_call make_bool_f
            [| L.const_int pml_bool_t (Bool.to_int b) |]
            (fresh_name ()) builder
        in
        (llval, builder)
    | LitUnit ->
        let llval = L.build_call make_unit_f [||] (fresh_name ()) builder in
        (llval, builder)
    | LitListEnd ->
        let llval = L.build_load pml_empty_list "pml_empty_list" builder in
        (llval, builder)
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
            Env (params_env', EnvNone)
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
  let topinits : L.llvalue StringMap.t =
    let topinit m (Def (n, e)) =
      let f = L.define_function ("_init_" ^ n) pml_init_t the_module in
      let entry_block = L.entry_block f in
      let builder = L.builder_at_end context entry_block in
      match e with
      | Lambda _ ->
          let argn =
            let rec argn' = function
              | Lambda (_, _, body) -> 1 + argn' body
              | _ -> 0
            in
            argn' e
          in
          let global = StringMap.find n toplevels in
          let topfunc = StringMap.find n topfuncs in
          let llval =
            L.build_call make_closure_f
              [| topfunc; L.const_int pml_int_t argn |]
              (fresh_name ()) builder
          in
          (* store the llval in the top-level *)
          let _ = L.build_store llval global builder in
          (* return void *)
          let _ = L.build_ret_void builder in
          StringMap.add n f m
      | _ ->
          let global = StringMap.find n toplevels in
          (* build the expression evaluation *)
          let evaluated_expr, builder = build_expr f builder EnvNone e in
          (* store the result in the top-level *)
          let _ = L.build_store evaluated_expr global builder in
          (* return void *)
          let _ = L.build_ret_void builder in
          StringMap.add n f m
    in
    List.fold_left topinit StringMap.empty definitions
  in

  (* Build calls in main for the top-evel init functions *)
  let () =
    let build_call_init f = ignore (L.build_call f [||] "" main_builder) in
    List.iter
      (fun (Def (n, _)) -> build_call_init (StringMap.find n topinits))
      definitions
  in

  (* Terminate main with a return *)
  let _ = L.build_ret (L.const_int pml_int_t 0) main_builder in

  (* Return the module *)
  the_module
