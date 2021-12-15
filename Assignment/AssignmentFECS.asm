;
; AssignmentFECS.asm
;
; Created: 9/15/2021 11:09:51 AM
; Author : Aman Kumar Singh
;

;;;;;;;;;;;;;;;;;;;;;;;;;NOTE;;;;;;;;;;;;;;;;;
.include"m32def.inc"

.cseg

.org 0x00
rjmp initData ;Jumps directly to the init data, bypassing the vector table

.org 0x0e ;Vector for Output Compare A interrupt
rjmp compA ;Jumps to Interrupt Sub-Routine

.org 0x10 ;Vector for Output Compare A interrupt
rjmp compB ;Jumps to Interrupt Sub-Routine

initData:
	ldi zl, low(2*ocr) ;Stores the memory address of ocr array in z register
	ldi zh, high(2*ocr) ;Stores the memory address of ocr array in z register
setup:
ocr: .dw 12499,7499, 6249,3749, 4166,2499, 3124,1874, 2499,1499, 2082,1249, 1785,1071, 1562,937, 1388,832, 1249,749 
//ocr array that contains the value of ocr a and ocr b register


	/****Initialize Stack Pointer*****/
	ldi r16,HIGH(ramend)
	out sph,r16
	ldi r16,LOW(ramend)
	out spl,r16
	/******************************************/

	ldi r21,0x04 //Load 0x04 in r21 register
	out ddrb,r21 //Sets ddb4 pin as high (ie making pinb4 output) by loading the value in r21
	out portb,r21
	/********************/
	lpm r18,z+ //stores the value of register that the z register is pointing to in r18 and the increment it
	lpm r17,z+ //stores the value of register that the z reg ister is pointing to in r17 and the increment it
	// r17 and r18 now contains high and low nibble of OCRA value to generate 10hz cycle
	sts 0x4b,r17 //Storing the high value in OCRA1L
	sts 0x4a,r18 //Storing the low value in OCRB1L
	
	lpm r18,z+ //stores the value of register that the z register is pointing to in r18 and the increment it
	lpm r17,z //stores the value of register that the z reg ister is pointing to in r17 and the increment it
	// r17 and r18 now contains high and low nibble of OCRB value to generate 10hz cycle with 60% duty cycle
	sts 0x49,r17 //Storing the high value in OCRB1L
	sts 0x48,r18 //Storing the high value in OCRB1L
	/*******************/
	ldi r16,(1<<wgm10)|(1<<wgm11) //Setting the Waveform Generation Mode as Fast-PWM with updatable TOP value. For this, WGM13:0 = 1
	sts 0x4f,r16 //Load it into TCCR1A register

	ldi r16,(1<<wgm12)|(1<<wgm13)|(1<<cs11)|(1<<cs10) //Here we have clock source as clock I/O with a pre-scaler of 64
	sts 0x4e,r16 //Load it into TCCR1B register

	ldi r16,(1<<ocie1a)|(1<<ocie1b) //Here we are enabling the output compare interrupt which executes the ISR after compare match has been found with OCR and TCNT
	sts 0x59,r16 //Load it into TIMSK register
	/*************************************/
	/*USEFUL VARIABLES*/
	ldi r16,-1 //Keeps track of OCR Values array and helps in updating it
	/**************************************/
	ldi r19,0 
	sts 0x4d,r19 //Resets the TCCNT1 register, ie resets the timer
	sts 0x4c,r19
	/**********************/
	sei

loop:
	rjmp loop //Main Loop

compA: //Output Compare A Interrtupt
	eor r20,r21   // Xclusive Or for toggling pin
	out portb,r20
	reti //return from interrupt

compB:  //Output Compare B Interrtupt
	eor r20,r21 // Xclusive Or for toggling pin
	out portb,r20

	/********************/

	;;;;;;;;;;;;;;;;;;;;;;
	;The program below is for updating the values of OCRA registers and OCRB registers with new values
	;to update the frequency of PWM before the cycle ends (because it is double buffered, we update before cycle ends).
	;Fist it goes in an incremental loop (incloop) and updates the frequency in increasing order. Then it goes into a decremental loop
	;(decloop) and updates the frequency in decreasing order. Hence it goes from 10Hz to 100Hz and then to 10Hz and so on.
	;The track of frequency is kept by r19 register. Value of r19 oscillates between -1 to 8

tst r19 
brne decloop 
incloop:
	inc zl
	lpm r18,z
	inc zl
	lpm r17,z
	sts 0x4b,r17
	sts 0x4a,r18
	
	inc zl
	lpm r18,z
	inc zl
	lpm r17,z
	sts 0x49,r17
	sts 0x48,r18

	inc r16
	
	cpi r16,0x08
	
	brne skip
	
	ldi r19,1
	dec zl
	dec zl
	dec zl
	

skip:
	rjmp continue
	/*******************/

	/********************/
decloop:

	dec zl
	lpm r17,z
	dec zl
	lpm r18,z
	sts 0x49,r17
	sts 0x48,r18

    dec zl
	lpm r17,z
	dec zl
	lpm r18,z
	sts 0x4b,r17
	sts 0x4a,r18

	dec r16

	cpi r16,-1
	brne continue
	ldi r19,0
	inc zl
	inc zl 
	inc zl
	
	/*******************/
continue:
	reti


