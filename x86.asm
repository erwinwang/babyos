[bits 32]
global inb
; inb(word port)
inb:
    push ebp
    mov ebp,esp

    xor eax,eax
    mov dx,[ebp + 0x08] ;port
    in al,dx

    pop ebp
    mov esp,ebp
    ret

global outb
; void outb(word port, uchar data)
outb:
    push ebp
    mov ebp,esp

    xor eax,eax
    mov dx,[ebp + 0x08] ;port
    mov al,[ebp + 0x0c] ;data
    out dx,al

    pop ebp
    mov esp,ebp
    ret

global insl
; void insl(unsigned short int port, void *addr, unsigned long int count)
insl:
    push ebp
    mov ebp,esp

    xor eax,eax
    cld
    mov dx,[ebp + 0x08] ;port
    mov edi,[ebp + 0x0c] ;dst
    mov ecx,[ebp + 0x10] ;count
    rep insd

    pop ebp
    mov esp,ebp
    ret

global stosb
; void stosb(void *addr, int data, int cnt)
stosb:
    push ebp
    mov ebp,esp

    xor eax,eax
    mov edi,[ebp + 0x08]    ;addr
    mov al,[ebp + 0x0c]     ;data
    mov ecx,[ebp + 0x10]    ;cnt
    cld
    rep stosb

    mov esp,ebp
    pop ebp
    ret