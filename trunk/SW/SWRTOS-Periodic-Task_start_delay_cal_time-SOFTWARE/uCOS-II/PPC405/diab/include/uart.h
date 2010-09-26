/*----------------------------------------------------------------------
Filename        : uart.h
Description     : Header file for UART Driver.
-----------------------------------------------------------------------*/

#ifndef UART_H
#define UART_H

/*-----------------------------------------------------------------------------+
| UART base addresses in PPC405GP.
+-----------------------------------------------------------------------------*/
#define UART0_BASE    (uint32)0xEF600300
#define UART1_BASE    (uint32)0xEF600400

/*-----------------------------------------------------------------------------+
| Interrupt Enable Register.
+-----------------------------------------------------------------------------*/
#define    asyncIERModemStatusIntrEnable        0x08
#define    asyncIERRxLineStatusIntrEnable        0x04
#define    asyncIERTxHoldRegEmptyIntrEnable    0x02
#define    asyncIERRxDataReceivedIntrEnable    0x01

/*-----------------------------------------------------------------------------+
| Interrupt Identification Register.
+-----------------------------------------------------------------------------*/

#define    asyncIIRFIFOCtrlIndicatorBits    0xC0
#define    asyncIIRFIFOEnabled        0xC0
#define    asyncIIRFIFODisabled        0x00

#define    asyncIIRInterruptPrioLvlBits    0x0E
#define    asyncIIRPriorityLvl4        0x00
#define    asyncIIRPriorityLvl3        0x02
#define    asyncIIRPriorityLvl2        0x04
#define    asyncIIRPriorityLvl1        0x06

#define    asyncIIRInterruptPendBit    0x01
#define    asyncIIRInterruptPend        0x00
#define    asyncIIRInterruptPendNone    0x01

/*-----------------------------------------------------------------------------+
| FIFO Control Register.
+-----------------------------------------------------------------------------*/
#define asyncFCRFIFOEnable            0x01
#define asyncFCRFIFODisable           0x00
#define asyncFCRRxFIFOReset           0x02
#define asyncFCRTxFIFOReset           0x04
#define asyncFCRDMAModeSingle         0x00
#define asyncFCRDMAModeMultiple       0x08
#define asyncFCRRxTrigLevel1          0x00
#define asyncFCRRxTrigLevel4          0x40
#define asyncFCRRxTrigLevel8          0x80
#define asyncFCRRxTrigLevel14         0xC0

/*-----------------------------------------------------------------------------+
| Line Control Register.
+-----------------------------------------------------------------------------*/
#define asyncLCRDivisorLatchAccess    0x80
#define asyncLCRBreakEnable          0x40
#define asyncLCRBreakDisable          0x00
#define asyncLCRStickyParity          0x20
#define asyncLCREvenParity            0x10
#define asyncLCROddParity             0x00
#define asyncLCRParityEnable          0x08
#define asyncLCRParityDisable         0x00
#define asyncLCRStopBitsOne           0x00
#define asyncLCRStopBitsTwo           0x04
#define asyncLCRWordLength7           0x02
#define asyncLCRWordLength8           0x03

/*-----------------------------------------------------------------------------+
| Modem Control Register.
+-----------------------------------------------------------------------------*/
#define    asyncMCRLoopBackMode       0x10
#define    asyncMCRRtsActive          0x02    
#define    asyncMCRRtsInActive        0x00    
#define    asyncMCRDtrActive          0x01    
#define    asyncMCRDtrInActive        0x00    

/*-----------------------------------------------------------------------------+
| Line Status Register.
+-----------------------------------------------------------------------------*/
#define asyncLSRDataReady             0x01
#define asyncLSROverrunError          0x02
#define asyncLSRParityError           0x04
#define asyncLSRFramingError          0x08
#define asyncLSRBreakInterrupt        0x10
#define asyncLSRTxHoldEmpty           0x20
#define asyncLSRTxShiftEmpty          0x40
#define asyncLSRRxFIFOError           0x80

/*-----------------------------------------------------------------------------+
| Modem Status Register.
+-----------------------------------------------------------------------------*/
#define    asyncMSRDataCarrierDetect  0x80
#define    asyncMSRDataRingIndicator  0x40
#define    asyncMSRDataSetReady       0x20
#define    asyncMSRClearToSend        0x10

/*-----------------------------------------------------------------------------+
| Miscellanies defines.
+-----------------------------------------------------------------------------*/
#define asyncXOFFchar                 0x13
#define asyncXONchar                  0x11
#define asyncUseDsr                   0x00
#define asyncUseCts                   0x01
#define asyncUseInternalClock         0x00
#define asyncUseSerialClockPin        0x02


#define BASE    0   /* Base (No real reason to have this) */
#define IER     1   /* Interrupt Enable Register */
#define IIR     2   /* Interrupt ID Register */
#define FCR     2   /* FIFO Control Register */
#define LCR     3   /* Line Control Register */
#define MCR     4   /* Modem Control Register */
#define LSR     5   /* Line Status Register */
#define MSR     6   /* Modem Status Register */
#define SCR     7   /* Scratch Register */

#define UART0   (uint8)0
#define UART1   (uint8)1

/*-----------------------------------------------------------------------------+
| Prototypes.
+-----------------------------------------------------------------------------*/
sint32  uart_init();
sint8   uart1_getchar(void);
sint32  uart_putchar(uint8, sint8);
sint8   uart_nonblock_getchar();
void    out_str(uint8 *);

#define BOARD_CLOCK 7372800

#define inbyte(port)            in8(port)
#define outbyte(port,data)      out8(port,data)

#endif /* UART_H */
