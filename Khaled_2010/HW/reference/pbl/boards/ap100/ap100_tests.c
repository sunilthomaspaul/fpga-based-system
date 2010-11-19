/**
 * @file ap100_tests.c Board specific test code for the AP100.
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
/*---------------------------------------------------------------------------*/
/*  Start of Testsys code                                                    */
/*---------------------------------------------------------------------------*/

#if !defined(PRODUCTION)

#include "system.h"
#include "ap100/ap100_tests.h"
#include "serial.h"
#include "xgpio_l.h"
#include "xsysace_l.h"


static int G_21555_device_id = -1;

#define PCI_MEM_82559ER_CSR_BASE    0x30200000
#define PCI_IO_82559ER_CSR_BASE     0x40000200

#define INTC_BASE_ADDRESS           0x4D000000
#define INTC_NUM_REGISTERS          8


#define NUMOF(x)    (sizeof(x)/sizeof(x[0]))

#define XGpio_mGetDataDirection(BaseAddress) \
    XGpio_mReadReg((BaseAddress), XGPIO_TRI_OFFSET)

static int G_ethernet_device_id = -1;

/** Scan PCI bus for devices, displays registers, and initialize known devices.
  * This function currently does not scan for multiple functions of a device
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int pci_scan(int *TheDeviceCount) {

    int dev;
    int func;
    unsigned short read_config_val;
    int ret_val = 0;
    int init_ret_val = 0;
    int device_count = 0;

    printf("Scanning PCI:\n");
    /* check for any devices on the bus */
    for(dev = 0; dev < 32; dev++) {
        func = 0;
        read_config_val = pci_read_config_word(0, dev, func, 0);

        /* if device found, initialize it */
        if (read_config_val != 0xffff){
            device_count++;
            init_ret_val = pci_initdevice(0, dev, func, 0);

            /* keep track of non-zero returns */
            ret_val |= init_ret_val;

            /* check for sub-devices */
            /* if device found, initialize it
            while((read_config_val != 0xFFFF) && (func < 8)){
                func++;
                read_config_val = pci_read_config_word(0, dev, func, 0);
                if(read_config_val != 0xFFFF){
                    ret_val = pci_initdevice(0, dev, func, 0);

                    device_count++;
                }
            } */
        }
    }

    *TheDeviceCount = device_count;
    return ret_val;
};


/*Note: These define the position of the GPIO banks in the following arrays.
        Keep them in sync if something changes!  They are mainly used for
        readability in the loopback test definition table (which uses indexes
        instead of register addresses to conserve space).
*/
    #define pPMC1   0
    #define pPMC2   1
    #define pLA1    2
    #define pEXP1   3
    #define pEXP2   4
    #define pLA2    5
    #define pEXP3   6
    #define pEXP4   7
    #define pEXP5   8
    #define pEXP6   9


/* Dual GE Mezzanine test does not need GPIO tests */
#if defined(TEST_DUAL_GE_PHY_MEZZ)
    #define NUM_GPIOS 0

    unsigned long gGPIOAddrArray[2] = { 0 };
    unsigned long gGPIOMaskArray[2] = { 0 };
    char         *gGPIONameArray[2] = { "\0" };
/* 20s and 30s: */
#elif defined(DEVICE_VP20) || defined(DEVICE_VP30)
    #define GPIO_EXP2_DATA_MASK 0x000001FF
    #define GPIO_EXP6_DATA_MASK 0x000003FF
    #define NUM_GPIOS           10



    unsigned long gGPIOAddrArray[NUM_GPIOS] = {
        XPAR_OPB_GPIO_PMC1_BASEADDR,
        XPAR_OPB_GPIO_PMC2_BASEADDR,
        XPAR_OPB_GPIO_LA1_BASEADDR ,
        XPAR_OPB_GPIO_EXP1_BASEADDR,
        XPAR_OPB_GPIO_EXP2_BASEADDR,
        XPAR_OPB_GPIO_LA2_BASEADDR ,
        XPAR_OPB_GPIO_EXP3_BASEADDR,
        XPAR_OPB_GPIO_EXP4_BASEADDR,
        XPAR_OPB_GPIO_EXP5_BASEADDR,
        XPAR_OPB_GPIO_EXP6_BASEADDR};

    unsigned long gGPIOMaskArray[NUM_GPIOS] = {
        0xFFFFFFFF,
        0xFFFFFFFF,
        0xFFFFFFFF,
        0xFFFFFFFF,
        GPIO_EXP2_DATA_MASK,
        0xFFFFFFFF,
        0xFFFFFFFF,
        0xFFFFFFFF,
        0xFFFFFFFF,
        GPIO_EXP6_DATA_MASK};

    char *gGPIONameArray[NUM_GPIOS] = {
        "PMC1",
        "PMC2",
        "LA1",
        "EXP1",
        "EXP2",
        "LA2",
        "EXP3",
        "EXP4",
        "EXP5",
        "EXP6",
    };

    char *ConnectorNameArray[NUM_GPIOS] = {
        "J14",
        "J14",
        "J8",
        "J16",
        "J16",
        "J6",
        "J17",
        "J17",
        "J17",
        "J17",
    };

#else /* defined(DEVICE_VP7) */
    #define GPIO_EXP2_DATA_MASK 0x000001FF
    #define NUM_GPIOS           5

    unsigned long gGPIOAddrArray[NUM_GPIOS] = {
        XPAR_OPB_GPIO_PMC1_BASEADDR,
        XPAR_OPB_GPIO_PMC2_BASEADDR,
        XPAR_OPB_GPIO_LA_BASEADDR ,
        XPAR_OPB_GPIO_EXP1_BASEADDR,
        XPAR_OPB_GPIO_EXP2_BASEADDR};

    unsigned long gGPIOMaskArray[NUM_GPIOS] = {
        0xFFFFFFFF,
        0xFFFFFFFF,
        0xFFFFFFFF,
        0xFFFFFFFF,
        GPIO_EXP2_DATA_MASK};

    char *gGPIONameArray[NUM_GPIOS] = {
        "PMC1",
        "PMC2",
        "LA",
        "EXP1",
        "EXP2"};

    char *ConnectorNameArray[NUM_GPIOS] = {
        "J14",
        "J14",
        "J8",
        "J16",
        "J16",
    };

#endif /* #if defined(DEVICE_VP20) || defined(DEVICE_VP30) */


struct pTJLoopBack {
    unsigned char outbank;
    unsigned char outbit;
    unsigned char outpin;
    unsigned char inbank;
    unsigned char inbit;
    unsigned char inpin;
};


/** Pin mapping of the loopback testjig */
struct pTJLoopBack TJLoopBackTable[] =
{
    /* Expansion I/O */
    {pEXP2,31,5,pEXP1,8,41},
    {pEXP2,31,5,pEXP1,17,75},
    {pEXP2,29,11,pEXP1,9,43},
    {pEXP2,30,13,pEXP1,10,49},
    {pEXP1,2,17,pEXP1,11,51},
    {pEXP1,3,19,pEXP1,12,57},
    {pEXP1,4,25,pEXP1,13,59},
    {pEXP1,5,27,pEXP1,14,65},
    {pEXP1,6,33,pEXP1,15,76},
    {pEXP1,7,35,pEXP1,16,73},

    {pEXP1,18,2,pEXP1,27,36},
    {pEXP1,19,4,pEXP1,28,42},
    {pEXP1,20,10,pEXP1,29,44},
    {pEXP1,21,12,pEXP1,30,50},
    {pEXP1,22,18,pEXP1,31,52},
    {pEXP1,23,20,pEXP2,23,58},
    {pEXP1,24,26,pEXP2,24,60},
    {pEXP1,25,28,pEXP2,25,66},
    {pEXP1,1,30,pEXP2,26,68},
    {pEXP1,0,32,pEXP2,27,74},
    {pEXP1,26,34,pEXP2,28,76},

    /* Logic Analyzer Connector*/
    {pLA1,0,7,pLA1,8,39},
    {pLA1,1,11,pLA1,9,43},
    {pLA1,2,15,pLA1,10,47},
    {pLA1,3,19,pLA1,11,51},
    {pLA1,4,23,pLA1,12,55},
    {pLA1,5,27,pLA1,13,59},
    {pLA1,6,31,pLA1,14,63},
    {pLA1,7,35,pLA1,15,67},

    {pLA1,24,40,pLA1,16,8},
    {pLA1,25,44,pLA1,17,12},
    {pLA1,26,48,pLA1,18,16},
    {pLA1,19,20,pLA1,27,52},
    {pLA1,20,24,pLA1,28,56},
    {pLA1,21,28,pLA1,29,60},
    {pLA1,22,32,pLA1,30,64},
    {pLA1,23,36,pLA1,31,68},

    /* PMC Connector */
    {pPMC2,30,1,pPMC1,1,33},
    {pPMC2,1,3,pPMC1,3,35},
    {pPMC2,3,5,pPMC1,5,37},
    {pPMC2,5,7,pPMC1,7,39},
    {pPMC2,7,9,pPMC1,9,41},
    {pPMC2,9,11,pPMC1,11,43},
    {pPMC2,11,13,pPMC1,13,45},
    {pPMC2,13,15,pPMC1,15,47},
    {pPMC2,15,17,pPMC1,17,49},
    {pPMC2,17,19,pPMC1,19,51},
    {pPMC2,19,21,pPMC1,21,53},
    {pPMC2,21,23,pPMC1,23,55},
    {pPMC2,23,25,pPMC1,25,57},
    {pPMC2,25,27,pPMC1,27,59},
    {pPMC2,27,29,pPMC1,29,61},
    {pPMC2,29,31,pPMC1,31,63},

