#include <stdlib.h>
#include "builtins.h"


_pml_val _make_closure(_pml_func *fp, _pml_int num_args) {
    _pml_val closure = malloc(_closure_size_with_args(num_args));

    _set_closure_fp(closure, fp);
    _set_closure_required(closure, num_args);
    _set_closure_supplied(closure, 0);

    return closure;
}