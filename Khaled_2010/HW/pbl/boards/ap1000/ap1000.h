/**
 * @file ap1000.h Board specific header for the AP1000 board.
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

#ifndef AP1000_H
#define AP1000_H

int BoardInit(void);
int PromptUser(void);
int MonitorInit(void);

#define udelay(x) usleep(x)

#define get_timer(x) (0)
#define disable_interrupts() (0)
#define enable_interrupts() (0)
#define ctrlc() (0)
#define WATCHDOG_RESET()
#define had_ctrlc() (0)
#define clear_ctrlc()

/* config stuff */
#define CFG_MAX_FLASH_BANKS     2
#define CFG_MAX_FLASH_SECT      128
#define CFG_FLASH_CFI           1
#define CFG_FLASH_PROTECTION
#define CFG_FLASH_USE_BUFFER_WRITE

#define CFG_UBOOT_IMAGE_BASE  0x08000000
#define CFG_UBOOT_RUN_BASE    0x08000100
#define CFG_UBOOT_IMAGE_SIZE  0x00040000 /* 256k */

#define CFG_NS16550_REG_SIZE    4

#define CFG_CBSIZE              256
#define CFG_MAXARGS             16
#define CFG_NS16550_CLK         40000000
#define CFG_BAUD                57600
#define CFG_LONGHELP            1

/* Monitor Command Prompt */
#define CFG_PROMPT      "-> "

#define CFG_CBSIZE      256             /* Console I/O Buffer Size      */
#define CFG_PBSIZE (CFG_CBSIZE+sizeof(CFG_PROMPT)+16) /* Print Buffer Size */

#define CFG_CACHELINE_SIZE  32

#define CFG_PCI_PCI_BRIDGE_DEV_ID   0x05

#define CFG_LOAD_ADDR       0x00100000


/* board info stuff */

#define CFG_PROGFLASH_BASE  0x20000000
#define CFG_CONFFLASH_BASE  0x24000000

#define SYSACE_BASEADDR         0x28000000
#define CPLD_BASEADDR           0x26000000
#define CPLD_SW_RECONFIGURE     0x01

/* Base address of PowerSpan II, dual PCI bridge chip */
#define PSPAN_BASEADDR  0x30000000

/** Default contents for PowerSpan II configuration eeprom. */
#define EEPROM_DEFAULT { 0x01,       /* Byte 0 - Long Load = 0x02, short = 01, use 0xff for try no load */  \
						0x0,0x0,0x0, /* Bytes 1 - 3 Power span reserved */ \
						0x0,         /* Byte 4 - Powerspan reserved  - start of short load */ \
						0x0F,        /* Byte 5 - Enable PCI 1 & 2 as Bus masters and Memory targets. */ \
						0x0E,        /* Byte 6 - PCI 1 Target image prefetch - on for image 0,1,2, off for i20 & 3. */ \
						0x00, 0x00,  /* Byte 7,8 - PCI-1 Subsystem ID - */ \
						0x00, 0x00,  /* Byte 9,10 - PCI-1 Subsystem Vendor Id -  */ \
						0x00,		 /* Byte 11 - No PCI interrupt generation on PCI-1 PCI-2 int A */ \
						0x1F,		 /* Byte 12 - PCI-1 enable bridge registers, all target images */ \
						0xBA,		 /* Byte 13 - Target 0 image 128 Meg(Ram), Target 1 image 64 Meg. (config Flash/CPLD )*/ \
						0xA0,		 /* Byte 14 - Target 2 image 64 Meg(program Flash), target 3 64k. */ \
						0x00,		 /* Byte 15 - Vital Product Data Disabled. */ \
						0x88,		 /* Byte 16 - PCI arbiter config complete, all requests routed through PCI-1, Unlock PCI-1  */ \
						0x40,		 /* Byte 17 - Interrupt direction control - PCI-1 Int A out, everything else in. */ \
						0x00,		 /* Byte 18 - I2O disabled */ \
						0x00,		 /* Byte 19 - PCI-2 Target image prefetch - off for all images. */ \
						0x00,0x00,	 /* Bytes 20,21 - PCI 2 Subsystem Id */ \
						0x00,0x00,	 /* Bytes 22,23 - PCI 2 Subsystem Vendor id */ \
						0x0C,		 /* Byte 24 - PCI-2 BAR enables, target image 0, & 1 */ \
                        0xBB,        /* Byte 25 - PCI-2 target 0 - 128 Meg(Ram), target 1  - 128 Meg (program/config flash) */ \
						0x00,		 /* Byte 26 - PCI-2 target 2 & 3 unused. */ \
						0x00,0x00,0x00,0x00,0x00, /* Bytes 27,28,29,30, 31 - Reserved */ \
						/* Long Load Information */ \
						0x82,0x60,	 /* Bytes 32,33 - PCI-1 Device ID - Powerspan II */ \
						0x10,0xE3,	 /* Bytes 24,35 - PCI-1 Vendor ID - Tundra */ \
						0x06,		 /* Byte 36 - PCI-1 Class Base - Bridge device. */ \
						0x80,		 /* Byte 37 - PCI-1 Class sub class - Other bridge. */ \
						0x00,		 /* Byte 38 - PCI-1 Class programing interface - Other bridge */ \
						0x01,		 /* Byte 39 - Power span revision 1. */ \
						0x6E,		 /* Byte 40 - PB SI0 enabled, translation enabled, decode enabled, 64 Meg */ \
						0x40,		 /* Byte 41 - PB SI0 memory command mode, PCI-1 dest */ \
						0x22,		 /* Byte 42 - Prefetch discard after read, PCI-little endian conversion, 32 byte prefetch */ \
						0x00,0x00,	 /* Bytes 43, 44 - Translation address for SI0, set to zero for now. */ \
						0x0E,		 /* Byte 45 - Translation address (0) and PB bus master enables - all. */ \
						0x2c,00,00,  /* Bytes 46,47,48 - PB SI0 processor base address - 0x2C000000 */ \
						0x30,00,00,  /* Bytes 49,50,51 - PB Address for Powerspan registers - 0x30000000, big Endian */ \
						0x82,0x60,	 /* Bytes 52, 53 - PCI-2 Device ID - Powerspan II */ \
						0x10,0xE3,	 /* Bytes 54,55 - PCI 2 Vendor Id - Tundra */ \
						0x06,		 /* Byte 56 - PCI-2 Class Base - Bridge device */ \
						0x80,		 /* Byte 57 - PCI-2 Class sub class - Other Bridge. */ \
						0x00,		 /* Byte 58 - PCI-2 class programming interface - Other bridge */ \
						0x01,		 /* Byte 59 - PCI-2 class revision  1 */ \
						0x00,0x00,0x00,0x00 }; /* Bytes 60,61, 62, 63 - Powerspan reserved */


