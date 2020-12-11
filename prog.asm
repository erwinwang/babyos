; prog.asm
;

    org 0x0000

    jmp start2

msg     db 'Program Loaded Succeed! Hello, myos!', $0

start2:
    mov ax, cs
    mov ds, ax
    mov es, ax
    
    call clean_screen

    mov si, msg
print:
    lodsb
    cmp al, 0
    je hang


    mov ah,0Eh
    mov bx,7
    int 10h

    jmp print

hang:
    hlt
    jmp hang

;clean screan
clean_screen:
	mov ax, 0x02
	int 0x10
    ret

    times 510 - ( $ - $$ ) db 0
    dw 0xAA55