/*
*********************************************************************************************************
*                                             uC/OS-II
*                                        The Real-Time Kernel
*
*                          (c) Copyright 1992-2010, Micrium, Inc., Weston, FL
*                                        All Rights Reserved
* 
* File        : bsp.h
* Programmer  : AHFAI
*               NB
*********************************************************************************************************
*/

#ifndef __BSP_H__
#define __BSP_H__

#include   "includes.h"

/*
*********************************************************************************************************
*                                             CONSTANTS
*********************************************************************************************************
*/

#define  BSP_INTC_DEVICE_ID     XPAR_INTC_0_DEVICE_ID
#define  BSP_INTC_TIMER1_ID     XPAR_INTC_0_TMRCTR_0_VEC_ID
#define  BSP_INTC_ADDR          XPAR_INTC_0_BASEADDR
#define  BSP_TIMER0_ADDR        XPAR_XPS_TIMER_1_BASEADDR

#define  BSP_TMR_VAL            (XPAR_CPU_DPLB_FREQ_HZ / OS_TICKS_PER_SEC)

/*
*********************************************************************************************************
*                                             PROTOTYPES
*********************************************************************************************************
*/

void  BSP_TmrInit            (void);
void  BSP_Init               (void);
void  BSP_IntDisAll          (void);
void  BSP_InitIntCtrl        (void);
void  BSP_InitIO             (void);

#endif
