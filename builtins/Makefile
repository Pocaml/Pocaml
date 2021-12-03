CC=gcc
CFLAGS=-I.
DEPS = buildins.h
OBJ = _add.o _apply_closure.o \
_divide.o _get_arg.o _less_equal.o \
_less_than.o _make_closure.o _make_primitives.o \
_minus.o _times.o

.PHONY: default
default: pml_builtins.a

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

pml_builtins.a: $(OBJ)
	ar rcs $@ $^

.PHONY: clean
clean:
	rm *.o pml_builtins.a