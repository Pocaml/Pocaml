%{ open Ast %}

%token EOF
%token <int> LITINT
%token <string> LITSTRING
%token <char> LITCHAR
%token <bool> LITBOOL
%token <string> VARIABLE                                     
%token SEMI LIST LEFT_BRAC RIGHT_BRAC                       
%token NOT                                                   
%token PLUS MINUS TIMES DIVIDE LT LE GT GE EQ NE OR AND CONS 
%token IF THEN ELSE                                          
%token LET IN                                               
%token FUN REC                                                
%token MATCH WITH PIPE                                      
%token ARROW
%token LEFT_PAREN RIGHT_PAREN
%token COLON                                                

%nonassoc LET IN FUN MATCH WITH PIPE ARROW
%right SEMI
%nonassoc IF THEN ELSE
%right OR AND
%left LT LE GT GE EQ NE
%right CONS
%left PLUS MINUS
%left TIMES DIVIDE
%nonassoc NOT

%start expr
%type <Ast.expr> expr

%%

program:
| definition program { Program ($1 :: extract_program $2) }
| definition { Program [$1] }

definition:
| LET VARIABLE param COLON type EQ expr { DefFn($2, $3, $5, $7) }
| LET VARIABLE param EQ expr { DefFn($2, $3, TNone, $5)}
| LET REC VARIABLE param COLON type EQ expr { DefFnRec($3, $4, $6, $8) }
| LET REC VARIABLE param EQ expr { DefFnRec($3, $4, TNone, $6)}

param:
| LEFT_PAREN VARIABLE COLON type RIGHT_PAREN { ParamAnn($2, $4) }
| VARIABLE param { }
| VARIABLE       { }

type:
| VARIABLE LIST { TApp(TCon("list"), TVar($1)) }
| VARIABLE      { }

list_literal:
| expr SEMI list_literal { ListConstruct($1, $3) }
|                        { [] }

expr:
  expr PLUS   expr { Binop($1, PlusOp, $3) }
| expr MINUS  expr { Binop($1, MinusOp, $3) }
| expr TIMES  expr { Binop($1, TimesOp, $3) }
| expr DIVIDE expr { Binop($1, DivideOp, $3) }
| IF expr THEN expr ELSE expr { Conditional($2, $4, $6) }
| LET var EQ expr IN expr { Letin($2, $4, $6) }
| LEFT_BRAC list_literal RIGHT_BRAC { $2 }
| LITINT          { LitInt($1) }
| LITBOOL         { LitBool($1) }
| VARIABLE        { Var($1) }


var:
  VARIABLE         { Var_id($1) }