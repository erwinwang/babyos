.equ BOOTSEG, 0x07C0 
          .org 0
          .code16  
          .section ".bstext", "ax"  
          .global bootsect_start  
  bootsect_start:  
    
          # Normalize the start address  
          ljmp    $BOOTSEG, $start2
    
  start2:  
          movw    %cs, %ax  
          movw    %ax, %ds  
          movw    %ax, %es  
          movw    %ax, %ss  
          xorw    %sp, %sp  
          sti  
          cld  
    
          movw    $bugger_off_msg, %si  
    
  msg_loop:  
          lodsb  
          andb    %al, %al  
          jz      bs_die  
          movb    $0xe, %ah  
          movw    $7, %bx  
          int     $0x10  
          jmp     msg_loop  
    
  bs_die:  
          # Allow the user to press a key, then reboot  
          xorw    %ax, %ax  
          int     $0x16  
          int     $0x19  
    
          # int 0x19 should never return.  In case it does anyway,  
          # invoke the BIOS reset code...  
          ljmp    $0xf000,$0xfff0  
    
  bugger_off_msg:  
          .ascii  "Hello Boot!\r\n"  
          .ascii  "by harvey\r\n"  
          .ascii  "\n"  
          .byte   0  
  
          .org 510  
          .word 0xAA55
          