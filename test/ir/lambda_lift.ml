open Pocaml
open Pocaml.Print_ir


let print_prog_ll = function
  | str ->
      let lexbuf = Lexing.from_string str in
      let prog = Parser.program Lexer.token lexbuf in
      Lower_ast.lower_program prog |> Lambda_lift.lambda_lift |> string_of_program |> print_endline

let%expect_test "lift lambdas in list" =
  print_prog_ll "let lambda_list : int -> int list = ([(fun (a:int) -> (a:int) : int -> int); (fun (b:int) -> (b:int) : int -> int);] : int -> int list)";
  [%expect {|
    let L1 = ( ( fun a -> ( a : int ) ) : int -> None )
    let L2 = ( ( fun b -> ( b : int ) ) : int -> None )
    let lambda_list = ( ( ( ( ( _cons : None ) ( L1 : int -> None ) ) : None ) ( ( ( ( ( _cons : None ) ( L2 : int -> None ) ) : None ) ( [] : None ) ) : None ) ) : int -> int ) |}]

let%expect_test "lift lambdas in letin expression" =
  print_prog_ll "let (a : int -> int) = let a = (3 : int) in (fun (b: int) -> ((b : int) + (a : int) : int) : int -> int)";
  [%expect {|
    let L3 = ( ( fun a -> ( ( fun b -> ( ( ( ( ( _add : None ) ( b : int ) ) : None ) ( a : int ) ) : int ) ) : int -> None ) ) : int -> int -> None )
    let a = ( let ( a : int -> int ) = ( 3 : int ) in ( ( ( L3 : int -> int -> None ) ( a : int ) ) : int -> None ) ) |}]

let%expect_test "lift lambdas in letin expression 2" =
  print_prog_ll " let f = let a = 3 in (fun b -> let c = 6 in (fun d -> b : int -> int) : int -> int -> int)";
  [%expect {|
    let L4 = ( ( fun a -> ( ( fun b -> ( ( fun c -> ( ( fun d -> ( b : None ) ) : None -> None ) ) : None -> None -> None ) ) : None -> None -> None -> None ) ) : None -> None -> None -> None -> None )
    let L5 = ( ( fun a -> ( ( fun b -> ( let ( c : None ) = ( 6 : None ) in ( ( ( ( ( ( ( L4 : None -> None -> None -> None -> None ) ( a : None ) ) : None -> None -> None -> None ) ( b : None ) ) : None -> None -> None ) ( c : None ) ) : None -> None ) ) ) : None -> None ) ) : None -> None -> None )
    let f = ( let ( a : None ) = ( 3 : None ) in ( ( ( L5 : None -> None -> None ) ( a : None ) ) : None -> None ) ) |}]

let%expect_test "lift lambdas in match arms" =
  print_prog_ll "let a = match 3 with | 3 -> fun b -> b | 4 -> fun c -> c";
  [%expect {|
    let L6 = ( ( fun b -> ( b : None ) ) : None -> None )
    let L7 = ( ( fun c -> ( c : None ) ) : None -> None )
    let a = ( (
     match ( 3 : None ) with
    |  ( 3 : None ) -> ( L6 : None -> None )
    |  ( 4 : None ) -> ( L7 : None -> None )
    ) : None ) |}]

let%expect_test "lift lambdas in expr being patterned match on" =
  print_prog_ll "
    let a = (
      match (let a = 3 in
        (fun (b : int) -> (a : int) : int -> int)
        : int -> int)
      with | _ -> 0
      : int)
  ";
  [%expect {|
    let L8 = ( ( fun a -> ( ( fun b -> ( a : int ) ) : int -> None ) ) : None -> int -> None )
    let a = ( (
     match ( let ( a : int -> int ) = ( 3 : None ) in ( ( ( L8 : None -> int -> None ) ( a : None ) ) : int -> None ) ) with
    |  ( U1 : None ) -> ( 0 : None )
    ) : int ) |}]

let%expect_test "don't lift top level lambdas" =
  print_prog_ll "let f = fun a -> fun b -> a";
  [%expect {|
    let f = ( ( fun a -> ( ( fun b -> ( a : None ) ) : None -> None ) ) : None -> None ) |}]
  
let%expect_test "don't lift immediately nested lambdas" =
  print_prog_ll "let a = let a = 1 in fun b -> fun c -> a";
  [%expect {|
    let L9 = ( ( fun a -> ( ( fun b -> ( ( fun c -> ( a : None ) ) : None -> None ) ) : None -> None ) ) : None -> None -> None )
    let a = ( let ( a : None ) = ( 1 : None ) in ( ( ( L9 : None -> None -> None ) ( a : None ) ) : None -> None ) ) |}]

let%expect_test "lift not immediately nested lambda" =
  print_prog_ll "let f = fun a -> let b = 1 in fun c -> a";
  [%expect {|
    let L10 = ( ( fun a -> ( ( fun b -> ( ( fun c -> ( a : None ) ) : None -> None ) ) : None -> None -> None ) ) : None -> None -> None -> None )
    let f = ( ( fun a -> ( let ( b : None ) = ( 1 : None ) in ( ( ( ( ( L10 : None -> None -> None -> None ) ( a : None ) ) : None -> None -> None ) ( b : None ) ) : None -> None ) ) ) : None -> None ) |}]

let %expect_test "lift lambda in application" =
  print_prog_ll "let a = ((fun a -> a) 3) + 4";
  [%expect {|
    let L11 = ( ( fun a -> ( a : None ) ) : None -> None )
    let a = ( ( ( ( ( _add : None ) ( ( ( L11 : None -> None ) ( 3 : None ) ) : None ) ) : None ) ( 4 : None ) ) : None ) |}]