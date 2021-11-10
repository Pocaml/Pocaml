open Ast

let string_of_typ = function
  | TVar(tvar_id) -> tvar_id
  | TCon(tcon_id) -> tcon_id
  | TApp(_, _) -> "TApp" 
  | TArrow(_, _) -> "TArrow" 
  | TNone -> ""

let string_of_param = function
  | ParamAnn(var_id, typ) -> 
    let typ_string = string_of_typ typ in
    if typ_string == "" then var_id else
      "( " ^ var_id ^ " : " ^ typ_string ^ " )"

let string_of_params = function
  params -> String.concat " " (List.map string_of_param params)


let string_of_def = function
      (* Def(var_id, params_opt, typ, expr) -> "Def" *)
      Def(_, _, _, _) -> "Def"
    | DefRecFn(_, _, _, _) -> "DefRecFn"

let string_of_program = function
    Program(defs) -> String.concat "\n" (List.map string_of_def defs)


let _ =
  let lexbuf = Lexing.from_channel stdin in
  let prog = Parser.program (Lexer.token) lexbuf in
      print_endline (string_of_program prog)

