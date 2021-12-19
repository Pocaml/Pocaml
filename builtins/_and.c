#include <stdlib.h>
#include "builtins.h"

_pml_val _and;

_pml_val _builtin__and(_pml_val *args)
{
	_pml_val left, right;

	left = (_pml_val) args[0];
	right = (_pml_val) args[1];

	_pml_bool res = _pml_get_bool(left) && _pml_get_bool(right);

	return _make_int(res);
}

void _init__and()
{
	_and = _make_closure(_builtin__and, 2);
}
