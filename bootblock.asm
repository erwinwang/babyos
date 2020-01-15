
bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.
.code16                       # Assemble for 16-bit mode
.globl start
start:
  cli                         # BIOS enabled interrupts; disable
    7c00:	fa                   	cli    

  # Zero data segment registers DS, ES, and SS.
  xorw    %ax,%ax             # Set %ax to zero
    7c01:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c03:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c05:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c07:	8e d0                	mov    %eax,%ss

00007c09 <seta20.1>:

  # Physical address line A20 is tied to zero so that the first PCs 
  # with 2 MB would run software that assumed 1 MB.  Undo that.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c09:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0b:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0d:	75 fa                	jne    7c09 <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c0f:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c11:	e6 64                	out    %al,$0x64

00007c13 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c13:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c15:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c17:	75 fa                	jne    7c13 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c19:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1b:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode.  Use a bootstrap GDT that makes
  # virtual addresses map directly to physical addresses so that the
  # effective memory map doesn't change during the transition.
  lgdt    gdtdesc
    7c1d:	0f 01 16             	lgdtl  (%esi)
    7c20:	78 7c                	js     7c9e <waitdisk+0x3>
  movl    %cr0, %eax
    7c22:	0f 20 c0             	mov    %cr0,%eax
  orl     $CR0_PE, %eax
    7c25:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c29:	0f 22 c0             	mov    %eax,%cr0

//PAGEBREAK!
  # Complete the transition to 32-bit protected mode by using a long jmp
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
  ljmp    $(SEG_KCODE<<3), $start32
    7c2c:	ea                   	.byte 0xea
    7c2d:	31 7c 08 00          	xor    %edi,0x0(%eax,%ecx,1)

00007c31 <start32>:

.code32  # Tell assembler to generate 32-bit code now.
start32:
  # Set up the protected-mode data segment registers
  movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
    7c31:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c35:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c37:	8e c0                	mov    %eax,%es
  movw    %ax, %ss                # -> SS: Stack Segment
    7c39:	8e d0                	mov    %eax,%ss
  movw    $0, %ax                 # Zero segments not ready for use
    7c3b:	66 b8 00 00          	mov    $0x0,%ax
  movw    %ax, %fs                # -> FS
    7c3f:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c41:	8e e8                	mov    %eax,%gs

  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c43:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call    bootmain
    7c48:	e8 02 01 00 00       	call   7d4f <bootmain>

  # If bootmain returns (it shouldn't), trigger a Bochs
  # breakpoint if running under Bochs, then loop.
  movw    $0x8a00, %ax            # 0x8a00 -> port 0x8a00
    7c4d:	66 b8 00 8a          	mov    $0x8a00,%ax
  movw    %ax, %dx
    7c51:	66 89 c2             	mov    %ax,%dx
  outw    %ax, %dx
    7c54:	66 ef                	out    %ax,(%dx)
  movw    $0x8ae0, %ax            # 0x8ae0 -> port 0x8a00
    7c56:	66 b8 e0 8a          	mov    $0x8ae0,%ax
  outw    %ax, %dx
    7c5a:	66 ef                	out    %ax,(%dx)

00007c5c <spin>:
spin:
  jmp     spin
    7c5c:	eb fe                	jmp    7c5c <spin>
    7c5e:	66 90                	xchg   %ax,%ax

00007c60 <gdt>:
	...
    7c68:	ff                   	(bad)  
    7c69:	ff 00                	incl   (%eax)
    7c6b:	00 00                	add    %al,(%eax)
    7c6d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c74:	00                   	.byte 0x0
    7c75:	92                   	xchg   %eax,%edx
    7c76:	cf                   	iret   
	...

00007c78 <gdtdesc>:
    7c78:	17                   	pop    %ss
    7c79:	00 60 7c             	add    %ah,0x7c(%eax)
    7c7c:	00 00                	add    %al,(%eax)
    7c7e:	90                   	nop
    7c7f:	90                   	nop

00007c80 <clear_screen>:
#define SECTSIZE  512

void readseg(uchar*, uint, uint);

