;
; Interrupt.asm
;
; Created: 9/2/2021 9:07:33 AM
; Author : Aman Kumar Singh
;

.include "m328Pdef.inc"
.equ OCRval = 64000
.org 0x00 
	jmp setup
.org 0x0E
	jmp tim1comp

setup:
	ldi r16,((1<<wgm12)|(1<<com1a0))
	sts tccr1a,r16
	ldi r16,(1<<cs10)|(1<<cs11)
	sts tccr1b,r16
	ldi r16,HIGH(OCRval)
	sts ocr1ah,r16
	ldi r16,LOW(OCRval)
	sts ocr1al,r16
	ldi r16,(1<<ocie1a)
	sts timsk1,r16
	ldi r16,(1<<ddb1)
	mov r17,r16
	out ddrb,r16
	out portb,r16

; do your stuff here
loop:
	jmp loop

tim1comp:
	eor r16,r17
	out portb,r16
	reti
	
