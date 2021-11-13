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

literal:
  | LEFT_BRAC list_literal RIGHT_BRAC { LitList($2) }
  | LITINT          { LitInt($1) }
  | LITBOOL         { LitBool($1) }


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
  | var             { $1 }
  | literal         { Lit($1) }
  | MATCH expr WITH match_arms { }

var:
  VARIABLE         { Var($1) }

match_arms:
    PIPE pat ARROW expr { }
  | PIPE pat ARROW expr match_arms {}

pat:
    VARIABLE  { }
  | literal   { }
  | pat CONS pat  { }
