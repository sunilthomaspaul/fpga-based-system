/**
 * @file ap1000.c Board specific code for the AP1000.
 *  This file is included through the use of #include<> in board.c, and
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

/** Index of the UART that is in use. */
unsigned int gChosenUART = PHYSICAL_UART0_INDEX;

/**
 * Initializes the UARTS.
 * @return The return value of SerialInit().
 */
int UARTInit(void){
    char* env_ptr;
    int uart_selection = 0;
    unsigned int uarts[1] = { PHYSICAL_UART0 };

    return SerialInit(uarts, 1);
}

/**
 * Initializes the DRAM.
 * Simply displays DRAM size.
 */
int DRAMInit(void){
    printf("%d MB (of possible %d MB)\n", (unsigned int) dram_size /(1024*1024),
           ((XPAR_SDRAM_0_HIGHADDR-XPAR_SDRAM_0_BASEADDR+1) /(1024*1024)));
}

/**
 * Standard hook function that initializes the board for the Monitor program or U-Boot.
 * - Initializes the UARTs
 * - Enables i/o to/from both UARTs.
 * - Initializes the PowerSpan II bridge.
 */
int BoardInit(void){
    /* serial init */
    UARTInit();
    SerialSelectConsole(SERIAL_SELECT_ALL);
#if defined(PRODUCTION)
    if(InitPowerSpan() != 0){
        printf("Unable to initialize PowerSpan II!\n");
    }
#endif
}

/**
 * Standard hook function that initializes the Monitor program for user i/o.
 * - Displays PBL banner.
 * - Initializes DRAM.
 * - Initializes flash.
 */
int MonitorInit(void){
    printf("\n");
    printf(PBL_BANNER_TEXT);
    printf("\n");
    printf("DRAM: ");
    DRAMInit();
    printf("Flash: ");
    flash_init();
}

#if defined(PRODUCTION)
/**
 * Standard hook function that allows the user to decide whether to run the Monitor program or load U-Boot.
 * The user is given 3 seconds to provide input to determine the boot procedure, unless
 *  U-Boot is not detected in the program flash, in which case the PBL monitor program
 *  will run immediately.
 *
 * By default U-Boot will be loaded if there is no user input.
 *
 * The user can decide the boot process by either pressing 'U' or the space bar within the
 *  3 seconds.  Pressing 'U' will load U-Boot if it has been detected in the program flash.
 *  Pressing the space bar will run the Monitor program.  Pressing either of these keys will
 *  end the 3 second wait period.
 *
 * The UART that the user uses to choose the boot procedure also determines which UART will be
 *  used by PBL, U-Boot, and Linux.  If no user input is detected, the PCI UART is selected,
 *  and the debug UART is disabled.  If the user provides input, the UART that the user used
 *  is designated as the active UART, and the other UART will be deactivated.
 *
 * @return Only returns if the Monitor program is selected.
 * @retval 0 if Monitor program is selected.
 */
