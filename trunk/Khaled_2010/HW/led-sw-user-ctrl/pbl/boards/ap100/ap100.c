/**
 * @file ap100.c Board specific code for the AP100.
 *  This file is included through the use of #include<> in system.c, and
 *  provides implementations of the required functions.
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

/* check the defines coming in from the xmp/make file */
#if defined(NO_PPCBOOT_LITE) && !defined(PRODUCTION)
    #error "Must define PRODUCTION if NO_PPCBOOT_LITE defined"
#endif

#if defined(DUAL_PPC) && defined(SINGLE_PPC)
    #error "Mutually Exclusive defines DUAL_PPC and SINGLE_PPC defined"
#endif

#if !defined(DUAL_PPC) && !defined(SINGLE_PPC)
    #error "Must define either DUAL_PPC or SINGLE_PPC"
#endif

#if defined(DEVICE_VP7)
    #if defined(DEVICE_VP20) || defined(DEVICE_VP30)
    #error "Mutually Exclusive DEVICE_VPxx flags defined"
    #endif
#endif

#if defined(DEVICE_VP20)
    #if defined(DEVICE_VP7) || defined(DEVICE_VP30)
    #error "Mutually Exclusive DEVICE_VPxx flags defined"
    #endif
#endif

#if defined(DEVICE_VP30)
    #if defined(DEVICE_VP7) || defined(DEVICE_VP20)
    #error "Mutually Exclusive DEVICE_VPxx flags defined"
    #endif
#endif

#if !defined(DEVICE_VP7) && !defined(DEVICE_VP20) && !defined(DEVICE_VP30)
    #error "Must define DEVICE_VP7, DEVICE_VP20 or DEVICE_VP30"
#endif



int uart_init(void){
    char* env_ptr;
    int uart_selection = 0;
    unsigned uarts = UART_ADDRESS;

    SerialInit(&uarts, 1);
}

int cpu_hangup(void){
    while(1);
}

int dram_init(void){
    printf("%d MB (of possible %d MB)\n",
           (unsigned int) dram_size /(1024*1024),
           ((XPAR_SDRAM_0_HIGHADDR-XPAR_SDRAM_0_BASEADDR+1) /(1024*1024)));
}

int BoardInit(void){
    /* serial init */
    uart_init();
    SerialSelectConsole(SERIAL_SELECT_ALL);

    /* bridge init */
    if(init_local_to_pci_bridge() != 0){
        printf("Unable to initialize PLX 9056!\n");
    }
    if(init_pci_to_pci_bridge(CFG_PCI_PCI_BRIDGE_DEV_ID) != 0){
        printf("Unable to initialize Intel 21555!\n");
    }
}

int MonitorInit(void){
    printf("\n");
    printf(PBL_BANNER_TEXT);
    printf("\n");
    printf("DRAM: ");
    dram_init();
    printf("Flash: ");
    flash_init();
}


int PromptUser(void){
    int wait = 0;
    int abort = 0;
    int normal = 1;
    int selection = PBL_SELECTED;
    int uboot_present = 0;
    char* prompt;
    char user_input;

    /* check for U-Boot Image */
    if((*((unsigned short *)CFG_PROGFLASH_BASE) == IH_MAGIC_WORD_1) &&
       (*((unsigned short *)(CFG_PROGFLASH_BASE + 2)) == IH_MAGIC_WORD_2)){
        uboot_present = 1;
    }

    prompt = AUTOBOOT_PROMPT;
    if(uboot_present){
        /* no user input loads u-boot */
        selection = UBOOT_SELECTED;
    }
    else{
        /* no prompting necessary */
        printf(NO_UBOOT_BANNER);
        return 0;
    }

    printf("\n\n\n\n\n\n\n\n\n\n\n");
    printf(prompt, (MAX_BOOT_WAIT/10));
    printf("0");

    /* count down */
    while((abort == 0) && (wait < MAX_BOOT_WAIT)){
        if(serial_tstc()){
            user_input = serial_getc();
            if(user_input == ' '){
                abort = 1;
                selection = PBL_SELECTED;
            }
            else if(tolower(user_input) == 'u'){
                if(uboot_present){
                    abort = 1;
                    selection = UBOOT_SELECTED;
                }
            }
        }

        if(abort == 0){
            udelay(TENTH_OF_A_SECOND);
            if((wait % 10) == 9){
                printf("\r%d", (wait + 1)/10);
            }
            wait++;
        }
    }
    /* clear count */
    printf(ERASE_STRING);

    if(selection == UBOOT_SELECTED){
        /* PBL currently only supporting single processor platforms */
        UBoot('O');
    }
    else{ /* selection == PBL_SELECTED */
        printf(PBL_SELECTED_BANNER);
    }
}

