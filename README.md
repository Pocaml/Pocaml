# Pocaml Programming Language

To output AST, run:
```
dune exec -- bin/main.exe -a
```

To output LLVM, run:
```
dune exec -- bin/main.exe -l
```

To format the project, run:
```
dune build @fmt
dune promote
```
## Running the Test Suites

To run test suites, run the automated script testall.sh in the docker by
```
./runDocker ./testall.sh
```
This will run the integration test suites contained in the tests/pml/ directory
and compare the output of the tests with the expected result contained in the .out
directory.  The running log will be saved in the root directory.

## pocamlc

pocamlc is a shell script for compiling, running pocaml among other things.
The most common usage is to compile the pocaml compiler and then run pocaml
on a `.pml` file.

> For pocamlc to run successfully, the project dependencies in pocaml.opam, llvm and gcc among others need to be installed.
>
> Alternatively, refer to the [docker](##docker) section to compile and run the project within a docker container.


Below is an example that uses pocamlc to compile pocaml and then runs it on
the `.pml` file at `test/pml/test_pattern_matching_1.pml` for testing pattern matching.

```shell
./pocamlc -rf test/pml/test_pattern_matching_1.pml
```

To see the comprehensive usage of pocamlc, simply run `./pocamlc` or
`./pocamlc -h`.


## docker
To run the project in a docker container, run:

```shell
./runDocker
```

> This will build a docker image with all the project dependencies in a
Ubuntu base image, start a docker container using the built image with the
your local project directory mounted into `/home/pocaml` in the
container, run `bash` within `/home/pocaml` and finally attach your terminal
to it.

Any additional arguments to `./runDocker` will be passed to the `bash`
command set to run once the container starts. Thus, to run the container as
an executable for compiling and running
`test/pml/test_pattern_matching_1.pml`, run:

```shell
./runDocker ./pocamlc -rf test/pml/test_pattern_matching_1.pml
```
