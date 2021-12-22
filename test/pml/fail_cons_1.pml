let x = true
let y = x :: [2; 3; 4]
(* type mismatch *)
let _ = print_int_list y
