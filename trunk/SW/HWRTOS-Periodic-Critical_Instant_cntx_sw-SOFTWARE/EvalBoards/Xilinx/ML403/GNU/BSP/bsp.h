/*
*********************************************************************************************************
*                                                uC/OS-II
*                                          The Real-Time Kernel
*
*                            (c) Copyright 1992-2007, Micrium, Inc., Weston, FL
*                                           All Rights Reserved
*
*                                          Board Support Package
*                                             Xilinx ML403
*********************************************************************************************************
*/

#include    <ucos_ii.h>

#include    "xparameters.h"
#include    "xgpio_l.h"
#include    "xintc.h"
#include    "xintc_i.h"
#include    "xintc_l.h"

/*
*********************************************************************************************************
*                                             CONSTANTS
*********************************************************************************************************
*/

#define  BSP_CLK_FREQ           XPAR_CPU_PPC405_CORE_CLOCK_FREQ_HZ

#define  BSP_INTC_DEVICE_ID     XPAR_INTC_0_DEVICE_ID

#define  BSP_INTC_ADDR          XPAR_INTC_0_BASEADDR

#define  BSP_GPIO_ADDR          XPAR_LEDS_4BIT_BASEADDR

#define  BSP_TMR_VAL            (BSP_CLK_FREQ / OS_TICKS_PER_SEC)

/*
*********************************************************************************************************
*                                             PROTOTYPES
*********************************************************************************************************
*/

void  LED_Toggle          (INT8U led);
void  LED_Off             (INT8U led);
void  LED_On              (INT8U led);
void  LED_Init            (void);

void  Tmr_Init            (void);

void  BSP_InitIO          (void);
void  BSP_IntDisAll       (void);

