let f a b = 
    let x = 
        match a with
        | 1 -> match b with 
            | 2 -> x 
            | _ -> b 
        | 2 -> match f with 
            | 1 -> a 
            | _ -> b 
        | _ -> 0
    in
x
(* scoping error *)

let _ = print_int (f 1 2)
