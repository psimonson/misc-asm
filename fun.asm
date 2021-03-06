; simple assembly program
; by 5n4k3

[bits 16]
[org 100h]
[section .text]
global _start:
jmp short _start

; ================ Data section ======================
hello_msg db "Hello user, please continue . . .",0dh,0ah,24h
; ================ End of Data =======================

_start:
	; setup data segment
	mov ax, cs
	mov ds, ax
	mov es, ax

	; print message with DOS interrupt
	mov ah, 9
	mov dx, hello_msg
	int 21h
	; return to DOS from COM program
	int 20h

