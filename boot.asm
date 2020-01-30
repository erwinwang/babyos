    org 0x7c00
[bits 16]
align 16
Entry:
	mov ax, cs
	mov ds, ax
	mov ss, ax
	mov sp, 0
	mov ax, 0xb800
	mov es, ax

;clean screan
CleanScreen:
	mov ax, 0x02
	int 0x10
    mov byte [es:0],'B'
	mov byte [es:1],0x07
	mov byte [es:2],'O'
	mov byte [es:3],0x07
	mov byte [es:4],'O'
	mov byte [es:5],0x07
	mov byte [es:6],'T'
	mov byte [es:7],0x07

    times 510-($-$$) db 0
    dw 0xaa55
