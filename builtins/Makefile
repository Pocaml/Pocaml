CC=gcc
CFLAGS=-I. $(PML_CFLAGS)
DEPS=buildins.h
OBJ= _init.o \
 _apply_closure.o \
 _get_arg.o \
 get_types.o \
 _make_closure.o \
 _make_primitives.o \
 _pattern_match.o \
 _error.o \
 _add.o \
 _and.o \
 _cons.o \
 _divide.o \
 _equal.o \
 _greater_equal.o \
 _greater_than.o \
 _less_equal.o \
 _less_than.o \
 _minus.o \
 _not_equal.o \
 _or.o \
 _seq.o \
 _times.o \
 string_of_int.o \
 string_of_bool.o \
 string_of_char.o \
 print_string.o \
 error.o

.PHONY: default
default: pml_builtins.a

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

pml_builtins.a: $(OBJ)
	ar rcs $@ $^

.PHONY: clean
clean:
	rm -f *.o pml_builtins.a
