/**
 * @file mem.c
 */

/*
 * (C) Copyright 2003
 * AMIRIX Systems Inc.
 *
 * Originated from ppcboot-2.0.0/common/cmd_mem.c
 *
 * (C) Copyright 2000
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
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

/*
 * Memory Functions
 *
 * Copied from FADS ROM, Dan Malek (dmalek@jlc.net)
 */

#include "system.h"
#include "monitor.h"
#include "serial.h"

unsigned int dram_size = DEFAULT_DRAM_SIZE;

int cmd_get_data_size(char* arg, int default_size)
{
    /* Check for a size specification .b, .w or .l.
     */
    int len = strlen(arg);
    if (len > 2 && arg[len-2] == '.') {
        switch(arg[len-1]) {
        case 'b':
            return 1;
        case 'w':
            return 2;
        case 'l':
            return 4;
        }
    }
    return default_size;
}


#ifdef  CMD_MEM_DEBUG
#define PRINTF(fmt,args...) printf (fmt ,##args)
#else
#define PRINTF(fmt,args...)
#endif

static int mod_mem(cmd_tbl_t *, int, int, int, char *[]);

/* Display values from last command.
 * Memory modify remembered values are different from display memory.
 */
uint    dp_last_addr, dp_last_size;
uint    dp_last_length = 0x40;
uint    mm_last_addr, mm_last_size;

static  ulong   base_address = 0;

/* Memory Display
 *
 * Syntax:
 *  md{.b, .w, .l} {addr} {len}
 */
#define DISP_LINE_LEN   16
int do_mem_md ( cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    ulong   addr, size, length;
    ulong   i, nbytes, linebytes;
    uchar   *cp;
    int rc = 0;

    /* We use the last specified parameters, unless new ones are
     * entered.
     */
    addr = dp_last_addr;
    size = dp_last_size;
    length = dp_last_length;

    if (argc < 2) {
        printf ("Usage:\n%s\n", cmdtp->usage);
        return 1;
    }

    if ((flag & CMD_FLAG_REPEAT) == 0) {
        /* New command specified.  Check for a size specification.
         * Defaults to long if no or incorrect specification.
         */
        size = cmd_get_data_size(argv[0], 4);

        /* Address is specified since argc > 1
        */
        addr = simple_strtoul(argv[1], NULL, 16);
        addr += base_address;

        /* If another parameter, it is the length to display.
         * Length is the number of objects, not number of bytes.
         */
        if (argc > 2)
            length = simple_strtoul(argv[2], NULL, 16);
    }

    /* Print the lines.
     *
     * We buffer all read data, so we can make sure data is read only
     * once, and all accesses are with the specified bus width.
     */


    nbytes = length * size;
    do {
        char    linebuf[DISP_LINE_LEN];
        uint    *uip = (uint   *)linebuf;
        ushort  *usp = (ushort *)linebuf;
        uchar   *ucp = (uchar *)linebuf;

        printf("%08lx:", addr);
        linebytes = (nbytes>DISP_LINE_LEN)?DISP_LINE_LEN:nbytes;
        for (i=0; i<linebytes; i+= size) {
            if (size == 4) {
                printf(" %08x", (*uip++ = *((uint *)addr)));
            } else if (size == 2) {
                printf(" %04x", (*usp++ = *((ushort *)addr)));
            } else {
                printf(" %02x", (*ucp++ = *((uchar *)addr)));
            }
            addr += size;
        }
        printf("    ");
        cp = linebuf;
        for (i=0; i<linebytes; i++) {
            if ((*cp < 0x20) || (*cp > 0x7e))
                printf(".");
            else
                printf("%c", *cp);
            cp++;
        }
        printf("\n");
        nbytes -= linebytes;
        if (ctrlc()) {
            rc = 1;
            break;
        }
    } while (nbytes > 0);


    dp_last_addr = addr;
    dp_last_length = length;
    dp_last_size = size;
    return (rc);
}

int do_mem_mm ( cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    return mod_mem (cmdtp, 1, flag, argc, argv);
}
int do_mem_nm ( cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    return mod_mem (cmdtp, 0, flag, argc, argv);
}

