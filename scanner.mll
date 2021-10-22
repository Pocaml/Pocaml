{ open Parser }

let blanks = [' ' '\t' '\r' '\n']+
let digit = ['0'-'9']
let uppercase = ['A'-'Z']
let lowercase = ['a'-'z']
let letter = [uppercase lowercase]
let capitalized_ident = uppercase [letter digit '_' "'"]*
let lowercase_ident = [lowercase '_'] [letter digit '_' "'"]*
let integer_literal = ['-']? digit [digit '_']*
let regular_char = [^ "'" '\\']

rule tokenize = parse
  [' ' '\t' '\r' '\n'] { tokenize lexbuf }
| '+' { PLUS }
| '-' { MINUS }
| '*' { TIMES }
| '/' { DIVIDE }
| "if" { IF }
| "then" { THEN }
| "else" { ELSE }
| ['0'-'9']+ as lit { LITERAL(int_of_string lit) }
| ['a'-'z']+ as var { VARIABLE(var) }
| eof { EOF }
