let x = [1; 2; 3]
let z = list_map (fun a -> list_tl a) x
let _ = print_bool_list z
