# Pocaml Programming Language

## Quickstart

Create a file called `pocaml.pml` using your text editor of choice and put in the following:
```ocaml
let _ = print_endline "Welcome to Pocaml!"
```

To compile and run this pocaml file, run
```shell
./runDocker ./pocaml pocaml.pml
```

If everything went well, you would see "Welcome to Pocaml!" printed in the console. Under the hood, `./runDocker`starts a docker container with all of our project dependencies and `./pocaml` compiles your source code into an executable and runs it.

To learn more about the usage of the `pocaml` script, run
```shell
./pocaml -h
```

To have more granular control on compiling pocaml code and executing, run the following to learn about the `pocamlc` script used by `pocaml` under the hood:
```shell
./pocamlc -h
```

##  Development FAQ

Below covers the topics of debugging and testing the pocaml compiler.

### debugging

To output AST, run:
```shell
dune exec -- bin/main.exe -a
```

To output LLVM, run:
```shell
dune exec -- bin/main.exe -l
```

### Running the Test Suites

To run test suites, run the automated script testall.sh in the docker by
```shell
./runDocker ./testall.sh
```
This will run the integration test suites contained in the tests/pml/ directory
and compare the output of the tests with the expected result contained in the .out
directory.  The running log will be saved in the root directory.

Aside from testing end-to-end pocaml programs, we also included tests in `test/` for testing compilation up to a certain stage. The output of each stage before code generation is an *abstract syntax tree (AST)*. We use **ppx_expect** to compare the pretty printed result of the AST with the expected result.

To run all of these tests for intermediate compiler stages, run
```shell
dune runtest
```

### Contributing

Make sure to format your OCaml source code before commits by running:
```shell
dune build @fmt
dune promote
```
