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
// Filename:          C:\solmaz\CMC\AP1100_design\baseline-ap1100_CMC\drivers\ms_rst_regs4_v1_00_a\src\ms_rst_regs4.h
// Version:           1.00.a
// Description:       ms_rst_regs4 Driver Header File
// Date:              Mon Feb 20 21:10:52 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////

#ifndef MS_RST_REGS4_H
#define MS_RST_REGS4_H

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
#define MS_RST_REGS4_USER_SLAVE_SPACE_OFFSET (0x00000000)
#define MS_RST_REGS4_SLAVE_REG0_OFFSET (MS_RST_REGS4_USER_SLAVE_SPACE_OFFSET + 0x00000000)
#define MS_RST_REGS4_SLAVE_REG1_OFFSET (MS_RST_REGS4_USER_SLAVE_SPACE_OFFSET + 0x00000004)
#define MS_RST_REGS4_SLAVE_REG2_OFFSET (MS_RST_REGS4_USER_SLAVE_SPACE_OFFSET + 0x00000008)
#define MS_RST_REGS4_SLAVE_REG3_OFFSET (MS_RST_REGS4_USER_SLAVE_SPACE_OFFSET + 0x0000000C)

/**
 * User Logic Master Space Offsets
 * -- MASTER_CR      : user logic master module control register
 * -- MASTER_SR      : user logic master module status register
 * -- MASTER_LA      : user logic master module local address (IP2IP_Addr) register
 * -- MASTER_RA      : user logic master module remote address (IP2Bus_Addr) register
 * -- MASTER_LENGTH  : user logic master module data transfer length (bytes) register
 * -- MASTER_BE      : user logic master module byte enable register
 * -- MASTER_GO_PORT : user logic master module go bit (to start master operation)
 */
#define MS_RST_REGS4_USER_MASTER_SPACE_OFFSET (0x00000100)
#define MS_RST_REGS4_MASTER_CR_OFFSET (MS_RST_REGS4_USER_MASTER_SPACE_OFFSET + 0x00000000)
#define MS_RST_REGS4_MASTER_SR_OFFSET (MS_RST_REGS4_USER_MASTER_SPACE_OFFSET + 0x00000001)
#define MS_RST_REGS4_MASTER_LA_OFFSET (MS_RST_REGS4_USER_MASTER_SPACE_OFFSET + 0x00000004)
#define MS_RST_REGS4_MASTER_RA_OFFSET (MS_RST_REGS4_USER_MASTER_SPACE_OFFSET + 0x00000008)
#define MS_RST_REGS4_MASTER_LENGTH_OFFSET (MS_RST_REGS4_USER_MASTER_SPACE_OFFSET + 0x0000000C)
#define MS_RST_REGS4_MASTER_BE_OFFSET (MS_RST_REGS4_USER_MASTER_SPACE_OFFSET + 0x0000000E)
#define MS_RST_REGS4_MASTER_GO_PORT_OFFSET (MS_RST_REGS4_USER_MASTER_SPACE_OFFSET + 0x0000000F)

/**
 * User Logic Master Module Masks
 * -- MST_RD_MASK   : user logic master read request control
 * -- MST_WR_MASK   : user logic master write request control
 * -- MST_BL_MASK   : user logic master bus lock control
 * -- MST_BRST_MASK : user logic master burst assertion control
 * -- MST_DONE_MASK : user logic master transfer done status
 * -- MST_BSY_MASK  : user logic master busy status
 * -- MST_BRRD      : user logic master burst read request
 * -- MST_BRWR      : user logic master burst write request
 * -- MST_SGRD      : user logic master single read request
 * -- MST_SGWR      : user logic master single write request
 * -- MST_START     : user logic master to start transfer
 */
#define MST_RD_MASK (0x80000000UL)
#define MST_WR_MASK (0x40000000UL)
#define MST_BL_MASK (0x20000000UL)
#define MST_BRST_MASK (0x10000000UL)
#define MST_DONE_MASK (0x00800000UL)
#define MST_BSY_MASK (0x00400000UL)
#define MST_BRRD (0x90)
#define MST_BRWR (0x50)
#define MST_SGRD (0x80)
#define MST_SGWR (0x40)
#define MST_START (0x0A)

/**
 * IPIF Reset/Mir Space Register Offsets
 * -- RST : software reset register
 * -- MIR : module identification register
 */
#define MS_RST_REGS4_IPIF_RST_SPACE_OFFSET (0x00000200)
#define MS_RST_REGS4_RST_OFFSET (MS_RST_REGS4_IPIF_RST_SPACE_OFFSET + 0x00000000)
#define MS_RST_REGS4_MIR_OFFSET (MS_RST_REGS4_IPIF_RST_SPACE_OFFSET + 0x00000000)

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
 * Write a value to a MS_RST_REGS4 register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the MS_RST_REGS4 device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note    None.
 *
 * C-style signature:
 * 	void MS_RST_REGS4_mWriteReg(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Data)
 *
 */
