
#include <stdlib.h>
#include <stdio.h>
#include "builtins.h"


#define	INT_MAX_CHAR_NUM    10
#define INT_STR_MAX_SIZE    (sizeof(_pml_char) * INT_MAX_CHAR_NUM)


_pml_val string_of_int;

_pml_val _builtin_string_of_int(_pml_val *args)
{
	_pml_int int_val;
	_pml_char res[INT_STR_MAX_SIZE];

	int_val = _pml_get_int(args[0]);
	sprintf(res, "%d", int_val);

#ifdef BUILTIN_DEBUG
	printf("[debug] string_of_int %d -> %s\n", int_val, res);
#endif

	return _make_string(res);
}

void _init_string_of_int()
{
	string_of_int = _make_closure(_builtin_string_of_int, 1);
}
