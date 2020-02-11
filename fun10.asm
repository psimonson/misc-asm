; simple cpu tester program.
; by 5n4k3

[bits 16]
[org 100h]
[section .text]

_start:
	mov ax, cs
	mov ds, ax
	mov es, ax

	; check for 8086
	mov cx, 0121h
	shl ch, cl
	jz short p1_8086
	; check for 286
	push sp
	pop ax
	cmp ax, sp
	jne short p1_186
	; check for 386
	mov ax, 7000h
	push ax
	popf
	pushf
	pop ax
	and ax, 7000h
	cmp ax, 7000h
	jne short p1_286
	mov dx, p2_386
.done:
	mov ah, 09h
	int 21h
	int 20h
p1_8086:
	mov dx, p2_8086
	jmp short _start.done
p1_186:
	mov dx, p2_186
	jmp short _start.done
p1_286:
	mov dx, p2_286
	jmp short _start.done

; data
p2_8086 db "You have a 8086 processor.",0ah,0dh,24h
p2_186 db "You have a 80186 processor.",0ah,0dh,24h
p2_286 db "You have a 80286 processor.",0ah,0dh,24h
p2_386 db "You have a 80386 processor.",0ah,0dh,24h

