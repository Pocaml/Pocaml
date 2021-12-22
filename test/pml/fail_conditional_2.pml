let f1 x = 10 * x
let f2 x = 100 * x
let g = 50
let result = if g > 50 then f2 g else f1 g else 10
(* Extra Else *)
let _ = print_int result
