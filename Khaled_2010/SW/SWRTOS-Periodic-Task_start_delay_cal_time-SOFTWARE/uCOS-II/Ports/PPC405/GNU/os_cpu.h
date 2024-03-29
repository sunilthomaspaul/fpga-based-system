/*
*********************************************************************************************************
*                                               uC/OS-II
*                                        The Real-Time Kernel
*
*                            (c) Copyright 2007, Micrium, Inc., Weston, FL
*                                          All Rights Reserved
*
*                                             PowerPC405
*
*                                          GNU  C/C++ Compiler
*
* File: os_cpu.h
*********************************************************************************************************
*/

#ifdef  OS_CPU_GLOBALS
#define OS_CPU_EXT
#else
#define OS_CPU_EXT  extern
#endif

/*$PAGE*/
/*
*********************************************************************************************************
*                                              DATA TYPES
*                                         (Compiler Specific)
*********************************************************************************************************
*/

typedef unsigned  char           BOOLEAN;
typedef unsigned  char           INT8U;        /* Unsigned  8 bit quantity                           */
typedef signed    char           INT8S;        /* Signed    8 bit quantity                           */
typedef unsigned  short          INT16U;       /* Unsigned 16 bit quantity                           */
typedef signed    short          INT16S;       /* Signed   16 bit quantity                           */
typedef unsigned  int            INT32U;       /* Unsigned 32 bit quantity                           */
typedef signed    int            INT32S;       /* Signed   32 bit quantity                           */
typedef float                    FP32;
typedef double                   FP64;

typedef unsigned  int            OS_STK;       /* Each stack entry is 32-bits wide                   */
typedef unsigned  int  volatile  OS_CPU_SR;    /* The CPU Status Word is 32-bits wide. This variable */
											   /* MUST be volatile for proper operation. Refer to    */
											   /* os_cpu_a.s for more details                        */

/*
*********************************************************************************************************
*                                    CRITICAL SECTIONS MANAGEMENT
*
* Method #1:  Disable/Enable interrupts using simple instructions.  After critical section, interrupts
*             will be enabled even if they were disabled before entering the critical section.
*
* Method #2:  Disable/Enable interrupts by preserving the state of interrupts.  In other words, if
*             interrupts were disabled before entering the critical section, they will be disabled when
*             leaving the critical section.
*
* Method #3:  Disable/Enable interrupts by preserving the state of interrupts.  Generally speaking you
*             would store the state of the interrupt disable flag in the local variable 'cpu_sr' and then
*             disable interrupts.  'cpu_sr' is allocated in all of uC/OS-II's functions that need to
*             disable interrupts.  You would restore the interrupt disable state by copying back 'cpu_sr'
*             into the CPU's status register.
*********************************************************************************************************
*/

#define  OS_CRITICAL_METHOD    3

#define  OS_ENTER_CRITICAL()    cpu_sr = OS_CPU_SR_Save();
#define  OS_EXIT_CRITICAL()     OS_CPU_SR_Restore(cpu_sr);


/*
*********************************************************************************************************
*                                            PowerPC405
*********************************************************************************************************
*/

#define  OS_STK_GROWTH        1            /* Stack grows from HIGH to LOW memory on PowerPC           */

#define  OS_TASK_SW()         __asm__ __volatile__("sc\n") 

/*
*********************************************************************************************************
*                                          FUNCTION PROTOTYPES
*********************************************************************************************************
*/

OS_CPU_SR	OS_CPU_SR_Save(void);          /* See OS_CPU_A.S                                           */
void		OS_CPU_SR_Restore(OS_CPU_SR);  /* See OS_CPU_A.S                                           */

