/* $Id: xplb2opb_selftest.c,v 1.2 2002/07/26 20:19:19 linnj Exp $ */
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
* @file xplb2opb_selftest.c
*
* Contains diagnostic self-test functions for the XPlb2Opb component.
* See xplb2opb.h for more information about the component.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a ecm  12/7/01 First release
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xstatus.h"
#include "xplb2opb.h"
#include "xplb2opb_i.h"

#include "xio.h"
#include "xio_dcr.h"    /* DCR is only interface */

/************************** Constant Definitions ****************************/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Variable Definitions ****************************/

/************************** Function Prototypes *****************************/


/*****************************************************************************/
/**
*
* Runs a self-test on the driver/device.
*
* This tests reads the BCR to verify that the proper value is there.
*
* XST_SUCCESS is returned if expected value is there,
* XST_PLB2OPB_FAIL_SELFTEST is returned otherwise.
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
* @param    TestAddress is a location that could cause an error on read,
*           not used - user definable for hw specific implementations.
*
* @return
*
* XST_SUCCESS if successful, or XST_PLB2OPB_FAIL_SELFTEST if the driver fails
* self-test.
*
* @note
*
* This test assumes that the bus error interrupts are not enabled.
*
******************************************************************************/
XStatus XPlb2Opb_SelfTest(XPlb2Opb *InstancePtr, Xuint32 TestAddress)
{
    volatile Xuint32 TestReadResult;

    /*
     * ASSERT the arguments
     */
    XASSERT_NONVOID(InstancePtr != XNULL);
    XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
    XASSERT_NONVOID(TestAddress != 0UL);

    /*
     * perform the read of the register
     */
    TestReadResult = XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BCR_OFFSET);

    /*
     * check for error
     */
    if (TestReadResult != XP2O_BCR_ENABLE_INTR_MASK)
    {
        /*
         * test failed, indicate this to the calling routine
         */
        return XST_PLB2OPB_FAIL_SELFTEST;
    }

    /*
     * test passed, indicate this to the calling routine
     */
    return XST_SUCCESS;
}

