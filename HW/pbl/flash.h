/**
 * @file flash.h
 */

/*
 * (C) Copyright 2003
 * AMIRIX Systems Inc.
 *
 * Originated from ppcboot-2.0.0/include/flash.h
 *                 ppcboot-2.0.0/common/cmd_flash.h
 *
 * (C) Copyright 2000, 2001
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

#ifndef _FLASH_H_
#define _FLASH_H_

#include "monitor.h"

/**
 * FLASH Info: contains chip specific data, per FLASH bank
 */

typedef struct {
    ulong   size;           /* total bank size in bytes     */
    ushort  sector_count;       /* number of erase units        */
    ulong   flash_id;       /* combined device & manufacturer code  */
    ulong   start[CFG_MAX_FLASH_SECT];   /* physical sector start addresses */
    uchar   protect[CFG_MAX_FLASH_SECT]; /* sector protection status    */
#ifdef CFG_FLASH_CFI
    uchar   portwidth;      /* the width of the port        */
    uchar   chipwidth;      /* the width of the chip        */
    ushort  buffer_size;        /* # of bytes in write buffer       */
    ulong   erase_blk_tout;     /* maximum block erase timeout      */
    ulong   write_tout;     /* maximum write timeout        */
    ulong   buffer_write_tout;  /* maximum buffer write timeout     */

#endif
} flash_info_t;

/**
 * Values for the width of the port
 */
#define FLASH_CFI_8BIT      0x01
#define FLASH_CFI_16BIT     0x02
#define FLASH_CFI_32BIT     0x04
#define FLASH_CFI_64BIT     0x08

/**
 * Values for the width of the chip
 */
#define FLASH_CFI_BY8       0x01
#define FLASH_CFI_BY16      0x02
#define FLASH_CFI_BY32      0x04
#define FLASH_CFI_BY64      0x08

#define FLASH_UNKNOWN   0xFFFF          /* unknown flash type                   */

/* Prototypes */

extern unsigned long flash_init (void);
extern void flash_print_info (flash_info_t *);
extern int flash_erase  (flash_info_t *, int, int);
extern int flash_sect_erase (ulong addr_first, ulong addr_last);
extern int flash_sect_protect (int flag, ulong addr_first, ulong addr_last);

extern void flash_protect (int flag, ulong from, ulong to, flash_info_t *info);
extern int flash_write (uchar *, ulong, ulong);
extern flash_info_t *addr2info (ulong);
extern int write_buff (flash_info_t *info, uchar *src, ulong addr, ulong cnt);

#if defined(CFG_FLASH_PROTECTION)
extern int flash_real_protect(flash_info_t *info, long sector, int prot);
#endif  /* CFG_FLASH_PROTECTION */

/**
 * return codes from flash_write():
 */
#define ERR_OK              0
#define ERR_TIMOUT          1
#define ERR_NOT_ERASED          2
#define ERR_PROTECTED           4
#define ERR_INVAL           8
#define ERR_ALIGN           16
#define ERR_UNKNOWN_FLASH_VENDOR    32
#define ERR_UNKNOWN_FLASH_TYPE      64
#define ERR_PROG_ERROR          128

/**
 * Protection Flags for flash_protect():
 */
#define FLAG_PROTECT_SET    0x01
#define FLAG_PROTECT_CLEAR  0x02

#define CMD_TBL_FLINFO  MK_CMD_TBL_ENTRY(                                       \
        "flinfo",       3,      2,      1,      do_flinfo,                      \
        "flinfo  - print FLASH memory information\n",                           \
        "\n    - print information for all FLASH memory banks\n"                \
        "flinfo N\n    - print information for FLASH memory bank # N\n"         \
),

#define CMD_TBL_FLERASE MK_CMD_TBL_ENTRY(                                       \
        "erase",        3,      3,      0,      do_flerase,                     \
        "erase   - erase FLASH memory\n",                                       \
        "start end\n"                                                           \
        "    - erase FLASH from addr 'start' to addr 'end'\n"                   \
        "erase N:SF[-SL]\n    - erase sectors SF-SL in FLASH bank # N\n"        \
        "erase bank N\n    - erase FLASH bank # N\n"                            \
        "erase all\n    - erase all FLASH banks\n"                              \
),

#define CMD_TBL_PROTECT MK_CMD_TBL_ENTRY(                                       \
        "protect",      4,      4,      0,      do_protect,                     \
        "protect - enable or disable FLASH write protection\n",                 \
        "on  start end\n"                                                       \
        "    - protect FLASH from addr 'start' to addr 'end'\n"                 \
        "protect on  N:SF[-SL]\n"                                               \
        "    - protect sectors SF-SL in FLASH bank # N\n"                       \
        "protect on  bank N\n    - protect FLASH bank # N\n"                    \
        "protect on  all\n    - protect all FLASH banks\n"                      \
        "protect off start end\n"                                               \
        "    - make FLASH from addr 'start' to addr 'end' writable\n"           \
        "protect off N:SF[-SL]\n"                                               \
        "    - make sectors SF-SL writable in FLASH bank # N\n"                 \
        "protect off bank N\n    - make FLASH bank # N writable\n"              \
        "protect off all\n    - make all FLASH banks writable\n"                \
),

int do_flinfo (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_flerase(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
int do_protect(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);





#endif /* _FLASH_H_ */
