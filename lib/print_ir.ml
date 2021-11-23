open Ir


exception PrintIrError of string
let error s = raise (PrintIrError s)
let rec string_of_typ = function
  | TUnit -> "unit"
  | TInt -> "int"
  | TBool -> "bool"
  | TChar -> "char"
  | TList typ -> string_of_typ typ
  | TVar tvar_id -> tvar_id
  | TArrow (t1, t2) -> string_of_typ t1 ^ " -> " ^ string_of_typ t2
  | TNone -> "None"
  | TString -> "string"

let annotate typ id = 
  let type_str = string_of_typ typ in match type_str with
  | "" -> id
  | typ_str -> "( " ^ id ^ " : " ^ typ_str ^ " )"


let rec string_of_expr = function
  | Lit (typ, literal) -> annotate typ (string_of_lit literal)
  | Var (typ, id) -> annotate typ id
  | Letin (typ, id, e1, e2) ->
      "( let " ^ annotate typ id ^ " = " ^ string_of_expr e1 ^ " in " ^ string_of_expr e2
      ^ " )"
  | Lambda (typ, var_id, e) ->
      annotate typ ("( fun " ^ var_id ^ " -> " ^ string_of_expr e ^ " )")
  | Apply (typ, e1, e2) -> annotate typ ("( " ^ string_of_expr e1 ^ " " ^ string_of_expr e2 ^ " )")
  | Match (typ, e, lst) -> 
      annotate typ ("(\n match " ^ string_of_expr e ^ " with\n" ^ string_of_match_arms lst ^ "\n)")

and string_of_lit = function
  | LitInt int -> string_of_int int
  | LitBool bool -> string_of_bool bool
  | LitChar char -> "\'" ^ String.make 1 char ^ "\'"
  | LitList list -> "[" ^ String.concat ";" (List.map string_of_expr list) ^ "]"
  | LitUnit -> "()"
  | LitString str -> "\"" ^ str ^ "\""

and string_of_pattern = function
  | PatDefault (typ, id) -> annotate typ id
  | PatLit (typ, lit) -> annotate typ (string_of_lit lit)
  | PatCons (typ, id1, id2) ->
      annotate typ ("( " ^ id1 ^ " :: " ^ id2 ^ " )")
  | PatConsEnd (typ, id) -> annotate typ id

and string_of_match_arm (pat, e) =
  "|  " ^ string_of_pattern pat ^ " -> " ^ string_of_expr e

and string_of_match_arms arms =
  String.concat "\n" (List.map string_of_match_arm arms)

let string_of_def = function
  | Def (var_id, expr) ->
     (* let type_str = string_of_typ typ in
      let formatted_type_str = if type_str = "" then "" else " : " ^ type_str in
      let params_str = string_of_params params_opt in
      let formatted_params_str =
        if params_str = "" then "" else " " ^ params_str
      in*)
      ("let " ^ var_id ^ " = " ^ string_of_expr expr)

let string_of_program = function
  | Program defs -> String.concat "\n" (List.map string_of_def defs)

let print_prog = function
  | str ->
      let lexbuf = Lexing.from_string str in
      let prog = Parser.program Lexer.token lexbuf in
      print_endline (string_of_program(Lower_ast.lower_program(prog)))

let print_prog_ll = function
  | str ->
      let lexbuf = Lexing.from_string str in
      let prog = Parser.program Lexer.token lexbuf in
      Lower_ast.lower_program prog |> Lambda_lift.lambda_lift |> string_of_program |> print_endline