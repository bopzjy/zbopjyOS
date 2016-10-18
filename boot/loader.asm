org		0100h
    jmp     short LABEL_START

;栈基址
BaseOfStack     equ     0x100

%include	"pm.inc"
%include	"load.inc"
%include	"fat12hdr.inc"

								;	段基址			段界限					属性
LABEL_GDT:				Descriptor	0,				0,						0
LABEL_DESC_FLAT_C:		Descriptor	0,				0FFFFH,					DA_CR + DA_32 + DA_LIMIT_4K
LABEL_DESC_FLAT_RW:		Descriptor	0,				0ffffh,					DA_DRW + DA_32 + DA_LIMIT_4K
LABEL_DESC_VIDEO:		Descriptor	0B8000h,		0ffffh,					DA_DRW + DA_DPL3

GdtLen		equ		$ - LABEL_GDT
GdtPtr		dw		GdtLen - 1
			dd		BaseOfLoaderPhyAddr + LABEL_GDT

; GDT 选择子
SelectorFlatC       equ     LABEL_DESC_FLAT_C       - LABEL_GDT
SelectorFlatRW		equ		LABEL_DESC_FLAT_RW		- LABEL_GDT
SelectorVideo		equ		LABEL_DESC_VIDEO		- LABEL_GDT


;    jmp     short LABEL_START

;%include	"fat12hdr.inc"

LABEL_START:
    mov     ax,cs
    mov     es,ax
    mov     ds,ax
    mov     ax,0b800h
    mov     gs,ax

;	给程序分配堆栈空间
    mov     esp,BaseOfStack

;	获得内存信息
	xor		ebx,ebx
	mov		di,_MemChkBuf
.loop:
	mov		ax,0E820H
	mov		ecx,20
	mov		edx,0534D4150H	;strng:"SMAP"
	int		15H
	jc		LABEL_MEM_CHECK_FAIL
	inc		dword [_dwMCRNumber]
	add		di,20
	test	ebx,ebx
	jnz		.loop
	jmp		LABEL_MEM_CHECK_OK
LABEL_MEM_CHECK_FAIL:
	mov		dword [_dwMCRNumber],0
LABEL_MEM_CHECK_OK:
   
	mov		dh,0						; "Loading  "
	call	DispStrRealMode				; 显示字符串

    ;复位软驱，ah=0,dl=0
    xor     ah,ah
    xor     dl,dl
    int     13h;

    ;读取根目录区,ax=起始扇区号,cl=要读取的扇区数目,es:bx=保存的位置,dl=driverToBeRead
	xor		dl,dl
    mov     ax,BaseOfKernelFile
    mov     es,ax
    mov     ax,SectorNoOfRootDir
    mov     cl,RootDirSectors
    mov     bx,OffsetOfKernelFile
    call    ReadSector

	;从根目录区中遍历找到Kernel.bin的首簇号
    xor     cx,cx
LABEL_FIND_BEGIN:
    cmp     cx,[BPB_RootEntCnt]
    je      LABEL_FIND_FAIL
    mov     si,bx
    xor     dx,dx
    mov     di,KernelMsg
LABEL_CMPSTR:
    cmp     dx,11
    je      LABEL_FINDED
    mov     al,[di]
    cmp     [es:si],al
    jne     LABEL_NEXT
    inc     si
    inc     di
    inc     dx
    jmp     LABEL_CMPSTR
LABEL_NEXT:
    add     bx,32
    inc     cx
    jmp     LABEL_FIND_BEGIN
LABEL_FIND_FAIL:
	mov		dh,2
	call	DispStrRealMode
%ifdef	_LOADER_DEBUG_
	mov		ax,4c00h
	int		21h
%else
    jmp     $
%endif

;	找到了kernel.bin的首簇号
LABEL_FINDED:

;	遍历簇链将kernel.bin加载到内存中
	mov		dx,word [es:bx+0x1a]
	mov		bx,OffsetOfKernelFile
.loop1:
	cmp		dx,0xff8
	jnl		LABEL_LOADER_FINISHED
	push	dx
	mov		ax,dx
	add		ax,DeltaSectorNo
	mov		cl,1
	call	ReadSector
	pop		dx
	push	bx
	call	GetFATEntry
	pop		bx
	add		bx,0x200

;	打印'.'号  一个'.'代表读取了一个扇区
	push	ax	
	push	bx
	mov		ah,0eh
	mov		al,'.'
	mov		bl,0fh
	int		10h
	pop		bx
	pop		ax

	jmp		.loop1

