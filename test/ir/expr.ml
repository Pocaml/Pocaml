open Pocaml.Print_ir

let%expect_test "annotated literal" =
  print_prog "let (a : int) = (3 : int)";
  [%expect {| let a = ( 3 : int ) |}]

let%expect_test "annotated variable" =
  print_prog "let _ = let a = 3 in (a : int)";
  [%expect {| let _ = ( let ( a : None ) = ( 3 : None ) in ( a : int ) ) |}]

let%expect_test "annotated expr with unary operator" =
  print_prog "let a = (not true : bool)";
  [%expect {| let a = ( ( ( not : None ) ( true : None ) ) : bool ) |}]

let%expect_test "annotated expr with binary operator" =
  print_prog "let a = (3 + 5 : int)";
  [%expect {| let a = ( ( ( ( ( + : None ) ( 3 : None ) ) : None ) ( 5 : None ) ) : int ) |}]

let%expect_test "annotated conditional expression" =
  print_prog "let a = (if true then 1 else 2 : int)";
  [%expect {|
    let a = ( (
     match ( true : None ) with
    |  ( true : None ) -> ( 1 : None )
    |  ( false : None ) -> ( 2 : None )
    ) : int ) |}]

let%expect_test "annotated let in expression" =
  print_prog "let a = (let b = 3 in b : int)";
  [%expect {| let a = ( let ( b : int ) = ( 3 : None ) in ( b : None ) ) |}]

let%expect_test "annotated lambda expression" =
  print_prog "let a = (fun (a: int) -> (a + 1 : int) : int -> int)";
  [%expect
    {| let a = ( ( fun a -> ( ( ( ( ( + : None ) ( a : None ) ) : None ) ( 1 : None ) ) : int ) ) : int -> None ) |}]

let%expect_test "annotated function application" =
  print_prog "let a = (print (\"hello\" : string) : ())";
  [%expect {| let a = ( ( ( print : None ) ( "hello" : string ) ) : unit ) |}]

let%expect_test "annotated function application with multiple arguments" =
  print_prog "let a = (fn 0 f 1 : bool)";
  [%expect {| let a = ( ( ( ( ( ( ( fn : None ) ( 0 : None ) ) : None ) ( f : None ) ) : None ) ( 1 : None ) ) : bool ) |}]

(* TODO: add test case for annotated match expression *)
let%expect_test "annotated match expression" =
  print_prog "let a = ( match 3 with | _ -> 1 : int )";
  [%expect {|
    let a = ( (
     match ( 3 : None ) with
    |  ( U1 : None ) -> ( 1 : None )
    ) : int ) |}]