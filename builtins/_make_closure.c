#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

typedef void *(*_pocaml_func_t)(int32_t, void *);

void *_make_closure(_pocaml_func_t f, int32_t num_args) {
    size_t f_size = sizeof(_pocaml_func_t);
    size_t two_int_size = 2 * sizeof(int32_t);
    size_t args_size = sizeof(void *) * (num_args - 1);
    void *new_closure = malloc(f_size + two_int_size + args_size);

    _pocaml_func_t *f_ptr = new_closure;
    int32_t *two_int_ptr = (int32_t *) (new_closure + f_size);
    *f_ptr = f;
    *two_int_ptr = num_args;
    *(two_int_ptr + 1) = 0;

    return new_closure;
}
