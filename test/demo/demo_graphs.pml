let edges = [
    ['a'; 'b'; '1']; ['a'; 'c'; '2'];
    ['a'; 'd'; '3']; ['b'; 'e'; '4'];
    ['c'; 'f'; '5']; ['d'; 'e'; '6'];
    ['e'; 'f'; '7']; ['e'; 'g'; '8'] 
]

let nodes = [['a'];['b'];['c'];['d'];['e'];['f'];['g']]

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


let rec same_comp a b = function
    | hd_in :: tl_in -> 
        if (list_mem a hd_in) && (list_mem b hd_in) then
            true
        else
            same_comp a b tl_in
    | [] -> false

let rec get_comp a = function
    | hd_in :: tl_in -> 
        if (list_mem a hd_in) then
            hd_in
        else
            get_comp a tl_in
    | [] -> [a]

let rec kruskal comps res = function
| [] -> res
| hd :: tl ->
    let u = list_hd hd in
    let v = list_hd (list_tl hd) in
    
    if (same_comp u v comps) then
        kruskal comps res tl
    else
        let res = hd :: res in
        let comp_u = (get_comp u comps) in
        let comp_v = (get_comp v comps) in
        let comps = list_filter (fun a -> (list_mem u a) = false) comps in
        let comps = list_filter (fun a -> (list_mem v a) = false) comps in        
        let comp_uv = list_append comp_u comp_v in
        let comps = comp_uv :: comps in
        kruskal comps res tl

let _ = print_endline "Minimum Spanning Tree: ";
print_list (print_list print_char) (kruskal nodes [] edges)


