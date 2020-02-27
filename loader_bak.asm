    
TI_GDT	 equ   000b
RPL0  equ   00b
;--------------   gdt描述符属性  -----------
DESC_G_4K   equ	  1_00000000000000000000000b   
DESC_D_32   equ	   1_0000000000000000000000b
DESC_L	    equ	    0_000000000000000000000b	;  64位代码标记，此处标记为0便可。
DESC_AVL    equ	     0_00000000000000000000b	;  cpu不用此位，暂置为0  
DESC_LIMIT_CODE2  equ 1111_0000000000000000b
DESC_LIMIT_DATA2  equ DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2  equ 0000_000000000000000b
DESC_P	    equ		  1_000000000000000b
DESC_DPL_0  equ		   00_0000000000000b
DESC_DPL_1  equ		   01_0000000000000b
DESC_DPL_2  equ		   10_0000000000000b
DESC_DPL_3  equ		   11_0000000000000b
DESC_S_CODE equ		     1_000000000000b
DESC_S_DATA equ	  DESC_S_CODE
DESC_S_sys  equ		     0_000000000000b
DESC_TYPE_CODE  equ	      1000_00000000b	;x=1,c=0,r=0,a=0 代码段是可执行的,非依从的,不可读的,已访问位a清0.  
DESC_TYPE_DATA  equ	      0010_00000000b	;x=0,e=0,w=1,a=0 数据段是不可执行的,向上扩展的,可写的,已访问位a清0.

DESC_CODE_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00
DESC_DATA_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00
DESC_VIDEO_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b


;---loader const----
;we read kernel.elf from disk sector 10 
KERNEL_OFF EQU 10	

;----we assume that kernel max is 256 kb (0x40000 byte)----

;we read kernel.elf to memory 0x10000
;so the segment is 0x1000, we are in real mode now.
KERNEL_SEG EQU 0x8000

;kernel.elf phy addr is KERNEL_SEG*16, 
;0x1000*16 = 0x10000
;KERNEL_PHY_ADDR EQU KERNEL_SEG*16
KERNEL_PHY_ADDR EQU 0x80000

;we can read sector less than 128 sector. so I set block size,
;every time we load 128 sectors
BLOCK_SIZE EQU 128

FILE_OFF EQU 600

FILE_SEG EQU 0x5000

    org 0x70000
[bits 16]
    jmp entry
 
entry:
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00



    mov ax,0xb800
    mov es,ax
    mov di,0
    mov byte [es:di + 0],'L'
    mov byte [es:di + 1],0xcf
    mov byte [es:di + 2],'o'
    mov byte [es:di + 3],0xcf
    mov byte [es:di + 4],'a'
    mov byte [es:di + 5],0xcf
    mov byte [es:di + 6],'d'
    mov byte [es:di + 7],0xcf
    mov byte [es:di + 8],'i'
    mov byte [es:di + 9],0xcf
    mov byte [es:di + 0x0a],'n'
    mov byte [es:di + 0x0b],0xcf
    mov byte [es:di + 0x0c],'g'
    mov byte [es:di + 0x0d],0xcf

    ; call LoadKernel
    ; call LoadFile

    

; ; read_sect(buf[es:bx],)
; read_sect:
;     mov dx,0x80     ; 硬盘主盘
;     mov cl,0x02     ;
;     mov ch,0x00
;     mov ax,0x7000
;     mov es,ax
;     xor bx,bx
;     mov ah,0x02
;     mov al,0x10
;     int 0x13

;     jnc read_success
;     jmp read_sect

;si=LBA address, from 0
;cx=sectors
;es:dx=buffer address	
;this function was borrowed from internet
ReadOneSect:
	push ax 
	push cx 
	push dx 
	push bx 
	
	mov ax, si 
	xor dx, dx 
	mov bx, 18
	
	div bx 
	inc dx 
	mov cl, dl 
	xor dx, dx 
	mov bx, 2
	
	div bx 
	
	mov dh, dl
	xor dl, dl 
	mov ch, al 
	pop bx 
.RP:
	mov al, 0x01
	mov ah, 0x02 
	int 0x13 
	jc .RP 
	pop dx
	pop cx 
	pop ax
	ret

;ax = 写入的段偏移
;si = 扇区LBA地址
;cx = 扇区数
LoadBlock:
	mov es, ax
	xor bx, bx 
.loop:
	call ReadOneSect
	add bx, 512
	inc si 
	loop .loop
	ret

;在这个地方把elf格式的内核加载到一个内存，elf文件不能从头执行，
;必须把它的代码和数据部分解析出来，这个操作是进入保护模式之后进行的
LoadKernel:
	;loade kernel
	;first block 128 sectors
	;把内核文件加载到段为KERNEL_SEG（0x1000）的地方，也就是物理内存
	;为0x10000的地方，一次性加载BLOCK_SIZE（128）个扇区
	;写入参数
	mov ax, KERNEL_SEG
	mov si, KERNEL_OFF
	mov cx, BLOCK_SIZE
	;调用读取一整个块的扇区数据函数，其实也就是循环读取128个扇区，只是
	;把它做成函数，方便调用
	call LoadBlock
	
	;second block 128 sectors
	;当读取完128个扇区后，我们的缓冲区位置要改变，也就是增加128*512=0x10000
	;的空间，由于ax会给es，所以这个地方用改变段的位置，所以就是0x1000,
	;扇区的位置是保留在si中的，上一次调用后，si递增了128，所以这里我们不对
	;si操作
	add ax, 0x1000
	mov cx, BLOCK_SIZE
	call LoadBlock
	
	;third block 128 sectors
	;这个地方和上面同理
	add ax, 0x1000
	mov cx, BLOCK_SIZE
	call LoadBlock
    
    ;fourth block 128 sectors
	;这个地方和上面同理
	add ax, 0x1000
	mov cx, BLOCK_SIZE
	call LoadBlock
    
	ret