#define MS_RST_REGS4_mWriteReg(BaseAddress, RegOffset, Data) \
 	XIo_Out32((BaseAddress) + (RegOffset), (Xuint32)(Data))

/**
 *
 * Read a value from a MS_RST_REGS4 register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the MS_RST_REGS4 device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note    None.
 *
 * C-style signature:
 * 	Xuint32 MS_RST_REGS4_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define MS_RST_REGS4_mReadReg(BaseAddress, RegOffset) \
 	XIo_In32((BaseAddress) + (RegOffset))


/**
 *
 * Write/Read value to/from MS_RST_REGS4 user logic slave registers.
 *
 * @param   BaseAddress is the base address of the MS_RST_REGS4 device.
 * @param   Value is the data written to the register.
 *
 * @return  Data is the data from the user logic slave register.
 *
 * @note    None.
 *
 * C-style signature:
 * 	Xuint32 MS_RST_REGS4_mReadSlaveRegn(Xuint32 BaseAddress)
 *
 */
#define MS_RST_REGS4_mWriteSlaveReg0(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG0_OFFSET), (Xuint32)(Value))
#define MS_RST_REGS4_mWriteSlaveReg1(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG1_OFFSET), (Xuint32)(Value))
#define MS_RST_REGS4_mWriteSlaveReg2(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG2_OFFSET), (Xuint32)(Value))
#define MS_RST_REGS4_mWriteSlaveReg3(BaseAddress, Value) \
 	XIo_Out32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG3_OFFSET), (Xuint32)(Value))

#define MS_RST_REGS4_mReadSlaveReg0(BaseAddress) \
 	XIo_In32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG0_OFFSET))
#define MS_RST_REGS4_mReadSlaveReg1(BaseAddress) \
 	XIo_In32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG1_OFFSET))
#define MS_RST_REGS4_mReadSlaveReg2(BaseAddress) \
 	XIo_In32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG2_OFFSET))
#define MS_RST_REGS4_mReadSlaveReg3(BaseAddress) \
 	XIo_In32((BaseAddress) + (MS_RST_REGS4_SLAVE_REG3_OFFSET))

/**
 *
 * Check status of MS_RST_REGS4 user logic master module.
 *
 * @param   BaseAddress is the base address of the MS_RST_REGS4 device.
 *
 * @return  Status is the result of status checking.
 *
 * @note    None.
 *
 * C-style signature:
 * 	bool MS_RST_REGS4_mMasterDone(Xuint32 BaseAddress)
 * 	bool MS_RST_REGS4_mMasterBusy(Xuint32 BaseAddress)
 *
 */
#define MS_RST_REGS4_mMasterDone(BaseAddress) \
 	((((Xuint32) XIo_In8((BaseAddress)+(MS_RST_REGS4_MASTER_SR_OFFSET)))<<16 & MST_DONE_MASK) == MST_DONE_MASK)
#define MS_RST_REGS4_mMasterBusy(BaseAddress) \
 	((((Xuint32) XIo_In8((BaseAddress)+(MS_RST_REGS4_MASTER_SR_OFFSET)))<<16 & MST_BSY_MASK) == MST_BSY_MASK)

/**
 *
 * Reset MS_RST_REGS4 via software.
 *
 * @param   BaseAddress is the base address of the MS_RST_REGS4 device.
 *
 * @return  None.
 *
 * @note    None.
 *
 * C-style signature:
 * 	void MS_RST_REGS4_mReset(Xuint32 BaseAddress)
 *
 */
#define MS_RST_REGS4_mReset(BaseAddress) \
 	XIo_Out32((BaseAddress)+(MS_RST_REGS4_RST_OFFSET), IPIF_RESET)

/**
 *
 * Read module identification information from MS_RST_REGS4 device.
 *
 * @param   BaseAddress is the base address of the MS_RST_REGS4 device.
 *
 * @return  None.
 *
 * @note    None.
 *
 * C-style signature:
 * 	Xuint32 MS_RST_REGS4_mReadMIR(Xuint32 BaseAddress)
 *
 */
#define MS_RST_REGS4_mReadMIR(BaseAddress) \
 	XIo_In32((BaseAddress)+(MS_RST_REGS4_MIR_OFFSET))

/************************** Function Prototypes ****************************/


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
XStatus MS_RST_REGS4_SelfTest(void * baseaddr_p);

#endif // MS_RST_REGS4_H
