
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 10 10 00       	mov    $0x101000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 00 30 10 80       	mov    $0x80103000,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 44 00 10 80       	mov    $0x80100044,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
	...

80100040 <io_hlt>:
80100040:	f4                   	hlt    
80100041:	c3                   	ret    
	...

80100044 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80100044:	55                   	push   %ebp
80100045:	89 e5                	mov    %esp,%ebp
80100047:	83 e4 f0             	and    $0xfffffff0,%esp
    unsigned long base = 0xb8000;
    base += 2;
    *(char*)base = 'M';
8010004a:	c6 05 02 80 0b 00 4d 	movb   $0x4d,0xb8002
    base++;
    *(char*)base = 0xfc;
80100051:	c6 05 03 80 0b 00 fc 	movb   $0xfc,0xb8003
    for (;;)
    {
         __asm ("hlt");
80100058:	f4                   	hlt    
        extern void io_hlt();
        io_hlt();
80100059:	e8 e2 ff ff ff       	call   80100040 <io_hlt>
8010005e:	eb f8                	jmp    80100058 <main+0x14>
