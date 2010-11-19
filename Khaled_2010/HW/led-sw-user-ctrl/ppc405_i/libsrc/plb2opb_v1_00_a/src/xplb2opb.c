/* $Id: xplb2opb.c,v 1.3 2003/02/03 22:31:43 meinelte Exp $ */
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
* @file xplb2opb.c
*
* Contains required functions for the XPlb2Opb component. See xplb2opb.h
* for more information about the component.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a ecm  12/7/01 First release
* 1.00a rpm  05/14/02 Made configuration typedef/lookup public
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xstatus.h"
#include "xparameters.h"
#include "xplb2opb.h"
#include "xplb2opb_i.h"

#include "xio.h"
#include "xio_dcr.h"    /* DCR is only interface */

/************************** Constant Definitions ****************************/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Variable Definitions ****************************/
/*
 * Array for master bit positions
 */

static Xuint32 MasterBitPos[32] =
{
    0x80000000,
    0x40000000,
    0x20000000,
    0x10000000,
    0x08000000,
    0x04000000,
    0x02000000,
    0x01000000,
    0x00800000,
    0x00400000,
    0x00200000,
    0x00100000,
    0x00080000,
    0x00040000,
    0x00020000,
    0x00010000,
    0x00008000,
    0x00004000,
    0x00002000,
    0x00001000,
    0x00000800,
    0x00000400,
    0x00000200,
    0x00000100,
    0x00000080,
    0x00000040,
    0x00000020,
    0x00000010,
    0x00000008,
    0x00000004,
    0x00000002,
    0x00000001
};


/************************** Function Prototypes *****************************/



/*****************************************************************************/
/**
*
* Initializes a specific XPlb2Opb instance.  Looks for configuration data for
* the specified device, then initializes instance data.
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
* @param    DeviceId is the unique id of the device controlled by this XPlb2Opb
*           component.  Passing in a device id associates the generic XPlb2Opb
*           component to a specific device, as chosen by the caller or application
*           developer.
*
* @return
*
* - XST_SUCCESS if everything starts up as expected.
* - XST_DEVICE_NOT_FOUND if the requested device is not found
*
* @note
*
* None.
*
*****************************************************************************/
XStatus XPlb2Opb_Initialize(XPlb2Opb *InstancePtr, Xuint16 DeviceId)
{
    XPlb2Opb_Config *BusConfigPtr;

    /*
     * Assert validates the input arguments
     */
    XASSERT_NONVOID(InstancePtr != XNULL);

    /*
     * Lookup the device configuration in the temporary CROM table. Use this
     * configuration info down below when initializing this component.
     */
    BusConfigPtr = XPlb2Opb_LookupConfig(DeviceId);

    if (BusConfigPtr == (XPlb2Opb_Config *)XNULL)
    {
        return XST_DEVICE_NOT_FOUND;
    }


    /*
     * Set some default values.
     */
    InstancePtr->BaseAddress = BusConfigPtr->BaseAddress;
    InstancePtr->NumMasters = BusConfigPtr->NumMasters;

    /*
     * Indicate the instance is now ready to use, initialized without error
     */
    InstancePtr->IsReady = XCOMPONENT_IS_READY;

    return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* Returns XTRUE is there is an error outstanding
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* Boolean XTRUE if there is an error, XFALSE if there is no current error.
*
* @note
*
* None.
*
******************************************************************************/
Xboolean XPlb2Opb_IsError(XPlb2Opb *InstancePtr)
{
    Xuint32 RegisterContents;

    /*
     * Assert validates the input arguments
     */
    XASSERT_NONVOID(InstancePtr != XNULL);
    XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BESR_MERR_OFFSET);

    return (RegisterContents != 0UL);
}

/*****************************************************************************/
/**
*
* Clears any outstanding errors for the given master.
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
* @param    Master of which the indicated error is to be cleared, valid range
*           is 0 - the number of masters on the bus
*
* @return
*
* None.
*
* @note
*
* None.
*
******************************************************************************/
void XPlb2Opb_ClearErrors(XPlb2Opb *InstancePtr, Xuint8 Master)
{
    Xuint32 ClearMask;

    /*
     * Assert validates the input arguments
     */
    XASSERT_VOID(InstancePtr != XNULL);
    XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
    XASSERT_VOID(Master < InstancePtr->NumMasters);

    /*
     * select the proper bit position
     */
    ClearMask = MasterBitPos[Master];

    /*
     * Clear the specific master error indication
     */
    XPlb2Opb_Out32(InstancePtr->BaseAddress + XP2O_BESR_MERR_OFFSET, ClearMask);
}


