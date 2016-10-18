%include "sconst.inc"

;导入函数
extern		cstart
extern		exception_handler
extern		spurious_irq
extern		kernel_main
extern		disp_str
extern 		delay
extern		clock_handler

; 导入变量
extern		gdt_ptr
extern		idt_ptr
extern		p_proc_ready
extern		tss
extern		k_reenter

;debug
extern		disp_int

[section .data]
clock_int_msg		db		"^", 0

[section .bss]
StackSpace		resb		2 * 1024
StackTop:					;栈顶

[section .text]

global	_start

global	restart

; 中断和异常处理函数
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
global  hwint00
global  hwint01
global  hwint02
global  hwint03
global  hwint04
global  hwint05
global  hwint06
global  hwint07
global  hwint08
global  hwint09
global  hwint10
global  hwint11
global  hwint12
global  hwint13
global  hwint14
global  hwint15

_start:
	mov		esp, StackTop
	sgdt	[gdt_ptr]		;把gdt_ptr导出到外部变量中，cstart()会用到
;	xchg	bx,bx
	call	cstart			;改变gdt_ptr, 让它指向新的GDT

	lgdt	[gdt_ptr]		;使用新的GDT
	lidt	[idt_ptr]		;新的idt

	; 强制使用刚刚初始化的结构
	jmp		SELECTOR_KERNEL_CS:csinit
csinit:

; 测试异常
;	ud2
;	jmp		0x40:0

	sti
;	hlt

	xor		eax,eax
	mov		eax,SELECTOR_TSS
	ltr		ax

	jmp		kernel_main

; 中断和异常 -- 硬件中断
; ---------------------------------
%macro  hwint_master    1
        push    %1
        call    spurious_irq
        add     esp, 4
        hlt
%endmacro
; ---------------------------------

ALIGN   16
hwint00:                ; Interrupt routine for irq 0 (the clock).
	sub		esp, 4
	; save the scene
	pushad
	push	ds
	push	es
	push	fs
	push	gs
	mov		dx, ss
	mov		ds, dx
	mov		es, dx

	inc		byte [gs:0]

	; send EOI，renew i8259A
	mov		al,EOI
	out		INT_M_CTL, al

	; 解决中断重入问题
	inc		dword [k_reenter]
	cmp		dword [k_reenter],0
	jne		.re_enter

	mov		esp, StackTop		; switch into kernel stack
	
	; 切换到内核栈时再打开中断，如果发生中断重入，压栈全压在内核栈中
	sti

	push	0
	call	clock_handler
	add		esp, 4

	; 加入延迟
	push	10
	call	delay
	add		esp,4

	cli

	mov		esp, [p_proc_ready]  ; leave kernel stack

	lea		eax, [esp + P_STACKTOP]
	mov		dword [tss + TSS3_S_SP0], eax

.re_enter:
	dec		dword [k_reenter]

	pop		gs
	pop		fs
	pop		es
	pop		ds
	popad
	add		esp, 4

	iretd

ALIGN   16
hwint01:                ; Interrupt routine for irq 1 (keyboard)
        hwint_master    1

ALIGN   16
hwint02:                ; Interrupt routine for irq 2 (cascade!)
        hwint_master    2

ALIGN   16
hwint03:                ; Interrupt routine for irq 3 (second serial)
        hwint_master    3

ALIGN   16
hwint04:                ; Interrupt routine for irq 4 (first serial)
        hwint_master    4

ALIGN   16
hwint05:                ; Interrupt routine for irq 5 (XT winchester)
        hwint_master    5

ALIGN   16
hwint06:                ; Interrupt routine for irq 6 (floppy)
        hwint_master    6

ALIGN   16
hwint07:                ; Interrupt routine for irq 7 (printer)
        hwint_master    7

; ---------------------------------
%macro  hwint_slave     1
        push    %1
        call    spurious_irq
        add     esp, 4
        hlt
%endmacro
; ---------------------------------

ALIGN   16
hwint08:                ; Interrupt routine for irq 8 (realtime clock).
        hwint_slave     8

ALIGN   16
hwint09:                ; Interrupt routine for irq 9 (irq 2 redirected)
        hwint_slave     9

ALIGN   16
hwint10:                ; Interrupt routine for irq 10
        hwint_slave     10

ALIGN   16
hwint11:                ; Interrupt routine for irq 11
        hwint_slave     11

ALIGN   16
hwint12:                ; Interrupt routine for irq 12
        hwint_slave     12

ALIGN   16
hwint13:                ; Interrupt routine for irq 13 (FPU exception)
        hwint_slave     13

ALIGN   16
hwint14:                ; Interrupt routine for irq 14 (AT winchester)
        hwint_slave     14

ALIGN   16
hwint15:                ; Interrupt routine for irq 15
        hwint_slave     15


divide_error:
	push	0xFFFFFFFF
	push	0
	jmp		exception
single_step_exception:
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

restart:
	
	mov		esp, [p_proc_ready]
	mov		eax, [esp + P_LDT_SEL] 
	lldt	[esp + P_LDT_SEL]
	lea		eax, [esp + P_STACKTOP]
	mov		dword [tss + TSS3_S_SP0], eax

	pop		gs
	pop		fs
	pop		es
	pop		ds
	popad
	add		esp,4
	
	iretd
