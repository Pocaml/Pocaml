#include "builtins.h"

void _init__builtins() {
    _init__less_equal();
    _init__less_than();
    _init__add();
    _init__minus();
    _init__divide();
    _init__times();
}