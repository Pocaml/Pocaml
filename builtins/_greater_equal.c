#include <stdlib.h>
#include "builtins.h"

_pml_val _greater_equal;

_pml_val _builtin__greater_equal(_pml_val *args)
{
	_pml_int *left_operand, *right_operand;
	_pml_bool *res = (_pml_bool *)malloc(sizeof(_pml_bool));

	left_operand = (_pml_int *)args[0];
	right_operand = (_pml_int *)args[1];

	*res = *left_operand >= *right_operand;
	return (_pml_val)res;
}

void _init__greater_equal()
{
	_greater_equal = _make_closure(_builtin__greater_equal, 2);
}
