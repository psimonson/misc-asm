; fun2.asm - same as fun.asm but only BIOS.
; by 5n4k3
[bits 16]
[org 100h]
[section .text]
global _start
jmp short _start

; =================== Data again ============================
hello_msg db "Hello user, press any key to continue . . .",0dh,0ah,24h
; =================== End again =============================

_start:
	; setup segments
	mov ax, cs
	mov ds, ax
	mov es, ax

	mov dx, hello_msg
	call print
	int 20h

print:
	push ax
	push bx
	push dx
	mov si, dx
	mov cx, 0
.loop:
	push cx
	lodsb
	cmp al, 24h
	je .done
	mov ah, 0eh
	mov bx, 0007h
	int 10h
	pop cx
	inc cx
	jmp .loop
.done:
	pop dx
	pop bx
	pop ax
	ret

