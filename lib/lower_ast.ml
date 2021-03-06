module A = Ast
module I = Ir
module P = Print
open Fresh

exception LowerAstError of string

let error s = raise (LowerAstError s)

let not_implemented () = error "Not implemented"

let rec char_list_of_string = function
  | "" -> []
  | s ->
      String.get s 0
      :: char_list_of_string (String.sub s 1 (String.length s - 1))

let fresh_if_wild = function "_" -> fresh_name () | s -> s

let rec annotate t1 t2 =
  match (t1, t2) with
  | t1, I.TNone -> t1
  | I.TNone, t2 -> t2
  | t1, I.TVar _ -> t1
  | I.TVar _, t2 -> t2
  | I.TBool, I.TBool -> I.TBool
  | I.TChar, I.TChar -> I.TChar
  | I.TInt, I.TInt -> I.TInt
  | I.TString, I.TString -> I.TString
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
      I.Def (fresh_if_wild avar, lower_lambda no_annotation aparams atyp abody)
  | A.DefRecFn (avar, aparams, atyp, abody) ->
      I.Def (fresh_if_wild avar, lower_lambda no_annotation aparams atyp abody)

and lower_expr ann = function
  | A.Lit lit -> lower_lit ann lit
  | A.Var var_id -> I.Var (ann I.TNone, var_id)
  | A.UnaryOp (aop, e) -> lower_unary_op ann aop e
  | A.BinaryOp (e1, aop, e2) -> lower_binary_op ann aop e1 e2
  | A.Conditional (cond, e1, e2) -> lower_conditional ann cond e1 e2
  | A.Letin (avar_id, e1, e2) -> lower_letin ann avar_id e1 e2
  | A.Lambda (ps, e) -> lower_lambda ann ps A.TNone e
  | A.Function arms -> lower_function ann arms
  | A.Apply (e1, e2) -> lower_apply ann e1 e2
  | A.Match (e, arms) -> lower_match ann e arms
  | A.Annotation (e, t) -> lower_expr (annotate (ann (lower_typ t))) e

and lower_function ann arms =
  let n = fresh_name () in
  let match' = lower_match no_annotation (A.Var n) arms in
  I.Lambda
    ( ann I.TNone,
      n,
      match')

and lower_unary_op ann aop e =
  I.Apply
    ( ann I.TNone,
      I.Var (I.TNone, P.string_of_unop aop),
      lower_expr no_annotation e )

and lower_binary_op ann aop e1 e2 =
  I.Apply
    ( ann I.TNone,
      I.Apply
        ( I.TNone,
          I.Var (I.TNone, P.string_of_binop aop),
          lower_expr no_annotation e1 ),
      lower_expr no_annotation e2 )

and lower_conditional ann cond e1 e2 =
  I.Match
    ( ann I.TNone,
      lower_expr no_annotation cond,
      [
        (I.PatLit (I.TNone, I.LitBool true), lower_expr no_annotation e1);
        (I.PatLit (I.TNone, I.LitBool false), lower_expr no_annotation e2);
      ] )

and lower_letin ann var_id e1 e2 =
  I.Letin
    ( ann I.TNone,
      fresh_if_wild var_id,
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
          fresh_if_wild avar_id,
          lower_lambda no_annotation aps aoutput_typ abody )

and lower_match ann e arms =
  let typ' = ann I.TNone in
  let e' = lower_expr no_annotation e in
  let lower_arm = function
    | arm_pat, arm_e -> (lower_pat arm_pat, lower_expr no_annotation arm_e)
  in
  let arms' = List.map lower_arm arms in
  I.Match (typ', e', arms')

and lower_pat =
  let lower_literal = function
    | A.LitInt i -> I.LitInt i
    | A.LitChar c -> I.LitChar c
    | A.LitBool b -> I.LitBool b
    | A.LitList [] -> I.LitListEnd
    | A.LitList _ -> error "Can't lower pattern matching on non-emtpy list"
    | A.LitString s -> I.LitString s
    | A.LitUnit -> I.LitUnit
  in
  function
  | A.PatId avar_id -> I.PatDefault (I.TNone, fresh_if_wild avar_id)
  | A.PatLit lit -> I.PatLit (I.TNone, lower_literal lit)
  | A.PatCons (pat1, pat2) -> (
      match (pat1, pat2) with
      | A.PatId avar_id1, A.PatId avar_id2 ->
          I.PatCons (I.TNone, fresh_if_wild avar_id1, fresh_if_wild avar_id2)
      | A.PatId avar_id1, A.PatLit (A.LitList []) ->
          I.PatConsEnd (I.TNone, fresh_if_wild avar_id1)
      | _ -> error "Can't lower recursive patterns yet")

and lower_lit ann alit =
  match alit with
  | A.LitInt i -> I.Lit (ann I.TNone, I.LitInt i)
  | A.LitChar c -> I.Lit (ann I.TNone, I.LitChar c)
  | A.LitBool b -> I.Lit (ann I.TNone, I.LitBool b)
  | A.LitList [] -> I.Lit (ann I.TNone, I.LitListEnd)
  | A.LitList (e :: es) ->
      let outerCons x =
        I.Apply
          ( ann I.TNone,
            I.Apply
              ( I.TNone,
                I.Var (I.TNone, Print.string_of_binop ConsOp),
                lower_expr no_annotation e ),
            x )
      in
      let innerCons =
        List.fold_right
          (fun e l ->
            I.Apply
              ( I.TNone,
                I.Apply
                  (I.TNone, I.Var (I.TNone, Print.string_of_binop ConsOp), e),
                l ))
          (List.map (lower_expr no_annotation) es)
          (I.Lit (I.TNone, I.LitListEnd))
      in
      outerCons innerCons
  | A.LitString s -> I.Lit (ann I.TNone, I.LitString s)
  | A.LitUnit -> I.Lit (ann I.TNone, I.LitUnit)

and lower_typ = function
  | A.TVar tvar_id -> I.TVar tvar_id
  | A.TCon "int" -> I.TInt
  | A.TCon "bool" -> I.TBool
  | A.TCon "char" -> I.TChar
  | A.TCon "()" -> I.TUnit
  | A.TCon "string" -> I.TString
  | A.TApp (A.TCon "list", t) -> I.TList (lower_typ t)
  | A.TArrow (t1, t2) -> I.TArrow (lower_typ t1, lower_typ t2)
  | A.TNone -> I.TNone
  | A.TCon _ -> error "Can't lower any TCon besides built-in types"
  | A.TApp _ -> error "Can't lower any TApp besides list"
