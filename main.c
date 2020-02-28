#include "lib/kernel/print.h"

char g_str[] = "global hello world\n";
char buf[256];
int main(void)
{
  char *str = "local auto hello world\n";
  static char static_str[] = {"local static hello world\n"};
  put_char('m');
  put_char('=');
  put_char('>');
  put_char('n');
  put_char('\n');
  put_str(g_str);
  put_str(str);
  put_str(static_str);
  buf[0] = '.';
  buf[1] = 'b';
  buf[2] = 's';
  buf[3] = 's';
  buf[4] = '\0';
  put_str(buf);
  char ch = g_str[3];
  while (1)
  {
    __asm__ ("hlt\n\t");
  }
  
  return 0;
}