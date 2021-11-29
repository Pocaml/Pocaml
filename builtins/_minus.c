#include <stdint.h>
#include "builtins.h"

_pml_val _builtin__minus(_pml_val *args) {
    _pml_int *int_args = (_pml_int *)args;
    _pml_int first = int_args[0];
    _pml_int second = int_args[1];

    _pml_int *ret = (_pml_int *) malloc(sizeof(_pml_int));
    *ret = first - second;
    return (_pml_val) ret;
}

_pml_val _minus;
void _init__minus() {
    _minus = _make_closure(_builtin__minus, 2);
}
