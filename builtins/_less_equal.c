#include <stdlib.h>
#include <string.h>
#include "builtins.h"


_pml_val _less_equal;

_pml_val _builtin__less_equal(_pml_val *args) {
	_pml_val left, right;

	left = (_pml_val) args[0];
	right = (_pml_val) args[1];

	_pml_bool res;
	switch (left->type) {
		case PML_CHAR:
			res = _pml_get_char(left) <= _pml_get_char(right);
			return _make_bool(res);
		case PML_BOOL:
			res = _pml_get_bool(left) <= _pml_get_bool(right);
			return _make_bool(res);
		case PML_UNIT:
			res = _pml_get_unit(left) <= _pml_get_unit(right);
			return _make_bool(res);
		case PML_INT:
			res = _pml_get_int(left) <= _pml_get_int(right);
			return _make_bool(res);
		case PML_STRING:
			res = 0 <= strcmp(_pml_get_string(left), _pml_get_string(right));
			return _make_bool(res);
		default:
			_pml_error("This type does not support equality operator");
	}

	_pml_error("This type does not support equality operator");
	return _make_int(420);
}

void _init__less_equal() {
    _less_equal = _make_closure(_builtin__less_equal, 2);
}
