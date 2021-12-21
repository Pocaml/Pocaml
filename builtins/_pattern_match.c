#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "builtins.h"

_pml_bool _match_pat_cons(_pml_val val) {
    _pml_list *l = _pml_get_list(val);
    return l != NULL;
}

_pml_bool _match_pat_cons_end(_pml_val val) {
    _pml_list *l = _pml_get_list(val);
    if (l == NULL)
        return false;
    l = l->next;
    return l == NULL;
}

_pml_bool _match_pat_lit_int(_pml_val val, _pml_int pat) {
    _pml_int i = _pml_get_int(val);
    return i == pat;
}

_pml_bool _match_pat_lit_char(_pml_val val, _pml_char pat) {
    _pml_char c = _pml_get_char(val);
    return c == pat;
}

_pml_bool _match_pat_lit_bool(_pml_val val, _pml_bool pat) {
    _pml_bool b = _pml_get_bool(val);
    return b == pat;
}

_pml_bool _match_pat_lit_string(_pml_val val, _pml_string pat) {
    _pml_string s = _pml_get_string(val);
    return strcmp(s, pat) == 0;
}

_pml_bool _match_pat_lit_unit(_pml_val val, _pml_unit pat) {
    _pml_unit u = _pml_get_unit(val);
    return u == pat;
}

_pml_bool _match_pat_lit_list_end(_pml_val val) {
    _pml_list *l = _pml_get_list(val);
    return l == NULL;
}

_pml_val _list_get_head(_pml_val val) {
    _pml_list *l = _pml_get_list(val);

    if (l == NULL)
        _pml_error("Can't get head of list with length 0");

    return l->data;
}

_pml_val _list_get_tail(_pml_val val) {
    _pml_list *l = _pml_get_list(val);

    if (l == NULL)
        _pml_error("Can't get tail of list with length 0");

    _pml_val_internal *v = malloc(sizeof(_pml_val_internal));
    v->type = PML_LIST;
    v->l = l->next;

    return v;
}
