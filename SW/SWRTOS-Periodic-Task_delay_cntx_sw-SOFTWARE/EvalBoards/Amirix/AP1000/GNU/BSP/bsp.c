/*
*********************************************************************************************************
*                                                uC/OS-II
*                                          The Real-Time Kernel
*
*                            (c) Copyright 1992-2007, Micrium, Inc., Weston, FL
*                                           All Rights Reserved
*
*                                          Board Support Package
*                                              Amirix AP1000
*********************************************************************************************************
*/

#include "bsp.h"

/*
*********************************************************************************************************
*                                                 LED ON
*
* Description : This function is used to control any or all the LEDs on the board.
*
* Arguments   : led    is the number of the LED to control
*                      0    indicates that you want ALL the LEDs to be ON
*                      1    turns ON LED 0 on the board
*                      .
*                      .
*                      4    turns ON LED 4 on the board
*********************************************************************************************************
*/

void  LED_On (INT8U led)
{
    INT32U  led_status;

#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr;
#endif    

    led_status = XGpio_mGetDataReg(BSP_GPIO_ADDR,1);

    OS_ENTER_CRITICAL();
    switch (led) {
        case 0:
            //led_status |= 0x000001FF;
			led_status |= 0xFFFFFFFF;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 1:
            led_status |= 0x00000001;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 2:
            led_status |= 0x00000002;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 3:
            led_status |= 0x00000004;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 4:
            led_status |= 0x00000008;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        default:
		      break;
    }
    OS_EXIT_CRITICAL();
}

/*
*********************************************************************************************************
*                                                LED OFF
*
* Description : This function is used to control any or all the LEDs on the board.
*
* Arguments   : led    is the number of the LED to turn OFF
*                      0    indicates that you want ALL the LEDs to be OFF
*                      1    turns OFF LED 0 on the board
*                      .
*                      .
*                      4    turns OFF LED 4 on the board
*********************************************************************************************************
*/

void  LED_Off (INT8U led)
{
    INT32U  led_status;

#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr;
#endif    

    led_status = XGpio_mGetDataReg(BSP_GPIO_ADDR,1);

    OS_ENTER_CRITICAL();
    switch (led) {
        case 0:
            //led_status &= 0xFFFFFE00;
			led_status &= 0x00000000;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 1:
            led_status &= 0xFFFFFFFE;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 2:
            led_status &= 0xFFFFFFFD;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 3:
            led_status &= 0xFFFFFFFB;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 4:
            led_status &= 0xFFFFFFF7;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        default:
            break;
    }
    OS_EXIT_CRITICAL();
}

/*
*********************************************************************************************************
*                                              LED TOGGLE
*
* Description : This function is used to alternate the state of an LED
*
* Arguments   : led    is the number of the LED to control
*                      0    indicates that you want ALL the LEDs to toggle
*                      1    toggle LED 0 on the board
*                      .
*                      .
*                      4    toggle LED 0 on the board
*********************************************************************************************************
*/

void  LED_Toggle (INT8U led)
{
    INT32U  led_status;

#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr;
#endif    

    led_status = XGpio_mGetDataReg(BSP_GPIO_ADDR,1);

    OS_ENTER_CRITICAL();
    switch (led) {
        case 0:
            //led_status ^= 0xFFFFFFFF;
			led_status ^= 0x000001FF;;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 1:
            led_status ^= 0x00000001;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 2:
            led_status ^= 0x00000002;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 3:
            led_status ^= 0x00000004;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        case 4:
            led_status ^= 0x00000008;
            XGpio_mSetDataReg(BSP_GPIO_ADDR,1,led_status);
            break;
        default:
		      break;
    }
    OS_EXIT_CRITICAL();        
}

/*
*********************************************************************************************************
*                                       LED_Init()
*
* Description: This function initializes all of the board's leds
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  LED_Init (void) 
{
    XGpio_mWriteReg(BSP_GPIO_ADDR, XGPIO_TRI_OFFSET, 0x00000000); 
    LED_Off(0);                          /* Turn off all of the LEDs                                                  */
}


