let test_pattern_matching lst =
  match lst with
    | x :: xs ->
      match x with
	  | 1	  -> "int    list   (1 :: ints)"
	  | true  -> "bool   list   (true  :: bools)"
	  | false -> "bool   list   (false :: bools)"
	  | 'a'	  -> "char   list   ('a' :: chars)"
	  | ()	  -> "unit   list"
	  | "pml" -> "string list   (\"pml\" :: strings)"
	  | _	  -> "other  list"
    | [] -> "empty list ([])"

let _ = print_endline (test_pattern_matching [1; 2])
let _ = print_endline (test_pattern_matching [true; false])
let _ = print_endline (test_pattern_matching [false; true])
let _ = print_endline (test_pattern_matching ['a'; 'b'])
let _ = print_endline (test_pattern_matching [()])
let _ = print_endline (test_pattern_matching ["pml"; "cool"])
let _ = print_endline (test_pattern_matching [2;1])
