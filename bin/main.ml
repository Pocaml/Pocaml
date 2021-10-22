open Pocaml
open Pocaml.Ast


let _ =
  let rec printAstTree = function
      Lit(x)            -> string_of_int x
    | Conditional(e1, e2, e3) -> "( if " ^ (printAstTree e1) ^ " then " ^ (printAstTree e2) ^ " else " ^ (printAstTree e3) ^ " )"
    (* print_string "( if ";
       printAstTree e1;
       print_string " then ";
       printAstTree e2;
       print_string " else ";
       printAstTree e3;
       print_string " )";  *)
    | Binop(e1, op, e2) ->
      let astTreeE1 = printAstTree e1 in
      let astTreeE2 = printAstTree e2 in
      let opStr =
        (match op with
           Add -> "+"
         | Sub -> "-"
         | Mul -> "*"
         | Div -> "/"
         | _ -> ""
        ) in
      ("(" ^ astTreeE1 ^ opStr ^ astTreeE2 ^ ")")
    | _ -> ""
  in
  let lexbuf = Lexing.from_channel stdin in
  let expr = Parser.expr (Lexer.token) lexbuf in
  let tree = printAstTree expr in
  print_endline tree
