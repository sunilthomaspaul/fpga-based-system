/*
*********************************************************************************************************
*                                                uC/OS-II
*                                          The Real-Time Kernel
*
*                            (c) Copyright 1992-2010, Micrium, Inc., Weston, FL
*                                           All Rights Reserved
*
*
* File        : bsp.c
* Programmer  : AHFAI
*               NB
*********************************************************************************************************
*/

#include "includes.h"

/*
*********************************************************************************************************
*                                         LOCAL GLOBAL VARIABLES
*********************************************************************************************************
*/

XIntc    int_ctl;

/*
*********************************************************************************************************
*                                          BSP_Timer1Handler()
* 
* Description: This function services interrupts produced by the timer counter.  These interrupts serve
*              as uC/OS-II's tick source.

* Arguments  : baseaddr_p     is a pointer to the XTmrCtr driver structure
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_Timer1Handler (void *baseaddr_p)
{
    INT32S  baseaddr;
    INT32U  csr;


    baseaddr = *(INT32S *)baseaddr_p;
    csr      = XTmrCtr_GetControlStatusReg(BSP_TIMER0_ADDR, 0);
    if (csr & XTC_CSR_INT_OCCURED_MASK) {              
        XTmrCtr_SetControlStatusReg(BSP_TIMER0_ADDR, 0, csr);
                                                   /* Notify uC/OS-II that a tick interrupt occurred   */
        OSTimeTick();                                                
    }
}

/*
*********************************************************************************************************
*                                               Tmr_Init()
*
* Description: This function should intialize the timers used by your application
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_TmrInit (void)
{
                                                   /* Set the timer's period                           */
    XTmrCtr_SetLoadReg(BSP_TIMER0_ADDR, 0, BSP_TMR_VAL);
                                                   /* Reset the timer                                  */
    XTmrCtr_SetControlStatusReg(BSP_TIMER0_ADDR, 0, XTC_CSR_INT_OCCURED_MASK | XTC_CSR_LOAD_MASK);
                                                   /* Start the timer                                  */
    XTmrCtr_SetControlStatusReg(BSP_TIMER0_ADDR, 0, XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_ENABLE_INT_MASK | XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_DOWN_COUNT_MASK);
}

/*
*********************************************************************************************************
*                                            BSP_IntHandler()
*
* Description: This function is called by OS_CPU_ISR() in os_cpu_a.s to service all active interrupts 
*              from the interrupt controller.  Two versions of this function are provided.  One of these 
*              versions uses the interrupt controller's IVR to determine the highest priority pending 
*              interrupt, while the other version consults the relevant status register.  The code that 
*              uses the IVR is capable of processing interrupts quickly, so the relatively slow code that 
*              uses a status register is excluded with a #if 0 directive.  If, however, your interrupt 
*              controller has been modified from the default configuration and it doesn't offer the IVR, 
*              you will need to place a #if 0 around the faster code, and include the code that is 
*              currently ignored in your project.
*
*              Handlers for devices connected to the interrupt controller can be registered in one of 
*              two ways: via the "Interrupt Handlers" section of your project's "Software Platform
*              Settings", or by calling XIntc_Connect(), which is used to register a handler for the 
*              operating system's tick interrupt in this file's BSP_InitIntCtrl().  Both of these methods 
*              achieve similar results, placing a pointer to your handler in the table accessed by 
*              BSP_IntHandler().  Regardless of which method is used, then, the interrupt corresponding 
*              to your device should be enabled by calling XIntc_Enable() or a similar function.
* 
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/
#if 1
void  BSP_IntHandler (void) 
{	 
                                                   /* This handler uses the interrupt controller's IVR */
    INT32U                  int_status;   
    INT32U                  int_mask;
    INT32U                  int_vector;
    XIntc_Config           *CfgPtr;
    XIntc_VectorTableEntry *tbl_ptr;


    CfgPtr = &XIntc_ConfigTable[0];
    int_status = XIntc_GetIntrStatus(BSP_INTC_ADDR);

    while (int_status != 0) {
                                                   /* Get the interrupts waiting to be serviced        */
        int_vector = *(INT32U *)(BSP_INTC_ADDR + 0x00000018);
        int_mask   = 1 << int_vector;
       
        if (((CfgPtr->AckBeforeService) & int_mask) != 0) {
            XIntc_AckIntr(BSP_INTC_ADDR, int_mask);
        }
        tbl_ptr = &(CfgPtr->HandlerTable[int_vector]);
        tbl_ptr->Handler(tbl_ptr->CallBackRef);    /* Call the handler assigned to the interrupt       */
        if (((CfgPtr->AckBeforeService) & int_mask) == 0) {
            XIntc_AckIntr(BSP_INTC_ADDR, int_mask);
        }
        int_status = XIntc_GetIntrStatus(BSP_INTC_ADDR);
    }
}
#endif

