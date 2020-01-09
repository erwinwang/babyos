findmessage        db      "find...."
findstrlen              equ     $-findmessage        
nofindmessage           db    "find fail..."
nofindstrlen            equ     $-nofindmessage
LoaderFileName        db    "LOADER  BIN"
strlen             equ    $-LoaderFileName
times     510-($-$$)    db    0    ; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw     0x6699                ; 结束标志
