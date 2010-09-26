/**
 * @file system.c
 */

/*
 * (C) Copyright 2005
 * AMIRIX Systems Inc.
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

#include "system.h"

/**
 * Start of PBL.
 * This function calls 3 board specific functions before running the Monitor
 *  program that:
 *  - Initialize the board.
 *  - Prompts the user to choose the boot procedure.
 * Then if the Monitor program is to run:
 *  - Initialize the Monitor program.
 */
main()
{
    BoardInit();
#if defined(PRODUCTION)
    PromptUser();
#else
    printf("\n\n\nTest System\n");
#endif
    MonitorInit();
    Monitor();
}
