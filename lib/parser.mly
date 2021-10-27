%{ open Ast %}

%token EOF
%token <int> LITINT
%token <string> LITSTRING
%token <char> LITCHAR
%token <bool> LITBOOL
%token SEMI LIST LEFT_BRAC RIGHT_BRAC                             (* List *)
%token <string> VARIABLE                                     (* Var *)
%token NOT                                                   (* UnaryOp *)
%token PLUS MINUS TIMES DIVIDE LT LE GT GE EQ NE OR AND CONS (* BinaryOp *)
%token IF THEN ELSE                                          (* Conditional *)
%token LET IN                                                (* Letin *)
%token FUN                                                   (* Lambda *)
%token MATCH WITH PIPE                                       (* Match *)
%token ARROW
%token LEFT_PAREN RIGHT_PAREN
%token COLON                                                 (* type annotation *)

%nonassoc LET IN FUN MATCH WITH PIPE ARROW
%left SEMI
%nonassoc IF THEN ELSE
%left OR
%left AND
%left LT LE GT GE EQ NE
%right CONS
%left PLUS MINUS
%left TIMES DIVIDE
%nonassoc NOT

%start expr
%type <Ast.expr> expr
%type <Ast.var> var

%%

program:
| definition program { Program ($1 :: extract_program $2) }
| definition { Program [$1] }

definition:
| LET VARIABLE param COLON type EQ expr { DefFn($2, $3, $5, $7) }
| LET VARIABLE param EQ expr { DefFn($2, $3, TNone, $5)}
| LET REC VARIABLE param COLON type EQ expr { DefFnRec($3, $4, $6, $7) }
| LET REC VARIABLE param EQ expr { DefFnRec($3, $4, TNone, $7)}

param:
| LEFT_PAREN VARIABLE COLON type RIGHT_PAREN { ParamAnn($2, $4) }
| VARIABLE param
| VARIABLE

type:
| VARIABLE LIST { TApp(TCon("list"), TVar($1)) }
| VARIABLE

expr:
  expr PLUS   expr { Binop($1, PlusOp, $3) }
| expr MINUS  expr { Binop($1, MinusOp, $3) }
| expr TIMES  expr { Binop($1, TimesOp, $3) }
| expr DIVIDE expr { Binop($1, DivideOp, $3) }
| IF expr THEN expr ELSE expr { Conditional($2, $4, $6) }
| LET var EQ expr IN expr { Letin($2, $4, $6) }
| LITERAL          { LitInt($1) }
| VARIABLE         { Var($1) }

var:
  VARIABLE         { Var_id($1) }
