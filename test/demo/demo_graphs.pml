let edges = [
    ['a'; 'b'; '1']; ['a'; 'c'; '2'];
    ['a'; 'd'; '3']; ['b'; 'e'; '4'];
    ['c'; 'f'; '5']; ['d'; 'e'; '6'];
    ['e'; 'f'; '7']; ['e'; 'g'; '8'] 
]

let rec successors n = function
    | [] -> []
    | hd :: edges -> match hd with 
        | s :: t -> 
            if s = n then
                (list_hd t) :: (successors n edges)
            else
                successors n edges
        | _ -> error "edges formatted incorrectly"

let _ = print_string "Successors of a: "; 
        print_list print_char (successors 'a' edges)
let _ = print_string "Successors of b: ";
        print_list print_char (successors 'b' edges)
let _ = print_endline " "


let rec dfs edges visited = function
    | [] -> list_rev visited
    | n :: nodes ->
        if list_mem n visited then
            dfs edges visited nodes
        else
            dfs edges (n::visited) (list_append (successors n edges) nodes)

let _ = print_string "DFS from a: ";
        print_char_list (dfs edges [] ['a'])
let _ = print_string "DFS from e: ";
        print_char_list (dfs edges [] ['e'])
