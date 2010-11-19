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
// Filename:          C:\users\susan\support_to_university\baseline_CMC_WL_uartlite\drivers\opb_slave1_v1_00_a\src\opb_slave1.h
// Version:           1.00.a
// Description:       opb_slave1 Driver Header File
// Date:              Sun Feb 26 21:20:34 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////

#ifndef OPB_SLAVE1_H
#define OPB_SLAVE1_H

/***************************** Include Files *******************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xio.h"

/************************** Constant Definitions ***************************/


/**
 * User Logic Slave Space Offsets
 */
#define OPB_SLAVE1_USER_SLAVE_SPACE_OFFSET (0x00000000)

/**
 * IPIF Reset/Mir Space Register Offsets
 * -- RST : software reset register
 * -- MIR : module identification register
 */
#define OPB_SLAVE1_IPIF_RST_SPACE_OFFSET (0x00000100)
#define OPB_SLAVE1_RST_OFFSET (OPB_SLAVE1_IPIF_RST_SPACE_OFFSET + 0x00000000)
#define OPB_SLAVE1_MIR_OFFSET (OPB_SLAVE1_IPIF_RST_SPACE_OFFSET + 0x00000000)

/**
 * IPIF Reset/Mir Masks
 * -- IPIF_MAVN_MASK   : module major version number
 * -- IPIF_MIVN_MASK   : module minor version number
 * -- IPIF_MIVL_MASK   : module minor version letter
 * -- IPIF_BID_MASK    : module block id
 * -- IPIF_BTP_MASK    : module block type
 * -- IPIF_RESET       : software reset
 */
#define IPIF_MAVN_MASK (0xF0000000UL)
#define IPIF_MIVN_MASK (0x0FE00000UL)
#define IPIF_MIVL_MASK (0x001F0000UL)
#define IPIF_BID_MASK (0x0000FF00UL)
#define IPIF_BTP_MASK (0x000000FFUL)
#define IPIF_RESET (0x0000000A)

/***************** Macros (Inline Functions) Definitions *******************/

/**
 *
 * Write a value to a OPB_SLAVE1 register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the OPB_SLAVE1 device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note    None.
 *
 * C-style signature:
 * 	void OPB_SLAVE1_mWriteReg(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Data)
 *
 */
#define OPB_SLAVE1_mWriteReg(BaseAddress, RegOffset, Data) \
 	XIo_Out32((BaseAddress) + (RegOffset), (Xuint32)(Data))

/**
 *
 * Read a value from a OPB_SLAVE1 register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the OPB_SLAVE1 device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note    None.
 *
 * C-style signature:
 * 	Xuint32 OPB_SLAVE1_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define OPB_SLAVE1_mReadReg(BaseAddress, RegOffset) \
 	XIo_In32((BaseAddress) + (RegOffset))


/**
 *
 * Reset OPB_SLAVE1 via software.
 *
 * @param   BaseAddress is the base address of the OPB_SLAVE1 device.
 *
 * @return  None.
 *
 * @note    None.
 *
 * C-style signature:
 * 	void OPB_SLAVE1_mReset(Xuint32 BaseAddress)
 *
 */
#define OPB_SLAVE1_mReset(BaseAddress) \
 	XIo_Out32((BaseAddress)+(OPB_SLAVE1_RST_OFFSET), IPIF_RESET)

/**
 *
 * Read module identification information from OPB_SLAVE1 device.
 *
 * @param   BaseAddress is the base address of the OPB_SLAVE1 device.
 *
 * @return  None.
 *
 * @note    None.
 *
 * C-style signature:
 * 	Xuint32 OPB_SLAVE1_mReadMIR(Xuint32 BaseAddress)
 *
 */
#define OPB_SLAVE1_mReadMIR(BaseAddress) \
 	XIo_In32((BaseAddress)+(OPB_SLAVE1_MIR_OFFSET))

/************************** Function Prototypes ****************************/


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
XStatus OPB_SLAVE1_SelfTest(void * baseaddr_p);

#endif // OPB_SLAVE1_H