void clear_screen()
{
    7c80:	55                   	push   %ebp
    7c81:	89 e5                	mov    %esp,%ebp
    int i;
    unsigned long base = 0xb8000;
    7c83:	b8 00 80 0b 00       	mov    $0xb8000,%eax
    for (i = 0; i < 80 * 25; i++)
    {
        /* code */
        *(char*)base = ' ';
    7c88:	c6 00 20             	movb   $0x20,(%eax)
        base++;
        *(char*)base = 0x07;
    7c8b:	c6 40 01 07          	movb   $0x7,0x1(%eax)
        base++;
    7c8f:	83 c0 02             	add    $0x2,%eax
    for (i = 0; i < 80 * 25; i++)
    7c92:	3d a0 8f 0b 00       	cmp    $0xb8fa0,%eax
    7c97:	75 ef                	jne    7c88 <clear_screen+0x8>
    }
}
    7c99:	5d                   	pop    %ebp
    7c9a:	c3                   	ret    

00007c9b <waitdisk>:
    entry();
}

void
waitdisk(void)
{
    7c9b:	55                   	push   %ebp
    7c9c:	89 e5                	mov    %esp,%ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
    7c9e:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7ca3:	ec                   	in     (%dx),%al
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
    7ca4:	25 c0 00 00 00       	and    $0xc0,%eax
    7ca9:	83 f8 40             	cmp    $0x40,%eax
    7cac:	75 f5                	jne    7ca3 <waitdisk+0x8>
    ;
}
    7cae:	5d                   	pop    %ebp
    7caf:	c3                   	ret    

00007cb0 <readsect>:

// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
    7cb0:	55                   	push   %ebp
    7cb1:	89 e5                	mov    %esp,%ebp
    7cb3:	57                   	push   %edi
    7cb4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  // Issue command.
  waitdisk();
    7cb7:	e8 df ff ff ff       	call   7c9b <waitdisk>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
    7cbc:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7cc1:	b8 01 00 00 00       	mov    $0x1,%eax
    7cc6:	ee                   	out    %al,(%dx)
    7cc7:	b2 f3                	mov    $0xf3,%dl
    7cc9:	89 f8                	mov    %edi,%eax
    7ccb:	ee                   	out    %al,(%dx)
  outb(0x1F2, 1);   // count = 1
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
    7ccc:	89 f8                	mov    %edi,%eax
    7cce:	c1 e8 08             	shr    $0x8,%eax
    7cd1:	b2 f4                	mov    $0xf4,%dl
    7cd3:	ee                   	out    %al,(%dx)
  outb(0x1F5, offset >> 16);
    7cd4:	89 f8                	mov    %edi,%eax
    7cd6:	c1 e8 10             	shr    $0x10,%eax
    7cd9:	b2 f5                	mov    $0xf5,%dl
    7cdb:	ee                   	out    %al,(%dx)
  outb(0x1F6, (offset >> 24) | 0xE0);
    7cdc:	c1 ef 18             	shr    $0x18,%edi
    7cdf:	89 f8                	mov    %edi,%eax
    7ce1:	83 c8 e0             	or     $0xffffffe0,%eax
    7ce4:	b2 f6                	mov    $0xf6,%dl
    7ce6:	ee                   	out    %al,(%dx)
    7ce7:	b2 f7                	mov    $0xf7,%dl
    7ce9:	b8 20 00 00 00       	mov    $0x20,%eax
    7cee:	ee                   	out    %al,(%dx)
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

  // Read data.
  waitdisk();
    7cef:	e8 a7 ff ff ff       	call   7c9b <waitdisk>
  asm volatile("cld; rep insl" :
    7cf4:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cf7:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cfc:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d01:	fc                   	cld    
    7d02:	f3 6d                	rep insl (%dx),%es:(%edi)
  insl(0x1F0, dst, SECTSIZE/4);
}
    7d04:	5f                   	pop    %edi
    7d05:	5d                   	pop    %ebp
    7d06:	c3                   	ret    

00007d07 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
    7d07:	55                   	push   %ebp
    7d08:	89 e5                	mov    %esp,%ebp
    7d0a:	57                   	push   %edi
    7d0b:	56                   	push   %esi
    7d0c:	53                   	push   %ebx
    7d0d:	83 ec 08             	sub    $0x8,%esp
    7d10:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7d13:	8b 75 10             	mov    0x10(%ebp),%esi
  uchar* epa;

  epa = pa + count;
    7d16:	89 df                	mov    %ebx,%edi
    7d18:	03 7d 0c             	add    0xc(%ebp),%edi

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;
    7d1b:	89 f0                	mov    %esi,%eax
    7d1d:	25 ff 01 00 00       	and    $0x1ff,%eax
    7d22:	29 c3                	sub    %eax,%ebx
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d24:	39 df                	cmp    %ebx,%edi
    7d26:	76 1f                	jbe    7d47 <readseg+0x40>
  offset = (offset / SECTSIZE) + 1;
    7d28:	c1 ee 09             	shr    $0x9,%esi
    7d2b:	83 c6 01             	add    $0x1,%esi
    readsect(pa, offset);
    7d2e:	89 74 24 04          	mov    %esi,0x4(%esp)
    7d32:	89 1c 24             	mov    %ebx,(%esp)
    7d35:	e8 76 ff ff ff       	call   7cb0 <readsect>
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d3a:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d40:	83 c6 01             	add    $0x1,%esi
    7d43:	39 df                	cmp    %ebx,%edi
    7d45:	77 e7                	ja     7d2e <readseg+0x27>
    7d47:	83 c4 08             	add    $0x8,%esp
    7d4a:	5b                   	pop    %ebx
    7d4b:	5e                   	pop    %esi
    7d4c:	5f                   	pop    %edi
    7d4d:	5d                   	pop    %ebp
    7d4e:	c3                   	ret    

