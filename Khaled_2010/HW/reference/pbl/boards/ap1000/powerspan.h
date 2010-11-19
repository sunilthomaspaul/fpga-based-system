/**
 * @file powerspan.h Header file for PowerSpan II code.
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

#ifndef POWERSPAN_H
#define POWERSPAN_H

#define NO_DEVICE_FOUND     -1
#define ILLEGAL_REG_OFFSET  -2
#define I2C_BUSY            -3
#define I2C_ERR             -4

#define REG_P1_CSR          0x004
#define REG_P1_BSREG		0x014
#define REGS_P1_BST0        0x018
#define REGS_P1_BST1        0x01C
#define REGS_P1_BST2        0x020
#define REGS_P1_BST3        0x024
#define REGS_P1_HS_CSR      0x0E4
#define REG_P1_ERR_CSR      0x150
#define REG_P1_MISC_CSR     0x160
#define REG_P1_ARB_CTRL		0x164
#define REGS_P1_TGT_CSR     0x100
#define REGS_P1_TGT_TADDR   0x104
#define REGS_PB_SLAVE_CSR   0x200
#define REGS_PB_SLAVE_TADDR 0x204
#define REGS_PB_SLAVE_BADDR 0x208
#define REG_CONFIG_ADDRESS  0x290
#define REG_CONFIG_DATA     0x294
#define REG_PB_ERR_CSR      0x2B0
#define REG_PB_MISC_CSR     0x2C0
#define REG_DMA0_SRC_ADDR   0x304
#define REG_DMA0_DST_ADDR   0x30C
#define REG_DMA0_TCR        0x314
#define REG_DMA0_GCSR       0x320
#define REG_MISC_CSR        0x400
#define REG_I2C_CSR         0x408
#define REG_RESET_CSR       0x40C
#define REG_ISR0            0x410
#define REG_ISR1            0x414
#define REG_IER0            0x418
#define REG_IER1			0x41C
#define REG_MBOX_MAP        0x420
#define REG_DB_MAP			0x424
#define REG_HW_MAP          0x42C
#define REG_IMR_P1			0x430
#define REG_IMR_P2			0x434
#define REG_IMR_PB			0x438
#define REG_IMR2_PB			0x43C
#define REG_IMR_MISC		0x440
#define REG_IDR             0x444

/* Power Span control registers for Dual port Powerspan II */
#define REG_P2_CSR			0x804
#define REGS_P2_BST			0x818
#define REG_P2_ERR_CSR		0x950
#define REG_P2_MISC_CSR		0x960
#define REGS_P2_TGT_CSR		0x900
#define REGS_P2_TGT_TADDR	0x904
#define REG_P2_ARB_CTRL		0x964


#define CSR_MEMORY_SPACE_ENABLE 0x00000002
#define CSR_PCI_MASTER_ENABLE   0x00000004

#define P1_BST_OFF  0x04

#define PX_ERR_ERR_STATUS   0x01000000

#define PX_MISC_CSR_MAX_RETRY_MASK  0x00000F00
#define PX_MISC_CSR_MAX_RETRY       0x00000F00
#define PX_MISC_REG_BAR_ENABLE      0x00008000
#define PX_MISC_REG_MAC_ERROR		0x00000080
#define PB_MISC_TEA_ENABLE          0x00000010
#define PB_MISC_MAC_TEA             0x00000040
#define PB_MISC_ARTRY_EN			0x00000008

#define P1_TGT_IMAGE_OFF    0x010
#define PX_TGT_CSR_IMG_EN   0x80000000
#define PX_TGT_CSR_TA_EN    0x40000000
#define PX_TGT_CSR_BAR_EN   0x20000000
#define PX_TGT_CSR_MD_EN    0x10000000
#define PX_TGT_CSR_MODE     0x00800000
#define PX_TGT_CSR_DEST     0x00400000
#define PX_TGT_CSR_MEM_IO   0x00200000
#define PX_TGT_CSR_GBL      0x00080000
#define PX_TGT_CSR_CL       0x00040000
#define PX_TGT_CSR_PRKEEP   0x00000080

