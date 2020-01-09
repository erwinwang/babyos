all: boot.img
boot.o: boot.s
	as -o $@ $<
boot: boot.o
	ld --oformat binary -N -Ttext 0x7c00 -o $@ $<
boot.img: boot
	dd if=boot of=babyos.img bs=512 count=1 conv=notrunc
run:
	qemu-system-i386 -m 512M \
		-name "XBook Development Platform for x86" \
		-fda babyos.img -boot a \
		-net nic,vlan=0,model=pcnet,macaddr=12:34:56:78:9a:be \
		-net user,vlan=0 \
		-serial stdio
clean:
	rm ./boot ./boot.o