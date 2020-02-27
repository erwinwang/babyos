	.file	"main.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	pushl	%ebp
.LCFI0:
	movl	%esp, %ebp
.LCFI1:
	andl	$-16, %esp
	subl	$32, %esp
.LCFI2:
	movl	$0, 28(%esp)
	movl	$3, 4(%esp)
	movl	$2, (%esp)
	call	add
	movl	%eax, 28(%esp)
	movl	$109, (%esp)
	call	put_char
.L2:
	addl	$1, 28(%esp)
/APP
/  35 "main.c" 1
	hlt
	
/NO_APP
	jmp	.L2
.LFE0:
	.size	main, .-main
	.globl	add
	.type	add, @function
add:
.LFB1:
	pushl	%ebp
.LCFI3:
	movl	%esp, %ebp
.LCFI4:
	subl	$16, %esp
.LCFI5:
	movl	$0, -4(%ebp)
	movl	12(%ebp), %eax
	movl	8(%ebp), %edx
	addl	%edx, %eax
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %eax
	leave
.LCFI6:
	ret
.LFE1:
	.size	add, .-add
	.section	.eh_frame,"aw",@progbits
.Lframe1:
	.long	.LECIE1-.LSCIE1
.LSCIE1:
	.long	0
	.byte	0x1
	.string	""
	.byte	0x1
	.byte	0x7c
	.byte	0x8
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.byte	0x88
	.byte	0x1
	.align 4
.LECIE1:
.LSFDE1:
	.long	.LEFDE1-.LASFDE1
.LASFDE1:
	.long	.LASFDE1-.Lframe1
	.long	.LFB0
	.long	.LFE0-.LFB0
	.byte	0x4
	.long	.LCFI0-.LFB0
	.byte	0xe
	.byte	0x8
	.byte	0x85
	.byte	0x2
	.byte	0x4
	.long	.LCFI1-.LCFI0
	.byte	0xd
	.byte	0x5
	.align 4
.LEFDE1:
.LSFDE3:
	.long	.LEFDE3-.LASFDE3
.LASFDE3:
	.long	.LASFDE3-.Lframe1
	.long	.LFB1
	.long	.LFE1-.LFB1
	.byte	0x4
	.long	.LCFI3-.LFB1
	.byte	0xe
	.byte	0x8
	.byte	0x85
	.byte	0x2
	.byte	0x4
	.long	.LCFI4-.LCFI3
	.byte	0xd
	.byte	0x5
	.byte	0x4
	.long	.LCFI6-.LCFI4
	.byte	0xc5
	.byte	0xc
	.byte	0x4
	.byte	0x4
	.align 4
.LEFDE3:
	.ident	"GCC: (GNU) 4.6.1"
