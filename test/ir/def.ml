open Pocaml.Print

(* open Pocaml.Parser *)
(* open Pocaml.Lexer *)

let%expect_test _ =
  print_prog "let a: () = ()";
  [%expect {| let a : () = Not Implemented |}]
