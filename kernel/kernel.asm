SELECTOR_KERNEL_CS		equ		8

;导入函数和变量
extern		cstart
extern		gdt_ptr
extern		idt_ptr
extern		exception_handler

;debug
extern		disp_int

[section .bss]
StackSpace		resb		2 * 1024
StackTop:					;栈顶

[section .text]

global	_start
global	testHandler

global	divide_error
global	single_step_exception
global	nmi
global	breakpoint_exception
global	overflow
global	bounds_check
global	inval_opcode
global	copr_not_available
global	double_fault
global	copr_seg_overrun
global	inval_tss
global	segment_not_present
global	stack_exception
global	general_protection
global	page_fault
global	copr_error

_start:
	mov		esp, StackTop
	sgdt	[gdt_ptr]		;把gdt_ptr导出到外部变量中，cstart()会用到
;	xchg	bx,bx
	call	cstart			;改变gdt_ptr, 让它指向新的GDT

	lgdt	[gdt_ptr]		;使用新的GDT
	lidt	[idt_ptr]		;新的idt

	mov		ah,0fh
	mov		al,'K'
	mov		[gs:((80 * 20 + 39) * 2)],ax

	push	0xcef12
	call	disp_int

	jmp		$

testHandler:
	mov		ah,0fh
	mov		al,'I'
	mov		[gs:((80 * 21 + 39) * 2)],ax
	iret

divide_error:
	push	0xFFFFFFFF
	push	0
	jmp		exception
single_step_error:
	push	0xFFFFFFFF
	push	1
nmi:
	push	0xFFFFFFFF	; no err code
	push	2		; vector_no	= 2
	jmp	exception
breakpoint_exception:
	push	0xFFFFFFFF	; no err code
	push	3		; vector_no	= 3
	jmp	exception
overflow:
	push	0xFFFFFFFF	; no err code
	push	4		; vector_no	= 4
	jmp	exception
bounds_check:
	push	0xFFFFFFFF	; no err code
	push	5		; vector_no	= 5
	jmp	exception
inval_opcode:
	push	0xFFFFFFFF	; no err code
	push	6		; vector_no	= 6
	jmp	exception
copr_not_available:
	push	0xFFFFFFFF	; no err code
	push	7		; vector_no	= 7
	jmp	exception
double_fault:
	push	8		; vector_no	= 8
	jmp	exception
copr_seg_overrun:
	push	0xFFFFFFFF	; no err code
	push	9		; vector_no	= 9
	jmp	exception
inval_tss:
	push	10		; vector_no	= A
	jmp	exception
segment_not_present:
	push	11		; vector_no	= B
	jmp	exception
stack_exception:
	push	12		; vector_no	= C
	jmp	exception
general_protection:
	push	13		; vector_no	= D
	jmp	exception
page_fault:
	push	14		; vector_no	= E
	jmp	exception
copr_error:
	push	0xFFFFFFFF	; no err code
	push	16		; vector_no	= 10h
	jmp	exception

exception:
	call	exception_handler
	add	esp, 4*2	; 让栈顶指向 EIP，堆栈中从顶向下依次是：EIP、CS、EFLAGS
	hlt
