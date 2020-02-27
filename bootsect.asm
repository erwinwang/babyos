org 0x7c00
[bits 16]
start:
    cli

    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00

; clear the screen
clear_screen:  
    mov ah,0x00
    mov al,0x02
    int 0x10

; load_loader:
;     mov ax,0x7000
;     mov es,ax
;     xor bx,bx
;     mov ch,0x00
;     mov cl,0x02     ; 扇区02(CHS寻址方式 扇区编号从01开始)
; retry:
;     mov ah,0x02
;     mov al,0x8     ; 8个扇区/4k
;     mov dh,0        ; head=0
;     mov dl,0x80     ; hard_disk
;     int 0x13
;     jnc read_ok
; reset:
;     mov ah,0x00
;     mov dl,0x80
;     int 0x13
;     jc  reset
;     jmp retry

; read_ok:
    mov ax,0x7000
    mov cx,2
    mov si,1
    call LoadBlock
    jmp 0x7000:0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;si=LBA address, from 0
;cx=sectors
;es:dx=buffer address	
;this function was borrowed from internet
ReadSectors:
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
	;xor dl, dl ;dl=0 软盘
	mov dl,0x80
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
	call ReadSectors
	add bx, 512
	inc si 
	loop .loop
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    times 510 - ($ - $$) db 0
    db 0x55,0xaa