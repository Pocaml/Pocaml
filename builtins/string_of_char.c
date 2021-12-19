#include <stdlib.h>
#include <stdio.h>
#include "builtins.h"

#define	CHAR_MAX_CHAR_NUM    2
#define CHAR_STR_MAX_SIZE    (sizeof(_pml_char) * CHAR_MAX_CHAR_NUM)

_pml_val string_of_char;

_pml_val _builtin_string_of_char(_pml_val *args)
{
	_pml_char char_val;
	_pml_char res[CHAR_STR_MAX_SIZE];

	char_val = _pml_get_char(args[0]);
	res[0] = char_val;
	res[1] = '\0';

#ifdef BUILTIN_DEBUG
	printf("[debug] string_of_char %c -> %s\n", char_val, res);
#endif

	return _make_string(res);
}

void _init_string_of_char()
{
	string_of_char = _make_closure(_builtin_string_of_char, 1);
}
