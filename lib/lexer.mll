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
let string_literal = (letter | digit | '_' | '\'')
(* TODO: fix var_id regex: support 'a *)
let capitalized_ident = uppercase string_literal*
let lowercase_ident = (lowercase | '_') string_literal*
let integer_literal = ['-']? digit (digit | '_')*
let regular_char = [^ '\'' '\\'] 
let variable_id = lowercase (lowercase | uppercase)*

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
| "function" { FUN }
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
| "True"  { LITBOOL(true)  }
| "False" { LITBOOL(false) }
| integer_literal+ as lit { LITINT(int_of_string lit) }
| '"' string_literal+ '"' as lit  { LITSTRING(lit) }
| '\''(letter as lit)'\'' { LITCHAR(lit) }  (* excape sequence not supported *)
| variable_id as var { VARIABLE(var) }
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
