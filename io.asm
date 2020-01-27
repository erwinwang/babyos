    global io_hlt
;--------------------------
;void io_hlt();
;--------------------------
align 4
section .text 
io_hlt:
    hlt
    ret