/*****************************************************************************/
/**
*
* Returns the error status for the specified master.
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
* @param    Master of which the indicated error is to be cleared, valid range
*           is 0 - the number of masters on the bus
*
* @return
*
* The current error status for the requested master on the PLB. The status is
* a bit-mask and the values are described in xplb2opb.h.
*
* @note
*
* None.
*
******************************************************************************/
Xuint32 XPlb2Opb_GetErrorStatus(XPlb2Opb *InstancePtr, Xuint8 Master)
{
    Xuint32 RegisterContents;
    Xuint32 MasterMask;
    Xuint32 ReturnStatus = 0UL;

    /*
     * Assert validates the input arguments
     */
    XASSERT_NONVOID(InstancePtr != XNULL);
    XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);
    XASSERT_NONVOID(Master < InstancePtr->NumMasters);

    /*
     * select the proper bit position
     */
    MasterMask = MasterBitPos[Master];

    /*
     * read each register and build up the return status
     */
    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BESR_MDRIVE_OFFSET);

    if ((RegisterContents & MasterMask) != 0)
    {
        ReturnStatus |= XP2O_DRIVING_BEAR_MASK;
    }


    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BESR_READ_OFFSET);

    if ((RegisterContents & MasterMask) != 0)
    {
        ReturnStatus |= XP2O_ERROR_READ_MASK;
    }

    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BESR_ERR_TYPE_OFFSET);

    if ((RegisterContents & MasterMask) != 0)
    {
        ReturnStatus |= XP2O_ERROR_TYPE_MASK;
    }

    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BESR_LCK_ERR_OFFSET);

    if ((RegisterContents & MasterMask) != 0)
    {
        ReturnStatus |= XP2O_LOCK_ERR_MASK;
    }

    return ReturnStatus;
}


/*****************************************************************************/
/**
*
* Returns the OPB Address where the most recent error occurred If there isn't
* an outstanding error, the last address in error is returned. 0x00000000
* is the initial value coming out of reset.
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* Address where error causing access occurred
*
* @note
*
* Calling XPlb2Opb_IsError() is recommended to confirm that an error has
* occurred prior to calling XPlb2Opb_GetErrorAddress() to ensure that the data
* in the error address register is relevant.
*
******************************************************************************/
Xuint32 XPlb2Opb_GetErrorAddress(XPlb2Opb *InstancePtr)
{
    Xuint32 RegisterContents;

    /*
     * Assert validates the input arguments
     */
    XASSERT_NONVOID(InstancePtr != XNULL);
    XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BEAR_ADDR_OFFSET);

    return RegisterContents;
}

/*****************************************************************************/
/**
*
* Returns the byte-enables asserted during the access causing the error. The
* enables are parameters in the hardware making the return value dynamic. An
* example of a 32-bit bus with all 4 byte enables available,
* XPlb2Opb_GetErrorByteEnables will have the value 0xF0000000 returned from
* a 32-bit access error.
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* The byte-enables asserted during the error causing access.
*
* @note
*
* None.
*
******************************************************************************/
Xuint32 XPlb2Opb_GetErrorByteEnables(XPlb2Opb *InstancePtr)
{
    Xuint32 RegisterContents;

    /*
     * Assert validates the input arguments
     */
    XASSERT_NONVOID(InstancePtr != XNULL);
    XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BEAR_BYTE_EN_OFFSET);

    return RegisterContents;
}

/*****************************************************************************/
/**
*
* Returns the ID of the master which is driving the error condition
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* The ID of the master that is driving the error
*
* @note
*
* None.
*
******************************************************************************/
Xuint8 XPlb2Opb_GetMasterDrivingError(XPlb2Opb *InstancePtr)
{
    Xuint32 RegisterContents;
    Xuint8 Master = 0;

    /*
     * Assert validates the input arguments
     */
    XASSERT_NONVOID(InstancePtr != XNULL);
    XASSERT_NONVOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

    /*
     * read the register and determine the correct master
     */
    RegisterContents =
        XPlb2Opb_In32(InstancePtr->BaseAddress + XP2O_BESR_MDRIVE_OFFSET);

    while (((RegisterContents & XP2O_M0_ERROR_MASK) == 0) &&
            (Master < InstancePtr->NumMasters))
    {
        /*
         * shift the register contents over to the next master's position
         */
        RegisterContents = RegisterContents << 1;
        Master++;
    }


    return Master;
}


