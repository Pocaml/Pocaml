#include <stdio.h>
#include <stdlib.h>
#include "builtins.h"

void _pml_error(_pml_string s) {
    fprintf(stderr, "%s\n", s);
    exit(EXIT_FAILURE);
}

void _pml_error_nonexhaustive_pattern_matching() {
    _pml_error("Non-exhaustive pattern matching");
}
