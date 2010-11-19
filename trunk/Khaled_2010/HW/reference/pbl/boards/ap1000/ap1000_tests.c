/**
 * @file ap1000_tests.c Board specific test code for the AP1000.
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
#include "serial.h"
#include "xgpio_l.h"
#include "xsysace_l.h"
#include "ap1000/ap1000_tests.h"

#define INTC_BASE_ADDRESS 0x4D000000

#define NUMOF(x)    (sizeof(x)/sizeof(x[0]))

#define XGpio_mGetDataDirection(BaseAddress) XGpio_mReadReg((BaseAddress), XGPIO_TRI_OFFSET)


int gPCIInitialized = 0;

/** Scan PCI bus for devices, displays registers, and initialize known devices.
  * This function currently does not scan for multiple functions of a device
  * @ingroup TestSystem
  * @retval 0 success
  * @retval -1 pci bridge not initialized
  * @return ORed return values from pci_initdevice().
  */
int pci_scan(int *TheDeviceCount) {

    int dev;
    int func;
    unsigned short read_config_val;
	int ret_config_val;
    int ret_val = 0;
    int init_ret_val = 0;
    int device_count = 0;

    if(!gPCIInitialized){
        printf("PCI not initialized, aborting.\n");
        return -1;
    }

    /* check for any devices on the bus */
    for(dev = 0; dev < 32; dev++) {
        func = 0;

        ret_config_val = pci_read_config_word(0, dev, func, 0, &read_config_val);

        /* if device found, initialize it */
        if ((ret_config_val != NO_DEVICE_FOUND) &&
        	(ret_config_val != ILLEGAL_REG_OFFSET)){
            device_count++;
            init_ret_val = pci_initdevice(0, dev, 0);

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


#ifdef CMD_TBL_GPIOTEST

/*Note: These define the position of the GPIO banks in the following arrays.
        Keep them in sync if something changes!  They are mainly used for
        readability in the loopback test definition table (which uses indexes
        instead of register addresses to conserve space).
*/


	#define pPMC1	0
	#define pPMC2	1
	#define pEXP1	2
	#define pEXP2	3
	#define pEXP3	4
	#define pEXP4	5
	#define pEXP5	6
	#define pEXP6	7
	#define pEXP7	8
	#define pEXP8	9

/* Dual GE Mezzanine test does not need GPIO tests */
#if defined(TEST_DUAL_GE_PHY_MEZZ)
    #define NUM_GPIOS 0
	#define NUM_CONNECTORS	0

    unsigned long gGPIOAddrArray[2] = { 0 };
    unsigned long gGPIOMaskArray[2] = { 0 };
    char         *gGPIONameArray[2] = { "\0" };
	char 		 *gConnectorNameArray[2] = { "\0" );


#elif defined(DEVICE_VP70)|| defined(DEVICE_VP100)

	#define	NUM_GPIOS			XPAR_XGPIO_NUM_INSTANCES
	#define NUM_CONNECTORS		4

	#define GPIO_EXP3_DATA_MASK	0x0007FFFF
	#define GPIO_EXP5_DATA_MASK 0x007FFFFF
	#define GPIO_EXP8_DATA_MASK 0x001FFFFF

	unsigned long gGPIOAddrArray[NUM_GPIOS] = {
		XPAR_OPB_GPIO_PMC1_BASEADDR,
		XPAR_OPB_GPIO_PMC2_BASEADDR,
		XPAR_OPB_GPIO_EXP1_BASEADDR,
		XPAR_OPB_GPIO_EXP2_BASEADDR,
		XPAR_OPB_GPIO_EXP3_BASEADDR,
		XPAR_OPB_GPIO_EXP4_BASEADDR,
		XPAR_OPB_GPIO_EXP5_BASEADDR,
		XPAR_OPB_GPIO_EXP6_BASEADDR,
		XPAR_OPB_GPIO_EXP7_BASEADDR,
		XPAR_OPB_GPIO_EXP8_BASEADDR};

	unsigned long gGPIOMaskArray[NUM_GPIOS] = {
		0xFFFFFFFF,
		0xFFFFFFFF,
		0xFFFFFFFF,
		0xFFFFFFFF,
		GPIO_EXP3_DATA_MASK,
		0xFFFFFFFF,
		GPIO_EXP5_DATA_MASK,
		0xFFFFFFFF,
		0xFFFFFFFF,
		GPIO_EXP8_DATA_MASK};

	char *gGPIONameArray[NUM_GPIOS] = {
		"PMC1",
		"PMC2",
		"EXP1",
		"EXP2",
		"EXP3",
		"EXP4",
		"EXP5",
		"EXP6",
		"EXP7",
		"EXP8"};

	#define CJ_14	0
	#define CJ_16   1
	#define CJ_17   2
	#define CJ_23	3
	char *gConnectorNameArray[NUM_CONNECTORS] = {
		"J14",		/* PMC connector I/O on back of board */
		"J16",
		"J17",
		"J23"
			};


#endif

struct pTJLoopBack {
    unsigned char outbank;	/**< Output on which port, pPMC1 to pEXP8 */
    unsigned char outbit;	/**< Output on which port pin. Bit 0 = MSB */
	unsigned char outcon;	/**< Output on which physical connector */
    unsigned char outpin;	/**< Output Pin number on physical connector */
    unsigned char inbank;	/**< Input on which port, pPMC1 to pEXP8 */
    unsigned char inbit;	/**< Input on which port pin. Bit 0 = MSB */
	unsigned char incon;	/**< Input on which physical connector. */
    unsigned char inpin;	/**< Input Pin number on physical connector */
};


/** Pin mapping of the loopback testjig */
struct pTJLoopBack TJLoopBackTable[] =
{
    /* Expansion I/O  J16 connector */
    {pEXP6,28,CJ_16,5,pEXP1,10,CJ_16,41},
    {pEXP6,28,CJ_16,5,pEXP1,19,CJ_16,75},
    {pEXP1,0,CJ_16,11,pEXP1,11,CJ_16,43},
    {pEXP1,1,CJ_16,13,pEXP1,12,CJ_16,49},
    {pEXP1,4,CJ_16,17,pEXP1,13,CJ_16,51},
    {pEXP1,5,CJ_16,19,pEXP1,14,CJ_16,57},
    {pEXP1,6,CJ_16,25,pEXP1,15,CJ_16,59},
    {pEXP1,7,CJ_16,27,pEXP1,16,CJ_16,65},
    {pEXP1,8,CJ_16,33,pEXP1,17,CJ_16,67},
    {pEXP1,9,CJ_16,35,pEXP1,18,CJ_16,73},

    {pEXP1,20,CJ_16,2,pEXP1,29,CJ_16,36},
    {pEXP1,21,CJ_16,4,pEXP1,30,CJ_16,42},
    {pEXP1,22,CJ_16,10,pEXP1,31,CJ_16,44},
    {pEXP1,23,CJ_16,12,pEXP2,0,CJ_16,50},
    {pEXP1,24,CJ_16,18,pEXP2,1,CJ_16,52},
    {pEXP1,25,CJ_16,20,pEXP2,2,CJ_16,58},
    {pEXP1,26,CJ_16,26,pEXP2,3,CJ_16,60},
    {pEXP1,27,CJ_16,28,pEXP2,4,CJ_16,66},
    {pEXP1,3,CJ_16,30,pEXP2,5,CJ_16,68},
    {pEXP1,2,CJ_16,32,pEXP3,21,CJ_16,74},
    {pEXP1,28,CJ_16,34,pEXP3,22,CJ_16,76},


	/* Expanision IO  J17 Connector. */
	{pEXP6,4,CJ_17,61,pEXP2,6,CJ_17,1},
	{pEXP6,7,CJ_17,63,pEXP2,7,CJ_17,3},
	{pEXP6,6,CJ_17,65,pEXP2,8,CJ_17,5},
	{pEXP6,9,CJ_17,67,pEXP2,9,CJ_17,7},
	{pEXP6,8,CJ_17,69,pEXP2,10,CJ_17,9},
	{pEXP6,11,CJ_17,71,pEXP2,11,CJ_17,11},
	{pEXP6,10,CJ_17,73,pEXP2,12,CJ_17,13},
	{pEXP6,13,CJ_17,75,pEXP2,13,CJ_17,15},
	{pEXP6,12,CJ_17,77,pEXP2,14,CJ_17,19},
	{pEXP6,15,CJ_17,81,pEXP2,15,CJ_17,21},

	{pEXP6,14,CJ_17,83,pEXP2,16,CJ_17,23},
	{pEXP6,17,CJ_17,85,pEXP2,17,CJ_17,25},
	{pEXP6,16,CJ_17,87,pEXP2,18,CJ_17,27},
	{pEXP6,19,CJ_17,89,pEXP2,19,CJ_17,29},
	{pEXP6,18,CJ_17,91,pEXP2,20,CJ_17,31},
	{pEXP6,20,CJ_17,95,pEXP2,21,CJ_17,33},
	{pEXP6,21,CJ_17,97,pEXP2,22,CJ_17,37},
	{pEXP6,22,CJ_17,99,pEXP2,23,CJ_17,39},
	{pEXP6,23,CJ_17,101,pEXP2,24,CJ_17,41},
	{pEXP6,24,CJ_17,103,pEXP2,25,CJ_17,43},

	{pEXP6,25,CJ_17,105,pEXP3,23,CJ_17,45},
	{pEXP6,26,CJ_17,107,pEXP3,24,CJ_17,47},
	{pEXP6,1,CJ_17,51,pEXP6,27,CJ_17,109},
	{pEXP6,0,CJ_17,53,pEXP6,29,CJ_17,111},
	{pEXP6,3,CJ_17,55,pEXP4,0,CJ_17,115},
	{pEXP6,2,CJ_17,57,pEXP4,1,CJ_17,117},
	{pEXP6,5,CJ_17,59,pEXP5,31,CJ_17,118},
	{pEXP4,2,CJ_17,4,pEXP4,28,CJ_17,62},
	{pEXP4,3,CJ_17,6,pEXP4,29,CJ_17,64},
	{pEXP4,4,CJ_17,8,pEXP4,30,CJ_17,66},

	{pEXP4,5,CJ_17,10,pEXP4,31,CJ_17,68},
	{pEXP4,6,CJ_17,12,pEXP5,9,CJ_17,70},
	{pEXP4,7,CJ_17,14,pEXP5,10,CJ_17,72},
	{pEXP4,8,CJ_17,16,pEXP5,11,CJ_17,74},
	{pEXP4,9,CJ_17,18,pEXP5,12,CJ_17,76},
	{pEXP4,10,CJ_17,22,pEXP5,13,CJ_17,78},
	{pEXP4,11,CJ_17,24,pEXP5,14,CJ_17,80},
	{pEXP4,12,CJ_17,26,pEXP5,15,CJ_17,84},
	{pEXP4,13,CJ_17,28,pEXP5,16,CJ_17,86},
	{pEXP4,14,CJ_17,30,pEXP5,27,CJ_17,88},

	{pEXP4,15,CJ_17,32,pEXP5,28,CJ_17,90},
	{pEXP4,16,CJ_17,34,pEXP5,17,CJ_17,94},
	{pEXP4,17,CJ_17,36,pEXP5,18,CJ_17,96},
	{pEXP4,18,CJ_17,38,pEXP5,19,CJ_17,98},
	{pEXP4,19,CJ_17,40,pEXP5,20,CJ_17,100},
	{pEXP4,20,CJ_17,44,pEXP5,21,CJ_17,102},
	{pEXP4,21,CJ_17,46,pEXP5,22,CJ_17,104},
	{pEXP4,22,CJ_17,48,pEXP5,23,CJ_17,106},
	{pEXP4,23,CJ_17,50,pEXP5,24,CJ_17,108},
	{pEXP4,24,CJ_17,52,pEXP5,25,CJ_17,110},

	{pEXP4,25,CJ_17,54,pEXP5,26,CJ_17,112},
	{pEXP4,26,CJ_17,58,pEXP5,29,CJ_17,114},
	{pEXP4,27,CJ_17,60,pEXP5,30,CJ_17,116},

	/* Expansion IO - Connector J23 */
	{pEXP3,31,CJ_23,41,pEXP2,27,CJ_23,3},
	{pEXP6,30,CJ_23,43,pEXP2,28,CJ_23,5},
	{pEXP6,31,CJ_23,45,pEXP2,29,CJ_23,7},
	{pEXP7,0,CJ_23,47,pEXP2,30,CJ_23,9},
	{pEXP7,1,CJ_23,49,pEXP2,31,CJ_23,11},
	{pEXP7,2,CJ_23,53,pEXP3,13,CJ_23,13},
	{pEXP7,3,CJ_23,55,pEXP3,14,CJ_23,15},
	{pEXP7,4,CJ_23,57,pEXP3,15,CJ_23,17},
	{pEXP7,5,CJ_23,59,pEXP3,16,CJ_23,19},
	{pEXP7,6,CJ_23,63,pEXP3,17,CJ_23,21},

	{pEXP7,7,CJ_23,65,pEXP3,18,CJ_23,23},
	{pEXP7,8,CJ_23,67,pEXP3,19,CJ_23,25},
	{pEXP7,9,CJ_23,69,pEXP3,20,CJ_23,27},
	{pEXP7,10,CJ_23,73,pEXP3,25,CJ_23,29},
	{pEXP7,11,CJ_23,75,pEXP3,26,CJ_23,31},
	{pEXP7,12,CJ_23,77,pEXP3,27,CJ_23,33},
	{pEXP7,13,CJ_23,79,pEXP3,28,CJ_23,35},
	{pEXP2,26,CJ_23,1,pEXP3,29,CJ_23,37},
	{pEXP8,31,CJ_23,80,pEXP3,30,CJ_23,39},
	{pEXP7,14,CJ_23,2,pEXP8,12,CJ_23,40},

	{pEXP7,15,CJ_23,4,pEXP8,13,CJ_23,42},
	{pEXP7,16,CJ_23,6,pEXP8,14,CJ_23,44},
	{pEXP7,17,CJ_23,8,pEXP8,15,CJ_23,46},
	{pEXP7,18,CJ_23,10,pEXP8,16,CJ_23,48},
	{pEXP7,19,CJ_23,12,pEXP8,17,CJ_23,50},
	{pEXP7,20,CJ_23,14,pEXP8,18,CJ_23,52},
	{pEXP7,21,CJ_23,16,pEXP8,19,CJ_23,54},
	{pEXP7,22,CJ_23,18,pEXP8,20,CJ_23,56},
	{pEXP7,23,CJ_23,20,pEXP8,21,CJ_23,60},
	{pEXP7,24,CJ_23,22,pEXP8,22,CJ_23,62},

	{pEXP7,25,CJ_23,24,pEXP8,23,CJ_23,64},
	{pEXP7,26,CJ_23,26,pEXP8,24,CJ_23,66},
	{pEXP7,27,CJ_23,28,pEXP8,25,CJ_23,68},
	{pEXP7,28,CJ_23,30,pEXP8,26,CJ_23,70},
	{pEXP7,29,CJ_23,32,pEXP8,27,CJ_23,72},
	{pEXP7,30,CJ_23,34,pEXP8,28,CJ_23,74},
	{pEXP7,31,CJ_23,36,pEXP8,29,CJ_23,76},
	{pEXP8,11,CJ_23,38,pEXP8,30,CJ_23,78},

	/* PMC Connector */
	{pPMC2,0,CJ_14,1,pPMC2,8,CJ_14,33},
	{pPMC2,1,CJ_14,5,pPMC2,9,CJ_14,37},
	{pPMC2,2,CJ_14,9,pPMC2,10,CJ_14,41},
	{pPMC2,3,CJ_14,13,pPMC2,11,CJ_14,45},
	{pPMC2,4,CJ_14,17,pPMC2,12,CJ_14,49},
	{pPMC2,5,CJ_14,21,pPMC2,13,CJ_14,53},
	{pPMC2,6,CJ_14,25,pPMC2,14,CJ_14,57},
	{pPMC2,7,CJ_14,29,pPMC2,15,CJ_14,61},
	{pPMC2,16,CJ_14,2,pPMC2,24,CJ_14,34},
	{pPMC2,17,CJ_14,6,pPMC2,25,CJ_14,38},

	{pPMC2,18,CJ_14,10,pPMC2,26,CJ_14,42},
	{pPMC2,19,CJ_14,14,pPMC2,27,CJ_14,46},
	{pPMC2,20,CJ_14,18,pPMC2,28,CJ_14,50},
	{pPMC2,21,CJ_14,22,pPMC2,29,CJ_14,54},
	{pPMC2,22,CJ_14,26,pPMC2,30,CJ_14,58},
	{pPMC2,23,CJ_14,30,pPMC2,31,CJ_14,62},
	{pPMC1,0,CJ_14,3,pPMC1,8,CJ_14,35},
	{pPMC1,1,CJ_14,7,pPMC1,9,CJ_14,39},
	{pPMC1,2,CJ_14,11,pPMC1,10,CJ_14,43},
	{pPMC1,3,CJ_14,15,pPMC1,11,CJ_14,47},

	{pPMC1,4,CJ_14,19,pPMC1,12,CJ_14,51},
	{pPMC1,5,CJ_14,23,pPMC1,13,CJ_14,55},
	{pPMC1,6,CJ_14,27,pPMC1,14,CJ_14,59},
	{pPMC1,7,CJ_14,31,pPMC1,15,CJ_14,63},
	{pPMC1,16,CJ_14,4,pPMC1,24,CJ_14,36},
	{pPMC1,17,CJ_14,8,pPMC1,25,CJ_14,40},
	{pPMC1,18,CJ_14,12,pPMC1,26,CJ_14,44},
	{pPMC1,19,CJ_14,16,pPMC1,27,CJ_14,48},
	{pPMC1,20,CJ_14,20,pPMC1,28,CJ_14,52},
	{pPMC1,21,CJ_14,24,pPMC1,29,CJ_14,56},

	{pPMC1,22,CJ_14,28,pPMC1,30,CJ_14,60},
	{pPMC1,23,CJ_14,32,pPMC1,31,CJ_14,64}

};


/* Command for sio test is defined, include the function to process the command. */

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
int do_gpiotest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]) {
    int ret_val = 0;

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
	int	hadError;

    /* Start with everything set as input.  Output level to 0.*/
    for(i = 0; i < NUM_GPIOS; i++){
        XGpio_mSetDataDirection(gGPIOAddrArray[i],1, 0xFFFFFFFF);
        XGpio_mSetDataReg(gGPIOAddrArray[i],1, 0x00000000);
    }

    /* Set direction of all output pins -- for walking 1 only. */
    if(level){
        for(i = 0; i < NUMOF(TJLoopBackTable); i++){
            oreg = TJLoopBackTable[i].outbank;
            obit = TJLoopBackTable[i].outbit;
            data_read = XGpio_mGetDataDirection(gGPIOAddrArray[oreg]);
            mask_out = 0x80000000 >> obit;
            XGpio_mSetDataDirection(gGPIOAddrArray[oreg],1, data_read & ~mask_out);
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

        /* Special exception - This bit goes 2 places.*/
        if(oreg==pEXP6 && obit==28){
            mask_in = 0x80000000 >> 10;
            mask_in |= (0x80000000 >> 19);
        }

        mask_out = level ? mask_out : ~mask_out;
        mask_in = level ? mask_in : ~mask_in;

        /* Set the output (walking 1 only) */
        if(level){
            XGpio_mSetDataReg(gGPIOAddrArray[oreg],1, mask_out);
        }
        /* Set the output pin direction (for walking 0 only) */
        else {
            XGpio_mSetDataDirection(gGPIOAddrArray[oreg],1, mask_out);
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

        for(j = 0, hadError = 0; j < NUM_GPIOS; j++){
            data_read = XGpio_mGetDataReg(gGPIOAddrArray[j],1);

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
				hadError = 1;


            }

        } //Verification loop

		if (hadError) /* Tell operator which pin was under test. */
			printf("Output on %s %d Input on %s %d\n",
					gConnectorNameArray[(unsigned int) TJLoopBackTable[i].outcon],
					(int) TJLoopBackTable[i].outpin,
					gConnectorNameArray[(unsigned int) TJLoopBackTable[i].incon],
					(int) TJLoopBackTable[i].inpin);


        /* Unset the output pin direction (for walking 0 only) */
        if(!level){
            XGpio_mSetDataDirection(gGPIOAddrArray[oreg], 1, 0xFFFFFFFF);
        }
        /* Unset the output (walking 1 only) */
        else {
            XGpio_mSetDataReg(gGPIOAddrArray[oreg], 1, 0x00000000);
        }
    } //TJLoopBackTable loop


    return ret_val;
}

#endif /* CMD_TBL_GPIOTEST */


#ifdef CMD_TBL_ACE_CMD

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
#endif	/* CMD_TBL_ACE_CMD */

#ifdef CMD_TBL_PCIINIT
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

    printf("Init PowerSpan II bridge:");
    ret_val = InitPowerSpan();
    if(ret_val != 0){
        printf("FAILED!\n");
        return ret_val;
    }
    else
    {
        printf("PASSED\n");
    }

    return 0;
}
#endif /* #ifdef CMD_TBL_PCIINIT */

#if defined(CMD_TBL_PCISCAN)
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
        printf("PASSED - %d devices detected\n",num_devices);
    }

    return ret_val;
}
#endif /* #if defined(CMD_TBL_PCISCAN) */