    {pPMC2,31,2,pPMC1,2,34},
    {pPMC2,2,4,pPMC1,4,36},
    {pPMC2,4,6,pPMC1,6,38},
    {pPMC2,6,8,pPMC1,8,40},
    {pPMC2,8,10,pPMC1,10,42},
    {pPMC2,10,12,pPMC1,12,44},
    {pPMC2,12,14,pPMC1,14,46},
    {pPMC2,14,16,pPMC1,16,48},
    {pPMC2,16,18,pPMC1,18,50},
    {pPMC2,18,20,pPMC1,20,52},
    {pPMC2,20,22,pPMC1,22,54},
    {pPMC2,22,24,pPMC1,24,56},
    {pPMC2,24,26,pPMC1,26,58},
    {pPMC2,26,28,pPMC1,28,60},
    {pPMC2,28,30,pPMC1,30,62},
    {pPMC1,0,32,pPMC2,0,64},

#if defined(DEVICE_VP20) || defined(DEVICE_VP30)

    /* Expansion I/O */
    {pEXP5,27,61,pEXP4,8,1},
    {pEXP5,28,63,pEXP4,9,3},
    {pEXP5,29,65,pEXP4,10,5},
    {pEXP5,30,67,pEXP4,11,7},
    {pEXP5,31,69,pEXP4,12,9},
    {pEXP6,22,71,pEXP4,13,11},
    {pEXP6,23,73,pEXP4,14,13},
    {pEXP6,24,75,pEXP4,15,15},
    {pEXP6,25,77,pEXP4,16,19},
    {pEXP6,26,81,pEXP4,17,21},
    {pEXP6,27,83,pEXP4,18,23},
    {pEXP6,28,85,pEXP4,19,25},
    {pEXP6,29,87,pEXP4,20,27},
    {pEXP6,30,89,pEXP4,21,29},
    {pEXP6,31,91,pEXP4,22,31},
    {pEXP5,13,95,pEXP4,23,33},
    {pEXP5,14,97,pEXP4,24,37},
    {pEXP5,15,99,pEXP4,25,39},
    {pEXP5,16,101,pEXP4,26,41},
    {pEXP5,17,103,pEXP4,27,43},
    {pEXP5,18,105,pEXP4,28,45},
    {pEXP5,19,107,pEXP4,29,47},
    {pEXP5,22,51,pEXP5,20,109},
    {pEXP5,23,53,pEXP5,21,111},
    {pEXP5,24,55,pEXP4,30,115},
    {pEXP5,25,57,pEXP4,31,117},
    {pEXP5,26,59,pEXP5,12,118},

    {pEXP3,16,4,pEXP3,2,62},
    {pEXP3,17,6,pEXP3,3,64},
    {pEXP3,18,8,pEXP3,4,66},
    {pEXP3,19,10,pEXP3,5,68},
    {pEXP3,20,12,pEXP3,6,70},
    {pEXP3,21,14,pEXP3,7,72},
    {pEXP3,22,16,pEXP3,8,74},
    {pEXP3,23,18,pEXP3,9,76},
    {pEXP3,24,22,pEXP3,10,78},
    {pEXP3,25,24,pEXP3,11,80},
    {pEXP3,26,26,pEXP3,12,84},
    {pEXP3,27,28,pEXP3,13,86},
    {pEXP3,28,30,pEXP3,14,88},
    {pEXP3,29,32,pEXP3,15,90},
    {pEXP3,30,34,pEXP5,0,94},
    {pEXP3,31,36,pEXP5,1,96},
    {pEXP4,0,38,pEXP5,2,98},
    {pEXP4,1,40,pEXP5,3,100},
    {pEXP4,2,44,pEXP5,4,102},
    {pEXP4,3,46,pEXP5,5,104},
    {pEXP4,4,48,pEXP5,6,106},
    {pEXP4,5,50,pEXP5,7,108},
    {pEXP4,6,52,pEXP5,8,110},
    {pEXP4,7,54,pEXP5,9,112},
    {pEXP3,0,58,pEXP5,10,114},
    {pEXP3,1,60,pEXP5,11,116},

    /* Second Logic Analyzer Connection */
    {pLA2,8,7,pLA2,16,39},
    {pLA2,9,11,pLA2,17,43},
    {pLA2,10,15,pLA2,18,47},
    {pLA2,11,19,pLA2,19,51},
    {pLA2,12,23,pLA2,20,55},
    {pLA2,13,27,pLA2,21,59},
    {pLA2,14,31,pLA2,22,63},
    {pLA2,15,35,pLA2,23,67},

    {pLA2,6,40,pLA2,24,8},
    {pLA2,7,44,pLA2,25,12},
    {pLA2,0,48,pLA2,26,16},
    {pLA2,1,52,pLA2,27,20},
    {pLA2,2,56,pLA2,28,24},
    {pLA2,3,60,pLA2,29,28},
    {pLA2,4,64,pLA2,30,32},
    {pLA2,5,68,pLA2,31,36},

#endif //defined(DEVICE_VP20) || defined(DEVICE_VP30)

};

/** Test the spare I/Os
  * Called by run_command, calls several gpio testing functions
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (ignored)
  * @param  *argv[] [IN] as passed by run_command (ignored)
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see gpio_test()
  * @see gpio_drive()
  * @ingroup TestSystem
  */
int do_siotest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]) {
    int ret_val = 0;

#if 0 /* Replaced by gpio_loopback() */
    /* GPIO Tests */
    if(gpio_test(1) != 0){
        printf("Walking 1 test FAILED!\n");
        ret_val = -1;
    }

    if(gpio_test(0) != 0){
        printf("Walking 0 test FAILED!\n");
        ret_val = -1;
    }
#endif

    /* GPIO Tests */
    if(gpio_loopback(1) != 0){
        ret_val = -1;
    }

    if(gpio_loopback(0) != 0){
        ret_val = -1;
    }

    if(ret_val == 0){
        printf("PASSED\n");
    } else {
        printf("FAILED\n");
    }

    return ret_val;
}


#if 0 /* Replaced by gpio_test() to conserve codespace */
/** With all GPIO bits output, walks a 1 across all GPIOs to check for shorts.
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int gpio_walking1(){
    int ret_val = 0;
    unsigned long mask;
    unsigned long data_write;
    unsigned long data_read;
    unsigned long register_offset;
    int reg;
    int bit;
    int i;

    /* all output and all cleared */
    mask = 0x00000000;
    for(reg = 0;reg < NUM_GPIOS;reg++){
        XGpio_mSetDataDirection(gGPIOAddrArray[reg], mask);
    }

    data_write = 0x00000000;
    for(reg = 0;reg < NUM_GPIOS;reg++){
        XGpio_mSetDataReg(gGPIOAddrArray[reg], data_write);
    }

    /* walk across all GPIOs */
    for(reg = 0;reg < NUM_GPIOS;reg++){
        data_write = 0x80000000;

        for(bit = 0;bit < 32;bit++){
            /* move the 1 along */
            XGpio_mSetDataReg(gGPIOAddrArray[reg], data_write);

            for(i = 0;i < NUM_GPIOS;i++){
                data_read = XGpio_mGetDataReg(gGPIOAddrArray[i]);
                /* if active register, check for proper 1 */
                if(i == reg){
                    if((data_read & gGPIOMaskArray[i]) != (data_write & gGPIOMaskArray[i])) {
                        ret_val = -1;
                        printf("%s is 0x%08x should be 0x%08x\n", gGPIONameArray[i],
                            (data_read & gGPIOMaskArray[i]), (data_write & gGPIOMaskArray[i]));
                    }
                }
                /* if not the active register, should be all 0 */
                else{
                    if((data_read & gGPIOMaskArray[i]) != 0x00000000) {
                        ret_val = -1;
                        printf("%s is 0x%08x should be 0x00000000\n", gGPIONameArray[i],
                            (data_read & gGPIOMaskArray[i]));
                    }
                }
            }

            /* move the 1 along */
            data_write  = data_write >> 1;
        }

        /* clear last active register */
        XGpio_mSetDataReg(gGPIOAddrArray[reg], 0x00000000);
    }

    return ret_val;
}
#endif



