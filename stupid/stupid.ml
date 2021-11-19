open Stupidlib
type action = LLVM_IR | Compile

let () =
  let action = ref Compile in
  let set_action a () = action := a in
  let speclist =
    [
      ("-l", Arg.Unit (set_action LLVM_IR), "Print the generated LLVM IR");
      ( "-c",
        Arg.Unit (set_action Compile),
        "Check and print the generated LLVM IR (default)" );
    ]
  in
  let usage_msg = "usage: ./stupid [-l|-c]" in
  Arg.parse speclist (fun _ -> ()) usage_msg;
  let m = Codegen.codegen () in
  match !action with
  | LLVM_IR -> print_string (Llvm.string_of_llmodule m)
  | Compile ->
      Llvm_analysis.assert_valid_module m;
      print_string (Llvm.string_of_llmodule m)
