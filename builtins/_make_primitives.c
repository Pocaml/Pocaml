#include <string.h>
#include <stdlib.h>
#include "builtins.h"

_pml_val _make_int(_pml_int n) {
    _pml_int *p = malloc(sizeof(_pml_int));
    *p = n;
    return (_pml_val) p;
}

_pml_val _make_bool(_pml_bool b) {
   _pml_bool *p = malloc(sizeof(_pml_bool));
    *p = b;
    return (_pml_val) p;
}

_pml_val _make_char(_pml_char c) {
    _pml_char *p = malloc(sizeof(_pml_char));
    *p = c;
    return (_pml_val) p;
}

_pml_val _make_string(_pml_char *s) {
    size_t n = strlen((char *) s) + 1;
    _pml_char *p = malloc(sizeof(_pml_char) * n);
    strcpy(p, s);
    return (_pml_val) p;
}

_pml_unit _unit = 69;

_pml_val _make_unit() {
    return &_unit;
}

_pml_val _pml_empty_list = NULL;

_pml_val _make_list(_pml_val data, _pml_val next_list_val) {
    _pml_list *next_list = (_pml_list *)next_list_val;
    _pml_list *list = malloc(sizeof(_pml_list));
    list->data = data;
    list->next = next_list;
    return (_pml_val) list;
}
