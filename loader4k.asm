
loader4k.o:     file format elf32-i386


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
   70017:	b8 a0 80 0b 00       	mov    $0xb80a0,%eax
   7001c:	c6 00 4c             	movb   $0x4c,(%eax)
   7001f:	40                   	inc    %eax
   70020:	c6 00 2f             	movb   $0x2f,(%eax)

00070023 <move_kernel>:
   70023:	b9 00 04 00 00       	mov    $0x400,%ecx
   70028:	fc                   	cld    
   70029:	be 00 10 07 00       	mov    $0x71000,%esi
   7002e:	bf 00 00 10 00       	mov    $0x100000,%edi
   70033:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
   70035:	e8 20 01 00 00       	call   7015a <bootmain>

0007003a <spin>:
   7003a:	f4                   	hlt    
   7003b:	e9 fa ff ff ff       	jmp    7003a <spin>

00070040 <waitdisk>:
 
}

void
waitdisk(void)
{
   70040:	55                   	push   %ebp
   70041:	89 e5                	mov    %esp,%ebp
   70043:	83 ec 18             	sub    $0x18,%esp
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
   70046:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
   7004d:	e8 5e 01 00 00       	call   701b0 <inb>
   70052:	25 c0 00 00 00       	and    $0xc0,%eax
   70057:	83 f8 40             	cmp    $0x40,%eax
   7005a:	75 ea                	jne    70046 <waitdisk+0x6>
    ;
}
   7005c:	c9                   	leave  
   7005d:	c3                   	ret    

0007005e <readsect>:

// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
   7005e:	55                   	push   %ebp
   7005f:	89 e5                	mov    %esp,%ebp
   70061:	53                   	push   %ebx
   70062:	83 ec 14             	sub    $0x14,%esp
   70065:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  // Issue command.
  waitdisk();
   70068:	e8 d3 ff ff ff       	call   70040 <waitdisk>
  outb(0x1F2, 1);   // count = 1
   7006d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
   70074:	00 
   70075:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
   7007c:	e8 3d 01 00 00       	call   701be <outb>
  outb(0x1F3, offset);
   70081:	0f b6 c3             	movzbl %bl,%eax
   70084:	89 44 24 04          	mov    %eax,0x4(%esp)
   70088:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
   7008f:	e8 2a 01 00 00       	call   701be <outb>
  outb(0x1F4, offset >> 8);
   70094:	0f b6 c7             	movzbl %bh,%eax
   70097:	89 44 24 04          	mov    %eax,0x4(%esp)
   7009b:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
   700a2:	e8 17 01 00 00       	call   701be <outb>
  outb(0x1F5, offset >> 16);
   700a7:	89 d8                	mov    %ebx,%eax
   700a9:	c1 e8 10             	shr    $0x10,%eax
   700ac:	0f b6 c0             	movzbl %al,%eax
   700af:	89 44 24 04          	mov    %eax,0x4(%esp)
   700b3:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
   700ba:	e8 ff 00 00 00       	call   701be <outb>
  outb(0x1F6, (offset >> 24) | 0xE0);
   700bf:	c1 eb 18             	shr    $0x18,%ebx
   700c2:	83 cb e0             	or     $0xffffffe0,%ebx
   700c5:	0f b6 db             	movzbl %bl,%ebx
   700c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
   700cc:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
   700d3:	e8 e6 00 00 00       	call   701be <outb>
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors
   700d8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
   700df:	00 
   700e0:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
   700e7:	e8 d2 00 00 00       	call   701be <outb>

  // Read data.
  waitdisk();
   700ec:	e8 4f ff ff ff       	call   70040 <waitdisk>
  insl(0x1F0, dst, SECTSIZE/4);
   700f1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
   700f8:	00 
   700f9:	8b 45 08             	mov    0x8(%ebp),%eax
   700fc:	89 44 24 04          	mov    %eax,0x4(%esp)
   70100:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
   70107:	e8 c3 00 00 00       	call   701cf <insl>
}
   7010c:	83 c4 14             	add    $0x14,%esp
   7010f:	5b                   	pop    %ebx
   70110:	5d                   	pop    %ebp
   70111:	c3                   	ret    