int do_mem_mw ( cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    ulong   addr, size, writeval, count;

    if ((argc < 3) || (argc > 4)) {
        printf ("Usage:\n%s\n", cmdtp->usage);
        return 1;
    }

    /* Check for size specification.
    */
    size = cmd_get_data_size(argv[0], 4);

    /* Address is specified since argc > 1
    */
    addr = simple_strtoul(argv[1], NULL, 16);
    addr += base_address;

    if (addr2info(addr) != NULL){
        printf("memory write does not work on flash...\n");
        return 1;
    }

    /* Get the value to write.
    */
    writeval = simple_strtoul(argv[2], NULL, 16);

    /* Count ? */
    if (argc == 4) {
        count = simple_strtoul(argv[3], NULL, 16);
    } else {
        count = 1;
    }

    while (count-- > 0) {
        if (size == 4)
            *((ulong  *)addr) = (ulong )writeval;
        else if (size == 2)
            *((ushort *)addr) = (ushort)writeval;
        else
            *((uchar *)addr) = (uchar)writeval;
        addr += size;
    }
    return 0;
}

int do_mem_cmp (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    ulong   size, addr1, addr2, count, ngood;
    int     rcode = 0;

    if (argc != 4) {
        printf ("Usage:\n%s\n", cmdtp->usage);
        return 1;
    }

    /* Check for size specification.
    */
    size = cmd_get_data_size(argv[0], 4);

    addr1 = simple_strtoul(argv[1], NULL, 16);
    addr1 += base_address;

    addr2 = simple_strtoul(argv[2], NULL, 16);
    addr2 += base_address;

    count = simple_strtoul(argv[3], NULL, 16);

    ngood = 0;

    while (count-- > 0) {
        if (size == 4) {
            ulong word1 = *(ulong *)addr1;
            ulong word2 = *(ulong *)addr2;
            if (word1 != word2) {
                printf("word at 0x%08lx (0x%08lx) "
                    "!= word at 0x%08lx (0x%08lx)\n",
                    addr1, word1, addr2, word2);
                rcode = 1;
                break;
            }
        }
        else if (size == 2) {
            ushort hword1 = *(ushort *)addr1;
            ushort hword2 = *(ushort *)addr2;
            if (hword1 != hword2) {
                printf("halfword at 0x%08lx (0x%04x) "
                    "!= halfword at 0x%08lx (0x%04x)\n",
                    addr1, hword1, addr2, hword2);
                rcode = 1;
                break;
            }
        }
        else {
            uchar byte1 = *(uchar *)addr1;
            uchar byte2 = *(uchar *)addr2;
            if (byte1 != byte2) {
                printf("byte at 0x%08lx (0x%02x) "
                    "!= byte at 0x%08lx (0x%02x)\n",
                    addr1, byte1, addr2, byte2);
                rcode = 1;
                break;
            }
        }
        ngood++;
        addr1 += size;
        addr2 += size;
    }


    printf("Total of %ld %s%s were the same\n",
        ngood, size == 4 ? "word" : size == 2 ? "halfword" : "byte",
        ngood == 1 ? "" : "s");
    return rcode;
}

int do_mem_cp ( cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    ulong   addr, size, dest, count;

    if (argc != 4) {
        printf ("Usage:\n%s\n", cmdtp->usage);
        return 1;
    }

    /* Check for size specification.
    */
    size = cmd_get_data_size(argv[0], 4);

    addr = simple_strtoul(argv[1], NULL, 16);
    addr += base_address;

    dest = simple_strtoul(argv[2], NULL, 16);
    dest += base_address;

    count = simple_strtoul(argv[3], NULL, 16);

    if (count == 0) {
        serial_puts ("Zero length ???\n");
        return 1;
    }

#ifndef CFG_NO_FLASH
    /* check if we are copying to Flash */
    if (addr2info(dest) != NULL) {
        int rc;

        printf ("Copy to Flash... ");

        rc = flash_write ((uchar *)addr, dest, count*size);
        if (rc != 0) {
            flash_perror (rc);
            return (1);
        }
        serial_puts ("done\n");
        return 0;
    }
#endif /* #ifndef CFG_NO_FLASH */

    while (count-- > 0) {
        if (size == 4)
            *((ulong  *)dest) = *((ulong  *)addr);
        else if (size == 2)
            *((ushort *)dest) = *((ushort *)addr);
        else
            *((uchar *)dest) = *((uchar *)addr);
        addr += size;
        dest += size;
    }
    return 0;
}

int do_mem_base (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    if (argc > 1) {
        /* Set new base address.
        */
        base_address = simple_strtoul(argv[1], NULL, 16);
    }
    /* Print the current base address.
    */
    printf("Base Address: 0x%08lx\n", base_address);
    return 0;
}

