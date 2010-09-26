/**
 * @file sdram.c
 */

/*
 * (C) Copyright 2003
 * AMIRIX Systems Inc.
 *
 * Originated from ppcboot-2.0.0/common/cmd_mem.c
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
#include "sleep.h"
//#include "serial.h"



/**
 * Probe for DRAM size.
 * Check memory range for valid RAM. A simple memory test determines
 * the actually available RAM size between addresses `base' and
 * `base + maxsize'. Some (not all) hardware errors are detected:
 * - short between address lines
 * - short between data lines
 * From PPCBoot 2.0.0
 */

static long int
dram_size(long int *base, long int maxsize)
{
    volatile long int *addr;
    unsigned long   cnt, val;
    unsigned long   save[32];   /* to make test non-destructive */
    unsigned char   i = 0;

    for (cnt = maxsize / sizeof(long); cnt > 0; cnt >>= 1)
    {
        addr = base + cnt;      /* pointer arith! */

        save[i++] = *addr;
        *addr = ~cnt;
    }

    /* write 0 to base address */
    addr = base;
    save[i] = *addr;
    *addr = 0;

    /* check at base address */
    if ((val = *addr) != 0)
    {
        *addr = save[i];
        return (0);
    }

    for (cnt = 1; cnt <= maxsize / sizeof(long); cnt <<= 1)
    {
        addr = base + cnt;      /* pointer arith! */

        val = *addr;
        *addr = save[--i];

        if (val != (~cnt))
        {
            return (cnt * sizeof(long));
        }
    }
    return (maxsize);
}



main() {
    long int sdram_base_addr = 0x00000000;
    long int sdram_max_size = 0x0FFFFFFF;
    unsigned int sleep_time = 4;
    static long int size;


      usleep(sleep_time);

//  	size = dram_size(&sdram_base_addr, sdram_max_size);
}
