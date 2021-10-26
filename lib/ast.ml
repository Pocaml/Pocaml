type operator =
  | PlusOp | MinusOp | TimesOp | DivideOp
  | LtOp | LeOp | GtOp | GeOp
  | EqOp | NeOp
  | OrOp | AndOp

(* separate var type out, because likely to change the representation of symbols *)
type var = 
  | Var_id of string

type expr =
  | LitInt of int
  | Var of string
  | Binop of expr * operator * expr
  | Conditional of expr * expr * expr
  | Letin of var * expr * expr

