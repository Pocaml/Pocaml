(* 
  function type_check : program -> t_program optional 
*)

open Ast

let type_infer (p: program) : program = p