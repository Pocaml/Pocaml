module A = Ast
module I = Ir
(* open Op *)

exception LowerAstError of string

let error s = raise (LowerAstError s)

let not_implemented () = error "Not implemented"

let rec annotate t1 t2 =
  match (t1, t2) with
  | t1, I.TNone -> t1
  | I.TNone, t2 -> t2
  | t1, I.TVar _ -> t1
  | I.TVar _, t2 -> t2
  | I.TBool, I.TBool -> I.TBool
  | I.TChar, I.TChar -> I.TChar
  | I.TInt, I.TInt -> I.TInt
  | I.TUnit, I.TUnit -> I.TUnit
  | I.TArrow (t11, t12), I.TArrow (t21, t22) ->
      I.TArrow (annotate t11 t21, annotate t12 t22)
  | I.TList t1', I.TList t2' -> I.TList (annotate t1' t2')
  | _ -> error "Can't collapse type annotation"

let no_annotation = annotate I.TNone

(* A.program -> I.program *)
let rec lower_program = function
  | A.Program defs -> I.Program (List.map lower_def defs)

(* A.definition -> (I.binder * I.Expr)*)
and lower_def = function
  | A.Def (avar, aparams, atyp, abody) ->
      I.Def (Some avar, lower_lambda aparams atyp abody)
  | A.DefRecFn (avar, aparams, atyp, abody) ->
      I.Def (Some avar, lower_lambda aparams atyp abody)

and lower_expr ann = function
  | A.Lit lit -> I.Lit (ann I.TNone, lower_lit lit)
  | A.Var var_id -> I.Var (ann I.TNone, var_id)
  | A.UnaryOp (aop, e) -> lower_unary_op ann aop e
  | A.BinaryOp (e1, aop, e2) -> lower_binary_op ann aop e1 e2
  | A.Annotation (e, t) -> lower_expr (annotate (ann (lower_typ t))) e
  | A.Apply (e1, e2) -> lower_apply ann e1 e2
  | _ -> not_implemented ()

(* and lower_pat ()= not_implemented *)

and lower_unary_op ann aop e =
  I.Apply
    ( ann I.TNone,
      I.Var (I.TNone, A.string_of_unary_op aop),
      lower_expr no_annotation e )

and lower_binary_op ann aop e1 e2 =
  I.Apply
    ( ann I.TNone,
      I.Apply
        ( I.TNone,
          I.Var (I.TNone, A.string_of_binary_op aop),
          lower_expr no_annotation e1 ),
      lower_expr no_annotation e2 )

and lower_apply ann e1 e2 =
  I.Apply (ann I.TNone, lower_expr no_annotation e1, lower_expr no_annotation e2)

(* Note: the typ here is wrong *)
and lower_lambda aparams atyp abody =
  match aparams with
  | [] -> (
      match atyp with
      | A.TNone -> lower_expr no_annotation abody
      | _ -> lower_expr (annotate (lower_typ atyp)) abody)
  | ParamAnn (avar_id, atyp) :: ps ->
      I.Lambda
        (lower_typ atyp, binder_of_var_id avar_id, lower_lambda ps atyp abody)

and lower_lit = function A.LitInt i -> I.LitInt i | _ -> not_implemented ()

and lower_typ = function
  | A.TVar tvar_id -> I.TVar tvar_id
  | A.TCon "int" -> I.TInt
  | A.TCon "bool" -> I.TBool
  | A.TCon "char" -> I.TChar
  | A.TCon "()" -> I.TUnit
  | A.TCon "string" -> I.TList TChar
  | A.TApp (A.TCon "list", t) -> I.TList (lower_typ t)
  | A.TArrow (t1, t2) -> I.TArrow (lower_typ t1, lower_typ t2)
  | A.TNone -> I.TNone
  | _ -> error "Can't lower this type."

and binder_of_var_id (avar_id : A.var_id) =
  match avar_id with "_" -> None | _ -> Some avar_id