#ifdef CMD_TBL_SETVERB

#if !defined(VERBOSITY)
int gVerbosityLevel = 0;
#endif

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
#endif /* #ifdef CMD_TBL_SETVERB */

#if defined(CMD_TBL_READCFG)
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
    unsigned long readLval;
	unsigned short readSval;
	unsigned char  readCval;

    if(!gPCIInitialized){
        printf("PCI not initialized, aborting.\n");
        return -1;
    }

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
                pci_read_config_byte(0, device_id,  0, offset,&readCval);
                printf("Value is 0x%02x\n", (unsigned int)readCval);
                break;
            }
            case 2:{
                pci_read_config_word(0, device_id,  0, offset,&readSval);
                printf("Value is 0x%04x\n", (unsigned int)readSval);
                break;
            }
            case 4:{
                pci_read_config_dword(0, device_id,  0, offset,&readLval);
                printf("Value is 0x%08x\n", readLval);
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
#endif /* #if defined(CMD_TBL_READCFG) */

#if defined(CMD_TBL_WRITECFG)
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

    if(!gPCIInitialized){
        printf("PCI not initialized, aborting.\n");
        return -1;
    }

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
                pci_write_config_dword(0, device_id,  0, offset, value);
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
#endif /* #if defined(CMD_TBL_WRITECFG) */

#if defined(CMD_TBL_ETHTEST)
/* Ether net test command defined. Include support functions for ethernet. */

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
#if defined(VERBOSITY)
    if(gVerbosityLevel > 0)
        printf("read %d\n", one_or_two);
#endif

    /* poll ready bit */
    if(one_or_two == 1){
		asm("eieio");
        read_value = *((volatile unsigned long *)ETH1_READ_REG_ADD);
		asm("eieio");
#if defined(VERBOSITY)
    	if(gVerbosityLevel > 0)
        	printf("     %8x\n", read_value);
#endif
        while((read_value & ETH_READY) == 0){
			asm("eieio");
            read_value = *((volatile unsigned long *)ETH1_READ_REG_ADD);
			asm("eieio");
#if defined(VERBOSITY)
            if(gVerbosityLevel > 0)
                printf("     %8x\n", read_value);
#endif
        }
    }
    else{
		asm("eieio");
        read_value = *((volatile unsigned long *)ETH2_READ_REG_ADD);
		asm("eieio");
#if defined(VERBOSITY)
        if(gVerbosityLevel > 0)
            printf("     %8x\n", read_value);
#endif
        while((read_value & ETH_READY) == 0){
			asm("eieio");
            read_value = *((volatile unsigned long *)ETH2_READ_REG_ADD);
			asm("eieio");
#if defined(VERBOSITY)
            if(gVerbosityLevel > 0)
                printf("     %8x\n", read_value);
#endif
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
#if defined(VERBOSITY)
    if(gVerbosityLevel > 0)
        printf("write %d %08x\n", one_or_two, write_value);
#endif

    if(one_or_two == 1){
        /* wait for ready state */
        read_eth_read_reg(1);
        *((volatile unsigned long *)ETH1_CTRL_REG_ADD) = write_value;
        read_eth_read_reg(1);
    }
    else{
        /* wait for ready state */
        read_eth_read_reg(2);
        *((volatile unsigned long *)ETH2_CTRL_REG_ADD) = write_value;
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
        *((volatile unsigned long *)ETH1_READ_REG_ADD) = ETH_START;
		asm("eieio");
    }
    else{
        /* wait for ready state */
        read_eth_read_reg(2);
        *((volatile unsigned long *)ETH2_READ_REG_ADD) = ETH_START;
		asm("eieio");
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
        *(((volatile unsigned long *)ETH1_TBUFF_BASE) + i) = 0x00000000;
        *(((volatile unsigned long *)ETH1_RBUFF_BASE) + i) = 0x11111111;
        *(((volatile unsigned long *)ETH2_TBUFF_BASE) + i) = 0x00000000;
        *(((volatile unsigned long *)ETH2_RBUFF_BASE) + i) = 0x22222222;
    }


        *(((volatile unsigned long *)ETH1_TBUFF_BASE) + 0) = 0x55555555;
        *(((volatile unsigned long *)ETH2_TBUFF_BASE) + 0) = 0x55555555;

        *(((volatile unsigned long *)ETH1_TBUFF_BASE) + 1) = 0xaaaaaaaa;
        *(((volatile unsigned long *)ETH2_TBUFF_BASE) + 1) = 0xaaaaaaaa;

        *(((volatile unsigned long *)ETH1_TBUFF_BASE) + 2) = 0x01020408;
        *(((volatile unsigned long *)ETH2_TBUFF_BASE) + 2) = 0x01020408;

        *(((volatile unsigned long *)ETH1_TBUFF_BASE) + 3) = 0x10204080;
        *(((volatile unsigned long *)ETH2_TBUFF_BASE) + 3) = 0x10204080;


    for(i = 4;i < ETH_BUFF_NUM_DWORDS;i++){
        *(((volatile unsigned long *)ETH1_TBUFF_BASE) + i) = 0xdeadbeef;
        *(((volatile unsigned long *)ETH2_TBUFF_BASE) + i) = 0xdeadbeef;
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
        if(*(((volatile unsigned long *)ETH1_TBUFF_BASE) + i) !=
           *(((volatile unsigned long *)ETH2_RBUFF_BASE) + i)){
            error_count++;
        }
    }

    if(error_count != 0){
        printf("%d words do not match in Eth1->Eth2 transfer.\n", error_count);
        ret_val = 1;
    }

    error_count = 0;
    for(i = 0;i < ETH_BUFF_NUM_DWORDS;i++){
        if(*(((volatile unsigned long *)ETH2_TBUFF_BASE) + i) !=
           *(((volatile unsigned long *)ETH1_RBUFF_BASE) + i)){
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

#endif /* #if defined(CMD_TBL_ETHTEST) */

int EEPROMTest(){
    int ii;
    int error = 0;
    int ret_val = 0;
    unsigned char temp_char;

    printf("    Writing count: ");
    for(ii = 0;((ii < EEPROM_LENGTH) && (error == 0));ii++){
        if(EEPROMWrite(ii, ii) != 0){
            error = 1;
        }
    }

    if(error != 0){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }

    error = 0;
    printf("    Verifying count: ");
    for(ii = 0;((ii < EEPROM_LENGTH) && (error == 0));ii++){
        if(EEPROMRead(ii, &temp_char) != 0){
            printf("Read Error.\n");
            error = 1;
        }
        else{
            if(temp_char != ii){
                printf("Data Error: 0x%02x should be 0x%02x\n", temp_char, ii, ii);
                error = 1;
            }
        }
    }
    if(error != 0){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }

    printf("    Writing defaults: ");
    if(SetEEPROMToDefault() != 1){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }
    printf("    Verifying defaults: ");
    if(VerifyDefaultEEPROM() != 1){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }

    return ret_val;
}


/**
 * Runs all code that must be executed before the PPCBoot Lite prompt.
 * This function runs a variety of tests to validate the board.  Written to be run at the board
 *     production site to streamline the board testing.
 * @param theFlag currently, a non-zero causes the DRAM to be tested at the end.
 * @retval 0 if passed
 * @retval -1 if failed
 * @ingroup TestSystem
 */
int TestSystemAutoRun(int theFlag){
    int i = 0;
    int wait = 0;
    int abort = 0;
    int num_devices = 0;
    int ret_val = 0;

    /* mtest */
    printf("\n>>> SRAM Test: ");
    if(memtest(0x08000000, 0x083fffff, 0, 1) != 0){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }

    /* acetest */
    printf("\n>>> SystemACE Test: ");
    if(ace_signature() != 0){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }

    /* pciinit */
    printf("\n>>> PCI Tests: ");
    if(InitPowerSpan() != 0){
        printf("FAILED to initialize PowerSpan II, unable to proceed!\n");
        return -1;
    }
    /* pciscan: 1 or 2 devices is acceptable (2 if PMC card is present) */
    num_devices = 0;
    if(pci_scan(&num_devices) != 0){
        printf("FAILED PCI scan!\n");
        ret_val = -1;
    }
    else if((num_devices < 1) || (num_devices > 2)){
        printf("BAD device count: %d (expected 1 or 2)\n", num_devices);
        ret_val = -1;
    }
    else{
        printf("Found %d PCI devices; passed\n", num_devices);
    }

    /* inttest */
    printf("\n>>> Int Test: ");
    if(int_test() != 0){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }

    /* eeprom write */
    printf("\n>>> EEPROM Test:\n");
    if(EEPROMTest() != 0){
        printf("FAILED\n");
        ret_val = -1;
	}
	else{
        printf("passed.\n");
	}

    /* Ethernet interface test */
    printf("\n>>> Ether Test: ");
    if(ethernet_test() != 0){
        printf("FAILED\n");
        ret_val = -1;
    }
    else{
        printf("passed.\n");
    }

    if(theFlag){
        printf("\n>>> DRAM Test:\n");
        printf("    DRAM#1: ");
        if(memtest(0x00000000, 0x03ffffff, 0, 1) != 0){
            printf("FAILED\n");
            ret_val = -1;
        }
        else{
            printf("passed.\n");
        }
        printf("    DRAM#2: ");
        if(memtest(0x04000000, 0x07ffffff, 0, 1) != 0){
            printf("FAILED\n");
            ret_val = -1;
        }
        else{
            printf("passed.\n");
        }
    }

    printf("\n*** Test Suite %s ***\n", (ret_val == 0) ? "PASSED" : "FAILED");

    /* CPLD write prompt */
    printf("Press 's' for reconfigure or any key to exit.\n");
    if(tolower(serial_getc()) == 's'){
        /* does not return */
        DoSWReconfig();
    }

    return ret_val;
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

    i = pci_read_config_word(bus, dev, fn, 2, &device_id);
	if ((i == NO_DEVICE_FOUND) || (i == ILLEGAL_REG_OFFSET)) device_id = 0xFFFF;

    i = pci_read_config_word(bus, dev, fn, 0, &vendor_id);
	if ((i == NO_DEVICE_FOUND) || (i == ILLEGAL_REG_OFFSET)) vendor_id = 0xFFFF;

    printf("DevID: 0x%04x\tVenID: 0x%04x\n", device_id, vendor_id);

    return ret_val;
}

#define GET_ISR()           *((unsigned long *)(INTC_BASE_ADDRESS))

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



#if defined(CMD_TBL_INTTEST_CMD)

#define NUM_INTS    12

#define INT_SYSACE_BIT      0x00000001
#define INT_ETH_BIT         0x00000002
#define INT_PMC_INTB_BIT    0x00000004
#define INT_PMC_INTA_BIT    0x00000008
#define INT_PS2_INT0_BIT    0x00010000
#define INT_PS2_INT1_BIT    0x00020000
#define INT_PS2_INT2_BIT    0x00040000
#define INT_PS2_INT3_BIT    0x00080000
#define INT_PS2_INT4_BIT    0x00100000
#define INT_PS2_INT5_BIT    0x00200000
#define INT_SENSOR_BIT      INT_PS2_INT5_BIT
#define INT_PS2_P2_INTA_BIT INT_PMC_INTB_BIT

#define INT_TEST_DB_MAP 0x02eca864
#define DB0_SHIFT 8

/**
 * Causes the System Ace interrupt.
 * The data ready interrupt is enabled, then data is read to trigger it.
 * @param unused not used.
 */
void SystemAceCauseInt(int unused){
    unsigned char read_buffer[XSA_CF_SECTOR_SIZE];

    XSysAce_mEnableIntr(SYSACE_BASEADDR, XSA_CR_DATARDYIRQ_MASK);

    /* Get a lock */
    XSysAce_mWaitForLock(SYSACE_BASEADDR);

    /* Make sure the device is ready for a command */
    if (XSysAce_mIsReadyForCmd(SYSACE_BASEADDR) == 0){
        printf("XSysAce_mIsReadyForCmd() failed!\n");
        return;
    }

    /* read boot sector */
    if (XSysAce_ReadSector(SYSACE_BASEADDR, 0, read_buffer) == 0){
        printf("XSysAce_ReadSector() failed\n");
        return;
    }

    /* Release the lock */
    XSysAce_mAndControlReg(SYSACE_BASEADDR, ~XSA_CR_LOCKREQ_MASK);
}

/**
 * Clears the System Ace interrupt.
 * The data ready interrupt is disabled, then the interrupt bit is cleared.
 * @param unused not used.
 */
void SystemAceClearInt(int unused){
    XSysAce_mDisableIntr(SYSACE_BASEADDR, XSA_CR_DATARDYIRQ_MASK);

    /* need to toggle interrupt enable bit */
    XSysAce_mOrControlReg(SYSACE_BASEADDR, XSA_CR_RESETIRQ_MASK);
    XSysAce_mAndControlReg(SYSACE_BASEADDR, ~XSA_CR_RESETIRQ_MASK);
}

unsigned int gEthernetBaseAddresses[3] = {
    0x32000000,
    0x34000000,
    0x36000000
};

#define ETHERNET_INT_CAUSE_SET_OFFSET   0xc8
#define ETHERNET_INT_MASK_SET_OFFSET    0xd0
#define ETHERNET_INT_MASK_CLEAR_OFFSET  0xd8

#define ETHERNET_GPI0_INT_MASK          0x00002000
/**
 * Causes the ethernet interrupt.
 * Sets the General Purpose Interrupt0 bit.
 * @param theIndex the index of the 8254x ethernet device.
 */
void EthernetCauseInt(int theIndex){
    /* enable General Purpose Interrupt 0 mask bit */
    *((unsigned int*)(gEthernetBaseAddresses[theIndex] + ETHERNET_INT_MASK_SET_OFFSET)) = ETHERNET_GPI0_INT_MASK;

    /* set GPI0 bit */
    *((unsigned int*)(gEthernetBaseAddresses[theIndex] + ETHERNET_INT_CAUSE_SET_OFFSET)) = ETHERNET_GPI0_INT_MASK;
    udelay(TENTH_OF_A_SECOND);
}
/**
 * Clears the ethernet interrupt.
 * Clears the General Purpose Interrupt0 bit.
 * @param theIndex the index of the 8254x ethernet device.
 */
void EthernetClearInt(int theIndex){
    /* Disable General Purpose Interrupt 0 mask bit */
    *((unsigned int*)(gEthernetBaseAddresses[theIndex] + ETHERNET_INT_MASK_CLEAR_OFFSET)) = ETHERNET_GPI0_INT_MASK;
    udelay(TENTH_OF_A_SECOND);
}

/**
 * Causes an interrupt on a given PS2_INT line.
 * This function rings the indicated doorbell.  In int_test(), the doorbells are
 *  mapped such that DB0 -> PS2_INT0, DB1 -> PS2_INT1, etc.
 * @param theIndex the PS2_INT line to use.
 */
void PS2_INTCauseInt(int theIndex){
    PowerSpanWrite(REG_IER0, (1UL << (DB0_SHIFT + theIndex)));
}
/**
 * Clears an interrupt on a given PS2_INT line.
 * This function clears the indicated doorbell.  In int_test(), the doorbells are
 *  mapped such that DB0 -> PS2_INT0, DB1 -> PS2_INT1, etc.
 * @param theIndex the PS2_INT line to clear.
 */
void PS2_INTClearInt(int theIndex){
    PowerSpanWrite(REG_ISR0, (1UL << (DB0_SHIFT + theIndex)));
}

/**
 * Causes an interrupt on the temperature sensor.
 * This function lowers the local high limit to 0, causing the interrupt.
 * @param unused not used.
 */
void SensorCauseInt(int unused){
    unsigned char temp = 0;

    I2CAccess(0xB, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp, I2C_WRITE);
}
/**
 * Clears an interrupt on the temperature sensor.
 * This function raises the local high limit back to 85, clearing the interrupt
 *  condition. Then, the I2C ARA read is done to finish clearing the interrupt.
 *  Finally, reading the sensor status clears the local high bit.
 * @param unused not used.
 */
void SensorClearInt(int unused){
    unsigned char temp = 85;

    I2CAccess(0xB, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp, I2C_WRITE);
    I2CAccess(0, TEMP_ARA_DEV, TEMP_ARA_CHIP_SEL, &temp, I2C_READ);
    I2CAccess(0x2, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp, I2C_READ);
}

/**
 * Checks the THERM line/bit from the temperature sensor.
 * This function verifies the THERM line by verifying that the sensor THERM bit
 *  behaves correctly when manipulating the sensor's THERM limit.  The bit should
 *  be set to start, then cleared when the THERM limit is exceeded, and finally,
 *  set again when the limit is set back to the maximum. Finally, reading the sensor
 *  status clears the local THERM bit.
 */
void CheckSensorTherm(){
    unsigned char temp = 0;
    unsigned int  reg_val;

    /* set to start */
    reg_val = *((unsigned int*)0x29000004);
    if(!(reg_val & 0x00040000)){
        printf("expected THERM bit not found: 0x%08x\n", reg_val);
    }

    I2CAccess(0x20, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp, I2C_WRITE);

    reg_val = *((unsigned int*)0x29000004);
    if((reg_val & 0x00040000)){
        printf("THERM bit not cleared: 0x%08x\n", reg_val);
    }

    temp = 85;
    I2CAccess(0x20, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp, I2C_WRITE);

    reg_val = *((unsigned int*)0x29000004);
    if(!(reg_val & 0x00040000)){
        printf("expected THERM bit not found: 0x%08x\n", reg_val);
    }

    I2CAccess(0x2, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp, I2C_READ);
}

typedef void (*CauseIntFunc)(int);
typedef void (*ClearIntFunc)(int);

CauseIntFunc gCauseIntFuncArray[NUM_INTS] = {
    SystemAceCauseInt,  /* SystemAce */
    EthernetCauseInt,   /* Ethernet0 */
    EthernetCauseInt,   /* PMC_INTB by Ethernet1 */
    EthernetCauseInt,   /* PMC_INTA by Ethernet2 */
    PS2_INTCauseInt,    /* PS2_INT0 */
    PS2_INTCauseInt,    /* PS2_INT1 */
    PS2_INTCauseInt,    /* PS2_INT2 */
    PS2_INTCauseInt,    /* PS2_INT3 */
    PS2_INTCauseInt,    /* PS2_INT4 */
    PS2_INTCauseInt,    /* PS2_INT5 */
    PS2_INTCauseInt,    /* PS2_P2_INTA */
    SensorCauseInt};    /* Sensor */

ClearIntFunc gClearIntFuncArray[NUM_INTS] = {
    SystemAceClearInt,  /* SystemAce */
    EthernetClearInt,   /* Ethernet0 */
    EthernetClearInt,   /* PMC_INTB by Ethernet1 */
    EthernetClearInt,   /* PMC_INTA by Ethernet2 */
    PS2_INTClearInt,    /* PS2_INT0 */
    PS2_INTClearInt,    /* PS2_INT1 */
    PS2_INTClearInt,    /* PS2_INT2 */
    PS2_INTClearInt,    /* PS2_INT3 */
    PS2_INTClearInt,    /* PS2_INT4 */
    PS2_INTClearInt,    /* PS2_INT5 */
    PS2_INTClearInt,    /* PS2_P2_INTA */
    SensorClearInt};    /* Sensor */

int gIntFuncParamArray[NUM_INTS] = {
    0, /* SystemAce */
    0, /* Ethernet0 */
    1, /* PMC_INTB by Ethernet1 */
    2, /* PMC_INTA by Ethernet2 */
    0, /* PS2_INT0 */
    1, /* PS2_INT1 */
    2, /* PS2_INT2 */
    3, /* PS2_INT3 */
    4, /* PS2_INT4 */
    5, /* PS2_INT5 */
    6, /* PS2_P2_INTA */
    0};/* Sensor */

unsigned int gISRMaskArray[NUM_INTS] = {
    INT_SYSACE_BIT,         /* SystemAce */
    INT_ETH_BIT,            /* Ethernet0 */
    INT_PMC_INTB_BIT,       /* PMC_INTB by Ethernet1 */
    INT_PMC_INTA_BIT,       /* PMC_INTA by Ethernet2 */
    INT_PS2_INT0_BIT,       /* PS2_INT0 */
    INT_PS2_INT1_BIT,       /* PS2_INT1 */
    INT_PS2_INT2_BIT,       /* PS2_INT2 */
    INT_PS2_INT3_BIT,       /* PS2_INT3 */
    INT_PS2_INT4_BIT,       /* PS2_INT4 */
    INT_PS2_INT5_BIT,       /* PS2_INT5 */
    INT_PS2_P2_INTA_BIT,    /* PS2_P2_INTA */
    INT_SENSOR_BIT          /* Sensor */
};

char *gIntNameArray[NUM_INTS] = {
    "System Ace",               /* SystemAce */
    "Ethernet0",                /* Ethernet0 */
    "PMC_INTB by Ethernet1",    /* PMC_INTB by Ethernet1 */
    "PMC_INTA by Ethernet2",    /* PMC_INTA by Ethernet2 */
    "PS2_INT0",                 /* PS2_INT0 */
    "PS2_INT1",                 /* PS2_INT1 */
    "PS2_INT2",                 /* PS2_INT2 */
    "PS2_INT3",                 /* PS2_INT3 */
    "PS2_INT4",                 /* PS2_INT4 */
    "PS2_INT5",                 /* PS2_INT5 */
    "PS2_P2_INTA",              /* PS2_P2_INTA */
    "Sensor"};                  /* Sensor */

/**
 * Test all the external interrupt lines.
 * This test tests the 10 connected interrupt lines which are external to the
 *  FPGA by triggering an interrupt on the attached device.  After calling
 *  this function, the board must be reset for this test to pass again.
 * The test checks that each ISR bit is off, then causes the interrupt, and
 *  verifies that the ISR bit becomes set, then stops the interrupt, clears
 *  the ISR bit, and verifies that the ISR bit remains clear.
 * The lines tested are:
 *
 *  0 : system ace, by data ready interrupt
 *  1 : ethernet
 *  2 : PMC_INTB by PMC ethernet and doorbell via P2_INTA
 *  3 : PMC_INTA by PMC ethernet
 *  16: PS2_INT0 by doorbell
 *  17: PS2_INT1 by doorbell
 *  18: PS2_INT2 by doorbell
 *  19: PS2_INT3 by doorbell
 *  20: PS2_INT4 by doorbell
 *  21: PS2_INT5 by doorbell and sensor
 *
 * @return
 * <pre>
 *      0 if passed
 *     -1 if failed
 * </pre>
 * @ingroup TestSystem
 */
int int_test(){
    int ii;
    unsigned long isr;
    int ret_val = 0;

    if(!gPCIInitialized){
        printf("PCI not initialized, aborting.\n");
        return -1;
    }

    /* enable hardware interrupts and master interrupt */
    *((unsigned long *)(INTC_BASE_ADDRESS + 0x1C)) = 0x00000003;
    int_clear(0xFFFFFFFF);

    /* setup the doorbells; map DB0 -> PS2_INT0, DB1 -> PS2_INT1, etc. DB6 -> P2_INTA*/
    PowerSpanWrite(REG_DB_MAP, INT_TEST_DB_MAP);

    /* Make PS2_INT5 output so that doorbell works */
    PowerSpanWrite(REG_IDR,0xFF000000);

    /* Set up the 3 ethernet devices; one onboard, two on PMC */
    /* Turn on memory enable and bus mastering */
    /* Map CSRs to 0x3_000000 */
    PCIWriteConfig(0, 1, 0, 0x04, 4, 1, 0x6);
    PCIWriteConfig(0, 1, 0, 0x10, 4, 1, gEthernetBaseAddresses[0]);

    PCIWriteConfig(0, 2, 1, 0x04, 4, 1, 0x6);
    PCIWriteConfig(0, 2, 1, 0x10, 4, 1, gEthernetBaseAddresses[1]);

    PCIWriteConfig(0, 2, 0, 0x04, 4, 1, 0x6);
    PCIWriteConfig(0, 2, 0, 0x10, 4, 1, gEthernetBaseAddresses[2]);

    for(ii = 0;ii < NUM_INTS;ii++){
        isr = GET_ISR();
        if(isr != 0){
            printf("Unexpected bits present before testing %s: 0x%08x\n", gIntNameArray[ii], isr);
            ret_val = 1;
        }

        gCauseIntFuncArray[ii](gIntFuncParamArray[ii]);

        isr = GET_ISR();
        if(!(isr & gISRMaskArray[ii])){
            printf("%s interrupt not found!\n", gIntNameArray[ii]);
            ret_val = 1;
        }
        if((isr & !gISRMaskArray[ii])){
            printf("Unexpected bits present while testing %s: 0x%08x\n", gIntNameArray[ii], isr);
            ret_val = 1;
        }

        gClearIntFuncArray[ii](gIntFuncParamArray[ii]);
        int_clear(gISRMaskArray[ii]);

        isr = GET_ISR();
        if(isr & gISRMaskArray[ii]){
            printf("%s interrupt not cleared: 0x%08x\n", gIntNameArray[ii], isr);
            ret_val = 1;
        }
    }

    /* disable hardware interrupts and master interrupt */
    *((unsigned long *)(INTC_BASE_ADDRESS + 0x1C)) = 0x00000000;

    /* Put PS2_INT5 back */
    PowerSpanWrite(REG_IDR,0x5F000000);

    /* check sensor THERM bit */
    CheckSensorTherm();

    return ret_val;
}


/** Wrapper for int_test() */
int do_int_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[])
{
    if(int_test() != 0){
        printf("FAILED\n");
    } else {
        printf("PASS\n");
    }
}
#endif /* #if defined(CMD_TBL_INTTEST_CMD) */

#if defined(CMD_TBL_INT_CMD)

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
            if(do_int_test(cmdtp, flag, argc, argv) == 0){
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
#endif /* #if defined(CMD_TBL_INT_CMD) */

#if defined(CMD_TBL_ACE_CMD)
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

#endif /* #if defined(CMD_TBL_ACE_CMD) */

#if defined(CMD_TBL_SENSOR)

#define GET_DECIMAL(low_byte) ((low_byte >> 5) * 125)
#define TEMP_BUSY_BIT   0x80
#define TEMP_LHIGH_BIT  0x40
#define TEMP_LLOW_BIT   0x20
#define TEMP_EHIGH_BIT  0x10
#define TEMP_ELOW_BIT   0x08
#define TEMP_OPEN_BIT   0x04
#define TEMP_ETHERM_BIT 0x02
#define TEMP_LTHERM_BIT 0x01

int do_temp_sensor(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    char cmd;
    int ret_val = 0;
    unsigned char temp_byte;
    int temp;
    int temp_low;
    int low;
    int low_low;
    int high;
    int high_low;
    int therm;
    unsigned char user_data[4] = { 0 };
    int user_data_count = 0;
    int ii;

    if(argc > 1){
        cmd = argv[1][0];
    }
    else{
        cmd = 's'; /* default to status */
    }

    user_data_count = argc - 2;
    for(ii = 0;ii < user_data_count;ii++){
        user_data[ii] = simple_strtoul(argv[2 + ii], NULL, 0);
    }
    switch (cmd){
        case 's':{

            if(I2CAccess(0x2, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            printf("Status    : 0x%02x  ", temp_byte);
            if(temp_byte & TEMP_BUSY_BIT){
                printf("BUSY ");
            }

            if(temp_byte & TEMP_LHIGH_BIT){
                printf("LHIGH ");
            }

            if(temp_byte & TEMP_LLOW_BIT){
                printf("LLOW ");
            }

            if(temp_byte & TEMP_EHIGH_BIT){
                printf("EHIGH ");
            }

            if(temp_byte & TEMP_ELOW_BIT){
                printf("ELOW ");
            }

            if(temp_byte & TEMP_OPEN_BIT){
                printf("OPEN ");
            }

            if(temp_byte & TEMP_ETHERM_BIT){
                printf("ETHERM ");
            }

            if(temp_byte & TEMP_LTHERM_BIT){
                printf("LTHERM");
            }
            printf("\n");

            if(I2CAccess(0x3, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            printf("Config    : 0x%02x  ", temp_byte);

            if(I2CAccess(0x4, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                printf("\n");
                goto fail;
            }
            printf("Conversion: 0x%02x\n", temp_byte);
            if(I2CAccess(0x22, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            printf("Cons Alert: 0x%02x  ", temp_byte);

            if(I2CAccess(0x21, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                printf("\n");
                goto fail;
            }
            printf("Therm Hyst: %d\n", temp_byte);

            if(I2CAccess(0x0, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            temp = temp_byte;
            if(I2CAccess(0x6, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            low = temp_byte;
            if(I2CAccess(0x5, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            high = temp_byte;
            if(I2CAccess(0x20, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            therm = temp_byte;
            printf("Local Temp: %2d     Low: %2d     High: %2d     THERM: %2d\n", temp, low, high, therm);

            if(I2CAccess(0x1, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            temp = temp_byte;
            if(I2CAccess(0x10, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            temp_low = temp_byte;
            if(I2CAccess(0x8, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            low = temp_byte;
            if(I2CAccess(0x14, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            low_low = temp_byte;
            if(I2CAccess(0x7, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            high = temp_byte;
            if(I2CAccess(0x13, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            high_low = temp_byte;
            if(I2CAccess(0x19, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            therm = temp_byte;
            if(I2CAccess(0x11, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &temp_byte, I2C_READ) != 0){
                goto fail;
            }
            printf("Ext Temp  : %2d.%03d Low: %2d.%03d High: %2d.%03d THERM: %2d Offset: %2d\n", temp, GET_DECIMAL(temp_low), low, GET_DECIMAL(low_low), high, GET_DECIMAL(high_low), therm, temp_byte);
            break;
        }
        case 'l':{ /* alter local limits : low, high, therm */
            if(argc < 3){
                goto usage;
            }

            /* low */
            if(I2CAccess(0xC, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[0], I2C_WRITE) != 0){
                goto fail;
            }

            if(user_data_count > 1){
                /* high */
                if(I2CAccess(0xB, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[1], I2C_WRITE) != 0){
                    goto fail;
                }
            }

            if(user_data_count > 2){
                /* therm */
                if(I2CAccess(0x20, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[2], I2C_WRITE) != 0){
                    goto fail;
                }
            }
            break;
        }
        case 'e':{ /* alter external limits: low, high, therm, offset */
            if(argc < 3){
                goto usage;
            }

            /* low */
            if(I2CAccess(0xE, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[0], I2C_WRITE) != 0){
                goto fail;
            }

            if(user_data_count > 1){
                /* high */
                if(I2CAccess(0xD, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[1], I2C_WRITE) != 0){
                    goto fail;
                }
            }

            if(user_data_count > 2){
                /* therm */
                if(I2CAccess(0x19, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[2], I2C_WRITE) != 0){
                    goto fail;
                }
            }

            if(user_data_count > 3){
                /* offset */
                if(I2CAccess(0x11, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[3], I2C_WRITE) != 0){
                    goto fail;
                }
            }
            break;
        }
        case 'c':{ /* alter config settings: config, conv, cons alert, therm hyst */
            if(argc < 3){
                goto usage;
            }

            /* config */
            if(I2CAccess(0x9, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[0], I2C_WRITE) != 0){
                goto fail;
            }

            if(user_data_count > 1){
                /* conversion */
                if(I2CAccess(0xA, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[1], I2C_WRITE) != 0){
                    goto fail;
                }
            }

            if(user_data_count > 2){
                /* cons alert */
                if(I2CAccess(0x22, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[2], I2C_WRITE) != 0){
                    goto fail;
                }
            }

            if(user_data_count > 3){
                /* therm hyst */
                if(I2CAccess(0x21, I2C_SENSOR_DEV, I2C_SENSOR_CHIP_SEL, &user_data[3], I2C_WRITE) != 0){
                    goto fail;
                }
            }
            break;
        }
        default:{
            goto usage;
        }
    }

    goto done;
 fail:
    printf("Access to sensor failed\n");
    ret_val = -1;
    goto done;
 usage:
    printf ("Usage:\n%s\n", cmdtp->help);

 done:
     return ret_val;
}
#endif /* #if defined(CMD_TBL_SENSOR) */

#if defined(CMD_TBL_AUTOTEST_CMD)
int do_autotest(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    int the_flag = 0;

    if(argc > 1){
        if(tolower(argv[1][0]) == 'm'){
            the_flag = 1;
        }
    }
    TestSystemAutoRun(the_flag);
}
#endif

#define SW_BYTE_SECTOR_ADDR     0x24FE0000
#define SW_BYTE_SECTOR_OFFSET   0x0001FFFF
#define SW_BYTE_MASK            0x00000003
#define CFG_DEFAULT_TEMP_ADDR   0x00100000
#define SW_BYTE_SECTOR_SIZE     0x00020000

#if defined(CMD_TBL_SWCONFIG)

/**
 * Console command to display and set the software reconfigure byte
 * <pre>
 * swconfig         - display the current value of the software reconfigure byte
 * swconfig N [ADD] - change the software reconfigure byte to #
 * </pre>
 * @param  *cmdtp  [IN] as passed by run_command (ignored)
 * @param  flag    [IN] as passed by run_command (ignored)
 * @param  argc    [IN] as passed by run_command if 1, display, if 2 change
 * @param  *argv[] [IN] contains the parameters to use
 * @retval 0  if passed
 * @retval -1 if failed
 */
int do_swconfigbyte(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    unsigned char *sector_buffer = NULL;
    unsigned char input_char;
    int write_result;
    unsigned int  input_uint;

    /* display value if no argument */
    if(argc < 2){
        printf("Software configuration byte is currently: 0x%02x\n",
               *((unsigned char *) (SW_BYTE_SECTOR_ADDR + SW_BYTE_SECTOR_OFFSET)));
        return 0;
    }
    else if(argc > 3){
        printf("Too many arguments\n");
        return -1;
    }

    /* if 3 arguments, 3rd argument is the address to use */
    if(argc == 3){
        input_uint = simple_strtoul(argv[1], NULL, 16);
        sector_buffer = (unsigned char *)input_uint;
    }
    else{
        sector_buffer = (unsigned char *)CFG_DEFAULT_TEMP_ADDR;
    }

    input_char = simple_strtoul(argv[1], NULL, 0);
    if((input_char & ~SW_BYTE_MASK) != 0){
        printf("Input of 0x%02x will be masked to 0x%02x\n", input_char, (input_char & SW_BYTE_MASK));
        input_char = input_char & SW_BYTE_MASK;
    }

    memcpy(sector_buffer, (void *)SW_BYTE_SECTOR_ADDR, SW_BYTE_SECTOR_SIZE);
    sector_buffer[SW_BYTE_SECTOR_OFFSET] = input_char;


    printf("Erasing Flash...");
    if (flash_sect_erase (SW_BYTE_SECTOR_ADDR, (SW_BYTE_SECTOR_ADDR + SW_BYTE_SECTOR_OFFSET))){
        return -1;
    }

    printf("Writing to Flash... ");
    write_result = flash_write(sector_buffer, SW_BYTE_SECTOR_ADDR, SW_BYTE_SECTOR_SIZE);
    if (write_result != 0) {
        flash_perror (write_result);
        return -1;
    }
    else{
        printf("done\n");
        printf("Software configuration byte is now: 0x%02x\n",
                *((unsigned char *) (SW_BYTE_SECTOR_ADDR + SW_BYTE_SECTOR_OFFSET)));
    }

    return 0;
}
#endif /* #if defined(CMD_TBL_SWCONFIG) */

/**
 * Trigger a SWReconfig by writing to the CPLD.
 */
void DoSWReconfig(){
    *((unsigned char*)CPLD_BASEADDR) = 1;
}

#if defined(CMD_TBL_SWCONFIG)
int do_swreconfig(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    printf("Triggering software reconfigure (software config byte is 0x%02x)...\n",
           *((unsigned char *) (SW_BYTE_SECTOR_ADDR + SW_BYTE_SECTOR_OFFSET)));
    udelay (1000);
    DoSWReconfig();

    return 0;
}
#endif

#if defined(CMD_TBL_KINIT)

#define UBOOT_IMAGE_HEADER_OFFSET   0x1c

#define UBOOT_IMAGE_HEADER_VALUE    0x552d426f
#define KERNEL_IMAGE_HEADER_VALUE   0x05070201
#define RAMDISK_IMAGE_HEADER_VALUE  0x05070301

#define UBOOT_CHECK 0
#define KERNEL_CHECK 1
#define RAMDISK_CHECK 2
/**
 * Checks for a UBoot-type image that starts with the U-Boot magic word.
 * @param theAddress the address to check at.
 * @param theCheckHeaderFlag if UBOOT_CHECK, check for a valid U-Boot image.
 *                           if KERNEL_CHECK, check for a kernel image.
 *                           if RAMDISK_CHECK, check for a ramdisk image.
 * @retval 1 if a valid image is found.
 * @retval 0 if no image is found.
 */
int CheckForUBootImage(unsigned int theAddress, int theCheckHeaderFlag){
    unsigned int* mem_ptr = (unsigned int*)theAddress;
    int ret_val = 1;

    if(*mem_ptr != ((IH_MAGIC_WORD_1 << 16) | IH_MAGIC_WORD_2)){
        ret_val = 0;
    }
    else if(theCheckHeaderFlag == UBOOT_CHECK){
        mem_ptr++;
        if(*mem_ptr != UBOOT_IMAGE_HEADER_VALUE){
            ret_val = 0;
        }
    }
    else if(theCheckHeaderFlag == KERNEL_CHECK){
        mem_ptr = (unsigned int*)(theAddress + UBOOT_IMAGE_HEADER_OFFSET);
        if(*mem_ptr != KERNEL_IMAGE_HEADER_VALUE){
            ret_val = 0;
        }
    }
    else if(theCheckHeaderFlag == RAMDISK_CHECK){
        mem_ptr = (unsigned int*)(theAddress + UBOOT_IMAGE_HEADER_OFFSET);
        if(*mem_ptr != RAMDISK_IMAGE_HEADER_VALUE){
            ret_val = 0;
        }
    }

    return ret_val;
}

#define CONFIG_MAGIC_WORD1 0xffffffff
#define CONFIG_MAGIC_WORD2 0xaa995566
/**
 * Checks for a configuration image that starts with the configuration magic words.
 * @retval 1 if a valid image is found.
 * @retval 0 if no image is found.
 */
int CheckForConfigImage(unsigned int theAddress, int ununused){
    unsigned int* mem_ptr = (unsigned int*)theAddress;
    int ret_val = 1;

    if((mem_ptr[0] != CONFIG_MAGIC_WORD1) || (mem_ptr[1] != CONFIG_MAGIC_WORD2)){
        ret_val = 0;
    }

    return ret_val;
}

/**
 * Very lenient char check.  Anything between 0x21 and 0x7e inclusive is considered a character.
 */
#define ISALPHANUMERIC(c) ((c > 0x20) && (c < 0x7f))

#define MAX_ENV_NAME_SIZE   50
#define MAX_ENV_VALUE_SIZE  0x1000

/**
 * Checks for an environment variable image.
 * Skips the checksum, and instead verifies that a valid environment variable exists
 *  just after the checksum.  An arbitrary (but huge) limit on the size of a variable name
 *  is imposed.
 * @retval 1 if a valid image is found.
 * @retval 0 if no image is found.
 */
int CheckForEnvironmentImage(unsigned int theAddress, int ununused){
    char* mem_ptr = (char*)(theAddress + 4);
    int size;

    /* find variable name */
    if(!ISALPHANUMERIC(*mem_ptr)){
        return 0;
    }
	mem_ptr++;

    /* size will not be reset for value, as it uses the size of the environment space as it's check */
    size = 1;
    while((*mem_ptr != 0x00) && (*mem_ptr != '=') && (size < MAX_ENV_NAME_SIZE)){
        if(!ISALPHANUMERIC(*mem_ptr)){
            return 0;
        }
		mem_ptr++;
        size++;
    }

    /* find '=' */
    if((*mem_ptr != '=') || (size >= MAX_ENV_NAME_SIZE)){
        return 0;
    }

    /* find value */
    *mem_ptr++;
    size++;
    while((*mem_ptr != 0x00) && (size < MAX_ENV_VALUE_SIZE)){
        if(!ISALPHANUMERIC(*mem_ptr)){
            return 0;
        }
		mem_ptr++;
        size++;
    }

    /* check size: */
    if((*mem_ptr != 0x00) || (size >= MAX_ENV_VALUE_SIZE)){
        return 0;
    }

    return 1;
}

extern flash_info_t  flash_info[CFG_MAX_FLASH_BANKS]; /* from strataflash.c */

/**
 * (Unprotect and) erase indicated flash.
 * @param theFlashBank the 1-based index (as used by PBL and U-Boot monitor programs).
 * @param theProtectFlag if 0, do not unprotect the sectors first.
 * @retval 1 if the operation succeeeds.
 * @retval 0 if the operation fails.
 */
int KInitKleanFunc(int theFlashBank, int theStartSector, int theEndSector, int theProtectFlag){
    int ii;

    if(theProtectFlag){
        printf("Unprotecting flash...\n");
        for(ii = theStartSector; ii <= theEndSector; ii++){
            if(flash_real_protect(&flash_info[theFlashBank - 1], ii, 0)){
                printf("Unprotecting flash failed!\n");
                return 0;
            }
        }
    }

    printf("Erasing flash:");
    if(flash_erase(&flash_info[theFlashBank - 1], theStartSector, theEndSector)){
        printf("Erasing flash failed!\n");
        return 0;
    }

    return 1;
}

/**
 * Kopy image to flash (and protect).
 * After a successfull copy, break the image by writing a bunch of 0s over the image.
 * @param theFlashBank the 1-based index (as used by PBL and U-Boot monitor programs).
 * @param theProtectFlag if 0, do not unprotect the sectors first.
 * @retval 1 if the operation succeeeds.
 * @retval 0 if the operation fails.
 */
int KInitKopyFunc(unsigned int theImageSource, unsigned int theImageDest, unsigned int theImageSize){
    int ii;

    printf("Kopying to flash...\n");
    if(flash_write((unsigned char*)theImageSource, theImageDest, theImageSize)){
        printf("Kopy failed, aborting!\n");
        return 0;
    }
    else{
        memset((void*)theImageSource, 0, 0x20);
    }

    return 1;
}

int KInitProtectFunc(int theFlashBank, int theStartSector, int theEndSector){
    int ii;

    for(ii = theStartSector; ii <= theEndSector; ii++){
        if(flash_real_protect(&flash_info[theFlashBank - 1], ii, 1)){
            printf("Protecting flash failed!\n");
            return 0;
        }
    }

    return 1;
}

#define NUM_IMAGES 5

typedef int (*KInitStatusCheckFunc)(unsigned int, int);

char *gKInitImageNameArray[NUM_IMAGES] = {
    "U-Boot binary",
    "U-Boot environment",
    "Linux Kernel",
    "Linux Ramdisk",
    "Configuration"};

KInitStatusCheckFunc gKInitStatusCheckFuncArray[NUM_IMAGES] = {
    CheckForUBootImage,         /* U-Boot binary */
    CheckForEnvironmentImage,   /* U-Boot environment */
    CheckForUBootImage,         /* Linux Kernel */
    CheckForUBootImage,         /* Linux Ramdisk */
    CheckForConfigImage};       /* Configuration */

unsigned int gKInitImageBaseAddressArray [NUM_IMAGES] = {
    0x00100000,     /* U-Boot binary */
    0x00140000,     /* U-Boot environment */
    0x00160000,     /* Linux Kernel */
    0x00260000,     /* Linux Ramdisk */
    0x01100000};    /* Configuration */

unsigned int gKInitImageDestAddressArray [NUM_IMAGES] = {
    0x20000000,     /* U-Boot binary */
    0x20040000,     /* U-Boot environment */
    0x20060000,     /* Linux Kernel */
    0x20160000,     /* Linux Ramdisk */
    0x24a00000};    /* Configuration */

#if 0
/* test values */
unsigned int gKInitImageDestAddressArray [NUM_IMAGES] = {
0x20800000,     /* U-Boot binary */
0x20840000,     /* U-Boot environment */
0x20860000,     /* Linux Kernel */
0x20960000,     /* Linux Ramdisk */
0x24000000};    /* Configuration */
#endif


unsigned int gKInitImageSizeArray [NUM_IMAGES] = {
    0x00040000,     /* U-Boot binary */
    0x00001000,     /* U-Boot environment */
    0x00100000,     /* Linux Kernel */
    0x00400000,     /* Linux Ramdisk */
    0x00500000};    /* Configuration */

int gKInitStatusCheckParam2Array[NUM_IMAGES] = {
    UBOOT_CHECK,    /* U-Boot binary */
    0,              /* U-Boot environment */
    KERNEL_CHECK,   /* Linux Kernel */
    RAMDISK_CHECK,  /* Linux Ramdisk */
    0};             /* Configuration */

char gKInitCmdCharArray[NUM_IMAGES] = {
    'u',    /* U-Boot binary */
    'e',    /* U-Boot environment */
    'k',    /* Linux Kernel */
    'r',    /* Linux Ramdisk */
    'c'};   /* Configuration */

int gKInitFlashBankArray[NUM_IMAGES] = {
    1,  /* U-Boot binary */
    1,  /* U-Boot environment */
    1,  /* Linux Kernel */
    1,  /* Linux Ramdisk */
    2}; /* Configuration */

int gKInitStartSectorArray[NUM_IMAGES] = {
    0,      /* U-Boot binary */
    2,      /* U-Boot environment */
    3,      /* Linux Kernel */
    11,     /* Linux Ramdisk */
    80};    /* Configuration */

int gKInitEndSectorArray[NUM_IMAGES] = {
    1,      /* U-Boot binary */
    2,      /* U-Boot environment */
    10,     /* Linux Kernel */
    42,     /* Linux Ramdisk */
    119};   /* Configuration */

#if 0
/* test values */
int gKInitStartSectorArray[NUM_IMAGES] = {
64,      /* U-Boot binary */
66,      /* U-Boot environment */
67,      /* Linux Kernel */
75,     /* Linux Ramdisk */
0};    /* Configuration */
int gKInitEndSectorArray[NUM_IMAGES] = {
65,      /* U-Boot binary */
66,      /* U-Boot environment */
74,     /* Linux Kernel */
95,     /* Linux Ramdisk */
39};   /* Configuration */
#endif

int gKInitProtectFlagArray[NUM_IMAGES] = {
    0,  /* U-Boot binary */
    1,  /* U-Boot environment */
    0,  /* Linux Kernel */
    0,  /* Linux Ramdisk */
    1}; /* Configuration */



/**
 * Ask user to confirm KInit.
 * @retval 1 if the user says yes.
 * @retval 0 if the user says no.
 */
int KInitPromptUser(char* theString){
    int ret_val = 0;
    char input;

    printf("Klean and Initialize %s? [y/N]: ", theString);
    input = tolower(serial_getc());
    if(input == 'y'){
        ret_val = 1;
    }
    printf("%c\n", input);

    return ret_val;
}

/**
 * u-boot, environment, kernel, ramdisk, configuration
 * kinit [s]    - show status of the 5 images
 * kinit [f] a  - copy all 5 images [f] forces with no prompt
 * kinit [f] u  - copy u-boot
 * kinit [f] e  - copy environment
 * kinit [f] k  - copy kernel
 * kinit [f] r  - copy ramdisk
 * kinit [f] c  - copy configuration
 * kinit [f] b  - copy all but environment
 * return 1 on pass, 0 on fail
 */
int do_kinit(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    char cmd;
    int prompt = 1;
    int user_response = 1;
    int ii;
    int all_but_environment = 0;

    if(argc > 1){
        cmd = argv[1][0];

        /* if force flag was used, get actual command */
        if(cmd == 'f'){
            prompt = 0;

            if(argc > 2){
                cmd = argv[2][0];
            }
        }

        if(cmd == 'b'){
            all_but_environment = 1;
            cmd = 'a';
        }
    }
    else{
        cmd = 's'; /* default to status */
    }

    /* ensure valid cmd */
    if((cmd != 's') && (cmd != 'a') && (cmd != 'u') && (cmd != 'e') && (cmd != 'k') && (cmd != 'r') && (cmd != 'c')){
        printf ("Usage:\n%s\n", cmdtp->help);
        return 0;
    }

    if(cmd == 's'){
        for(ii = 0;ii < NUM_IMAGES;ii++){
            printf("%s image %s\n", gKInitImageNameArray[ii], gKInitStatusCheckFuncArray[ii](gKInitImageBaseAddressArray [ii], gKInitStatusCheckParam2Array[ii]) ? "found." : "NOT FOUND!");
        }
    }

    /* if doing all, verify all before starting any */
    if(cmd == 'a'){
        for(ii = 0;ii < NUM_IMAGES;ii++){
            if(gKInitStatusCheckFuncArray[ii](gKInitImageBaseAddressArray [ii], gKInitStatusCheckParam2Array[ii]) == 0){
                printf("%s image not found, aborting.\n", gKInitImageNameArray[ii]);
                return 0;
            }
        }

        if(prompt){
            if(!KInitPromptUser("all images")){
                return 0;
            }
        }

    }

    for(ii = 0;ii < NUM_IMAGES;ii++){
        if((cmd == gKInitCmdCharArray[ii]) || (cmd == 'a')){
            if((all_but_environment == 1) && (gKInitCmdCharArray[ii] == 'e')){
                printf("Skipping Environment.\n");
            }
            else{
                /* verify image */
                if(gKInitStatusCheckFuncArray[ii](gKInitImageBaseAddressArray [ii], gKInitStatusCheckParam2Array[ii]) == 0){
                    printf("%s image not found, aborting.\n", gKInitImageNameArray[ii]);
                    return 0;
                }

                if((prompt) && (cmd != 'a')){
                    user_response = KInitPromptUser(gKInitImageNameArray[ii]);
                }

                if(user_response){
                    printf("Kleaning %s:\n", gKInitImageNameArray[ii]);
                    if(KInitKleanFunc(gKInitFlashBankArray[ii], gKInitStartSectorArray[ii], gKInitEndSectorArray[ii], gKInitProtectFlagArray[ii]) != 1){
                        printf("\nkinit failed.\n");
                        return 0;
                    }
                    printf("Kleaning succeeded\n");

                    printf("Kopying %s:\n", gKInitImageNameArray[ii]);
                    if(KInitKopyFunc(gKInitImageBaseAddressArray[ii], gKInitImageDestAddressArray[ii], gKInitImageSizeArray[ii]) != 1){
                        printf("\nkinit failed.\n");
                        return 0;
                    }
                    printf("Kopying succeeded\n");

                    if(gKInitProtectFlagArray[ii]){
                        printf("Unprotecting flash...\n");
                        if(KInitProtectFunc(gKInitFlashBankArray[ii], gKInitStartSectorArray[ii], gKInitEndSectorArray[ii]) != 1){
                            printf("\nkinit failed.\n");
                            return 0;
                        }
                        printf("Protecting succeeded\n");
                    }
                }
            }
        }
    }

    return 1;
}
#endif /* #if defined(CMD_TBL_KINIT) */

#if defined(CMD_TBL_HOSTTEST)
#define WALKING1_BASE_ADDR 0x00100000
#define WALKING0_BASE_ADDR 0x00200000

#define HOST_MTEST_RECEIVE_OFFSET   0x400

#define TARGET_PSPAN_PCI_BASE_ADDR  0x3c000000
#define HOST_RAM_PCI_BASE_ADDR      0x38000000

#define DUT_PCI_DEV 3

/* From DUT to host PCI, default endianness */
#define HOST_TEST_WRITE_TCR_VALUE 0x28000000
#define HOST_TEST_READ_TCR_VALUE  0x88000000
#define HOST_TEST_DMA_READ  1
#define HOST_TEST_DMA_WRITE 0

#define MAX_DMA_WAIT 100

/**
 */
void HostTestSetupPatterns(unsigned int theWalking1BaseAddr, unsigned int theWalking0Addr){
    uint64* ptr64;
    uint64 pattern;
    int ii;

    /* walking 1 at 0x00100000 */
    ptr64 = (uint64*)theWalking1BaseAddr;
    pattern = 1;
    for(ii = 0;ii < 64;ii++){
        *ptr64 = pattern;
        pattern = pattern << 1;
        ptr64++;
    }

    /* walking 0 at 0x00200000 */
    ptr64 = (uint64*)theWalking0Addr;
    pattern = 1;
    for(ii = 0;ii < 64;ii++){
        *ptr64 = ~pattern;
        pattern = pattern << 1;
        ptr64++;
    }

    return;
}


#define BYTE_SWAP(x) (((x & 0xff000000) >> 24) | ((x & 0xff0000) >> 8)| ((x & 0xff00) << 8)| ((x & 0xff) << 24))

/**
 * @param theReadFlag if 0, do a write, else do a read.
 * @retval 1 if the dma succeeded.
 * @retval 0 if the dma failed.
 */
int HostTestDMA(unsigned int theSrcAddr, unsigned int theDstAddr, unsigned int theByteCount, int theReadFlag){
    volatile unsigned int* dut_reg_ptr;
    unsigned int base_tcr_value;
    int ii = 0;
    int ret_val = -1;

    if(theReadFlag){
        base_tcr_value = HOST_TEST_READ_TCR_VALUE;
    }
    else{
        base_tcr_value = HOST_TEST_WRITE_TCR_VALUE;
    }

    /* do DMA on the device under test */
    /* source address */
    dut_reg_ptr = (unsigned int*)(TARGET_PSPAN_PCI_BASE_ADDR + REG_DMA0_SRC_ADDR);
    *dut_reg_ptr = BYTE_SWAP(theSrcAddr);

    /* dest address */
    dut_reg_ptr = (unsigned int*)(TARGET_PSPAN_PCI_BASE_ADDR + REG_DMA0_DST_ADDR);
    *dut_reg_ptr = BYTE_SWAP(theDstAddr);

    /* byte count address */
    dut_reg_ptr = (unsigned int*)(TARGET_PSPAN_PCI_BASE_ADDR + REG_DMA0_TCR);
    *dut_reg_ptr = BYTE_SWAP((theByteCount | base_tcr_value));

    /* control */
    dut_reg_ptr = (unsigned int*)(TARGET_PSPAN_PCI_BASE_ADDR + REG_DMA0_GCSR);
    *dut_reg_ptr = BYTE_SWAP(DMAX_GCSR_CLEAR_STATUS);
    PSII_SYNC();
    *dut_reg_ptr = BYTE_SWAP(DMAX_GCSR_GO);

    while(ret_val == -1){
        if(BYTE_SWAP((*dut_reg_ptr)) & DMAX_GCSR_DONE){
            ret_val = 1;
        }
        else if(ii > MAX_DMA_WAIT){
            ret_val = 0;
        }
        else{
            ii++;
            udelay(10);
        }
    }

    if((BYTE_SWAP((*dut_reg_ptr)) & DMAX_GCSR_CLEAR_STATUS) && (ret_val == 0)){
        printf("DMA failed with error: 0x%x\n", *dut_reg_ptr);
    }

    return ret_val;
}
/**
 * @param theWalkingFlag [in] if 0, check a walking 1, else check a walking 0.
 * @retval 1 if the check succeeds
 * @retval 0 if the check fails
 */
int HostCheckPattern(unsigned int theStartAddr, int theWalking0Flag){
    uint64* ptr64;
    uint64 pattern;
    uint64 to_check;
    int ii;
    int ret_val = 1;

    ptr64 = (uint64*)theStartAddr;
    pattern = 1;
    for(ii = 0;((ii < 64) && (ret_val == 1));ii++){
        if(theWalking0Flag){
            to_check = ~pattern;
        }
        else{
            to_check = pattern;
        }

        if(*ptr64 != to_check){
            ret_val = 0;
            printf("Offset 0x%x: Expected 0x%x, got 0x%x\n", (ii * 8), to_check, *ptr64);
        }
        pattern = pattern << 1;
        ptr64++;
    }

    return ret_val;
}

/**
 * PowerSpan LED
 */
void HostCauseReset(){
    /* Set DUT powerspan reg base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REG_P1_BSREG, 4, 0, 0x3c000000);
    udelay(TENTH_OF_A_SECOND);
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REGS_P1_HS_CSR, 4, 0, 0x00080000);
    udelay(TENTH_OF_A_SECOND);
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REGS_P1_HS_CSR, 4, 0, 0x00000000);

    /* Clear DUT powerspan reg base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REG_P1_BSREG, 4, 0, 0x00000000);

    return;
}

/**
 * CPLD write
 */
void HostCauseSoftwareReconfig(){
    unsigned int* cpld_ptr = (unsigned int*)(0x38000000 + 0x02000000);

    /* Set DUT config flash window base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REGS_P1_BST1, 4, 0, 0x38000000);
    udelay(TENTH_OF_A_SECOND);
    *cpld_ptr = 1;

    /* Clear DUT config flash window base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REGS_P1_BST1, 4, 0, 0x00000000);

    return;
}

/**
 * Ethernet write.
 * Note that the DUT needs to come up to U-Boot for this to function properly, as U-Boot
 *  initializes the ethernet device to allow us to access it here.
 */
void HostCauseDefaultReconfig(){
    unsigned int* eth_ptr = (unsigned int*)(0x3c000000);

    /* Set DUT ethernet reg base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REGS_P1_BST3, 4, 0, 0x3c000000);

    *eth_ptr = 0;
    udelay(TENTH_OF_A_SECOND);
    *eth_ptr = 0xffffffff;

    /* Clear DUT ethernet reg base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REGS_P1_BST3, 4, 0, 0x00000000);

    return;
}

/**
 * Ask user to confirm a reconfigure type.
 * @retval 1 if the user says yes.
 * @retval 0 if the user says no.
 */
int HostPromptUser(char* theString){
    int ret_val = 1;
    char input;

    printf("Press any key to trigger %s, or 'n' to skip this step: ", theString);
    input = tolower(serial_getc());
    if(input == 'n'){
        ret_val = 0;
        printf("\nSkipped\n");
    }
    else{
        printf("\n");
    }

    return ret_val;
}

void HostMemoryTest(){
    int ret_val = 1;

    /* set ram base address to receive DMA */
    PowerSpanWrite(REGS_P1_BST0, HOST_RAM_PCI_BASE_ADDR);

    /* Set DUT powerspan reg base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REG_P1_BSREG, 4, 0, 0x3c000000);

    /* setup pattern to send */
    HostTestSetupPatterns(WALKING1_BASE_ADDR, WALKING0_BASE_ADDR);

    /* do send transfer */
    if(!HostTestDMA((HOST_RAM_PCI_BASE_ADDR + WALKING1_BASE_ADDR), WALKING1_BASE_ADDR, 0x200, HOST_TEST_DMA_WRITE)){
        printf("First DMA write failed.\n");
        return;
    }
    if(!HostTestDMA((HOST_RAM_PCI_BASE_ADDR + WALKING0_BASE_ADDR), WALKING0_BASE_ADDR, 0x200, HOST_TEST_DMA_WRITE)){
        printf("Second DMA write failed.\n");
        return;
    }

    /* do receive transfer */
    if(!HostTestDMA(WALKING1_BASE_ADDR, (HOST_RAM_PCI_BASE_ADDR + WALKING1_BASE_ADDR + HOST_MTEST_RECEIVE_OFFSET), 0x200, HOST_TEST_DMA_READ)){
        printf("First DMA read failed.\n");
        return;
    }
    if(!HostTestDMA(WALKING0_BASE_ADDR, (HOST_RAM_PCI_BASE_ADDR + WALKING0_BASE_ADDR + HOST_MTEST_RECEIVE_OFFSET), 0x200, HOST_TEST_DMA_READ)){
        printf("Second DMA read failed.\n");
        return;
    }

    /* check buffers */
    if(!HostCheckPattern((WALKING1_BASE_ADDR + HOST_MTEST_RECEIVE_OFFSET), 0)){
        printf("Walking 1s test failed.\n");
        ret_val = 0;
    }
    if(!HostCheckPattern((WALKING0_BASE_ADDR + HOST_MTEST_RECEIVE_OFFSET), 1)){
        printf("Walking 0s test failed.\n");
        ret_val = 0;
    }

    if(ret_val){
        printf("Memory test passed.\n");
    }

    /* clear ram base address on the host */
    PowerSpanWrite(REGS_P1_BST0, 0);

    /* Clear DUT powerspan reg base address */
    PCIWriteConfig(0, DUT_PCI_DEV, 0, REG_P1_BSREG, 4, 0, 0x00000000);
}

/**
 * host [a]    - test all
 * host m      - memory test
 * host r      - reset test
 * host s      - software reconfig
 * host d      - default reconfig
 *
 * - set up base address for memory
 * - do dma access
 * - check 64-bit walking 0s and 1s
 * - check the resets and reconfigures
 * return 1 on pass, 0 on fail
 */
int do_host_test(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    char cmd;
    unsigned int* dut_reg_ptr;
    int ret_val = 1;
    int do_it;

    if(argc > 1){
        cmd = argv[1][0];
    }
    else{
        cmd = 'a'; /* default to test all */
    }

    if((cmd != 'a') && (cmd != 'm') && (cmd != 'r') && (cmd != 's') && (cmd != 'd')){
        printf("Illegal parameter '%c'\n", cmd);
    }

    /* clear windows to PCI-2 */
    PowerSpanWrite(0x200, 0);
    PowerSpanWrite(0x210, 0);
    PowerSpanWrite(0x220, 0);
    PowerSpanWrite(0x230, 0);
    PowerSpanWrite(0x240, 0);
    PowerSpanWrite(0x250, 0);

    /* 4k window to PCI-1 */
    SetSlaveImage(7, PB_SI_BS_4K, PB_SLAVE_USE_MEM_IO, PX_TGT_CSR_BIG_END, TARGET_PSPAN_PCI_BASE_ADDR, TARGET_PSPAN_PCI_BASE_ADDR);
    /* 64MB window to PCI-1 */
    SetSlaveImage(6, PB_SI_BS_64MB, PB_SLAVE_USE_MEM_IO, PX_TGT_CSR_BIG_END, 0X38000000, 0X38000000);

    if((cmd == 'a') || (cmd == 'm')){
        HostMemoryTest();
    }

    if((cmd == 'a') || (cmd == 'r')){
        do_it = 1;
        if(cmd == 'a'){
            if(!HostPromptUser("reset")){
                do_it = 0;
            }
        }

        if(do_it){
            HostCauseReset();
        }
    }

    if((cmd == 'a') || (cmd == 's')){
        do_it = 1;
        if(cmd == 'a'){
            if(!HostPromptUser("software reconfig")){
                do_it = 0;
            }
        }

        if(do_it){
            HostCauseSoftwareReconfig();
        }

    }

    if((cmd == 'a') || (cmd == 'd')){
        do_it = 1;
        if(cmd == 'a'){
            if(!HostPromptUser("default reconfig")){
                do_it = 0;
            }
        }

        if(do_it){
            HostCauseDefaultReconfig();
        }
    }

    return ret_val;

}
#endif /* #if defined(CMD_TBL_HOSTTEST) */

#endif /* #if !defined(PRODUCTION) */
