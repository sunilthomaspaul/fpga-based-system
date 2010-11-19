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

static  OS_STK   AppTaskFirstStk   [APP_TASK_FIRST_STK_SIZE];   /* Start task stack                        */
static  OS_STK   AppTaskSecondStk  [APP_TASK_SECOND_STK_SIZE];  /* Start task stack                        */
static  OS_STK   AppTaskThirdStk   [APP_TASK_THIRD_STK_SIZE];   /* Start task stack                        */
static  OS_STK   AppTaskFourthStk  [APP_TASK_FOURTH_STK_SIZE];  /* Start task stack                        */
static  OS_STK   AppTaskFifthStk   [APP_TASK_FIFTH_STK_SIZE];   /* Start task stack                        */
static  OS_STK   AppTaskSixthStk   [APP_TASK_SIXTH_STK_SIZE];   /* Start task stack                        */
static  OS_STK   AppTaskSeventhStk [APP_TASK_SEVENTH_STK_SIZE]; /* Start task stack                        */
static  OS_STK   AppTaskEighthStk  [APP_TASK_EIGHTH_STK_SIZE];  /* Start task stack                        */
static  OS_STK   AppTaskNinethStk  [APP_TASK_NINETH_STK_SIZE];  /* Start task stack                        */
static  OS_STK   AppTaskTenthStk   [APP_TASK_TENTH_STK_SIZE];   /* Start task stack                        */

//INT8U   RandomSem;
//INT8U   AckMbox;
//INT8U   TxMbox;

/*
*********************************************************************************************************
*                                             PROTOTYPES
*********************************************************************************************************
*/

static  void     AppTaskFirst  (void *p_arg);
static  void     AppTaskSecond (void *p_arg);
static  void     AppTaskThird  (void *p_arg);
static  void     AppTaskFourth (void *p_arg);
static  void     AppTaskFifth  (void *p_arg);
static  void     AppTaskSixth  (void *p_arg);
static  void     AppTaskSeventh(void *p_arg);
static  void     AppTaskEighth (void *p_arg);
static  void     AppTaskNineth (void *p_arg);
static  void     AppTaskTenth  (void *p_arg);

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
          
	 BSP_SwTmrStart();
     overhead = BSP_SwTmrStop();
     xil_printf("\r\n HW timer overhead = %ld \r\n", overhead);     
     test = getnum();               
	 
	 OSInit();                                        /* Initialize uC/OS-II                                         */	 	 
	 
	//RandomSem   = OSSemCreate(1); 	
	//AckMbox = OSMboxCreate((void *)0);               /* Create 2 message mailboxes               */
    //TxMbox  = OSMboxCreate((void *)0);
        	 
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
                   65535);                            //Character '1' as application First task name with max period                                                                         
                           
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
                   65535);                            //Character '2' as application Second task name with max period        
               
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
                   65535);                            //Character '3' as application Third task name with max period        
              
    OSTaskCreatePeriodic(AppTaskFourth,
                   (void *)0,
                   &AppTaskFourthStk[APP_TASK_FOURTH_STK_SIZE - 1],
                   APP_TASK_FOURTH_PRIO,
                   APP_TASK_FOURTH_ID,
                   &AppTaskFourthStk[0],
                   APP_TASK_FOURTH_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x34,
                   65535);                            //Character '4' as application Fourth task name with max period        
                          
    OSTaskCreatePeriodic(AppTaskFifth,
                   (void *)0,
                   &AppTaskFifthStk[APP_TASK_FIFTH_STK_SIZE - 1],
                   APP_TASK_FIFTH_PRIO,
                   APP_TASK_FIFTH_ID,
                   &AppTaskFifthStk[0],
                   APP_TASK_FIFTH_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x35,
                   65535);                            //Character '5' as application Fifth task name with max period        
                 
    OSTaskCreatePeriodic(AppTaskSixth,
                   (void *)0,
                   &AppTaskSixthStk[APP_TASK_SIXTH_STK_SIZE - 1],
                   APP_TASK_SIXTH_PRIO,
                   APP_TASK_SIXTH_ID,
                   &AppTaskSixthStk[0],
                   APP_TASK_SIXTH_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x36,
                   65535);                            //Character '6' as application Sixth task name with max period        
                  
    OSTaskCreatePeriodic(AppTaskSeventh,
                   (void *)0,
                   &AppTaskSeventhStk[APP_TASK_SEVENTH_STK_SIZE - 1],
                   APP_TASK_SEVENTH_PRIO,
                   APP_TASK_SEVENTH_ID,
                   &AppTaskSeventhStk[0],
                   APP_TASK_SEVENTH_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x37,
                   65535);                            //Character '7' as application Seventh task name with max period                                                     
    
    OSTaskCreatePeriodic(AppTaskEighth,
                   (void *)0,
                   &AppTaskEighthStk[APP_TASK_EIGHTH_STK_SIZE - 1],
                   APP_TASK_EIGHTH_PRIO,
                   APP_TASK_EIGHTH_ID,
                   &AppTaskEighthStk[0],
                   APP_TASK_EIGHTH_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x38,
                   65535);                            //Character '8' as application Eighth task name with max period        
                                           
    OSTaskCreatePeriodic(AppTaskNineth,
                   (void *)0,
                   &AppTaskNinethStk[APP_TASK_NINETH_STK_SIZE - 1],
                   APP_TASK_NINETH_PRIO,
                   APP_TASK_NINETH_ID,
                   &AppTaskNinethStk[0],
                   APP_TASK_NINETH_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x39,
                   65535);                            //Character '9' as application Nineth task name with max period        
                        
    OSTaskCreatePeriodic(AppTaskTenth,
                   (void *)0,
                   &AppTaskTenthStk[APP_TASK_TENTH_STK_SIZE - 1],
                   APP_TASK_TENTH_PRIO,
                   APP_TASK_TENTH_ID,
                   &AppTaskTenthStk[0],
                   APP_TASK_TENTH_STK_SIZE,
                   (void *)0,
                   OS_TASK_OPT_STK_CHK | OS_TASK_OPT_STK_CLR,
                   0x41,
                   65535);                            //Character 'A' as application Tenth task name with max period                                    

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
    ctx_sw_time = BSP_SwTmrStop() - overhead;				                            
	xil_printf("\r\n Critical instant ctx sw time = %ld \r\n", ctx_sw_time);
        
    p_arg = p_arg;
       
	BSP_InitIO();    
	 	     
    while (1) {	         
          xil_printf("\r\n Task 1 \r\n");                         				  
          OSTaskDone();		                 
    }
}


