#include <stdint.h>
#include <string.h>
#include "builtins.h"

_pml_val _make_int(_pml_int n) {
    _pml_int *p = malloc(sizeof(_pml_int));
    *p = n;
    return (_pml_val) p;
}

_pml_val _make_bool(_pml_bool bool) {
   _pml_bool *p = malloc(sizeof(_pml_bool));
    *p = bool;
    return (_pml_val) p;
}

_pml_val _make_char(_pml_char c) {
    _pml_char *p = malloc(sizeof(_pml_char));
    *p = c;
    return (_pml_val) p;
}

_pml_val _make_string(_pml_char *s) {
    _pml_char *p = malloc(strlen(s));
    strcpy(p, s);
    return (_pml_val) p;
}

_pml_unit _unit = 69;

_pml_val _make_unit() {
    return &_unit;
}

_pml_list _empty_list = { NULL };
_pml_val _pml_empty_list = &_empty_list;

_pml_val _make_list(_pml_val data, _pml_val next_list) {
    _pml_list_node *next_list_node = ((_pml_list *)next_list)->head;
    _pml_list_node *node = malloc(sizeof(_pml_list_node));
    node->data = data;
    node->next = next_list_node;
    _pml_list *list = malloc(sizeof(_pml_list));
    list->head = node;
    return list;
}