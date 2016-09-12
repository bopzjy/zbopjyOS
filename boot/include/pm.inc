; 描述符属性见p35
DA_32       EQU		4000h   ; 32 位段
DA_LIMIT_4K	EQU		8000H	; G=1,粒度为4K

; DPL
DA_DPL0		EQU		00H
DA_DPL1		EQU		20H
DA_DPL2		EQU		40H
DA_DPL3		EQU		60H

; 存储段描述符
DA_DR		EQU		90H		; 存在的只读数据段
DA_DRW      EQU		92h		; 存在的可读写数据段属性值
DA_DRWA		EQU		93H		; 存在的可读可写的已访问的数据段
DA_C        EQU		98h		; 存在的只执行的非一致代码段属性值
DA_CR		EQU		9AH		; 存在的可读可执行的非一致代码段
DA_CCO		EQU		9CH		; 存在的可执行的一致代码段
DA_CCOR		EQU		9EH		; 存在的可执行的可读的一致代码段

; 系统段描述符号类型
DA_LDT		EQU		82H		; 局部描述符表段
DA_TaskGate	EQU		85H		; 任务门类型值
DA_386TSS	EQU		89H		; 可用386任务状态段类型值
DA_386CGate	EQU		8CH		; 386 调用门类型值
DA_386IGate	EQU		8EH		; 386 中断门类型值
DA_386TGate	EQU		8FH		; 386 陷阱门类型值

; flag Ti in attr of selector
SA_TIL		EQU		4		;选择子置Ti为1,说明从LDT中找描述符

; RPL
SA_RPL0     EQU		0
SA_RPL1     EQU		1
SA_RPL2     EQU		2
SA_RPL3     EQU		3

; PDE 和 PTE,details in p69
PG_P		EQU		01H		; 页存在
PG_RWR		EQU		00H		; 可读 可执行
PG_RWW		EQU		02H		; 可读可写 可执行
PG_USU		EQU		04H		; 用户级
PG_USS		EQU		00H		; 系统级	



; 见书p32
; Parameter
;	Base:	dd
;	Limit:	dd (仅低 20 bits有用)
;	Attr:	dw
%macro Descriptor 3
	dw	%2 & 0ffffh
	dw	%1 & 0ffffh
	db	(%1 >> 16) & 0ffh
	dw	((%2 >> 8) & 0f00h) | (%3 & 0f0ffh)
	db	(%1 >> 24) & 0ffh
%endmacro

; 见书p51
; Parameter
;	Selector:	dw
;	Offset:		dd
;	DCount:		db
;	Attr:		db
%macro Gate 4
	dw	%2 & 0FFFFH
	dw	%1
	db	%3 & 01FH
	db	%4
	dw	((%2 >> 16) & 0FFFFH)
%endmacro

%macro _MAGIC_BREAK_POINT_ 0
	xchg	bx,bx
%endmacro