int do_uboot(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    /* PBL currently only supporting single processor platforms */
    UBoot('O');
}


/** Write one byte with byte swapping.
  * @param  addr [IN] the address to write to
  * @param  val  [IN] the value to write
  * @ingroup ProductionSystem
  */
void write1(unsigned long addr, unsigned char val) {
    volatile unsigned char* p = (volatile unsigned char*)addr;
#if !defined(PRODUCTION)
    if(gVerbosityLevel > 1)
        printf("write1: addr=%08x val=%02x\n", addr, val);
#endif
    *p = val;
    asm("eieio");
}

/** Read one byte with byte swapping.
  * @param  addr  [IN] the address to read from
  * @return the value at addr
  * @ingroup ProductionSystem
  */
unsigned char read1(unsigned long addr) {
    unsigned char val;
    volatile unsigned char* p = (volatile unsigned char*)addr;

    val = *p;
    asm("eieio");
#if !defined(PRODUCTION)
    if(gVerbosityLevel > 1)
        printf("read1: addr=%08x val=%02x\n", addr, val);
#endif
    return val;
}

/** Write one 2-byte word with byte swapping.
  * @param  addr  [IN] the address to write to
  * @param  val   [IN] the value to write
  * @ingroup ProductionSystem
  */
void write2(unsigned long addr, unsigned short val) {
    volatile unsigned short* p = (volatile unsigned short*)addr;

#if !defined(PRODUCTION)
    if(gVerbosityLevel > 1)
        printf("write2: addr=%08x val=%04x -> *p=%04x\n", addr, val,
                ((val & 0xFF00) >> 8) | ((val & 0x00FF) << 8));
#endif
    *p = ((val & 0xFF00) >> 8) | ((val & 0x00FF) << 8);
    asm("eieio");
}

/** Read one 2-byte word with byte swapping.
  * @param  addr  [IN] the address to read from
  * @return the value at addr
  * @ingroup ProductionSystem
  */
unsigned short read2(unsigned long addr) {
    unsigned short val;
    volatile unsigned short* p = (volatile unsigned short*)addr;

    val = *p;
    val = ((val & 0xFF00) >> 8) | ((val & 0x00FF) << 8);
    asm("eieio");
#if !defined(PRODUCTION)
    if(gVerbosityLevel > 1)
        printf("read2: addr=%08x *p=%04x -> val=%04x\n", addr, *p, val);
#endif
    return val;
}

/** Write one 4-byte word with byte swapping.
  * @param  addr  [IN] the address to write to
  * @param  val   [IN] the value to write
  * @ingroup ProductionSystem
  */
void write4(unsigned long addr, unsigned long val) {
    volatile unsigned long* p = (volatile unsigned long*)addr;
#if !defined(PRODUCTION)
    if(gVerbosityLevel > 1)
        printf("write4: addr=%08x val=%08x -> *p=%08x\n", addr, val,
            ((val & 0xFF000000) >> 24) | ((val & 0x000000FF) << 24) |
            ((val & 0x00FF0000) >> 8)  | ((val & 0x0000FF00) << 8));
#endif
    *p = ((val & 0xFF000000) >> 24) | ((val & 0x000000FF) << 24) |
         ((val & 0x00FF0000) >> 8)  | ((val & 0x0000FF00) << 8);
    asm("eieio");
}

/** Read one 4-byte word with byte swapping.
  * @param  addr  [IN] the address to read from
  * @return the value at addr
  * @ingroup ProductionSystem
  */
unsigned long read4(unsigned long addr) {
    unsigned long val;
    volatile unsigned long* p = (volatile unsigned long*)addr;

    val = *p;
    val = ((val & 0xFF000000) >> 24) | ((val & 0x000000FF) << 24) |
          ((val & 0x00FF0000) >> 8)  | ((val & 0x0000FF00) << 8);
    asm("eieio");
#if !defined(PRODUCTION)
    if(gVerbosityLevel > 1)
        printf("read4: addr=%08x *p=%08x -> val=%08x\n", addr, *p, val);
#endif
    return val;
}

