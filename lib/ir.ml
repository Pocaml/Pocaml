(* type variable name *)
type tvar_id = string

(* variable name *)
type var_id = string

(* variable name or underscore *)
type binder = string option

(* type annotation *)
type typ =
  | TUnit
  | TInt
  | TBool
  | TChar
  | TList of typ
  | TVar of tvar_id
  | TArrow of typ * typ
  | TNone

type program = Program of definition list

and definition = Def of binder * expr

and expr =
  | Lit of typ * literal
  | Var of typ * var_id
  | Letin of typ * binder * expr * expr
  | Lambda of typ * binder * expr
  | Apply of typ * expr * expr
  | Match of typ * expr * (pat * expr) list
  | Unit of typ

and literal =
  | LitInt of int
  | LitChar of char
  | LitList of expr list
  | LitBool of bool

and pat =
  | PatDefault of typ * binder
  | PatLit of typ * literal
  | PatCons of typ * binder * binder
  | PatConsEnd of typ * binder

let typ_of_expr = function
  | Lit (typ, _) -> typ
  | Var (typ, _) -> typ
  | Letin (typ, _, _, _) -> typ
  | Lambda (typ, _, _) -> typ
  | Apply (typ, _, _) -> typ
  | Match (typ, _, _) -> typ
  | Unit typ -> typ
