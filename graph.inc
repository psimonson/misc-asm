
; ===========================================
; no parameters
plot:
	push bx
	mov ah, 0x0c
	mov bh, 0x00
	int 0x10
	pop bx
	ret
