let x = [1; 2; 3]
let z = list_map (fun a -> (a > 1)) x
let _ = print_bool_list z
