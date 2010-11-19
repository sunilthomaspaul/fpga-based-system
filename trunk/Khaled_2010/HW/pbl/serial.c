/**
 * @file serial.c
 */

/*
 * (C) Copyright 2005
 * AMIRIX Systems Inc.
 *
 * Originated from ppcboot-2.0.0/drivers/serial.c
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */


#include "xparameters.h"
#include "ns16550.h"
#include "serial.h"

#define MAX_NUM_UARTS 4

static NS16550_t gConsoleList[MAX_NUM_UARTS];
static int gNumConsoles = 0;
static int gActiveConsole = 0;

/**
 * Function pointer to the proper getc() routine.
 * This pointer is set in SerialSelectConsole() to correspond to which UARTs are
 *  in use.
 */
int (*serial_getc)(void) = NULL;

/**
 * Function pointer to the proper putc() routine.
 * This pointer is set in SerialSelectConsole() to correspond to which UARTs are
 *  in use.
 */
void (*serial_putc)(const char c) = NULL;

/**
 * Function pointer to the proper tstc() routine.
 * This pointer is set in SerialSelectConsole() to correspond to which UARTs are
 *  in use.
 */
int (*serial_tstc)(void) = NULL;

/**
 * Function pointer to the proper puts() routine.
 * This pointer is set in SerialSelectConsole() to correspond to which UARTs are
 *  in use.
 */
void (*serial_puts)(const char *s) = NULL;



/**
 * getc() that uses one UART.
 */
int Serial_getc_One(void)
{
    return NS16550_getc(gConsoleList[gActiveConsole]);
}


/**
 * getc() that uses more than one UART.
 * This function polls all UARTs until one of them provides an input character.
 * @return The first character received from any of the UARTs.
 */
int Serial_getc_All(void)
{
    int ret_val;
    int got_char = 0;
    int index = 0;

    while(got_char == 0){
        if(NS16550_tstc(gConsoleList[index])){
            got_char = 1;
            ret_val = NS16550_getc(gConsoleList[index]);
        }

        index = (index + 1) % gNumConsoles;
    }

    return ret_val;
}

/**
 * putc() that uses one UART.
 */
void Serial_putc_One(const char c)
{
    if(c == '\n'){
        NS16550_putc(gConsoleList[gActiveConsole], '\r');
    }

    NS16550_putc(gConsoleList[gActiveConsole], c);
}

/**
 * putc() that uses more than one UART.
 * This function outputs the provided char to all UARTs.  '\r' characters are
 *  added after all '\n' characters.
 */
void Serial_putc_All(const char c)
{
    int ii;

    for(ii = 0;ii < gNumConsoles;ii++){
        if (c == '\n'){
            NS16550_putc(gConsoleList[ii], '\r');
        }
        NS16550_putc(gConsoleList[ii], c);
    }
}

/**
 * tstc() that uses one UART.
 * @return The index of the UART with a pending character, if any.
 * @retval 0  No characters were pending.
 * @retval SERIAL_TESTC_OFFSET A character is pending.
 */
int Serial_tstc_One(void)
{
    int ret_val = 0;
    if(NS16550_tstc(gConsoleList[gActiveConsole])){
        ret_val = SERIAL_TESTC_OFFSET + gActiveConsole;
    }
    return ret_val;
}

/**
 * tstc() that uses more than one UART.
 * This function checks all UARTs for pending characters.  If more than one UART
 *  has pending characters, the return value will correspond to the LAST UART in
 *  the list with pending characters.
 *
 * To maintain the standard tstc() return value of 0 indicating no pending characters,
 *  the return value is determined by adding SERIAL_TESTC_OFFSET to the index of
 *  the UART with a pending character.  Thus, a return value of 0 still indicates no
 *  characters, and != 0 (or >0) indicates pending characters, and by subtracting
 *  SERIAL_TESTC_OFFSET from the return value, the UART with input can be determined.
 * @return The index of the UART with a pending character, if any.
 * @retval 0  No characters were pending on any of the UARTs.
 * @retval >0 The index of the UART with a pending character, plus SERIAL_TESTC_OFFSET.
 */
int Serial_tstc_All(void)
{
    int ret_val = 0;
    int ii;

    for(ii = 0;ii < gNumConsoles;ii++){
        if(NS16550_tstc(gConsoleList[ii])){
            ret_val = ii + SERIAL_TESTC_OFFSET;
        }
    }

    return ret_val;
}

/**
 * puts() that uses one UART.
 */
void Serial_puts_One(const char *s)
{
    while(*s){
        serial_putc(*s++);
    }
}

/**
 * puts() that uses more than one UART.
 */
void serial_puts_all(const char *s)
{
    while (*s){
        Serial_putc_All(*s++);
    }
}

/**
 * Initializes a list of 16550 UARTs.
 * NS16550_init() is called for each UART listed, and the contents of theUARTList.
 *  are copied to @ref gConsoleList.
 *
 * This function calls SerialSelectConsole() to ensure that i/o is provided.
 *  If one UART is present, it is selected.  If more than one are present, SERIAL_SELECT_ALL
 *  is used.
 * @param  theUARTList [IN] array of addresses to each UART.
 * @param  theNumUARTs [IN] number of elements in the UARTList array.
 * @return The status of the function call.
 * @retval 0 if the function succeeded. (This function always succeeds)
 */
int SerialInit(unsigned int* theUARTList, int theNumUARTs)
{
    int ii;
    int clock_divisor = CFG_NS16550_CLK / 16 / CFG_BAUD;

    gNumConsoles = 0;
    for(ii = 0;ii < theNumUARTs;ii++){
        gConsoleList[gNumConsoles] = (NS16550_t) theUARTList[ii];
        NS16550_init(gConsoleList[gNumConsoles], clock_divisor);
        gNumConsoles++;
    }

    if(theNumUARTs > 1){
        SerialSelectConsole(SERIAL_SELECT_ALL);
    }
    else{
        SerialSelectConsole(0);
    }

    return (0);
}

/**
 * Selects one or all of the initialized UARTs to be used for user i/o.
 * An invalid theConsoleIndex results in no change to the selected console.
 * @param  theConsoleIndex [IN] index in @ref gConsoleList to use.
 * @return The status of the function call.
 * @retval 0  if the function succeeded.
 * @retval -1 if an invalid theConsoleIndex was provided.
 */
int SerialSelectConsole(int theConsoleIndex){
    int ret_val = 0;
    if(theConsoleIndex == SERIAL_SELECT_ALL){
        serial_getc = &Serial_getc_All;
        serial_putc = &Serial_putc_All;
        serial_tstc = &Serial_tstc_All;
        serial_puts = &serial_puts_all;
    }
    else if(theConsoleIndex < gNumConsoles){
        gActiveConsole = theConsoleIndex;
        serial_getc = &Serial_getc_One;
        serial_putc = &Serial_putc_One;
        serial_tstc = &Serial_tstc_One;
        serial_puts = &Serial_puts_One;
    }
    else{
        ret_val = -1;
    }

    return ret_val;
}
