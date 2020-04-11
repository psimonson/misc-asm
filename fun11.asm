; simple print hex
; by 5n4k3

[bits 16]
[org 0x100]

[section .data]
hex_string db "0x0000",0x0
crlf db 0x0a,0x0d,0x0
a20yes db "A20 is enabled.",0x0a,0x0d,0x0
a20no db "A20 unavailable.",0x0a,0x0d,0x0

[section .text]
[global _start]

_start:
	mov ax, cs
	mov ds, ax
	mov es, ax

	; print hex
	mov si, hex_string
	call print_string
	mov si, crlf
	call print_string
	mov dx, 0x2BAD
	call print_hex
	mov si, crlf
	call print_string
	mov si, hex_string
	call print_string
	mov si, crlf
	call print_string
	call enable_a20

	int 0x20 ; return from DOS

; si : contains string to print.
print_string:
	pusha
.loop:
	lodsb
	or al, al
	jz .done
	mov ah, 0x0e
	mov bx, 7
	int 0x10
	jmp .loop
.done:
	popa
	ret

; dx : contains number to print.
print_hex:
	pusha
	mov cx, 4
.loop:
	dec cx
	mov ax, dx
	shr dx, 4
	and ax, 0xf
	mov bx, hex_string
	add bx, 2
	add bx, cx
	cmp ax, 0xa
	jl .set
	add byte [bx], 7
.set:
	add byte [bx], al
	cmp cx, 0
	je .done
	jmp .loop
.done:
	mov si, hex_string
	call print_string
	call clr_hex
	popa
	ret

clr_hex:
	pusha
	mov cx, 4
.loop:
	dec cx
	mov bx, hex_string
	add bx, 2
	add bx, cx
	mov byte [bx], 0x30
	cmp cx, 0
	jne .loop
	popa
	ret

set_a20_bios:
	pusha
	mov ax, 0x2401
	int 0x15
	popa
	ret

set_a20_fast:
	pusha
	in al, 0x92
	or al, 2
	out 0x92, al
	popa
	ret

check_a20:
	pushf
	push ds
	push es
	push si
	push di
	cli
	xor ax, ax
	mov es, ax
	not ax
	mov ds, ax
	mov al, byte [es:di]
	push ax
	mov al, byte [ds:si]
	push ax
	mov byte [es:di], 0x00
	mov byte [ds:si], 0xff
	cmp byte [es:di], 0xff
	pop ax
	mov byte [ds:si], al
	pop ax
	mov byte [es:di], al
	mov ax, 0
	je .done
	mov ax, 1
.done:
	pop di
	pop si
	pop es
	pop ds
	popf
	ret

enable_a20:
	call check_a20
	cmp ax, 0
	jne .done
	call set_a20_bios
	call check_a20
	cmp ax, 0
	jne .done
	call set_a20_fast
	call check_a20
	cmp ax, 0
	jne .done
	mov si, a20no
	call print_string
.done:
	mov si, a20yes
	call print_string
	ret
