%include "boot.inc"

org 0x900
[bits 16]
loader_start:
    ; 初始化段和栈
    ; 由于从boot跳过来的时候用的jmp LOADER_SEG(0x7000):0
    ; 所以这个地方的cs是0x7000，其它的段也是这个值
    mov ax, 0
    mov ds, ax
    mov es,ax
    mov ss, ax
    mov sp, 0x7c00


    mov ax, 0xb800
    mov es, ax
    ; show 'LOADER'
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

    ;jmp $

    ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; ; kernel.elf加载到0x90000处
    ; load_kernel:
    ; mov ax,0x9000
    ; mov es,ax		; ex<-0x9000
    ; xor bx,bx		; bx<-0    es:bx = 0x9000*16 + 0
    ; mov ch,0x00		; 磁头0
    ; mov cl,0x04     ; 扇区04(CHS寻址方式 扇区编号从01开始)
    ; retry:
    ; mov ah,0x02		; 读盘
    ; mov al,0x15     ; 15个扇区
    ; mov dh,0        ; head=0
    ; mov dl,0x80     ; hard_disk
    ; int 0x13
    ; jnc read_ok
    ; reset:
    ; mov ah,0x00
    ; mov dl,0x80
    ; int 0x13
    ; jc  reset
    ; jmp retry

    ; read_ok:
    ; ; mov ax,0xb800
    ; ; mov es,ax
    ; ; mov byte [es:320+0],'O'
    ; ; mov byte [es:320+1],0x07
    ; ; mov byte [es:320+2],'K'
    ; ; mov byte [es:320+3],0x07

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

    lgdt [gdt_ptr]
setpe:
    mov eax,cr0
    or eax,0x1
    mov cr0,eax

pipe_line_flush:
    jmp dword 0x08:start32

error:
    hlt
    jmp error

[bits 32]
start32:
    mov ax, SELECTOR_DATA
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov esp,LOADER_STACK_TOP
   mov ax, SELECTOR_VIDEO
   mov gs, ax

   ; -------------------------   加载kernel  ----------------------
   mov eax, KERNEL_START_SECTOR                        ; kernel.bin所在的扇区号
   mov ebx, KERNEL_BIN_BASE_ADDR                       ; 从磁盘读出后，写入到ebx指定的地址
   mov ecx, 200    
   ;jmp $                                    ; 读入的扇区数

   call rd_disk_m_32

;    ; 创建页目录及页表并初始化页内存位图
;    call setup_page

;    ; 要将描述符表地址及偏移量写入内存gdt_ptr,一会用新地址重新加载
;    sgdt [gdt_ptr]                                      ; 存储到原来gdt所有的位置

;                                                        ; 将gdt描述符中视频段描述符中的段基址+0xc0000000
;    mov ebx, [gdt_ptr + 2]
;    or dword [ebx + 0x18 + 4], 0xc0000000               ; 视频段是第3个段描述符,每个描述符是8字节,故0x18。
;                                                        ; 段描述符的高4字节的最高位是段基址的31~24位

;                                                        ; 将gdt的基址加上0xc0000000使其成为内核所在的高地址
;    add dword [gdt_ptr + 2], 0xc0000000

;    add esp, 0xc0000000                                 ; 将栈指针同样映射到内核地址

;                                                        ; 把页目录地址赋给cr3
;    mov eax, PAGE_DIR_TABLE_POS
;    mov cr3, eax

;    ; 打开cr0的pg位(第31位)
;    mov eax, cr0
;    or eax, 0x80000000
;    mov cr0, eax

;    ; 在开启分页后,用gdt新的地址重新加载
;    lgdt [gdt_ptr]                                      ; 重新加载

;                                                        ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;  此时不刷新流水线也没问题  ;;;;;;;;;;;;;;;;;;;;;;;;
;                                                        ; 由于一直处在32位下,原则上不需要强制刷新,经过实际测试没有以下这两句也没问题.
;                                                        ; 但以防万一，还是加上啦，免得将来出来莫句奇妙的问题.
    jmp SELECTOR_CODE:enter_kernel                      ; 强制刷新流水线,更新gdt
enter_kernel:
   ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   call kernel_init
   ;mov esp, 0xc009f000
   jmp KERNEL_ENTRY_POINT                              ; 用地址0x1500访问测试，结果ok
   

