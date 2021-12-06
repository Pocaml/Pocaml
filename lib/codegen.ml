module L = Llvm
open Ir
open Fresh
open Print_ir
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
  let pml_bool_t = L.i8_type context in
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
    List.fold_left builtin StringMap.empty Print.builtin_names
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
        let (hd, tl) = match e with
          | Apply (t1, Apply (t2, _, hd), tl) -> (hd, tl)
          | _ -> (e, e)
        in
        let rec pat_match extract_f  = function
          | (pat, _) -> extract_f pat 
        and extract_lit = function 
          | PatLit (_, lit) -> compare_lit (lit, e)
          | _ -> false
        and extract_cons = function 
          | PatCons (_, vid_hd, vid_tl) -> check_cons (hd, tl)
          | _ -> false
        and extract_cons_end = function 
          | PatConsEnd (t, vid) -> check_cons_end (hd, tl)
          | _ -> false
        and extract_var = function 
          | PatDefault (t, vid) -> true
          | _ -> false
        and lookup_val n = function
          | Env (m, parent_env) -> (
              try StringMap.find n m with Not_found -> lookup_val n parent_env)
          | EnvNone -> error ("codegen: unbound variable " ^ n)
        and compare_lit = function
          (*| lit, Var (_, vid) -> compare_var (lit, (lookup_val vid env)) *)
          | LitInt (x), Lit (_, LitInt (y))   -> x = y
          | LitChar (x), Lit (_, LitChar (y)) -> x = y
          | LitBool (x), Lit (_, LitBool (y)) -> x = y
          | _, _ -> false
        
        and check_cons = function
          | (hd, Apply (_, Apply (_, _, hd2), tl)) -> true
          | _ -> false
        and check_cons_end = function
          | (hd, Lit (_, LitListEnd)) -> true
          | _ -> false
        in

        let matched = List.filter (pat_match extract_lit) arms in
        let matched = if (List.length matched) > 0 
                      then matched 
                      else List.filter (pat_match extract_cons) arms 
        in
        let matched = if (List.length matched) > 0 
                      then matched 
                      else List.filter (pat_match extract_cons_end) arms 
        in
        let matched = if (List.length matched) > 0 
                      then matched 
                      else List.filter (pat_match extract_var) arms 
        in

        let (pm, em) = match matched with 
          | (pm, em) :: l -> (pm, em)
          | _ -> error "codegen: pattern matching failed"
        in 
        let env = match pm with
          | PatLit (_, lit) -> env
          | PatCons (_, vid_hd, vid_tl) -> 
              let llval_hd, builder = build_expr f builder env hd in
              let llval_tl, builder = build_expr f builder env tl in
              let env = add_var_to_scope vid_hd llval_hd env in 
              add_var_to_scope vid_tl llval_tl env
          | PatConsEnd (t, vid_hd) -> 
              let llval_hd, builder = build_expr f builder env hd in
              add_var_to_scope vid_hd llval_hd env
          | PatDefault (t, vid) -> 
              let llval1, builder = build_expr f builder env e in
              add_var_to_scope vid llval1 env
        in
        let llval2, builder = build_expr f builder env em in
        print_string (string_of_expr em);
        (llval2, builder)

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
    | LitListEnd -> (pml_empty_list, builder)
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
    let build_call_init _ f = ignore (L.build_call f [||] "" main_builder) in
    StringMap.iter build_call_init topinits
  in

  (* Terminate main with a return *)
  let _ = L.build_ret (L.const_int pml_int_t 0) main_builder in

  (* Return the module *)
  the_module
