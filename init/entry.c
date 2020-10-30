#include "console.h"

int kern_entry()
{
    console_clear();

    console_write_color("Hello, OS kernel!\n", rc_black, rc_green);
    console_write("hurlex");

    return 0;
}