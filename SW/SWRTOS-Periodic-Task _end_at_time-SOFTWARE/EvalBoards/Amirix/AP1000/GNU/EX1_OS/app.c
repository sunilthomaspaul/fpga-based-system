/*
*********************************************************************************************************
*                                                uC/OS-II
*                                          The Real-Time Kernel
*
*                                                  EX1_OS
*
*
* Description:  Shows an example of how to use uC/OS-II with the PowerPC405.  
*********************************************************************************************************
*/

#include "includes.h"

/*
*********************************************************************************************************
*                                              CONSTANTS
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                           GLOBAL VARIABLES
*********************************************************************************************************
*/

static  OS_STK   AppTaskFirstStk  [APP_TASK_FIRST_STK_SIZE];   /* Start task stack                        */
static  OS_STK   AppTaskSecondStk [APP_TASK_SECOND_STK_SIZE];  /* Start task stack                        */
static  OS_STK   AppTaskThirdStk  [APP_TASK_THIRD_STK_SIZE];   /* Start task stack                        */

//OS_EVENT     *RandomSem;
//OS_EVENT     *AckMbox;                                /* Message mailboxes for Tasks #4 and #5         */
//OS_EVENT     *TxMbox;


/*
*********************************************************************************************************
*                                             PROTOTYPES
*********************************************************************************************************
*/

static  void     AppTaskFirst (void *p_arg);
static  void     AppTaskSecond(void *p_arg);
static  void     AppTaskThird (void *p_arg);

/*
*********************************************************************************************************
*                                              main()
* 
* Description: This is the 'standard' C startup entry point.  main() does the following:
*              
*              1) Initialize uC/OS-II
*              2) Create a single task
*              3) Start uC/OS-II
*
* Arguments  : None
*
* Returns    : main() should NEVER return
*********************************************************************************************************
*/

int  main (void)
{       
    INT32U	 test;    
	 
	//XCACHE_DISABLE_DCACHE(); 	 
	//XCACHE_DISABLE_ICACHE();
	 
#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr;
#endif	 	 	 
	 
	 BSP_IntDisAll();                                 /* Make sure interrupts are disabled on interrupt controller */
          
     BSP_CnotTmrStart();
     overhead = BSP_CnotTmrRead();
     BSP_ContTmrStop();
     xil_printf("\r\n HW cont timer overhead2 = %ld \r\n", overhead);     
     test = getnum();          
	 
	 OSInit();                                        /* Initialize uC/OS-II                                        */	 	 
     	 	 
	//RandomSem   = OSSemCreate(1); 	
	//AckMbox = OSMboxCreate((void *)0);                     /* Create 2 message mailboxes               */
    //TxMbox  = OSMboxCreate((void *)0);
        	 
    OSTaskCreateExt(AppTaskFirst,
                   (void *)0,
                   &AppTaskFirstStk[APP_TASK_FIRST_STK_SIZE - 1],
                   APP_TASK_FIRST_PRIO,
                   APP_TASK_FIRST_ID,
                   &AppTaskFirstStk[0],
                   APP_TASK_FIRST_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR
                   );                                                                            
                         
    OSTaskCreateExt(AppTaskSecond,
                   (void *)0,
                   &AppTaskSecondStk[APP_TASK_SECOND_STK_SIZE - 1],
                   APP_TASK_SECOND_PRIO,
                   APP_TASK_SECOND_ID,
                   &AppTaskSecondStk[0],
                   APP_TASK_SECOND_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR
                   );    
                   
    OSTaskCreateExt(AppTaskThird,
                   (void *)0,
                   &AppTaskThirdStk[APP_TASK_THIRD_STK_SIZE - 1],
                   APP_TASK_THIRD_PRIO,
                   APP_TASK_THIRD_ID,
                   &AppTaskThirdStk[0],
                   APP_TASK_THIRD_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR
                   ); 
               
    BSP_CnotTmrStart();
    OSStart();                                        /* Start multitasking                                        */
}

/*$PAGE*/
/*
*********************************************************************************************************
*                                             AppTaskFirst()
* 
* Description: This is the first task executed by uC/OS-II following OSStart()
*              
* Arguments  : p_arg        Argument passed to this task when task is created.  The argument is not used.
*
* Returns    : None
*********************************************************************************************************
*/

static  void  AppTaskFirst (void *p_arg)
{	        
    INT32U  i, test, iteration;
    INT16U  rem_time;
    
    p_arg = p_arg;
    iteration = 1;
    BSP_InitIO();   	     
	
    while (1) {	                      
           for (i=0; i<4819277; i++){
            test = i + overhead;                    
           }           
		   rem_time = (75*iteration++) - ((BSP_CnotTmrRead() - overhead) / 800000);		   
           OSTimeDly(rem_time);			                 
    }
}


static  void  AppTaskSecond (void *p_arg)
{	     
    T1_cont_tmr_value = BSP_CnotTmrRead();          
    INT32U  i, test, iteration;
    INT16U  rem_time;
            
    p_arg = p_arg;     	     
	iteration = 1; 
     	     
    while (1) {	            
           for (i=0; i<2409638; i++){
            test = i + overhead;                    
           }           
		   rem_time = (150*iteration++) - ((BSP_CnotTmrRead() - overhead) / 800000);		  
           OSTimeDly(rem_time);			                 
    }
}


static  void  AppTaskThird (void *p_arg)
{	    
    T2_cont_tmr_value = BSP_CnotTmrRead(); 
    INT32U  i, test, iteration;
    INT16U  rem_time;
            
    p_arg = p_arg;
    iteration = 1;     	     
	 	     
    while (1) {	              
           for (i=0; i<2409638; i++){
            test = i + overhead;                    
           }          
           rem_time = (300*iteration++) - ((BSP_CnotTmrRead() - overhead) / 800000);           
           OSTimeDly(rem_time);			                 
    }
}
