open Pocaml
open Pocaml.Ast

(* 
  Parse to ast
  Desugar ast (optional)
  Check ast (optional)
  Infer types 
  Lambda lift
  Defunctionalize
  Monomorphize
  Codegen
*)

type action = Ast | LLVM_IR | Compile

let () =
  let action = ref Compile in
  let set_action a () = action := a in
  let speclist = [
    ("-a", Arg.Unit (set_action Ast), "Print the AST");
    (*("-s", Arg.Unit (set_action Sast), "Print the SAST");*)
    ("-l", Arg.Unit (set_action LLVM_IR), "Print the generated LLVM IR");
    ("-c", Arg.Unit (set_action Compile),
      "Check and print the generated LLVM IR (default)");
  ] in  
  let usage_msg = "usage: ./main.native [-a|-l|-c] [file.pml]" in
  let channel = ref stdin in
  Arg.parse speclist (fun filename -> channel := open_in filename) usage_msg;

  let lexbuf = Lexing.from_channel !channel in
  let program = Parser.program (Lexer.token) lexbuf in
  match !action with
    Ast -> print_string (Ast.string_of_program program)
  | _ -> let m = program |> Type_infer.type_infer |> Lambda_lift.lambda_lift |> Defunctionalize.defunctionalize |> Monomorphize.monomorphize |> Codegen.codegen in
    match !action with
        Ast     -> ()
      | LLVM_IR -> print_string (Llvm.string_of_llmodule m)
      | Compile -> Llvm_analysis.assert_valid_module m;
                   print_string (Llvm.string_of_llmodule m)