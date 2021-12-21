let rec f = function 
    | xh :: xs -> xh + f xs
    | _ -> 0
let y = f [1; 4; 5; 6; 7]
let _ = print_int y
