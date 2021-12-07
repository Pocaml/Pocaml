{
  open Parser

  module L = Lexing

  exception Error

  type token = Parser.token

  let semi_stack = ref [SEQ]

  let push_semi t = semi_stack := t :: !semi_stack

  let pop_semi () = semi_stack := List.tl !semi_stack

  let get_semi () = List.hd !semi_stack
}

let blanks = [' ' '\t' '\r' '\n']+
let digit = ['0'-'9']
let uppercase = ['A'-'Z']
let lowercase = ['a'-'z']
let letter = (uppercase | lowercase)
let char_literal = (letter | "\\n" | "\\t")
let string_literal = (letter | digit | '_' | '\'' | ' ' | '\\')
let id_literal = (letter | digit | '_' | '\'')
(* TODO: fix var_id regex: support 'a *)
let capitalized_ident = uppercase id_literal*
let lowercase_ident = ('_' | (lowercase) id_literal*)
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
| ";"  { get_semi () }
| "list" { LIST }
| "["    { push_semi LSEP; LEFT_BRAC }
| "]"    { pop_semi (); RIGHT_BRAC }
| "("    { push_semi SEQ; LEFT_PAREN }
| ")"    { pop_semi (); RIGHT_PAREN }
| "if" { IF }
| "then" { THEN }
| "else" { ELSE }
| "let" { LET }
| "in"  { IN }
| "fun" { FUN }
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
| "true"  { LITBOOL(true)  }
| "false" { LITBOOL(false) }
| integer_literal+ as lit { LITINT(int_of_string lit) }
| '"' (string_literal+ as lit) '"'  { LITSTRING(lit) }
| '\''(char_literal as lit)'\'' { LITCHAR(lit) }
| lowercase_ident as var { VARIABLE(var) }
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
