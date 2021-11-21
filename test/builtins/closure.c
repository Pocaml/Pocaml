#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include "../../builtins/builtins.h"


int main()
{
	_pml_int *a = malloc(sizeof(_pml_int)),
			 *b = malloc(sizeof(_pml_int));
	_pml_val builtin_add = _make_closure(_builtin_add, 2);
	_pml_val res;

	*a = 6, *b = 9;
	res = _apply_closure(builtin_add, a);	/* partial function application */
	res = _apply_closure(res, b);

	assert(*(_pml_int *) res == *a + *b);
	free(a);
	free(b);
}