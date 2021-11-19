open Stupidlib

let () =
  let m = Codegen.codegen () in
  Llvm_analysis.assert_valid_module m;
  print_string (Llvm.string_of_llmodule m)
