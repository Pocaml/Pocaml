#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "builtins.h"


void *_dup_closure(void *closure)
{
	_pml_int num_args, dup_size;
	void *dup_closure;
	_pml_func *f;

	num_args = _closure_required(closure);
	dup_size = _closure_size(closure);
	f = _closure_fp(closure);

    dup_closure = malloc(_closure_size_with_args(num_args));
    _set_closure_fp(closure, f);
    _set_closure_required(closure, num_args);
    _set_closure_supplied(closure, 0);

	memcpy(dup_closure, closure, dup_size);

	return dup_closure;
}

void _add_arg_to_closure(void *closure, _pml_val arg)
{
	_pml_int supplied = _closure_supplied(closure);
	_start_of_args_in_closure(closure)[supplied] = arg;
}

_pml_val _apply_closure(_pml_val _closure, _pml_val arg)
{
	/*
	 * if have the required # args -> apply func with args, return result
	 * else -> duplicate a closure, add arg to the closure, update supplied
	*/

#ifdef BUILTIN_DEBUG
	printf("[debug] _apply_closure\n");
#endif

	void *closure = _pml_get_closure(_closure);

	_pml_val ret;
	_pml_int required = _closure_required(closure);
	_pml_int supplied = _closure_supplied(closure); 
	_pml_func *fn = _closure_fp(closure);

	if (required == supplied + 1) {
		/* get the arguments and store in an array */
		_pml_val *args = malloc(sizeof(_pml_val) * required);
		_pml_int args_size = sizeof(_pml_val) * supplied;

		memcpy(args, _start_of_args_in_closure(closure), args_size);
		args[required - 1] = arg;

		ret = fn(args);
		free(args);
	} else {
		void *dup_c = _dup_closure(closure);
		_add_arg_to_closure(dup_c, arg);
		_set_closure_supplied(dup_c, supplied + 1);
		ret = malloc(sizeof(_pml_val_internal));
		ret->type = PML_CLOSURE;
		ret->closure = dup_c;
	}

	return ret;
}
