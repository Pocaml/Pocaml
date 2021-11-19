open Pocaml.Print_ir

(* open Pocaml.Parser *)
(* open Pocaml.Lexer *)

let%expect_test _ =
  print_prog "let fn (a: int) : int = 3";
  [%expect {| let fn = ( fun ( a : int -> int ) = ( 3 : int ) ) |}]

let%expect_test _ =
  print_prog "let fn (a: int) = 3";
  [%expect {| let fn = ( fun ( a : int ->  ) = 3 ) |}]

let%expect_test _ =
  print_prog "let rec fn (a: int): int = 3";
  [%expect {| let fn = ( fun ( a : int -> int ) = ( 3 : int ) ) |}]

let%expect_test _ =
  print_prog "let rec fn (a: int) b (c: int): int = 3";
  [%expect {| let fn = ( fun ( a : int ->  -> int -> int ) = ( fun ( b :  -> int -> int ) = ( fun ( c : int -> int ) = ( 3 : int ) ) ) ) |}]

let%expect_test _ =
  print_prog "let a: int = 3";
  [%expect {| let a = ( 3 : int ) |}]

let%expect_test _ =
  print_prog "let a = \"some string\"";
  [%expect {| let a = ['s';'o';'m';'e';' ';'s';'t';'r';'i';'n';'g'] |}]

let%expect_test _ =
  print_prog "let a = false";
  [%expect {| let a = false |}]

let%expect_test _ =
  print_prog "let a = 'c'";
  [%expect {| let a = 'c' |}]

let%expect_test _ =
  print_prog "let a = [1;2;3;]";
  [%expect {| let a = [1;2;3] |}]