spin:
    hlt
    jmp spin

    ; 遍历每一个 Program Header，根据 Program Header 中的信息来确定把什么放进内存，放到什么位置，以及放多少。
    ; 把内核的代码段和数据段从elf文件中读取到1个对应的内存地址中
    ; kernel.elf 0x70000处
KERNEL_PHY_ADDR equ 0x70000
kernel_init:
    xor	esi, esi
    mov	cx, word [KERNEL_PHY_ADDR + 2Ch]               ; ┓ ecx <- pELFHdr->e_phnum
    movzx	ecx, cx
    mov	esi, [KERNEL_PHY_ADDR + 1Ch]                   ; esi <- pELFHdr->e_phoff
    add	esi, KERNEL_PHY_ADDR                           ; esi <- OffsetOfKernel + pELFHdr->e_phoff
.begin:
    mov	eax, [esi + 0]
    cmp	eax, 0                                         ; PT_NULL
    jz	.noaction
    push	dword [esi + 010h]                            ; size
    mov	eax, [esi + 04h]
    add	eax, KERNEL_PHY_ADDR                           ; src
    push	eax
    push	dword [esi + 08h]                             ; dst
    call	memcpy
    add	esp, 12
.noaction:
    add	esi, 020h                                      ; esi += pELFHdr->e_phentsize
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

    mov	edi, [ebp + 8]                                 ; Destination
    mov	esi, [ebp + 12]                                ; Source
    mov	ecx, [ebp + 16]                                ; Counter
.1:
    cmp	ecx, 0                                         ; 判断计数器
    jz	.2                                              ; 计数器为零时跳出

    mov	al, [ds:esi]
    inc	esi

    mov	byte [es:edi], al
    inc	edi

    dec	ecx                                            ; 计数器减一
    jmp	.1                                             ; 循环
.2:
    mov	eax, [ebp + 8]                                 ; 返回值

    pop	ecx
    pop	edi
    pop	esi
    mov	esp, ebp
    pop	ebp

    ret                                                ; 函数结束，返回


                                                       ; -------------------------------------------------------------------------------
                                                       ; 功能:读取硬盘n个扇区
rd_disk_m_32:
      ; -------------------------------------------------------------------------------
      ; eax=LBA扇区号
      ; ebx=将数据写入的内存地址
      ; ecx=读入的扇区数
      mov esi,eax                                      ; 备份eax
      mov di,cx                                        ; 备份扇区数到di
                                                       ; 读写硬盘:
                                                       ; 第1步：设置要读取的扇区数
      mov dx,0x1f2
      mov al,cl
      out dx,al                                        ; 读取的扇区数

      mov eax,esi                                      ; 恢复ax

                                                       ; 第2步：将LBA地址存入0x1f3 ~ 0x1f6

                                                       ; LBA地址7~0位写入端口0x1f3
      mov dx,0x1f3
      out dx,al

      ; LBA地址15~8位写入端口0x1f4
      mov cl,8
      shr eax,cl
      mov dx,0x1f4
      out dx,al

      ; LBA地址23~16位写入端口0x1f5
      shr eax,cl
      mov dx,0x1f5
      out dx,al

      shr eax,cl
      and al,0x0f                                      ; lba第24~27位
      or al,0xe0                                       ; 设置7～4位为1110,表示lba模式
      mov dx,0x1f6
      out dx,al

      ; 第3步：向0x1f7端口写入读命令，0x20
      mov dx,0x1f7
      mov al,0x20
      out dx,al

      ; ;;;;;; 至此,硬盘控制器便从指定的lba地址(eax)处,读出连续的cx个扇区,下面检查硬盘状态,不忙就能把这cx个扇区的数据读出来

      ; 第4步：检测硬盘状态
  .not_ready:                                          ; 测试0x1f7端口(status寄存器)的的BSY位
                                                       ; 同一端口,写时表示写入命令字,读时表示读入硬盘状态
      nop
      in al,dx
      and al,0x88                                      ; 第4位为1表示硬盘控制器已准备好数据传输,第7位为1表示硬盘忙
      cmp al,0x08
      jnz .not_ready                                   ; 若未准备好,继续等。

                                                       ; 第5步：从0x1f0端口读数据
      mov ax, di                                       ; 以下从硬盘端口读数据用insw指令更快捷,不过尽可能多的演示命令使用,
                                                       ; 在此先用这种方法,在后面内容会用到insw和outsw等

      mov dx, 256                                      ; di为要读取的扇区数,一个扇区有512字节,每次读入一个字,共需di*512/2次,所以di*256
      mul dx
      mov cx, ax
      mov dx, 0x1f0
  .go_on_read:
      in ax,dx
      mov [ebx], ax
      add ebx, 2
      ; 由于在实模式下偏移地址为16位,所以用bx只会访问到0~FFFFh的偏移。
      ; loader的栈指针为0x900,bx为指向的数据输出缓冲区,且为16位，
      ; 超过0xffff后,bx部分会从0开始,所以当要读取的扇区数过大,待写入的地址超过bx的范围时，
      ; 从硬盘上读出的数据会把0x0000~0xffff的覆盖，
      ; 造成栈被破坏,所以ret返回时,返回地址被破坏了,已经不是之前正确的地址,
      ; 故程序出会错,不知道会跑到哪里去。
      ; 所以改为ebx代替bx指向缓冲区,这样生成的机器码前面会有0x66和0x67来反转。
      ; 0X66用于反转默认的操作数大小! 0X67用于反转默认的寻址方式.
      ; cpu处于16位模式时,会理所当然的认为操作数和寻址都是16位,处于32位模式时,
      ; 也会认为要执行的指令是32位.
      ; 当我们在其中任意模式下用了另外模式的寻址方式或操作数大小(姑且认为16位模式用16位字节操作数，
      ; 32位模式下用32字节的操作数)时,编译器会在指令前帮我们加上0x66或0x67，
      ; 临时改变当前cpu模式到另外的模式下.
      ; 假设当前运行在16位模式,遇到0X66时,操作数大小变为32位.
      ; 假设当前运行在32位模式,遇到0X66时,操作数大小变为16位.
      ; 假设当前运行在16位模式,遇到0X67时,寻址方式变为32位寻址
      ; 假设当前运行在32位模式,遇到0X67时,寻址方式变为16位寻址.

      loop .go_on_read
      ret
      ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ; ##############################################
      ; 分页机制
      ; 内核页目录表地址
