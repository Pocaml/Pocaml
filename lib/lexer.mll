{
  open Parser

  module L = Lexing

  exception Error

  type token = Parser.token
}

let blanks = [' ' '\t' '\r' '\n']+
let digit = ['0'-'9']
let bool_literal = ('True' | 'False')
let uppercase = ['A'-'Z']
let lowercase = ['a'-'z']
let letter = (uppercase | lowercase)
let string_literal = (letter | digit | '_' | '\'')
let capitalized_ident = uppercase string_literal*
let lowercase_ident = (lowercase | '_') string_literal*
let integer_literal = ['-']? digit (digit | '_')*
let regular_char = [^ '\'' '\\'] 

rule token = parse
  blanks { token lexbuf }
| "(*" { comment [lexbuf.L.lex_start_p] lexbuf }
| '+' { PLUS }
| '-' { MINUS }
| '*' { TIMES }
| '/' { DIVIDE }
| "not" { NOT }
| ";"  { SEMI }
| "list" { LIST }
| "["    { LEFT_BRAC }
| "]"    { RIGHT_BRAC }
| "("    { LEFT_PAREN }
| ")"    { RIGHT_PAREN }
| "if" { IF }
| "then" { THEN }
| "else" { ELSE }
| "let" { LET }
| "in"  { IN }
| "function" { FUNC }
| "rec"   { REC }
| "match" { MATCH }
| "with"  { WITH }
| "|"     { PIPE }
| "->"    { ARROW }
| ":"     { COLON }
| "::"    { CONS }
| "="     { EQ }
| "<"     { LT }
| "<="    { LE }
| ">"     { GT }
| ">="    { GE }
| "&&"    { AND }
| "||"    { OR }
| integer_literal+ as lit { LITINT(int_of_string lit) }
| string_literal+ as lit  { LITSTRING(lit) }
| bool_literal as lit     { LITBOOL(lit) }
| letter+ as lit          { LITCHAR(lit) }
| lowercase+ as var { VARIABLE(var) }

| eof { EOF }

and comment level = parse
  "*)" { match level with
        | [_] -> token lexbuf
        | _::level' -> comment level' lexbuf
        | [] -> failwith "bug in comment scanner"
        }
| "(*" { comment (lexbuf.L.lex_start_p :: level) lexbuf }
| '\n' { L.new_line lexbuf;
        comment level lexbuf
        }
| _    { comment level lexbuf }
| eof  { raise Error }
