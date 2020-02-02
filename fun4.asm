; ==================================================================
; Simple command shell for MS-DOS and dosbox.
; Below are currently implemented for you.
; ==================================================================
;  1. Exit command.
;  2. Reboot command.
;  3. Help command.
; ==================================================================
; Exercises below, greater the number the harder to exercise.
; ==================================================================
;  1. Implement version command.
;  2. Add clear screen command, also clear screen for shell.
;  3. Make text type out for version info (like typewriters do).
; ==================================================================
; by 5n4k3
; ==================================================================

[bits 16]
[org 100h]
[section .bss]
buffer resb 32
[section .text]
global _start
jmp _start

; =========================== Data Section =========================

reboot_msg db "Press any key to reboot . . .",0dh,0ah,24h
help_msg:
         db "========================================",0dh,0ah
         db "=            *** Help ***              =",0dh,0ah
         db "========================================",0dh,0ah
         db "help     - This text is help.",0dh,0ah
         db "reboot   - Warm reboot the machine.",0dh,0ah
         db "exit     - Exit back to DOS.",0dh,0ah
         db "========================================",0dh,0ah,24h
help_cmd db "help",24h
reboot_cmd db "reboot",24h
exit_cmd db "exit",24h
bad_cmd db "Bad command.",0dh,0ah,24h
prompt db "> ",24h
crlf_msg db 0dh,0ah,24h

; ==================================================================

_start:
	; setup segments
	mov ax, cs
	mov ds, ax
	mov es, ax

	call shell
	; return from COM file if reboot doesn't occur
	int 20h

; ============================ Subroutines =========================

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
	mov si, buffer
	mov di, exit_cmd
	call cmp_str
	jnc .exit
	mov dx, bad_cmd
	call print
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
.exit:
	ret
