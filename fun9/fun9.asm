; ==================================================================
; Simple command shell for MS-DOS and dosbox in color, using BIOS
; video interrupt and function 09h.
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

%include "data.inc"
reboot_msg db "Press any key to reboot . . .",0dh,0ah,24h
help_cmd db "help",24h
reboot_cmd db "reboot",24h
exit_cmd db "exit",24h
bad_cmd db "Bad command.",0dh,0ah,24h
prompt db "> ",24h
wait_msg db "Press any key to continue . . .",0dh,0ah,24h
crlf_msg db 0dh,0ah,24h
color db 1eh		; back/fore ground color
width db 4fh		; screen width
height db 18h		; screen height
xpos db 0			; for mvcur
ypos db 0			; for mvcur
xpos2 db 0			; for scrolling
ypos2 db 0			; for scrolling

; ==================================================================

_start:
	; setup segment registers, no need for stack as it's a COM file.
	mov ax, cs
	mov ds, ax
	mov es, ax

	; program begins
	call clr_scr2
	mov dx, message_msg
	call print
	call beep
	mov cx, 000fh
	mov dx, 0a20h
	call timer
	mov dx, wait_msg
	call print
	xor ax, ax
	int 16h
	call shell
	; return from COM file if reboot doesn't occur
	int 20h

; ============================ Subroutines =========================

; put char in al
putc:
	mov ah, 09h
	mov bh, 00h
	mov bl, byte [color]
	mov cx, 0001h
	int 10h
	ret

mvcur:
	mov al, byte [height]
	cmp byte [ypos], al
	jl .done
	mov al, byte [height]
	mov byte [ypos], al
.done:
	mov ah, 02h
	mov bh, 00h
	mov dh, byte [ypos]
	mov dl, byte [xpos]
	int 10h
	ret

mvcur2:
	mov ah, 02h
	mov bh, 00h
	mov dh, byte [ypos2]
	mov dl, byte [xpos2]
	int 10h
	ret

gput:
	mov ah, 08h
	mov bh, 00h
	int 10h
	push ax
	mov ah, 02h
	mov dh, byte [ypos2]
	sub dh, 1
	mov dl, byte [xpos2]
	int 10h
	pop ax
	mov bl, ah
	mov ah, 09h
	mov bh, 00h
	mov bl, byte [color]
	mov cx, 0001h
	int 10h
	ret

clr_ln:
	mov ah, 02h
	mov dh, byte [ypos2]
	sub dh, 1
	mov dl, 0
	int 10h
.loop:
	mov al, 20h
	call putc
	mov ah, 02h
	inc dl
	int 10h
	cmp dl, byte [width]
	jl .loop
	call mvcur
	ret

; scroll screen down
scroll:
	mov byte [xpos2], 0
	mov byte [ypos2], 1
	call mvcur2
.loop:
	call gput
	inc byte [xpos2]
	call mvcur2
	mov al, byte [width]
	cmp byte [xpos2], al
	jl .loop
	mov byte [xpos2], 0
	inc byte [ypos2]
	call mvcur2
	mov al, byte [ypos2]
	cmp byte [ypos], al
	jge .loop
	call clr_ln
	ret

; put message in dx
print:
	mov si, dx
.loop:
	lodsb
	cmp al, 24h
	je .done
	cmp al, 0ah
	je .cr
	cmp al, 0dh
	je .lf
	call putc
	inc byte [xpos]
	call mvcur
	jmp short .loop
.cr:
	mov byte [xpos], 0
	call mvcur
	jmp short .loop
.lf:
	inc byte [ypos]
	call mvcur
	mov al, byte [height]
	cmp byte [ypos], al
	jl .loop
	call scroll
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

timer:
	mov ah, 86h
	int 15h
	ret

beep:
	push ax
	mov al, 182
	out 43h, al
	mov ax, 4560
	out 42h, al
	mov al, ah
	out 42h, al
	in al, 61h
	or al, 00000011b
	out 61h, al
	mov cx, 0007h
	mov dx, 0a20h
	call timer
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop ax
	ret

; clear full screen
clr_scr2:
	xor dx, dx
	call set_cur
.loop:
	mov al, 20h
	call putc
	inc dl
	call set_cur
	cmp dl, byte [width]
	jl .loop
	mov al, 20h
	call putc
	mov dl, 0
	inc dh
	call set_cur
	mov al, byte [height]
	add al, 1
	cmp dh, al
	jl .loop
	xor dx, dx
	call set_cur
	ret

; set cursor position
set_cur:
	mov ah, 02h
	int 10h
	ret

; clear shell screen
clr_scr:
	mov byte [xpos], 0
	mov byte [ypos], 0
	call mvcur
.loop:
	mov al, 20h
	call putc
	inc byte [xpos]
	call mvcur
	mov al, byte [width]
	cmp byte [xpos], al
	jl .loop
	mov al, 20h
	call putc
	mov byte [xpos], 0
	inc byte [ypos]
	call mvcur
	mov al, byte [height]
	cmp byte [ypos], al
	jl .loop
	mov byte [xpos], 0
	mov byte [ypos], 0
	call mvcur
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
	call clr_scr2
	mov dx, close_msg
	call print
	ret
