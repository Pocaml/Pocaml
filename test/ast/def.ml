open Pocaml.Print
(* open Pocaml.Parser *)
(* open Pocaml.Lexer *)


let%expect_test _ =
  print_prog "let fn (a: int) : int = 3";
  [%expect{| let fn ( a : int ) : int = 3 |}]

let%expect_test _ =
  print_prog "let fn (a: int) = 3";
  [%expect{| let fn ( a : int ) = 3 |}]

let%expect_test _ =
  print_prog "let rec fn (a: int): int = 3";
  [%expect{| let rec fn ( a : int ) : int = 3 |}]

let%expect_test _ =
  print_prog "let rec fn (a: int) b (c: int): int = 3";
  [%expect{| let rec fn ( a : int ) b ( c : int ) : int = 3 |}]

let%expect_test _ =
  print_prog "let a: int = 3";
  [%expect{| let a : int = 3 |}]

