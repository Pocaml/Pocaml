(*
   function codegen: m_program -> llvm optional
*)

module L = Llvm
(* module StringMap = Map.Make (String) *)

let codegen () =
  let context = L.global_context () in
  let the_module = L.create_module context "pocaml" in

  let i32_t = L.i32_type context and i8_t = L.i8_type context in

  (* declare a printf function *)
  let printf_t : L.lltype =
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |]
  in
  let (printf_func : L.llvalue) =
    L.declare_function "printf" printf_t the_module
  in

  (* declare a null function global with same type as printf *)
  let (printf_func2 : L.llvalue) =
    let printf_func2_t = L.pointer_type printf_t in
    let init = L.const_pointer_null printf_func2_t in
    L.define_global "printf_func2" init the_module
  in

  (* define an int global *)
  let (int_global : L.llvalue) =
    let (init : L.llvalue) = L.const_int i32_t 0 in
    L.define_global "int_global" init the_module
  in

  (* define another int global with int_global *)
  let (_ : L.llvalue) =
    let init = int_global in
    L.define_global "int_global2" init the_module
  in

  (* define a function *)
  let _ =
    let ftype = L.function_type i32_t [| i32_t |] in
    let func = L.define_function "func" ftype the_module in
    let param = Array.get (L.params func) 0 in
    let entry_block = L.entry_block func in
    let builder = L.builder_at_end context entry_block in
    (* change func parameter name *)
    let () = L.set_value_name "fun_param" param in
    (* add a local variable *)
    let local1 = L.build_alloca i32_t "local1" builder in
    (* store fun_param into local1 *)
    let _ = L.build_store param local1 builder in
    (* return param *)
    L.build_ret param builder
  in

  (* define a function that takes a function *)
  let _ =
    let pfunctype = L.pointer_type (L.function_type i32_t [| i32_t |]) in
    let ftype = L.function_type i32_t [| pfunctype |] in
    let func = L.define_function "func2" ftype the_module in
    let pfunc = Array.get (L.params func) 0 in
    let entry_block = L.entry_block func in
    let builder = L.builder_at_end context entry_block in
    (* change func parameter name *)
    let () = L.set_value_name "pfunc" pfunc in
    (* call the pfunc *)
    let _ =
      L.build_call pfunc [| L.const_int i32_t 69 |] "pfunc_result" builder
    in
    (* return a constant int *)
    L.build_ret (L.const_int i32_t 420) builder
  in

  (* define a function that updates global function var *)
  let _ =
    let ftype = L.function_type i32_t [| i32_t |] in
    let func = L.define_function "func3" ftype the_module in
    let entry_block = L.entry_block func in
    let builder = L.builder_at_end context entry_block in
    let _ = L.build_store printf_func printf_func2 builder in
    (* let _ = L.build_store int_global (L.const_int i32_t 123) builder in *)
    (* return void *)
    L.build_ret (L.const_int i32_t 69) builder
  in
  the_module