int PromptUser(void){
    int wait = 0;
    int abort = 0;
    int normal = 1;
    int selection = PBL_SELECTED;
    int uboot_present = 0;
    char* prompt;
    char user_input;
    int  tst_source;

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
        tst_source = serial_tstc();
        if(tst_source){
            tst_source -= SERIAL_TESTC_OFFSET;
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

    /* lock in the uart that got input, or default to the PCI uart */
    if(abort == 1){
        gChosenUART = tst_source;
    }

    if(selection == UBOOT_SELECTED){
        UBoot(gChosenUART);
    }
    else{ /* selection == PBL_SELECTED */
        printf(PBL_SELECTED_BANNER);
    }
}
#endif /* #if defined(PRODUCTION) */

/**
 * PBL command that attempts to load U-Boot from program flash.
 */
int do_uboot(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
#if !defined(PRODUCTION)
    if(!gPCIInitialized){
        printf("PCI not initialized, aborting.\n");
        return -1;
    }
#endif
    UBoot(gChosenUART);
}

/**
 * Initializes the PowerSpan II bridge to be used by PBL, U-Boot and Linux.
 * This is the sole place that the PowerSpan II is initialized by PBL, U-Boot or
 *  Linux.
 *
 * @return The status of the function call.
 * @retval 0 if the function succeeded
 */
int InitPowerSpan() {
    unsigned int reg_value;
    int eeprom_success = 1;

    /* check for EEPROM success */
    reg_value = PowerSpanRead(REG_RESET_CSR);

    if((reg_value & RESET_CSR_EEPROM_LOAD) == 0){
        printf("PowerSpan EEPROM load failed.\n");
        eeprom_success = 0;
    }

    /* Do everything from scratch. EEPROM configuration is not complete enough to do more
       than make bridge chip configuration registers available. */

    /* Stop all access */
    PowerSpanWrite(REG_P1_CSR,0);	/* Turn off bus master, memory response on PCI-1 */
    PowerSpanWrite(REG_P2_CSR,0);	/* Turn off bus master, memory response on PCI-2 */
    PowerSpanWrite(REG_P1_MISC_CSR,0); /* Turn off PCI-1 access to powerspan control registers. */
    PowerSpanWrite(REG_P2_MISC_CSR,0); /* Turn off PCI-2 access to powerspan control registers */

    /* clear isr status bits and all interrupt enables  */
    PowerSpanWrite(REG_ISR0, ISR_CLEAR_ALL);
    PowerSpanWrite(REG_ISR1, ISR_CLEAR_ALL);
    PowerSpanWrite(REG_IER0, 0);
    PowerSpanWrite(REG_IER1, 0);

    /* clear err log bits */
    PowerSpanWrite(REG_P1_ERR_CSR, PX_ERR_ERR_STATUS);
    PowerSpanWrite(REG_PB_ERR_CSR, PX_ERR_ERR_STATUS);
    PowerSpanWrite(REG_P2_ERR_CSR, PX_ERR_ERR_STATUS);

    /* set MAX_RETRY */
    PowerSpanSetBits(REG_P1_MISC_CSR, PX_MISC_CSR_MAX_RETRY);
    PowerSpanSetBits(REG_PB_MISC_CSR, PX_MISC_CSR_MAX_RETRY);
    PowerSpanSetBits(REG_P2_MISC_CSR, PX_MISC_CSR_MAX_RETRY);

    /* Clear lockout bits. Allow PCI bus addresses of 0 to be active. */
    PowerSpanSetBits(REG_MISC_CSR, MISC_CSR_PCI1_LOCK | MISC_CSR_PCI2_LOCK | MISC_CSR_BAR_EQ_0);

    /* Set up PB->PCI-2 Slave windows. */
    SetSlaveImage2(0,PB_SI_BS_16MB,PB_SLAVE_NOT_MEM_IO,PX_TGT_CSR_BIG_END,PCI_IO_BASE,PCI_IO_BASE,1);
    SetSlaveImage2(1,PB_SI_BS_32MB,PB_SLAVE_USE_MEM_IO,PX_TGT_CSR_BIG_END,PCI_MEM_BASE,PCI_MEM_BASE,1);
    SetSlaveImage2(2,PB_SI_BS_64MB,PB_SLAVE_USE_MEM_IO,PX_TGT_CSR_BIG_END,PCI_MEM_BASE + 0x02000000,PCI_MEM_BASE + 0x02000000,1);
    SetSlaveImage2(3,PB_SI_BS_128MB,PB_SLAVE_USE_MEM_IO,PX_TGT_CSR_BIG_END,PCI_MEM_BASE + 0x06000000,PCI_MEM_BASE + 0x06000000,1);
    SetSlaveImage2(4,PB_SI_BS_128MB,PB_SLAVE_USE_MEM_IO,PX_TGT_CSR_BIG_END,PCI_MEM_BASE + 0x0E000000, PCI_MEM_BASE + 0x0E000000,1);
    SetSlaveImage2(5,PB_SI_BS_64MB,PB_SLAVE_USE_MEM_IO,PX_TGT_CSR_BIG_END,PCI_MEM_BASE + 0x16000000, PCI_MEM_BASE + 0x16000000,1);

    /* Set PCI-1->PB windows */
    SetTargetImage(0,PX_TGT_CSR_BS_128MB,PX_TGT_NOT_MEM_IO,PX_TGT_CSR_BIG_END,XPAR_SDRAM_0_BASEADDR,NULL, 0); /* 128 Meg Ram */
    SetTargetImage(1,PX_TGT_CSR_BS_64MB,PX_TGT_USE_MEM_IO,PX_TGT_CSR_BIG_END,CFG_CONFFLASH_BASE,NULL, 0);     /* 64 Meg Config Flash and CPLD */
    SetTargetImage(2,PX_TGT_CSR_BS_64MB,PX_TGT_USE_MEM_IO,PX_TGT_CSR_BIG_END,CFG_PROGFLASH_BASE,NULL, 0);     /* 64 Meg Program Flash Space. */
    SetTargetImage(3,PX_TGT_CSR_BS_64K,PX_TGT_NOT_MEM_IO,PX_TGT_CSR_BIG_END,PCI_MEM_BASE,NULL, 1);            /* 64 K PCI-2 Ethernet. */

    /* PCI-2->PB windows */
    SetTargetImage2(0, PX_TGT_CSR_BS_128MB, PB_SLAVE_NOT_MEM_IO, PX_TGT_CSR_BIG_END, XPAR_SDRAM_0_BASEADDR, XPAR_SDRAM_0_BASEADDR, 0, 1);
    SetTargetImage2(1, PX_TGT_CSR_BS_128MB, PX_TGT_USE_MEM_IO, PX_TGT_CSR_BIG_END, CFG_PROGFLASH_BASE, CFG_PROGFLASH_BASE, 0, 1);

    /* Set up Interrupt direction.
        P1_HW_INT	-> Out to Host
        P2_HW_INT	-> In to Local Processors.
        INT5        -> In, Temperature alert from thermistor, connected to FPGA input.
        INT4		-> Out to Local Processor - P1 Error conditions.
        INT3        -> Out to local Processor - P2 Error Conditions.
        INT2		-> Out to local Processor - PB error Conditions.
        INT1		-> Out to local processor - Mailbox interrupt.
        INT0		-> IN, unused */

    PowerSpanWrite(REG_IDR,0x5F000000);

    /* Set HW interrupt signal to pin mapping. Associated each condition with the corresponding interrupt pin.
       P1_HW_INT --> P1_HW_INT, P2_HW_INT -> P2_HW_INT,
       INT0 -> INT0, INT1 -> INT1, INT2->INT2, INT3->INT3, INT4->INT4, INT5->INT5 */
    PowerSpanWrite(REG_HW_MAP,0x40ECA864);

    /* Set Up Mailbox interrupt mapping - All mailbox interrupts to INT1 */
    PowerSpanWrite(REG_MBOX_MAP,0x44444444);

    /* Set Up all PCI-1 error conditions to assert INT4 */
    PowerSpanWrite(REG_IMR_P1,0xCCCCCCC0);

    /* Set up all PCI-2 error condition to assert INT3 */
    PowerSpanWrite(REG_IMR_P2,0xAAAAAAA0);

    /* Set up all Processor bus errors to assert INT2 */
    PowerSpanWrite(REG_IMR_PB,0x88888880);
    PowerSpanWrite(REG_IMR2_PB,0x88800000);

    /* Set PCI-1 arbitor control - Low priority for external, PS high priority, park last master.
        Shouldn't really matter, since Powerspan is not arbitor on PCI-1 */
    PowerSpanWrite(REG_P1_ARB_CTRL,0x00000100);

    /* Set PCI-2 arbitor control - Low priority for PMC, Ether, High priority for PS, park last master,
        no monitor */
    PowerSpanWrite(REG_P2_ARB_CTRL,0x00000100);


    /* enable pci mem accesses bus master bits */
    PowerSpanSetBits(REG_P1_CSR, CSR_MEMORY_SPACE_ENABLE | CSR_PCI_MASTER_ENABLE);
	PowerSpanSetBits(REG_P2_CSR, CSR_MEMORY_SPACE_ENABLE | CSR_PCI_MASTER_ENABLE);

    /* enable PCI-1 CSRs. Power span control registers available on PCI-1 bus. */
    PowerSpanSetBits(REG_P1_MISC_CSR, PX_MISC_REG_BAR_ENABLE);

	/* Enable PCI-2 CSRs, return all 1's on master abort. Do not provide Powerspan registers to PCI-2 bus. */
	PowerSpanSetBits(REG_P2_MISC_CSR,  PX_MISC_REG_MAC_ERROR);

    /* Enable TEA generation ,return all 1's on master abort, retry lots but not forever,
       no extended cycles, no support for 7400 misaligned transfers, address retry disabled.  */
    PowerSpanWrite(REG_PB_MISC_CSR, PX_MISC_CSR_MAX_RETRY | PB_MISC_TEA_ENABLE | PB_MISC_MAC_TEA );

#if !defined(PRODUCTION)
    gPCIInitialized = 1;
#endif

    return 0;
}
