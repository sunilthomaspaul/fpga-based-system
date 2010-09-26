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
// Filename:          C:\solmaz\CMC\AP1100_design\baseline-ap1100_CMC\drivers\ms_rst_regs4_v1_00_a\src\ms_rst_regs4_selftest.c
// Version:           1.00.a
// Description:       Contains a diagnostic self-test function for the ms_rst_regs4 driver
// Date:              Mon Feb 20 21:10:52 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "ms_rst_regs4.h"

/************************** Constant Definitions ***************************/

#define MS_RST_REGS4_SELFTEST_BUFSIZE 128 /* size of buffer (for transfer test) in bytes*/

/************************** Variable Definitions ****************************/

static Xuint8 SrcBuffer[MS_RST_REGS4_SELFTEST_BUFSIZE];   /* Source buffer      */
static Xuint8 DstBuffer[MS_RST_REGS4_SELFTEST_BUFSIZE];   /* Destination buffer */

/************************** Function Definitions ***************************/

/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the MS_RST_REGS4 instance to be worked on.
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
XStatus MS_RST_REGS4_SelfTest(void * baseaddr_p)
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
   MS_RST_REGS4_mReset(baseaddr);
   xil_printf("   - write 0x%08x to software reset register \n\r", IPIF_RESET);
   Reg32Value = MS_RST_REGS4_mReadMIR(baseaddr);
   xil_printf("   - read 0x%08x from module identification register \n\r", Reg32Value);
   xil_printf("   - RST/MIR write/read passed\n\n\r");

   /*
    * Write to user logic slave module register(s) and read back
    */
   xil_printf("User logic slave module test...\n\r");
   xil_printf("   - write 0 to slave register 0\n\r");
   MS_RST_REGS4_mWriteSlaveReg0(baseaddr, 0);
   Reg32Value = MS_RST_REGS4_mReadSlaveReg0(baseaddr);
   xil_printf("   - read %d from register 0\n\r", Reg32Value);
   if ( Reg32Value != (Xuint32) 0 )
   {
      xil_printf("   - slave register 0 write/read failed\n\r");
      return XST_FAILURE;
   }
   xil_printf("   - write 1 to slave register 1\n\r");
   MS_RST_REGS4_mWriteSlaveReg1(baseaddr, 1);
   Reg32Value = MS_RST_REGS4_mReadSlaveReg1(baseaddr);
   xil_printf("   - read %d from register 1\n\r", Reg32Value);
   if ( Reg32Value != (Xuint32) 1 )
   {
      xil_printf("   - slave register 1 write/read failed\n\r");
      return XST_FAILURE;
   }
   xil_printf("   - write 2 to slave register 2\n\r");
   MS_RST_REGS4_mWriteSlaveReg2(baseaddr, 2);
   Reg32Value = MS_RST_REGS4_mReadSlaveReg2(baseaddr);
   xil_printf("   - read %d from register 2\n\r", Reg32Value);
   if ( Reg32Value != (Xuint32) 2 )
   {
      xil_printf("   - slave register 2 write/read failed\n\r");
      return XST_FAILURE;
   }
   xil_printf("   - write 3 to slave register 3\n\r");
   MS_RST_REGS4_mWriteSlaveReg3(baseaddr, 3);
   Reg32Value = MS_RST_REGS4_mReadSlaveReg3(baseaddr);
   xil_printf("   - read %d from register 3\n\r", Reg32Value);
   if ( Reg32Value != (Xuint32) 3 )
   {
      xil_printf("   - slave register 3 write/read failed\n\r");
      return XST_FAILURE;
   }
   xil_printf("   - slave register write/read passed\n\n\r");

   return XST_SUCCESS;
}
