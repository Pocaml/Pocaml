#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "builtins.h"


_pml_val _dup_closure(_pml_val closure)
{
	_pml_int num_args, dup_size;
	_pml_val dup_closure;
	_pml_func *f;

	num_args = _closure_required(closure);
	dup_size = _closure_size(closure);
	f = _closure_fp(closure);
	dup_closure = _make_closure(f, num_args);
	memcpy(dup_closure, closure, dup_size);

	return dup_closure;
}

void _add_arg_to_closure(_pml_val closure, _pml_val arg)
{
	_pml_int supplied = _closure_supplied(closure);
	_start_of_args_in_closure(closure)[supplied] = arg;
}

_pml_val _apply_closure(_pml_val closure, _pml_val arg)
{
	/*
	 * if have the required # args -> apply func with args, return result
	 * else -> duplicate a closure, add arg to the closure, update supplied
	*/
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
		ret = _dup_closure(closure);
		_add_arg_to_closure(ret, arg);
		_set_closure_supplied(ret, supplied + 1);
	}

	return ret;
}