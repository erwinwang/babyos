ENTRY_POINT = 0x000100000

AS = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump
ASFLAGS = -f elf
CFLAGS = -Wall -c -fno-builtin -W -Wstrict-prototypes \
         -Wmissing-prototypes -Wsystem-headers
#CFLAGS += -O0 -g -ggdb 
LDFLAGS = -m elf_i386

BOOT_BIN = boot.bin
LOADER_BIN = loader.bin

QEMU = qemu-system-i386
QEMUOPTS = -drive file=babyos.img,index=0,media=disk,format=raw -m 512 $(QEMUEXTRA)

##############################################################################################
bootsect.bin: bootsect.asm
	$(AS) -o $@ $<

OBJS = \
	main.o \
	head.o \
	print.o \
	interrupt.o \
	kernel.o \
	init.o \
	timer.o \
	debug.o \
	string.o \
	bitmap.o \
	memory.o

############ 汇编代码 ######################
loader.bin: loader.asm
	$(AS) -o $@ $<

head.o: head.asm
	$(AS) -f elf32 -o $@ $<

kernel.o: kernel.asm
	$(AS) -f elf32 -o $@ $<

print.o: print.asm
	$(AS) -f elf32 -o $@ $<
############ 汇编代码 ######################

timer.o: timer.c
	$(CC) $(CFLAGS) $< -o $@

init.o: init.c
	$(CC) $(CFLAGS) $< -o $@

main.o: main.c
	$(CC) $(CFLAGS) $< -o $@

interrupt.o: interrupt.c
	$(CC) $(CFLAGS) $< -o $@

debug.o: debug.c
	$(CC) $(CFLAGS) $< -o $@

string.o: string.c
	$(CC) $(CFLAGS) $< -o $@

bitmap.o: bitmap.c
	$(CC) $(CFLAGS) $< -o $@

memory.o: memory.c
	$(CC) $(CFLAGS) $< -o $@
	
kernel.elf: $(OBJS)
	$(LD) $(LDFLAGS) -N -e start -Ttext $(ENTRY_POINT) -o $@ $(OBJS)
	$(OBJDUMP) -M intel -D kernel.elf > kernel.elf.dumpdisasm
	
babyos: bootsect.bin loader.bin kernel.elf
	dd if=/dev/zero of=babyos.img bs=512 count=2880
	dd if=bootsect.bin of=babyos.img conv=notrunc
	dd if=loader.bin of=babyos.img bs=512 seek=1 conv=notrunc
	dd if=kernel.elf of=babyos.img bs=512 seek=3 conv=notrunc
##############################################################################################

qemu:babyos
	qemu-system-i386 -m 512M \
		-name "babyos" \
		-hda babyos.img \
		-boot c

qemudbg:
	qemu-system-i386 -m 512M \
		-name "babyos" \
		-fda babyos.img \
		-boot a	\
		-S -s

.PHONY: clean install all
clean:
	rm *.o *.d \
	*.bin *.elf *.sym *.img \
	*.dumpdisasm
# all: build install