open Pocaml.Print_ir


let%expect_test _ =
  print_prog "let fn (a: int) : int = 3";
  [%expect {| let fn = ( ( fun a -> ( 3 : int ) ) : int -> int ) |}]

let%expect_test _ =
  print_prog "let fn (a: int) = 3";
  [%expect {| let fn = ( ( fun a -> ( 3 : None ) ) : int -> None ) |}]

let%expect_test _ =
  print_prog "let rec fn (a: int): int = 3";
  [%expect {| let fn = ( ( fun a -> ( 3 : int ) ) : int -> int ) |}]

let%expect_test _ =
  print_prog "let rec fn (a: int) b (c: int): int = 3";
  [%expect {| let fn = ( ( fun a -> ( ( fun b -> ( ( fun c -> ( 3 : int ) ) : int -> int ) ) : None -> int -> int ) ) : int -> None -> int -> int ) |}]

let%expect_test _ =
  print_prog "let a: int = 3";
  [%expect {| let a = ( 3 : int ) |}]

let%expect_test _ =
  print_prog "let a = \"some string\"";
  [%expect {| let a = ( "some string" : None ) |}]

let%expect_test _ =
  print_prog "let a = false";
  [%expect {| let a = ( false : None ) |}]

let%expect_test _ =
  print_prog "let a = 'c'";
  [%expect {| let a = ( 'c' : None ) |}]

let%expect_test _ =
  print_prog "let a = [1;2;3;]";
  [%expect {| let a = ( ( ( ( ( :: : None ) ( 1 : None ) ) : None ) ( ( ( ( ( :: : None ) ( 2 : None ) ) : None ) ( ( ( ( ( :: : None ) ( 3 : None ) ) : None ) ( [] : None ) ) : None ) ) : None ) ) : None ) |}]

let%expect_test _ =
  print_prog "let a: () = ()";
  [%expect {| let a = ( () : unit ) |}]
