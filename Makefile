#!Makefile
#
# --------------------------------------------------------
#
#    hurlex 这个小内核的 Makefile
#    默认使用的C语言编译器是 GCC、汇编语言编译器是 nasm
#
# --------------------------------------------------------
#

# patsubst 处理所有在 C_SOURCES 字列中的字（一列文件名），如果它的 结尾是 '.c'，就用 '.o' 把 '.c' 取代
C_SOURCES = \
		entry.c\
		common.c\
		console.c\
		debug.c\
		elf.c\
		printk.c\

C_OBJECTS = \
		entry.o\
		common.o\
		console.o\
		debug.o\
		elf.o\
		printk.o\

S_SOURCES = \
		boot.s\

S_OBJECTS = \
		boot.o\

CC = gcc
LD = ld
ASM = nasm

C_FLAGS = -c -Wall -m32 -ggdb -gstabs+ -nostdinc -fno-builtin -fno-stack-protector
LD_FLAGS = -T kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f elf -g -F stabs

all: $(S_OBJECTS) $(C_OBJECTS) link

# # The automatic variable `$<' is just the first prerequisite
.c.o:
	$(CC) $(C_FLAGS) $< -o $@

.s.o:
	$(ASM) $(ASM_FLAGS) $<

# boot.o:boot.s
# 	$(ASM) $(ASM_FLAGS) $<

# entry.o:entry.c
# 	$(CC) $(C_FLAGS) $< -o $@

bootsect.bin:bootsect.asm
	$(ASM) $< -o $@

prog.bin:prog.asm
	$(ASM) $< -o $@

link: $(S_OBJECTS) $(C_OBJECTS)
	$(LD) $(LD_FLAGS) $(S_OBJECTS) $(C_OBJECTS) -o hx_kernel

.PHONY:linux.img
linux.img:bootsect.bin prog.bin
	dd if=/dev/zero of=linux.img bs=512 count=2880
	dd if=bootsect.bin of=linux.img bs=512 count=1 conv=notrunc
	dd if=prog.bin of=linux.img bs=512 seek=1 count=1 conv=notrunc

.PHONY:clean
clean:
	$(RM) *.o

.PHONY:qemu
qemu:linux.img
	qemu-system-i386 -fda linux.img -boot a
	#add '-nographic' option if using server of linux distro, such as fedora-server,or "gtk initialization failed" error will occur.

.PHONY:debug
debug:
	qemu-system-i386 -S -s -kernel hx_kernel
	sleep 1
	gdb -x gdbinit

