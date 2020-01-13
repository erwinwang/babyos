# babyos
 A baby OS

 2020.1.13
    gdb + qemu + boot源码级调试
    qemu -s -S选项控制 -hda babyos.img
    gdb target remote localhost:1234
        file boot(elf文件 带调试信息)
        set arch i8086
        break * 0x7c00(注意*与0x7c00有空格)
        c 继续
        si 汇编步进
        info registers显示寄存器的值
        q退出

