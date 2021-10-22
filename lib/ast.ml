type operator =
  | PlusOp | MinusOp | TimesOp | DivideOp
  | LtOp | LeOp | GtOp | GeOp
  | EqOp | NeOp
  | OrOp | AndOp

(* separate var type out, because likely to change the representation of symbols *)
type var = string

type expr =
  | LitInt of int
  | Var of var
  | Binop of expr * operator * expr
  | Conditional of expr * expr * expr
