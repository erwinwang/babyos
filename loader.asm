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

KERNEL_PHY_ADDR equ 0x90000
org 0x900
[bits 16]
align 16
Entry:
	;初始化段和栈
	;由于从boot跳过来的时候用的jmp LOADER_SEG(0x7000):0
	;所以这个地方的cs是0x7000，其它的段也是这个值
	mov ax, cs
	mov ds, ax
	mov es,ax 
	mov ss, ax
	mov sp, 0x7c00

	
	mov ax, 0xb800
	mov es, ax
	;show 'LOADER'
	mov byte [es:160+0],'L'
	mov byte [es:160+1],0x07
	mov byte [es:160+2],'O'
	mov byte [es:160+3],0x07
	mov byte [es:160+4],'A'
	mov byte [es:160+5],0x07
	mov byte [es:160+6],'D'
	mov byte [es:160+7],0x07
	mov byte [es:160+8],'E'
	mov byte [es:160+9],0x07
	mov byte [es:160+10],'R'
	mov byte [es:160+11],0x07

	jmp $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; kernel.elf加载到0x90000处
load_kernel:
    mov ax,0x9000
    mov es,ax		; ex<-0x9000
    xor bx,bx		; bx<-0    es:bx = 0x9000*16 + 0
    mov ch,0x00		; 磁头0
    mov cl,0x04     ; 扇区04(CHS寻址方式 扇区编号从01开始)
retry:
    mov ah,0x02		; 读盘
    mov al,0x15     ; 15个扇区
    mov dh,0        ; head=0
    mov dl,0x80     ; hard_disk
    int 0x13
    jnc read_ok
reset:
    mov ah,0x00
    mov dl,0x80
    int 0x13
    jc  reset
    jmp retry

read_ok:
	; mov ax,0xb800
	; mov es,ax
	; mov byte [es:320+0],'O'
	; mov byte [es:320+1],0x07
	; mov byte [es:320+2],'K'
	; mov byte [es:320+3],0x07

pm_prepare:
    cli
seta20.1:
    in  al,0x64
    test al,0x02
    jnz seta20.1

    mov al,0xd1
    out 0x64,al

seta20.2:
    in al,0x64
    test al,0x02
    jnz seta20.2

    mov al,0xdf
    out 0x60,al

    lgdt [gdtptr]
setpe:
    mov eax,cr0
    or eax,0x1
    mov cr0,eax

pipe_line_flush:
    jmp dword 0x08:start32

[bits 32]
start32:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov gs,ax
    mov esp,190000

    ; mov eax,0xb8000 + 480
	; mov byte [es:eax+0],'P'
	; mov byte [es:eax+1],0x07
	; mov byte [es:eax+2],'M'
	; mov byte [es:eax+3],0x07

	;call setup_page
	; mov byte [0x800b8000+160*3+0], 'P'
	; mov byte [0x800b8000+160*3+1], 0X07
	; mov byte [0x800b8000+160*3+2], 'A'
	; mov byte [0x800b8000+160*3+3], 0X07
	; mov byte [0x800b8000+160*3+4], 'G'
	; mov byte [0x800b8000+160*3+5], 0X07
	; mov byte [0x800b8000+160*3+6], 'E'
	; mov byte [0x800b8000+160*3+7], 0X07
	;jmp $
    call read_kernel
	;jmp $
	jmp 0x08:0x100000

spin:
	hlt	
	jmp spin

align 16
; 遍历每一个 Program Header，根据 Program Header 中的信息来确定把什么放进内存，放到什么位置，以及放多少。
;把内核的代码段和数据段从elf文件中读取到1个对应的内存地址中
; kernel.elf 0x90000处
read_kernel:
	xor	esi, esi
	mov	cx, word [KERNEL_PHY_ADDR + 2Ch]; ┓ ecx <- pELFHdr->e_phnum
	movzx	ecx, cx					;
	mov	esi, [KERNEL_PHY_ADDR + 1Ch]	; esi <- pELFHdr->e_phoff
	add	esi, KERNEL_PHY_ADDR		; esi <- OffsetOfKernel + pELFHdr->e_phoff
.begin:
	mov	eax, [esi + 0]
	cmp	eax, 0				; PT_NULL
	jz	.noaction
	push	dword [esi + 010h]		; size
	mov	eax, [esi + 04h]	
	add	eax, KERNEL_PHY_ADDR	;	src
	push	eax				; 
	push	dword [esi + 08h]		;dst
	call	memcpy
	add	esp, 12	
.noaction:
	add	esi, 020h			; esi += pELFHdr->e_phentsize
	dec	ecx
	jnz	.begin
	ret

; memcpy(void *dst, void *src, int cnt)
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

	ret			; 函数结束，返回


;##############################################
;分页机制
;内核页目录表地址
PAGE_DIR_PHY_ADDR EQU   0x201000
;内核页表地址
PAGE_TBL_PHY_ADDR EQU   0x202000
;显存页表地址
VRAM_PT_PHY_ADDR    EQU 0x203000

PAGE_P_1	EQU  	1	; 0001 exist in memory
PAGE_P_0	EQU  	0	; 0000 not exist in memory
PAGE_RW_R  	EQU     0	; 0000 R/W read/execute
PAGE_RW_W  	EQU     2	; 0010 R/W read/write/execute
PAGE_US_S  	EQU     0	; 0000 U/S system level, cpl0,1,2
PAGE_US_U  	EQU     4	; 0100 U/S user level, cpl3

KERNEL_PAGE_ATTR    EQU (PAGE_US_S | PAGE_RW_W | PAGE_P_1)
setup_page:
	mov ecx,4096
	xor esi,esi
.clean_page_dir:
	mov byte [PAGE_DIR_PHY_ADDR + esi],0
	inc esi
	loop .clean_page_dir
.create_pde:
	mov eax,PAGE_DIR_PHY_ADDR
	add eax,0x1000
	mov ebx,eax

.fin:
	ret
;################################################

align 16
gdt_head:
    dd 0x0000000
    dd 0x0000000

    dw 0x000ffff    ;段限制：0-15位
    dw 0x0000000    ;段基地址：0-15位
    db 0x0000000    ;段基地址：16-23位
    db 10011010b    ;段描述符的第6字节属性（代码段可读写）
    db 11001111b    ;段描述符的第7字节属性：16-19位
    db 0x0000000    ;段描述符的最后一个字节是段基地址的第二部分：24-31位

    dw 0x000ffff    ;段限制：0-15位
    dw 0x0000000    ;段基地址：0-15位
    db 0x0000000    ;段基地址：16-23位
    db 10010010b    ;段描述符的第6字节属性（数据段可读写）
    db 11001111b    ;段描述符的第7字节属性：limit（位16-19）
    db 0x0000000    ;段描述符的最后一个字节是段基地址的第二部分：24-31位2

VIDEO_DESC: dd    0x80000007	       ; limit=(0xbffff-0xb8000)/4k=0x7
	        dd    DESC_VIDEO_HIGH4  ; 此时dpl为0

SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0	 ; 同上
gdtptr:
    dw gdtptr - gdt_head - 1
    dd gdt_head

    times 1024 - ($ - $$) db 0