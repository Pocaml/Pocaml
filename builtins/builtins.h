typedef void *(_pocaml_func_t)(int32_t, void *);
typedef void* _pocaml_val_t; 
struct _closure_metadata {
	_pocaml_func_t *fp;
	int required;
	int supplied;
};

void *_builtin_add(void **);
void *_make_closure(_pocaml_func_t *f, int32_t num_args);