#include <stdlib.h>
#include "builtins.h"


_pml_val _divide;

_pml_val _builtin__divide(_pml_val *args) {
	_pml_val left, right;

	left = (_pml_val) args[0];
	right = (_pml_val) args[1];

	_pml_int res = _pml_get_int(left) / _pml_get_int(right);

	return _make_int(res);
}

void _init__divide() {
    _divide = _make_closure(_builtin__divide, 2);
}
