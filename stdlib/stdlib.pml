let print_endline s =
  print_string s;
  print_string "\n"

let print_int n = print_string (string_of_int n)
let print_bool b = print_string (string_of_bool b)
let print_char c = print_string (string_of_char c)

let rec list_length = function [] -> 0 | _ :: xs -> 1 + list_length xs

let rec list_map f = function [] -> [] | x :: xs -> f x :: list_map f xs

let rec list_iter f = function
  | [] -> ()
  | x :: xs ->
      f x;
      list_iter f xs

let rec list_append xs ys =
  match xs with [] -> ys | x :: xs -> x :: list_append xs ys

let rec list_filter pred = function
  | [] -> []
  | x :: xs -> if pred x then x else list_filter pred xs

let rec list_fold_left f m = function
  | [] -> m
  | x :: xs -> list_fold_left f (f m x) xs

let list_rev xs =
  list_fold_left (fun l x -> x :: l) [] xs
