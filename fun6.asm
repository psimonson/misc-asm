; ==================================================================
; Simple clock sleep and beep functions.
; by 5n4k3
; ==================================================================

[bits 16]
[org 100h]
[section .text]
global _start
jmp short _start

; ==================================================================
; Main program
; ==================================================================

_start:
	call beep			; call beep function
	int 20h				; exit to DOS

; ==================================================================
; Subroutines below here...
; ==================================================================

; cx for high word, low word dx
timer:
	push ax				; store ax on the stack
	mov ah, 86h			; timer function BIOS
	int 15h				; BIOS interrupt
	pop ax				; restore ax from the stack
	ret					; return to previous code

beep:
	mov al, 182			; prepare speaker for note
	out 43h, al			; send command
	mov ax, 4560		; note to play
	out 42h, al			; send low byte
	mov al, ah			; get high byte
	out 42h, al			; send high byte
	in al, 61h			; turn on note
	or al, 00000011b	; do NOT change
	out 61h, al			; send new value
	mov cx, 07h			; set high word for timer
	mov dx, 0a120h		; set low word for timer
	call timer			; execute timer
	in al, 61h			; turn off note
	and al, 11111100b	; reset bit 1 and 0
	out 61h, al			; send new value
	ret					; return to previous code
