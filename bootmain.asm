
bootmain.o:     file format elf32-i386


Disassembly of section .text:

00000000 <clear_screen>:
#define SECTSIZE  512

void readseg(uchar*, uint, uint);

void clear_screen()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
    int i;
    unsigned long base = 0xb8000;
   3:	b8 00 80 0b 00       	mov    $0xb8000,%eax
    for (i = 0; i < 80 * 25; i++)
    {
        /* code */
        *(char*)base = ' ';
   8:	c6 00 20             	movb   $0x20,(%eax)
        base++;
        *(char*)base = 0x07;
   b:	c6 40 01 07          	movb   $0x7,0x1(%eax)
        base++;
   f:	83 c0 02             	add    $0x2,%eax
    for (i = 0; i < 80 * 25; i++)
  12:	3d a0 8f 0b 00       	cmp    $0xb8fa0,%eax
  17:	75 ef                	jne    8 <clear_screen+0x8>
    }
}
  19:	5d                   	pop    %ebp
  1a:	c3                   	ret    

0000001b <waitdisk>:
    entry();
}

void
waitdisk(void)
{
  1b:	55                   	push   %ebp
  1c:	89 e5                	mov    %esp,%ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  1e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  23:	ec                   	in     (%dx),%al
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
  24:	25 c0 00 00 00       	and    $0xc0,%eax
  29:	83 f8 40             	cmp    $0x40,%eax
  2c:	75 f5                	jne    23 <waitdisk+0x8>
    ;
}
  2e:	5d                   	pop    %ebp
  2f:	c3                   	ret    

00000030 <readsect>:

// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
  30:	55                   	push   %ebp
  31:	89 e5                	mov    %esp,%ebp
  33:	57                   	push   %edi
  34:	8b 7d 0c             	mov    0xc(%ebp),%edi
  // Issue command.
  waitdisk();
  37:	e8 fc ff ff ff       	call   38 <readsect+0x8>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
  3c:	ba f2 01 00 00       	mov    $0x1f2,%edx
  41:	b8 01 00 00 00       	mov    $0x1,%eax
  46:	ee                   	out    %al,(%dx)
  47:	b2 f3                	mov    $0xf3,%dl
  49:	89 f8                	mov    %edi,%eax
  4b:	ee                   	out    %al,(%dx)
  outb(0x1F2, 1);   // count = 1
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
  4c:	89 f8                	mov    %edi,%eax
  4e:	c1 e8 08             	shr    $0x8,%eax
  51:	b2 f4                	mov    $0xf4,%dl
  53:	ee                   	out    %al,(%dx)
  outb(0x1F5, offset >> 16);
  54:	89 f8                	mov    %edi,%eax
  56:	c1 e8 10             	shr    $0x10,%eax
  59:	b2 f5                	mov    $0xf5,%dl
  5b:	ee                   	out    %al,(%dx)
  outb(0x1F6, (offset >> 24) | 0xE0);
  5c:	c1 ef 18             	shr    $0x18,%edi
  5f:	89 f8                	mov    %edi,%eax
  61:	83 c8 e0             	or     $0xffffffe0,%eax
  64:	b2 f6                	mov    $0xf6,%dl
  66:	ee                   	out    %al,(%dx)
  67:	b2 f7                	mov    $0xf7,%dl
  69:	b8 20 00 00 00       	mov    $0x20,%eax
  6e:	ee                   	out    %al,(%dx)
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

  // Read data.
  waitdisk();
  6f:	e8 fc ff ff ff       	call   70 <readsect+0x40>
  asm volatile("cld; rep insl" :
  74:	8b 7d 08             	mov    0x8(%ebp),%edi
  77:	b9 80 00 00 00       	mov    $0x80,%ecx
  7c:	ba f0 01 00 00       	mov    $0x1f0,%edx
  81:	fc                   	cld    
  82:	f3 6d                	rep insl (%dx),%es:(%edi)
  insl(0x1F0, dst, SECTSIZE/4);
}
  84:	5f                   	pop    %edi
  85:	5d                   	pop    %ebp
  86:	c3                   	ret    