/** Check GPIO input/outputs using loopback testjig.
  *
  * Checks for shorts by making each bit in all GPIO banks the only output bit and
  * verifying that changing its value does not affect any of the input bits.
  * Pullups will force any input bits to 1 if they are not receiving any input.
  *
  * @param  level   [IN] 0 for walking 0, 1 for walking 1
  *
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int gpio_loopback(int level){
    int ret_val = 0;
    unsigned long data_read;
    unsigned long data_expect;
    unsigned long mask_out;
    unsigned long mask_in;
    int oreg,ireg;
    int obit,ibit;
    int i,j;

    /* Start with everything set as input.  Output level to 0.*/
    for(i = 0; i < NUM_GPIOS; i++){
        XGpio_mSetDataDirection(gGPIOAddrArray[i], 0xFFFFFFFF);
        XGpio_mSetDataReg(gGPIOAddrArray[i], 0x00000000);
    }

    /* Set direction of all output pins -- for walking 1 only. */
    if(level){
        for(i = 0; i < NUMOF(TJLoopBackTable); i++){
            oreg = TJLoopBackTable[i].outbank;
            obit = TJLoopBackTable[i].outbit;
            data_read = XGpio_mGetDataDirection(gGPIOAddrArray[oreg]);
            mask_out = 0x80000000 >> obit;
            XGpio_mSetDataDirection(gGPIOAddrArray[oreg], data_read & ~mask_out);
        }
    }


    /* Test each loopback individually */
    for(i = 0; i < NUMOF(TJLoopBackTable); i++){

        oreg = TJLoopBackTable[i].outbank;
        obit = TJLoopBackTable[i].outbit;
        ireg = TJLoopBackTable[i].inbank;
        ibit = TJLoopBackTable[i].inbit;

        mask_out = 0x80000000 >> obit;
        mask_in = 0x80000000 >> ibit;

        /* Special exception */
        if(oreg==pEXP2 && obit==31){
            mask_in = 0x80000000 >> 8;
            mask_in |= (0x80000000 >> 17);
        }

        mask_out = level ? mask_out : ~mask_out;
        mask_in = level ? mask_in : ~mask_in;

        /* Set the output (walking 1 only) */
        if(level){
            XGpio_mSetDataReg(gGPIOAddrArray[oreg], mask_out);
        }
        /* Set the output pin direction (for walking 0 only) */
        else {
            XGpio_mSetDataDirection(gGPIOAddrArray[oreg], mask_out);
        }

        udelay(100);
#if 0
//Print every test by register name / bit number
        printf("Driving %s bit %i to %i. Expecting input on %s bit %i\n",
            gGPIONameArray[oreg], obit, level,
            gGPIONameArray[ireg], ibit);
#endif

#if 0
//Print every test by connector name / pin number
        printf("Driving %s pin %i to %i. Expecting input on %s pin %i...\n",
            ConnectorNameArray[oreg], TJLoopBackTable[i].outpin, level,
            ConnectorNameArray[ireg], TJLoopBackTable[i].inpin);
#endif
        for(j = 0; j < NUM_GPIOS; j++){
            data_read = XGpio_mGetDataReg(gGPIOAddrArray[j]);

            /* If j==outbank==inbank */
            if(j==oreg && j==ireg){
                data_expect = level ?
                              (mask_out | mask_in) :
                              (mask_out & mask_in);
            }
            /* If j==outbank */
            else if(j==oreg){
                data_expect = mask_out;
            }
            /* If j==inbank */
            else if(j==ireg){
                data_expect = mask_in;
            }
            /* Else inactive register */
            else{
                data_expect = level ? 0x00000000 : 0xFFFFFFFF;
            }

            if(
                (data_read & gGPIOMaskArray[j]) !=
                (data_expect & gGPIOMaskArray[j])
              )
            {
                ret_val = -1;
                printf("***Error*** %s is 0x%08x. Should be 0x%08x\n",
                    gGPIONameArray[j],
                    (data_read & gGPIOMaskArray[j]),
                    (data_expect & gGPIOMaskArray[j]));

            }

        } //Verification loop

        /* Unset the output pin direction (for walking 0 only) */
        if(!level){
            XGpio_mSetDataDirection(gGPIOAddrArray[oreg], 0xFFFFFFFF);
        }
        /* Unset the output (walking 1 only) */
        else {
            XGpio_mSetDataReg(gGPIOAddrArray[oreg], 0x00000000);
        }
    } //TJLoopBackTable loop


    return ret_val;
}

#if 0 /* Replaced by gpio_loopback() */
/** Test GPIO input bits.
  * Prompts the user to set up and use the test jig to test the input bits
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int gpio_drive(){
    int ret_val = 0;
    char input_char;
    unsigned long mask;
    unsigned long data_write;
    unsigned long data_read;
    int reg;

    mask = 0xFFFFFFFF;
    for(reg = 0;reg < NUM_GPIOS;reg++){
        XGpio_mSetDataDirection(gGPIOAddrArray[reg], mask);
    }

    /** drive high and verify **/
    printf("Attach jig and Drive high.  Press key when ready, 'q' to abort\n");
    input_char = serial_getc();
    if((input_char == 'q') || (input_char == 'Q')){
        printf("ABORT!\n");
        return -1;
    }

    /* check for all 1s */
    data_write = 0xFFFFFFFF;
    for(reg = 0;reg < NUM_GPIOS;reg++){
        data_read = XGpio_mGetDataReg(gGPIOAddrArray[reg]);
        if((data_read & gGPIOMaskArray[reg]) != (data_write & gGPIOMaskArray[reg])){
            ret_val = -1;
            printf("%s is 0x%08x should be 0x%08x\n", gGPIONameArray[reg],
                (data_read & gGPIOMaskArray[reg]), (data_write & gGPIOMaskArray[reg]));
        }
    }
     /** drive low and verify **/
    printf("Drive low.  Press key when ready, 'q' to abort\n");
    input_char = serial_getc();
    if((input_char == 'q') || (input_char == 'Q')){
        printf("ABORT!\n");
        return -1;
    }

    /* check for all 0s */
    data_write = 0x00000000;
    for(reg = 0;reg < NUM_GPIOS;reg++){
        data_read = XGpio_mGetDataReg(gGPIOAddrArray[reg]);
        if((data_read & gGPIOMaskArray[reg]) != (data_write & gGPIOMaskArray[reg])){
            ret_val = -1;
            printf("%s is 0x%08x should be 0x%08x\n", gGPIONameArray[reg],
                (data_read & gGPIOMaskArray[reg]), (data_write & gGPIOMaskArray[reg]));
        }
    }

    return ret_val;
}
#endif

#if 0 /* Replaced by gpio_loopback() */
/** Check GPIO input/outputs.
  *
  * Checks for shorts by making each bit in all GPIO banks the only output bit and
  * verifying that changing its value does not affect any of the input bits.
  * Pullups will force any input bits to 1 if they are not receiving any input.
  *
  * @param  level   [IN] 0 for walking 0, 1 for walking 1
  *
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int gpio_test(int level){
    int ret_val = 0;
    unsigned long mask;
    unsigned long data_read;
    unsigned long data_expect;
    int reg;
    int i;
    int bit;

    /* All input for walking 0, all output for walking 1 */
    mask = level ? 0x00000000 : 0xFFFFFFFF;

    for(reg = 0;reg < NUM_GPIOS;reg++){
        XGpio_mSetDataDirection(gGPIOAddrArray[reg], mask);

        /* Note: No affect on inputs.  Do it anyway. */
        XGpio_mSetDataReg(gGPIOAddrArray[reg], 0x00000000);
    }

    /* Walk all registers */
    for(reg = 0;reg < NUM_GPIOS;reg++){
        mask = 0x80000000;

        for(bit = 0;bit < 32;bit++){
            if(level){
                /* move the one along */
                XGpio_mSetDataReg(gGPIOAddrArray[reg], mask);
            }
            else {
                /* invert the mask for convenience */
                mask = ~mask;

                /* move the output along */
                XGpio_mSetDataDirection(gGPIOAddrArray[reg], mask);
                XGpio_mSetDataReg(gGPIOAddrArray[reg], 0x00000000);
            }
            udelay(100);

            for(i = 0;i < NUM_GPIOS;i++){
                data_read = XGpio_mGetDataReg(gGPIOAddrArray[i]);
                /* if active register, check for proper value */
                if(i == reg){
                    if((data_read & gGPIOMaskArray[i]) != (mask & gGPIOMaskArray[i])) {
                        ret_val = -1;
                        printf("%s is 0x%08x should be 0x%08x\n", gGPIONameArray[i],
                            (data_read & gGPIOMaskArray[i]), (mask & gGPIOMaskArray[i]));
                    }
                }
                /* if not the active register */
                else{
                    data_expect = level ? 0 : (0xFFFFFFFF & gGPIOMaskArray[i]);
                    if((data_read & gGPIOMaskArray[i]) != data_expect) {
                        ret_val = -1;
                        printf("%s is 0x%08x should be 0x%08x\n", gGPIONameArray[i],
                            (data_read & gGPIOMaskArray[i]), data_expect);
                    }
                }
            }

            /* Undo our convenience inversion */
            if(!level){
                mask = ~mask;
            }
            mask  = mask >> 1;
        }

        /* clear last active bit */
        if(level){
            XGpio_mSetDataReg(gGPIOAddrArray[reg], 0x00000000);
        } else {
            XGpio_mSetDataDirection(gGPIOAddrArray[reg], 0xFFFFFFFF);
        }
    }

    return ret_val;
}
#endif

