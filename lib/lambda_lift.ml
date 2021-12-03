open Ir
open Print_ir
open Fresh

exception LambdaLiftError of string

let error s = raise (LambdaLiftError s)

(* helper to extract list of definitions from a program *)
let extract_defs = function Program defs -> defs

(* creates an application of var to a lambda *)
let apply_actual (e : expr) (var : expr) =
  let l_type =
    match typ_of_expr e with
    | TArrow (t1, _) -> t1
    | ty ->
        error
          ("[ Lambda_lift.apply_actual ] apply " ^ string_of_expr var
         ^ " to expr (" ^ string_of_expr e
         ^ ") : expected type TArrow, but has " ^ string_of_typ ty)
  in
  Apply (l_type, e, var)

let rec add_formal_helper (formal : string) (formal_t : typ) = function
  | Lambda (ty, id, body) ->
      Lambda (TArrow (ty, formal_t), id, add_formal_helper formal formal_t body)
  | e -> Lambda (TArrow (formal_t, typ_of_expr e), formal, e)

(* adds a formal parameter to a lambda to create a new lambda *)
let add_formal (lambda : expr) (var : expr) =
  let formal_t, formal_name =
    match var with
    | Var (ty, n) -> (ty, n)
    | _ ->
        let actual_typ = typ_of_expr var in
        error
          ("[ Lambda_lift.add_formal ] expected a Var, but "
         ^ string_of_expr var ^ "is of type " ^ string_of_typ actual_typ)
  in
  add_formal_helper formal_name formal_t lambda

(*
   function lift:
   bool -> Ir.program -> Ir.expr list -> Ir.expr -> (Ir.expr * Ir.program)

   switch (bool)
    - avoid lifing nested lambdas: we turn off switch when we recursivly
      lift lambda in expr inside a Lambda
    - avoid lifting top-level lambdas: turn off switch when we lift expr inside
      a top-level declaration
*)
let rec lift switch (p : program) (ctx : expr list) = function
  | Lambda (ty, id, e) ->
      let rec get_id_typ = function
        | TArrow(a,b) -> get_id_typ a
        | ty -> ty
      in
      let id_typ = get_id_typ ty in
      let e', p' = lift false p (Var(id_typ, id) :: ctx) e in
      let l = Lambda (ty, id, e') in
      if switch then
        (* add closure as parameters to lambda *)
        let lambda_with_closure = List.fold_left add_formal l ctx in
        let lambda_name = fresh_lambda_name () in
        (* create a global definition *)
        let lifted_lambda_def = Def (lambda_name, lambda_with_closure) in
        let lifted_lambda_var =
          Var (typ_of_expr lambda_with_closure, lambda_name)
        in
        (* substitute original lambda with named function applied with params in closure *)
        let new_expr = List.fold_left apply_actual lifted_lambda_var ctx in
        (* update global definition *)
        let defs = match p' with Program ds -> ds in
        (new_expr, Program (lifted_lambda_def :: defs))
      else
        (l, p')
  | Letin (ty, id, e1, e2) ->
      let e1', p1 = lift true p ctx e1 in
      let e2', p2 = lift true p1 (Var (typ_of_expr e1, id) :: ctx) e2 in
      (Letin (ty, id, e1', e2'), p2)
  | Apply (ty, e1, e2) ->
      let e1', p1 = lift true p ctx e1 in
      let e2', p2 = lift true p1 ctx e2 in
      (Apply (ty, e1', e2'), p2)
  | Match (ty, e1, cases) ->
    (*
      takes in
        - an accumalator (program, context, list of match arms seen)
        - next match arm to lift lambdas from
      returns the updated accumulator
    *)
      let lift_lambda_in_case (p, ctx, lst) (pat, e) =
        (* no expr in pat -> don't have to worry about lifting lambdas in pat *)
        let update_ctx ctx = function
          | PatDefault (ty, id) -> List.rev (Var (ty, id) :: ctx)
          | PatLit (_, _) -> ctx
          | PatCons (ty, id1, id2) ->
              List.rev (Var (ty, id2) :: Var (ty, id1) :: ctx)
          | PatConsEnd (ty, id) -> List.rev (Var (ty, id) :: ctx)
        in
        let ctx' = update_ctx ctx pat in
        let e', p' = lift true p ctx' e in
        (p', ctx, (pat, e') :: lst)
      in
      let e1', p' = lift true p ctx e1 in
      let p'', _, cases' =
        List.fold_left lift_lambda_in_case (p', ctx, []) cases
      in
      (Match (ty, e1', List.rev cases'), p'')
  | e -> (e, p)

(*
   function lambda_lift: Ir.program -> Ir.program
*)
let lambda_lift (p : program) =
  let defs = extract_defs p in
  let lift_def (p : program) (d : definition) =
    let id, e = match d with Def (id, e) -> (id, e) in
    let e', p' = lift false p [] e in
    let defs = extract_defs p' in
    let new_def = Def (id, e') in
    (* defs are in reverse order *)
    Program (new_def :: defs)
  in
  let lifted_program = List.fold_left lift_def (Program []) defs in
  Program (List.rev (extract_defs lifted_program))