/*
*********************************************************************************************************
*                                       Tmr_Init()
*
* Description: This function should intialize the timers used by your application
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  Tmr_Init (void)
{
    __asm__ __volatile__("mtspr " "987" ",%0\n" : : "r" (0x00000000));    /* Clear the PIT                */
    __asm__ __volatile__("mtspr " "984" ",%0\n" : : "r" (0x08000000));    /* Clear pending PIT interrputs */
    __asm__ __volatile__("mtspr " "986" ",%0\n" : : "r" (0x04400000));    /* Enable PIT interrupts        */
    __asm__ __volatile__("mtspr " "987" ",%0\n" : : "r" (BSP_TMR_VAL));   /* Load the PIT                 */

}

/*
*********************************************************************************************************
*                                BSP_CriticalIntHandler()
*
* Description: This function should be used to service critical interrupts.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_CriticalIntHandler (void)
{
}

/*
*********************************************************************************************************
*                               BSP_NonCriticalIntHandler()
*
* Description: This function is called by OS_CPU_ISR_NON_CRITICAL() in os_cpu_a.S to service all active 
*              interrupts on the interrupt controller.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_NonCriticalIntHandler (void) 
{
                                                                    /* This handler uses the interrupt controller's IVR, so you need to     */
    INT32U                  int_status;                             /* check that this register exists.  If possible, this handler should   */
    INT32U                  int_mask;                               /* always be used, because of its speed.                                */
    INT32U                  int_vector;
    XIntc_Config           *CfgPtr;
    XIntc_VectorTableEntry *tbl_ptr;


    CfgPtr = &XIntc_ConfigTable[0];
    int_status = XIntc_mGetIntrStatus(BSP_INTC_ADDR);

    while (int_status != 0) {
                                                                     /* Get the interrupts that are waiting to be serviced                  */
                                                                     /* Service each interrupt that is active and enabled by checking ...   */
                                                                     /* ... each bit in the register from LSB to MSB which corresponds ...  */
                                                                     /* ... to an interrupt intput signal                                   */
        int_vector = *(INT32U *)(BSP_INTC_ADDR + 0x00000018);
        int_mask   = 1 << int_vector;
        if (((CfgPtr->AckBeforeService) & int_mask) != 0) {
            XIntc_mAckIntr(BSP_INTC_ADDR, int_mask);
        }
        tbl_ptr = &(CfgPtr->HandlerTable[int_vector]);
        tbl_ptr->Handler(tbl_ptr->CallBackRef);
        if (((CfgPtr->AckBeforeService) & int_mask) == 0) {
            XIntc_mAckIntr(BSP_INTC_ADDR, int_mask);
        }
        int_status = XIntc_mGetIntrStatus(BSP_INTC_ADDR);
    }
#if 0
                                                                    /* This handler is exactly the same as that in intc_l.c.  Since the     */
    Xuint32 IntrStatus;                                             /* registers should have already been saved by OS_CPU_ISR, this handler */
    Xuint32 IntrMask = 1;                                           /* is really all that is needed if speed is not an issue (or if IVR is  */
    int IntrNumber;                                                 /* not present in hardware                                              */
    XIntc_Config *CfgPtr;
  

    /* Get the configuration data using the device ID */
    CfgPtr = &XIntc_ConfigTable[(Xuint32)BSP_INTC_DEVICE_ID];
  
    /* Get the interrupts that are waiting to be serviced */
    IntrStatus = XIntc_mGetIntrStatus(CfgPtr->BaseAddress);
  
    /* Service each interrupt that is active and enabled by checking each
     * bit in the register from LSB to MSB which corresponds to an interrupt
     * intput signal
     */
    for (IntrNumber = 0; IntrNumber < XPAR_INTC_MAX_NUM_INTR_INPUTS;
         IntrNumber++)
    {
        if (IntrStatus & 1)
        {
            XIntc_VectorTableEntry *TablePtr;
      
            /* If the interrupt has been setup to acknowledge it before
             * servicing the interrupt, then ack it
             */
            if (CfgPtr->AckBeforeService & IntrMask)
            {
                XIntc_mAckIntr(CfgPtr->BaseAddress, IntrMask);
            }
      
            /* The interrupt is active and enabled, call the interrupt
             * handler that was setup with the specified parameter
             */
            TablePtr = &(CfgPtr->HandlerTable[IntrNumber]);
            TablePtr->Handler(TablePtr->CallBackRef);
      
            /* If the interrupt has been setup to acknowledge it after it
             * has been serviced then ack it
             */
            if ((CfgPtr->AckBeforeService & IntrMask) == 0)
            {
                XIntc_mAckIntr(CfgPtr->BaseAddress, IntrMask);
            }

            /*
             * If only the highest priority interrupt is to be serviced,
             * exit loop and return after servicing interrupt
             */
            if (CfgPtr->Options == XIN_SVC_SGL_ISR_OPTION)
            {
                return;
            }
        }
        
        /* Move to the next interrupt to check */
        IntrMask <<= 1;
        IntrStatus >>= 1;
      
        /* If there are no other bits set indicating that all interrupts
         * have been serviced, then exit the loop
         */
        if (IntrStatus == 0)
        {
            break;
        }
    }
