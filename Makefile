#!Makefile
#
# --------------------------------------------------------
#
#    hurlex 这个小内核的 Makefile
#    默认使用的C语言编译器是 GCC、汇编语言编译器是 nasm
#
# --------------------------------------------------------
#

CC = gcc
LD = ld
ASM = nasm
OBJCOPY = objcopy
OBJDUMP = objdump

C_FLAGS = -c -fno-pic -fno-stack-protector -static -fno-builtin -fno-strict-aliasing -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer
LD_FLAGS = -T kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f elf
ASM_BINFLAGS = -f bin


########boot.bin loader.bin####################
boot.bin:boot.asm
	$(ASM) $(ASM_BINFLAGS) -o $@ $<

loader.bin:loader.asm
	$(ASM) $(ASM_BINFLAGS) -o $@ $<

#####setup.bin#################################
start.o: start.asm
	$(ASM) $(ASM_FLAGS) $<

setup.o: setup.c
	$(CC) $(C_FLAGS) $< -o $@

page.o: page.c
	$(CC) $(C_FLAGS) $< -o $@

lib.o: lib.c
	$(CC) $(C_FLAGS) $< -o $@

#####end setup.bin#################################
SETUP_LDFLAGS = -m elf_i386 -nostdlib -no-pie -e _start -Ttext 0x91000
SETUP_OBJS    = start.o setup.o page.o lib.o

setup.bin: $(SETUP_OBJS)
	$(LD) $(SETUP_LDFLAGS) -o setup.elf $(SETUP_OBJS)
	$(OBJCOPY) -R .note -R .comment -S -O binary setup.elf $@

#####kernel.elf#################################
main.o: main.c
	$(CC) $(C_FLAGS) $< -o $@

console.o: console.c
	$(CC) $(C_FLAGS) $< -o $@

common.o: common.c
	$(CC) $(C_FLAGS) $< -o $@

printk.o: printk.c
	$(CC) $(C_FLAGS) $< -o $@

gdt.o: gdt.c
	$(CC) $(C_FLAGS) $< -o $@

gdt_flush.o: gdt_flush.asm
	$(ASM) $(ASM_FLAGS) $<

idt.o: idt.c
	$(CC) $(C_FLAGS) $< -o $@

idt_flush.o: idt_flush.asm
	$(ASM) $(ASM_FLAGS) $<

timer.o: timer.c
	$(CC) $(C_FLAGS) $< -o $@

keyboard.o: keyboard.c
	$(CC) $(C_FLAGS) $< -o $@
#####end kernel.elf#################################
KERNEL_LDFLAGS = -m elf_i386 -nostdlib -T kernel.ld 
KERNEL_OBJS    = main.o common.o console.o printk.o gdt.o gdt_flush.o idt.o idt_flush.o\
				timer.o keyboard.o \

kernel.elf: $(KERNEL_OBJS)
	$(LD) $(KERNEL_LDFLAGS) -o $@ $(KERNEL_OBJS)


KERNEL_OFF 	= 100
KERNEL_CNTS	= 1024		# assume 512kb 
.PHONY:linux
linux:boot.bin loader.bin setup.bin kernel.elf
	dd if=/dev/zero of=linux.img bs=512 count=2880
	dd if=boot.bin of=linux.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=linux.img bs=512 seek=2 count=8 conv=notrunc
	dd if=setup.bin of=linux.img bs=512 seek=10 count=90 conv=notrunc
	dd if=kernel.elf of=linux.img bs=512 seek=100 count=1024 conv=notrunc

.PHONY:clean
clean:
	$(RM) *.o *.bin *.elf *.img

.PHONY:qemu
qemu:linux
	qemu-system-i386 -fda linux.img -boot a
	#add '-nographic' option if using server of linux distro, such as fedora-server,or "gtk initialization failed" error will occur.

.PHONY:debug
debug:
	qemu-system-i386 -S -s -fda linux.img -boot a

.PHONY:run
run:qemu

