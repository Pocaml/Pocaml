#include <stdlib.h>
#include "builtins.h"


_pml_val _cons;

_pml_val _builtin__cons(_pml_val *args) {
  _pml_val left_operand;
  _pml_list_node *right_operand;
  left_operand = (_pml_val) args[0];
	right_operand = (_pml_list_node *) args[1];

	_pml_list_node *node = malloc(sizeof(_pml_list_node));
  node->data = left_operand;
  node->next = right_operand;

  return node;
}

void _init__cons() {
    _cons = _make_closure(_builtin__cons, 2);
}
