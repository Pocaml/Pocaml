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
   Ir.program -> Ir.expr list -> Ir.expr -> (Ir.expr * Ir.program)
*)
let rec lift (p : program) (ctx : expr list) = function
  | Lit (ty, lit) ->
      let lit', p' =
        match lit with
        (* Only LitList may associate with expr that contains lambda *)
        | LitList es ->
            let lift_lambda_in_list (es, p) e =
              let e', p' = lift p ctx e in
              (e' :: es, p')
            in
            let es', p' = List.fold_left lift_lambda_in_list ([], p) es in
            (LitList (List.rev es'), p')
        | lit -> (lit, p)
      in
      (Lit (ty, lit'), p')
  | Lambda (ty, id, e) ->
      let e', p' = lift p ctx e in
      let l = Lambda (ty, id, e') in
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
  | Letin (ty, id, e1, e2) ->
      let e1', p1 = lift p ctx e1 in
      let e2', p2 = lift p1 (Var (typ_of_expr e1, id) :: ctx) e2 in
      (Letin (ty, id, e1', e2'), p2)
  | Apply (ty, e1, e2) ->
      let e1', p1 = lift p ctx e1 in
      let e2', p2 = lift p1 ctx e2 in
      (Apply (ty, e1', e2'), p2)
  | Match (ty, e1, cases) ->
    (*
      takes in
        - an accumalator (program, context, list of match arms seen)
        - next match arm to lift lambdas from
      returns the updated accumulator
    *)
      let lift_lambda_in_case (p, ctx, lst) (pat, e) =
        let lift_lambda_in_pat (p : program) = function
          | PatLit (ty, lit) ->
              let lit_expr, p' = lift p ctx (Lit (ty, lit)) in
              let lit' =
                match lit_expr with Lit (_, lit) -> lit | _ -> error "BUG"
              in
              (PatLit (ty, lit'), p')
          | pat -> (pat, p)
        in
        let update_ctx ctx = function
          | PatDefault (ty, id) -> List.rev (Var (ty, id) :: ctx)
          | PatLit (_, _) -> ctx
          | PatCons (ty, id1, id2) ->
              List.rev (Var (ty, id2) :: Var (ty, id1) :: ctx)
          | PatConsEnd (ty, id) -> List.rev (Var (ty, id) :: ctx)
        in
        let pat', p' = lift_lambda_in_pat p pat in
        let ctx' = update_ctx ctx pat' in
        let e', p'' = lift p' ctx' e in
        (p'', ctx, (pat', e') :: lst)
      in
      let e1', p' = lift p ctx e1 in
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
    let e', p' = lift p [] e in
    let defs = extract_defs p' in
    let new_def = Def (id, e') in
    (* defs are in reverse order *)
    Program (new_def :: defs)
  in
  let lifted_program = List.fold_left lift_def (Program []) defs in
  Program (List.rev (extract_defs lifted_program))