#define PX_TGT_CSR_BS_MASK      0x0F000000
#define PX_TGT_PCI2             0x00400000
#define PX_TGT_MEM_IO           0x00200000
#define PX_TGT_CSR_RTT_MASK     0x001F0000
#define PX_TGT_CSR_RTT_READ     0x000A0000
#define PX_TGT_CSR_WTT_MASK     0x00001F00
#define PX_TGT_CSR_WTT_WFLUSH   0x00000200
#define PX_TGT_CSR_END_MASK     0x00000060
#define PX_TGT_CSR_BIG_END      0x00000040
#define PX_TGT_CSR_TRUE_LEND    0x00000060
#define PX_TGT_CSR_RDAMT_MASK   0x00000007

#define PX_TGT_CSR_BS_128MB 0xB
#define PX_TGT_CSR_BS_64MB  0xA
#define PX_TGT_CSR_BS_32MB  0x9
#define PX_TGT_CSR_BS_16MB  0x8
#define PX_TGT_CSR_BS_64K   0x0

#define PX_TGT_USE_MEM_IO   1
#define PX_TGT_NOT_MEM_IO   0

#define PB_SLAVE_IMAGE_OFF  0x010
#define PB_SLAVE_CSR_IMG_EN 0x80000000
#define PB_SLAVE_CSR_TA_EN  0x40000000
#define PB_SLAVE_CSR_MD_EN  0x20000000
#define PB_SLAVE_CSR_MODE   0x00800000
#define PB_SLAVE_CSR_DEST   0x00400000
#define PB_SLAVE_CSR_MEM_IO 0x00200000
#define PB_SLAVE_CSR_PRKEEP 0x00000080

#define PB_SLAVE_CSR_BS_MASK    0x1F000000
#define PB_SLAVE_CSR_END_MASK   0x00000060
#define PB_SLAVE_CSR_BIG_END    0x00000040
#define PB_SLAVE_CSR_TRUE_LEND  0x00000060
#define PB_SLAVE_CSR_RDAMT_MASK 0x00000007

#define PB_SLAVE_USE_MEM_IO 1
#define PB_SLAVE_NOT_MEM_IO 0

/* Processor Bus Slave Image Block Size definitions. */
#define PB_SI_BS_4K         0x0
#define PB_SI_BS_1MB        0x8
#define PB_SI_BS_2MB		0x9
#define PB_SI_BS_4MB		0xA
#define PB_SI_BS_8MB		0xB
#define PB_SI_BS_16MB		0xC
#define PB_SI_BS_32MB		0xD
#define PB_SI_BS_64MB		0xE
#define PB_SI_BS_128MB		0xF
#define PB_SI_BS_256MB		0x10
#define PB_SI_BS_512MB		0x11

/* PCI_x Control Status register control bits. */
#define PX_CSR_R_MA			0x20000000	/**< Master Abort received on PCI_x, write 1 to clear */

/* DMAX Control Status register control bits. */
#define DMAX_GCSR_CLEAR_STATUS  0x00003f00
#define DMAX_GCSR_GO            0x80000000
#define DMAX_GCSR_DONE          0x00000100

#define MISC_CSR_PCI1_LOCK  0x00000080	 /**< Set = lock out PCI-1 bus. Write 1 to clear */
#define MISC_CSR_PCI2_LOCK	0x00000040	 /**< Set = lock out PCI-2 bus. Write 1 to clear */
#define MISC_CSR_BAR_EQ_0	0x00000800	 /**< Set to enable PCI-X base addresses of 0. */

#define I2C_CSR_ADDR      0xFF000000  /**< Specifies I2C Device Address to be Accessed */
#define I2C_CSR_DATA      0x00FF0000  /**< Specifies the Required Data for a Write */
#define I2C_CSR_DEV_CODE  0x0000F000  /**< Device Select. I2C 4-bit Device Code */
#define I2C_CSR_CS        0x00000E00  /**< Chip Select */
#define I2C_CSR_RW        0x00000100  /**< Read/Write */
#define I2C_CSR_ACT       0x00000080  /**< I2C Interface Active */
#define I2C_CSR_ERR       0x00000040  /**< Error */