static  void  AppTaskSecond (void *p_arg)
{	     
    p_arg = p_arg;	 	     	
     	     
    while (1) {         
          xil_printf("\r\n Task 2 \r\n");                    				  
          OSTaskDone();		    		 
    }
}


static  void  AppTaskThird (void *p_arg)
{	     
    p_arg = p_arg;	 	     
	 	     
    while (1) {	           
          xil_printf("\r\n Task 3 \r\n");                    				  
          OSTaskDone();		    		 
    }
}


static  void  AppTaskFourth (void *p_arg)
{	     
    p_arg = p_arg;	 	     
	 	     
    while (1) {	             
          xil_printf("\r\n Task 4 \r\n");                  				  
          OSTaskDone();		    		 
    }
}


static  void  AppTaskFifth (void *p_arg)
{	     
    p_arg = p_arg;	 	     
	 	     
    while (1) {            
          xil_printf("\r\n Task 5 \r\n");                 				  
          OSTaskDone();		    		 
    }
}


static  void  AppTaskSixth (void *p_arg)
{	     
    p_arg = p_arg;	 	     
	 	     
    while (1) {	                 
          xil_printf("\r\n Task 6 \r\n");                 				  
          OSTaskDone();		    		 
    }
}


static  void  AppTaskSeventh (void *p_arg)
{	     
    p_arg = p_arg;	 	     
	 	     
    while (1) {	          
          xil_printf("\r\n Task 7 \r\n");                   				  
          OSTaskDone();		    		 
    }
}


static  void  AppTaskEighth (void *p_arg)
{	    
    p_arg = p_arg;	 	     
	 	     
    while (1) {	             
          xil_printf("\r\n Task 8 \r\n");                  				  
          OSTaskDone();		    		 
    }
}


static  void  AppTaskNineth (void *p_arg)
{	   
    p_arg = p_arg;    	 	     	
     	     
    while (1) {	            
          xil_printf("\r\n Task 9 \r\n");                      				  
          OSTaskDone();		    		 
    }
}



static  void  AppTaskTenth (void *p_arg)
{	      
     INT32U test, i;
          
     p_arg = p_arg;     
	 	 	  	 	                                                                  	 	  	 	 	 	  	 
     while (1) {	
        xil_printf("\r\n Task 10 \r\n");                                     	                                                              
        for (i=0; i<1000000; i++){
            test = i + overhead;                      
        }
        OSTaskDone();					
    } 
}




