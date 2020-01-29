%define STA_X   0x8       // Executable segment
%define STA_W   0x2       // Writeable (non-executable segments)
%define STA_R   0x2       // Readable (executable segments)
bits 16
global start
start:
    cli

    xor     ax,ax
    mov     ds,ax
    mov     es,ax
    mov     ss,ax

seta20.1:
    in      al,0x64
    test    al,0x2
    jnz     seta20.1

    mov     al,0xd1
    out     0x64,al

seta20.2:
    in      al,0x64
    test    al,0x2
    jnz     seta20.2:

align 4
gdt:
seg_nullasm:
    dw 0, 0
    db 0, 0, 
    db 0, 0
seg_kcode:
    dw (0xffffffff >> 12) & 0xffff, 0x0 & 0xffff
    db (0x0 >> 16) & 0xff, 
    db 0x90 | STA_X | STA_R,
    db 0xc0 | ((0xffffffff >> 28) & 0xf), (0x0 >> 24) & 0xff
seg_kdata:
    dw (0xffffffff >> 12) & 0xffff, 0x0 & 0xffff
    db (0x0 >> 16) & 0xff, 0x90 | STA_W,
    db 0xc0 | ((0xffffffff >> 28)) & 0xf, (0x0 >> 24) & 0xff