int do_mem_loop (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    ulong   addr, size, length, i, junk;
    volatile uint   *longp;
    volatile ushort *shortp;
    volatile uchar  *cp;

    if (argc < 3) {
        printf ("Usage:\n%s\n", cmdtp->usage);
        return 1;
    }

    /* Check for a size spefication.
     * Defaults to long if no or incorrect specification.
     */
    size = cmd_get_data_size(argv[0], 4);

    /* Address is always specified.
    */
    addr = simple_strtoul(argv[1], NULL, 16);

    /* Length is the number of objects, not number of bytes.
    */
    length = simple_strtoul(argv[2], NULL, 16);


    /* We want to optimize the loops to run as fast as possible.
     * If we have only one object, just run infinite loops.
     */
    if (length == 1) {
        if (size == 4) {
            longp = (uint *)addr;
            for (;;)
                i = *longp;
        }
        if (size == 2) {
            shortp = (ushort *)addr;
            for (;;)
                i = *shortp;
        }
        cp = (uchar *)addr;
        for (;;)
            i = *cp;
    }

    if (size == 4) {
        for (;;) {
            longp = (uint *)addr;
            i = length;
            while (i-- > 0)
                junk = *longp++;
        }
    }
    if (size == 2) {
        for (;;) {
            shortp = (ushort *)addr;
            i = length;
            while (i-- > 0)
                junk = *shortp++;
        }
    }
    for (;;) {
        cp = (uchar *)addr;
        i = length;
        while (i-- > 0)
            junk = *cp++;
    }


}

/*
 * Perform a memory test.
 * The complete test loops until
 * interrupted by ctrl-c or by a failure of one of the sub-tests.
 */
int do_mem_mtest (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    int iterations = 0;
    char input_char;
    unsigned int start, end, pattern;
    int errors = 0;
    int abort = 0;

    if (argc > 1) {
        start = simple_strtoul(argv[1], NULL, 16);
    } else {
        start = 0;
    }

    if (argc > 2) {
        end = simple_strtoul(argv[2], NULL, 16);
    } else {
        end = DEFAULT_DRAM_SIZE - 1;
    }

    if (argc > 3) {
        pattern = simple_strtoul(argv[3], NULL, 16);
    } else {
        pattern = 0;
    }

    if (addr2info(start) != NULL){
        printf("mtest does not work on flash...\n");
        return 1;
    }


    printf ("Testing %08x ... %08x:\n", start, end);
    PRINTF("%s:%d: start 0x%p end 0x%p\n",
        __FUNCTION__, __LINE__, start, end);

    while(abort == 0){
        iterations++;
        printf("\bIteration: %6d\n", iterations);

        if(memtest(start, end, pattern, 1) != 0){
            printf("\nIteration %d failed.\n", iterations);
            errors = 1;
            return 0;
        }

        /* check for quit */
        printf("Press 'q' to abort, or any other key for another iteration.\n");
        if(tolower(serial_getc()) == 'q'){
            abort = 1;
        }
    }

    return 0;
}