#define I2C_EEPROM_DEV      0xa
#define I2C_EEPROM_CHIP_SEL 0
#define EEPROM_LENGTH 64

#define I2C_READ    0
#define I2C_WRITE   1

#define RESET_CSR_EEPROM_LOAD 0x00000010

#define ISR_CLEAR_ALL   0xFFFFFFFF

#define IER0_DMA_INTS_EN    0x0F000000
#define IER0_PCI_1_EN       0x00400000
#define IER0_HW_INTS_EN     0x003F0000
#define IER0_MB_INTS_EN     0x000000FF
#define IER0_DEFAULT        (IER0_DMA_INTS_EN | IER0_PCI_1_EN | IER0_HW_INTS_EN | IER0_MB_INTS_EN)

#define MBOX_MAP_TO_INT4    0xCCCCCCCC

#define HW_MAP_HW4_TO_INT4  0x000C0000

#define IDR_PCI_A_OUT   0x40000000
#define IDR_MBOX_OUT    0x10000000


int pci_read_config_byte(int bus, int dev, int fn, int reg, unsigned char* val);
int pci_write_config_byte(int bus, int dev, int fn, int reg, unsigned char val);
int pci_read_config_word(int bus, int dev, int fn, int reg, unsigned short* val);
int pci_write_config_word(int bus, int dev, int fn, int reg, unsigned short val);
int pci_read_config_dword(int bus, int dev, int fn, int reg, unsigned long* val);
int pci_write_config_dword(int bus, int dev, int fn, int reg, unsigned long val);

unsigned int PowerSpanRead(unsigned int theOffset);
void PowerSpanWrite(unsigned int theOffset, unsigned int theValue);
void PowerSpanSetBits(unsigned int theOffset, unsigned int theMask);
void PowerSpanClearBits(unsigned int theOffset, unsigned int theMask);

int I2CAccess(unsigned char theI2CAddress, unsigned char theDevCode, unsigned char theChipSel, unsigned char* theValue, int RWFlag);

int PCIWriteConfig(int bus, int dev, int fn, int reg, int width, int targetPCI2, unsigned long val);
int PCIReadConfig(int bus, int dev, int fn, int reg, int width, int targetPCI2, unsigned long* val);

int SetSlaveImage(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr);
int SetTargetImage(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr, int targetPCI);
int SetSlaveImage2(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr,int destBus);
int SetTargetImage2(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr, int targetPCI, int whichBus);

int SetEEPROMToDefault();

int do_eeprom(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
#define CMD_TBL_EEPROM   MK_CMD_TBL_ENTRY(                                      \
        "eeprom",        2,      4,      0,      do_eeprom,                     \
        "eeprom  - read/write/copy to/from the PowerSpan II eeprom\n",          \
                                                                                \
        "r OFF [NUM]\n"                                                         \
        "    - read NUM words starting at OFF\n"                                \
        "eeprom w OFF VAL\n"                                                    \
        "    - write VAL to eeprom at OFF\n"                                    \
        "eeprom g ADD\n"                                                        \
        "    - get contents of eeprom, store at address ADD\n"                  \
        "eeprom p ADD\n"                                                        \
        "    - put eeprom data stored at ADD into the eeprom\n"                 \
        "eeprom d\n"                                                            \
        "    - return eeprom to default contents\n"                             \
),

#if 0
int do_bridge(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]);
#define CMD_TBL_BRIDGE   MK_CMD_TBL_ENTRY(                                      \
        "bridge",        2,      7,      0,      do_bridge,                     \
        "bridge  - Configure the PowerSpan II memory images\n",                 \
                                                                                \
        "DIR INDEX BLOCK_SIZE MEM_IO LOCAL_BASE PCI_BASE\n"                     \
        "    - set image #INDEX, in direction DIR(i/o) with MEM_IO flag,\n"     \
        "      addresses LOCAL_BASE and PCI_BASE, of size described by\n"       \
        "      BLOCK_SIZE (as defined by PowerSpan II Docs).\n"                 \
),
#endif

#endif
