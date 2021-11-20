(* type variable name *)
type tvar_id = string

(* variable name *)
type var_id = string

(* type annotation *)
type typ =
  | TUnit
  | TInt
  | TBool
  | TChar
  | TString
  | TList of typ
  | TVar of tvar_id
  | TArrow of typ * typ
  | TNone

type program = Program of definition list

and definition = Def of var_id * expr

and expr =
  | Lit of typ * literal
  | Var of typ * var_id
  | Letin of typ * var_id * expr * expr
  | Lambda of typ * var_id * expr
  | Apply of typ * expr * expr
  | Match of typ * expr * (pat * expr) list

and literal =
  | LitInt of int
  | LitChar of char
  | LitString of string
  | LitList of expr list
  | LitBool of bool
  | LitUnit

and pat =
  | PatDefault of typ * var_id
  | PatLit of typ * literal
  | PatCons of typ * var_id * var_id
  | PatConsEnd of typ * var_id

let typ_of_expr = function
  | Lit (typ, _) -> typ
  | Var (typ, _) -> typ
  | Letin (typ, _, _, _) -> typ
  | Lambda (typ, _, _) -> typ
  | Apply (typ, _, _) -> typ
  | Match (typ, _, _) -> typ
