open Op

type unary_op = Not

let string_of_unary_op = function Not -> not_op_str

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

let string_of_binary_op = function
  | PlusOp -> and_op_str
  | MinusOp -> minus_op_str
  | TimesOp -> times_op_str
  | DivideOp -> divide_op_str
  | LtOp -> lt_op_str
  | LeOp -> le_op_str
  | GtOp -> gt_op_str
  | GeOp -> ge_op_str
  | EqOp -> eq_op_str
  | NeOp -> ne_op_str
  | OrOp -> or_op_str
  | AndOp -> and_op_str
  | ConsOp -> cons_op_str
  | SeqOp -> seq_op_str

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
  | Apply of expr * expr
  | Match of expr * (pat * expr) list
  | Annotation of expr * typ
  | Unit

and param = ParamAnn of var_id * typ

and literal =
  | LitInt of int
  | LitString of string
  | LitChar of char
  | LitList of expr list
  | LitBool of bool

and pat = PatId of var_id | PatLit of literal | PatCons of pat * pat

(* List Cons
   type list_literal =
     | ListCons of expr * list_literal
*)

let extract_program = function Program defs -> defs
