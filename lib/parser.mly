%{ open Ast %}

%token IF THEN ELSE
%token PLUS MINUS TIMES DIVIDE EOF
%token <int> LITERAL
%token <string> VARIABLE

%left IF THEN ELSE
%left PLUS MINUS
%left TIMES DIVIDE

%start expr
%type <Ast.expr> expr

%%

expr:
  expr PLUS   expr { Binop($1, PlusOp, $3) }
| expr MINUS  expr { Binop($1, MinusOp, $3) }
| expr TIMES  expr { Binop($1, TimesOp, $3) }
| expr DIVIDE expr { Binop($1, DivideOp, $3) }
| IF expr THEN expr ELSE expr { Conditional($2, $4, $6) }
| LITERAL          { LitInt($1) }
| VARIABLE         { Var($1) }