/** Read one 2-byte word from pci config space.
  * If the PLX indicates a master abort, target abort or SERR, 0xffff is returned
  *     and the error bits are cleared from the PLX status register (PCISR)
  * @param  bus [IN] bus
  * @param  dev [IN] device number
  * @param  fn  [IN] function
  * @param  reg [IN] register offset
  * @return
  * <pre>
  *     the value at offset: reg on device: bus.dev.fn
  *     or
  *     0xffff if no target responds
  * </pre>
  * @ingroup ProductionSystem
  */
unsigned short pci_read_config_word(int bus, int dev, int fn, int reg) {

    unsigned short val;
    unsigned short status;

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC,
        (1 << 31)            |
        ((bus & 0xFF) << 16) |
        ((dev & 0x1F) << 11) |
        ((fn & 0x07)<< 8)    |
        ((reg & 0xFF) & ~3)  |
        ((bus == 0)? 0: 1));

    val = read2(PCI_IO_BASE + (reg & 3));

    /* PCISR - if master/target abort or SERR bit set, no data and reset bit */
    status = read2(PLX_BASE_ADDRESS+0x06);
    if (status & PLX_STATUS_NO_TARGET) {
        write2(PLX_BASE_ADDRESS+0x06, (status | PLX_STATUS_NO_TARGET));
        val = 0xffff;
    }

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC, 0);

    return val;
}

/** Write one 2-byte word to pci config space offset: reg on device: bus.dev.fn.
  * If the PLX indicates a master abort, target abort or SERR, -1 is returned
  *     and the error bits are cleared from the PLX status register (PCISR)
  * @param  bus [IN] bus
  * @param  dev [IN] device number
  * @param  fn  [IN] function
  * @param  reg [IN] register offset
  * @param  val [IN] value to write
  * @return
  * <pre>
  *      0 if the write succeeded
  *     -1 if no target responds
  * </pre>
  * @ingroup ProductionSystem
  */
int pci_write_config_word(int bus, int dev, int fn, int reg, unsigned short val) {
    int ret_val = 0;
    unsigned short status;

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC,
        (1 << 31)            |
        ((bus & 0xFF) << 16) |
        ((dev & 0x1F) << 11) |
        ((fn & 0x07)<< 8)    |
        ((reg & 0xFF) & ~3)  |
        ((bus == 0)? 0: 1));

    write2(PCI_IO_BASE + (reg & 3), val);

    /* PCISR - if master/target abort or SERR bit set, no data and reset bit */
    status = read2(PLX_BASE_ADDRESS+0x06);
    if (status & PLX_STATUS_NO_TARGET) {
        write2(PLX_BASE_ADDRESS+0x06, (status | PLX_STATUS_NO_TARGET));
        ret_val = -1;
    }

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC, 0);

    return ret_val;
}

/** Read one 4-byte word from pci config space.
  * If the PLX indicates a master abort, target abort or SERR, 0xffffffff is returned
  *     and the error bits are cleared from the PLX status register (PCISR)
  * @param  bus [IN] bus
  * @param  dev [IN] device number
  * @param  fn  [IN] function
  * @param  reg [IN] register offset
  * @return
  * <pre>
  *     the value at offset: reg on device: bus.dev.fn
  *     or
  *     0xffffffff if no target responds
  * </pre>
  * @ingroup ProductionSystem
  */
unsigned long pci_read_config_word_long(int bus, int dev, int fn, int reg) {

    unsigned long val;
    unsigned short status;

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC,
        (1 << 31)   |
        ((bus & 0xFF) << 16) |
        ((dev & 0x1F) << 11) |
        ((fn & 0x07)<< 8)    |
        ((reg & 0xFF) & ~3)  |
        ((bus == 0)? 0: 1));

    val = read4(PCI_IO_BASE + (reg & 3));

    /* PCISR - if master/target abort or SERR bit set, no data and reset bit */
    status = read2(PLX_BASE_ADDRESS+0x06);
    if (status & PLX_STATUS_NO_TARGET) {
        write2(PLX_BASE_ADDRESS+0x06, (status | PLX_STATUS_NO_TARGET));
        val = 0xffffffff;
    }

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC, 0);

    return val;
}

