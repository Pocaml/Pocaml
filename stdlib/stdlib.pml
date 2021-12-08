let print_endline s = print_string s; print_string "\n"

let rec map f xs = match xs with
  | [] -> []
  | (x :: xs) -> f x :: map f xs
