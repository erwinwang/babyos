CC=gcc -m32
LD=ld -m elf_i386

QEMU = qemu-system-i386
all: babyos
babyos: bootsect.bin
boot: boot.o
	ld --oformat binary -N -Ttext 0x7c00 -o $@ $<

load.o:load.s
	as -o $@ $<
bootsect.bin: bootsect.asm
	nasm -o main.img bootsect.asm 
babyos:bootsect.bin
	dd if=bootsect.bin of=babyos.img bs=512 count=1 conv=notrunc
run:
	qemu-system-i386 -m 512M \
		-name "babyos" \
		-fda babyos.img -boot a
.PHONY: clean
clean:
	rm ./boot ./boot.o ./load ./load.o