/** Write one 4-byte word to pci config space offset: reg on device: bus.dev.fn.
  * If the PLX indicates a master abort, target abort or SERR, -1 is returned
  *     and the error bits are cleared from the PLX status register (PCISR)
  * @param  bus [IN] bus
  * @param  dev [IN] device number
  * @param  fn  [IN] function
  * @param  reg [IN] register offset
  * @param  val [IN] value to write
  * @return
  * <pre>
  *      0 if the write succeeded
  *     -1 if no target responds
  * </pre>
  * @ingroup ProductionSystem
  */
int pci_write_config_word_long(int bus, int dev, int fn, int reg, unsigned long val) {
    int ret_val = 0;
    unsigned short status;

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC,
        (1 << 31)   |
        ((bus & 0xFF) << 16) |
        ((dev & 0x1F) << 11) |
        ((fn & 0x07)<< 8)    |
        ((reg & 0xFF) & ~3)  |
        ((bus == 0)? 0: 1));

    write4(PCI_IO_BASE + (reg & 3), val);

    /* PCISR - if master/target abort or SERR bit set, no data and reset bit */
    status = read2(PLX_BASE_ADDRESS+0x06);
    if (status & PLX_STATUS_NO_TARGET) {
        write2(PLX_BASE_ADDRESS+0x06, (status | PLX_STATUS_NO_TARGET));
        ret_val = -1;
    }

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC, 0);

    return ret_val;
}

/** Read one byte from pci config space.
  * If the PLX indicates a master abort, target abort or SERR, 0xff is returned
  *     and the error bits are cleared from the PLX status register (PCISR)
  * @param  bus [IN] bus
  * @param  dev [IN] device number
  * @param  fn  [IN] function
  * @param  reg [IN] register offset
  * @return
  * <pre>
  *     the value at offset: reg on device: bus.dev.fn
  *     or
  *     0xff if no target responds
  * </pre>
  * @ingroup ProductionSystem
  */
unsigned char pci_read_config_byte(int bus, int dev, int fn, int reg) {

    unsigned char val;
    unsigned short status;

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC,
        (1 << 31)   |
        ((bus & 0xFF) << 16) |
        ((dev & 0x1F) << 11) |
        ((fn & 0x07)<< 8)    |
        ((reg & 0xFF) & ~3)  |
        ((bus == 0)? 0: 1));

    val = read1(PCI_IO_BASE + (reg & 3));

    /* PCISR - if master/target abort or SERR bit set, no data and reset bit */
    status = read2(PLX_BASE_ADDRESS+0x06);
    if (status & PLX_STATUS_NO_TARGET) {
        write2(PLX_BASE_ADDRESS+0x06, (status | PLX_STATUS_NO_TARGET));
        val = 0xff;
    }

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC, 0);

    return val;
}

/** Write one byte to pci config space offset: reg on device: bus.dev.fn.
  * If the PLX indicates a master abort, target abort or SERR, -1 is returned
  *     and the error bits are cleared from the PLX status register (PCISR)
  * @param  bus [IN] bus
  * @param  dev [IN] device number
  * @param  fn  [IN] function
  * @param  reg [IN] register offset
  * @param  val [IN] value to write
  * @return
  * <pre>
  *      0 if the write succeeded
  *     -1 if no target responds
  * </pre>
  * @ingroup ProductionSystem
  */
int pci_write_config_byte(int bus, int dev, int fn, int reg, unsigned char val) {
    int ret_val = 0;
    unsigned short status;

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC,
        (1 << 31)   |
        ((bus & 0xFF) << 16) |
        ((dev & 0x1F) << 11) |
        ((fn & 0x07)<< 8)    |
        ((reg & 0xFF) & ~3)  |
        ((bus == 0)? 0: 1));

    write1(PCI_IO_BASE + (reg & 3), val);

    /* PCISR - if master/target abort or SERR bit set, no data and reset bit */
    status = read2(PLX_BASE_ADDRESS+0x06);
    if (status & PLX_STATUS_NO_TARGET) {
        write2(PLX_BASE_ADDRESS+0x06, (status | PLX_STATUS_NO_TARGET));
        ret_val = -1;
    }

    /* DMCFGA */
    write4(PLX_BASE_ADDRESS+0xAC, 0);

    return ret_val;
}

/** Initialize the PLX Local-Pci Bridge registers.
  * In a production system, this function is called immediately after the the
  *     initialization of the serial port.  This is required so that the board
  *     is ready for PPCBoot.
  * In a test system, this is function is not called automatically, but can be
  *     called with the console command pciint.
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup ProductionSystem
  */
