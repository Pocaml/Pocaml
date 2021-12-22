let rec map f = function
  head :: tail -> 
      let r = f head in 
      r :: map f tail
  | [] -> []

let _ =
let fn_creator = fun is_flip x -> if is_flip then -1 * x else x in
let do_flip = fn_creator true in

let modify = function do_flip -> function x -> 
  let res = do_flip x in
  if res < 0 then (-1 * res) else res
in

let modified_fns = map modify [do_flip] in
let abs = list_hd modified_fns in

let value = 3 + 4 * -2 in
print_int (abs value)