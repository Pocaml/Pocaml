#include "builtins.h"

void _init__builtins()
{
    _init__add();
    _init__minus();
    _init__times();
    _init__divide();
    _init__less_than();
    _init__less_equal();
    _init__greater_than();
    _init__greater_equal();
    _init__equal();
    _init__not_equal();
    _init__or();
    _init__and();
    _init__cons();
    _init__seq();
}