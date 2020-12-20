#include "console.h"
#include "debug.h"
#include "gdt.h"
#include "idt.h"
#include "timer.h"
#include "keyboard.h"

int kernel_start(void)
{
    init_gdt();
    init_idt();

    init_timer(100);
    init_keyboard();

    console_clear();
    printk("Hello kernel!\n");

    // __asm__ __volatile__ ("int $0x3");
    // __asm__ __volatile__ ("int $0x4");
    __asm__ __volatile__ ("sti");
    for(;;)
    {
        __asm__ __volatile__ ("hlt");
    }

    return -1;
}