(*
   function codegen: m_program -> llvm optional
*)

module L = Llvm
open Ir
module StringMap = Map.Make (String)

exception CodegenError of string

let error s = raise (CodegenError s)

let not_implemented () = error "Not implemented"

(* translate : I.program -> Llvm.module *)
let codegen = function
  | Program definitions ->
      let context = L.global_context () in
      let the_module = L.create_module context "pocaml" in

      (* Get types from the context *)
      let i32_t = L.i32_type context
      and i8_t = L.i8_type context
      and i1_t = L.i1_type context (*and void_t     = L.void_type   context*) in
      (* let get_typ = function A.LitInt   -> i32_t in *)
      let ltype_of_typ = function
        | TVar _ -> raise (CodegenError "Cannot have type variables.")
        | TInt -> i32_t
        | TChar -> i8_t
        | TBool -> i1_t
        | TUnit -> i8_t
        | TList _ -> raise (CodegenError "TApp type is not supported.")
        | TArrow (_, _) -> raise (CodegenError "TArrow type is not supported.")
        | TNone -> raise (CodegenError "Cannot have unknown types.")
        (* | _ -> raise (CodegenError "Type is not supported.") *)
      in
      let ltype_of_expr e = ltype_of_typ (typ_of_expr e) in

      (*
  let fresh_var =
    let _fresh_var = ref 1 in
      _fresh_var := _fresh_var + 1;
      string_of_int _fresh_var
  in
  *)
      let fresh_var =
        let n = ref 0 in
        fun () ->
          n := !n + 1;
          string_of_int !n
      in

      let printf_t : L.lltype =
        L.var_arg_function_type i32_t [| L.pointer_type i8_t |]
      in
      let printf_func : L.llvalue =
        L.declare_function "printf" printf_t the_module
      in

      let function_decls : (L.llvalue * definition) StringMap.t =
        let function_decl m def =
          match def with
          | Def (dbinder, dexpr) -> (
              match dbinder with
              | Some dname ->
                  StringMap.add dname
                    ( L.define_function dname (ltype_of_expr dexpr) the_module,
                      def )
                    m
              | None -> not_implemented ())
        in
        List.fold_left function_decl StringMap.empty definitions
      in

      (* Fill in the body of the given function *)
      let build_function_body = function
        | Def (dbinder, dexpr) -> (
            match dbinder with
            | Some dname ->
                let the_function, _ = StringMap.find dname function_decls in
                let builder =
                  L.builder_at_end context (L.entry_block the_function)
                in
                let int_format_str =
                  L.build_global_stringptr "%d\n" "fmt" builder
                in

                let rec llexpr builder (e : expr) =
                  match e with
                  | Lit (_, LitInt i) -> L.const_int i32_t i
                  | Apply (_, Var (_, "print_int"), Lit (_, LitInt _)) ->
                      L.build_call printf_func
                        [| int_format_str; llexpr builder e |]
                        (fresh_var ()) builder
                  | _ -> raise (CodegenError "Unexpected case")
                in
                ignore (L.build_ret (llexpr builder dexpr) builder)
            | None -> not_implemented ())
      in

      List.iter build_function_body definitions;
      the_module