#define EEPROM_SIZE		64	/* Long Load */

#define PSII_SYNC() asm("eieio")

#define XPAR_SDRAM_0_BASEADDR 0x00000000	/**< Processor local bus address for start of SDRAM */
#define XPAR_SDRAM_0_HIGHADDR 0x07FFFFFF	/**< Processor local bus upper address for end of SDRAM */

#if !defined(PRODUCTION)
#define DEFAULT_DRAM_SIZE     0x08000000    /**< AP1000 board has 128 MB RAM in test */
#else
#define DEFAULT_DRAM_SIZE     0x04000000    /**< AP1000 board has 128 MB RAM in baseline */
#endif

#define PCI_MEM_BASE                0x32000000	/**< Start Mapping PCI-2 memory devices at this location. */
#define PCI_IO_BASE                 0x31000000	/**< Start Mapping PCI-2 io devices at this location. */

#define MAX_BRIDGE_RETRIES          10000
#define BRIDGE_RETRY_DELAY          100

/* include after CFG defines */
#include "monitor.h"

int InitPowerSpan();

int do_uboot(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);

#define SYNC() asm("eieio")

/**
 * PBL command that attempts to load U-Boot from program flash.
 */
#define CMD_TBL_UBOOT   MK_CMD_TBL_ENTRY(                   \
        "uboot",        3,      1,      0,      do_uboot,   \
        "uboot   - attempt to boot u-boot from flash\n",    \
        "uboot   - attempt to boot u-boot from flash\n"     \
),

/** List of available PBL commands. */
#if !defined(PRODUCTION)
#define BOARD_CMD_TABLE \
    CMD_TBL_ACETEST     \
    CMD_TBL_AUTOTEST_CMD\
    CMD_TBL_BASE        \
    CMD_TBL_CMP         \
    CMD_TBL_CP          \
    CMD_TBL_EEPROM      \
    CMD_TBL_FLERASE     \
    CMD_TBL_ETHTEST     \
    CMD_TBL_FLINFO      \
    CMD_TBL_GO          \
    CMD_TBL_GPIOTEST    \
    CMD_TBL_HELP        \
    CMD_TBL_HOSTTEST    \
    CMD_TBL_INT_CMD     \
    CMD_TBL_INTTEST_CMD \
    CMD_TBL_KINIT       \
    CMD_TBL_LOADB       \
    CMD_TBL_LOOP        \
    CMD_TBL_MD          \
    CMD_TBL_MM          \
    CMD_TBL_MTEST       \
    CMD_TBL_MW          \
    CMD_TBL_NM          \
    CMD_TBL_PCIINIT     \
    CMD_TBL_PCISCAN     \
    CMD_TBL_PROTECT     \
    CMD_TBL_READCFG     \
    CMD_TBL_SWCONFIG    \
    CMD_TBL_SWRECONFIG  \
    CMD_TBL_SENSOR      \
    CMD_TBL_UBOOT       \
    CMD_TBL_SETVERB     \
    CMD_TBL_WRITECFG

#else
#define BOARD_CMD_TABLE \
    CMD_TBL_BASE        \
    CMD_TBL_CMP         \
    CMD_TBL_CP          \
    CMD_TBL_FLERASE     \
    CMD_TBL_FLINFO      \
    CMD_TBL_PROTECT     \
    CMD_TBL_GO          \
    CMD_TBL_HELP        \
    CMD_TBL_LOADB       \
    CMD_TBL_LOOP        \
    CMD_TBL_MD          \
    CMD_TBL_MM          \
    CMD_TBL_MTEST       \
    CMD_TBL_MW          \
    CMD_TBL_NM          \
    CMD_TBL_UBOOT

#define AUTOBOOT_PROMPT         "\nAutobooting U-Boot in %d seconds.\nPress SPACE to load PBL, or 'U' to load U-Boot.\n"
#define TEST_AUTOBOOT_PROMPT    "\nRunning tests in %d seconds, press SPACE to stop\n"

#endif /* !defined(PRODUCTION) */

#define XPAR_OPB_UART16550_I2_BASEADDR 0x10

#define PHYSICAL_UART0          0x4C001000
#define PHYSICAL_UART0_INDEX    0

#endif
