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
    if typ_string = "" then var_id else
      "( " ^ var_id ^ " : " ^ typ_string ^ " )"

let string_of_params = function
  params -> String.concat " " (List.map string_of_param params)

let string_of_lit = function
  LitInt(int) -> string_of_int int
  | _ -> "some other lit"
  (* | LitString of string
  | LitChar of char
  | LitList of expr list
  | LitBool of bool *)

let string_of_expr = function
    Lit(literal) -> string_of_lit literal
  | _ -> "some other expr"
  (* | Var of var_id
  | UnaryOp of unary_op * expr
  | BinaryOp of expr * binary_op * expr
  | Conditional of expr * expr * expr
  | Letin of var_id * expr * expr
  | Lambda of param list * expr
  | Apply of expr * expr
  | Match of expr * (pat * expr) list *)

let string_of_def = function
      Def(var_id, params_opt, typ, expr) ->
      let type_str = string_of_typ typ in
      let formatted_type_str = if type_str = "" then "" else (" : " ^ type_str) in
      let params_str = string_of_params params_opt in
      let formatted_params_str = if params_str = "" then "" else " " ^ params_str in
      "let " ^ var_id ^ formatted_params_str ^ formatted_type_str ^ " = " ^ string_of_expr expr
    | DefRecFn(var_id, params_opt, typ, expr) ->
      let type_str = string_of_typ typ in
      let formatted_type_str = if type_str = "" then "" else (" : " ^ type_str) in
      let params_str = string_of_params params_opt in
      let formatted_params_str = if params_str = "" then "" else " " ^ params_str in
      "let rec " ^ var_id ^ formatted_params_str ^ formatted_type_str ^ " = " ^ string_of_expr expr

let string_of_program = function
    Program(defs) -> String.concat "\n" (List.map string_of_def defs)

let print_prog = function
    str -> let lexbuf = Lexing.from_string str in
    let prog = Parser.program (Lexer.token) lexbuf in
    print_endline (string_of_program prog)

let _ =
  let lexbuf = Lexing.from_channel stdin in
  let prog = Parser.program (Lexer.token) lexbuf in
      print_endline (string_of_program prog)

