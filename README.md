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