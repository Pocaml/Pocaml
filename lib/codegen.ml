(* 
  function codegen: m_program -> llvm optional
*)

module L = Llvm
open IR 

module StringMap = Map.Make(String)
exception CodegenError of string

(* translate : Sast.program -> Llvm.module *)
let codegen = function Program (definitions) -> 
  let context    = L.global_context () in
  let the_module = L.create_module context "Pocaml" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and void_t     = L.void_type   context in
  (* let get_typ = function A.LitInt   -> i32_t in *)
  let ltype_of_typ = function
  | TVar (tvar_id) -> raise CodegenError "Cannot have type variables."
  | TCon ("int") -> i32_t
  | TCon ("()") -> void_t
  | TApp (typ, typ) -> raise CodegenError "TApp type is not supported."
  | TArrow (typ, typ) -> raise CodegenError "TArrow type is not supported."
  | TNone -> raise CodegenError "Cannot have unknown types."
  | _ -> raise CodegenError "Type is not supported."
  in
  (* temporary *)
  
  let fresh_var =
    let _fresh_var = ref 1 in
      _fresh_var := _fresh_var + 1;
      string_of_int _fresh_var
  in

  let printf_t : L.lltype = 
    L.var_arg_function_type void_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
    L.declare_function "printf" printf_t the_module in

  let function_decls : (L.llvalue * definition) StringMap.t =
    let function_decl m def = match def with 
    Def (name, _, def_typ, _) -> 
        let ftype = L.function_type (ltype_of_typ def_type) formal_types in
          StringMap.add name (L.define_function name def_type the_module, def) m in
    List.fold_left function_decl StringMap.empty definitions in
  
  (* Fill in the body of the given function *)
  let build_function_body = function 
    Def (name, _, _, body) -> 
      let (the_function, _) = StringMap.find name function_decls in
      let builder = L.builder_at_end context (L.entry_block def) in
      let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder in

      let rec llexpr builder ((_, e) : expr) = match e with
        | LitInt i -> L.const_int i32_t i
        | Apply (Var "print_int", Lit (LitInt i)) ->
              L.build_call printf_func [| int_format_str ; (llexpr builder e) |] fresh_var builder
        | _ -> raise (CodegenError "Not implemented")
      in
      llexpr body
    | _ -> raise (CodegenError "Unexpected case")
    in
  List.iter build_function_body defintions;
  the_module