#if 0 /* Replaced by gpio_test() to conserve codespace */
/** Check GPIO input pullups, and identify any shorts between the bits.
  * Checks for shorts by making each bit in all 5 GPIOs the only output bit and
  *     verifying that changing its value does not affect any of the input bits.
  * Pullups will force any input bits to 1 if they are not receiving any input
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int gpio_walkingoutput(){
    int ret_val = 0;
    unsigned long not_mask;
    unsigned long data_read;
    unsigned long register_offset;
    int reg;
    int i;
    int bit;

    /* all input */
    for(reg = 0;reg < NUM_GPIOS;reg++){
        XGpio_mSetDataDirection(gGPIOAddrArray[reg], 0xFFFFFFFF);
    }

    /* begin pmc1 and walk across all 5 */
    for(reg = 0;reg < NUM_GPIOS;reg++){
        /* choose which register to walk */
        not_mask = 0x80000000;

        for(bit = 0;bit < 32;bit++){
            /* move the output along. ~not_mask provides a walking 0 */
            XGpio_mSetDataDirection(gGPIOAddrArray[reg], (~not_mask));
            XGpio_mSetDataReg(gGPIOAddrArray[reg], 0x00000000);
            udelay(100);

            for(i = 0;i < NUM_GPIOS;i++){
                data_read = XGpio_mGetDataReg(gGPIOAddrArray[i]);
                /* if active register, check for proper 1 */
                if(i == reg){
                    if((data_read & gGPIOMaskArray[i]) != ((~not_mask) & gGPIOMaskArray[i])) {
                        ret_val = -1;
                        printf("%s is 0x%08x should be 0x%08x\n", gGPIONameArray[i],
                            (data_read & gGPIOMaskArray[i]), ((~not_mask) & gGPIOMaskArray[i]));
                    }
                }
                /* if not the active register, should be all 0 */
                else{
                    if((data_read & gGPIOMaskArray[i]) != (0xFFFFFFFF & gGPIOMaskArray[i])) {
                        ret_val = -1;
                        printf("%s is 0x%08x should be 0x%08x\n", gGPIONameArray[i],
                            (data_read & gGPIOMaskArray[i]), (0xFFFFFFFF & gGPIOMaskArray[i]));
                    }
                }
            }

            /* move the 1 along, so the 0 in ~not_mask will walk */
            not_mask  = not_mask >> 1;
        }

        /* clear last active register */
        XGpio_mSetDataDirection(gGPIOAddrArray[reg], 0xFFFFFFFF);
    }

    return ret_val;
}
#endif


/** Console command to test the system ace.
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (ignored)
  * @param  *argv[] [IN] as passed by run_command (ignored)
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see ace_signature()
  * @ingroup TestSystem
  */
int do_acetest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int ret_val = 0;

    ret_val = ace_signature();
    if(ret_val != 0){
        printf("FAILED!\n");
        return ret_val;
    }
    else
    {
        printf("PASSED\n");
    }

    return ret_val;
}

/** Check compact flash card for valid boot sector signature.
  * Exercises the system ace component by checking boot sector data.  Requires
  *     that a valid compact flash card be present.
  * Note that this function will go into an infinite loop if no flash card is
  *     present.
  * @return
  *      <B>0</B> if passed<BR>
  *     <B>-1</B> if failed
  * @ingroup TestSystem
  */
int ace_signature(){
    unsigned char read_buffer[XSA_CF_SECTOR_SIZE];
    int read_result;
    int ret_val = 0;

    /** Get a lock **/
    XSysAce_mWaitForLock(SYSACE_BASEADDR);

    /* Make sure the device is ready for a command */
    if (XSysAce_mIsReadyForCmd(SYSACE_BASEADDR) == 0)
    {
        printf("SysAce error\n");
        return -1;
    }

    /** read boot sector **/
    read_result = XSysAce_ReadSector(SYSACE_BASEADDR, 0, read_buffer);
    if (read_result == 0)
    {
        printf("SysAce error\n");
        return -1;
    }

    /* Release the lock */
    XSysAce_mAndControlReg(SYSACE_BASEADDR, ~XSA_CR_LOCKREQ_MASK);

    /** validate sector data **/
    /* currently just checking for end of boot sector signature */
    if((read_buffer[510] != 0x55) || (read_buffer[511] != 0xaa))
    {
        printf("Signature not found!\n");
        ret_val = -1;
    }

    return ret_val;
}


/** Console command to initialize the local-pci bridge.
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (ignored)
  * @param  *argv[] [IN] as passed by run_command (ignored)
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see init_local_to_pci_bridge()
  * @ingroup TestSystem
  */
int do_pciinit(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int ret_val = 0;

    printf("Initializing PLX bridge:");
    ret_val = init_local_to_pci_bridge();
    if(ret_val != 0){
        printf("F!\n");
        return ret_val;
    }
    else
    {
        printf("PASSED\n");
    }

    return 0;
}

/** Console command to scan the pci bus and initialize the devices found.
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (ignored)
  * @param  *argv[] [IN] as passed by run_command (ignored)
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see pci_scan()
  * @ingroup TestSystem
  */
int do_pciscan (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int ret_val = 0;
    int num_devices = 0;

    printf("Scanning pci bus:");
    ret_val = pci_scan(&num_devices);
    if(ret_val != 0){
        printf("FAILED!\n");
        return ret_val;
    }
    else
    {
        printf("PASSED\n");
    }

    return ret_val;
}

/** Console command to set verbosity level for debugging.
  * <pre>
  * verb       - displays the current verbosity level
  * verb VALUE - sets the verbosity level to VALUE
  * </pre>
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] 1 if no arguments, 2 if new value
  * @param  *argv[] [IN] argv[1] contains new value, or NULL to display current
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int do_verbosity(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int ret_val = 0;
    int i;

    /** display verbosity level if no args **/
    if(argc < 2){
        printf("Verbosity is %d\n", gVerbosityLevel);
    }
    else if(argc == 2){
        gVerbosityLevel = atoi(argv[1]);
        printf("Verbosity is %d\n", gVerbosityLevel);
    }
    else{
        printf("Too many arguments\n");
    }

    return ret_val;
}

/** Console command to read pci config space.
  * This function assumes that bus and function are both 0.
  * Proper syntax is: -> readconfig [device] [offset] [1/2/4]
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (4 is only valid value)
  * @param  *argv[] [IN] contains parameters to use
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see pci_read_config_byte()
  * @see pci_read_config_word()
  * @see pci_read_config_word_long()
  * @ingroup TestSystem
  */
int do_readconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int ret_val = 0;
    int i;
    int device_id;
    unsigned long offset;
    unsigned long value;
    int size;
    unsigned long read_value;

    if(argc < 4){
        printf("Not enough arguments: readconfig [device] [offset] [size]\n");
    }
    else if(argc == 4){
        /* get values */
        device_id = simple_strtoul(argv[1], NULL, 0);
        offset    = simple_strtoul(argv[2], NULL, 16);
        size      = simple_strtoul(argv[3], NULL, 0);

        switch(size){
            case 1:{
                read_value = pci_read_config_byte(0, device_id,  0, offset);
                printf("Value is 0x%02x\n", read_value);
                break;
            }
            case 2:{
                read_value = pci_read_config_word(0, device_id,  0, offset);
                printf("Value is 0x%04x\n", read_value);
                break;
            }
            case 4:{
                read_value = pci_read_config_word_long(0, device_id,  0, offset);
                printf("Value is 0x%08x\n", read_value);
                break;
            }
            default:{
                printf("Size must be 1, 2 or 4\n");
                break;
            }
        }
    }
    else{
        printf("Too many arguments\n");
    }

    return ret_val;
}

/** Console command to write pci config space.
  * This function assumes that bus and function are both 0.
  * Proper syntax is: -> writeconfig [device] [offset] [value] [1/2/4]
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (5 is only valid value)
  * @param  *argv[] [IN] contains parameters to use
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see pci_write_config_byte()
  * @see pci_write_config_word()
  * @see pci_write_config_word_long()
  * @ingroup TestSystem
  */
int do_writeconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int ret_val = 0;
    int i;
    int device_id;
    unsigned long offset;
    unsigned long value;
    int size;

    if(argc < 5){
        printf("Not enough arguments: writeconfig [device] [offset] [value] [size]\n");
    }
    else if(argc == 5){
        /* get values */
        device_id = simple_strtoul(argv[1], NULL, 0);
        offset    = simple_strtoul(argv[2], NULL, 16);
        value     = simple_strtoul(argv[3], NULL, 16);
        size      = simple_strtoul(argv[4], NULL, 0);

        switch(size){
            case 1:{
                pci_write_config_byte(0, device_id,  0, offset, value);
                break;
            }
            case 2:{
                pci_write_config_word(0, device_id,  0, offset, value);
                break;
            }
            case 4:{
                pci_write_config_word_long(0, device_id,  0, offset, value);
                break;
            }
            default:{
                printf("Size must be 1, 2 or 4\n");
                break;
            }
        }
    }
    else{
        printf("Too many arguments\n");
    }

    return ret_val;
}

#define ETH1_CTRL_REG_ADD       0x4FA00000
#define ETH1_READ_REG_ADD       0x4FA00004
#define ETH2_CTRL_REG_ADD       0x4FA00008
#define ETH2_READ_REG_ADD       0x4FA0000C
#define ETH1_TBUFF_BASE         0x4FC00000
#define ETH1_RBUFF_BASE         0x4FD00000
#define ETH2_TBUFF_BASE         0x4FE00000
#define ETH2_RBUFF_BASE         0x4FF00000

#define ETH_BUFF_NUM_DWORDS     128
#define ETH_READY               0x80000000
#define ETH_START               0xFFFFFFFF

/** Console command to run GigaBit ethernet test.
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (ignored)
  * @param  *argv[] [IN] as passed by run_command (ignored)
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see ethernet_test()
  * @ingroup TestSystem
  */
