; simple clear screen with color
; by 5n4k3
[bits 16]
[org 100h]
[section .text]
global _start
jmp short _start

; data
width db 80
height db 24
background db 10h
foreground db 0eh
welcome db "Welcome to the look of a commodore 64!",0dh,0ah,24h

_start:
	; setup segments
	mov ax, cs
	mov ds, ax
	mov es, ax

	call clr_scrn
	mov dx, welcome
	call prnt_str
	int 20h

prnt_str:
	mov si, dx
.loop:
	mov al, byte [si]
	inc si
	cmp al, 24h
	je .done
	mov ah, 0eh
	mov bx, 0007h
	mov cx, 1
	int 10h
	jmp short .loop
.done:
	ret

clr_scrn:
	mov ah, 02h
	mov dx, 0
	int 10h
.loop:
	mov ah, 09h
	mov al, 20h
	mov bh, 00h
	mov bl, byte [background]
	or bl, byte [foreground]
	mov cx, 1
	int 10h
	mov ah, 02h
	inc dl
	int 10h
	cmp dl, byte [width]
	jl .loop
.loop2:
	mov ah, 09h
	mov al, 20h
	mov bh, 00h
	mov bl, byte [background]
	or bl, byte [foreground]
	mov cx, 1
	int 10h
	mov ah, 02h
	inc dh
	mov dl, 0
	int 10h
	cmp dh, byte [height]
	jle .loop
	mov ah, 02h
	mov dx, 0
	int 10h
	ret
