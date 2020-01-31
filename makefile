AS = as
CC = gcc
LD = ld
NASM = nasm
OBJCOPY = objcopy
OBJDUMP = objdump
ASFLAGS = -g
NASMFLAGS = -f elf
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -O0 -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer
#CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null | head -n 1)

QEMU = qemu-system-i386
QEMUOPTS = -drive file=babyos.img,index=0,media=disk,format=raw -m 512 $(QEMUEXTRA)

OBJS = \
	main.o \
	entry.o \
	io.o	\
	test.o

main.o: main.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c main.c

entry.o: entry.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c entry.S

io.o: io.asm
	$(NASM) $(NASMFLAGS) $< -o $@

test.o: test.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c test.c

bootblock: bootasm.S bootmain.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c bootasm.S
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootblock.o bootasm.o bootmain.o
	$(OBJDUMP) -S bootblock.o > bootblock.asm
	$(OBJCOPY) -S -O binary -j .text bootblock.o bootblock
	./sign.pl bootblock

kernel: $(OBJS) kernel.ld
	$(LD) $(LDFLAGS) -T kernel.ld -o kernel $(OBJS) -b binary
	$(OBJDUMP) -S kernel > kernel.asm
	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym

babyos: bootblock kernel
	dd if=bootblock of=babyos.img conv=notrunc
	dd if=kernel of=babyos.img seek=1 conv=notrunc

qemu:
	$(QEMU) -serial mon:stdio $(QEMUOPTS)

run:
	qemu-system-i386 -m 512M \
		-name "babyos" \
		-fda babyos.img \
		-boot a	\

.PHONY: clean
clean:
	rm *.o bootblock