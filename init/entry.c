#include "console.h"
#include "debug.h"
#include "gdt.h"
#include "idt.h"
#include "timer.h"
#include "kbd_ps2.h"

int kern_entry()
{
    init_debug();
    init_gdt();
    init_idt();

    console_clear();
    printk_color(rc_black, rc_green, "Hello, OS kernel!\n");

    //init_timer(200);
    init_keyboard_ps2();

    // 开启中断
    asm volatile ("sti");

    return 0;
}