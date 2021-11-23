(*
   function lambda_lift: Ir.program -> Ir.program
*)

open Ir
open Fresh

exception LambdaLiftError of string

let error s = raise (LambdaLiftError s)
let lambda_lift (p : program) = p


(*
   function lift:
   Ir.program -> Ir.expr list -> Ir.expr -> (Ir.expr * Ir.program)
*)
let rec lift (p : program) (ctx : expr list) = function
      Lambda(_, _, e) as l -> 
      (* 1. recursively lower e *)
      let (_, p') = lift p ctx e in
      (* adds a formal parameter to a lambda to create a new lambda *)
      let add_formal (lambda : expr) (var : expr) =
         let formal_name =
            match var with
               | Var(_, n) -> n
               | _ ->  error "passed non variable expr into context"
         in match lambda with
               Lambda(_, _, _) ->
                  let (h_t, ret_t) = match typ_of_expr var with
                     TArrow(t1, t2) -> t1, t2
                     | _ -> error "BUG"
               in
                  Lambda(
                     TArrow(TArrow(h_t, typ_of_expr var), ret_t),
                     formal_name,
                     lambda)
            | _ -> error "BUG" 
      in
         let new_lambda = List.fold_left add_formal l ctx in
         let l_name = fresh_lambda_name () in
         let add_actual (e : expr) (var : expr) =
            let l_type = match typ_of_expr e with TArrow(t1, _) -> t1 | _ -> error "BUG" in
            Apply(l_type, e, var)
         in let lifted_lambda_def = Def(l_name, new_lambda) in
         let lifted_lambda_var = Var(typ_of_expr new_lambda, l_name) in
         let new_expr = List.fold_left add_actual lifted_lambda_var ctx in
         (* create a global definition *)
         let defs = match p' with Program ds -> ds in
         new_expr, Program(lifted_lambda_def :: defs)
   | Letin(ty, id, e1, e2) ->
      let e1', p1 = lift p ctx e1 in
      let e2', p2 = lift p1 (Var(typ_of_expr e1, id) :: ctx) e2 in
      Letin(ty, id, e1', e2'), p2
   | e -> e, p