#if 0
void  BSP_IntHandler (void) 
{	 	 
	                                                    /* This handler doesn't use the IVR                 */                   
    INT32U    IntrStatus;                                         
    INT32U    IntrMask = 1;                                           
    INT32U    IntrNumber;                                                 
    XIntc_Config *CfgPtr;
  

    CfgPtr = &XIntc_ConfigTable[(Xuint32)BSP_INTC_DEVICE_ID];

    IntrStatus = XIntc_mGetIntrStatus(CfgPtr->BaseAddress);
  
    for (IntrNumber = 0; IntrNumber < XPAR_INTC_MAX_NUM_INTR_INPUTS;
         IntrNumber++)
    {
        if (IntrStatus & 1)
        {
            XIntc_VectorTableEntry *TablePtr;

            if (CfgPtr->AckBeforeService & IntrMask)
            {
                XIntc_mAckIntr(CfgPtr->BaseAddress, IntrMask);
            }

            TablePtr = &(CfgPtr->HandlerTable[IntrNumber]);
            TablePtr->Handler(TablePtr->CallBackRef);

            if ((CfgPtr->AckBeforeService & IntrMask) == 0)
            {
                XIntc_mAckIntr(CfgPtr->BaseAddress, IntrMask);
            }

            if (CfgPtr->Options == XIN_SVC_SGL_ISR_OPTION)
            {
                return;
            }
        }

        IntrMask <<= 1;
        IntrStatus >>= 1;
  
        if (IntrStatus == 0)
        {
            break;
        }
    } 
}
#endif

/*
*********************************************************************************************************
*                                            BSP_IntDisAll()
* 
* Description: Disable all interrupts at the interrupt controller.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_IntDisAll (void)
{
    XIntc_MasterDisable(BSP_INTC_ADDR);
}

/*
*********************************************************************************************************
*                                           BSP_InitIntCtrl()
*
* Description: This function initializes the interrupt controller by registering the appropriate handler
*              functions and enabling interrupts.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_InitIntCtrl (void)
{
    XStatus  init_status;

                                                   /* Initialize a handle for the interrupt controller */
    init_status = XIntc_Initialize(&int_ctl, BSP_INTC_DEVICE_ID);
                                                   /* Connect the first timer with its handler         */
    init_status = XIntc_Connect(&int_ctl, BSP_INTC_TIMER1_ID,BSP_Timer1Handler,(void *)0);
                                                   /* Enable interrupts from the first timer           */
    XIntc_Enable(&int_ctl, BSP_INTC_TIMER1_ID);  
                                                   /* Start the interrupt controller                   */
    init_status = XIntc_Start(&int_ctl, XIN_REAL_MODE);
}

/*
*********************************************************************************************************
*                                              BSP_InitIO()
* 
* Description: Initialize all the I/O devices.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_InitIO (void)    
{
    BSP_InitIntCtrl();                             /* Initialize the interrupt controller              */
    BSP_TmrInit();                                 /* Initialize the timers                            */
}


