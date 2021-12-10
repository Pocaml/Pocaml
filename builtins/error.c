#include <stdlib.h>
#include <stdio.h>
#include "builtins.h"


_pml_val error;

_pml_val _builtin_error(_pml_val *args)
{
	_pml_string s;

	s = (_pml_string) args[0];

	fprintf(stderr, "Error: %s", s);
	exit(1);
	
	return _make_unit();
}

void _init_error()
{
	error = _make_closure(_builtin_error, 1);
}
