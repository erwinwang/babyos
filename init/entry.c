#include "console.h"
#include "debug.h"
#include "gdt.h"
#include "idt.h"
#include "timer.h"
#include "kbd_ps2.h"
#include "pmm.h"

int kern_entry()
{
    init_debug();
    init_gdt();
    init_idt();
    // init_pmm();

    console_clear();
    printk_color(rc_black, rc_green, "Hello, OS kernel!\n");

    //init_timer(200);
    init_keyboard_ps2();

    // 开启中断
    asm volatile ("sti");

    printk("kernel in memory start: 0x%08X\n", kern_start);
    printk("kernel in memory end:   0x%08X\n", kern_end);
    printk("kernel in memory used:   %d KB\n\n", (kern_end - kern_start + 1023) / 1024);
    
    show_memory_map();

    return 0;
}