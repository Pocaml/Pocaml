let f = function
    1 -> "1"
  | 2 -> "2"
  | _ -> "_"

let _ = print_string "f 1 = "; print_endline (f 1)
let _ = print_string "f 2 = "; print_endline (f 2)
let _ = print_string "f others = "; print_endline (f 3)