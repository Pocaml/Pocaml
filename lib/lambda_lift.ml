open Ir
open Fresh

exception LambdaLiftError of string

let error s = raise (LambdaLiftError s)

(* creates an Application of var to a lambda *)
let apply_actual (e : expr) (var : expr) =
   let l_type = match typ_of_expr e with TArrow(t1, _) -> t1 | _ -> error "BUG" in
   Apply(l_type, e, var)

let rec add_formal_helper (formal : string) (ty : typ) = function
     Lambda(ty, id, body) -> Lambda(ty, id, add_formal_helper formal ty body)
   | e ->  Lambda(TArrow(ty, typ_of_expr e), formal, e) 

(* adds a formal parameter to a lambda to create a new lambda *)
let add_formal (lambda : expr) (var : expr) =
   let formal_name = match var with | Var(_, n) -> n | _ ->  error "passed non variable expr into context"
   in match lambda with Lambda(ty, _, _) ->
         let (h_t, ret_t) = match ty with TArrow(t1, t2) -> t1, t2 | _ -> error "BUG" in 
         let new_lambda_typ = TArrow(TArrow(h_t, typ_of_expr var), ret_t) in
            add_formal_helper formal_name new_lambda_typ lambda
      | _ -> error "BUG"

(*
   function lift:
   Ir.program -> Ir.expr list -> Ir.expr -> (Ir.expr * Ir.program)
*)
let rec lift (p : program) (ctx : expr list) = function
     Lambda(_, _, e) as l -> 
      (* recursively lower e *)
      let (_, p') = lift p ctx e in
      let lambda_with_closure = List.fold_left add_formal l ctx in
      let lambda_name = fresh_lambda_name () in
      let lifted_lambda_def = Def(lambda_name, lambda_with_closure) in
      let lifted_lambda_var = Var(typ_of_expr lambda_with_closure, lambda_name) in
      let new_expr = List.fold_left apply_actual lifted_lambda_var ctx in
      (* create a global definition *)
      let defs = match p' with Program ds -> ds in
      new_expr, Program(lifted_lambda_def :: defs)
   | Letin(ty, id, e1, e2) ->
      let e1', p1 = lift p ctx e1 in
      let e2', p2 = lift p1 (Var(typ_of_expr e1, id) :: ctx) e2 in
      Letin(ty, id, e1', e2'), p2
   | e -> e, p

(*
   function lambda_lift: Ir.program -> Ir.program
*)
let lambda_lift (p : program) = 
   let defs = match p with Program ds -> ds in
   let lift_def (p: program) (d : definition) =
      let (id, e) = match d with Def(id, e) -> id, e in
      let (e', p') = lift p [] e in
      let defs = match p' with Program ds -> ds in
      let new_def = Def(id, e') in
         Program(List.rev (new_def :: defs))
   in
      List.fold_left lift_def (Program([])) defs
