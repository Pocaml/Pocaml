#include <stdlib.h>
#include <stdio.h>
#include "builtins.h"

#define BOOL_NUM_CHAR    6
#define BOOL_STR_SIZE    (sizeof(_pml_char) * BOOL_NUM_CHAR)


_pml_val string_of_bool;

_pml_val _builtin_string_of_bool(_pml_val *args)
{
	_pml_bool *bool_val;
	_pml_string bool_str = "false";
	_pml_string res = (_pml_string) malloc(BOOL_STR_SIZE);

	bool_val = (_pml_bool *) args[0];
	if (*bool_val) {
		bool_str = "true";
	}
	sprintf(res, "%s", bool_str);

#ifdef BUILTIN_DEBUG
	printf("[debug] string_of_bool %d -> %s\n", *bool_val, res);
#endif

	return (_pml_val) res;
}

void _init_string_of_bool()
{
	string_of_bool = _make_closure(_builtin_string_of_bool, 1);
}
