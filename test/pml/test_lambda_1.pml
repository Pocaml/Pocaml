let lambda =
  let a = 1 in
  let b = 2 in
  let str = "pocaml" in
    fun lst ->
      list_iter
        ( fun el ->
            match el with
              | 1 -> (fun x -> print_string str) 1
              | _ -> print_int (a + b)
        )
      lst

let _ = lambda [ 6; 1; 9 ]
