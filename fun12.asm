; get BIOS memory

[bits 16]
[org 0x100]

[section .data]
MEMSIZ equ 5
memmsg db "Total memory: ",0x0
memory times MEMSIZ+1 db 0
memcnt dw 0

[section .text]
global _start
_start:
	mov ax, cs
	mov ds, ax
	mov es, ax

	mov si, memmsg
	call print

	int 0x12
	mov bx, MEMSIZ
	mov si, memory
	call itoa

	mov si, memory
	call print

	int 0x20

; =========================== Functions Below ============================

%include "funcs.inc"
