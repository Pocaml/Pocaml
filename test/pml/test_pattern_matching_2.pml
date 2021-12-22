let f a b = match a with
| 1 -> match b with 
    | 2 -> print_int a 
    | _ -> print_int b 
| 2 -> match b with 
    | 1 -> print_int a 
    | _ -> print_int b 
| _ -> print_int 0

let _ = f 1 2
