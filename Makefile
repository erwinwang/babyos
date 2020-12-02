#!Makefile
#
# --------------------------------------------------------
#
#    hurlex 这个小内核的 Makefile
#    默认使用的C语言编译器是 GCC、汇编语言编译器是 nasm
#
# --------------------------------------------------------
#
C_SOURCES = \

C_OBJECTS = \

S_SOURCES = \
			boot.asm\
			loader.asm\

S_OBJECTS = \
			boot.bin\
			loader.bin\



CC = gcc
LD = ld
ASM = nasm

C_FLAGS = -c -Wall -m32 -ggdb -gstabs+ -nostdinc -fno-pic -fno-builtin -fno-stack-protector -I include
LD_FLAGS = -T scripts/kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f bin

all: $(S_OBJECTS) $(C_OBJECTS) update_image

boot.bin:boot.asm
	$(ASM) $(ASM_FLAGS) $< -o $@

loader.bin:loader.asm
	$(ASM) $(ASM_FLAGS) $< -o $@

# # The automatic variable `$<' is just the first prerequisite
# .c.o:
# 	@echo 编译代码文件 $< ...
# 	$(CC) $(C_FLAGS) $< -o $@

# .s.o:
# 	@echo 编译汇编文件 $< ...
# 	$(ASM) $(ASM_FLAGS) $<

# link:
# 	@echo 链接内核文件...
# 	$(LD) $(LD_FLAGS) $(S_OBJECTS) $(C_OBJECTS) -o hx_kernel

.PHONY:clean
clean:
	$(RM) $(S_OBJECTS) $(C_OBJECTS) hx_kernel

.PHONY:update_image
update_image:
	dd if=boot.bin of=babyos.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=babyos.img seek=2 bs=512 count=1 conv=notrunc

.PHONY:qemu
qemu:
	qemu-system-i386 -fda babyos.img -boot a

.PHONY:bochs
bochs:
	bochs -f scripts/bochsrc.txt

.PHONY:debug
debug:
	qemu -S -s -fda floppy.img -boot a &
	sleep 1
	gdb -x scripts/gdbinit