int do_eth_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int ret_val = 0;

    ret_val = ethernet_test();
    if(ret_val != 0){
        printf("FAILED!\n");
    }
    else
    {
        printf("PASSED.\n");
    }

}

/** Wait for ready bit, then read the GigaBit ethernet test read register.
  * Polls the ready bit of the read register, and once the bit becomes set,
  *     returns the value of the desired read register.  Since it waits for the
  *     ready bit, it is used to poll for the ready bit after a command has been
  *     issued.
  * @param  one_or_two [IN] 1 or 2; which of the GigaBit ethernet controllers
  * @return the value of the desired read register
  * @ingroup TestSystem
  */
unsigned long read_eth_read_reg(int one_or_two){
    unsigned long read_value;
    if(gVerbosityLevel > 0)
        printf("read %d\n", one_or_two);

    /* poll ready bit */
    if(one_or_two == 1){
        read_value = *((unsigned long *)ETH1_READ_REG_ADD);
    if(gVerbosityLevel > 0)
        printf("     %8x\n", read_value);
        while((read_value & ETH_READY) == 0){
            read_value = *((unsigned long *)ETH1_READ_REG_ADD);
            if(gVerbosityLevel > 0)
                printf("     %8x\n", read_value);
        }
    }
    else{
        read_value = *((unsigned long *)ETH2_READ_REG_ADD);
        if(gVerbosityLevel > 0)
            printf("     %8x\n", read_value);
        while((read_value & ETH_READY) == 0){
            read_value = *((unsigned long *)ETH2_READ_REG_ADD);
            if(gVerbosityLevel > 0)
                printf("     %8x\n", read_value);
        }
    }

    return read_value;
}

/** Write to a GigaBit ethernet test control register.
  * Calls read_eth_read_reg() before and after the write to ensure the register
  *     is ready.
  * @param  one_or_two  [IN] 1 or 2; which of the GigaBit ethernet controllers
  * @param  write_value [IN] the value to be written
  * @ingroup TestSystem
  */
void write_eth_ctrl_reg(int one_or_two, unsigned long write_value){
    if(gVerbosityLevel > 0)
        printf("write %d %08x\n", one_or_two, write_value);

    if(one_or_two == 1){
        /* wait for ready state */
        read_eth_read_reg(1);
        *((unsigned long *)ETH1_CTRL_REG_ADD) = write_value;
        read_eth_read_reg(1);
    }
    else{
        /* wait for ready state */
        read_eth_read_reg(2);
        *((unsigned long *)ETH2_CTRL_REG_ADD) = write_value;
        read_eth_read_reg(2);
    }
}

/** Write the start bit of the GigaBit ethernet test.
  * Ensures that the ethernet tester is ready before setting the bit
  * @param  one_or_two [IN] 1 or 2; which of the GigaBit ethernet controllers
  * @ingroup TestSystem
  */
void eth_start(int one_or_two){
    if(one_or_two == 1){
        /* wait for ready state */
        read_eth_read_reg(1);
        *((unsigned long *)ETH1_READ_REG_ADD) = ETH_START;
    }
    else{
        /* wait for ready state */
        read_eth_read_reg(2);
        *((unsigned long *)ETH2_READ_REG_ADD) = ETH_START;
    }

}

