#include <stdlib.h>
#include "builtins.h"

_pml_val _seq;

_pml_val _builtin__seq(_pml_val *args)
{
  _pml_val left_operand, right_operand;
  left_operand = args[0];
  right_operand = args[1];
  return right_operand;
}

void _init__seq()
{
  _seq = _make_closure(_builtin__seq, 2);
}