int memtest(unsigned int start_address, unsigned int end_address, unsigned int a_pattern, int progress_flag){
    vu_long *addr, *start, *end;
    ulong   readback;
    int j;
    int display_index;
    ulong   val;
    vu_long pattern;
    vu_long addr_mask;
    vu_long offset;
    vu_long test_offset;
    vu_long temp;
    vu_long anti_pattern;
    vu_long num_words;
    vu_long *dummy = (vu_long *)0x00040000;

    static const ulong bitpattern[] = {
        0x00000001, /* single bit */
        0x00000003, /* two adjacent bits */
        0x00000007, /* three adjacent bits */
        0x0000000F, /* four adjacent bits */
        0x00000005, /* two non-adjacent bits */
        0x00000015, /* three non-adjacent bits */
        0x00000055, /* four non-adjacent bits */
        0xaaaaaaaa, /* alternating 1/0 */
    };

    if(end_address < start_address){
        printf("ERROR: End is before Start\n");
        return -1;
    }

    start = (vu_long *)start_address;

    if(end_address == 0){
        end = (vu_long *)(dram_size -1);
    }
    else{
        end = (vu_long *)end_address;
    }

    pattern = a_pattern;

    /*
     * Data line test: write a pattern to the first
     * location, write the 1's complement to a 'parking'
     * address (changes the state of the data bus so a
     * floating bus doen't give a false OK), and then
     * read the value back. Note that we read it back
     * into a variable because the next time we read it,
     * it might be right (been there, tough to explain to
     * the quality guys why it prints a failure when the
     * "is" and "should be" are obviously the same in the
     * error message).
     *
     * Rather than exhaustively testing, we test some
     * patterns by shifting '1' bits through a field of
     * '0's and '0' bits through a field of '1's (i.e.
     * pattern and ~pattern).
     */
    addr = start;
    for (j = 0; j < sizeof(bitpattern)/sizeof(bitpattern[0]); j++) {
        val = bitpattern[j];
        for(; val != 0; val <<= 1) {
            *addr  = val;
            *dummy  = ~val; /* clear the test data off of the bus */
            readback = *addr;
            if(readback != val) {
                 printf ("FAILURE (data line): "
                         "expected %08lx, actual %08lx\n",
                         val, readback);
                 return 1;
            }
            *addr  = ~val;
            *dummy  = val;
            readback = *addr;
            if(readback != ~val) {
                printf ("FAILURE (data line): "
                        "Is %08lx, should be %08lx\n",
                        readback, ~val);
                return 1;
            }
        }
    }

    /*
     * Based on code whose Original Author and Copyright
     * information follows: Copyright (c) 1998 by Michael
     * Barr. This software is placed into the public
     * domain and may be used for any purpose. However,
     * this notice must not be changed or removed and no
     * warranty is either expressed or implied by its
     * publication or distribution.
     */

    /*
     * Address line test
     *
     * Description: Test the address bus wiring in a
     *              memory region by performing a walking
     *              1's test on the relevant bits of the
     *              address and checking for aliasing.
     *              This test will find single-bit
     *              address failures such as stuck -high,
     *              stuck-low, and shorted pins. The base
     *              address and size of the region are
     *              selected by the caller.
     *
     * Notes:   For best results, the selected base
     *              address should have enough LSB 0's to
     *              guarantee single address bit changes.
     *              For example, to test a 64-Kbyte
     *              region, select a base address on a
     *              64-Kbyte boundary. Also, select the
     *              region size as a power-of-two if at
     *              all possible.
     *
     * Returns:     0 if the test succeeds, 1 if the test fails.
     *
     * ## NOTE ##   Be sure to specify start and end
     *              addresses such that addr_mask has
     *              lots of bits set. For example an
     *              address range of 01000000 02000000 is
     *              bad while a range of 01000000
     *              01ffffff is perfect.
     */
    addr_mask = ((ulong)end - (ulong)start)/sizeof(vu_long);
    pattern = (vu_long) 0xaaaaaaaa;
    anti_pattern = (vu_long) 0x55555555;

    PRINTF("%s:%d: addr mask = 0x%.8lx\n",
        __FUNCTION__, __LINE__,
        addr_mask);
    /*
     * Write the default pattern at each of the
     * power-of-two offsets.
     */
    for (offset = 1; (offset & addr_mask) != 0; offset <<= 1) {
        start[offset] = pattern;
    }

    /*
     * Check for address bits stuck high.
     */
    test_offset = 0;
    start[test_offset] = anti_pattern;

    for (offset = 1; (offset & addr_mask) != 0; offset <<= 1) {
        temp = start[offset];
        if (temp != pattern) {
        printf ("\nFAILURE: Address bit stuck high @ 0x%.8lx:"
            " expected 0x%.8lx, actual 0x%.8lx\n",
            (ulong)&start[offset], pattern, temp);
        return 1;
        }
    }
    start[test_offset] = pattern;

    /*
     * Check for addr bits stuck low or shorted.
     */
    for (test_offset = 1; (test_offset & addr_mask) != 0; test_offset <<= 1) {
        start[test_offset] = anti_pattern;

        for (offset = 1; (offset & addr_mask) != 0; offset <<= 1) {
            temp = start[offset];
            if ((temp != pattern) && (offset != test_offset)) {
                printf ("\nFAILURE: Address bit stuck low or shorted @"
                " 0x%.8lx: expected 0x%.8lx, actual 0x%.8lx\n",
                (ulong)&start[offset], pattern, temp);
                return 1;
            }
        }
        start[test_offset] = pattern;
    }

    if(progress_flag){
        printf(".");
    }

    /*
     * Description: Test the integrity of a physical
     *      memory device by performing an
     *      increment/decrement test over the
     *      entire region. In the process every
     *      storage bit in the device is tested
     *      as a zero and a one. The base address
     *      and the size of the region are
     *      selected by the caller.
     *
     * Returns:     0 if the test succeeds, 1 if the test fails.
     */
    num_words = ((ulong)end - (ulong)start)/sizeof(vu_long) + 1;
    display_index = num_words / 30;

    /*
     * Fill memory with a known pattern.
     */
    for (pattern = 1, offset = 0; offset < num_words; pattern++, offset++) {
        start[offset] = pattern;

        if(progress_flag){
            if((offset % (display_index)) == 0){
                printf(".");
            }
        }
    }

    /*
     * Check each location and invert it for the second pass.
     */
    for (pattern = 1, offset = 0; offset < num_words; pattern++, offset++) {
        temp = start[offset];
        if (temp != pattern) {
            printf ("\nFAILURE (read/write) @ 0x%.8lx:"
                " expected 0x%.8lx, actual 0x%.8lx)\n",
                (ulong)&start[offset], pattern, temp);
            return 1;
        }

        anti_pattern = ~pattern;
        start[offset] = anti_pattern;

        if(progress_flag){
            if((offset % (display_index)) == 0){
                printf(".");
            }
        }
    }

    /*
     * Check each location for the inverted pattern and zero it.
     */
    for (pattern = 1, offset = 0; offset < num_words; pattern++, offset++) {
        anti_pattern = ~pattern;
        temp = start[offset];
        if (temp != anti_pattern) {
            printf ("\nFAILURE (read/write): @ 0x%.8lx:"
                " expected 0x%.8lx, actual 0x%.8lx)\n",
                (ulong)&start[offset], anti_pattern, temp);
            return 1;
        }
        start[offset] = 0;

        if(progress_flag){
            if((offset % (display_index)) == 0){
                printf(".");
            }
        }
    }

    if(progress_flag){
        printf("\n");
    }

    return 0;
}

