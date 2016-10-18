[SECTION .text]

global		memcpy
global		memset
global		strcpy

; void* memcpy(void* pDst, void* pSrc, int iSize)
memcpy:
	push	ebp
	mov		ebp,esp
	push	ecx
	push	esi
	push	edi

	mov		ecx,[ebp + 16]
	mov		esi,[ebp + 12]
	mov		edi,[ebp + 8]
	cld		
	rep		movsb

	pop		edi
	pop		esi
	pop		ecx
	pop		ebp
ret

; void* memset(void* p_dst, char ch, int size);
memset:
	push	ebp
	mov		ebp,esp
	push	edi
	push	es
	push	eax
	push	ecx
	
	mov		edi,[ebp + 8]
	mov		al, [ebp + 12]
	mov		ecx,[ebp + 16]
	mov		ax,ss
	mov		es,ax
	cld
	rep		stosb

	pop		ecx
	pop		eax
	pop		es
	pop		edi
	pop		ebp

	ret

; char* strcpy(char* p_dst, char* p_src)
strcpy:
	push	ebp
	mov		ebp,esp
	push	esi
	push	edi

	std
	mov		edi, [ebp + 8]
	mov		esi, [ebp + 12]
	cmp		byte [ds:esi],0
	jne		.exit
	movsb

.exit:
	pop		edi
	pop		esi
	pop		ebp

	ret
