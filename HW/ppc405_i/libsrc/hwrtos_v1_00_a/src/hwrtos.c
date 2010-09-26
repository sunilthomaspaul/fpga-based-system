//////////////////////////////////////////////////////////////////////////////
// Filename:          C:\Baseline_9_Working_Folder\K-new-base/drivers/hwrtos_v1_00_a/src/hwrtos.c
// Version:           1.00.a
// Description:       hwrtos Driver Source File
// Date:              Tue Jun 02 12:44:27 2009 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "hwrtos.h"

/************************** Function Definitions ***************************/

/**
 *
 * Write/Read value to/from HWRTOS user logic slave registers.
 *
 * @param   baseaddr_p is the base address of the HWRTOS device.
 * @param   data is a point to a given Xuint64 structure for fetching or storing value.
 *
 * @return  None.
 *
 * @note    data should be allocated by the caller.
 *
 */
void HWRTOS_WriteSlaveReg0(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG0_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG0_OFFSET+0x4, data->Lower);
}

void HWRTOS_WriteSlaveReg1(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG1_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG1_OFFSET+0x4, data->Lower);
}

void HWRTOS_WriteSlaveReg2(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG2_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG2_OFFSET+0x4, data->Lower);
}

void HWRTOS_WriteSlaveReg3(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG3_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG3_OFFSET+0x4, data->Lower);
}

void HWRTOS_WriteSlaveReg4(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG4_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG4_OFFSET+0x4, data->Lower);
}

void HWRTOS_WriteSlaveReg5(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG5_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG5_OFFSET+0x4, data->Lower);
}

void HWRTOS_WriteSlaveReg6(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG6_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG6_OFFSET+0x4, data->Lower);
}

void HWRTOS_WriteSlaveReg7(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG7_OFFSET, data->Upper);
  XIo_Out32(baseaddr+HWRTOS_SLAVE_REG7_OFFSET+0x4, data->Lower);
}


void HWRTOS_ReadSlaveReg0(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG0_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG0_OFFSET+0x4);
}

void HWRTOS_ReadSlaveReg1(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG1_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG1_OFFSET+0x4);
}

void HWRTOS_ReadSlaveReg2(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG2_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG2_OFFSET+0x4);
}

void HWRTOS_ReadSlaveReg3(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG3_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG3_OFFSET+0x4);
}

void HWRTOS_ReadSlaveReg4(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG4_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG4_OFFSET+0x4);
}

void HWRTOS_ReadSlaveReg5(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG5_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG5_OFFSET+0x4);
}

void HWRTOS_ReadSlaveReg6(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG6_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG6_OFFSET+0x4);
}

void HWRTOS_ReadSlaveReg7(void * baseaddr_p, Xuint64 * data)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  data->Upper = XIo_In32(baseaddr+HWRTOS_SLAVE_REG7_OFFSET);
  data->Lower = XIo_In32(baseaddr+HWRTOS_SLAVE_REG7_OFFSET+0x4);
}

/**
 *
 * Enable all possible interrupts from HWRTOS device.
 *
 * @param   baseaddr_p is the base address of the HWRTOS device.
 *
 * @return  None.
 *
 * @note    None.
 *
 */
void HWRTOS_EnableInterrupt(void * baseaddr_p)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  /*
   * Enable all interrupt source from user logic.
   */
  HWRTOS_mWriteReg(baseaddr, HWRTOS_INTR_IER_OFFSET, 0x00000001);

  /*
   * Enable all possible interrupt sources from device.
   */
  HWRTOS_mWriteReg(baseaddr, HWRTOS_INTR_DIER_OFFSET,
    INTR_TERR_MASK
    | INTR_DPTO_MASK
    | INTR_IPIR_MASK
    );

  /*
   * Set global interrupt enable.
   */
  HWRTOS_mWriteReg(baseaddr, HWRTOS_INTR_DGIER_OFFSET, INTR_GIE_MASK);
}

/**
 *
 * Example interrupt controller handler for HWRTOS device.
 * This is to show example of how to toggle write back ISR to clear interrupts.
 *
 * @param   baseaddr_p is the base address of the HWRTOS device.
 *
 * @return  None.
 *
 * @note    None.
 *
 */
void HWRTOS_Intr_DefaultHandler(void * baseaddr_p)
{
  Xuint32 baseaddr;
  Xuint32 IntrStatus;
Xuint32 IpStatus;

  baseaddr = (Xuint32) baseaddr_p;

  /*
   * Get status from Device Interrupt Status Register.
   */
  IntrStatus = HWRTOS_mReadReg(baseaddr, HWRTOS_INTR_DISR_OFFSET);

  xil_printf("Device Interrupt! DISR value : 0x%08x \n\r", IntrStatus);

  /*
   * Verify the source of the interrupt is the user logic and clear the interrupt
   * source by toggle write baca to the IP ISR register.
   */
  if ( (IntrStatus & INTR_IPIR_MASK) == INTR_IPIR_MASK )
  {
    xil_printf("User logic interrupt! \n\r");
    IpStatus = HWRTOS_mReadReg(baseaddr, HWRTOS_INTR_ISR_OFFSET);
    HWRTOS_mWriteReg(baseaddr, HWRTOS_INTR_ISR_OFFSET, IpStatus);
  }

}