#endif
}

/*
*********************************************************************************************************
*                                             BSP_IntDisAll()
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
    XIntc_mMasterDisable(BSP_INTC_ADDR);                       
}

/*
*********************************************************************************************************
*                                      BSP_InitIntCtrl()
*
* Description: This function intializes the interrupt controller by registering the appropriate handler
*              functions and enabling interrupts.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

static  void  BSP_InitIntCtrl (void) 
{          
    XStatus  init_status;
    XIntc    int_ctl;        

#if OS_CRITICAL_METHOD == 3               /* Allocate storage for CPU status register                                  */
    OS_CPU_SR  cpu_sr;
#endif        
    
                                          /* Initialize a handle for the interrupt controller                          */
    init_status = XIntc_Initialize(&int_ctl, BSP_INTC_DEVICE_ID);
                                          /* Start the interrupt controller                                            */
    init_status = XIntc_Start(&int_ctl, XIN_REAL_MODE);               	 
}

/*
*********************************************************************************************************
*                                             BSP_InitIO()
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
    BSP_InitIntCtrl();                   /* Initialize the interrupt controller                                       */
    Tmr_Init();                          /* Initialize the timers                                                     */
    LED_Init();                          /* Initialize LEDs                                                           */

}

/*
*********************************************************************************************************
*                                             BSP_ExtTmrInit()
* 
* Description: Initialize the external timer/counter device.
*
* Arguments  : None
*
* Returns    : overhead consumed by start/stop the timer/counter device
*********************************************************************************************************
*/

INT32U  BSP_ExtTmrInit (void)    
{
	INT32U	ret_overhead;
	
	XTmrCtr_mSetLoadReg(BSP_EXT_TMR_ADDR, TIMER_COUNTER_0, 0x00000000);								// Set the load register with the initial value
	XTmrCtr_mLoadTimerCounterReg(BSP_EXT_TMR_ADDR, TIMER_COUNTER_0);								// Load the timer/counter register with the value saved in load register

	XTmrCtr_mSetControlStatusReg(BSP_EXT_TMR_ADDR, TIMER_COUNTER_0, XTC_CSR_ENABLE_TMR_MASK);	    // Start the specified timer/counter using control/status register
	XTmrCtr_mSetControlStatusReg(BSP_EXT_TMR_ADDR, TIMER_COUNTER_0, 0x00000000);					// Stop the specified timer/counter using control/status register
	ret_overhead = XTmrCtr_mGetTimerCounterReg(BSP_EXT_TMR_ADDR, TIMER_COUNTER_0);						// Get the value in the timer/counter register

   return(ret_overhead);                                                                                
}

/*
*********************************************************************************************************
*                                             BSP_SwTmrStart()
* 
* Description: Start the stop-watch timer.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_SwTmrStart (void)    
{
    Xuint64 Reg64Value_o;    
      
    Reg64Value_o.Lower = 0;  
    Reg64Value_o.Upper = 0;
      
#if OS_CRITICAL_METHOD == 3               /* Allocate storage for CPU status register                                  */
    OS_CPU_SR  cpu_sr;
#endif      
      	   
    Reg64Value_o.Lower |= HWRTOS_SW_TIMER_START;                             
    OS_ENTER_CRITICAL(); 
    HWRTOS_WriteSlaveReg0(hwrtos_addrp, &Reg64Value_o);         
    OS_EXIT_CRITICAL();						                                                                                  
}

/*
*********************************************************************************************************
*                                             BSP_SwTmrStop()
* 
* Description: Stop the stop-watch timer.
*
* Arguments  : None
*
* Returns    : Timer count
*********************************************************************************************************
*/