;在这个地方把file加载到一个内存
LoadFile:
	;loade file
	;first block 128 sectors
	;把内核文件加载到段为FILE_SEG（0x4200）的地方，也就是物理内存
	;为0x42000的地方，一次性加载BLOCK_SIZE（128）个扇区
	;写入参数
	mov ax, FILE_SEG
	mov si, FILE_OFF
	mov cx, 128
	;调用读取一整个块的扇区数据函数，其实也就是循环读取128个扇区，只是
	;把它做成函数，方便调用
	call LoadBlock
	
	;second block 128 sectors
	;当读取完128个扇区后，我们的缓冲区位置要改变，也就是增加128*512=0x10000
	;的空间，由于ax会给es，所以这个地方用改变段的位置，所以就是0x1000,
	;扇区的位置是保留在si中的，上一次调用后，si递增了128，所以这里我们不对
	;si操作
	add ax, 0x1000
	mov cx, BLOCK_SIZE
	call LoadBlock
	
	ret

align 16
[bits 32]
start32:
    xor eax,eax
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov gs,ax
    mov esp,0x7c00

    mov dword [0xb8000 + 160 + 0], 'P'
    mov dword [0xb8000 + 160 + 1], 0x2f
    mov dword [0xb8000 + 160 + 2], 'M'
    mov dword [0xb8000 + 160 + 3], 0x2f

    ;jmp $
    ; call ReadKernel
    ; jmp $

; load_kernel:
;     mov edx,0
;     mov dx,0x1f2
;     mov al,0x01     ; 1 sectors:kernel.bin
;     out dx,al

; LBA28:
;     mov dx,0x1f3
;     mov al,0x09     ; 9st sector(start from 0st)
;     out dx,al       ; LBA:0~7 bit

;     mov dx,0x1f4
;     mov al,0x00
;     out dx,al

;     mov dx,0x1f5
;     out dx,al

;     mov al,0x1f6
;     mov al,0xe0
;     out dx,al

; read_hd:
;     mov dx,0x1f7
;     mov al,0x20
;     out dx,al

;     mov dx,0x1f7
; waits:
;     in  al,dx
;     and al,0x88
;     cmp al,0x08
;     jnz waits

;     mov cx,512
;     mov dx,0x1f0
;     mov ebx,0x100000
; readw:
;     in ax,dx
;     mov word [ebx],ax
;     add ebx,2
;     loop readw

    ;jmp $
    mov ecx,1024   ; 4k / 4
    cld
    mov esi,0x71000
    mov edi,0x100000
    rep movsd

jmp_to_kernel:
    jmp 0x08:0x100000

spin:
    hlt
    jmp spin

; 遍历每一个 Program Header，根据 Program Header 中的信息来确定把什么放进内存，放到什么位置，以及放多少。
;把内核的代码段和数据段从elf文件中读取到1个对应的内存地址中
ReadKernel:
	xor	esi, esi
	mov	cx, word [KERNEL_PHY_ADDR + 2Ch]; ┓ ecx <- pELFHdr->e_phnum
	movzx	ecx, cx					;
	mov	esi, [KERNEL_PHY_ADDR + 1Ch]	; esi <- pELFHdr->e_phoff
	add	esi, KERNEL_PHY_ADDR		; esi <- OffsetOfKernel + pELFHdr->e_phoff
.begin:
	mov	eax, [esi + 0]
	cmp	eax, 0				; PT_NULL
	jz	.unaction
	push	dword [esi + 010h]		; size
	mov	eax, [esi + 04h]	
	add	eax, KERNEL_PHY_ADDR	;	memcpy(	(void*)(pPHdr->p_vaddr),
	push	eax				; src uchCode + pPHdr->p_offset,
	push	dword [esi + 08h]		; dst	pPHdr->p_filesz;
	call	memcpy
	add	esp, 12	
.unaction:
	add	esi, 020h			; esi += pELFHdr->e_phentsize
	dec	ecx
	jnz	.begin
	ret

; memcpy(dst,src,size)
memcpy:
	push	ebp
	mov	ebp, esp

	push	esi
	push	edi
	push	ecx

	mov	edi, [ebp + 8]	; Destination
	mov	esi, [ebp + 12]	; Source
	mov	ecx, [ebp + 16]	; Counter
.1:
	cmp	ecx, 0		; 判断计数器
	jz	.2		; 计数器为零时跳出

	mov	al, [ds:esi]
	inc	esi			
					
	mov	byte [es:edi], al
	inc	edi

	dec	ecx		; 计数器减一
	jmp	.1		; 循环
.2:
	mov	eax, [ebp + 8]	; 返回值

	pop	ecx
	pop	edi
	pop	esi
	mov	esp, ebp
	pop	ebp

	ret

    times 4096 - ($ - $$) db 0


