module A = Ast
module I = Ir

exception LowerAstError of string

let error s = raise (LowerAstError s)
let not_implemented = error "Not implemented"

(* A.program -> I.program *)
let lowerProgram = function 
  (Program defs) -> I.Program (List.map lowerDef defs)

(* A.definition -> (I.binder * I.Expr)*)
let lowerDef = function
  (Def (avar, aparams, atyp, abody)) -> (some avar, lowerLambda aparams atyp abody))
| (DefRecFn (avar, aparams, atyp, abody)) -> (some avar, lowerLambda aparams atyp abody))

let lowerExpr = not_implemented

let lowerPat = not_implemented

let lowerLambda = not_implemented

let lowerLit = not_implemented