//////////////////////////////////////////////////////////////////////////////
// Filename:          C:\Baseline_9_Working_Folder\K-new-base/drivers/hwrtos_v1_00_a/src/hwrtos.h
// Version:           1.00.a
// Description:       hwrtos Driver Header File
// Date:              Tue Jun 02 12:44:27 2009 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////

#ifndef HWRTOS_H
#define HWRTOS_H

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
 * -- SLAVE_REG4 : user logic slave module register 4
 * -- SLAVE_REG5 : user logic slave module register 5
 * -- SLAVE_REG6 : user logic slave module register 6
 * -- SLAVE_REG7 : user logic slave module register 7
 */
#define HWRTOS_USER_SLAVE_SPACE_OFFSET (0x00000000)
#define HWRTOS_SLAVE_REG0_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000000)
#define HWRTOS_SLAVE_REG1_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000008)
#define HWRTOS_SLAVE_REG2_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000010)
#define HWRTOS_SLAVE_REG3_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000018)
#define HWRTOS_SLAVE_REG4_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000020)
#define HWRTOS_SLAVE_REG5_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000028)
#define HWRTOS_SLAVE_REG6_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000030)
#define HWRTOS_SLAVE_REG7_OFFSET (HWRTOS_USER_SLAVE_SPACE_OFFSET + 0x00000038)

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
#define HWRTOS_USER_MASTER_SPACE_OFFSET (0x00000100)
#define HWRTOS_MASTER_CR_OFFSET (HWRTOS_USER_MASTER_SPACE_OFFSET + 0x00000000)
#define HWRTOS_MASTER_SR_OFFSET (HWRTOS_USER_MASTER_SPACE_OFFSET + 0x00000001)
#define HWRTOS_MASTER_LA_OFFSET (HWRTOS_USER_MASTER_SPACE_OFFSET + 0x00000004)
#define HWRTOS_MASTER_RA_OFFSET (HWRTOS_USER_MASTER_SPACE_OFFSET + 0x00000008)
#define HWRTOS_MASTER_LENGTH_OFFSET (HWRTOS_USER_MASTER_SPACE_OFFSET + 0x0000000C)
#define HWRTOS_MASTER_BE_OFFSET (HWRTOS_USER_MASTER_SPACE_OFFSET + 0x0000000E)
#define HWRTOS_MASTER_GO_PORT_OFFSET (HWRTOS_USER_MASTER_SPACE_OFFSET + 0x0000000F)

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
#define HWRTOS_IPIF_RST_SPACE_OFFSET (0x00000200)
#define HWRTOS_RST_OFFSET (HWRTOS_IPIF_RST_SPACE_OFFSET + 0x00000000)
#define HWRTOS_MIR_OFFSET (HWRTOS_IPIF_RST_SPACE_OFFSET + 0x00000000)

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

/**
 * IPIF Interrupt Controller Space Offsets
 * -- INTR_DISR  : device (ipif) interrupt status register
 * -- INTR_DIPR  : device (ipif) interrupt pending register
 * -- INTR_DIER  : device (ipif) interrupt enable register
 * -- INTR_DIIR  : device (ipif) interrupt id (priority encoder) register
 * -- INTR_DGIER : device (ipif) global interrupt enable register
 * -- INTR_ISR   : ip (user logic) interrupt status register
 * -- INTR_IER   : ip (user logic) interrupt enable register
 */
#define HWRTOS_IPIF_INTR_SPACE_OFFSET (0x00000300)
#define HWRTOS_INTR_DISR_OFFSET (HWRTOS_IPIF_INTR_SPACE_OFFSET + 0x00000000)
#define HWRTOS_INTR_DIPR_OFFSET (HWRTOS_IPIF_INTR_SPACE_OFFSET + 0x00000004)
#define HWRTOS_INTR_DIER_OFFSET (HWRTOS_IPIF_INTR_SPACE_OFFSET + 0x00000008)
#define HWRTOS_INTR_DIIR_OFFSET (HWRTOS_IPIF_INTR_SPACE_OFFSET + 0x00000018)
#define HWRTOS_INTR_DGIER_OFFSET (HWRTOS_IPIF_INTR_SPACE_OFFSET + 0x0000001C)
#define HWRTOS_INTR_ISR_OFFSET (HWRTOS_IPIF_INTR_SPACE_OFFSET + 0x00000020)
#define HWRTOS_INTR_IER_OFFSET (HWRTOS_IPIF_INTR_SPACE_OFFSET + 0x00000028)

/**
 * IPIF Interrupt Controller Masks
 * -- INTR_TERR_MASK : transaction error
 * -- INTR_DPTO_MASK : data phase time-out
 * -- INTR_IPIR_MASK : ip interrupt requeset
 * -- INTR_DMA0_MASK : dma channel 0 interrupt request
 * -- INTR_DMA1_MASK : dma channel 1 interrupt request
 * -- INTR_RFDL_MASK : read packet fifo deadlock interrupt request
 * -- INTR_WFDL_MASK : write packet fifo deadlock interrupt request
 * -- INTR_IID_MASK  : interrupt id
 * -- INTR_GIE_MASK  : global interrupt enable
 * -- INTR_NOPEND    : the DIPR has no pending interrupts
 */
