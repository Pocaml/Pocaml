open Ast

let rec string_of_typ = function
  | TVar tvar_id -> tvar_id
  | TCon tcon_id -> tcon_id
  | TApp (_, _) -> "TApp"
  | TArrow (t1, t2) -> string_of_typ t1 ^ " -> " ^ string_of_typ t2
  | TNone -> ""

let string_of_param = function
  | ParamAnn (var_id, typ) ->
      let typ_string = string_of_typ typ in
      if typ_string = "" then var_id
      else "( " ^ var_id ^ " : " ^ typ_string ^ " )"

let string_of_params = function
  | params -> String.concat " " (List.map string_of_param params)

let string_of_unop = function Not -> "_not"

let string_of_binop = function
  | PlusOp -> "_add"
  | MinusOp -> "_minus"
  | TimesOp -> "_times"
  | DivideOp -> "_divide"
  | LtOp -> "_less_than"
  | LeOp -> "_less_equal"
  | GtOp -> "_greater_than"
  | GeOp -> "_greater_equal"
  | EqOp -> "_equal"
  | NeOp -> "_not_equal"
  | OrOp -> "_or"
  | AndOp -> "_and"
  | ConsOp -> "_cons"
  | SeqOp -> "_seq"

let rec string_of_expr = function
  | Lit literal -> string_of_lit literal
  | Var id -> id
  | UnaryOp (op, e) -> string_of_unop op ^ " " ^ string_of_expr e
  | BinaryOp (e1, binop, e2) ->
      "( " ^ string_of_expr e1 ^ " " ^ string_of_binop binop ^ " "
      ^ string_of_expr e2 ^ " )"
  | Conditional (e1, e2, e3) ->
      let pred = string_of_expr e1 in
      let br1 = string_of_expr e2 in
      let br2 = string_of_expr e3 in
      "( if " ^ pred ^ " then " ^ br1 ^ " else " ^ br2 ^ " )"
  | Letin (id, e1, e2) ->
      "( let " ^ id ^ " = " ^ string_of_expr e1 ^ " in " ^ string_of_expr e2
      ^ " )"
  | Lambda (params, e) ->
      "( fun " ^ string_of_params params ^ " = " ^ string_of_expr e ^ " )"
  | Function arms ->
      "(\n function " ^ string_of_match_arms arms ^ "\n)"
  | Apply (e1, e2) -> "( " ^ string_of_expr e1 ^ " " ^ string_of_expr e2 ^ " )"
  | Match (e, lst) ->
      "(\n match " ^ string_of_expr e ^ " with\n" ^ string_of_match_arms lst
      ^ "\n)"
  | Annotation (expr, typ) ->
      let expr_string = string_of_expr expr in
      let typ_string = string_of_typ typ in
      "( " ^ expr_string ^ " : " ^ typ_string ^ " )"

and string_of_lit = function
  | LitInt int -> string_of_int int
  | LitString str -> "\"" ^ str ^ "\""
  | LitBool bool -> string_of_bool bool
  | LitChar char -> "\'" ^ String.make 1 char ^ "\'"
  | LitList list -> "[" ^ String.concat ";" (List.map string_of_expr list) ^ "]"
  | LitUnit -> "()"

and string_of_pattern = function
  | PatId id -> id
  | PatLit lit -> string_of_lit lit
  | PatCons (p1, p2) ->
      "( " ^ string_of_pattern p1 ^ " :: " ^ string_of_pattern p2 ^ " )"

and string_of_match_arm (pat, e) =
  "|  " ^ string_of_pattern pat ^ " -> " ^ string_of_expr e

and string_of_match_arms arms =
  String.concat "\n" (List.map string_of_match_arm arms)

let string_of_def = function
  | Def (var_id, params_opt, typ, expr) ->
      let type_str = string_of_typ typ in
      let formatted_type_str = if type_str = "" then "" else " : " ^ type_str in
      let params_str = string_of_params params_opt in
      let formatted_params_str =
        if params_str = "" then "" else " " ^ params_str
      in
      "let " ^ var_id ^ formatted_params_str ^ formatted_type_str ^ " = "
      ^ string_of_expr expr
  | DefRecFn (var_id, params_opt, typ, expr) ->
      let type_str = string_of_typ typ in
      let formatted_type_str = if type_str = "" then "" else " : " ^ type_str in
      let params_str = string_of_params params_opt in
      let formatted_params_str =
        if params_str = "" then "" else " " ^ params_str
      in
      "let rec " ^ var_id ^ formatted_params_str ^ formatted_type_str ^ " = "
      ^ string_of_expr expr

let string_of_program = function
  | Program defs -> String.concat "\n" (List.map string_of_def defs)

let print_prog = function
  | str ->
      let lexbuf = Lexing.from_string str in
      let prog = Parser.program Lexer.token lexbuf in
      print_endline (string_of_program prog)
