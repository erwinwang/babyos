# This program draws color pixels at mode 0x13
# 2012-12-26 01:31
# guzhoudiaoke@126.com	
 .equ  BUFFER_SEG, 0x1000
 # 常量定义：
	VIDEO_SEG_TEXT		= 0xb800
	TEXT_COLOR			= 0x04
 
.section .text
.global _start
.code16
 
_start:
	jmp		main
 
#--------------------------------------------------------------
# 清屏函数：
#	设置屏幕背景色，调色板的索引0指代的颜色为背景色
clear_screen:				# 清屏函数
	movb	$0x06,	%ah		# 功能号0x06
	movb	$0,		%al		# 上卷全部行，即清屏
	movb	$0,		%ch		# 左上角行
	movb	$0,		%ch		# 左上角列	
	movb	$24,	%dh		# 右下角行
	movb	$79,	%dl		# 右下角列
	movb	$0x07,	%bh		# 空白区域属性
	int		$0x10
	ret
 
#---------------------------------------------------------------
# 直接写显存显示一些文字函数：
#	调用前需要设置DS：SI为源地址，DI为显示位置，
#	CX 为显示的字符个数, AL为颜色属性
draw_some_text:
	# ES:DI is the dst address, DS:SI is the src address
	movw	$VIDEO_SEG_TEXT,	%bx
	movw	%bx,				%es
	
copy_a_char:
	movsb
	stosb
	loop	copy_a_char
	ret
 
#----------------------------------------------------------------
# 读取软盘第二个扇区：
#	使用BIOS INT 0x13中断，使用前需要设置ES：BX作为缓冲区
read_one_sect:
	movb	$0x02,	%ah		# 功能号
	movb	$0x01,	%al		# 读取扇区数
	movb	$0x00,	%ch		# 柱面号
	movb	$0x02,	%cl		# 扇区号
	movb	$0x00,	%dh		# 磁头号
	movb	$0x00,	%dl		# 驱动器号
 
re_read:					# 若调用失败则重新调用
	int		$0x13
	jc		re_read			# 若进位位（CF）被置位，表示调用失败
	
	ret
 
main:
	movw	%cx,	%ax
	movw	%ax,	%ds
	movw	%ax,	%es
 
	call	clear_screen		# 清屏
 
	movw	$0,			%ax
	movw	%ax,		%ds
	leaw	msg_str,	%si
	xorw	%di,		%di
	movw	msg_len,	%cx
	movb	$TEXT_COLOR,%al
	call	draw_some_text		# 绘制字符串
 
	movw	$BUFFER_SEG,%ax		
	movw	%ax,		%es		# ES:BX 为缓冲区地址
	xorw	%bx,		%bx
	call	read_one_sect
 
	# 下面调用绘制函数，在屏幕上显示读取的信息
	movw	$BUFFER_SEG,%ax
	movw	%ax,		%ds		# ds:si 为源地址
	xorw	%si,		%si
	movw	$160,		%di		# 第一行已经打印了msg_str，从第二行开始显示
	movw	$512,		%cx		# 显示512个字符
	movb	$0x01,		%al
	call	draw_some_text
 
1:
	hlt
	jmp		1b
 
msg_str:
	.asciz	"The data of the second sect of the floppy (sect 1):"
msg_len:
	.int	. - msg_str - 1
 
	.org	0x1fe,	0x90
	.word	0xaa55
