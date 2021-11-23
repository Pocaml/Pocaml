open Pocaml.Print_ir


let%expect_test "closure" =
  print_prog_ll "let (a : int -> int) = let a = (3 : int) in (fun (b: int) -> ((b : int) + (a : int) : int) : int -> int)";
  [%expect {|
    let L1 = ( ( fun b -> ( ( fun a -> ( ( ( ( ( + : None ) ( b : int ) ) : None ) ( a : int ) ) : int ) ) : int -> None -> int ) ) : int -> None )
    let a = ( let ( a : int -> int ) = ( 3 : int ) in ( ( ( L1 : int -> None ) ( a : int ) ) : int ) ) |}]