INT32U  BSP_SwTmrStop (void)    
{
	INT32U	ret_time;
	Xuint64 Reg64Value_o;
    Xuint64 Reg64Value_i;
      
#if OS_CRITICAL_METHOD == 3               /* Allocate storage for CPU status register                                  */
    OS_CPU_SR  cpu_sr;
#endif      
      
    Reg64Value_o.Lower = 0;  
    Reg64Value_o.Upper = 0;
    Reg64Value_i.Lower = 0;  
    Reg64Value_i.Upper = 0;
		    
    Reg64Value_o.Lower |= HWRTOS_SW_TIMER_STOP;     
    OS_ENTER_CRITICAL();                        
    HWRTOS_WriteSlaveReg0(hwrtos_addrp, &Reg64Value_o);       
    HWRTOS_ReadSlaveReg4(hwrtos_addrp, &Reg64Value_i);              	
    OS_EXIT_CRITICAL();
	ret_time = Reg64Value_i.Lower;						    
    
   return(ret_time);                                                                                
}

/*
*********************************************************************************************************
*                                             BSP_CnotTmrStart()
* 
* Description: Start the continuous timer.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_CnotTmrStart (void)    
{
    Xuint64 Reg64Value_o;    
      
    Reg64Value_o.Lower = 0;  
    Reg64Value_o.Upper = 0;
      
#if OS_CRITICAL_METHOD == 3               /* Allocate storage for CPU status register                                  */
    OS_CPU_SR  cpu_sr;
#endif      
      	   
    Reg64Value_o.Lower |= HWRTOS_CONT_TIMER_START;     
     OS_ENTER_CRITICAL();                        
     HWRTOS_WriteSlaveReg0(hwrtos_addrp, &Reg64Value_o); 
     OS_EXIT_CRITICAL();						                                                                                  
}

/*
*********************************************************************************************************
*                                             BSP_CnotTmrRead()
* 
* Description: Read the continuous timer.
*
* Arguments  : None
*
* Returns    : Timer count
*********************************************************************************************************
*/

INT32U  BSP_CnotTmrRead (void)    
{
	INT32U	ret_time;
	Xuint64 Reg64Value_o;
    Xuint64 Reg64Value_i;
      
#if OS_CRITICAL_METHOD == 3               /* Allocate storage for CPU status register                                  */
    OS_CPU_SR  cpu_sr;
#endif      
      
    Reg64Value_o.Lower = 0;  
    Reg64Value_o.Upper = 0;
    Reg64Value_i.Lower = 0;  
    Reg64Value_i.Upper = 0;
		    
    Reg64Value_o.Lower |= HWRTOS_CONT_TIMER_RD;     
    OS_ENTER_CRITICAL();                        
    HWRTOS_WriteSlaveReg0(hwrtos_addrp, &Reg64Value_o);         
    HWRTOS_ReadSlaveReg4(hwrtos_addrp, &Reg64Value_i);             	
    OS_EXIT_CRITICAL();
	ret_time = Reg64Value_i.Lower;						    
    
   return(ret_time);    					                                                                                  
}

/*
*********************************************************************************************************
*                                             BSP_ContTmrStop()
* 
* Description: Stop the continuous timer.
*
* Arguments  : None
*
* Returns    : None
*********************************************************************************************************
*/

void  BSP_ContTmrStop (void)    
{	
	Xuint64 Reg64Value_o;  
      
#if OS_CRITICAL_METHOD == 3               /* Allocate storage for CPU status register                                  */
    OS_CPU_SR  cpu_sr;
#endif      
      
    Reg64Value_o.Lower = 0;  
    Reg64Value_o.Upper = 0;   
		    
    Reg64Value_o.Lower |= HWRTOS_CONT_TIMER_STOP;     
    OS_ENTER_CRITICAL();                        
    HWRTOS_WriteSlaveReg0(hwrtos_addrp, &Reg64Value_o);            	
    OS_EXIT_CRITICAL();					                                                                                      
}

/*
*********************************************************************************************************
*                                             getnum()
* 
* Description: Get a number from the input.
*
* Arguments  : None
*
* Returns    : Number entered
*********************************************************************************************************
*/

INT32U getnum(void) {
	char   srb=0;
	INT32U num=0;

	// skip non digits
	while(srb < '0' || srb > '9') srb=XUartLite_RecvByte(STDIN_BASEADDRESS);

	// read all digits
	while(srb >= '0' && srb <= '9') { 
		num=num*10+(srb-'0');
		srb=XUartLite_RecvByte(STDIN_BASEADDRESS);
	};
	return num;
}
