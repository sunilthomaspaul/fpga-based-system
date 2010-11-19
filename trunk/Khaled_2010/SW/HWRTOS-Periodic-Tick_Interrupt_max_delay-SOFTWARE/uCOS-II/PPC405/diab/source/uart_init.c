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
 *  File name: uart_init.c
 *
 *  Ganesh S, Wipro Technologies. 
 *
 *  This code has been tested on the IBM Walnut PPC405GP board.
 *  The board has 2 UART channels, UART0 and UART1.
 *  UART0 is setup as a console only port. UART1 is setup as a terminal port.
 *  This driver uses a polling approach. 
****************************************************************************/
#include "types.h"
#include "uart.h"

#include <stdarg.h>
#include <ctype.h>

sint32 g_inchar, g_inchar0;
/*
* uart0_init
* Function iniatilises the uart0 channel for console port operations.
* Input: None
* Return: None
*/
static void uart0_init()
{

/* Set LCR[DLA] to access baud registers */
    outbyte((UART0_BASE+LCR), asyncLCRDivisorLatchAccess);

/* Set baud rate of the console prot at 9600 bps */    
    outbyte(UART0_BASE,0x48);
    outbyte((UART0_BASE+1), 0);
            
/* 8N1 */
    outbyte((UART0_BASE+LCR), (asyncLCRWordLength8 | 
                                     asyncLCRParityDisable | 
                                     asyncLCRStopBitsOne));
        
/* enable FIFO, Reset FIFOs, trigger Rx FIFO at 1 byte */    
    outbyte((UART0_BASE+FCR), (asyncFCRFIFOEnable | 
                                    asyncFCRRxFIFOReset |
                                    asyncFCRTxFIFOReset | 
                                    asyncFCRRxTrigLevel1));
        
/* polled mode. Disable tx and rx interrupt. */
    outbyte((UART0_BASE+IER), 0x00);

/* Activate DTR, RTS  - we are using a 3 wire cable only */
    outbyte((UART0_BASE+MCR), (asyncMCRRtsActive | 
                                        asyncMCRDtrActive));
#ifdef UART_INTERRUPT
/* Hook up the uart1 isr */
    uic_install_isr(0,uart0_isr,0);
#endif
    
   return;
}

/*
* uart1_init
* Function iniatilises the uart1 channel for serial i/o operations
* Input: None
* Return: None
*/
static void uart1_init()
{

/* Set LCR[DLA] to access baud registers */
    outbyte((UART1_BASE+LCR), asyncLCRDivisorLatchAccess);

/* Set baud rate of the console prot at 9600 bps */    
    outbyte(UART1_BASE,0x48);
    outbyte((UART1_BASE+1), 0);
            
/* 8N1 */
    outbyte((UART1_BASE+LCR), (asyncLCRWordLength8 | 
                                     asyncLCRParityDisable | 
                                     asyncLCRStopBitsOne));
        
/* enable FIFO, Reset FIFOs, trigger Rx FIFO at 1 byte */    
    outbyte((UART1_BASE+FCR), (asyncFCRFIFOEnable | 
                                    asyncFCRRxFIFOReset |
                                    asyncFCRTxFIFOReset | 
                                    asyncFCRRxTrigLevel4));
        
/* rx interrupt. */
    outbyte((UART1_BASE+IER), 0x00);

/* Activate DTR, RTS  - we are using a 3 wire cable only */
    outbyte((UART1_BASE+MCR), (asyncMCRRtsActive | 
                                        asyncMCRDtrActive));
    return;
}


/*
* uart_init
* Function calls uart0 and uart1 init.
* Input: None
* Return: None
*/
sint32 uart_init()
{
    uart0_init();
    uart1_init();

    return SUCCESS;  
}


/*
* uart1_getchar
* Gets a character from the UART1 channel. It is a blocking function.
* Input: None
* Return: character.
*/
sint8 uart1_getchar()
{
    uint8 err=0;
    uint8 status;

    for(;;) 
    {
        status = (uint8)inbyte(UART1_BASE+LSR);
        if (status & asyncLSRDataReady)
        {
            g_inchar = 0x000000ff & (sint32)inbyte(UART1_BASE);
            break;
        }
    }
    return((sint8)g_inchar);
}


/*
* uart_nonblock_getchar
* Gets a character from the UART1 channel. It is a non-blocking function.
* Input: None
* Return: character if exists.
*/
sint8 uart_nonblock_getchar()
{
    uint8  status;

    status = (uint8)inbyte(UART1_BASE+LSR);
    if (status & asyncLSRDataReady)
    {
        g_inchar = 0x000000ff & (sint32)inbyte(UART1_BASE);
        return g_inchar;
    }
    return 0;
}