PAGE_DIR_PHY_ADDR EQU   0x201000
; 内核页表地址
PAGE_TBL_PHY_ADDR EQU   0x202000
; 显存页表地址
VRAM_PT_PHY_ADDR    EQU 0x203000

PAGE_P_1	EQU  	1                                       ; 0001 exist in memory
PAGE_P_0	EQU  	0                                       ; 0000 not exist in memory
PAGE_RW_R  	EQU     0                                  ; 0000 R/W read/execute
PAGE_RW_W  	EQU     2                                  ; 0010 R/W read/write/execute
PAGE_US_S  	EQU     0                                  ; 0000 U/S system level, cpl0,1,2
PAGE_US_U  	EQU     4                                  ; 0100 U/S user level, cpl3

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
    ; ################################################

align 16
GDT_BASE:   dd    0x00000000
           dd    0x00000000

   CODE_DESC:  dd    0x0000FFFF
           dd    DESC_CODE_HIGH4

   DATA_STACK_DESC:  dd    0x0000FFFF
             dd    DESC_DATA_HIGH4

   VIDEO_DESC: dd    0x80000007                        ; limit=(0xbffff-0xb8000)/4k=0x7
           dd    DESC_VIDEO_HIGH4                      ; 此时dpl为0

   GDT_SIZE   equ   $ - GDT_BASE
   GDT_LIMIT   equ   GDT_SIZE -	1
   times 60 dq 0                                       ; 此处预留60个描述符的空位(slot)
   SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0       ; 相当于(CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0
   SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0       ; 同上
   SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0      ; 同上

                                                       ; total_mem_bytes用于保存内存容量,以字节为单位,此位置比较好记。
                                                       ; 当前偏移loader.bin文件头0x200字节,loader.bin的加载地址是0x900,
                                                       ; 故total_mem_bytes内存中的地址是0xb00.将来在内核中咱们会引用此地址
   total_mem_bytes dd 0
   ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ; 以下是定义gdt的指针，前2字节是gdt界限，后4字节是gdt起始地址
   gdt_ptr  dw  GDT_LIMIT
        dd  GDT_BASE

        ; 人工对齐:total_mem_bytes4字节+gdt_ptr6字节+ards_buf244字节+ards_nr2,共256字节
   ards_buf times 244 db 0
   ards_nr dw 0                                        ; 用于记录ards结构体数量

    times 4096 - ($ - $$) db 0