/** Run the GigaBit Ethernet test.
  * Check initial values of the registers, and transmit and recieve from both
  *     ports.  After calling this function, the board must be reset for this
  *     test to pass again.
  * @return
  * <pre>
  *      0 if passed
  *      1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int ethernet_test(){
    int ret_val = 0;
    unsigned long read_value;
    int i;
    int error_count;
    int clock_changes;
    unsigned long last_read;

    /* initialize */
    read_value = read_eth_read_reg(1);
    if((read_value & 0xFF1F0000) != 0x80010000){
        printf("Read1 is 0x%08x(0x%08x) should be 0x80010000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    read_value = read_eth_read_reg(2);
    if((read_value & 0xFF1F0000) != 0x80010000){
        printf("Read2 is 0x%08x(0x%08x) should be 0x80010000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    write_eth_ctrl_reg(1, 0x10184900);
    write_eth_ctrl_reg(1, 0x02000000);
    write_eth_ctrl_reg(2, 0x10184900);
    write_eth_ctrl_reg(2, 0x02000000);

    read_value = read_eth_read_reg(1);
    if((read_value & 0xFF0F0000) != 0x80000000){
        printf("Read1 is 0x%08x(0x%08x) should be 0x80000000.\n",
            read_value, (read_value & 0xFF0F0000));
        ret_val = 1;
    }

    read_value = read_eth_read_reg(2);
    if((read_value & 0xFF0F0000) != 0x80000000){
        printf("Read2 is 0x%08x(0x%08x) should be 0x80000000.\n",
            read_value, (read_value & 0xFF0F0000));
        ret_val = 1;
    }

    write_eth_ctrl_reg(1, 0x12184100);
    write_eth_ctrl_reg(2, 0x12184100);

    read_value = read_eth_read_reg(1);
    if((read_value & 0xFF1F0000) != 0x98010000){
        printf("Read1 is 0x%08x(0x%08x) should be 0x98010000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    read_value = read_eth_read_reg(2);
    if((read_value & 0xFF1F0000) != 0x98010000){
        printf("Read2 is 0x%08x(0x%08x) should be 0x98010000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    write_eth_ctrl_reg(1, 0x120011C0);

    write_eth_ctrl_reg(2, 0x120011C0);

    for(i = 0;i < ETH_BUFF_NUM_DWORDS;i++){
        *(((unsigned long *)ETH1_TBUFF_BASE) + i) = 0x00000000;
        *(((unsigned long *)ETH1_RBUFF_BASE) + i) = 0x11111111;
        *(((unsigned long *)ETH2_TBUFF_BASE) + i) = 0x00000000;
        *(((unsigned long *)ETH2_RBUFF_BASE) + i) = 0x22222222;
    }


        *(((unsigned long *)ETH1_TBUFF_BASE) + 0) = 0x55555555;
        *(((unsigned long *)ETH2_TBUFF_BASE) + 0) = 0x55555555;

        *(((unsigned long *)ETH1_TBUFF_BASE) + 1) = 0xaaaaaaaa;
        *(((unsigned long *)ETH2_TBUFF_BASE) + 1) = 0xaaaaaaaa;

        *(((unsigned long *)ETH1_TBUFF_BASE) + 2) = 0x01020408;
        *(((unsigned long *)ETH2_TBUFF_BASE) + 2) = 0x01020408;

        *(((unsigned long *)ETH1_TBUFF_BASE) + 3) = 0x10204080;
        *(((unsigned long *)ETH2_TBUFF_BASE) + 3) = 0x10204080;


    for(i = 4;i < ETH_BUFF_NUM_DWORDS;i++){
        *(((unsigned long *)ETH1_TBUFF_BASE) + i) = 0xdeadbeef;
        *(((unsigned long *)ETH2_TBUFF_BASE) + i) = 0xdeadbeef;
    }

    eth_start(1);
    udelay(2000000);

    eth_start(2);
    udelay(2000000);

    read_value = read_eth_read_reg(1);
    if((read_value & 0xFF1F0000) != 0x801B0000){
        printf("Read1 is 0x%08x(0x%08x) should be 0x801B0000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    read_value = read_eth_read_reg(2);
    if((read_value & 0xFF1F0000) != 0x801B0000){
        printf("Read2 is 0x%08x(0x%08x) should be 0x801B0000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    write_eth_ctrl_reg(1, 0x10001140);
    write_eth_ctrl_reg(2, 0x10001140);

    eth_start(1);
    udelay(10);

    eth_start(2);
    udelay(10);

    error_count = 0;
    for(i = 0;i < ETH_BUFF_NUM_DWORDS;i++){
        if(*(((unsigned long *)ETH1_TBUFF_BASE) + i) != *(((unsigned long *)ETH2_RBUFF_BASE) + i)){
            error_count++;
        }
    }

    if(error_count != 0){
        printf("%d words do not match in Eth1->Eth2 transfer.\n", error_count);
        ret_val = 1;
    }

    error_count = 0;
    for(i = 0;i < ETH_BUFF_NUM_DWORDS;i++){
        if(*(((unsigned long *)ETH2_TBUFF_BASE) + i) != *(((unsigned long *)ETH1_RBUFF_BASE) + i)){
            error_count++;
        }
    }

    if(error_count != 0){
        printf("%d words do not match in Eth2->Eth1 transfer.\n", error_count);
        ret_val = 1;
    }



    read_value = read_eth_read_reg(1);
    if((read_value & 0xFF1F0000) != 0x80090000){
        printf("Read1 is 0x%08x(0x%08x) should be 0x80090000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    read_value = read_eth_read_reg(2);
    if((read_value & 0xFF1F0000) != 0x80090000){
        printf("Read2 is 0x%08x(0x%08x) should be 0x80090000.\n",
            read_value, (read_value & 0xFF1F0000));
        ret_val = 1;
    }

    last_read = read_eth_read_reg(1);
    clock_changes = 0;
    for(i = 0;i < 7;i++){
        read_value = read_eth_read_reg(1);
        if((read_value & 0x00E00000) != (last_read & 0x00E00000)){
            clock_changes++;
        }

        last_read = read_value;
    }

    if(clock_changes == 0){
        printf("Eth1 clock did not change.\n");
        ret_val = 1;
    }

    last_read = read_eth_read_reg(2);
    clock_changes = 0;
    for(i = 0;i < 7;i++){
        read_value = read_eth_read_reg(2);
        if((read_value & 0x00E00000) != (last_read & 0x00E00000)){
            clock_changes++;
        }

        last_read = read_value;
    }

    if(clock_changes == 0){
        printf("Eth2 clock did not change.\n");
        ret_val = 1;
    }

    return ret_val;
}


/** Runs all code that must be executed before the PPCBoot Lite prompt.
  * This function runs a variety of tests to validate the board.  Written to be run at the board
  *     production site to streamline the board testing.  Prompts user to cancel out of tests, then
  *     runs all the tests required in section 4.3.3 of DOC-003246 Ap107-6PCI Production Test
  *     Procedure, EXCEPT for GPIO drive test (part of siotest), as it requires a test jig.
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int TestSystemAutoRun(){
    int i = 0;
    int wait = 0;
    int abort = 0;
    int errors = 0;
    int num_devices = 0;


    printf("\n\n\n\n\n\n\n\n\n");
    printf(TEST_AUTOBOOT_PROMPT, (MAX_BOOT_WAIT/10));
    printf("0");

    /* count down */
    while((abort == 0) && (wait < MAX_BOOT_WAIT)){
        if(serial_tstc()){
            if(serial_getc() == ' '){
                abort = 1;
            }
        }
        udelay(TENTH_OF_A_SECOND);
        if((wait % 10) == 9){
            printf("\r%d", (wait + 1)/10);
        }
        wait++;
    }

    printf("\b");

    /* if not aborted, run tests*/
    if(abort == 1){
        printf("\n\n\n\n");
        return 0;
    }
    else{

        /* mtest */
        printf("\n>>> Memory Test\n");
        if(memtest(0, 0, 0) != 0){
            printf("***FAILED\n");
            errors = 1;
        }

        /* acetest */
        printf("\n>>> SystemACE Test\n");
        if(ace_signature() != 0){
            printf("***FAILED\n");
            errors = 1;
        }

        /* pciinit */
        printf("\n>>> PCI Tests\n");
        if(init_local_to_pci_bridge() != 0){
            printf("***FAILED Local-PCI init!\n");
            errors = 1;
        }
        if(init_pci_to_pci_bridge(CFG_PCI_PCI_BRIDGE_DEV_ID) != 0){
            printf("***FAILED PCI-PCI init!\n");
            errors = 1;
        }

        /* pciscan: 2 or 3 devices is acceptable (3 if PMC card is present) */
        num_devices = 0;
        if(pci_scan(&num_devices) != 0){
            printf("***FAILED PCI scan!\n");
            errors = 1;
        }
        else if((num_devices < 2) || (num_devices > 3)){
            printf("***BAD device count: %d (expected 2 or 3)\n", num_devices);
            errors = 1;
        }
        else{
            printf("Found %d PCI devices.\n", num_devices);
        }

        /* inttest */
        printf("\n>>> Int Test\n");
        if(int_test() != 0){
            printf("***FAILED\n");
            errors = 1;
        }

        /* srom write */
        printf("\n>>> SROM Test\n");
        if(program_SROM() != 0){
            printf("***FAILED\n");
            errors = 1;
        }

        /* Ethernet interface test */
        printf("\n>>> Ether Test\n");
        if(ethernet_test() != 0){
            printf("***FAILED\n");
            errors = 1;
        }

#if 0 /* Replaced by gpio_loopback() */
        /* GPIO Tests */
        printf("\n>>> GPIO Tests\n");
        if(gpio_test(1) != 0){
            printf("***FAILED Walking 1\n");
            errors = 1;
        }
        if(gpio_test(0) != 0){
            printf("***FAILED Walking 0\n");
            errors = 1;
        }
#endif

        /* GPIO Tests */
        printf("\n>>> GPIO Tests\n");
        if(gpio_loopback(1) != 0){
            printf("***FAILED Walking 1 loopback test\n");
            errors = 1;
        }
        if(gpio_loopback(0) != 0){
            printf("***FAILED Walking 0 loopback test\n");
            errors = 1;
        }



        printf("\n*** Test Suite %s ***\n", (errors == 0) ? "PASSED" : "FAILED");

        /* CPLD write prompt */
        printf("Press 's' for reconfigure or any key to exit.\n");
        if(tolower(serial_getc()) == 's'){
            *((unsigned char *)CPLD_BASEADDR) = CPLD_SW_RECONFIGURE;
        }
    }
}

/** Display and initialize a pci device found on the local Pci bus.
  * This function displays the device ID and vendor ID of the device, and if
  *     it's a recognized device, calls the appropriate init function.
  * @param  bus [IN] device's bus
  * @param  dev [IN] device's device number
  * @param  fn  [IN] device's function
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int pci_initdevice(int bus, int dev, int fn){
    int ret_val = 0;
    unsigned short read_val;
    int i;
    unsigned short device_id;
    unsigned short vendor_id;

    /* for now, simply dump some of the config registers */
    printf("Dev %02d Fn %02d:\n", dev, fn);

    device_id = pci_read_config_word(bus, dev, fn, 2);
    vendor_id = pci_read_config_word(bus, dev, fn, 0);
    printf("DevID: 0x%04x\tVenID: 0x%04x\n", device_id, vendor_id);

    /* Intel 21555 Pci-Pci bridge */
    if((device_id == 0xb555) && (vendor_id == 0x8086)){
        printf("Init 21555 Pci-Pci bridge:");
        G_21555_device_id = dev;
        ret_val = init_pci_to_pci_bridge(dev);
        if(ret_val != 0){
            printf("FAILED!\n");
        }
        else{
            printf("complete.\n");
        }
    }
    /* Intel 82559ER Ethernet */
    if((device_id == 0x1209) && (vendor_id == 0x8086)){
        printf("Init 82559ER Ethernet:");
        G_ethernet_device_id = dev;
        ret_val = init_82559ER(dev);
        if(ret_val != 0){
            printf("FAILED!\n");
        }
        else{
            printf("complete.\n");
        }
    }

    return ret_val;
}

#define SROM_DATA_ARRAY_SIZE 67
#define SROM_DATA_ARRAY { \
    /* preload enable (sets bit 7 for preload enable) */ \
    0x80, 0x00, 0x00, 0x00, \
    /* Primary Class Code */ \
    0x00, 0x00, 0x00, \
    /* Subvendor IDs */ \
    0x00, 0x00, 0x00, 0x00, \
    /* Primary Min GNT, Max LAT */ \
    0x00, 0x00, \
    /* Secondary Class Code */ \
    0x00, 0x00, 0x00, \
    /* Secondary Min GNT, Max LAT */ \
    0x00, 0x00, \
    /* Downstream Mem 0 - CSRs only (Set a 4K window size) */ \
    0x00, 0xF0, 0xFF, 0xFF, \
    /* Downstream Mem 1 or I/O (Set 256 byte I/O window size) */ \
    0x01, 0xFF, 0xFF, 0xFF, \
    /* Downstream Mem 2 (Set 128MB memory window size) */ \
    0x00, 0x00, 0x00, 0xF8, \
    /* Downstream Mem 3 (Set 64MB memory window size) */ \
    0x00, 0x00, 0x00, 0xFC, \
    /* Downstream Mem 3 Upper 32 (disabled)*/ \
    0x00, 0x00, 0x00, 0x00, \
    /* Expansion ROM (Set 1MB expansion ROM size) */ \
    0x00, 0x00, \
    /* Upstream Mem 0 or I/O (Set 256 byte I/O window size) */ \
    0x01, 0xFF, 0xFF, 0xFF, \
    /* Upstream Mem 1 (Set 1MB memory window size) */ \
    0x00, 0x00, 0xF0, 0xFF, \
    /* Chip Control 0 */ \
    0x00, \
    /* clear lockout bit */ \
    0x00, \
    /* Chip Control 1 */ \
    0x00, \
    /* LUT disable,i2o disable */ \
    0x00, \
    /* Arbiter control (Sets internal 21555 secondary bus request to high priority ring) */ \
    0x00, 0x02, \
    /* System error disable */ \
    0x00, 0x00, \
    /* Power management */ \
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }

#define SROM_OP_GENERAL         0x00000000
#define SROM_OP_WRITEENABLE     0x00000180
#define SROM_OP_WRITEDISABLE    0x00000000
#define SROM_OP_ERASEALL        0x00000100
#define SROM_OP_WRITE           0x00000200
#define SROM_OP_READ            0x00000400

#define SROM_START_BUSY_BIT     0x01
#define SROM_POLL_BIT           0x08

/** Program the intel 21555 Pci-Pci bridge's SROM with the default data array.
  * This function writes the default srom data array, and then verifies that it
  *     was written.  This function could easily be altered to take an array as
  *     an argument.
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int program_SROM(){
    int ret_val = 0;
    unsigned char byte_value;
    int i = SROM_DATA_ARRAY_SIZE;
    unsigned char byte_array[SROM_DATA_ARRAY_SIZE] = SROM_DATA_ARRAY;

    /* check for proper pci initialization */
    if(G_21555_device_id == -1){
        printf("pci uninitialized\n");
        return 1;
    }

    /* write enable */
    /* check par and ser start and busy bits are clear */
    while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);

    /* setup 21555 for write enable, base = 21555 memory mapped CSR base address */
    write4((PCI_MEM_21555_CSR_BASE + 0xCC), (SROM_OP_GENERAL | SROM_OP_WRITEENABLE));

    /* kick the start bit */
    write1((PCI_MEM_21555_CSR_BASE + 0xCF), SROM_START_BUSY_BIT);

    /* wait for busy bit to deassert */
    while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);

    /* program data */
    printf("Programming SROM:\n");
    for(i = 0;i < SROM_DATA_ARRAY_SIZE;i++){
        /* setup for write command. i = srom offset, sBuffer[i] = data to write */
        write4((PCI_MEM_21555_CSR_BASE + 0xCC), (i | SROM_OP_WRITE));
        write1((PCI_MEM_21555_CSR_BASE + 0xCA), byte_array[i]);

        /* kick the start bit */
        write1((PCI_MEM_21555_CSR_BASE + 0xCF), SROM_START_BUSY_BIT);

        /* wait for busy bit to deassert */
        while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);

        /* we are now in write mode, kick the start bit again to program the data*/
        write1((PCI_MEM_21555_CSR_BASE + 0xCF), SROM_START_BUSY_BIT);

        while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);

        /* keep issuing a start command to see if the SROM has accepted the data */
        /* by checking the poll bit */
        while(read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_POLL_BIT){
            write1(PCI_MEM_21555_CSR_BASE + 0xCF,SROM_START_BUSY_BIT);
            while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);
        }

        printf(".");
    }
    printf("done\n");

    /* disable writing */
    /* setup 21555 for write enable, base = 21555 memory mapped CSR base address */
    write4((PCI_MEM_21555_CSR_BASE + 0xCC), (SROM_OP_GENERAL | SROM_OP_WRITEDISABLE));

    /* kick the start bit */
    write1((PCI_MEM_21555_CSR_BASE + 0xCF), SROM_START_BUSY_BIT);

    /* wait for busy bit to deassert */
    while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);

    /* read some crap */
    printf("Validating SROM:\n");
    for(i = 0;i < SROM_DATA_ARRAY_SIZE;i++){
        /* issue a read command */
        write4((PCI_MEM_21555_CSR_BASE + 0xCC), (i | SROM_OP_READ));

        /* kick the start bit */
        write1((PCI_MEM_21555_CSR_BASE + 0xCF), SROM_START_BUSY_BIT);

        /* wait for busy bit to deassert */
        while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);

        /* read the data and compare to desired value */
        byte_value = read1(PCI_MEM_21555_CSR_BASE + 0xCA);
        if(byte_value != byte_array[i]){
            ret_val = -1;
            printf("!");
        }
        else{
            printf(".");
        }
    }
    printf("passed\n");

    return ret_val;
}

/** Display the contents of the Intel 21555 Pci-Pci bridge SROM.
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int read_SROM(){
    int i;
    unsigned char byte_value;

    /* check for proper pci initialization */
    if(G_21555_device_id == -1){
        printf("pci uninitialized\n");
        return 1;
    }

    for(i = 0;i < SROM_DATA_ARRAY_SIZE;i++){
        /* issue a read command */
        write4((PCI_MEM_21555_CSR_BASE + 0xCC), (i | SROM_OP_READ));

        /* kick the start bit */
        write1((PCI_MEM_21555_CSR_BASE + 0xCF), SROM_START_BUSY_BIT);

        /* wait for busy bit to deassert */
        while (read1(PCI_MEM_21555_CSR_BASE + 0xCF) & SROM_START_BUSY_BIT);

        /* read the data and compare to desired value */
        byte_value = read1(PCI_MEM_21555_CSR_BASE + 0xCA);

        printf("%02x ", byte_value);

        if((i % 16) == 15){
            printf("\n");
        }
    }

    printf("\n");
    return 0;
}


/** Console command to call Intel 21555 Pci-Pci bridge SROM functions.
  * <pre>
  * srom write - Write default data array to the SROM
  * srom read  - display contents of the SROM
  * </pre>
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command (ignored)
  * @param  *argv[] [IN] as passed by run_command (ignored)
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see program_SROM()
  * @see read_SROM()
  * @ingroup TestSystem
  */
int do_program_SROM(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){

    if(argc < 2){
        printf("read or write?\n");
    }
    else if(argc == 2){
        if(strcmp(argv[1], "write") == 0){
            if(program_SROM() != 0){
                printf("program_SROM() failed!\n");
            }
            else{
                printf("program_SROM() passed.\n");
            }
        }
        else if(strcmp(argv[1], "read") == 0){
            if(read_SROM() != 0){
                printf("read_SROM() failed!\n");
            }
            else{
                printf("read_SROM() passed.\n");
            }
        }
    }
    else{
        printf("Too many arguments\n");
    }
}

/** Initialize the onboard Intel 82559ER ethernet controller.
  * Currently simply sets the CSR BARs.  Assumes bus and function to be 0
  * @param  device_id [IN] device ID of the ethernet controller on the PCI bus
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int init_82559ER(int device_id){
    int ret_val = 0;

    /* Command register
     * [0]: I/O Space
     * [1]: Memory Space
     * [2]: Master Enable
     * [6]: Parity Error Response
     * [8]: SERR# Enable
     */
    pci_write_config_word(0, device_id,  0, 0x04, 0x147);

    /* set BARs for CSRs */
    pci_write_config_word_long(0, device_id,  0, 0x10, PCI_MEM_82559ER_CSR_BASE);
    pci_write_config_word_long(0, device_id,  0, 0x14, PCI_IO_82559ER_CSR_BASE);

    return ret_val;
}

