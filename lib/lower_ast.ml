module A = Ast
module I = Ir

exception LowerAstError of string

let error s = raise (LowerAstError s)
let not_implemented = error "Not implemented"

(* A.program -> I.program *)
let rec lower_program = function 
  (A.Program defs) -> I.Program (List.map lower_def defs)

(* A.definition -> (I.binder * I.Expr)*)
and lower_def = function
  (A.Def (avar, aparams, atyp, abody)) -> I.Def (Some avar, lower_lambda aparams atyp abody)
| (A.DefRecFn (avar, aparams, atyp, abody)) -> I.Def (Some avar, lower_lambda aparams atyp abody)

and lower_expr = not_implemented

and lower_pat = not_implemented

and lower_lambda = not_implemented

and lower_lit = not_implemented