let f a = match a with
| hd :: tl -> match tl with 
    | hd1 :: tl1 -> hd :: hd1 :: (list_rev tl1)
    | _ -> tl
| _ -> []

let _ = print_int_list (f [1; 2; 3; 4])
