let helper (prefix : string) = 
  let n = ref 0 in
  fun () -> n := !n + 1; prefix ^ string_of_int !n
let fresh_name = helper "U"

let fresh_lambda_name = helper "L"
