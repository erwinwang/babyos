    bits 16
    org 0x0000

    %define DEF_ORG_START   0x7c0
    %define DEF_BOOT_START  0x9ec0

start:
    cli

    mov ax, DEF_ORG_START
    mov ds, ax
    mov ss, ax
    mov sp,0xfff0
    cld

    mov si, 0x0
    mov ax, DEF_BOOT_START
    mov es, ax
    mov di, 0x0
    mov cx, 0x200
    rep movsb

    mov ax, DEF_BOOT_START
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xffe
    jmp DEF_BOOT_START:start2

start2:
    mov byte [device_index], dl
    call printmsg
    jmp $

printmsg:
    mov ah, 0x3
    mov bh, 0x0
    int 0x10
    mov cx, [msg_len]
    mov bx, 0x07
    mov bp, msg
    mov ah, 0x13
    mov al, 0x01
    int 0x10
    ret

data:
    msg db 'boot phase'
    msg_len db $ - msg
    device_index db 0

; 入口参数：
; AH=02H 指明调用读扇区功能。
; AL 置要读的扇区数目，不允许使用读磁道末端以外的数值，也不允许使该寄存器为0。
; CH 磁道号的低8位数。
; CL 低5位放入所读起始扇区号，位7-6表示磁道号的高2位。cl=开始扇区（位0—5），磁道号高二位（位6—7）
; DL 需要进行读操作的驱动器号。dl=驱动器号（若是硬盘则要置位7）
; DH 所读磁盘的磁头号。dh=磁头号
; es:bx—>指向数据缓冲区   ES:BX 读出数据的缓冲区地址。
; 出口参数:
; 如果CF=1，AX中存放出错状态。读出后的数据在ES:BX区域依次排列
; void read_sect(void* buf)
read_sect:
    mov ah, 0x2
    mov al, 1
    int 0x13
    ret

    times 510-($-$$) db 0
    dw 0xaa55
