#include "builtins.h"

_pml_char _pml_get_char(_pml_val val) {
    if (val->type != PML_CHAR)
        _pml_error("Run-time type error: value is not char type");
    return val->c;
}

_pml_bool _pml_get_bool(_pml_val val) {
    if (val->type != PML_BOOL)
        _pml_error("Run-time type error: value is not bool type");
    return val->b;
}

_pml_unit _pml_get_unit(_pml_val val) {
    if (val->type != PML_UNIT)
        _pml_error("Run-time type error: value is not unit type");
    return val->u;
}

_pml_int _pml_get_int(_pml_val val) {
    if (val->type != PML_INT)
        _pml_error("Run-time type error: value is not int type");
    return val->i;
}

_pml_string _pml_get_string(_pml_val val) {
    if (val->type != PML_STRING)
        _pml_error("Run-time type error: value is not string type");
    return val->s;
}

_pml_list *_pml_get_list(_pml_val val) {
    if (val->type != PML_LIST)
        _pml_error("Run-time type error: value is not list type");
    return (_pml_list *) val->l;
}

void *_pml_get_closure(_pml_val val) {
#ifdef BUILTIN_DEBUG
	printf("[debug] _pml_get_closure: got %d\n", val->type);
#endif

    if (val->type != PML_CLOSURE)
        _pml_error("Run-time type error: value is not function type");
    return (void *) val->closure;
}
