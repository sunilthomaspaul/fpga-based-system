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
// Filename:          C:\solmaz\CMC\AP1100_design\baseline-ap1100_CMC\drivers\slave_regs4_v1_00_a\src\slave_regs4.h
// Version:           1.00.a
// Description:       slave_regs4 Driver Header File
// Date:              Tue Feb 21 10:28:42 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////

#ifndef SLAVE_REGS4_H
#define SLAVE_REGS4_H

/***************************** Include Files *******************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xio.h"

/************************** Constant Definitions ***************************/


/**
 * User Logic Slave Space Offsets
 * -- SLAVE_REG0 : user logic slave module register 0
 * -- SLAVE_REG1 : user logic slave module register 1
 * -- SLAVE_REG2 : user logic slave module register 2
 * -- SLAVE_REG3 : user logic slave module register 3
 */
#define SLAVE_REGS4_USER_SLAVE_SPACE_OFFSET (0x00000000)
#define SLAVE_REGS4_SLAVE_REG0_OFFSET (SLAVE_REGS4_USER_SLAVE_SPACE_OFFSET + 0x00000000)
#define SLAVE_REGS4_SLAVE_REG1_OFFSET (SLAVE_REGS4_USER_SLAVE_SPACE_OFFSET + 0x00000004)
#define SLAVE_REGS4_SLAVE_REG2_OFFSET (SLAVE_REGS4_USER_SLAVE_SPACE_OFFSET + 0x00000008)
#define SLAVE_REGS4_SLAVE_REG3_OFFSET (SLAVE_REGS4_USER_SLAVE_SPACE_OFFSET + 0x0000000C)

/***************** Macros (Inline Functions) Definitions *******************/

/**
 *
 * Write a value to a SLAVE_REGS4 register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the SLAVE_REGS4 device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note    None.
 *
 * C-style signature:
 * 	void SLAVE_REGS4_mWriteReg(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Data)
 *
 */
#define SLAVE_REGS4_mWriteReg(BaseAddress, RegOffset, Data) \
 	XIo_Out32((BaseAddress) + (RegOffset), (Xuint32)(Data))

/**
 *
 * Read a value from a SLAVE_REGS4 register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the SLAVE_REGS4 device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note    None.
 *
 * C-style signature:
 * 	Xuint32 SLAVE_REGS4_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define SLAVE_REGS4_mReadReg(BaseAddress, RegOffset) \
 	XIo_In32((BaseAddress) + (RegOffset))


/**
 *
 * Write/Read value to/from SLAVE_REGS4 user logic slave registers.
 *
 * @param   BaseAddress is the base address of the SLAVE_REGS4 device.
 * @param   Value is the data written to the register.
 *
 * @return  Data is the data from the user logic slave register.
 *
 * @note    None.
 *
 * C-style signature:
 * 	Xuint32 SLAVE_REGS4_mReadSlaveRegn(Xuint32 BaseAddress)
 *
 */
#define SLAVE_REGS4_mWriteSlaveReg0(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG0_OFFSET), (Xuint32)(Value))
#define SLAVE_REGS4_mWriteSlaveReg1(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG1_OFFSET), (Xuint32)(Value))
#define SLAVE_REGS4_mWriteSlaveReg2(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG2_OFFSET), (Xuint32)(Value))
#define SLAVE_REGS4_mWriteSlaveReg3(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG3_OFFSET), (Xuint32)(Value))

#define SLAVE_REGS4_mReadSlaveReg0(BaseAddress) \
 	XIo_In32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG0_OFFSET))
#define SLAVE_REGS4_mReadSlaveReg1(BaseAddress) \
 	XIo_In32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG1_OFFSET))
#define SLAVE_REGS4_mReadSlaveReg2(BaseAddress) \
 	XIo_In32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG2_OFFSET))
#define SLAVE_REGS4_mReadSlaveReg3(BaseAddress) \
 	XIo_In32((BaseAddress) + (SLAVE_REGS4_SLAVE_REG3_OFFSET))

/************************** Function Prototypes ****************************/


/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the SLAVE_REGS4 instance to be worked on.
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
XStatus SLAVE_REGS4_SelfTest(void * baseaddr_p);

#endif // SLAVE_REGS4_H