;	读取kernel.bin完成
LABEL_LOADER_FINISHED:
;	打印了16 bytes 看是否真的加载了
;   mov     ecx,16
;   mov     dword [dwDispPosRM],(80 * 15 + 0) * 2
;	mov		bx,OffsetOfKernelFile
;.loop: 
;   mov     al,[es:bx]
;   inc     bx
;   call    DispALRealMode
;   add     dword [dwDispPosRM],2
;   loop    .loop

	call	KillMotor

;	打印"Ready.   "
	mov		dh,1
	call	DispStrRealMode

;	进入保护模式
;	加载gdtr
	lgdt	[GdtPtr]

;	关中断
	cli

;	打开地址线A20
	in		al,92h
	or		al,00000010b
	out		92h,al

;	准备切换到保护模式
	mov		eax,cr0
	or		eax,1
	mov		cr0,eax

;	真正跳入保护模式
	jmp		dword SelectorFlatC:BaseOfLoaderPhyAddr + LABEL_SEG_CODE32

    dwDispPosRM   dd  (80 * 3 + 32) * 2
    KernelMsg   db  'KERNEL  BIN'
	bOdd		db	'aa'

	MessageLength		equ		9
	BootMessage:		db		"Loading  "
	Message1			db		"Ready.   "
	Message2			db		"No Kernel"

;************************************************************************************************
;*																								*
;*											End													*
;*											End													*
;*											End													*
;*																								*
;************************************************************************************************

DispStrRealMode:
	mov		ax,MessageLength
	mul		dh
	add		ax,BootMessage
	mov		bp,ax
	mov		ax,ds
	mov		es,ax
	mov		cx,MessageLength
	mov		ax,01301h
	mov		bx,0007h
	mov		dl,0
	add		dh,3
	int		10h
	ret

DispALRealMode:      
    push    edx 
    push    ecx 
    push    edi
             
    mov     edi,dword [dwDispPosRM]
             
    mov     ecx,2     
    mov     dh,0Ch    
.loop:       
    ror     al,4
    mov     dl,al     
    and     dl,0FH    
    cmp     dl,9
    ja      .1
    add     dl,'0'    
    jmp     .2
.1:           
    sub     dl,0AH    
    add     dl,'A'    
.2:           
    mov     [gs:edi],dx
    add     edi,2     
    loop    .loop     
              
    mov     [dwDispPosRM],edi
              
    pop     edi
    pop     ecx
    pop     edx
    ret     

;************************************************************************************************
;   NumOfCluster:dx
;
GetFATEntry:
    push    es
    push    ax
	push	bx
    mov     ax,BaseOfKernelFile
    sub     ax,0x100
    mov     es,ax

;	mov		word [],dx
	mov		ax,dx
	mov		bx,3
	mul		bx						;dx:ax<-ax*3
	mov		bx,2
	div		bx						;ax<-shang, dx<-remainder
	mov		word [bOdd],dx

	mov		bx,word [BPB_BytesPerSec]
	xor		dx,dx
	div		bx						;ax<-SectorNo, dx<-offset
	push	dx
	add		ax,SectorNoOfFAT1
    xor     bx,bx
    mov     cl,2
    call    ReadSector

	pop		bx
	mov		dx,word [es:bx]
	cmp		word [bOdd],1
	jne		LABEL_EVEN
	shr		dx,4

LABEL_EVEN:
	and		dx,0xfff

	pop		bx
    pop     ax
    pop     es
    ret
;************************************************************************************************


;************************************************************************************************
;void ReadSector(NoOfSectorToRead ax, NumOfSecs cl, PathToSave es:bx, DriverToBeRead dl)
ReadSector:
    push    bx
    push    cx

    mov     bl,[BPB_SecPerTrk]
    div     bl

    mov     cl,ah               ;cl:扇区号
    inc     cl

    mov     ch,al               ;ch:柱面号
    shr     ch,1

    mov     dh,al               ;dh:磁道号
    and     dh,1

;    mov     dl,[BS_DrvNum]     ;dl=驱动器号
    mov     dl,0     ;dl=驱动器号

    pop     ax
    pop     bx

.GoOnReading:
    mov     ah,2
    int     13h
    jc      .GoOnReading        ;读取错误 CF=1;这时会不停得读，直到正确

    ret
;************************************************************************************************

KillMotor:
	push	dx
	mov		dx,03f2h
	mov		dl,0
	out		dx,al
	pop		dx
	ret


