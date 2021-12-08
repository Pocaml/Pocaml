#include <stdlib.h>
#include <stdio.h>
#include "builtins.h"


_pml_val print_string;

_pml_val _builtin_print_string(_pml_val *args)
{
	_pml_string s;

	s = (_pml_string) args[0];

	printf("%s", s);
	return _make_unit();
}

void _init_print_string()
{
	print_string = _make_closure(_builtin_print_string, 1);
}
