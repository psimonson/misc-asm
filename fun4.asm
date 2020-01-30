; simple command shell for MS-DOS and dosbox
; by 5n4k3
[bits 16]
[org 100h]
[section .bss]
buffer resb 32
[section .text]
global _start
jmp _start

; =========================== Data Section =========================
reboot_msg db "Press any key to reboot . . .",0dh,0ah,24h
help_msg db "Help [None yet]",0dh,0ah,24h
help_cmd db "help",24h
reboot_cmd db "reboot",24h
prompt db "> ",24h
crlf_msg db 0dh,0ah,24h
; ==================================================================

_start:
	call shell
	; return from COM file if reboot doesn't occur
	int 20h

; put message in dx
print:
	mov si, dx
.loop:
	lodsb
	cmp al, 24h
	je .done
	mov ah, 0eh
	mov bx, 0007h
	int 10h
	jmp short .loop
.done:
	ret

; put command in di
cmp_str:
	clc
.loop:
	lodsb
	mov bl, byte [di]
	cmp al, bl
	jne .fail
	cmp byte [di], 24h
	je .done
	inc di
	jmp short .loop
.fail:
	stc
.done:
	ret

get_str:
	mov di, buffer
.loop:
	xor ax, ax
	int 16h
	cmp al, 08h
	je .back
	cmp al, 0dh
	je .done
	mov ah, 0eh
	mov bx, 7
	int 10h
	stosb
	jmp short .loop
.back:
	mov ah, 0eh
	mov al, 08h
	mov bx, 0007h
	mov cx, 0001h
	int 10h
	mov ah, 0eh
	mov al, 20h
	mov bx, 0007h
	mov cx, 0001h
	int 10h
	mov ah, 0eh
	mov al, 08h
	mov bx, 0007h
	mov cx, 0001h
	int 10h
	dec di
	mov byte [di], 24h
	jmp short .loop
.done:
	mov al, 24h
	stosb
	mov dx, crlf_msg
	call print
	ret

clr_str:
	mov di, buffer
	mov cx, 0020h
.loop:
	dec cx
	xor ax, ax
	mov al, 24h
	stosb
	cmp cx, 0
	jne .loop
	ret

shell:
	mov dx, prompt
	call print
	call clr_str
	call get_str
	mov si, buffer
	mov di, help_cmd
	call cmp_str
	jnc .help
	mov si, buffer
	mov di, reboot_cmd
	call cmp_str
	jnc .reboot
	jmp short shell
.help:
	mov dx, help_msg
	call print
	jmp short shell
.reboot:
	mov dx, reboot_msg
	call print
	; get key press
	mov ax, 0001h
	int 16h
	; warm reboot machine
	push 0ffffh
	push 0000h
	retf

