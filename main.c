#include "print.h"

char buf[256];
int main(void)
{
  put_str("I am kernel!\n");

  while (1)
  {
    __asm__ ("hlt\n\t");
  }
  
  return 0;
}