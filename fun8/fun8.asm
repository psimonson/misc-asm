; funny image
; by 5n4k3

[bits 16]
[org 100h]
[section .text]
global _start
jmp short _start

; data
start_msg db "Preparing to delete system...        ",24h
okay_msg db "[OK]",0dh,0ah,24h
end_msg: db "Thank god it was only a joke, right?",0dh,0ah
         db "Press any key to quit...",0dh,0ah,24h

width db 80
height db 25

_start:
	; setup segments
	mov ax, cs
	mov ds, ax
	mov es, ax

	call clr_scrn
	mov dx, start_msg
	call print
	mov cx, 0007h
	mov dx, 030ah
	call timer
	mov dx, okay_msg
	call print
	mov cx, 0007h
	mov dx, 01feh
	call timer
	mov dx, virii_msg
	call print
	mov dx, end_msg
	call print
	xor ax, ax
	int 16h
	int 20h

; =============================== Subroutines =============================

; dx contains string to print
print:
	mov si, dx
.loop:
	lodsb
	cmp al, 24h
	jz .done
	mov ah, 0eh
	mov bx, 0007h
	mov cx, 1
	int 10h
	jmp short .loop
.done:
	ret

; cx high word, dx low word.
timer:
	mov ah, 86h
	int 15h
	ret

clr_scrn:
	mov ah, 02h
	mov dx, 0
	int 10h
.loop:
	mov ah, 09h
	mov al, 20h
	mov bx, 001eh
	mov cx, 0001h
	int 10h
	mov ah, 02h
	inc dl
	int 10h
	push dx
	mov cx, 0000h
	mov dx, 01fh
	call timer
	pop dx
	cmp dl, byte [width]
	jl .loop
	mov ah, 09h
	mov al, 20h
	mov bx, 001eh
	mov cx, 0001h
	int 10h
	mov ah, 02h
	mov dl, 0
	inc dh
	int 10h
	cmp dh, byte [height]
	jl .loop
	mov ah, 02h
	mov dx, 0000h
	int 10h
	ret

%include "data.inc"
