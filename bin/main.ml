open Pocaml

type action = Ast | IR | Lambda | LLVM_IR | Compile

let () =
  let action = ref Compile in
  let set_action a () = action := a in
  let speclist =
    [
      ("-a", Arg.Unit (set_action Ast), "Print the AST");
      ("-i", Arg.Unit (set_action IR), "Print the IR");
      (*("-s", Arg.Unit (set_action Sast), "Print the SAST");*)
      ( "-lambda",
        Arg.Unit (set_action Lambda),
        "Print the IR after lambda-lifting" );
      ("-l", Arg.Unit (set_action LLVM_IR), "Print the generated LLVM IR");
      ( "-c",
        Arg.Unit (set_action Compile),
        "Check and print the generated LLVM IR (default)" );
    ]
  in
  let usage_msg = "usage: ./main.native [-a|-i|-l|-c] [file.pml]" in
  let channel = ref stdin in
  Arg.parse speclist (fun filename -> channel := open_in filename) usage_msg;

  let lexbuf = Lexing.from_channel !channel in
  let program = Parser.program Lexer.token lexbuf in
  match !action with
  | Ast -> print_string (Print.string_of_program program)
  | IR ->
      print_string
        (Print_ir.string_of_program (Lower_ast.lower_program program))
  | Lambda ->
      program |> Lower_ast.lower_program |> Type_infer.type_infer
      |> Lambda_lift.lambda_lift |> Print_ir.string_of_program |> print_string
  | _ -> (
      let m =
        program |> Lower_ast.lower_program |> Type_infer.type_infer
        |> Lambda_lift.lambda_lift |> Codegen.codegen
      in
      match !action with
      | Ast -> ()
      | IR -> ()
      | Lambda -> ()
      | LLVM_IR -> print_string (Llvm.string_of_llmodule m)
      | Compile ->
          Llvm_analysis.assert_valid_module m;
          print_string (Llvm.string_of_llmodule m))
