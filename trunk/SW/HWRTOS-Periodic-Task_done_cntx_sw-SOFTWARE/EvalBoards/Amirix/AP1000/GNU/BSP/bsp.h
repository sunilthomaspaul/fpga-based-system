/*
*********************************************************************************************************
*                                                uC/OS-II
*                                          The Real-Time Kernel
*
*                            (c) Copyright 1992-2007, Micrium, Inc., Weston, FL
*                                           All Rights Reserved
*
*                                          Board Support Package
*                                             Amirix AP1000
*********************************************************************************************************
*/

#include    <stdlib.h>
#include    <ucos_ii.h>

#include    "xparameters.h"
#include    "xgpio_l.h"
#include    "xintc.h"
#include    "xintc_i.h"
#include    "xintc_l.h"
#include    "xtmrctr.h"                                                                                                                                                            
#include    "xuartlite_l.h"
#include    "hwrtos.h"

/*
*********************************************************************************************************
*                                             CONSTANTS
*********************************************************************************************************
*/

#define HWRTOS_TICKS_PER_SEC           100
#define HWRTOS_PLB_CLK_FREQ            80000000

#define  hwrtos_addrp                  (void *)XPAR_HWRTOS_0_BASEADDR
#define  HWRTOS_CMD_RST                0x00000000
#define  HWRTOS_HW_INIT                0x01
#define  HWRTOS_TICK_EN                0x02
#define  HWRTOS_TICK_DIS               0x03
#define  HWRTOS_SEL_INT_OUT            0x04
#define  HWRTOS_TSK_CREATE_PERIODIC    0x05
#define  HWRTOS_TASK_DONE              0x06
#define  HWRTOS_SEMA4_CREATE           0x07
#define  HWRTOS_SEMA4_PEND             0x08
#define  HWRTOS_SEMA4_PEND_STAT        0x09
#define  HWRTOS_SEMA4_POST             0x0A
#define  HWRTOS_MBOX_CREATE            0x0B
#define  HWRTOS_MBOX_PEND              0x0C
#define  HWRTOS_MBOX_PEND_STAT         0x0D
#define  HWRTOS_MBOX_POST              0x0E
#define  HWRTOS_OS_START               0x0F
#define  HWRTOS_TEST                   0x10
#define  HWRTOS_SW_TIMER_START         0x11
#define  HWRTOS_SW_TIMER_STOP          0x12
#define  HWRTOS_CONT_TIMER_START       0x13
#define  HWRTOS_CONT_TIMER_RD          0x14
#define  HWRTOS_CONT_TIMER_STOP        0x15


#define  BSP_EXT_TMR_ADDR       XPAR_OPB_TIMER_0_BASEADDR
#define  TIMER_COUNTER_0	 	0
#define  TIMER_COUNTER_1	 	1

#define  BSP_CLK_FREQ           XPAR_CPU_PPC405_CORE_CLOCK_FREQ_HZ

#define  BSP_INTC_DEVICE_ID     XPAR_OPB_INTC_I_DEVICE_ID
#define  BSP_INTC_ADDR          XPAR_OPB_INTC_I_BASEADDR

#define  BSP_GPIO_ADDR          XPAR_OPB_GPIO_0_BASEADDR

#define  BSP_TMR_VAL            (BSP_CLK_FREQ / OS_TICKS_PER_SEC)

/*
*********************************************************************************************************
*                                             PROTOTYPES
*********************************************************************************************************
*/

INT32U	BSP_ExtTmrInit   (void);

void    BSP_SwTmrStart   (void);

INT32U  BSP_SwTmrStop    (void);

void    BSP_CnotTmrStart (void);

INT32U  BSP_CnotTmrRead  (void);   

void    BSP_ContTmrStop  (void);

INT32U	getnum		     (void);

void  	LED_Toggle       (INT8U led);
void  	LED_Off          (INT8U led);
void  	LED_On           (INT8U led);
void  	LED_Init         (void);

void  	Tmr_Init         (void);

void  	BSP_InitIO       (void);
void  	BSP_IntDisAll    (void);

/*
*********************************************************************************************************
*                                             GLOBAL VARIABLES
*********************************************************************************************************
*/

INT32U  overhead, ctx_sw_time;
