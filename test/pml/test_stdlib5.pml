let x = [1; 2; 3]
let z = list_fold_left (fun a l -> a + l) 0 x
let _ = print_int z