int init_local_to_pci_bridge() {
    unsigned long  long_value;
    int retries = 0;

    /** <B>NOTES:</B> */
    /** All register settings given set all other bits to 0 unless otherwise indicated */
    /** Wait until the PLX responds by reading vendor ID and device ID.
      *   This will also indicate whether we need to set the endian bit or not */
    long_value = read4(PLX_BASE_ADDRESS+0x00);
    while((long_value != 0x905610b5) && (long_value != 0xb5105690)){
        retries++;
        udelay(BRIDGE_RETRY_DELAY);
        long_value = read4(PLX_BASE_ADDRESS+0x00);

        /* give up eventually */
        if(retries >  MAX_BRIDGE_RETRIES){
            printf("timeout\n");
            return -1;
        }
    }

    /** If big endian is on, we can access BIGEND at offset 0x8C, otherwise we
      *     need to munge the address (0x8F) to reach the register */
    if(long_value == 0x905610b5){
        /* do NOT munge address */
        /** <pre>BIGEND: Big/Little Endian Descriptor
         * [0]: Big Endian for configuration
         * [1]: Big Endian for direct master
         * [2]: Big Endian for direct slave
         * [4]: Big Endian Byte Lane
         * </pre>
         */
        write1(PLX_BASE_ADDRESS+0x8C, 0x17);
    }
    else{
        /* we MUST set the endian bits first (munge address) */
        /* BIGEND: Big/Little Endian Descriptor
         * [0]: Big Endian for configuration
         * [1]: Big Endian for direct master
         * [2]: Big Endian for direct slave
         * [4]: Big Endian Byte Lane
         */
        write1(PLX_BASE_ADDRESS+0x8F, 0x17);
    }


    /* General set up */
    /** <pre> PCICR: PCI Command
     * [0]: I/O Space enabled
     * [1]: Memory Space enabled
     * [2]: Master Enable enabled
     * [6]: Parity Error Response enabled
     * [8]: SERR# Enable
     * </pre>
     */
    write2(PLX_BASE_ADDRESS+0x04, 0x0147);

    /** <pre> MARBR: Mode/DMA Arbitration:
     * [28]: Read Ahead Mode enabled to deal with 21555 read ahead mode
     * </pre>
     */
    write4(PLX_BASE_ADDRESS+0x88, PLX_ENABLE_READ_AHEAD);

    /** <pre> INTCSR: Interrupt Control/Status:
     * [12]: Retry Abort enabled to only try 256 times before aborting
     * </pre>
     */
    long_value = read4(PLX_BASE_ADDRESS+0xE8);
    long_value |= PLX_256_RETRIES;
    write4(PLX_BASE_ADDRESS+0xE8, long_value);

    /** <pre> PCILTR: PCI Bus Latency Timer
      * [7-0]: PCI Bus Latency set to 32
      * </pre>
      */
    write1(PLX_BASE_ADDRESS+0x0D, PCI_BUS_LATENCY);

    /** <pre> LBRD0: Local Address Space 0 Bus Region Descriptor
      *         (defaults maintained, except for these changes)
      * [1-0]: Bus Width is 32 (11b)
      * [8]  : Local Address Space 0 prefetch disabled
      * </pre>
      */
    long_value = read4(PLX_BASE_ADDRESS+0x98);
    long_value |= 0x00000103;
    write4(PLX_BASE_ADDRESS+0x98, long_value);

    /** <pre> LBRD1: Local Address Space 1 Bus Region Descriptor
      *         (defaults maintained, except for these changes)
      * [1-0]: Bus Width is 8 (00b)
      * [9]  : Local Address Space 0 prefetch disabled
      * </pre>
      */
    long_value = read4(PLX_BASE_ADDRESS+0x178);
    long_value |= 0x00000200;
    long_value &= ~0x3;
    write4(PLX_BASE_ADDRESS+0x178, long_value);

    /* Master Setup */
    /**<pre> DMRR: Local Range for Direct Master-to-PCI 4MB </pre>
      */
    /* 4 MB; 2nd meg to map to 21555 CSRs 3rd meg to map to 82559 CSRs */
    write4(PLX_BASE_ADDRESS+0x9C, PLX_LOCAL_MRANGE);

    /** <pre> DMPBAM: PCI Base Address (Remap) for Direct Master-to-PCI Memory
      * [0]    : Direct Master Memory Access Enable
      * [1]    : Direct Master I/O Access Enable
      * [31-16]: PCI Base Address
      * </pre>
      */
    /* Map memory "straight across" */
    write4(PLX_BASE_ADDRESS+0xA8, PCI_MEM_BASE | 0x00000003);

    /** <pre> DMLBAM: Local Base Address for Direct Master-to-PCI Memory
      * [31-16]: Local Base Address
      * </pre>
      */
    write4(PLX_BASE_ADDRESS+0xA0, PCI_MEM_BASE);

    /** <pre> DMLBAI: Local Base Address for Direct Master-to-PCI I/O Configuration
      * [31-16]: Local Base Address
      * </pre>
      */
    write4(PLX_BASE_ADDRESS+0xA4, PCI_IO_BASE);

    /* Slave Setup */
    /** <pre> LAS0RR: Local Range for Direct PCI-to-Slave
      * [31-4]: Local Range
      * </pre>
      */
    /* RAM window*/
    write4(PLX_BASE_ADDRESS+0x80, DRAM_RANGE);

    /** <pre> LAS0BA: Local Base Address for Direct PCI-to-Slave Memory
      * [0]   : Memory Space enabled
      * [31-4]: Local Base Address
      * </pre>
      */
    /* RAM window*/
    write4(PLX_BASE_ADDRESS+0x84, (PLX_DRAM_BASE | PLX_LOCAL_DECODE_ENABLE));

    /** <pre> PCIBAR2: PCI Base Address for Direct PCI-to-Slave Memory 0
      * [31-4]: Pci Base Address
      * </pre>
      */
    /* RAM window*/
    write4(PLX_BASE_ADDRESS+0x18, PCI_DRAM_BASE);

    /** <pre> LAS1RR: Local Range for Direct PCI-to-Slave
      * [31-4]: Local Range
      * </pre>
      */
    /* config window */
    write4(PLX_BASE_ADDRESS+0x170, CONFIG_RANGE);

    /** <pre> LAS1BA: Local Base Address for Direct PCI-to-Slave Memory 1
      * [0]   : Memory Space enabled
      * [31-4]: Local Base Address
      * </pre>
      */
    /* config window */
    write4(PLX_BASE_ADDRESS+0x174, (PLX_CONFIG_BASE | PLX_LOCAL_DECODE_ENABLE));

    /** <pre> PCIBAR3: PCI Base Address for Direct PCI-to-Slave Memory
      * [31-4]: Pci Base Address
      * </pre>
      */
    /* config window */
    write4(PLX_BASE_ADDRESS+0x1C, PCI_CONFIG_BASE);

    /** <pre> LMISC1: set init status bit
      * [1]: I/O Base Address enabled
      * [2]: Local Init Status done
      * </pre>
      */
    write1(PLX_BASE_ADDRESS+0x8D, 0x05);

    return 0;
}

