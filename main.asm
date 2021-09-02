;
; Delay.asm
;
; Created: 9/1/2021 5:53:20 PM
; Author : Aman Kumar Singh
;

.include "m328Pdef.inc"
.equ outloop = 30000
.equ inloop = 5
.org 0x00
; Replace with your application code

main:
	ldi r16,(1<<ddb5)
	
	ldi r17,(1<<portb5)
	out ddrb,r16
	ldi r16,0

	ldi r24,LOW(outloop)
	ldi r25,HIGH(outloop)	

loop:
	eor r16,r17
	out portb,r16
	call delay
	jmp loop


delay:
	ldi r23,inloop
delay1:
	dec r23
	brne delay1

	sbiw r24,1
	brne delay
	ret
	
	

	
