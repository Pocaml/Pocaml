let f = function
    true -> "true"
  | _ -> "false"

let _ = print_string "f true = "; print_endline (f true)
let _ = print_string "f others = "; print_endline (f false)
