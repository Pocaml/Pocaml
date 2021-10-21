type operator = Add | Sub | Mul | Div | Assign | Separate

type expr =
  | Binop of expr * operator * expr
  | Conditional of expr * expr * expr
  | Lit of int
  | Var of string
