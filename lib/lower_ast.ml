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

and lower_expr annotation =
  let default_typ = match annotation with
      Some typ -> typ
    | None -> I.TNone
  in function
      (A.Lit lit) -> lower_lit lit
    | (A.Var "print_int") -> I.Var ((I.TArrow (I.TInt, I.TUnit)), "print_int")
    | (A.Annotation (e, t)) -> lower_expr (Some (lower_typ t)) e
    | (A.Apply (e1, e2)) -> I.Apply (default_typ, (lower_expr None e1), (lower_expr None e2))
    | _ -> not_implemented

and lower_pat = not_implemented

(* Note: the typ here is wrong *)
(* need to work on setting the type right *)
and lower_lambda aparams atyp abody = match aparams with
    [] -> (match atyp with
          A.TNone -> lower_expr None abody
        | _ -> lower_expr (Some (lower_typ atyp)) abody)
  | (ParamAnn (avar_id, atyp)::ps) -> I.Lambda ((lower_typ atyp), binder_of_var_id avar_id, lower_lambda ps atyp abody)

and lower_lit = function
    A.LitInt i -> I.Lit (I.TInt, I.LitInt i)
  | _ -> not_implemented

and lower_typ = function
    A.TVar tvar_id -> I.TVar tvar_id
  | A.TCon "int" -> I.TInt
  | A.TCon "bool" -> I.TBool
  | A.TCon "char" -> I.TChar
  | A.TCon "()" -> I.TUnit
  | A.TCon "string" -> I.TList TChar
  | A.TApp (A.TCon "list", t) -> I.TList (lower_typ t)
  | A.TArrow (t1, t2) -> I.TArrow ((lower_typ t1), (lower_typ t2))
  | A.TNone -> I.TNone
  | _ -> error "Can't lower this type."

and binder_of_var_id (avar_id: A.var_id) = match avar_id with
  "_" -> None
| _ -> Some avar_id