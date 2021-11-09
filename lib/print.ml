open Ast


let string_of_def = function
      Def(var_id, params, typ, expr) -> "Def"
    | DefRecFn(var_id, params, typ, expr) -> "DefRecFn"

let string_of_program = function
    Program(defs) -> String.concat "\n" (List.map string_of_def defs)


let _ =
  let lexbuf = Lexing.from_channel stdin in
  let prog = Parser.program (Lexer.token) lexbuf in
      print_endline (string_of_program prog)