/* Modify memory.
 *
 * Syntax:
 *  mm{.b, .w, .l} {addr}
 *  nm{.b, .w, .l} {addr}
 */
static int
mod_mem(cmd_tbl_t *cmdtp, int incrflag, int flag, int argc, char *argv[])
{
    ulong   addr, size, i;
    int nbytes;
    extern char console_buffer[];

    if (argc != 2) {
        printf ("Usage:\n%s\n", cmdtp->usage);
        return 1;
    }

#ifdef CONFIG_BOOT_RETRY_TIME
    reset_cmd_timeout();    /* got a good command to get here */
#endif
    /* We use the last specified parameters, unless new ones are
     * entered.
     */
    addr = mm_last_addr;
    size = mm_last_size;

    if ((flag & CMD_FLAG_REPEAT) == 0) {
        /* New command specified.  Check for a size specification.
         * Defaults to long if no or incorrect specification.
         */
        size = cmd_get_data_size(argv[0], 4);

        /* Address is specified since argc > 1
        */
        addr = simple_strtoul(argv[1], NULL, 16);
        addr += base_address;
    }

    if (addr2info(addr) != NULL){
        printf("memory modify does not work on flash...\n");
        return 1;
    }

    /* Print the address, followed by value.  Then accept input for
     * the next value.  A non-converted value exits.
     */
    do {
        printf("%08lx:", addr);
        if (size == 4)
            printf(" %08x", *((uint   *)addr));
        else if (size == 2)
            printf(" %04x", *((ushort *)addr));
        else
            printf(" %02x", *((uchar *)addr));

        nbytes = readline (" ? ");
        if (nbytes == 0 || (nbytes == 1 && console_buffer[0] == '-')) {
            /* <CR> pressed as only input, don't modify current
             * location and move to next. "-" pressed will go back.
             */
            if (incrflag)
                addr += nbytes ? -size : size;
            nbytes = 1;
#ifdef CONFIG_BOOT_RETRY_TIME
            reset_cmd_timeout(); /* good enough to not time out */
#endif
        }
#ifdef CONFIG_BOOT_RETRY_TIME
        else if (nbytes == -2) {
            break;  /* timed out, exit the command  */
        }
#endif
        else {
            char *endp;
            i = simple_strtoul(console_buffer, &endp, 16);
            nbytes = endp - console_buffer;
            if (nbytes) {
#ifdef CONFIG_BOOT_RETRY_TIME
                /* good enough to not time out
                 */
                reset_cmd_timeout();
#endif
                if (size == 4)
                    *((uint   *)addr) = i;
                else if (size == 2)
                    *((ushort *)addr) = i;
                else
                    *((uchar *)addr) = i;
                if (incrflag)
                    addr += size;
            }
        }
    } while (nbytes);

    mm_last_addr = addr;
    mm_last_size = size;
    return 0;
}