#define INT_PLX_INTERRUPT       0x00000010
#define INT_PMCA_INTERRUPT      0x00000008
#define INT_21555_INTERRUPT     0x00000004
#define INT_82559ER_INTERRUPT   0x00000002
#define INT_SYSACE_INTERRUPT    0x00000001

#define INTC_ISR_ADDRESS    (INTC_BASE_ADDRESS + 0)
#define GET_ISR()           *((unsigned long *)(INTC_ISR_ADDRESS))

/** Dump the important Interrupt Controller registers.
  * @ingroup TestSystem
  */
void int_dump(){
    unsigned long *intc_ptr = (unsigned long *)(INTC_BASE_ADDRESS);

    printf("(0x4d000000)ISR: 0x%08x\n", *intc_ptr);
    intc_ptr++;

/*    printf("(0x4d000004)IPR: 0x%08x\n", *intc_ptr);*/
    intc_ptr++;

    printf("(0x4d000008)IER: 0x%08x\n", *intc_ptr);
    intc_ptr++;

/*    printf("(0x4d00000c)IAR: 0x%08x\n", *intc_ptr);*/
    intc_ptr++;

/*    printf("(0x4d000010)SIE: 0x%08x\n", *intc_ptr);*/
    intc_ptr++;

/*    printf("(0x4d000014)CIE: 0x%08x\n", *intc_ptr);*/
    intc_ptr++;

    printf("(0x4d000018)IVR: 0x%08x\n", *intc_ptr);
    intc_ptr++;

    printf("(0x4d00001c)MER: 0x%08x\n", *intc_ptr);
    intc_ptr++;
}

/** Clear some or all of the interrupts in the Interrupt Controller.
  * Writes the provided mask to the IAR to clear the desired interrupts
  * @param  mask [IN] the bits to clear
  * @ingroup TestSystem
  */
void int_clear(unsigned long mask){
    *((unsigned long *)(INTC_BASE_ADDRESS + 0x0C)) = mask;
}

/** Enable some or all of the interrupts in the Interrupt Controller.
  * Writes the provided mask to the IER to enable the desired interrupts
  * @param  mask [IN] the bits to set
  * @ingroup TestSystem
  */
void int_enable(unsigned long mask){
    *((unsigned long *)(INTC_BASE_ADDRESS + 0x08)) = mask;
}




