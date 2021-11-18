module A = Ast
module I = Ir

exception LowerAstError of string

let error s = raise (LowerAstError s)

let not_implemented () = error "Not implemented"

let rec char_list_of_string = function
  | "" -> []
  | s ->
      String.get s 0
      :: char_list_of_string (String.sub s 1 (String.length s - 1))

let binder_of_avar_id = function "_" -> None | s -> Some s

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

and lower_def = function
  | A.Def (avar, aparams, atyp, abody) ->
      I.Def (Some avar, lower_lambda no_annotation aparams atyp abody)
  | A.DefRecFn (avar, aparams, atyp, abody) ->
      I.Def (Some avar, lower_lambda no_annotation aparams atyp abody)

and lower_expr ann = function
  | A.Lit lit -> lower_lit ann lit
  | A.Var var_id -> I.Var (ann I.TNone, var_id)
  | A.UnaryOp (aop, e) -> lower_unary_op ann aop e
  | A.BinaryOp (e1, aop, e2) -> lower_binary_op ann aop e1 e2
  | A.Conditional (cond, e1, e2) -> lower_conditional ann cond e1 e2
  | A.Letin (avar_id, e1, e2) -> lower_letin ann avar_id e1 e2
  | A.Lambda (ps, e) -> lower_lambda ann ps A.TNone e
  | A.Apply (e1, e2) -> lower_apply ann e1 e2
  (* | A.Match (e, pats) -> lower_match ann e pats *)
  | A.Match (_, _) -> error "Lowering pattern-match is not implemented"
  | A.Annotation (e, t) -> lower_expr (annotate (ann (lower_typ t))) e

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

and lower_conditional ann cond e1 e2 =
  I.Match
    ( ann I.TNone,
      lower_expr no_annotation cond,
      [
        (I.PatLit (I.LitBool true), lower_expr no_annotation e1);
        (I.PatLit (I.LitBool false), lower_expr no_annotation e2);
      ] )

and lower_letin ann var_id e1 e2 =
  if var_id = "_" then
    I.Letin
      ( ann I.TNone,
        None,
        lower_expr no_annotation e1,
        lower_expr no_annotation e2 )
  else
    I.Letin
      ( ann I.TNone,
        Some var_id,
        lower_expr no_annotation e1,
        lower_expr no_annotation e2 )

and lower_apply ann e1 e2 =
  I.Apply (ann I.TNone, lower_expr no_annotation e1, lower_expr no_annotation e2)

and lower_lambda ann aparams aoutput_typ abody =
  let rec get_lambda_ityp = function
    | [] -> lower_typ aoutput_typ
    | A.ParamAnn (_, atyp) :: ps -> I.TArrow (lower_typ atyp, get_lambda_ityp ps)
  in
  let lambda_ityp = get_lambda_ityp aparams in
  match aparams with
  | [] -> lower_expr (annotate (ann lambda_ityp)) abody
  | ParamAnn (avar_id, _) :: aps ->
      I.Lambda
        ( lambda_ityp,
          binder_of_avar_id avar_id,
          lower_lambda no_annotation aps aoutput_typ abody )

(* and lower_match ann e pats = *)
(*   let typ' = ann I.TNone in *)
(*   let e' = lower_expr e in *)
(*   let pats' = map (lower_pat no_annotation) pats in *)
(*   I.Match (typ', e', pats') *)

(* and lower_pat ann = function *)
(*   | A.PatId avar_id -> I.PatDefault (binder_of_avar_id avar_id) *)
(*   | A.PatLit lit -> I.PatLit lit *)
(*   | A.PatCons *)

and lower_lit ann alit =
  let i_expr_of_char c = I.Lit (I.TNone, I.LitChar c) in
  let ilit =
    match alit with
    | A.LitInt i -> I.LitInt i
    | A.LitChar c -> I.LitChar c
    | A.LitBool b -> I.LitBool b
    | A.LitList es -> I.LitList (List.map (lower_expr no_annotation) es)
    | A.LitString s ->
        I.LitList (List.map i_expr_of_char (char_list_of_string s))
  in
  I.Lit (ann I.TNone, ilit)

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
  | A.TCon _ -> error "Can't lower any TCon besides built-in types"
  | A.TApp _ -> error "Can't lower any TApp besides list"

and binder_of_var_id (avar_id : A.var_id) =
  match avar_id with "_" -> None | _ -> Some avar_id
