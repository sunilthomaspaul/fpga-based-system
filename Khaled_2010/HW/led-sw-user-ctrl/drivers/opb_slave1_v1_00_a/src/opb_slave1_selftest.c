//////////////////////////////////////////////////////////////////////////////
//
// ***************************************************************************
// **                                                                       **
// ** Copyright (c) 1995-2005 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** You may copy and modify these files for your own internal use solely  **
// ** with Xilinx programmable logic devices and Xilinx EDK system or       **
// ** create IP modules solely for Xilinx programmable logic devices and    **
// ** Xilinx EDK system. No rights are granted to distribute any files      **
// ** unless they are distributed in Xilinx programmable logic devices.     **
// **                                                                       **
// ***************************************************************************
//
//////////////////////////////////////////////////////////////////////////////
// Filename:          C:\users\susan\support_to_university\baseline_CMC_WL_uartlite\drivers\opb_slave1_v1_00_a\src\opb_slave1_selftest.c
// Version:           1.00.a
// Description:       Contains a diagnostic self-test function for the opb_slave1 driver
// Date:              Sun Feb 26 21:20:34 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "opb_slave1.h"

/************************** Constant Definitions ***************************/


/************************** Variable Definitions ****************************/


/************************** Function Definitions ***************************/

/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the OPB_SLAVE1 instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus OPB_SLAVE1_SelfTest(void * baseaddr_p)
{
   int     Index;
   Xuint32 baseaddr;
   Xuint8  Reg8Value;
   Xuint16 Reg16Value;
   Xuint32 Reg32Value;
   Xuint64 Reg64Value;

   /*
    * Assert the argument
    */
   XASSERT_NONVOID(baseaddr_p != XNULL);
   baseaddr = (Xuint32) baseaddr_p;

   xil_printf("******************************\n\r");
   xil_printf("* User Peripheral Self Test\n\r");
   xil_printf("******************************\n\n\r");

   /*
    * Reset the device to get it back to its default state and get module identification value
    */
   xil_printf("RST/MIR test...\n\r");
   OPB_SLAVE1_mReset(baseaddr);
   xil_printf("   - write 0x%08x to software reset register \n\r", IPIF_RESET);
   Reg32Value = OPB_SLAVE1_mReadMIR(baseaddr);
   xil_printf("   - read 0x%08x from module identification register \n\r", Reg32Value);
   xil_printf("   - RST/MIR write/read passed\n\n\r");

   return XST_SUCCESS;
}
