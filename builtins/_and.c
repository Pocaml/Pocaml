#include <stdlib.h>
#include "builtins.h"

_pml_val _and;

_pml_val _builtin__and(_pml_val *args)
{
	_pml_bool *left_operand, *right_operand;
	_pml_bool *res = (_pml_bool *)malloc(sizeof(_pml_bool));

	left_operand = (_pml_bool *)args[0];
	right_operand = (_pml_bool *)args[1];

	*res = *left_operand && *right_operand;
	return (_pml_val)res;
}

void _init__and()
{
	_and = _make_closure(_builtin__and, 2);
}
