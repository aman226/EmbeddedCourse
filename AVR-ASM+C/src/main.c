/*
 * main.c
 *
 * Created: 9/11/2021 7:30:26 AM
 *  Author: Aman Kumar Singh
 */ 
#include <avr/io.h>
#include <util/delay.h>

void toggle();

int main()
{
 DDRB = _BV(DDB5);
 while(1)
 {
  toggle();
  _delay_ms(1000);
 }
 
 return 0;
}

