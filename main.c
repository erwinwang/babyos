#include "print.h"

char buf[256];
int main(void)
{
  put_str("I am kernel!\n");
  put_int(0);
  put_int(9);
  put_int(0x89abcd);
  while (1)
  {
    __asm__ ("hlt\n\t");
  }
  
  return 0;
}