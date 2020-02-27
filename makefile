AS = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump
ASFLAGS = -f elf32
CFLAGS = -c -o -m32
#CFLAGS += -O0 -g -ggdb 
LDFLAGS = -m elf_i386

BOOT_BIN = boot.bin
LOADER_BIN = loader.bin

QEMU = qemu-system-i386
QEMUOPTS = -drive file=babyos.img,index=0,media=disk,format=raw -m 512 $(QEMUEXTRA)

OBJS = \
	main.o \
	entry.o \
	io.o	\
	test.o
	
io.o: io.asm
	$(AS) $(ASMFLAGS) $< -o $@

test.o: test.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c test.c

bootblock: boot.asm bootmain.c
	$(NASM) -f elf -o boot.o boot.asm
	#$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c bootasm.S
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootblock.o boot.o bootmain.o
	$(OBJDUMP) -S bootblock.o > bootblock.asm
	$(OBJCOPY) -S -O binary -j .text bootblock.o bootblock
	./sign.pl bootblock

# kernel: $(OBJS) kernel.ld
# 	$(LD) $(LDFLAGS) -T kernel.ld -o kernel $(OBJS) -b binary
# 	$(OBJDUMP) -S kernel > kernel.asm
# 	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym

##############################################################################################
bootsect.bin: bootsect.asm
	$(NASM) -o $@ $<

# loader4k.bin: loader.asm bootmain.c x86.asm
# 	$(NASM) -f elf -o loader.o loader.asm
# 	$(NASM) -f elf -o x86.o x86.asm
# 	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c
# 	$(LD) $(LDFLAGS) -N -e start -Ttext 0x70000 -o loader4k.o loader.o bootmain.o x86.o
# 	$(OBJDUMP) -S loader4k.o > loader4k.asm
# 	$(OBJCOPY) -S -O binary -j .text loader4k.o loader4k.bin

loader.bin: loader.asm
	$(NASM) -o $@ $<

head.o: head.asm
	$(NASM) -f elf32 -o $@ $<
	
main.o: main.c
	$(CC) -c -o main.o main.c

lib/kernel/print.o: lib/kernel/print.asm
	$(NASM) -f elf32 -o $@ $<

kernel.elf: main.o head.o lib/kernel/print.o
	$(LD) $(LDFLAGS) -e start -Ttext 0x100000 -o kernel.elf head.o main.o lib/kernel/print.o
	$(OBJDUMP) -D kernel.elf > kernel.elf.dumpdisasm

# kernel.bin: head.o main.o lib/kernel/print.o
# 	$(LD) $(LDFLAGS) -N -e start -Ttext 0x100000 -o kernel.elf head.o main.o lib/kernel/print.o
# 	$(OBJDUMP) -S kernel.elf > kernel.bin.dumpdisasm
# 	$(OBJCOPY) -S -O binary -j .text kernel.elf kernel.bin
	
babyos: bootsect.bin loader.bin kernel.elf
	dd if=/dev/zero of=babyos.img bs=512 count=2880
	dd if=bootsect.bin of=babyos.img conv=notrunc
	dd if=loader.bin of=babyos.img bs=512 seek=1 conv=notrunc
	dd if=kernel.elf of=babyos.img bs=512 seek=3 conv=notrunc

# babyos: bootsect.bin loader.bin kernel.bin
# 	dd if=/dev/zero of=babyos.img bs=512 count=2880
# 	dd if=bootsect.bin of=babyos.img conv=notrunc
# 	dd if=loader.bin of=babyos.img bs=512 seek=1 conv=notrunc
# 	dd if=kernel.bin of=babyos.img bs=512 seek=9 conv=notrunc
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

#################################################################################
#    xv6 template
#################################################################################
# bootblock: bootasm.S bootmain.c
# 	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c bootasm.S
# 	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c
# 	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootblock.o bootasm.o bootmain.o
# 	$(OBJDUMP) -S bootblock.o > bootblock.asm
# 	$(OBJCOPY) -S -O binary -j .text bootblock.o bootblock
# 	./sign.pl bootblock

xv6.img: bootblock kernel.elf
	dd if=/dev/zero of=xv6.img count=10000
	dd if=bootblock of=xv6.img conv=notrunc
	dd if=kernel.elf of=xv6.img seek=1 conv=notrunc

run:xv6.img
	qemu-system-i386 -m 512M \
		-name "xv6" \
		-hda xv6.img \
		-boot c
##################################################################################

.PHONY: clean
clean:
	rm *.o \
	   *.bin \
	   *.elf \
	   lib/kernel/print.o \
	   kernel.dumpdisasm \
	   bootblock