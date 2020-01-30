; fun3.asm - same as fun2.asm but only BIOS with printing string length.
; by 5n4k3
[bits 16]
[org 100h]
[section .text]
global _start
jmp short _start

; =================== Data again ============================
hello_msg db "Hello user, press any key to continue . . .",0dh,0ah,24h
hex_digits db "0123456789ABCDEF",24h
hex_string db "00000000",24h
crlf_msg db 0dh,0ah,24h
; =================== End again =============================

_start:
	mov dx, hello_msg
	call print
	mov ax, 00ffh
	call hex_to_string
	int 20h

print:
	mov si, dx
.loop:
	lodsb
	cmp al, 24h
	je .done
	mov ah, 0eh
	mov bx, 0007h
	int 10h
	jmp .loop
.done:
	ret

hex_to_string:
	mov di, hex_string+8
	mov cx, 0008h
.loop:
	cmp cx, 0
	je .done
	cmp ax, 0
	je .done
	xor dx, dx
	mov bx, 0010h
	div bx
	push ax
	cmp dx, 0ah
	jge .other
	xor ax, ax
	add dx, 48
	mov ax, dx
	mov byte [di], al
	dec di
	pop ax
	jmp short .loop
.other:
	xor ax, ax
	add dx, 55
	mov ax, dx
	mov byte [di], al
	dec di
	pop ax
	jmp short .loop
.done:
	mov dx, hex_string	; copy offset of hex_string to dx
	call print			; call print sub routine
	ret					; return to previous code