/*****************************************************************************/
/**
*
* Returns the number of masters associated with the provided instance
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* The number of masters. This is a number from 1 to the maximum of 32.
*
* @note
*
* The value returned from this call needs to be adjusted if it is to be used
* as the argument for other calls since the masters are numbered from 0 and
* this function returns values starting at 1.
*
******************************************************************************/
Xuint8 XPlb2Opb_GetNumMasters(XPlb2Opb *InstancePtr)
{
    XASSERT_NONVOID(InstancePtr != XNULL);

    return InstancePtr->NumMasters;
}

/*****************************************************************************/
/**
*
* Enables the interrupt output from the bridge
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* None.
*
* @note
*
* The bridge hardware generates interrupts in error conditions. These interrupts
* are not handled by the driver directly. It is the application's responsibility
* to attach to the appropriate interrupt with a handler which then calls
* functions provided by this driver to determine the cause of the error and take
* the necessary actions to correct the situation.
*
******************************************************************************/
void XPlb2Opb_EnableInterrupt(XPlb2Opb *InstancePtr)
{
    /*
     * ASSERT the arguments
     */
    XASSERT_VOID(InstancePtr != XNULL);
    XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

    /*
     * enable the interrupts from the bridge
     */
    XPlb2Opb_Out32(InstancePtr->BaseAddress + XP2O_BCR_OFFSET,
              XP2O_BCR_ENABLE_INTR_MASK);
}


/*****************************************************************************/
/**
*
* Disables the interrupt output from the bridge
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* None.
*
* @note
*
* The bridge hardware generates interrupts in error conditions. These interrupts
* are not handled by the driver directly. It is the application's responsibility
* to attach to the appropriate interrupt with a handler which then calls
* functions provided by this driver to determine the cause of the error and take
* the necessary actions to correct the situation.
*
******************************************************************************/
void XPlb2Opb_DisableInterrupt(XPlb2Opb *InstancePtr)
{
    /*
     * ASSERT the arguments
     */
    XASSERT_VOID(InstancePtr != XNULL);
    XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

    /*
     * disable the interrupts from the bridge
     */
    XPlb2Opb_Out32(InstancePtr->BaseAddress + XP2O_BCR_OFFSET, 0);
}

/*****************************************************************************/
/**
*
* Forces a software-induced reset to occur in the bridge. Disables interrupts
* in the process.
*
* @param    InstancePtr is a pointer to the XPlb2Opb instance to be worked on.
*
* @return
*
* None.
*
* @note
*
* Disables interrupts in the process.
*
******************************************************************************/
void XPlb2Opb_Reset(XPlb2Opb *InstancePtr)
{
    /*
     * ASSERT the arguments
     */
    XASSERT_VOID(InstancePtr != XNULL);
    XASSERT_VOID(InstancePtr->IsReady == XCOMPONENT_IS_READY);

    /*
     * forces software interrupt to bridge
     */
    XPlb2Opb_Out32(InstancePtr->BaseAddress + XP2O_BCR_OFFSET,
              XP2O_BCR_SOFTWARE_RESET_MASK);

    /*
     * clears software interrupt to bridge
     */
    XPlb2Opb_Out32(InstancePtr->BaseAddress + XP2O_BCR_OFFSET, 0);
}

/*****************************************************************************/
/**
*
* Looks up the device configuration based on the unique device ID. The table
* PlbOpbConfigTable contains the configuration info for each device in the
* system.
*
* @param DeviceId is the unique device ID to look for
*
* @return
*
* A pointer to the configuration data for the given device, or XNULL if no
* match is found.
*
* @note
*
* None.
*
******************************************************************************/
XPlb2Opb_Config *XPlb2Opb_LookupConfig(Xuint16 DeviceId)
{
    XPlb2Opb_Config *CfgPtr = XNULL;

    int i;

    for (i=0; i < XPAR_XPLB2OPB_NUM_INSTANCES; i++)
    {
        if (XPlb2Opb_ConfigTable[i].DeviceId == DeviceId)
        {
            CfgPtr = &XPlb2Opb_ConfigTable[i];
            break;
        }
    }

    return CfgPtr;
}

