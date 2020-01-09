/*************************************************************************
	> File:		write_data.c
	> Author:	孤舟钓客
	> Mail:		guzhoudiaoke@126.com 
	> Time:		2012年12月26日 星期三 01时20分26秒
 ************************************************************************/
 
#include <stdio.h>
#include <string.h>
 
int main()
{
	FILE *fp;
	fp = fopen("./data", "wb");
	
	int i;
	char *str = "baby os, guzhoudiaoke@126.com ";
	int len = strlen(str);
	
	for (i = 0; i < len; i++)
		fprintf(fp, "%c", str[i]);
 
	for (i = 512-len; i > 0; i--)
		fprintf(fp, "%c", i % 26 + 'A');
 
	return 0;
}