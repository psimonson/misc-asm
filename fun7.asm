; ==================================================================
; Simple program displaying variable ways of using print, timer, and
; beep functions.
; ==================================================================
; by 5n4k3
; ==================================================================

[bits 16]
[org 100h]
[section .text]
global _start
jmp short _start

; ==================================================================
; Data section
; ==================================================================

hello_msg db "Hello user, this is a test...",0dh,0ah,24h

; ==================================================================
; Main program
; ==================================================================

_start:
	; make some noise
	mov ax, 4560
	mov cx, 7
	mov dx, 01a20h
	call beep
	mov cx, 7
	mov dx, 0a20h
	mov ax, 2500
	call beep
	mov ax, 6000
	mov cx, 7
	mov dx, 01feh
	call beep
	mov ax, 1250
	mov cx, 4
	mov dx, 01a20h
	call beep
	; text typer
	mov dx, hello_msg
	call print
	int 20h				; exit to DOS

; ==================================================================
; Subroutines below here...
; ==================================================================

; dx for message
print:
	mov si, dx
.loop:
	lodsb
	cmp al, 24h
	je .done
	mov ah, 0eh
	mov bx, 0007h
	mov cx, 1
	int 10h
	cmp al, 20h
	je .loop
	cmp al, 0ah
	je .loop
	cmp al, 0dh
	je .loop
	cmp al, 08h
	je .loop
	mov ax, 4560
	mov cx, 1
	mov dx, 01a5h
	call beep
	mov ax, 3520
	mov cx, 0
	mov dx, 01f3h
	call beep
	mov cx, 4
	mov dx, 001f8h
	call timer
	jmp short .loop
.done:
	ret

; cx for high word, low word dx
timer:
	push ax				; store ax on the stack
	mov ah, 86h			; timer function BIOS
	int 15h				; BIOS interrupt
	pop ax				; restore ax from the stack
	ret					; return to previous code

beep:
	push dx
	push cx
	push ax
	mov al, 182			; prepare speaker for note
	out 43h, al			; send command
	pop ax
;	mov ax, 4560		; note to play
	out 42h, al			; send low byte
	mov al, ah			; get high byte
	out 42h, al			; send high byte
	in al, 61h			; turn on note
	or al, 00000011b	; do NOT change
	out 61h, al			; send new value
	pop cx
	pop dx
;	mov cx, 07h			; set high word for timer
;	mov dx, 0a120h		; set low word for timer
	call timer			; execute timer
	in al, 61h			; turn off note
	and al, 11111100b	; reset bit 1 and 0
	out 61h, al			; send new value
	ret					; return to previous code
