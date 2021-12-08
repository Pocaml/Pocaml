#include <stdlib.h>
#include <stdio.h>
#include "builtins.h"


_pml_val string_of_char;

_pml_val _builtin_string_of_char(_pml_val *args)
{
	_pml_char *char_val;
	_pml_string res = (_pml_string) malloc(sizeof(_pml_char));

	char_val = (_pml_char *) args[0];
	snprintf(res, "%c", *char_val);

#ifdef BUILTIN_DEBUG
	printf("[debug] string_of_char %c -> %s\n", *char_val, res);
#endif

	return (_pml_val) res;
}

void _init_string_of_char()
{
	string_of_char = _make_closure(_builtin_string_of_char, 1);
}