00007d4f <bootmain>:
{
    7d4f:	55                   	push   %ebp
    7d50:	89 e5                	mov    %esp,%ebp
    7d52:	57                   	push   %edi
    7d53:	56                   	push   %esi
    7d54:	53                   	push   %ebx
    7d55:	83 ec 2c             	sub    $0x2c,%esp
    clear_screen();
    7d58:	e8 23 ff ff ff       	call   7c80 <clear_screen>
    *(char*)base = 'B';
    7d5d:	c6 05 00 80 0b 00 42 	movb   $0x42,0xb8000
    *(char*)base = 0xfc;
    7d64:	c6 05 01 80 0b 00 fc 	movb   $0xfc,0xb8001
    readseg((uchar*)elf, 4096, 0);
    7d6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
    7d72:	00 
    7d73:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
    7d7a:	00 
    7d7b:	c7 04 24 00 00 01 00 	movl   $0x10000,(%esp)
    7d82:	e8 80 ff ff ff       	call   7d07 <readseg>
    if(elf->magic != ELF_MAGIC)
    7d87:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d8e:	45 4c 46 
    7d91:	75 5d                	jne    7df0 <bootmain+0xa1>
    ph = (struct proghdr*)((uchar*)elf + elf->phoff);
    7d93:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
    7d99:	81 c3 00 00 01 00    	add    $0x10000,%ebx
    eph = ph + elf->phnum;
    7d9f:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7da6:	c1 e0 05             	shl    $0x5,%eax
    7da9:	01 d8                	add    %ebx,%eax
    7dab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(; ph < eph; ph++){
    7dae:	39 c3                	cmp    %eax,%ebx
    7db0:	73 38                	jae    7dea <bootmain+0x9b>
        pa = (uchar*)ph->paddr;
    7db2:	8b 73 0c             	mov    0xc(%ebx),%esi
        readseg(pa, ph->filesz, ph->off);
    7db5:	8b 43 04             	mov    0x4(%ebx),%eax
    7db8:	89 44 24 08          	mov    %eax,0x8(%esp)
    7dbc:	8b 43 10             	mov    0x10(%ebx),%eax
    7dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
    7dc3:	89 34 24             	mov    %esi,(%esp)
    7dc6:	e8 3c ff ff ff       	call   7d07 <readseg>
        if(ph->memsz > ph->filesz)
    7dcb:	8b 4b 14             	mov    0x14(%ebx),%ecx
    7dce:	8b 43 10             	mov    0x10(%ebx),%eax
    7dd1:	39 c1                	cmp    %eax,%ecx
    7dd3:	76 0d                	jbe    7de2 <bootmain+0x93>
            stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
    7dd5:	8d 3c 06             	lea    (%esi,%eax,1),%edi
    7dd8:	29 c1                	sub    %eax,%ecx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    7dda:	b8 00 00 00 00       	mov    $0x0,%eax
    7ddf:	fc                   	cld    
    7de0:	f3 aa                	rep stos %al,%es:(%edi)
    for(; ph < eph; ph++){
    7de2:	83 c3 20             	add    $0x20,%ebx
    7de5:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
    7de8:	77 c8                	ja     7db2 <bootmain+0x63>
    entry();
    7dea:	ff 15 18 00 01 00    	call   *0x10018
}
    7df0:	83 c4 2c             	add    $0x2c,%esp
    7df3:	5b                   	pop    %ebx
    7df4:	5e                   	pop    %esi
    7df5:	5f                   	pop    %edi
    7df6:	5d                   	pop    %ebp
    7df7:	c3                   	ret    
