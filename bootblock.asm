
bootblock.o:     file format elf32-i386


Disassembly of section .text:

00070000 <start>:
   70000:	66 b8 10 00          	mov    $0x10,%ax
   70004:	8e d8                	mov    %eax,%ds
   70006:	8e c0                	mov    %eax,%es
   70008:	8e d0                	mov    %eax,%ss
   7000a:	66 b8 00 00          	mov    $0x0,%ax
   7000e:	8e e0                	mov    %eax,%fs
   70010:	8e e8                	mov    %eax,%gs
   70012:	bc 00 7c 00 00       	mov    $0x7c00,%esp
   70017:	b8 b4 80 0b 00       	mov    $0xb80b4,%eax
   7001c:	c6 00 4c             	movb   $0x4c,(%eax)
   7001f:	40                   	inc    %eax
   70020:	c6 00 2f             	movb   $0x2f,(%eax)
   70023:	e9 fb ff ff ff       	jmp    70023 <start+0x23>
   70028:	e8 bb 00 00 00       	call   700e8 <bootmain>

0007002d <spin>:
   7002d:	f4                   	hlt    
   7002e:	e9 fa ff ff ff       	jmp    7002d <spin>
   70033:	90                   	nop

00070034 <waitdisk>:
    entry();
}

void
waitdisk(void)
{
   70034:	55                   	push   %ebp
   70035:	89 e5                	mov    %esp,%ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
   70037:	ba f7 01 00 00       	mov    $0x1f7,%edx
   7003c:	ec                   	in     (%dx),%al
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
   7003d:	25 c0 00 00 00       	and    $0xc0,%eax
   70042:	83 f8 40             	cmp    $0x40,%eax
   70045:	75 f5                	jne    7003c <waitdisk+0x8>
    ;
}
   70047:	5d                   	pop    %ebp
   70048:	c3                   	ret    

00070049 <readsect>:

// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
   70049:	55                   	push   %ebp
   7004a:	89 e5                	mov    %esp,%ebp
   7004c:	57                   	push   %edi
   7004d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  // Issue command.
  waitdisk();
   70050:	e8 df ff ff ff       	call   70034 <waitdisk>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
   70055:	ba f2 01 00 00       	mov    $0x1f2,%edx
   7005a:	b8 01 00 00 00       	mov    $0x1,%eax
   7005f:	ee                   	out    %al,(%dx)
   70060:	b2 f3                	mov    $0xf3,%dl
   70062:	89 f8                	mov    %edi,%eax
   70064:	ee                   	out    %al,(%dx)
  outb(0x1F2, 1);   // count = 1
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
   70065:	89 f8                	mov    %edi,%eax
   70067:	c1 e8 08             	shr    $0x8,%eax
   7006a:	b2 f4                	mov    $0xf4,%dl
   7006c:	ee                   	out    %al,(%dx)
  outb(0x1F5, offset >> 16);
   7006d:	89 f8                	mov    %edi,%eax
   7006f:	c1 e8 10             	shr    $0x10,%eax
   70072:	b2 f5                	mov    $0xf5,%dl
   70074:	ee                   	out    %al,(%dx)
  outb(0x1F6, (offset >> 24) | 0xE0);
   70075:	c1 ef 18             	shr    $0x18,%edi
   70078:	89 f8                	mov    %edi,%eax
   7007a:	83 c8 e0             	or     $0xffffffe0,%eax
   7007d:	b2 f6                	mov    $0xf6,%dl
   7007f:	ee                   	out    %al,(%dx)
   70080:	b2 f7                	mov    $0xf7,%dl
   70082:	b8 20 00 00 00       	mov    $0x20,%eax
   70087:	ee                   	out    %al,(%dx)
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

  // Read data.
  waitdisk();
   70088:	e8 a7 ff ff ff       	call   70034 <waitdisk>
  asm volatile("cld; rep insl" :
   7008d:	8b 7d 08             	mov    0x8(%ebp),%edi
   70090:	b9 80 00 00 00       	mov    $0x80,%ecx
   70095:	ba f0 01 00 00       	mov    $0x1f0,%edx
   7009a:	fc                   	cld    
   7009b:	f3 6d                	rep insl (%dx),%es:(%edi)
  insl(0x1F0, dst, SECTSIZE/4);
}
   7009d:	5f                   	pop    %edi
   7009e:	5d                   	pop    %ebp
   7009f:	c3                   	ret    

