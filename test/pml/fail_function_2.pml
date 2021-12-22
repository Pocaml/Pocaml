let f = function
    hd :: tl -> tl
  | [] -> "empty"

let _ = print_string "f [1; 2; 3] = "; print_int_list (f "hello")
let _ = print_string "f others = "; print_endline (f [])
