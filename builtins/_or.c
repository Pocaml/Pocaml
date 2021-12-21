#include <stdlib.h>
#include "builtins.h"

_pml_val _or;

_pml_val _builtin__or(_pml_val *args)
{
	_pml_val left, right;

	left = (_pml_val) args[0];
	right = (_pml_val) args[1];

	_pml_bool res = _pml_get_bool(left) || _pml_get_bool(right);

	return _make_int(res);
}

void _init__or()
{
	_or = _make_closure(_builtin__or, 2);
}