00070112 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
   70112:	55                   	push   %ebp
   70113:	89 e5                	mov    %esp,%ebp
   70115:	57                   	push   %edi
   70116:	56                   	push   %esi
   70117:	53                   	push   %ebx
   70118:	83 ec 1c             	sub    $0x1c,%esp
   7011b:	8b 5d 08             	mov    0x8(%ebp),%ebx
   7011e:	8b 75 10             	mov    0x10(%ebp),%esi
  uchar* epa;

  epa = pa + count;
   70121:	89 df                	mov    %ebx,%edi
   70123:	03 7d 0c             	add    0xc(%ebp),%edi

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;
   70126:	89 f0                	mov    %esi,%eax
   70128:	25 ff 01 00 00       	and    $0x1ff,%eax
   7012d:	29 c3                	sub    %eax,%ebx
  offset = (offset / SECTSIZE) + 9;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
   7012f:	39 df                	cmp    %ebx,%edi
   70131:	76 1f                	jbe    70152 <readseg+0x40>
  offset = (offset / SECTSIZE) + 9;
   70133:	c1 ee 09             	shr    $0x9,%esi
   70136:	83 c6 09             	add    $0x9,%esi
    readsect(pa, offset);
   70139:	89 74 24 04          	mov    %esi,0x4(%esp)
   7013d:	89 1c 24             	mov    %ebx,(%esp)
   70140:	e8 19 ff ff ff       	call   7005e <readsect>
  for(; pa < epa; pa += SECTSIZE, offset++)
   70145:	81 c3 00 02 00 00    	add    $0x200,%ebx
   7014b:	83 c6 01             	add    $0x1,%esi
   7014e:	39 df                	cmp    %ebx,%edi
   70150:	77 e7                	ja     70139 <readseg+0x27>
   70152:	83 c4 1c             	add    $0x1c,%esp
   70155:	5b                   	pop    %ebx
   70156:	5e                   	pop    %esi
   70157:	5f                   	pop    %edi
   70158:	5d                   	pop    %ebp
   70159:	c3                   	ret    

0007015a <bootmain>:
{
   7015a:	55                   	push   %ebp
   7015b:	89 e5                	mov    %esp,%ebp
   7015d:	83 ec 18             	sub    $0x18,%esp
    *(char*)(0xb8000 + 320) = 'E';
   70160:	c6 05 40 81 0b 00 45 	movb   $0x45,0xb8140
    *(char*)(0xb8000 + 321) = 0x2f;
   70167:	c6 05 41 81 0b 00 2f 	movb   $0x2f,0xb8141
    *(char*)(0xb8000 + 322) = 'L';
   7016e:	c6 05 42 81 0b 00 4c 	movb   $0x4c,0xb8142
    *(char*)(0xb8000 + 323) = 0x2f;
   70175:	c6 05 43 81 0b 00 2f 	movb   $0x2f,0xb8143
    *(char*)(0xb8000 + 324) = 'F';
   7017c:	c6 05 44 81 0b 00 46 	movb   $0x46,0xb8144
    *(char*)(0xb8000 + 325) = 0x2f;
   70183:	c6 05 45 81 0b 00 2f 	movb   $0x2f,0xb8145
    readseg((uchar*)elf, 4096, 0);
   7018a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
   70191:	00 
   70192:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
   70199:	00 
   7019a:	c7 04 24 00 00 08 00 	movl   $0x80000,(%esp)
   701a1:	e8 6c ff ff ff       	call   70112 <readseg>
   701a6:	eb fe                	jmp    701a6 <bootmain+0x4c>
   701a8:	90                   	nop
   701a9:	90                   	nop
   701aa:	90                   	nop
   701ab:	90                   	nop
   701ac:	90                   	nop
   701ad:	90                   	nop
   701ae:	90                   	nop
   701af:	90                   	nop

000701b0 <inb>:
   701b0:	55                   	push   %ebp
   701b1:	89 e5                	mov    %esp,%ebp
   701b3:	31 c0                	xor    %eax,%eax
   701b5:	66 8b 55 08          	mov    0x8(%ebp),%dx
   701b9:	ec                   	in     (%dx),%al
   701ba:	5d                   	pop    %ebp
   701bb:	89 ec                	mov    %ebp,%esp
   701bd:	c3                   	ret    

000701be <outb>:
   701be:	55                   	push   %ebp
   701bf:	89 e5                	mov    %esp,%ebp
   701c1:	31 c0                	xor    %eax,%eax
   701c3:	66 8b 55 08          	mov    0x8(%ebp),%dx
   701c7:	8a 45 0c             	mov    0xc(%ebp),%al
   701ca:	ee                   	out    %al,(%dx)
   701cb:	5d                   	pop    %ebp
   701cc:	89 ec                	mov    %ebp,%esp
   701ce:	c3                   	ret    

000701cf <insl>:
   701cf:	55                   	push   %ebp
   701d0:	89 e5                	mov    %esp,%ebp
   701d2:	31 c0                	xor    %eax,%eax
   701d4:	fc                   	cld    
   701d5:	66 8b 55 08          	mov    0x8(%ebp),%dx
   701d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
   701dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
   701df:	f3 6d                	rep insl (%dx),%es:(%edi)
   701e1:	5d                   	pop    %ebp
   701e2:	89 ec                	mov    %ebp,%esp
   701e4:	c3                   	ret    

000701e5 <stosb>:
   701e5:	55                   	push   %ebp
   701e6:	89 e5                	mov    %esp,%ebp
   701e8:	31 c0                	xor    %eax,%eax
   701ea:	8b 7d 08             	mov    0x8(%ebp),%edi
   701ed:	8a 45 0c             	mov    0xc(%ebp),%al
   701f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
   701f3:	fc                   	cld    
   701f4:	f3 aa                	rep stos %al,%es:(%edi)
   701f6:	89 ec                	mov    %ebp,%esp
   701f8:	5d                   	pop    %ebp
   701f9:	c3                   	ret    
