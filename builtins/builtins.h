#ifndef _POCAML_BUILTINS_H_
#define _POCAML_BUILTINS_H_

#include <stdint.h>

/* pocaml primitives */
typedef		int8_t		_pml_char;
typedef		int8_t		_pml_bool;
typedef		int8_t		_pml_unit;
typedef		int32_t		_pml_int;
typedef		int8_t		*_pml_val;
typedef		_pml_val	_pml_func(_pml_val*);
typedef struct _pml_list_node {
	_pml_val data;
	struct _pml_list_node *next;
} _pml_list_node;
typedef struct
{
	_pml_list_node *head;
} _pml_list;

typedef void _pml_init(void);

/* closure */
typedef struct _pml_closure_md
{
	_pml_func *fp;
	_pml_int required;
	_pml_int supplied;
} _pml_closure_md;

#define _closure_fp(closure) (((_pml_closure_md *)(closure))->fp)
#define _set_closure_fp(closure, f_ptr) (((_pml_closure_md *)(closure))->fp = (f_ptr))
#define _closure_required(closure) (((_pml_closure_md *)(closure))->required)
#define _set_closure_required(closure, n) (((_pml_closure_md *)(closure))->required = (n))
#define _closure_supplied(closure) (((_pml_closure_md *)(closure))->supplied)
#define _set_closure_supplied(closure, n) (((_pml_closure_md *)(closure))->supplied = (n))
#define _start_of_args_in_closure(closure) ((_pml_val *)((_pml_closure_md *)(closure) + 1))
#define _closure_size(closure) (sizeof(_pml_closure_md) + sizeof(_pml_val) * (((_pml_closure_md *)(closure))->supplied))
#define _closure_size_with_args(n) (sizeof(_pml_func *) + 2 * sizeof(_pml_int) + sizeof(_pml_val) * ((n)-1))

_pml_val _make_closure(_pml_func *fp, _pml_int num_args);
_pml_val _apply_closure(_pml_val closure, _pml_val arg);

/* primitives */
_pml_val _make_int(_pml_int n);
_pml_val _make_bool(_pml_bool b);
_pml_val _make_char(_pml_char c);
_pml_val _make_string(_pml_char *s);
_pml_val _make_int(_pml_int n);
_pml_val _make_unit();
_pml_val _make_list(_pml_val data, _pml_val next_list);
/* pml func helpers */
_pml_val _get_arg(_pml_val *params, _pml_int i);

/* builtins */
_pml_func _builtin__add;
extern _pml_val _add;
_pml_init _init__add;

_pml_func _builtin__minus;
extern _pml_val _minus;
_pml_init _init__minus;

_pml_func _builtin__times;
extern _pml_val _times;
_pml_init _init__times;

_pml_func _builtin__divide;
extern _pml_val _divide;
_pml_init _init__divide;

_pml_func _builtin__less_than;
extern _pml_val _less_than;
_pml_init _init__less_than;

_pml_func _builtin__less_equal;
extern _pml_val _less_equal;
_pml_init _init__less_equal;

_pml_func _builtin__greater_than;
extern _pml_val _greater_than;
_pml_init _init__greater_than;

_pml_func _builtin__greater_equal;
extern _pml_val _greater_equal;
_pml_init _init__greater_equal;

_pml_func _builtin__equal;
extern _pml_val _equal;
_pml_init _init__equal;

_pml_func _builtin__not_equal;
extern _pml_val _not_equal;
_pml_init _init__not_equal;

_pml_func _builtin__or;
extern _pml_val _or;
_pml_init _init__or;

_pml_func _builtin__and;
extern _pml_val _and;
_pml_init _init__and;

_pml_func _builtin__cons;
extern _pml_val _cons;
_pml_init _init__cons;

_pml_func _builtin__seq;
extern _pml_val _seq;
_pml_init _init__seq;

_pml_func _builtin_print_string;
extern _pml_val print_string;
_pml_init _init_print_string;

_pml_init _init__builtins;

#endif
