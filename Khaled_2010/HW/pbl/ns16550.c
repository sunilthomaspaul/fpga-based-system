/**
 * @file ns16550.c
 * COM1 NS16550 support,
 */

/*
 * (C) Copyright 2003
 * AMIRIX Systems Inc.
 *
 * Originated from ppcboot-2.0.0/drivers/ns16550.c
 *
 * originally from linux source (arch/ppc/boot/ns16550.c)
 * modified to use CFG_ISA_MEM and new defines
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


#include "ns16550.h"

#define LCRVAL LCR_8N1					/* 8 data, 1 stop, no parity */

#define MCRVAL (MCR_DTR | MCR_RTS)
#define FCRVAL (0)

void NS16550_init (NS16550_t com_port, int baud_divisor)
{
	com_port->ier = 0x00;
	com_port->lcr = LCR_BKSE | LCRVAL;
	com_port->dll = baud_divisor & 0xff;
	com_port->dlm = (baud_divisor >> 8) & 0xff;
	com_port->lcr = LCRVAL;
	com_port->mcr = MCRVAL;
	com_port->fcr = FCRVAL;
}

void NS16550_reinit (NS16550_t com_port, int baud_divisor)
{
	com_port->ier = 0x00;
	com_port->lcr = LCR_BKSE;
	com_port->dll = baud_divisor & 0xff;
	com_port->dlm = (baud_divisor >> 8) & 0xff;
	com_port->lcr = LCRVAL;
	com_port->mcr = MCRVAL;
	com_port->fcr = FCRVAL;
}

void NS16550_putc (NS16550_t com_port, char c)
{
	while ((com_port->lsr & LSR_THRE) == 0);
	com_port->thr = c;
}

char NS16550_getc (NS16550_t com_port)
{
	while ((com_port->lsr & LSR_DR) == 0);
	return (com_port->rbr);
}

int NS16550_tstc (NS16550_t com_port)
{
	return ((com_port->lsr & LSR_DR) != 0);
}

