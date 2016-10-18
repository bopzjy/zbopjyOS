
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                              klib.asm
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; 导入全局变量
extern	disp_pos

[SECTION .text]

; 导出函数
global	disp_str
global	disp_color_str
global	out_byte

; 导出变量
global	disp_pos

; ========================================================================
;                  void disp_str(char * info);
; ========================================================================
disp_str:
	push	ebp
	mov	ebp, esp

	mov	esi, [ebp + 8]	; pszInfo
	mov	al,[esi]
	mov	edi, [disp_pos]
	mov	ah, 0Fh
.1:
	lodsb
	test	al, al
	jz	.2
	cmp	al, 0Ah	; 是回车吗?
	jnz	.3
	push	eax
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	eax
	jmp	.1
.3:
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1

.2:
	mov	[disp_pos], edi

	pop	ebp
	ret


; void out_byte(u16 port, u8 value);
out_byte:
	mov		edx,[esp + 4]
	mov		al,[esp + 4 + 4]
	out		dx,al
	nop		;要加点延迟
	nop		
	ret

;	u8 in_byte(u16 port);
in_byte:
	mov		edx,[esp + 4] 
	xor		eax,eax
	in 		al,dx
	nop
	nop
	ret

; ========================================================================
;                  void disp_color_str(char * info, int color);
; ========================================================================
disp_color_str:
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp + 8]	; pszInfo
	mov		edi, [disp_pos]
	mov		ah, [ebp + 12] ; color
.1:
	lodsb
	test	al, al
	jz		.2
	cmp		al, 0Ah	; 是回车吗?
	jnz		.3
	push	eax
	mov		eax, edi
	mov		bl, 160
	div		bl
	and		eax, 0FFh
	inc		eax
	mov		bl, 160
	mul		bl
	mov		edi, eax
	pop		eax
	jmp		.1
.3:
	mov		[gs:edi], ax
	add		edi, 2
	jmp		.1

.2:
	mov		[disp_pos], edi

	pop		ebp
	ret