[section .s32]
[bits	32]
LABEL_SEG_CODE32:
	mov		ax,SelectorVideo
	mov		gs,ax
	mov		ax,SelectorFlatRW
	mov		ds,ax
	mov		es,ax
	mov		ss,ax
	mov		esp,TopOfStack

	mov		edi,(80 * 11 + 79) * 2
	mov		ah,0ch
	mov		al,'P'
	mov		[gs:edi],ax

	mov		dword [dwDispPos],(80 * 6 + 0) * 2
	call	DispMemInfo
	call	SetupPaging

	call	InitKernel
	jmp		SelectorFlatC:KernelEntryPointPhyAddr

	jmp		$

DispReturn:
	push	szReturn
	call	DispStr
    add     esp,4
	ret

; parameter:
;	al:		    the byte to be ouput
;	dwDispPos:	where to ouput
; Assume:
;	the gs has pointed the segment of video memory
DispAL:
	push	edx
	push	ecx
    push    edi

    mov     edi,dword [dwDispPos]

	mov		ecx,2
	mov		dh,0Ch
.loop:
	ror		al,4
	mov		dl,al
	and		dl,0FH
	cmp		dl,9
	ja		.1
	add		dl,'0'
	jmp		.2
.1:
	sub		dl,0AH
	add		dl,'A'
.2:
;    add     bx,2
	mov		[gs:edi],dx
	add		edi,2
	loop	.loop
;	空格就是这么简单
;	mov		dl,32
;	mov		[gs:edi],dx
;	add		edi,2

    mov     [dwDispPos],edi

    pop     edi
	pop		ecx
	pop		edx
	ret

DispInt:
    mov     eax,[esp + 4]
    rol     eax,8
    call    DispAL
    rol     eax,8
    call    DispAL
    rol     eax,8
    call    DispAL
    rol     eax,8
    call    DispAL

    mov     ah,07h          ;0000b:黑底   0111b:灰字
    mov     al,'h'
    push    edi
    mov     edi,dword [dwDispPos]
    mov     [gs:edi],ax
    add     edi,4
    mov     [dwDispPos],edi
    pop     edi
    
    ret

DispMemInfo:
    push    szMemChkTitle
    call    DispStr
    add     esp,4

    push    ecx
    push    esi
    push    edi

    cld
    mov     ecx,dword [dwMCRNumber]
    mov     esi,MemChkBuf
.loop:
    test    ecx,ecx
    jz      Finished
    mov     edi,ARDStruct
    movsd
    movsd
    movsd
    movsd
    movsd

    push    dword [dwBaseAddrLow]
    call    DispInt
    push    dword [dwBaseAddrHigh]
    call    DispInt
    push    dword [dwLengthLow]
    call    DispInt
    push    dword [dwLengthHigh]
    call    DispInt
    push    dword [dwType]
    call    DispInt
    add     esp,20

    call    DispReturn

    cmp     dword [dwType],1
    jne     .1
    mov     eax,[dwBaseAddrLow]
    add     eax,[dwLengthLow]
    cmp     eax,[dwMemSize]
    jb      .1
    mov     [dwMemSize],eax

.1:
    dec     ecx
    jmp     .loop
    
Finished:
    push    szRAMSize
    call    DispStr
    push    dword [dwMemSize]
    call    DispInt
    add     esp,8

    pop     edi
    pop     esi
    pop     ecx
	ret

	
; Parameter:
;	please push the offset of str to be displayed and clean the stack
;
DispStr:
	push	ebp
	mov		ebp,esp
	push	edi
	push	esi
	push	eax
	push	ebx

	cld
	mov		esi,[ebp + 8]
	mov		edi,dword [dwDispPos]
;	mov		ah,0CH
	mov		bl,160
.loop:
	lodsb
	cmp		al,0AH
	jnz		.1
	mov		eax,edi
	div		bl
	inc		al
	mul		bl
	mov		edi,eax
    jmp     .loop

.1:
	test	al,al
	jz		.2
	mov		ah,0CH
	mov		word [gs:edi],ax
	add		edi,2
	jmp		.loop

.2:
	mov		dword [dwDispPos],edi

	pop		ebx
	pop		eax
	pop		esi
	pop		edi
	pop		ebp
	ret


SetupPaging:
    xor     edx,edx
    mov     eax,[dwMemSize]
    mov     ebx,400000h         ;一个页表对应4M内存
    div     ebx
    mov     ecx,eax
    test    edx,edx
    jz      .no_remainder
    inc     ecx
