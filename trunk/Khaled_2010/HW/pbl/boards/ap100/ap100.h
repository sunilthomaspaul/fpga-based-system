/**
 * @file ap100.h Board specific header for the AP100.
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

#ifndef AP100_H
#define AP100_H

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
#define CFG_MAX_FLASH_SECT      32
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

#define UART_ADDRESS (XPAR_OPB_UART16550_I_BASEADDR + 0x1000)

/* board info stuff */

#define CFG_PROGFLASH_BASE  0x20000000
#define CFG_CONFFLASH_BASE  0x24000000

#define SYSACE_BASEADDR         0x28000000
#define CPLD_BASEADDR           0x26000000
#define CPLD_SW_RECONFIGURE     0x01

/* FRACK */
#define XPAR_SDRAM_0_BASEADDR 0x00000000
#define XPAR_SDRAM_0_HIGHADDR 0x07FFFFFF
#define DEFAULT_DRAM_SIZE 0x04000000 /**< AP100 has 64 MB RAM */

#define PLX_BASE_ADDRESS            0x2A000000
#define PLX_LOCAL_MRANGE            0xFFC00000
#define PCI_MEM_BASE                0x30000000
#define PCI_IO_BASE                 0x40000000
#define CONFIG_RANGE                0xFC000000 /* 64 MB */
#define DRAM_RANGE                  0xF8000000 /* 128 MB */
#define PLX_DRAM_BASE               0x00000000
#define PLX_CONFIG_BASE             0x24000000
#define PCI_DRAM_BASE               0x00000000
#define PCI_CONFIG_BASE             0x18000000
#define PCI_MEM_21555_CSR_BASE      0x30100000
#define PCI_IO_21555_CSR_BASE       0x40000100
#define PCI_DISABLED_BAR            0x00000000
#define INTEL_BRIDGE_PRELOAD_ENABLE 0x01
#define IO_RANGE_256B               0xFFFFFF01
#define MEM_RANGE_1MB               0xFFF00000
#define PCI_BUS_LATENCY             32

#define PLX_STATUS_NO_TARGET        0x7000
#define PLX_LOCAL_DECODE_ENABLE     0x00000001
#define PLX_256_RETRIES             0x00001000
#define PLX_ENABLE_READ_AHEAD       0x10000000
#define PLX_READY_BIT               0x04

#define MAX_BRIDGE_RETRIES          10000
#define BRIDGE_RETRY_DELAY          100

/* include after CFG defines */
#include "monitor.h"

int init_pci_to_pci_bridge(int device_id);
int init_local_to_pci_bridge();
int pci_initdevice(int bus, int dev, int fn);
int do_uboot(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);

#define SYNC() asm("eieio")

/**
 * uboot command
 */
#define CMD_TBL_UBOOT   MK_CMD_TBL_ENTRY(                   \
        "uboot",        1,      1,      0,      do_uboot,   \
        "uboot   - attempt to boot u-boot from flash\n",    \
        "uboot   - attempt to boot u-boot from flash\n"     \
),

#if !defined(PRODUCTION)
    #define AP100_TEST_CMDS \
        CMD_TBL_SETVERB     \
        CMD_TBL_SIOTEST     \
        CMD_TBL_ACETEST     \
        CMD_TBL_PCIINIT     \
        CMD_TBL_PCISCAN     \
        CMD_TBL_READCFG     \
        CMD_TBL_WRITECFG    \
        CMD_TBL_PROGSROM    \
        CMD_TBL_ETHTEST     \
        CMD_TBL_INTTEST_CMD

    #if 0 /* space */
        CMD_TBL_INT_CMD
        CMD_TBL_ACE_CMD
    #endif /* space */
#else
    #define AP100_TEST_CMDS
#endif /* !defined(PRODUCTION) */

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
    CMD_TBL_UBOOT       \
    AP100_TEST_CMDS


#define TEST_AUTOBOOT_PROMPT    "\nRunning tests in %d seconds, press SPACE to stop\n"
#define AUTOBOOT_PROMPT         "\nAutobooting U-Boot in %d seconds.\nPress SPACE to load PBL, or 'U' to load U-Boot.\n"


#endif