//////////////////////////////////////////////////////////////////////////////
// Filename:          C:\Baseline_9_Working_Folder\K-new-base/drivers/hwrtos_v1_00_a/src/hwrtos_selftest.c
// Version:           1.00.a
// Description:       Contains a diagnostic self-test function for the hwrtos driver
// Date:              Tue Jun 02 12:44:27 2009 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "hwrtos.h"

/************************** Constant Definitions ***************************/

#define HWRTOS_SELFTEST_BUFSIZE  128 /* Size of buffer (for transfer test) in bytes */

/************************** Variable Definitions ****************************/

static Xuint8 __attribute__((aligned (64))) SrcBuffer[HWRTOS_SELFTEST_BUFSIZE]; /* Source buffer      */
static Xuint8 __attribute__((aligned (64))) DstBuffer[HWRTOS_SELFTEST_BUFSIZE]; /* Destination buffer */

/************************** Function Definitions ***************************/

/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the HWRTOS instance to be worked on.
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
XStatus HWRTOS_SelfTest(void * baseaddr_p)
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
   HWRTOS_mReset(baseaddr);
   xil_printf("   - write 0x%08x to software reset register \n\r", IPIF_RESET);
   Reg32Value = HWRTOS_mReadMIR(baseaddr);
   if ( Reg32Value == 0x20200308 )
   {
      xil_printf("   - read 0x%08x (expected) from module identification register \n\r", Reg32Value);
      xil_printf("   - RST/MIR write/read passed\n\n\r");
   }
   else
   {
      xil_printf("   - read 0x%08x (unexpected) from module identification register, expect 0x20200308 \n\r", Reg32Value);
      xil_printf("   - RST/MIR write/read failed\n\n\r");
      return XST_FAILURE;
   }

   /*
    * Write to user logic slave module register(s) and read back
    */
   xil_printf("User logic slave module test...\n\r");
   Reg64Value.Upper = 1;
   Reg64Value.Lower = 1;
   xil_printf("   - write 1 to slave register 0 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg0(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg0(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 0 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 1 || Reg64Value.Lower != (Xuint32) 1 )
   {
      xil_printf("   - slave register 0 write/read failed\n\r");
      return XST_FAILURE;
   }
   Reg64Value.Upper = 2;
   Reg64Value.Lower = 2;
   xil_printf("   - write 2 to slave register 1 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg1(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg1(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 1 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 2 || Reg64Value.Lower != (Xuint32) 2 )
   {
      xil_printf("   - slave register 1 write/read failed\n\r");
      return XST_FAILURE;
   }
   Reg64Value.Upper = 3;
   Reg64Value.Lower = 3;
   xil_printf("   - write 3 to slave register 2 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg2(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg2(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 2 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 3 || Reg64Value.Lower != (Xuint32) 3 )
   {
      xil_printf("   - slave register 2 write/read failed\n\r");
      return XST_FAILURE;
   }
   Reg64Value.Upper = 4;
   Reg64Value.Lower = 4;
   xil_printf("   - write 4 to slave register 3 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg3(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg3(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 3 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 4 || Reg64Value.Lower != (Xuint32) 4 )
   {
      xil_printf("   - slave register 3 write/read failed\n\r");
      return XST_FAILURE;
   }
   Reg64Value.Upper = 5;
   Reg64Value.Lower = 5;
   xil_printf("   - write 5 to slave register 4 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg4(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg4(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 4 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 5 || Reg64Value.Lower != (Xuint32) 5 )
   {
      xil_printf("   - slave register 4 write/read failed\n\r");
      return XST_FAILURE;
   }
   Reg64Value.Upper = 6;
   Reg64Value.Lower = 6;
   xil_printf("   - write 6 to slave register 5 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg5(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg5(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 5 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 6 || Reg64Value.Lower != (Xuint32) 6 )
   {
      xil_printf("   - slave register 5 write/read failed\n\r");
      return XST_FAILURE;
   }
   Reg64Value.Upper = 7;
   Reg64Value.Lower = 7;
   xil_printf("   - write 7 to slave register 6 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg6(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg6(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 6 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 7 || Reg64Value.Lower != (Xuint32) 7 )
   {
      xil_printf("   - slave register 6 write/read failed\n\r");
      return XST_FAILURE;
   }
   Reg64Value.Upper = 8;
   Reg64Value.Lower = 8;
   xil_printf("   - write 8 to slave register 7 upper and lower portion\n\r");
   HWRTOS_WriteSlaveReg7(baseaddr_p, &Reg64Value);
   HWRTOS_ReadSlaveReg7(baseaddr_p, &Reg64Value);
   xil_printf("   - read %d, %d from register 7 upper and lower portion \n\r", Reg64Value.Upper, Reg64Value.Lower);
   if ( Reg64Value.Upper != (Xuint32) 8 || Reg64Value.Lower != (Xuint32) 8 )
   {
      xil_printf("   - slave register 7 write/read failed\n\r");
      return XST_FAILURE;
   }
   xil_printf("   - slave register write/read passed\n\n\r");

   /*
    * Enable all possible interrupts and clear interrupt status register(s)
    */
   xil_printf("Interrupt controller test...\n\r");
   Reg32Value = HWRTOS_mReadReg(baseaddr, HWRTOS_INTR_ISR_OFFSET);
   xil_printf("   - IP (user logic) interrupt status : 0x%08x \n\r", Reg32Value);
   xil_printf("   - clear IP (user logic) interrupt status register\n\r");
   HWRTOS_mWriteReg(baseaddr, HWRTOS_INTR_ISR_OFFSET, Reg32Value);
   Reg32Value = HWRTOS_mReadReg(baseaddr, HWRTOS_INTR_DISR_OFFSET);
   xil_printf("   - Device (peripheral) interrupt status : 0x%08x \n\r", Reg32Value);
   xil_printf("   - clear Device (peripheral) interrupt status register\n\r");
   HWRTOS_mWriteReg(baseaddr, HWRTOS_INTR_DISR_OFFSET, Reg32Value);
   xil_printf("   - enable all possible interrupt(s)\n\r");
   HWRTOS_EnableInterrupt(baseaddr_p);
   xil_printf("   - write/read interrupt register passed \n\n\r");

   return XST_SUCCESS;
}
