/*
* multit.c
*
* Sample multitasking application.
*
* Author: Ganesh.S
* Wipro Technologies
*/

#include "includes.h"
#include "types.h"

/* function prototypes */
void taskOne(void *);
void taskTwo(void *);
void taskThree(void *);

/* globals */
#define ITER1 10
#define ITER2 1
#define LONG_TIME 100000
#define HIGH 10 /* high priority */
#define MID 11 /* medium priority */
#define LOW 12 /* low priority */

#define	TASK_STK_SIZE     2048
#define T_DELAY				 1

/* Globals */
INT8U	taskOneData;
INT8U	taskTwoData;
INT8U	taskThreeData;

OS_STK		taskOneStk[TASK_STK_SIZE];
OS_STK		taskTwoStk[TASK_STK_SIZE];
OS_STK		taskThreeStk[TASK_STK_SIZE];

extern void sc_vect();
extern void timer_vect();
extern void ext_vect();

OS_EVENT *s_t3;

void main(void)
{
	INT32S	idx;
	INT32U	temp, v;
        
	int_disable();

	interrupt_init();
        uart_init();
        set_vector(0x0C00,sc_vect,VT_INTR,0);
        set_vector(0x1000,timer_vect,VT_INTR,0);
        set_vector(0x0500,ext_vect,VT_INTR,0);

        v =  OSVersion();
        s1printf("\n\n-----------------------------------------------------------\n");
        s1printf("UCOS-II Real Time Operating System for PPC405GP.\n");
        s1printf("Ported to UCOS-II v%d.%d by Wipro Technologies. India\n",v/100, v%100);
        s1printf("-----------------------------------------------------------\n\n");

        int_enable();

	OSInit ();

/* Create a semaphore for task 1 and task 3 sync. */
        s_t3 = OSSemCreate(0);

/* spawn the three tasks */
	OSTaskCreate(taskThree,(void *)&taskThreeData,&taskThreeStk[TASK_STK_SIZE],HIGH);
	OSTaskCreate(taskTwo,(void *)&taskTwoData,&taskTwoStk[TASK_STK_SIZE],MID);
	OSTaskCreate(taskOne,(void *)&taskOneData,&taskOneStk[TASK_STK_SIZE],LOW);

	OSStart();
	/* No, it never returns... */ 
}

void taskOne(void *data) 
{
int i,j;
for (i=0; i < ITER1; i++)
        {
        for (j=0; j < ITER2; j++)
                s1printf("taskOne (LOW)\n");
        for (j=0; j < LONG_TIME; j++);  
        }
        OSSemPost(s_t3);
}



void taskTwo(void *data) 
{
int i,j;
for (i=0; i < ITER1; i++)
        {
        for (j=0; j < ITER2; j++)
                s1printf("taskTwo (MED)\n");
        for (j=0; j < LONG_TIME; j++);
        }
        OSTaskSuspend(OS_PRIO_SELF);
}

void taskThree(void *data) 
{
int i,j;
INT8U err;

for (i=0; i < ITER1; i++)
        { 
        for (j=0; j < ITER2; j++)
                s1printf("taskThree (HIGH)\n");
        for (j=0; j < LONG_TIME; j++);
        }
        OSSemPend(s_t3,0,&err);
}
