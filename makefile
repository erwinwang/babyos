AS = as
CC = gcc
LD = ld
OBJCOPY = objcopy
OBJDUMP = objdump
CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer
#CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
LDFLAGS += -m $(shell $(LD) -V | grep elf_i386 2>/dev/null | head -n 1)

QEMU = qemu-system-i386
QEMUOPTS = -drive file=babyos.img,index=0,media=disk,format=raw -m 512 $(QEMUEXTRA)

boot: boot.o
	ld --oformat binary -N -Ttext 0x7c00 -o $@ $<

OBJS = \
	main.o

main.o: main.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c main.c
entry.o: entry.S
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c entry.S

kernel: $(OBJS) entry.o kernel.ld
	$(LD) $(LDFLAGS) -T kernel.ld -o kernel entry.o $(OBJS) -b binary
	$(OBJDUMP) -S kernel > kernel.asm
	$(OBJDUMP) -t kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym

bootblock: bootasm.S bootmain.c
	$(CC) $(CFLAGS) -fno-pic -O -nostdinc -I. -c bootmain.c
	$(CC) $(CFLAGS) -fno-pic -nostdinc -I. -c bootasm.S
	$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o bootblock.o bootasm.o bootmain.o
	$(OBJDUMP) -S bootblock.o > bootblock.asm
	$(OBJCOPY) -S -O binary -j .text bootblock.o bootblock
	./sign.pl bootblock

babyos.img:bootblock kernel
	dd if=bootblock of=babyos.img conv=notrunc
	dd if=kernel of=babyos.img seek=1 conv=notrunc
qemu:
	$(QEMU) -serial mon:stdio $(QEMUOPTS)

run:
	qemu-system-i386 -m 512M \
		-name "babyos" \
		-fda babyos.img -boot a
.PHONY: clean
clean:
	rm *.o