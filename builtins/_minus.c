#include <stdint.h>
void *_builtin_minus(int32_t n, void *args) {
    int32_t *int_args = (int32_t *)args;
    int32_t first = int_args[0];
    int32_t second = int_args[1];

    int32_t *ret = (int32_t *) malloc(sizeof(int32_t));
    *ret = first - second;
    return (void *) ret;
}

void *_minus;
void _init_minus() {
    _minus = _make_closure(_builtin_minus, 2);
}
