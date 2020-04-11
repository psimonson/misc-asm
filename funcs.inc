
; ========================================
; eax - time in milliseconds.
conv_time:
	mov ebx, 1000
	mul ebx
	mov dx, ax
	rol eax, 16
	mov cx, ax
	ret

; ========================================
; ax - time in milliseconds
timer:
	push eax
	push ebx
	push ecx
	push edx
	call conv_time
	mov ax, 0x8600
	int 0x15
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

; ========================================
; no parameters
getc_ignore:
	push ax
	xor ax, ax
	int 0x16
	pop ax
	ret

; ========================================
; no parameters
getc:
	xor ax, ax
	int 0x16
	ret

; ========================================
; dl - key to hit.
kbdhit:
	mov ax, 0x0100
	int 0x16
	ret

; ========================================
; bh - page number.
; bl - color attribute.
; [ds:si] - message to print.
print:
	push ax
	push cx
	push dx
	push si
.loop:
	lodsb
	or al, al
	jz .done
	mov ah, 0x0e
	int 0x10
	jmp .loop
.done:
	pop si
	pop dx
	pop cx
	pop ax
	ret

; ========================================
; bx - amount of memory to clear.
; si - memory to clear.
clrmem:
	push ax
	push bx
	push si
.loop:
	mov byte [si+bx], 0
	dec bx
	cmp bx, 0
	jge .loop
	pop si
	pop bx
	pop ax
	ret

; ========================================
; bx - amount of memory to move.
; si - source string.
reverse:
	push ax
	push bx
	push cx
	push si
	xor cx, cx
.loop:
	push bx
	mov bx, cx
	mov ah, byte [si+bx]
	pop bx
	mov al, byte [si+bx]
	mov byte [si+bx], ah
	push bx
	mov bx, cx
	mov byte [si+bx], al
	pop bx
	dec bx
	inc cx
	cmp cx, bx
	jl .loop
.done:
	pop si
	pop dx
	pop bx
	pop ax
	ret

; ========================================
; ax - number to convert.
; bx - memory size.
; di - string to store to.
itoa:
	pusha
	call clrmem
	xor cx, cx
.loop:
	cmp cx, bx
	jg .done
	push bx
	mov bx, 10
	xor dx, dx
	div bx
	pop bx
	push ax
	add dx, '0'
	mov byte [si], dl
	inc si
	inc cx
	pop ax
	cmp ax, 0
	jge .loop
.done:
	popa
	call reverse
	ret

