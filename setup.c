#include "console.h"
#include "debug.h"
/**
 * setup_entry - 进入内核前的准备
 */
void setup_entry()
{   
    // /* 设置并启动分页机制 */
    // setup_paging();
    // print_str("enter setup_entry");
    // unsigned char *vram = (unsigned char *)0xb8000;
    // *vram = 'S';
    // vram++;
    // *vram = 0x07;

    // uint8_t *input = (uint8_t *)0xB8000 + 160 * 4;
    // uint8_t color = (0 << 4) | (15 & 0x0F);

    // *input++ = 'H'; *input++ = color;
    // *input++ = 'e'; *input++ = color;
    // *input++ = 'l'; *input++ = color;
    // *input++ = 'l'; *input++ = color;
    // *input++ = 'o'; *input++ = color;
    // *input++ = ','; *input++ = color;
    // *input++ = ' '; *input++ = color;
    // *input++ = 'O'; *input++ = color;
    // *input++ = 'S'; *input++ = color;
    // *input++ = ' '; *input++ = color;
    // *input++ = 'K'; *input++ = color;
    // *input++ = 'e'; *input++ = color;
    // *input++ = 'r'; *input++ = color;
    // *input++ = 'n'; *input++ = color;
    // *input++ = 'e'; *input++ = color;
    // *input++ = 'l'; *input++ = color;
    // *input++ = '!'; *input++ = color;

    console_clear();
    printk("Hello, OS kernel!\n");

    int value = 88888;
    printk("%d\n", value);

    int count = 0;
    for(;;)
    {
        count++;
        if (count < 10000)
        {
            count = 0;
        }
        __asm__ __volatile__ ("hlt");
    }
}