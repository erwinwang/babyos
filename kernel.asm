
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
    unsigned long base = 0xb8000;
    base += 2;
    *(char*)base = 'M';
80100003:	c6 05 02 80 0b 00 4d 	movb   $0x4d,0xb8002
    base++;
    *(char*)base = 0xfc;
8010000a:	c6 05 03 80 0b 00 fc 	movb   $0xfc,0xb8003
    extern void test();
    while(1)
    {
        // test();
         __asm ("hlt");
80100011:	f4                   	hlt    
80100012:	eb fd                	jmp    80100011 <main+0x11>

80100014 <dump>:
    return 0;
}

// Dump fixed
void dump()
{
80100014:	55                   	push   %ebp
80100015:	89 e5                	mov    %esp,%ebp
80100017:	83 ec 08             	sub    $0x8,%esp
  io_hlt();
8010001a:	e8 41 00 00 00       	call   80100060 <io_hlt>
}
8010001f:	c9                   	leave  
80100020:	c3                   	ret    
80100021:	00 00                	add    %al,(%eax)
	...

80100024 <multiboot_header>:
80100024:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
8010002a:	00 00                	add    %al,(%eax)
8010002c:	fe 4f 52             	decb   0x52(%edi)
8010002f:	e4                   	.byte 0xe4

80100030 <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100030:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100033:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100036:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100039:	b8 00 10 10 00       	mov    $0x101000,%eax
  movl    %eax, %cr3
8010003e:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
80100041:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100044:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100049:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010004c:	bc 00 30 10 80       	mov    $0x80103000,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
80100051:	b8 00 00 10 80       	mov    $0x80100000,%eax
  jmp *%eax
80100056:	ff e0                	jmp    *%eax
	...

80100060 <io_hlt>:
80100060:	f4                   	hlt    
80100061:	c3                   	ret    
	...

80100064 <test>:
void test();
void test()
{
80100064:	55                   	push   %ebp
80100065:	89 e5                	mov    %esp,%ebp
     unsigned long base = 0xb8000;
     base += 4;
     *(char*)base = 'W';
80100067:	c6 05 04 80 0b 00 57 	movb   $0x57,0xb8004
    base++;
    *(char*)base = 0xfc;
8010006e:	c6 05 05 80 0b 00 fc 	movb   $0xfc,0xb8005
80100075:	5d                   	pop    %ebp
80100076:	c3                   	ret    
