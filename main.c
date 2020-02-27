#include "lib/kernel/print.h"

char g_str[] = "hello world";
// char buf[256];
int main(void)
{
  put_char('m');
  put_char('=');
  put_char('>');
  put_char('n');
  put_char('\n');
  put_str(g_str);
  char ch = g_str[3];
  while (1)
  {
    __asm__ ("hlt\n\t");
  }
  
  return 0;
}