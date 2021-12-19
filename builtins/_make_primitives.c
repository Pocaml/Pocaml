#include <string.h>
#include <stdlib.h>
#include "builtins.h"

_pml_val _make_int(_pml_int n) {
    _pml_val_internal *p = malloc(sizeof(_pml_val_internal));
    p->type = PML_INT;
    p->i = n;
    return (_pml_val) p;
}

_pml_val _make_bool(_pml_bool b) {
    _pml_val_internal *p = malloc(sizeof(_pml_val_internal));
    p->type = PML_BOOL;
    p->b = b;
    return (_pml_val) p;
}

_pml_val _make_char(_pml_char c) {
    _pml_val_internal *p = malloc(sizeof(_pml_val_internal));
    p->type = PML_CHAR;
    p->c = c;
    return (_pml_val) p;
}

_pml_val _make_string(_pml_char *s) {
    _pml_val_internal *v = malloc(sizeof(_pml_val_internal));
    size_t n = strlen((char *) s) + 1;
    _pml_char *p = malloc(sizeof(_pml_char) * n);
    strcpy(p, s);
    v->type = PML_STRING;
    v->s = p;
    return (_pml_val) v;
}

_pml_val_internal _unit_internal = {
    .type = PML_UNIT,
    .u = 69
};

_pml_val _unit = &_unit_internal;

_pml_val _make_unit() {
    return _unit;
}

_pml_val_internal _pml_empty_list_internal = {
    .type = PML_LIST,
    .l = NULL
};

_pml_val _pml_empty_list = &_pml_empty_list_internal;

_pml_val _make_list(_pml_val data, _pml_val next_list_val) {
    _pml_list *next_list = (_pml_list *)next_list_val->l;
    _pml_list *list = malloc(sizeof(_pml_list));
    list->data = data;
    list->next = next_list;
    _pml_val_internal *v = malloc(sizeof(_pml_val_internal));
    v->type = PML_LIST;
    v->l = list;
    return (_pml_val) v;
}
