#include "print.h"
#include "init.h"
#include "debug.h"
#include "memory.h"

int main(void)
{
  put_str("I am kernel!\n");
  init_all();
  // ASSERT(1==2);
  while (1)
  {
    __asm__ ("hlt\n\t");
  }
  
  return 0;
}