.no_remainder:
    mov     [PageTableNumber],ecx

    ; 初始化页目录表
	mov		ax,SelectorFlatRW
	mov		es,ax
	mov		edi,PageDirBase
	mov		eax,PageTblBase | PG_USU | PG_P | PG_RWW
.1:
	stosd
	add		eax,4096
	loop	.1
    
    ; 初始化页表
    mov     eax,[PageTableNumber]
    mov     ebx,1024
    mul     ebx
    mov     ecx,eax
    mov     edi,PageTblBase
	mov		eax,PG_USU | PG_P | PG_RWW
.2:
	stosd
	add		eax,4096
	loop	.2

	mov		eax,PageDirBase
	mov		cr3,eax
	mov		eax,cr0
	or		eax,80000000H
	mov		cr0,eax

    mov     ax,SelectorFlatRW
    mov     es,ax

    jmp     short .3
.3:
    nop

	ret

;重新放置内核
InitKernel:
;	2CH: e_phnum---Program header table中有多少条目
	cld
	mov		ax,[BaseOfKernelFilePhyAddr + OffsetOfKernelFile + 2Ch]
	mov		[ProgramHeaderNumber],ax
	mov		ebp,[BaseOfKernelFilePhyAddr + OffsetOfKernelFile + 1ch]
	add		ebp,BaseOfKernelFilePhyAddr + OffsetOfKernelFile
.1:
	mov		esi,[ebp + 4]			;esi<--p_offset
	add		esi,BaseOfKernelFilePhyAddr + OffsetOfKernelFile
	mov		edi,[ebp + 8]			;edi<--p_vaddr
	mov		ecx,[ebp + 16]			;ecx<--p_filesz
	rep		movsb
	add		ebp,32
	dec		word [ProgramHeaderNumber]
	jnz		.1
	ret


[section .data1]
ALIGN	32
[BITS	32]
LABEL_DATA:
SPValueInRealMode:	dw		0
_dwMCRNumber:		dd		0
_dwMemSize:         dd      0
_szPMMessage:		db		"In Protect Mode now.",0x0A,0
StrTest:			db		0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0
_szReturn:			db		0x0A,0
_dwDispPos:			dd		0
_ARDStruct:
	_dwBaseAddrLow		dd		0
	_dwBaseAddrHigh		dd		0
	_dwLengthLow		dd		0
	_dwLengthHigh		dd		0
	_dwType				dd		0

_MemChkBuf:				times   256     db  0
_szMemChkTitle			db      "BaseAddrL BaseAddrH LengthLow LengthHigh   Type",0Ah,0
_szRAMSize				dw      "RAM size:",0
_PageTableNumber		dd      0
_ProgramHeaderNumber	dw		0

;偏移量
offsetStrTest		equ		StrTest + BaseOfLoaderPhyAddr
dwMCRNumber         equ     _dwMCRNumber + BaseOfLoaderPhyAddr
dwMemSize           equ     _dwMemSize + BaseOfLoaderPhyAddr
szPMMessage			equ		_szPMMessage + BaseOfLoaderPhyAddr
szReturn			equ		_szReturn + BaseOfLoaderPhyAddr
dwDispPos			equ		_dwDispPos + BaseOfLoaderPhyAddr
ARDStruct			equ		_ARDStruct + BaseOfLoaderPhyAddr
	dwBaseAddrLow		equ		_dwBaseAddrLow + BaseOfLoaderPhyAddr
	dwBaseAddrHigh		equ		_dwBaseAddrHigh + BaseOfLoaderPhyAddr
	dwLengthLow			equ		_dwLengthLow + BaseOfLoaderPhyAddr
	dwLengthHigh		equ		_dwLengthHigh + BaseOfLoaderPhyAddr
	dwType				equ		_dwType + BaseOfLoaderPhyAddr

MemChkBuf			equ		_MemChkBuf + BaseOfLoaderPhyAddr
szMemChkTitle       equ     _szMemChkTitle + BaseOfLoaderPhyAddr
szRAMSize           equ     _szRAMSize + BaseOfLoaderPhyAddr
PageTableNumber     equ     _PageTableNumber + BaseOfLoaderPhyAddr
ProgramHeaderNumber	equ		_ProgramHeaderNumber + BaseOfLoaderPhyAddr

DataLen				equ		$ - LABEL_DATA

StackSpace:	times	1024	db		0
TopOfStack	equ		BaseOfLoaderPhyAddr + $
