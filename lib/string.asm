[SECTION .text]

global		memcpy

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
	xchg	bx,bx
	rep		movsb

	pop		edi
	pop		esi
	pop		ecx
	pop		ebp
ret
