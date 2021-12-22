let f x = list_hd x
let g y = (f y) + 3
let _ = print_int (g [])
