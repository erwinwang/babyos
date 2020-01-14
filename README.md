# babyos
 A baby OS

 2020.1.14
    gcc支持c99语法 for(int i = 0;) 
        选项-std=c99
        嵌入汇编由原来的asm()变成__asm()


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
    boot
        as -gstabs -o boot.o boot.S
        ld -o boot boot.o -Tboot.ld
        objdump -h boot 看文件头(.text段距离文件距离)
            从File off栏可知.boot段位于距boot文件头0x00001000处。然后用dd命令将.boot段写入flp.img的第一个扇区。
        dd if=boot ibs=512 skip=8 of=babyos.img obs=512 seek=0 count=1 conv=notrunc
            其中skip * ibs = 0x00001000为待写数据，即.boot段，在输入源文件，即boot文件中的偏移距离，seek * obs = 0为待写数据将要被写入输出目标文件，即flp.img文件的起始位置，即从flp.img文件头字节开始写入数据，count*obs=512为待写数据的长度。

