
;%define     _DEBUG_BOOT_

%ifdef      _DEBUG_BOOT_
    org     0x100
%else
    org     0x7c00
%endif

;栈基址
%ifdef      _DEBUG_BOOT_
    BaseOfStack     equ     0x100
%else
    BaseOfStack     equ     0x7c00
%endif

%include	"load.inc"

    jmp     short LABEL_START
    nop

%include	"fat12hdr.inc"

LABEL_START:
    mov     ax,cs
    mov     es,ax
    mov     ds,ax
    mov     ax,0b800h
    mov     gs,ax

;	给程序分配堆栈空间
    mov     esp,BaseOfStack
    
;	清屏
	mov		ax,0x600
	mov		bx,0x700
	mov		cx,0
	mov		dx,0x184f
	int		10h

;	显示"Booting  "
	mov		dh,0
	call	DispStr

    ;复位软驱，ah=0,dl=0
    xor     ah,ah
    xor     dl,dl
    int     13h;

    ;读取根目录区,ax=起始扇区号,cl=要读取的扇区数目,es:bx=保存的位置,dl=driverToBeRead
	xor		dl,dl
    mov     ax,BaseOfLoader
    mov     es,ax
    mov     ax,SectorNoOfRootDir
    mov     cl,RootDirSectors
    mov     bx,OffsetOfLoader
    call    ReadSector

	;从根目录区中遍历找到loader.bin的首簇号
    xor     cx,cx
LABEL_FIND_BEGIN:
    cmp     cx,[BPB_RootEntCnt]
    je      LABEL_FIND_FAIL
    mov     si,bx
    xor     dx,dx
    mov     di,LoaderMsg
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
    jmp     $

;	找到了loader.bin的首簇号
LABEL_FINDED:

;	遍历簇链将loader.bin加载到内存中
	mov		dword [dwDispPos],(80 * 0 + 10) * 2		;用于打印'.'，一个'.'代表读取了一个扇区
	mov		dx,word [es:bx+0x1a]
	mov		bx,OffsetOfLoader
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

;	打印'.'号
	mov		edi,dword [dwDispPos]
	mov		ah,0ch
	mov		al,'.'
	mov		[gs:edi],ax
	add		dword [dwDispPos],2

	jmp		.loop1

;	读取loader.bin完成
LABEL_LOADER_FINISHED:
    mov     ecx,16
    mov     dword [dwDispPos],(80 * 14 + 0) * 2
	mov		bx,OffsetOfLoader
.loop: 
    mov     al,[es:bx]
    inc     bx
    call    DispAL
    add     dword [dwDispPos],2
    loop    .loop

;	打印"Ready"
	mov		dh,1
	call	DispStr

;	将控制权交给loader.bin
    jmp     BaseOfLoader:OffsetOfLoader

    dwDispPos   dd  (80 * 3 + 32) * 2
    LoaderMsg   db  'LOADER  BIN'
	bOdd		db	'aa'

	MessageLength		equ		9
	BootMessage:		db		"Booting  "
	Message1			db		"Ready.   "
	Message2			db		"No LOADER"

;************************************************************************************************
;*																								*
;*											End													*
;*											End													*
;*											End													*
;*																								*
;************************************************************************************************

DispStr:
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
	int		10h
	ret

DispAL:      
    push    edx 
    push    ecx 
    push    edi
             
    mov     edi,dword [dwDispPos]
             
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
              
    mov     [dwDispPos],edi
              
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
    mov     ax,BaseOfLoader
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

    times   510-($-$$)      db  0
    dw      0xaa55








