let fresh_name =
  let n = ref 0 in
  fun () -> n := !n + 1; "U" ^ string_of_int !n
