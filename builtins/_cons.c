#include <stdlib.h>
#include "builtins.h"

_pml_val _cons;

_pml_val _builtin__cons(_pml_val *args)
{
	_pml_val left, right;

	left = (_pml_val) args[0];
	right = (_pml_val) args[1];

  _pml_val res = _make_list(left, right);

	return res;
}

void _init__cons()
{
  _cons = _make_closure(_builtin__cons, 2);
}