000700a0 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
   700a0:	55                   	push   %ebp
   700a1:	89 e5                	mov    %esp,%ebp
   700a3:	57                   	push   %edi
   700a4:	56                   	push   %esi
   700a5:	53                   	push   %ebx
   700a6:	83 ec 08             	sub    $0x8,%esp
   700a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
   700ac:	8b 75 10             	mov    0x10(%ebp),%esi
  uchar* epa;

  epa = pa + count;
   700af:	89 df                	mov    %ebx,%edi
   700b1:	03 7d 0c             	add    0xc(%ebp),%edi

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;
   700b4:	89 f0                	mov    %esi,%eax
   700b6:	25 ff 01 00 00       	and    $0x1ff,%eax
   700bb:	29 c3                	sub    %eax,%ebx
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
   700bd:	39 df                	cmp    %ebx,%edi
   700bf:	76 1f                	jbe    700e0 <readseg+0x40>
  offset = (offset / SECTSIZE) + 1;
   700c1:	c1 ee 09             	shr    $0x9,%esi
   700c4:	83 c6 01             	add    $0x1,%esi
    readsect(pa, offset);
   700c7:	89 74 24 04          	mov    %esi,0x4(%esp)
   700cb:	89 1c 24             	mov    %ebx,(%esp)
   700ce:	e8 76 ff ff ff       	call   70049 <readsect>
  for(; pa < epa; pa += SECTSIZE, offset++)
   700d3:	81 c3 00 02 00 00    	add    $0x200,%ebx
   700d9:	83 c6 01             	add    $0x1,%esi
   700dc:	39 df                	cmp    %ebx,%edi
   700de:	77 e7                	ja     700c7 <readseg+0x27>
   700e0:	83 c4 08             	add    $0x8,%esp
   700e3:	5b                   	pop    %ebx
   700e4:	5e                   	pop    %esi
   700e5:	5f                   	pop    %edi
   700e6:	5d                   	pop    %ebp
   700e7:	c3                   	ret    

000700e8 <bootmain>:
{
   700e8:	55                   	push   %ebp
   700e9:	89 e5                	mov    %esp,%ebp
   700eb:	57                   	push   %edi
   700ec:	56                   	push   %esi
   700ed:	53                   	push   %ebx
   700ee:	83 ec 2c             	sub    $0x2c,%esp
    readseg((uchar*)elf, 4096, 0);
   700f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
   700f8:	00 
   700f9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
   70100:	00 
   70101:	c7 04 24 00 00 01 00 	movl   $0x10000,(%esp)
   70108:	e8 93 ff ff ff       	call   700a0 <readseg>
    if(elf->magic != ELF_MAGIC)
   7010d:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
   70114:	45 4c 46 
   70117:	75 5d                	jne    70176 <bootmain+0x8e>
    ph = (struct proghdr*)((uchar*)elf + elf->phoff);
   70119:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
   7011f:	81 c3 00 00 01 00    	add    $0x10000,%ebx
    eph = ph + elf->phnum;
   70125:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
   7012c:	c1 e0 05             	shl    $0x5,%eax
   7012f:	01 d8                	add    %ebx,%eax
   70131:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(; ph < eph; ph++){
   70134:	39 c3                	cmp    %eax,%ebx
   70136:	73 38                	jae    70170 <bootmain+0x88>
        pa = (uchar*)ph->paddr;
   70138:	8b 73 0c             	mov    0xc(%ebx),%esi
        readseg(pa, ph->filesz, ph->off);
   7013b:	8b 43 04             	mov    0x4(%ebx),%eax
   7013e:	89 44 24 08          	mov    %eax,0x8(%esp)
   70142:	8b 43 10             	mov    0x10(%ebx),%eax
   70145:	89 44 24 04          	mov    %eax,0x4(%esp)
   70149:	89 34 24             	mov    %esi,(%esp)
   7014c:	e8 4f ff ff ff       	call   700a0 <readseg>
        if(ph->memsz > ph->filesz)
   70151:	8b 4b 14             	mov    0x14(%ebx),%ecx
   70154:	8b 43 10             	mov    0x10(%ebx),%eax
   70157:	39 c1                	cmp    %eax,%ecx
   70159:	76 0d                	jbe    70168 <bootmain+0x80>
            stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
   7015b:	8d 3c 06             	lea    (%esi,%eax,1),%edi
   7015e:	29 c1                	sub    %eax,%ecx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
   70160:	b8 00 00 00 00       	mov    $0x0,%eax
   70165:	fc                   	cld    
   70166:	f3 aa                	rep stos %al,%es:(%edi)
    for(; ph < eph; ph++){
   70168:	83 c3 20             	add    $0x20,%ebx
   7016b:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
   7016e:	77 c8                	ja     70138 <bootmain+0x50>
    entry();
   70170:	ff 15 18 00 01 00    	call   *0x10018
}
   70176:	83 c4 2c             	add    $0x2c,%esp
   70179:	5b                   	pop    %ebx
   7017a:	5e                   	pop    %esi
   7017b:	5f                   	pop    %edi
   7017c:	5d                   	pop    %ebp
   7017d:	c3                   	ret    
