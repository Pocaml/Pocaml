/* pocaml primitives */
typedef		int8_t		_pml_char;
typedef		int8_t		_pml_bool;
typedef		int8_t		_pml_unit;
typedef		int32_t		_pml_int;
typedef		int8_t		*_pml_string;
typedef		void		*_pml_val; 
typedef		_pml_val	_pml_func(_pml_val*);
typedef struct _pml_list_node {
	_pml_val data;
	struct _pml_list_node *next;
} _pml_list_node;
typedef struct {
	_pml_list_node *head;
} _pml_list;

typedef void _pml_init(void);



/* closure */
typedef struct _pml_closure_md {
	_pml_func	*fp;
	_pml_int	required;
	_pml_int	supplied;
} _pml_closure_md;

#define _closure_fp(closure) (((_pml_closure_md *)(closure))->fp)
#define _set_closure_fp(closure, fp) (((_pml_closure_md *)(closure))->fp = (fp))
#define _closure_required(closure) (((_pml_closure_md *)(closure))->required)
#define _set_closure_required(closure, n) (((_pml_closure_md *)(closure))->required = (n))
#define _closure_supplied(closure) (((_pml_closure_md *)(closure))->supplied)
#define _set_closure_supplied(closure, n) (((_pml_closure_md *)(closure))->supplied = (n))
#define _start_of_args_in_closure(closure) ((_pml_val *)((_pml_closure_md)(closure) + 1))
#define _closure_size(closure) (sizeof(_pml_closure_md) + sizeof(_pml_val) * (((_pml_closure_md *)(closure))->supplied))
#define _closure_size_with_args(n) (sizeof(_pml_func*) + 2 * sizeof(_pml_int) + sizeof(_pml_val) * ((n) - 1))

_pml_val _make_closure(_pml_func *fp, _pml_int num_args);

/* builtins */
_pml_func	_builtin__add;
extern _pml_val _add;
_pml_init _init__add;