#define INTR_TERR_MASK (0x00000001UL)
#define INTR_DPTO_MASK (0x00000002UL)
#define INTR_IPIR_MASK (0x00000004UL)
#define INTR_DMA0_MASK (0x00000008UL)
#define INTR_DMA1_MASK (0x00000010UL)
#define INTR_RFDL_MASK (0x00000020UL)
#define INTR_WFDL_MASK (0x00000040UL)
#define INTR_IID_MASK (0x000000FFUL)
#define INTR_GIE_MASK (0x80000000UL)
#define INTR_NOPEND (0x80)

/**************************** Type Definitions *****************************/


/***************** Macros (Inline Functions) Definitions *******************/

/**
 *
 * Write a value to a HWRTOS register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the HWRTOS device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void HWRTOS_mWriteReg(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Data)
 *
 */
#define HWRTOS_mWriteReg(BaseAddress, RegOffset, Data) \
 	XIo_Out32((BaseAddress) + (RegOffset), (Xuint32)(Data))

/**
 *
 * Read a value from a HWRTOS register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the HWRTOS device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	Xuint32 HWRTOS_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define HWRTOS_mReadReg(BaseAddress, RegOffset) \
 	XIo_In32((BaseAddress) + (RegOffset))


/**
 *
 * Check status of HWRTOS user logic master module.
 *
 * @param   BaseAddress is the base address of the HWRTOS device.
 *
 * @return  Status is the result of status checking.
 *
 * @note
 * C-style signature:
 * 	bool HWRTOS_mMasterDone(Xuint32 BaseAddress)
 * 	bool HWRTOS_mMasterBusy(Xuint32 BaseAddress)
 *
 */
#define HWRTOS_mMasterDone(BaseAddress) \
 	((((Xuint32) XIo_In8((BaseAddress)+(HWRTOS_MASTER_SR_OFFSET)))<<16 & MST_DONE_MASK) == MST_DONE_MASK)
#define HWRTOS_mMasterBusy(BaseAddress) \
 	((((Xuint32) XIo_In8((BaseAddress)+(HWRTOS_MASTER_SR_OFFSET)))<<16 & MST_BSY_MASK) == MST_BSY_MASK)

/**
 *
 * Reset HWRTOS via software.
 *
 * @param   BaseAddress is the base address of the HWRTOS device.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void HWRTOS_mReset(Xuint32 BaseAddress)
 *
 */
#define HWRTOS_mReset(BaseAddress) \
 	XIo_Out32((BaseAddress)+(HWRTOS_RST_OFFSET), IPIF_RESET)

/**
 *
 * Read module identification information from HWRTOS device.
 *
 * @param   BaseAddress is the base address of the HWRTOS device.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	Xuint32 HWRTOS_mReadMIR(Xuint32 BaseAddress)
 *
 */
#define HWRTOS_mReadMIR(BaseAddress) \
 	XIo_In32((BaseAddress)+(HWRTOS_MIR_OFFSET))

/************************** Function Prototypes ****************************/


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
void HWRTOS_WriteSlaveReg0(void * baseaddr_p, Xuint64 * data);
void HWRTOS_WriteSlaveReg1(void * baseaddr_p, Xuint64 * data);
void HWRTOS_WriteSlaveReg2(void * baseaddr_p, Xuint64 * data);
void HWRTOS_WriteSlaveReg3(void * baseaddr_p, Xuint64 * data);
void HWRTOS_WriteSlaveReg4(void * baseaddr_p, Xuint64 * data);
void HWRTOS_WriteSlaveReg5(void * baseaddr_p, Xuint64 * data);
void HWRTOS_WriteSlaveReg6(void * baseaddr_p, Xuint64 * data);
void HWRTOS_WriteSlaveReg7(void * baseaddr_p, Xuint64 * data);

void HWRTOS_ReadSlaveReg0(void * baseaddr_p, Xuint64 * data);
void HWRTOS_ReadSlaveReg1(void * baseaddr_p, Xuint64 * data);
void HWRTOS_ReadSlaveReg2(void * baseaddr_p, Xuint64 * data);
void HWRTOS_ReadSlaveReg3(void * baseaddr_p, Xuint64 * data);
void HWRTOS_ReadSlaveReg4(void * baseaddr_p, Xuint64 * data);
void HWRTOS_ReadSlaveReg5(void * baseaddr_p, Xuint64 * data);
void HWRTOS_ReadSlaveReg6(void * baseaddr_p, Xuint64 * data);
void HWRTOS_ReadSlaveReg7(void * baseaddr_p, Xuint64 * data);

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
void HWRTOS_EnableInterrupt(void * baseaddr_p);

/**
 *
 * Example interrupt controller handler.
 *
 * @param   baseaddr_p is the base address of the HWRTOS device.
 *
 * @return  None.
 *
 * @note    None.
 *
 */
void HWRTOS_Intr_DefaultHandler(void * baseaddr_p);

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
XStatus HWRTOS_SelfTest(void * baseaddr_p);

#endif // HWRTOS_H
