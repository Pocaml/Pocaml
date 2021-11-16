type unary_op =
  | Not

type binary_op =
  | PlusOp | MinusOp | TimesOp | DivideOp
  | LtOp | LeOp | GtOp | GeOp
  | EqOp | NeOp
  | OrOp | AndOp
  | ConsOp
  | SeqOp

(* type variable name *)
type tvar_id = string

(* variable name *)
type var_id = string

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

type program = Program of (var_id * expr) list
and expr =
  | Lit of typ * literal
  | Var of typ * var_id
  | UnaryOp of typ * unary_op * expr
  | BinaryOp of typ * expr * binary_op * expr
  | Letin of typ * binder * expr * expr
  | Lambda of typ * binder * expr
  | Apply of typ * expr * expr
  | Match of typ * expr * (pat * expr) list
and literal = 
  | LitInt of int
  | LitChar of char
  | LitList of expr list
  | LitBool of bool
and pat =
  | PatDefault of binder
  | PatLit of literal
  | PatCons of pat * pat