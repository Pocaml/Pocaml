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

let lsts = [
  [1; 2];
  [true; false];
  [false; true];
  ['a'; 'b'];
  [()];
  ["pml"; "cool"];
  [2;1]
]

let _ = list_map (fun lst -> print_endline (test_pattern_matching lst)) lsts
