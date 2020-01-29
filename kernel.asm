
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80100000:	55                   	push   %ebp
80100001:	89 e5                	mov    %esp,%ebp
80100003:	83 e4 f0             	and    $0xfffffff0,%esp
    int i = 0;
    unsigned long base = 0xb8000;
    base += 2;
    *(char*)base = 'M';
80100006:	c6 05 02 80 0b 00 4d 	movb   $0x4d,0xb8002
    base++;
    *(char*)base = 0xfc;
8010000d:	c6 05 03 80 0b 00 fc 	movb   $0xfc,0xb8003
    extern void test();
    test();
80100014:	e8 4b 00 00 00       	call   80100064 <test>
    while(i <= 100)
    {
      // __asm ("hlt");
      io_hlt();
80100019:	e8 42 00 00 00       	call   80100060 <io_hlt>
8010001e:	eb f9                	jmp    80100019 <main+0x19>

80100020 <multiboot_header>:
80100020:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100026:	00 00                	add    %al,(%eax)
80100028:	fe 4f 52             	decb   0x52(%edi)
8010002b:	e4                   	.byte 0xe4

8010002c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010002c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010002f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100032:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100035:	b8 00 10 10 00       	mov    $0x101000,%eax
  movl    %eax, %cr3
8010003a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010003d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100040:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100045:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100048:	bc 10 30 10 80       	mov    $0x80103010,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010004d:	b8 00 00 10 80       	mov    $0x80100000,%eax
  jmp *%eax
80100052:	ff e0                	jmp    *%eax
	...

80100060 <io_hlt>:
80100060:	f4                   	hlt    
80100061:	c3                   	ret    
	...

80100064 <test>:
void test();
static unsigned long base = 0xb8000;
void test()
{
80100064:	55                   	push   %ebp
80100065:	89 e5                	mov    %esp,%ebp
    base+=4;
80100067:	a1 00 20 10 80       	mov    0x80102000,%eax
    *(char*)base = 'W';
8010006c:	c6 40 04 57          	movb   $0x57,0x4(%eax)
    base++;
    *(char*)base = 0xfc;
80100070:	c6 40 05 fc          	movb   $0xfc,0x5(%eax)
    base++;
80100074:	83 c0 06             	add    $0x6,%eax
80100077:	a3 00 20 10 80       	mov    %eax,0x80102000
8010007c:	5d                   	pop    %ebp
8010007d:	c3                   	ret    
