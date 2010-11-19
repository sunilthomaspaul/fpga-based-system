/*
*********************************************************************************************************
*                                    APPLICATION SPECIFIC RTOS SETUP
*
*                             (c) Copyright 2005, Micrium, Inc., Weston, FL
*                                          All Rights Reserved
*
*                                          CONFIGURATION FILE
*
* File : app_cfg.h
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*                                            TASKS PRIORITIES
*********************************************************************************************************
*/

#define  APP_TASK_FIRST_ID                  0                                                               

#define  APP_TASK_FIRST_PRIO                0

#define  APP_TASK_SECOND_ID                 1

#define  APP_TASK_SECOND_PRIO               1

#define  APP_TASK_THIRD_ID                  2

#define  APP_TASK_THIRD_PRIO                2

/*
*********************************************************************************************************
*                                              STACK SIZES
*                            Size of the task stacks (# of OS_STK entries)
*********************************************************************************************************
*/

#define  APP_TASK_FIRST_STK_SIZE          256

#define  APP_TASK_SECOND_STK_SIZE         256

#define  APP_TASK_THIRD_STK_SIZE          256
