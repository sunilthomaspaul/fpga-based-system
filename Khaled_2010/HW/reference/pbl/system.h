/**
 * @file system.h
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

#ifndef SYSTEM_H
#define SYSTEM_H

typedef unsigned char           uchar;
typedef unsigned short          ushort;
typedef unsigned int            uint;
typedef unsigned long           ulong;
typedef volatile unsigned long  vu_long;
typedef unsigned int            size_t;


#ifdef AP100
#include "ap100/ap100.h"
#endif

#ifdef AP1000
#include "ap1000/ap1000.h"
#include "ap1000/powerspan.h"
#endif

/* User Prompting stuff */
#define IH_MAGIC_WORD_1 0x2705  /* Image Magic Number */
#define IH_MAGIC_WORD_2 0x1956

#define MAX_BOOT_WAIT     30    /* in tenths of a second */
#define TENTH_OF_A_SECOND 100000

#define UBOOT_SELECTED 0
#define PBL_SELECTED   1

#define UBOOT_SELECTED_BANNER "Running U-Boot...\n"
#define NO_UBOOT_BANNER       "U-Boot not present, running PBL...\n"
#define PBL_SELECTED_BANNER   "Running PBL...\n"

#define PBL_BANNER_TEXT "Amirix PBL (" __TIME__ " on "__DATE__ ")\n"

#endif