/** Test all the external interrupt lines.
  * This test tests the 4 connected interrupt lines which are external to the
  *     FPGA by triggering an interrupt on the attached device.  After calling
  *     this function, the board must be reset for this test to pass again.
  * The test checks that each ISR bit is off, then causes the interrupt, and
  *     verifies that the ISR bit becomes set, then stops the interrupt, clears
  *     the ISR bit, and verifies that the ISR bit remains clear.
  * The lines tested are:
  *     0: intel 82559, by SGI
  *     1: system ace, by data ready interrupt
  *     3: intel 21555, by doorbell register
  *     4: PLX, by SGI
  *
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int int_test(){
    int ret_val = 0;
    unsigned char temp_byte;
    unsigned long isr;
    unsigned char read_buffer[XSA_CF_SECTOR_SIZE];

    if((G_21555_device_id == -1) || (G_ethernet_device_id == -1)){
        printf("pci devices not initialized\n");
        return 1;
    }

    /* enable hardware interrupts and master interrupt */
    *((unsigned long *)(INTC_BASE_ADDRESS + 0x1C)) = 0x00000003;
    int_clear(0xFFFFFFFF);

    /* 82559ER interrupt (ethernet) */
    isr = GET_ISR();
    if((isr & INT_82559ER_INTERRUPT) != 0){
        printf("ethernet interrupt already present!\n");
        return 1;
    }

    /* 82559ER interrupt is software generated interrupt */
    write2(PCI_MEM_82559ER_CSR_BASE+0x02, 0x0200);
    udelay(100000);

    isr = GET_ISR();
    if((isr & INT_82559ER_INTERRUPT) == 0){
        printf("ethernet interrupt not found!\n");
        return 1;
    }

    write2(PCI_MEM_82559ER_CSR_BASE+0x02, 0x0100);
    udelay(100000);
    int_clear(INT_82559ER_INTERRUPT);

    isr = GET_ISR();
    if((isr & INT_82559ER_INTERRUPT) != 0){
        printf("ethernet interrupt not cleared!\n");
        return 1;
    }

    /* SystemACE interrupt - enable data ready interrupt and read a sector */
    isr = GET_ISR();
    if((isr & INT_SYSACE_INTERRUPT) != 0){
        printf("SystemACE interrupt already present!\n");
        return 1;
    }

    XSysAce_mEnableIntr(SYSACE_BASEADDR, XSA_CR_DATARDYIRQ_MASK);

    /* Get a lock */
    XSysAce_mWaitForLock(SYSACE_BASEADDR);

    /* Make sure the device is ready for a command */
    if (XSysAce_mIsReadyForCmd(SYSACE_BASEADDR) == 0){
        printf("XSysAce_mIsReadyForCmd() failed!\n");
        return 1;
    }

    /* read boot sector */
    if (XSysAce_ReadSector(SYSACE_BASEADDR, 0, read_buffer) == 0){
        printf("XSysAce_ReadSector() failed\n");
        return 1;
    }

    /* Release the lock */
    XSysAce_mAndControlReg(SYSACE_BASEADDR, ~XSA_CR_LOCKREQ_MASK);

    isr = GET_ISR();
    if((isr & INT_SYSACE_INTERRUPT) == 0){
        printf("SystemACE interrupt not found!\n");
        return 1;
    }

    XSysAce_mDisableIntr(SYSACE_BASEADDR, XSA_CR_DATARDYIRQ_MASK);

    /* need to toggle interrupt enable bit */
    XSysAce_mOrControlReg(SYSACE_BASEADDR, XSA_CR_RESETIRQ_MASK);
    XSysAce_mAndControlReg(SYSACE_BASEADDR, ~XSA_CR_RESETIRQ_MASK);

    int_clear(INT_SYSACE_INTERRUPT);

    isr = GET_ISR();
    if((isr & INT_SYSACE_INTERRUPT) != 0){
        printf("SystemACE interrupt not cleared!\n");
        return 1;
    }

    /* 21555 interrupt */
    if(G_21555_device_id == -1){
        printf("pci uninitialized!\n");
        return 1;
    }

    isr = GET_ISR();
    if((isr & INT_21555_INTERRUPT) != 0){
        printf("21555 interrupt already present!\n");
        return 1;
    }

    /* 21555 int created by setting PCI-Local Doorbell */
    write2(PCI_MEM_21555_CSR_BASE+0x9E, 1);
    write2(PCI_MEM_21555_CSR_BASE+0xA2, 1);
    udelay(1000);

    isr = GET_ISR();
    if((isr & INT_21555_INTERRUPT) == 0){
        printf("21555 interrupt not found!\n");
        return 1;
    }

    write2(PCI_MEM_21555_CSR_BASE+0x9A, 1);
    write2(PCI_MEM_21555_CSR_BASE+0xA6, 1);
    int_clear(INT_21555_INTERRUPT);

    isr = GET_ISR();
    if((isr & INT_21555_INTERRUPT) != 0){
        printf("21555 interrupt not cleared!\n");
        return 1;
    }

    /* PLX interrupt */
    isr = GET_ISR();
    if((isr & INT_PLX_INTERRUPT) != 0){
        printf("plx interrupt already present!\n");
        return 1;
    }

    /* PLX int created by setting the BIST int bit; bit [6] of PCIBISTR */
    temp_byte = read1(PLX_BASE_ADDRESS + 0x0F);
    write1((PLX_BASE_ADDRESS + 0x0F), (temp_byte | 0x40));

    isr = GET_ISR();
    if((isr & INT_PLX_INTERRUPT) == 0){
        printf("plx interrupt not found!\n");
        return 1;
    }

    write1((PLX_BASE_ADDRESS + 0x0F), temp_byte);
    int_clear(INT_PLX_INTERRUPT);

    isr = GET_ISR();
    if((isr & INT_PLX_INTERRUPT) != 0){
        printf("plx interrupt not cleared!\n");
        return 1;
    }

    return ret_val;
}


/** Wrapper for int_test() */
int do_int_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    if(int_test() != 0){
        printf("***FAILED\n");
    } else {
        printf("PASS\n");
    }
}


#if 0  /* these functions have been made inactive to fit the test system in 64k of BRAM */
/** Console command to interact with the interrupt controller.
  * <pre>
  * int dump        - display important interrupt controller registers
  * int init        - enable all interrupts, and set hardware and master bits in MER
  * int clear MASK  - clear the interrupts indicated by MASK (or clear all if no MASK given)
  * int enable MASK - enable the interrupts indicated by MASK (or enable all if no MASK given)
  * </pre>
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command must be 2 or more
  * @param  *argv[] [IN] contains the parameters to use
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @see int_dump()
  * @see int_clear()
  * @see int_enable()
  * @ingroup TestSystem
  */
int do_int_cmd(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    if(argc < 2){
        printf("dump, clear, enable or init?\n");
    }
    else if(argc >= 2){
        if(strcmp(argv[1], "dump") == 0){
            int_dump();
        }
        else if(strcmp(argv[1], "init") == 0){
            /* enable all interrupts */
            *((unsigned long *)(INTC_BASE_ADDRESS + 0x08)) = 0xFFFFFFFF;

            /* enable hardware interrupts and master interrupt */
            *((unsigned long *)(INTC_BASE_ADDRESS + 0x1C)) = 0x00000003;
        }
        else if(strcmp(argv[1], "test") == 0){
            if(do_int_test() == 0){
                printf("int_test() passed.\n");
            }
        }
        else if(strcmp(argv[1], "clear") == 0){
            if(argc > 2){
                int_clear(simple_strtoul(argv[2], NULL, 16));
            }
            else{
                int_clear(0xFFFFFFFF);
            }
        }
        else if(strcmp(argv[1], "enable") == 0){
            if(argc > 2){
                int_enable(simple_strtoul(argv[2], NULL, 16));
            }
            else{
                int_enable(0xFFFFFFFF);
            }
        }
        else{
            printf("dump, clear, enable or init?\n");
        }
    }
}

/** Console command to interact with the system ace.
  * Manipulates the system ace control register, or dumps the important system
  *     ace registers based on user input.
  * <pre>
  * ace dump      - display important system ace registers
  * ace reset     - reconfigure from the system ace
  * ace clint     - clear any system ace interrupts
  * ace or VALUE  - VALUE is ORed into the control register
  * ace and VALUE - VALUE is ANDed into the control register
  * </pre>
  * @param  *cmdtp  [IN] as passed by run_command (ignored)
  * @param  flag    [IN] as passed by run_command (ignored)
  * @param  argc    [IN] as passed by run_command must be 2 or more
  * @param  *argv[] [IN] contains the parameters to use
  * @return
  * <pre>
  *      0 if passed
  *     -1 if failed
  * </pre>
  * @ingroup TestSystem
  */
int do_ace_cmd (cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    if(argc < 2){
        printf("dump, or, and, reset, or clint?\n");
    }
    else if(argc >= 2){
        if(strcmp(argv[1], "dump") == 0){
            printf("Control: 0x%08x\n", XSysAce_mGetControlReg(SYSACE_BASEADDR));
            printf("Error  : 0x%08x\n", XSysAce_mGetErrorReg(SYSACE_BASEADDR));
            printf("Status : 0x%08x\n", XSysAce_mGetStatusReg(SYSACE_BASEADDR));
            printf("Version: 0x%04x\n", XSysAce_RegRead16(SYSACE_BASEADDR + XSA_VR_OFFSET));
        }
        else if(strcmp(argv[1], "clint") == 0){
            XSysAce_mOrControlReg(SYSACE_BASEADDR, XSA_CR_RESETIRQ_MASK);
            XSysAce_mAndControlReg(SYSACE_BASEADDR, ~XSA_CR_RESETIRQ_MASK);
        }
        else if(strcmp(argv[1], "reset") == 0){
            XSysAce_mOrControlReg(SYSACE_BASEADDR, XSA_CR_CFGRESET_MASK);
            udelay(100);
            XSysAce_mAndControlReg(SYSACE_BASEADDR, ~XSA_CR_CFGRESET_MASK);
        }
        else if(strcmp(argv[1], "or") == 0){
            if(argc > 2){
                XSysAce_mOrControlReg(SYSACE_BASEADDR, simple_strtoul(argv[2], NULL, 16));
            }
            else{
                printf("or what?\n");
            }
        }
        else if(strcmp(argv[1], "and") == 0){
            if(argc > 2){
                XSysAce_mAndControlReg(SYSACE_BASEADDR, simple_strtoul(argv[2], NULL, 16));
            }
            else{
                printf("and what?\n");
            }
        }
        else{
            printf("dump, or, and, reset, or clint?\n");
        }
    }
}

#endif

#endif  /* !defined(PRODUCTION) */



