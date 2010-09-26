/**
 * @file serial.h
 */

/*
 * (C) Copyright 2005
 * AMIRIX Systems Inc.
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

#ifndef SERIAL_H
#define SERIAL_H

#include "xuartns550_l.h"
#include "xparameters.h"


extern int (*serial_getc)(void);
extern void (*serial_putc)(const char c);
extern int (*serial_tstc)(void);
extern void (*serial_puts)(const char *s);

/** Flag used with SerialSelectConsole() to indicate all UARTs to be active. */
#define SERIAL_SELECT_ALL -1

/** The value added to the index of the UART with a pending char to determine the
 * return value of Serial_tstc_All(). */
#define SERIAL_TESTC_OFFSET 0x10

int SerialInit(unsigned int* theUARTList, int theNumUARTs);
int SerialSelectConsole(int theConsoleIndex);

#endif
