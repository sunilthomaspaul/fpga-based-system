/**
 * @file board.c Source for board specific code.
 *
 * In order to keep a standard list of files to build, this file #includes the
 *  board specific .c files.  While somewhat messy, this eliminates the need of
 *  macros, overly large source files with massive ifdef conditional code, or
 *  the alteration of any of the platform system files.
 *
 * After including the header files, #ifdefs are used to #include the platform-
 *  appropriate source files.
 *
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
#include "monitor.h"
#include "serial.h"
#include "loadb.h"
#include "mem.h"
#include "flash.h"
#include "tests.h"

#ifdef AP100
#include "boards/ap100/ap100.c"
#include "boards/ap100/ap100_tests.c"
#endif

#ifdef AP1000
#include "boards/ap1000/powerspan.c"
#include "boards/ap1000/ap1000.c"
#include "boards/ap1000/ap1000_tests.c"
#endif
