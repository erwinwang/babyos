; boot.asm
; A minimal bootstrap

BOOTSEG     equ     0x07c0
INITSEG     equ     0x9000
SETUPLEN    equ          4

    org 0x0000

start:
    mov ax, BOOTSEG
    mov ds, ax
    mov ax, INITSEG
    mov es, ax
    mov cx, 256
    sub si, si
    sub di, di
    rep movsw
    jmp INITSEG:go


go:
    mov ax, cs
    mov ds, ax
    mov es, ax
    ; put statck at 0x9ff00
    mov ss, ax
    mov sp, 0xFF00

load_setup:
    mov dx, 0x0000
    mov cx, 0x0002
    mov bx, 0x0200
    mov ax, 0x0200 + SETUPLEN
    int 0x13
    jnc ok_load_setup
    mov dx, 0x0000
    mov ax, 0x0000
    int 0x13
    jmp load_setup

ok_load_setup:



hang:
    hlt
    jmp hang

    times 510 - ( $ - $$ ) db 0
boot_flag:
    dw  0xAA55