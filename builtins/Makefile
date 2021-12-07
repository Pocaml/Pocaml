CC=gcc
CFLAGS=-I.
DEPS=buildins.h
OBJ=_add.o \
 _and.o \
 _apply_closure.o \
 _cons.o \
 _divide.o \
 _equal.o \
 _get_arg.o \
 _greater_equal.o \
 _greater_than.o \
 _init.o \
 _less_equal.o \
 _less_than.o \
 _make_closure.o \
 _make_primitives.o \
 _minus.o \
 _not_equal.o \
 _or.o \
 _seq.o \
 _times.o \
 print_string.o

.PHONY: default
default: pml_builtins.a

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

pml_builtins.a: $(OBJ)
	ar rcs $@ $^

.PHONY: clean
clean:
	rm *.o pml_builtins.a
