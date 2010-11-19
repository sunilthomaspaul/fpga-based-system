#include    "xparameters.h"
#include    "xgpio_l.h"
#include    "xintc.h"
#include    "xintc_i.h"
#include    "xintc_l.h"

/*
*********************************************************************************************************
*                                             CONSTANTS
*********************************************************************************************************
*/

#define  BSP_CLK_FREQ           XPAR_CPU_PPC405_CORE_CLOCK_FREQ_HZ

#define  BSP_INTC_DEVICE_ID     XPAR_OPB_INTC_I_DEVICE_ID

#define  BSP_INTC_ADDR          XPAR_OPB_INTC_I_BASEADDR

#define  BSP_GPIO_ADDR          XPAR_OPB_GPIO_0_BASEADDR

#define  BSP_TMR_VAL            (BSP_CLK_FREQ / 100)
