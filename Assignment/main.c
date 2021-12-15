/*
 * main.c
 *
 * Created: 10/13/2021 9:58:16 AM
 *  Author: Aman Kumar Singh
 */ 
#include <avr/io.h>            //Header File Containing the Name and Definition of I/O
#include <avr/interrupt.h>     //Header File used because we are using interrupts to achieve our task
#include <stdbool.h>           //Header File included to be able to use bool type data

volatile uint16_t OCRAval[]={12499,6249,4166,3124,2499,2082,1785,1562,1388,1250}; //Contains Output Compare Register A Values that determines the time/frequency of a cycle.
volatile uint16_t OCRBval[]={7499,3749,2499,1874,1499,1249,1071,937,832,749}; //Contains Output Compare Register B Values that determines the duty of PWM cycle
volatile uint8_t count=0; //A variable that keeps track of OCR Values array and helps in updating it.(i.e. OCRAval[count],OCRBval[count] when count=0 generates 10hz PWM with 60% duty cycle)
volatile bool isReverse = false; //A reference variable to that states if frequency is increasing or decreasing (i.e. 10Hz->20Hz->..100Hz is represented by 0 and vice versa by 1)

ISR(TIMER1_COMPA_vect)
  {
  PORTB ^= (1<<5); // Toggle 5th Pin (PORTB4) 
}

ISR(TIMER1_COMPB_vect)
{
   PORTB ^= (1<<5); // Toggle 5th Pin (PORTB4) 
    if(isReverse)
    {
	    OCR1A = OCRAval[--count]; //Update OCR value for the next cycle. We do it before completing the cycle because it will be double-buffered
	    OCR1B = OCRBval[count]; //Values updating in an incremental manner
	    if(count==0)
	    isReverse = false;
    }
    else
    {
	    OCR1A = OCRAval[++count]; //Update OCR value for the next cycle. We do it before completing the cycle because it will be double-buffered
	    OCR1B = OCRBval[count]; //Values updating in a decremental manner
	    if(count==9)
	    isReverse = true;
    }
}

int main()
{
    DDRB = (1<<DDB4); // Set 5th PIN of Port B as output. We want to toggle this PIN to create a PWM of a specific frequency with 60% Duty Cycle.
    
    OCR1A = OCRAval[0]; //Updates OCR1A with the initial value (for 10 Hz)
    OCR1B = OCRBval[0]; //Updates OCR1A with the initial value (60% Duty Cycle)
    //Note :- We are using Fast-PWM with updatable TOP instead of the standard MAX Value. The TOP value is given in OCR1A register.
   
    TCCR1A = (1<<WGM11)|(1<<WGM10); //Setting the Waveform Generation Mode as Fast-PWM with updatable TOP value. For this, WGM13:0 = 1
    
    TCCR1B = (1<<WGM12)|(1<<WGM13)|(1<<CS10)|(1<<CS11); //Here we have clock source as clock I/O with a pre-scaler of 64
    
    TIMSK = (1<<OCIE1A)|(1<<OCIE1B); //Here we are enabling the output compare interrupt which executes the ISR after compare match has been found with OCR and TCNT
    
	PORTB ^= (1<<5); // Toggle 5th Pin (PORTB4) 
	
    TCNT1 = 0; //Reset the counter, i.e. we start from this instant
    
	sei(); //Set Global Interrupt Flag
   
    

    while(1)
    {
		//Do your stuff here
    }
    return 0;
}
