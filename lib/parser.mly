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

%nonassoc LET IN FUN MATCH WITH ARROW
%left PIPE
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
    /* nothing */    { [] }
  | def defs         { $1 :: $2 }

def:
    LET LEFT_PAREN VARIABLE COLON typ RIGHT_PAREN EQ expr    { Def($3, [], $5, $8) }
  | LET VARIABLE params_opt COLON typ EQ expr                { Def($2, $3, $5, $7) }
  | LET VARIABLE params_opt EQ expr                          { Def($2, $3, TNone, $5) }
  | LET REC VARIABLE params_opt COLON typ EQ expr            { DefRecFn($3, $4, $6, $8) }
  | LET REC VARIABLE params_opt EQ expr                      { DefRecFn($3, $4, TNone, $6)}

params_opt:
    /* no param */  { [] }
  | params          { $1 }

params:
    LEFT_PAREN VARIABLE COLON typ RIGHT_PAREN           { [ ParamAnn($2, $4) ] }
  | LEFT_PAREN VARIABLE COLON typ RIGHT_PAREN params    { ParamAnn($2, $4) :: $6 }
  | VARIABLE                                            { [ ParamAnn($1, TNone) ] }
  | VARIABLE params                                     { ParamAnn($1, TNone) :: $2 }

typ:
    VARIABLE LIST { TApp(TCon("list"), TVar($1)) }
  | VARIABLE      { TVar($1) }
  | LEFT_PAREN RIGHT_PAREN { TCon("()") }
  | typ ARROW typ { TArrow($1, $3) }

literal:
  | LEFT_BRAC list_literal RIGHT_BRAC   { LitList($2) }
  | LITINT                              { LitInt($1) }
  | LITBOOL                             { LitBool($1) }
  | LITSTRING                           { LitString($1) }
  | LITCHAR                             { LitChar($1) }
  | LEFT_PAREN RIGHT_PAREN              { LitUnit }

list_literal:
    /* empty list */        { [] } 
  | expr SEMI list_literal  { $1 :: $3 }

apply:
    apply atom { Apply($1, $2) }
  | atom { $1 }

atom:
    literal { Lit($1) }
  | var { $1 }
  | LEFT_PAREN expr COLON typ RIGHT_PAREN { Annotation($2, $4) }
  | LEFT_PAREN expr RIGHT_PAREN { $2 }

expr:
    NOT expr         { UnaryOp(Not, $2) }
  | expr PLUS   expr { BinaryOp($1, PlusOp, $3) }
  | expr MINUS  expr { BinaryOp($1, MinusOp, $3) }
  | expr TIMES  expr { BinaryOp($1, TimesOp, $3) }
  | expr DIVIDE expr { BinaryOp($1, DivideOp, $3) }
  | IF expr THEN expr ELSE expr { Conditional($2, $4, $6) }
  | LET VARIABLE EQ expr IN expr { Letin($2, $4, $6) }
  | MATCH expr WITH match_arms { Match($2, $4) }
  | FUN params ARROW expr { Lambda($2, $4) }
  | apply { $1 }


var:
  VARIABLE         { Var($1) }

match_arms:
    PIPE pat ARROW expr { [($2, $4)] }
  | PIPE pat ARROW expr match_arms { ($2, $4) :: $5 }

pat:
    VARIABLE  { PatId($1) }
  | literal   { PatLit($1) }
  | pat CONS pat  { PatCons($1, $3) }
