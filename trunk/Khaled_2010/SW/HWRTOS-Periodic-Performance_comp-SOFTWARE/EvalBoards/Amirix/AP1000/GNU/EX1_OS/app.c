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

INT8U   RandomSem;
INT8U   AckMbox;
//INT8U   TxMbox;

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
    INT32U	test;    	    
	 	 
	//XCACHE_DISABLE_DCACHE(); 	 
	//XCACHE_DISABLE_ICACHE();
		 	 
#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr;
#endif	 	     
	 	 	 
     BSP_IntDisAll();                                 /* Make sure interrupts are disabled on interrupt controller */
          
	 BSP_SwTmrStart();
     overhead = BSP_SwTmrStop();         
     xil_printf("\r\n HW timer overhead = %ld \r\n", overhead);                  
     test = getnum();                              	 
	 
	 BSP_SwTmrStart();
	 OSInit();                                        /* Initialize uC/OS-II                                         */	 	 	 
	 sw_tmr_value[0] = BSP_SwTmrStop() - overhead;
	 
	BSP_SwTmrStart();
    RandomSem   = OSSemCreate(1); 	
	sw_tmr_value[1] = BSP_SwTmrStop() - overhead;
	
    BSP_SwTmrStart();
	AckMbox = OSMboxCreate((void *)0);                /* Create 2 message mailboxes               */
	sw_tmr_value[2] = BSP_SwTmrStop() - overhead;
	
    //TxMbox  = OSMboxCreate((void *)0);
    
    BSP_SwTmrStart();    	 
    OSTaskCreatePeriodic(AppTaskFirst,
                   (void *)0,
                   &AppTaskFirstStk[APP_TASK_FIRST_STK_SIZE - 1],
                   APP_TASK_FIRST_PRIO,
                   APP_TASK_FIRST_ID,
                   &AppTaskFirstStk[0],
                   APP_TASK_FIRST_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x31,                                              
                   750);                               //Character '1' as application First task name                                                         
    sw_tmr_value[3] = BSP_SwTmrStop() - overhead;                   
                          
    OSTaskCreatePeriodic(AppTaskSecond,
                   (void *)0,
                   &AppTaskSecondStk[APP_TASK_SECOND_STK_SIZE - 1],
                   APP_TASK_SECOND_PRIO,
                   APP_TASK_SECOND_ID,
                   &AppTaskSecondStk[0],
                   APP_TASK_SECOND_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x32,
                   1500);                              //Character '2' as application Second task name       
               
    OSTaskCreatePeriodic(AppTaskThird,
                   (void *)0,
                   &AppTaskThirdStk[APP_TASK_THIRD_STK_SIZE - 1],
                   APP_TASK_THIRD_PRIO,
                   APP_TASK_THIRD_ID,
                   &AppTaskThirdStk[0],
                   APP_TASK_THIRD_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x33,
                   3000);                              //Character '3' as application Third task name                                   

    xil_printf("\r\n Init time = %ld \r\n", sw_tmr_value[0]);                  
    xil_printf("\r\n Semaphore create time = %ld \r\n", sw_tmr_value[1]);
    xil_printf("\r\n Mbox create time = %ld \r\n", sw_tmr_value[2]);
    xil_printf("\r\n Task create time = %ld \r\n", sw_tmr_value[3]);
    test = getnum();                
            
    BSP_SwTmrStart();        
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
    sw_tmr_value[4] = BSP_SwTmrStop() - overhead; 
    xil_printf("\r\n OSStart time = %ld \r\n", sw_tmr_value[4]);         
    //char    txmsg;
    INT32U  i, test;
    
    p_arg = p_arg;
    //txmsg = 'A';
    
    BSP_InitIO();   	     	
       
    while (1) {	   
           BSP_SwTmrStart(); 
           OSSemPend(RandomSem, 0, &err);  
           sw_tmr_value[6] = BSP_SwTmrStop() - overhead;
           xil_printf("\r\n Semaphore pend (ok) time = %ld \r\n", sw_tmr_value[6]); 	                               
           //BSP_SwTmrStart(); 
           //OSMboxPend(AckMbox, 0, &err);
           //OSMboxPost(TxMbox, (void *)&txmsg);  
           for (i=0; i<2409637; i++){
            test = i + overhead;                    
           }         
           BSP_SwTmrStart();                                  				  
           OSTaskDone();			                 
    }
}


static  void  AppTaskSecond (void *p_arg)
{	          
    sw_tmr_value[5] = BSP_SwTmrStop() - overhead;
    xil_printf("\r\n Task done time = %ld \r\n", sw_tmr_value[5]); 
    //sw_tmr_value[8] = BSP_SwTmrStop() - overhead;
    //xil_printf("\r\n Mbox pend (not ok) time = %ld \r\n", sw_tmr_value[8]); 
    INT32U  i, test;
            
    p_arg = p_arg;     	     
	 	     
    while (1) {
           BSP_SwTmrStop();	   
           BSP_SwTmrStart(); 
           OSSemPend(RandomSem, 0, &err);  
           //BSP_SwTmrStart(); 
           //OSMboxPend(AckMbox, 0, &err);  
           //sw_tmr_value[9] = BSP_SwTmrStop() - overhead;
           //xil_printf("\r\n Mbox pend (ok) time = %ld \r\n", sw_tmr_value[9]);                                                          
           for (i=0; i<1204819; i++){
            test = i + overhead;                    
           }                                          				  
           OSTaskDone();			                 
    }
}


static  void  AppTaskThird (void *p_arg)
{	    
    sw_tmr_value[7] = BSP_SwTmrStop() - overhead;
    xil_printf("\r\n Semaphore pend (not ok) time = %ld \r\n", sw_tmr_value[7]);  
    INT32U  i, test;
            
    p_arg = p_arg;    	     
	 	     
    while (1) {	 
           BSP_SwTmrStop();	                                 
           for (i=0; i<1204819; i++){
            test = i + overhead;                    
           }                                            				  		   
           OSTaskDone();			                 
    }
}

