[bits 32]
[section .text]
extern main
global start
start:
    xor eax,eax
    mov ax,0x10
    mov ds,ax
    mov es,ax                  
    mov ss,ax
    mov fs,ax
    mov gs,ax
    mov esp,0x7c00

    mov byte [0xb8000 + 640 + 0], 'h'
    mov byte [0xb8000 + 640 + 1], 0x2f
    mov byte [0xb8000 + 640 + 2], 'e'
    mov byte [0xb8000 + 640 + 3], 0x2f
    mov byte [0xb8000 + 640 + 4], 'a'
    mov byte [0xb8000 + 640 + 5], 0x2f
    mov byte [0xb8000 + 640 + 6], 'd'
    mov byte [0xb8000 + 640 + 7], 0x2f

    ;jmp $
    call main
spin:
    hlt
    jmp spin