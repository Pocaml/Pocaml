open Pocaml.Print_ir

let%expect_test "annotated literal" =
  print_prog_ll "let (a : int) = (3 : int)";
  [%expect {| |}]