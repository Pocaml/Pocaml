#include <stdlib.h>
#include "builtins.h"

_pml_val _seq;

_pml_val _builtin__seq(_pml_val *args)
{
  return args[1];
}

void _init__seq()
{
  _seq = _make_closure(_builtin__seq, 2);
}
