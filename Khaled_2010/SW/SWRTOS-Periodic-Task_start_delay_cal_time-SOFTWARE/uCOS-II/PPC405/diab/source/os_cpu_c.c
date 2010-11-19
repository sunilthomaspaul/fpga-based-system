/*
*********************************************************************************************************
*                                               uC/OS-II
*                                         The Real-Time Kernel
*
*                        (c) Copyright 1992-1998, Jean J. Labrosse, Plantation, FL
*                                          All Rights Reserved
*
*
*                                       PowerPC Specific code
*
* File : os_cpu_c.c
*********************************************************************************************************
*/

#define  OS_CPU_GLOBALS
#include "includes.h"

#define INITIAL_MSR	0x00008000          /* Enable Intr, Timers */

/*
*********************************************************************************************************
*                                        INITIALIZE A TASK'S STACK
*
* Description: This function is called by either OSTaskCreate() or OSTaskCreateExt() to initialize the
*              stack frame of the task being created.  This function is highly processor specific.
*
* Arguments  : task          is a pointer to the task code
*
*              pdata         is a pointer to a user supplied data area that will be passed to the task
*                            when the task first executes.
*
*              ptos          is a pointer to the top of stack.  It is assumed that 'ptos' points to
*                            a 'free' entry on the task stack.  If OS_STK_GROWTH is set to 1 then 
*                            'ptos' will contain the HIGHEST valid address of the stack.  Similarly, if
*                            OS_STK_GROWTH is set to 0, the 'ptos' will contains the LOWEST valid address
*                            of the stack.
*
*              opt           specifies options that can be used to alter the behavior of OSTaskStkInit().
*                            (see uCOS_II.H for OS_TASK_OPT_???).
*
* Returns    : Always returns the location of the new top-of-stack' once the processor registers have
*              been placed on the stack in the proper order.
*
* Note(s)    : Interrupts are enabled when your task starts executing. You can change this by setting the
*              PSW to 0x0002 instead.  In this case, interrupts would be disabled upon task startup.  The
*              application code would be responsible for enabling interrupts at the beginning of the task
*              code.  You will need to modify OSTaskIdle() and OSTaskStat() so that they enable 
*              interrupts.  Failure to do this will make your system crash!
*********************************************************************************************************
*/

void *OSTaskStkInit (void (*task)(void *pd), void *data, void *pstk, INT16U opt)
{
    long *stk;

/* get tasks stack pointer (LONG WORD ALIGNED) */
    stk              = (long *)((long) pstk &
                        (long) 0xfffffffcL);

    opt    = opt;                           /* 'opt' is not used, prevent warning                      */
/* save the status register */
    *--stk = INITIAL_MSR;   /* MSR */
    *--stk = 0L;            /* r31 */
    *--stk = 0L;            /* r30 */
    *--stk = 0L;            /* r29 */
    *--stk = 0L;            /* r28 */
    *--stk = 0L;            /* r27 */
    *--stk = 0L;            /* r26 */
    *--stk = 0L;            /* r25 */
    *--stk = 0L;            /* r24 */
    *--stk = 0L;            /* r23 */
    *--stk = 0L;            /* r22 */
    *--stk = 0L;            /* r21 */
    *--stk = 0L;            /* r20 */
    *--stk = 0L;            /* r19 */
    *--stk = 0L;            /* r18 */
    *--stk = 0L;            /* r17 */
    *--stk = 0L;            /* r16 */
    *--stk = 0L;            /* r15 */
    *--stk = 0L;            /* r14 */
    --stk;                  /* r13  Processor Initialized */
    *--stk = 0L;            /* r12 */
    *--stk = 0L;            /* r11 */
    *--stk = 0L;            /* r10 */
    *--stk = 0L;            /* r09 */
    *--stk = 0L;            /* r08 */
    *--stk = 0L;            /* r07 */
    *--stk = 0L;            /* r06 */
    *--stk = 0L;            /* r05 */
    *--stk = 0L;            /* r04 */
    *--stk = (long)data;    /* r03 */
    --stk;                  /* r02  Processor Initialized */
    --stk;                  /* BLANK */
    *--stk = (long)task;    /* LR */
    --stk;                  /* CR */
    --stk;                  /* XCR */
    --stk;                  /* CTR */
    *--stk = INITIAL_MSR;   /* SRR1 */
    *--stk = (long)task;    /* SRR0 */
    --stk;                  /* R0 */
    --stk;                  /* BLANK */
    *--stk = (long)pstk;    /* Stack Ptr */


    return ((void *)stk);
}

/*$PAGE*/
#if OS_CPU_HOOKS_EN
/*
*********************************************************************************************************
*                                          TASK CREATION HOOK
*
* Description: This function is called when a task is created.
*
* Arguments  : ptcb   is a pointer to the task control block of the task being created.
*
* Note(s)    : 1) Interrupts are disabled during this call.
*********************************************************************************************************
*/
void OSTaskCreateHook (OS_TCB *ptcb)
{
    ptcb = ptcb;                       /* Prevent compiler warning                                     */
}


/*
*********************************************************************************************************
*                                           TASK DELETION HOOK
*
* Description: This function is called when a task is deleted.
*
* Arguments  : ptcb   is a pointer to the task control block of the task being deleted.
*
* Note(s)    : 1) Interrupts are disabled during this call.
*********************************************************************************************************
*/
void OSTaskDelHook (OS_TCB *ptcb)
{
    ptcb = ptcb;                       /* Prevent compiler warning                                     */
}

/*
*********************************************************************************************************
*                                           TASK SWITCH HOOK
*
* Description: This function is called when a task switch is performed.  This allows you to perform other
*              operations during a context switch.
*
* Arguments  : none
*
* Note(s)    : 1) Interrupts are disabled during this call.
*              2) It is assumed that the global pointer 'OSTCBHighRdy' points to the TCB of the task that
*                 will be 'switched in' (i.e. the highest priority task) and, 'OSTCBCur' points to the 
*                 task being switched out (i.e. the preempted task).
*********************************************************************************************************
*/
void OSTaskSwHook (void)
{
}

/*
*********************************************************************************************************
*                                           STATISTIC TASK HOOK
*
* Description: This function is called every second by uC/OS-II's statistics task.  This allows your 
*              application to add functionality to the statistics task.
*
* Arguments  : none
*********************************************************************************************************
*/
void OSTaskStatHook (void)
{
}

/*
*********************************************************************************************************
*                                               TICK HOOK
*
* Description: This function is called every tick.
*
* Arguments  : none
*
* Note(s)    : 1) Interrupts may or may not be ENABLED during this call.
*********************************************************************************************************
*/
void OSTimeTickHook (void)
{
}
#endif
