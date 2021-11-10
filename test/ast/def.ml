open Pocaml.Print



let%expect_test _ =
  string_of_def "let a = 3";
  [%expect{||}]