00000087 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
  87:	55                   	push   %ebp
  88:	89 e5                	mov    %esp,%ebp
  8a:	57                   	push   %edi
  8b:	56                   	push   %esi
  8c:	53                   	push   %ebx
  8d:	83 ec 08             	sub    $0x8,%esp
  90:	8b 5d 08             	mov    0x8(%ebp),%ebx
  93:	8b 75 10             	mov    0x10(%ebp),%esi
  uchar* epa;

  epa = pa + count;
  96:	89 df                	mov    %ebx,%edi
  98:	03 7d 0c             	add    0xc(%ebp),%edi

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;
  9b:	89 f0                	mov    %esi,%eax
  9d:	25 ff 01 00 00       	and    $0x1ff,%eax
  a2:	29 c3                	sub    %eax,%ebx
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
  a4:	39 df                	cmp    %ebx,%edi
  a6:	76 1f                	jbe    c7 <readseg+0x40>
  offset = (offset / SECTSIZE) + 1;
  a8:	c1 ee 09             	shr    $0x9,%esi
  ab:	83 c6 01             	add    $0x1,%esi
    readsect(pa, offset);
  ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  b2:	89 1c 24             	mov    %ebx,(%esp)
  b5:	e8 fc ff ff ff       	call   b6 <readseg+0x2f>
  for(; pa < epa; pa += SECTSIZE, offset++)
  ba:	81 c3 00 02 00 00    	add    $0x200,%ebx
  c0:	83 c6 01             	add    $0x1,%esi
  c3:	39 df                	cmp    %ebx,%edi
  c5:	77 e7                	ja     ae <readseg+0x27>
  c7:	83 c4 08             	add    $0x8,%esp
  ca:	5b                   	pop    %ebx
  cb:	5e                   	pop    %esi
  cc:	5f                   	pop    %edi
  cd:	5d                   	pop    %ebp
  ce:	c3                   	ret    

000000cf <bootmain>:
{
  cf:	55                   	push   %ebp
  d0:	89 e5                	mov    %esp,%ebp
  d2:	57                   	push   %edi
  d3:	56                   	push   %esi
  d4:	53                   	push   %ebx
  d5:	83 ec 2c             	sub    $0x2c,%esp
    clear_screen();
  d8:	e8 fc ff ff ff       	call   d9 <bootmain+0xa>
    *(char*)base = 'B';
  dd:	c6 05 00 80 0b 00 42 	movb   $0x42,0xb8000
    *(char*)base = 0xfc;
  e4:	c6 05 01 80 0b 00 fc 	movb   $0xfc,0xb8001
    readseg((uchar*)elf, 4096, 0);
  eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  f2:	00 
  f3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  fa:	00 
  fb:	c7 04 24 00 00 01 00 	movl   $0x10000,(%esp)
 102:	e8 fc ff ff ff       	call   103 <bootmain+0x34>
    if(elf->magic != ELF_MAGIC)
 107:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
 10e:	45 4c 46 
 111:	75 5d                	jne    170 <bootmain+0xa1>
    ph = (struct proghdr*)((uchar*)elf + elf->phoff);
 113:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
 119:	81 c3 00 00 01 00    	add    $0x10000,%ebx
    eph = ph + elf->phnum;
 11f:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
 126:	c1 e0 05             	shl    $0x5,%eax
 129:	01 d8                	add    %ebx,%eax
 12b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(; ph < eph; ph++){
 12e:	39 c3                	cmp    %eax,%ebx
 130:	73 38                	jae    16a <bootmain+0x9b>
        pa = (uchar*)ph->paddr;
 132:	8b 73 0c             	mov    0xc(%ebx),%esi
        readseg(pa, ph->filesz, ph->off);
 135:	8b 43 04             	mov    0x4(%ebx),%eax
 138:	89 44 24 08          	mov    %eax,0x8(%esp)
 13c:	8b 43 10             	mov    0x10(%ebx),%eax
 13f:	89 44 24 04          	mov    %eax,0x4(%esp)
 143:	89 34 24             	mov    %esi,(%esp)
 146:	e8 fc ff ff ff       	call   147 <bootmain+0x78>
        if(ph->memsz > ph->filesz)
 14b:	8b 4b 14             	mov    0x14(%ebx),%ecx
 14e:	8b 43 10             	mov    0x10(%ebx),%eax
 151:	39 c1                	cmp    %eax,%ecx
 153:	76 0d                	jbe    162 <bootmain+0x93>
            stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
 155:	8d 3c 06             	lea    (%esi,%eax,1),%edi
 158:	29 c1                	sub    %eax,%ecx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 15a:	b8 00 00 00 00       	mov    $0x0,%eax
 15f:	fc                   	cld    
 160:	f3 aa                	rep stos %al,%es:(%edi)
    for(; ph < eph; ph++){
 162:	83 c3 20             	add    $0x20,%ebx
 165:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
 168:	77 c8                	ja     132 <bootmain+0x63>
    entry();
 16a:	ff 15 18 00 01 00    	call   *0x10018
}
 170:	83 c4 2c             	add    $0x2c,%esp
 173:	5b                   	pop    %ebx
 174:	5e                   	pop    %esi
 175:	5f                   	pop    %edi
 176:	5d                   	pop    %ebp
 177:	c3                   	ret    
