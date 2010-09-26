/* $Id: xplb2opb_l.h,v 1.3 2005/09/26 14:57:29 trujillo Exp $ */
/******************************************************************************
*
*       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*       FOR A PARTICULAR PURPOSE.
*
*       (c) Copyright 2002 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xplb2opb_l.h
*
* This file contains identifiers and low-level macros that can be used to
* access the device directly.  See xplb2opb.h for the high-level driver.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a rpm  05/10/02 First release
* </pre>
*
******************************************************************************/

#ifndef XPLB2OPB_L_H /* prevent circular inclusions */
#define XPLB2OPB_L_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#include "xbasic_types.h"
#include "xio.h"
#include "xio_dcr.h"    /* DCR is only interface */

/************************** Constant Definitions *****************************/

#define XP2O_M0_ERROR_MASK          0x80000000UL

/* PLB-OPB Bridge Register offsets - DCR bus */
#define XP2O_BESR_MERR_OFFSET       0x00 /* error register */

#define XP2O_BESR_MDRIVE_OFFSET     0x01 /* master driving the error */
#define XP2O_BESR_READ_OFFSET       0x02 /* error was a read operation */
#define XP2O_BESR_ERR_TYPE_OFFSET   0x03 /* error was a timeout */
#define XP2O_BESR_LCK_ERR_OFFSET    0x04 /* master has locked the registers */
#define XP2O_BEAR_ADDR_OFFSET       0x05 /* address where error occurred */
#define XP2O_BEAR_BYTE_EN_OFFSET    0x06 /* byte lane(s) where error occurred */
#define XP2O_BCR_OFFSET             0x07 /* control and status register */

/* BCR Register masks */
#define XP2O_BCR_ENABLE_INTR_MASK     0x80000000 /* set to enable interrupts */
#define XP2O_BCR_SOFTWARE_RESET_MASK  0x40000000 /* set to force reset,
                                                  * clear otherwise */

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/* Define the appropriate I/O access method for the bridge currently only
 * DCR
 */
#define XPlb2Opb_In32   XIo_DcrIn
#define XPlb2Opb_Out32  XIo_DcrOut

/*****************************************************************************
*
* Low-level driver macros and functions. The list below provides signatures
* to help the user use the macros.
*
* Xuint32 XPlb2Opb_mGetErrorDetectReg(Xuint32 BaseAddress)
* void XPlb2Opb_mSetErrorDetectReg(Xuint32 BaseAddress, Xuint32 Mask)
*
* Xuint32 XPlb2Opb_mGetMasterDrivingReg(Xuint32 BaseAddress)
* Xuint32 XPlb2Opb_mGetReadWriteReg(Xuint32 BaseAddress)
* Xuint32 XPlb2Opb_mGetErrorTypeReg(Xuint32 BaseAddress)
* Xuint32 XPlb2Opb_mGetLockBitReg(Xuint32 BaseAddress)
* Xuint32 XPlb2Opb_mGetErrorAddressReg(Xuint32 BaseAddress)
* Xuint32 XPlb2Opb_mGetByteEnableReg(Xuint32 BaseAddress)
*
* void XPlb2Opb_mSetControlReg(Xuint32 BaseAddress, Xuint32 Mask)
* Xuint32 XPlb2Opb_mGetControlReg(Xuint32 BaseAddress)
*
******************************************************************************/

/****************************************************************************/
/**
*
* Get the error detect register.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit value of the error detect register.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetErrorDetectReg(BaseAddress) \
                    XPlb2Opb_In32((BaseAddress) + XP2O_BESR_MERR_OFFSET)


/****************************************************************************/
/**
*
* Set the error detect register.
*
* @param    BaseAddress is the base address of the device
* @param    Mask is the 32-bit value to write to the error detect register.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mSetErrorDetectReg(BaseAddress, Mask) \
                    XPlb2Opb_Out32((BaseAddress) + XP2O_BESR_MERR_OFFSET, (Mask))


/****************************************************************************/
/**
*
* Get the master driving the error, if any.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit value of the BESR Master driving error register.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetMasterDrivingReg(BaseAddress) \
                    XPlb2Opb_In32((BaseAddress) + XP2O_BESR_MDRIVE_OFFSET)


/****************************************************************************/
/**
*
* Get the value of the Read-Not-Write register, which indicates whether the
* error is a read error or write error.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit value of the BESR RNW error register.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetReadWriteReg(BaseAddress) \
                    XPlb2Opb_In32((BaseAddress) + XP2O_BESR_READ_OFFSET)


/****************************************************************************/
/**
*
* Get the value of the error type register, which indicates whether the error
* is a timeout or a bus error.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit value of the BESR Lock error register.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetErrorTypeReg(BaseAddress) \
                    XPlb2Opb_In32((BaseAddress) + XP2O_BESR_ERR_TYPE_OFFSET)


/****************************************************************************/
/**
*
* Get the value of the lock bit register, which indicates whether the master
* has locked the error registers.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit value of the BESR Lock error register.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetLockBitReg(BaseAddress) \
                    XPlb2Opb_In32((BaseAddress) + XP2O_BESR_LCK_ERR_OFFSET)


/****************************************************************************/
/**
*
* Get the erorr address (or BEAR), which is the address that just caused the
* error.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit error address.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetErrorAddressReg(BaseAddress) \
                    XPlb2Opb_In32((BaseAddress) + XP2O_BEAR_ADDR_OFFSET)


/****************************************************************************/
/**
*
* Get the erorr address byte enable register.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit error address byte enable register contents.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetByteEnableReg(BaseAddress) \
                    XPlb2Opb_In32((BaseAddress) + XP2O_BEAR_BYTE_EN_OFFSET)


/****************************************************************************/
/**
*
* Set the control register to the given value.
*
* @param    BaseAddress is the base address of the device
* @param    Mask is the value to write to the control register.
*
* @return   None.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mSetControlReg(BaseAddress, Mask) \
             XPlb2Opb_Out32((BaseAddress) + XP2O_BCR_OFFSET, (Mask))


/****************************************************************************/
/**
*
* Get the contents of the control register.
*
* @param    BaseAddress is the base address of the device
*
* @return   The 32-bit value of the control register.
*
* @note     None.
*
*****************************************************************************/
#define XPlb2Opb_mGetControlReg(BaseAddress) \
             XPlb2Opb_In32((BaseAddress) + XP2O_BCR_OFFSET)


/************************** Function Prototypes ******************************/

#ifdef __cplusplus
}
#endif

#endif            /* end of protection macro */
