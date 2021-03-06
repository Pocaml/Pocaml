type unary_op = Not

type binary_op =
  | PlusOp
  | MinusOp
  | TimesOp
  | DivideOp
  | LtOp
  | LeOp
  | GtOp
  | GeOp
  | EqOp
  | NeOp
  | OrOp
  | AndOp
  | ConsOp
  | SeqOp

(* type variable name *)
type tvar_id = string

(* type constructor name *)
type tcon_id = string

(* data constructor name *)
type dcon_id = string

(* variable name *)
type var_id = string

(* type annotation *)
type typ =
  | TVar of tvar_id
  | TCon of tcon_id
  | TApp of typ * typ
  | TArrow of typ * typ
  | TNone

type program = Program of definition list

and definition =
  | Def of var_id * param list * typ * expr
  | DefRecFn of var_id * param list * typ * expr

and expr =
  | Lit of literal
  | Var of var_id
  | UnaryOp of unary_op * expr
  | BinaryOp of expr * binary_op * expr
  | Conditional of expr * expr * expr
  | Letin of var_id * expr * expr
  | Lambda of param list * expr
  | Function of (pat * expr) list
  | Apply of expr * expr
  | Match of expr * (pat * expr) list
  | Annotation of expr * typ

and param = ParamAnn of var_id * typ

and literal =
  | LitInt of int
  | LitString of string
  | LitChar of char
  | LitList of expr list
  | LitBool of bool
  | LitUnit

and pat = PatId of var_id | PatLit of literal | PatCons of pat * pat

(* List Cons
   type list_literal =
     | ListCons of expr * list_literal
*)

let extract_program = function Program defs -> defs
