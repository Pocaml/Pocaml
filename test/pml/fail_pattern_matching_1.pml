let f a = match a with 
| 2 -> print_int a 
| true -> print_int 3
| _ -> print_int 10

let _ = f 3
