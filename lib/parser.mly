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

%start program
%type <Ast.program> program

%%

program:
  defs EOF { Program ($1) }

defs:
  /* nothing */ { [] }
  | def defs { $1 :: $2 }

def:
    LET VARIABLE param COLON typ EQ expr { Def($2, $3, $5, $7) }
  | LET VARIABLE param EQ expr { Def($2, $3, TNone, $5)}
  | LET REC VARIABLE param COLON typ EQ expr { DefRecFn($3, $4, $6, $8) }
  | LET REC VARIABLE param EQ expr { DefRecFn($3, $4, TNone, $6)}

param:
    LEFT_PAREN VARIABLE COLON typ RIGHT_PAREN { [ParamAnn($2, $4)] }
  | VARIABLE       { [ParamAnn($1, TNone)] }
  | VARIABLE param { ParamAnn($1, TNone) :: $2 }

typ:
    VARIABLE LIST { TApp(TCon("list"), TVar($1)) }
  | VARIABLE      { TVar($1) }

list_literal:
    /* empty list */        { [] } 
  | expr SEMI list_literal  { $1 :: $3 }

expr:
    expr PLUS   expr { BinaryOp($1, PlusOp, $3) }
  | expr MINUS  expr { BinaryOp($1, MinusOp, $3) }
  | expr TIMES  expr { BinaryOp($1, TimesOp, $3) }
  | expr DIVIDE expr { BinaryOp($1, DivideOp, $3) }
  | IF expr THEN expr ELSE expr { Conditional($2, $4, $6) }
  | LET VARIABLE EQ expr IN expr { Letin($2, $4, $6) }
  | LEFT_BRAC list_literal RIGHT_BRAC { Lit(LitList($2)) }
  | LITINT          { Lit(LitInt($1)) }
  | LITBOOL         { Lit(LitBool($1)) }
  | var             { $1 }


var:
  VARIABLE         { Var($1) }
