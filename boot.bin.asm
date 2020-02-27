00000000  FA                cli
00000001  8CC8              mov ax,cs
00000003  8ED8              mov ds,ax
00000005  8EC0              mov es,ax
00000007  8ED0              mov ss,ax
00000009  BC007C            mov sp,0x7c00
0000000C  B406              mov ah,0x6
0000000E  B000              mov al,0x0
00000010  B500              mov ch,0x0
00000012  B100              mov cl,0x0
00000014  B618              mov dh,0x18
00000016  B24F              mov dl,0x4f
00000018  B717              mov bh,0x17
0000001A  CD10              int 0x10
0000001C  B800B8            mov ax,0xb800
0000001F  8EC0              mov es,ax
00000021  26C606000062      mov byte [es:0x0],0x62
00000027  26C606010007      mov byte [es:0x1],0x7
0000002D  26C60602006F      mov byte [es:0x2],0x6f
00000033  26C606030007      mov byte [es:0x3],0x7
00000039  26C60604006F      mov byte [es:0x4],0x6f
0000003F  26C606050007      mov byte [es:0x5],0x7
00000045  26C606060074      mov byte [es:0x6],0x74
0000004B  26C606070007      mov byte [es:0x7],0x7
00000051  3EA07A7C          mov al,[ds:0x7c7a]
00000055  26A20800          mov [es:0x8],al
00000059  26C606090007      mov byte [es:0x9],0x7
0000005F  8CC8              mov ax,cs
00000061  26A20A00          mov [es:0xa],al
00000065  26C6060B0007      mov byte [es:0xb],0x7
0000006B  2688260C00        mov [es:0xc],ah
00000070  26C6060D0007      mov byte [es:0xd],0x7
00000076  F4                hlt
00000077  E9FCFF            jmp 0x76
0000007A  6200              bound ax,[bx+si]
0000007C  0000              add [bx+si],al
0000007E  0000              add [bx+si],al
00000080  0000              add [bx+si],al
00000082  0000              add [bx+si],al
00000084  0000              add [bx+si],al
00000086  0000              add [bx+si],al
00000088  0000              add [bx+si],al
0000008A  0000              add [bx+si],al
0000008C  0000              add [bx+si],al
0000008E  0000              add [bx+si],al
00000090  0000              add [bx+si],al
00000092  0000              add [bx+si],al
00000094  0000              add [bx+si],al
00000096  0000              add [bx+si],al
00000098  0000              add [bx+si],al
0000009A  0000              add [bx+si],al
0000009C  0000              add [bx+si],al
0000009E  0000              add [bx+si],al
000000A0  0000              add [bx+si],al
000000A2  0000              add [bx+si],al
000000A4  0000              add [bx+si],al
000000A6  0000              add [bx+si],al
000000A8  0000              add [bx+si],al
000000AA  0000              add [bx+si],al
000000AC  0000              add [bx+si],al
000000AE  0000              add [bx+si],al
000000B0  0000              add [bx+si],al
000000B2  0000              add [bx+si],al
000000B4  0000              add [bx+si],al
000000B6  0000              add [bx+si],al
000000B8  0000              add [bx+si],al
000000BA  0000              add [bx+si],al
000000BC  0000              add [bx+si],al
000000BE  0000              add [bx+si],al
000000C0  0000              add [bx+si],al
000000C2  0000              add [bx+si],al
000000C4  0000              add [bx+si],al
000000C6  0000              add [bx+si],al
000000C8  0000              add [bx+si],al
000000CA  0000              add [bx+si],al
000000CC  0000              add [bx+si],al
000000CE  0000              add [bx+si],al
000000D0  0000              add [bx+si],al
000000D2  0000              add [bx+si],al
000000D4  0000              add [bx+si],al
000000D6  0000              add [bx+si],al
000000D8  0000              add [bx+si],al
000000DA  0000              add [bx+si],al
000000DC  0000              add [bx+si],al
000000DE  0000              add [bx+si],al
000000E0  0000              add [bx+si],al
000000E2  0000              add [bx+si],al
000000E4  0000              add [bx+si],al
000000E6  0000              add [bx+si],al
000000E8  0000              add [bx+si],al
000000EA  0000              add [bx+si],al
000000EC  0000              add [bx+si],al
000000EE  0000              add [bx+si],al
000000F0  0000              add [bx+si],al
000000F2  0000              add [bx+si],al
000000F4  0000              add [bx+si],al
000000F6  0000              add [bx+si],al
000000F8  0000              add [bx+si],al
000000FA  0000              add [bx+si],al
000000FC  0000              add [bx+si],al
000000FE  0000              add [bx+si],al
00000100  0000              add [bx+si],al
00000102  0000              add [bx+si],al
00000104  0000              add [bx+si],al
00000106  0000              add [bx+si],al
00000108  0000              add [bx+si],al
0000010A  0000              add [bx+si],al
0000010C  0000              add [bx+si],al
0000010E  0000              add [bx+si],al
00000110  0000              add [bx+si],al
00000112  0000              add [bx+si],al
00000114  0000              add [bx+si],al
00000116  0000              add [bx+si],al
00000118  0000              add [bx+si],al
0000011A  0000              add [bx+si],al
0000011C  0000              add [bx+si],al
0000011E  0000              add [bx+si],al
00000120  0000              add [bx+si],al
00000122  0000              add [bx+si],al
00000124  0000              add [bx+si],al
00000126  0000              add [bx+si],al
00000128  0000              add [bx+si],al
0000012A  0000              add [bx+si],al
0000012C  0000              add [bx+si],al
0000012E  0000              add [bx+si],al
00000130  0000              add [bx+si],al
00000132  0000              add [bx+si],al
00000134  0000              add [bx+si],al
00000136  0000              add [bx+si],al
00000138  0000              add [bx+si],al
0000013A  0000              add [bx+si],al
0000013C  0000              add [bx+si],al
0000013E  0000              add [bx+si],al
00000140  0000              add [bx+si],al
00000142  0000              add [bx+si],al
00000144  0000              add [bx+si],al
00000146  55                push bp
00000147  AA                stosb
