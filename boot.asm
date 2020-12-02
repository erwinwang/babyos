%include "const.inc"
%include "config.inc"

org 0x7c00
[bits 16]
align 16

start:
    cli

    xor ax,ax
	mov ds,ax
	mov ss, ax
	mov sp, 0x7c00
	mov ax, 0xb800
	mov es, ax

    call clean_screen

	;show 'BOOT'
	mov byte [es:0],'B'
	mov byte [es:1],0x07
	mov byte [es:2],'O'
	mov byte [es:3],0x07
	mov byte [es:4],'O'
	mov byte [es:5],0x07
	mov byte [es:6],'T'
	mov byte [es:7],0x07

seta20.1:
    in al,0x64
    test al,0x2
    jnz seta20.1

    mov al,0xd1
    out 0x64,al

seta20.2:
    in al,0x64
    test al,0x2
    jnz seta20.2

    mov al,0xdf
    out 0x60,al

    ; Switch from real to protected mode.  Use a bootstrap GDT that makes
    ; virtual addresses map directly to physical addresses so that the
    ; effective memory map doesn't change during the transition.
    lgdt [gdtdesc]
    ;set CR0 bit PE
	mov eax,cr0
	or  eax,1
	mov cr0,eax

    ; # Complete the transition to 32-bit protected mode by using a long jmp
    ; # to reload %cs and %eip.  The segment descriptors are set up with no
    ; # translation, so that the mapping is still the identity mapping.
    jmp dword 0x08:start32

;clean screan
clean_screen:
	mov ax, 0x02
	int 0x10
    ret

;boot phase Global Descriptor Table(GDT)
gdt_table:
	dd		0x00000000
	dd		0x00000000
	dd		0x0000ffff
	dd		0x00cf9A00
	dd		0x0000ffff
	dd		0x00cf9200
	
gdt_length equ $ - gdt_table	
gdtdesc:
	dw	(gdt_length-1)
	dd	gdt_table

[bits 32]
align 32
start32:
;   # Set up the protected-mode data segment registers
;   movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
;   movw    %ax, %ds                # -> DS: Data Segment
;   movw    %ax, %es                # -> ES: Extra Segment
;   movw    %ax, %ss                # -> SS: Stack Segment
;   movw    $0, %ax                 # Zero segments not ready for use
;   movw    %ax, %fs                # -> FS
;   movw    %ax, %gs                # -> GS

	mov ax, 0x10	;the data selector
	mov ds, ax 
	mov es, ax
    mov ss, ax
    mov ax, 0 
	mov fs, ax 
	mov gs, ax 

	mov esp, start
    ; call    bootmain
    
    ;show 'LOADER'
    mov eax, 0xb8000
    add eax, 160
	mov byte [eax+0],'L'
	mov byte [eax+1],0x07
	mov byte [eax+2],'O'
	mov byte [eax+3],0x07
	mov byte [eax+4],'A'
	mov byte [eax+5],0x07
	mov byte [eax+6],'D'
	mov byte [eax+7],0x07
	mov byte [eax+8],'E'
	mov byte [eax+9],0x07
	mov byte [eax+10],'R'
	mov byte [eax+11],0x07

spin:
    hlt
    jmp spin

   
; %ifdef CONFIG_BOOT_FLOPPY
; ; function: read a sector data from floppy
; ; @input:
; ;       es: dx -> buffer seg: off
; ;       si     -> lba
; floppy_read_sector:
; 	push ax 
; 	push cx 
; 	push dx 
; 	push bx 
	
; 	mov ax, si 
; 	xor dx, dx 
; 	mov bx, 18
	
; 	div bx 
; 	inc dx 
; 	mov cl, dl 
; 	xor dx, dx 
; 	mov bx, 2
	
; 	div bx 
	
; 	mov dh, dl
; 	xor dl, dl 
; 	mov ch, al 
; 	pop bx 
; .1:
; 	mov al, 0x01
; 	mov ah, 0x02 
; 	int 0x13 
; 	jc .1 
; 	pop dx
; 	pop cx 
; 	pop ax
; 	ret
; %endif

; %ifdef CONFIG_BOOT_HARDDISK
; align 4
; DAP:    ; disk address packet
;     db 0x10 ; [0]: packet size in bytes
;     db 0    ; [1]: reserved, must be 0
;     db 0    ; [2]: nr of blocks to transfer (0~127)
;     db 0    ; [3]: reserved, must be 0
;     dw 0    ; [4]: buf addr(offset)
;     dw 0    ; [6]: buf addr(seg)
;     dd 0    ; [8]: lba. low 32-bit
;     dd 0    ; [12]: lba. high 32-bit

; ; function: read a sector data from harddisk
; ; @input:
; ;       ax: dx  -> buffer seg: off
; ;       si     -> lba low 32 bits
; harddisk_read_sector:
;     push ax
;     push bx
;     push cx
;     push dx
;     push si

;     mov word [DAP + 2], 1       ; count
;     mov word [DAP + 4], dx      ; offset
;     mov word [DAP + 6], ax      ; segment
;     mov word [DAP + 8], si      ; lba low 32 bits
;     mov dword [DAP + 12], 0     ; lba high 32 bits
    
;     xor bx, bx
;     mov ah, 0x42
;     mov dl, 0x80
;     mov si, DAP
;     int 0x13
    
;     pop si
;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     ret
; %endif

; read_sectors:
;     push ax
;     push bx
;     push cx
;     push dx
;     push si
;     push di
;     push es

; .reply:
;     %ifdef CONFIG_BOOT_HARDDISK
;     call harddisk_read_sector
;     add ax, 0x20    ; next buffer
;     %endif
    
;     %ifdef CONFIG_BOOT_FLOPPY
;     mov es, ax
;     call floppy_read_sector
;     add bx, 512     ; next buffer
;     %endif

;     inc si          ; next lba
;     loop .reply

;     pop es
;     pop di
;     pop si
;     pop dx
;     pop cx
;     pop bx
;     pop ax
;     ret

times 510-($-$$) db 0
dw 0xaa55   ; boot sector flags