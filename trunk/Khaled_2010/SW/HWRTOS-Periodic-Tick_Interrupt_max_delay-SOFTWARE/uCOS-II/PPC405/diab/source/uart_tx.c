/****************************************************************************

		THIS SOFTWARE IS NOT COPYRIGHTED

   Wipro offers the following for use in the public domain.  Wipro makes no
   warranty with regard to the software or its performance and the
   user accepts the software "AS IS" with all faults.

   WIPRO DISCLAIMS ANY WARRANTIES, EXPRESS OR IMPLIED, WITH REGARD
   TO THIS SOFTWARE INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

****************************************************************************/
/****************************************************************************
 *  File name: uart_tx.c
 *
 *  Ganesh S, Wipro Technologies. 
 *
 *  This file contains uart tx functions.
****************************************************************************/

#include "types.h"
#include "uart.h"

#include <stdarg.h>
#include <ctype.h>

/*
* uart_putchar
* Sends a character on the specific uart port.
* Input: port - UART0 or UART1
*        c - character 
* Return: number of chars sent.
*/
sint32 uart_putchar(uint8 port, sint8 c)
{
    sint32 count = 1;
    sint8 outchar = c;
    sint8 status;
    uint32 base;

    if (port == UART0) base = UART0_BASE;
    else base = UART1_BASE;

    /*------------------------------------------------------------------------
        If the transmitter is ready, send the character out.
    -------------------------------------------------------------------------*/ 
    status = (sint8)inbyte(base+LSR);
    if ((status & asyncLSRTxHoldEmpty) != 0x0)
    {
        outbyte(base, outchar);
    }

    /*------------------------------------------------------------------------
        Wait till the character is sent out.        
    -------------------------------------------------------------------------*/ 
    while ((inbyte(base+LSR) & asyncLSRTxHoldEmpty) == 0) ;

    /*------------------------------------------------------------------------
        If a new line is to be sent, send it also out
    -------------------------------------------------------------------------*/ 
    if (outchar == '\n')
    {  
        /* newline  */
        outbyte(base, '\r');
        count++;
    }

    /*------------------------------------------------------------------------
        Wait till the newline is sent out.        
    -------------------------------------------------------------------------*/ 
    while ((inbyte(base+LSR) & asyncLSRTxHoldEmpty) == 0) ;

    return(count);           
}

/*
* out_str
* Sends a string on the console port.
* Input: str - pointer to the string.
* Return: none.
*/
void out_str(uint8 *str)
{
   while(*str != '\0')
   {
       uart_putchar(UART0, *str++);
   }
}

/*
* s1printf
* A printf version that outputs on console port.
*/
int s1printf(const char *format, ...)
{

   int  i, count;
   char   buffer[510];
   va_list arg_list;

   va_start(arg_list, format);
   count = vsprintf(buffer, format, arg_list);
   va_end(arg_list);

   if (count > 0)
   {
      for (i = 0; i < count; i++)
      {
         (void)uart_putchar(UART0, buffer[i]);
         if (buffer[i] == '\n')
         {
            (void)uart_putchar(UART0, '\r');
         }
      }
   }
   return(count);
}
