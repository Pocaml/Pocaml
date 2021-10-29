{
  open Parser

  module L = Lexing

  exception Error

  type token = Parser.token
}

let blanks = [' ' '\t' '\r' '\n']+
let digit = ['0'-'9']
let uppercase = ['A'-'Z']
let lowercase = ['a'-'z']
let letter = (uppercase | lowercase)
let capitalized_ident = uppercase (letter | digit | '_' | '\'')*
let lowercase_ident = (lowercase | '_') (letter | digit | '_' | '\'')*
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
| "if" { IF }
| "then" { THEN }
| "else" { ELSE }
| "let" { LET }
| "in"  { IN }
| "function" { FUNC }
| "match" { MATCH }
| "with"  { WITH }
| "->"    { ARROW }
| ":"     { COLON }
| "="     { EQ }
| ['0'-'9']+ as lit { LITERAL(int_of_string lit) }
| ['a'-'z']+ as var { VARIABLE(var) }
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
