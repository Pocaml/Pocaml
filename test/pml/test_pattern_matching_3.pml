let f a = match a with
| hd :: tl -> list_length tl
| [] -> 0
| _ -> error "Input should be a list"

let _ = print_int (f [1; 1; 1; 1])
