#ifndef VM__STACK_H__
#define VM__STACK_H__

#include <stdint.h>
struct Stack {
  uint64_t bp;
  uint64_t sp;
  uint8_t stack[];
};

#endif /* ifndef VM__STACK_H__ */
