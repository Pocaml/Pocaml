let x = [1; 2; 3]
let z = list_fold_right (fun a l -> a - l) x []
let _ = print_int_list z