/** Initialize the Intel Pci-Pci Bridge registers.
  * In a production system, this function is called immediately after the the
  *     initialization of the PLX Local-Pci bridge.  This is required so that
  *     the board is ready for PPCBoot.
  * In a test system, this is function is not called automatically, but by
  *     calling pciscan, this device will be found and configured if it is
  *
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see init_local_to_pci_bridge()
  * @ingroup ProductionSystem
  */
int init_pci_to_pci_bridge(int device_id){
    int ret_val = 0;
    unsigned short read_value;
    int retries = 0;

    /** <B>NOTES:</B> */
    /** All register settings given set all other bits to 0 unless otherwise indicated */
    /** Wait until the 21555 responds by reading vendor ID and device ID. */
    while(pci_read_config_word_long(0, device_id, 0, 0) != 0xb5558086){
        retries++;
        udelay(BRIDGE_RETRY_DELAY);

        /* give up eventually */
        if(retries >  MAX_BRIDGE_RETRIES){
            printf("timeout\n");
            return -1;
        }
    }

    /** If SROM preload was unsuccessful set ranges and issue error message: */
    if((pci_read_config_byte(0, device_id, 0, 0xd6) & INTEL_BRIDGE_PRELOAD_ENABLE) == 0)
    {
        printf("Pci-Pci bridge preload did not occur.\n"
               "Host may have incorrect information\n");

        /* Initialize downstream setup registers on 21555 (from secondary side) */
        /** <pre>
          *         Primary downstream bar0 requests 4k memory (for CSRs)
          *         Primary downstream bar1 requests 256 bytes IO space
          *         Primary downstream bar2 (RAM window) requests 128 MB non-prefetch memory
          *         Primary downstream bar3 (config window) requests 64 MB non-prefetch
          *         Primary downstream bar3 upper32 bits request disabled
          *         Secondary upstream bar0 requests 256 bytes IO space
          *         Secondary upstream bar1 requests 1MB non-prefetch memory
          * </pre>
          */

        /* downstream bar 0 */
        pci_write_config_word_long(0, device_id, 0, 0xAC, 0xFFFFF000);

        /* downstream bar 1 */
        pci_write_config_word_long(0, device_id, 0, 0xB0, IO_RANGE_256B);

        /* downstream bar 2 */
        pci_write_config_word_long(0, device_id, 0, 0xB4, DRAM_RANGE);

        /* downstream bar 3 */
        pci_write_config_word_long(0, device_id, 0, 0xB8, CONFIG_RANGE);

        /* downstream bar 3 */
        pci_write_config_word_long(0, device_id, 0, 0xBC, PCI_DISABLED_BAR);


        /* initialize up stream setup registers on 21555 (from secondary side) */
        /* upstream bar 0 */
        pci_write_config_word_long(0, device_id, 0, 0xC4, IO_RANGE_256B);

        /* upstream bar 1 */
        pci_write_config_word_long(0, device_id, 0, 0xC8, MEM_RANGE_1MB);

        /* disable bar2 explicitly? */
    }

    /* All downstream transactions need to point to valid local domain locations */
    /** downstream translated base 0 not used; bar0 is for CSRs only */
    pci_write_config_word_long(0, device_id,  0, 0x94, PCI_DISABLED_BAR);

    /** downstream translated base 1 is IO space */
    pci_write_config_word_long(0, device_id,  0, 0x98, PCI_IO_BASE);

    /** downstream translated base 2 is RAM window */
    pci_write_config_word_long(0, device_id,  0, 0x9c, PCI_DRAM_BASE);

    /** downstream translated base 3 is config window */
    pci_write_config_word_long(0, device_id,  0, 0xA0, PCI_CONFIG_BASE);


    /** upstream translated base registers
      * All upstream transactions need to point to valid host domain locations
      * this is typically negotiated with host driver at runtime */
    /* Upstream translated base address 0 is I/O - map straight across */
    pci_write_config_word_long(0, device_id,  0, 0xA4, PCI_IO_BASE);

    /* Upstream translated base address 1 is memory - map straight across */
    pci_write_config_word_long(0, device_id,  0, 0xA8, PCI_MEM_BASE);

    /* tbar2 is implicitly disabled */

    /* now configure 21555 BARs. Will typically happen in local PCI plug&play module*/
    /* set secondary command register to 0 (is this necessary?) */
    pci_write_config_word(0, device_id,  0, 0x04, 0);

    /** upstream BAR 0 is 21555 CSRs, BAR 1 is IO access to 21555 CSRs */
    pci_write_config_word_long(0, device_id,  0, 0x10, PCI_MEM_21555_CSR_BASE);
    pci_write_config_word_long(0, device_id,  0, 0x14, PCI_IO_21555_CSR_BASE);

    /* upstream bar0 is I/O */
    pci_write_config_word_long(0, device_id,  0, 0x18, PCI_IO_BASE);

    /* upstream bar1 is memory */
    pci_write_config_word_long(0, device_id,  0, 0x1c, PCI_MEM_BASE);

    /** <pre> PCI Bus Latency Timer
      * [7-0]: PCI Bus Latency set to 32
      * </pre>
      */
    pci_write_config_byte(0, device_id,  0, 0x0D, PCI_BUS_LATENCY);

    /** <pre> PCI Command
     * [0]: I/O Space enabled
     * [1]: Memory Space enabled
     * [2]: Master Enable enabled
     * [6]: Parity Error Response enabled
     * [8]: SERR# Enable
     * </pre>
     */
    pci_write_config_word(0, device_id,  0, 0x04, 0x0147);

    /** clear primary lockout bit */
    read_value = pci_read_config_word(0, device_id, 0, 0xCC);
    read_value &= ~0xFBFF;
    pci_write_config_word(0, device_id,  0, 0xCC, read_value);

    return ret_val;
}