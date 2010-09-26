/* $Id: xplb2opb.h,v 1.3 2005/09/26 14:57:29 trujillo Exp $ */
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
* @file xplb2opb.h
*
* This component contains the implementation of the XPlb2Opb component. It is
* the driver for the PLB to OPB Bridge. The bridge converts PLB bus transactions
* to OPB bus transactions. The hardware acts as a slave on the PLB side and as
* a master on the OPB side. This interface is necessary for the processor to
* access OPB based peripherals.
*
* This driver allows the user to access the Bridge registers to support
* the handling of bus errors and other access errors and determine an
* appropriate solution if possible.
*
* The bridge hardware generates interrupts in error conditions. These interrupts
* are not handled by the driver directly. It is the application's responsibility
* to attach to the appropriate interrupt with a handler which then calls
* functions provided by this driver to determine the cause of the error and take
* the necessary actions to correct the situation.
*
* The Xilinx PLB to OPB Bridge is a soft IP core designed for Xilinx FPGAs and
* contains the following features:
*   - PLB Slave interface
*   - 32-bit or 64-bit PLB Slave (configurable via a design parameter)
*   - Communicates with 32- or 64-bit PLB masters
*   - Non-burst transfers of 1-8 bytes
*   - Burst transfers, including word and double-word bursts of fixed or variable
*       lengths, up to depth of burst buffer. Buffer depth configurable via a
*       design parameter
*   - Limited support for byte, half-word, quad-word and octal-word bursts to
*       maintain PLB compliance
*   - Cacheline transactions of 4, 8, and 16 words
*   - Support for transactions not utilized by the PPC405 Core can be eliminated
*       via a design parameter
*   - PPC405 Core only utilizes single beat, 4, 8, or 16 word line transfers
*       support for burst transactions can be eliminated via a design parameter
*   - Supports up to 8 PLB masters (number of PLB masters configurable via a
*       design parameter)
*   - Programmable lower and upper address boundaries
*   - OPB Master interface with byte enable transfers
*       <i>Note</i>: Does not support dynamic bus sizing without additional glue logic
*   - Data width configurable via a design parameter
*   - PLB and OPB clocks can have a 1:1, 1:2, 1:4 synchronous relationship
*   - Bus Error Address Registers (BEAR) and Bus Error Status Registers (BESR)
*       to report errors
*   - DCR Slave interface provides access to BEAR/BESR
*   - BEAR, BESR, and DCR interface can be removed from the design via a design
*       parameter
*   - Posted write buffer. Buffer depth configurable via a design parameter
*
* <b>Device Configuration</b>
*
* The device can be configured in various ways during the FPGA implementation
* process.  The current configuration data contained in xplb2opb_g.c. A
* table is defined where each entry contains configuration information for
* device. This information includes such things as the base address of the DCR
* mapped device, and the number of masters on the bus.
*
* @note
*
* This driver is not thread-safe. Thread safety must be guaranteed by the layer
* above this driver if there is a need to access the device from multiple
* threads.
* <br><br>
* The Bridge registers reside on the DCR address bus.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a ecm  12/7/01  First release
* 1.00a rpm  05/14/02 Made configuration typedef/lookup public
* </pre>
*
*****************************************************************************/

#ifndef XPLB2OPB_H /* prevent circular inclusions */
#define XPLB2OPB_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/
#include "xbasic_types.h"
#include "xstatus.h"
#include "xplb2opb_l.h"

/************************** Constant Definitions ****************************/


/** @name PLB-OPB bridge error status masks
 * @{
 */
/**
 * <pre>
 * XP2O_DRIVING_BEAR_MASK           Indicates this master is driving the
 *                                  outstanding error
 * XP2O_ERROR_READ_MASK             Indicates the error is a read error. It is
 *                                  a write error otherwise.
 * XP2O_ERROR_TYPE_MASK             If set, the error was a timeout. Otherwise
 *                                  the error was an error acknowledge
 * XP2O_LOCK_ERR_MASK               Indicates the error is locked and cannot
 *                                  be overwritten.
 * </pre>
 */
#define XP2O_DRIVING_BEAR_MASK       0x80000000UL
#define XP2O_ERROR_READ_MASK         0x40000000UL
#define XP2O_ERROR_TYPE_MASK         0x20000000UL
#define XP2O_LOCK_ERR_MASK           0x10000000UL
/*@}*/

/**************************** Type Definitions ******************************/

/**
 * This typedef contains configuration information for the device.
 */
typedef struct
{
    Xuint16 DeviceId;       /**< Unique ID  of device */
    Xuint32 BaseAddress;    /**< Base address of device */
    Xuint8 NumMasters;      /**< Number of masters on the bus */
} XPlb2Opb_Config;


/**
 * The XPlb2Opb driver instance data. The user is required to allocate a
 * variable of this type for every PLB-to_OPB bridge device in the system.
 * A pointer to a variable of this type is then passed to the driver API
 * functions.
 */
typedef struct
{
    Xuint32 BaseAddress;        /* Base address of device */
    Xuint32 IsReady;            /* Device is initialized and ready */
    Xuint8 NumMasters;          /* number of masters for this bridge */

} XPlb2Opb;



/***************** Macros (Inline Functions) Definitions ********************/


/************************** Function Prototypes *****************************/


/*
 * Required functions in xplb2opb.c
 */

/*
 * Initialization Functions
 */
XStatus XPlb2Opb_Initialize(XPlb2Opb *InstancePtr, Xuint16 DeviceId);
void XPlb2Opb_Reset(XPlb2Opb *InstancePtr);
XPlb2Opb_Config *XPlb2Opb_LookupConfig(Xuint16 DeviceId);

/*
 * Access Functions
 */

Xboolean XPlb2Opb_IsError(XPlb2Opb *InstancePtr);
void XPlb2Opb_ClearErrors(XPlb2Opb *InstancePtr, Xuint8 Master);

Xuint32 XPlb2Opb_GetErrorStatus(XPlb2Opb *InstancePtr, Xuint8 Master);
Xuint32 XPlb2Opb_GetErrorAddress(XPlb2Opb *InstancePtr);
Xuint32 XPlb2Opb_GetErrorByteEnables(XPlb2Opb *InstancePtr);
Xuint8 XPlb2Opb_GetMasterDrivingError(XPlb2Opb *InstancePtr);

/*
 * Configuration
 */
Xuint8 XPlb2Opb_GetNumMasters(XPlb2Opb *InstancePtr);
void XPlb2Opb_EnableInterrupt(XPlb2Opb *InstancePtr);
void XPlb2Opb_DisableInterrupt(XPlb2Opb *InstancePtr);


/*
 * Self-test functions in xplb2opb_selftest.c
 */
XStatus XPlb2Opb_SelfTest(XPlb2Opb *InstancePtr, Xuint32 TestAddress);

#ifdef __cplusplus
}
#endif

#endif            /* end of protection macro */
