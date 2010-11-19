/*-------------------------------------------------------------------
* Filename : test_uartlite_9600.c
* on the STDOUT device
* ----------------------------------------------------------------*/
#include "xparameters.h"
/*#include "includes.h"

int led_status;

void  LED_On (int led)
{
    led_status = XGpio_mGetDataReg(BSP_GPIO_ADDR,1);

    switch (led) {
        case 0:
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
}


void  LED_Off (int led)
{

    led_status = XGpio_mGetDataReg(BSP_GPIO_ADDR,1);

    switch (led) {
        case 0:
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
}


void  LED_Toggle (int led)
{

    led_status = XGpio_mGetDataReg(BSP_GPIO_ADDR,1);
    
    switch (led) {
        case 0:
            led_status ^= 0x000001FF;
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
}


void  LED_Init (void) 
{
    XGpio_mWriteReg(BSP_GPIO_ADDR, XGPIO_TRI_OFFSET, 0x00000000); 
    LED_Off(0);                         
}


void  Tmr_Init (void)
{
    __asm__ __volatile__("mtspr " "987" ",%0\n" : : "r" (0x00000000));   
    __asm__ __volatile__("mtspr " "984" ",%0\n" : : "r" (0x08000000));   
    __asm__ __volatile__("mtspr " "986" ",%0\n" : : "r" (0x04400000));   
    __asm__ __volatile__("mtspr " "987" ",%0\n" : : "r" (BSP_TMR_VAL));  
}


void  BSP_InitIO (void)    
{
    Tmr_Init();                         
    LED_Init();                         
}*/

int main() {

//int i;

	xil_printf("Hello World \n");
	
/*	BSP_InitIO();
	while (1) {
	     LED_On(0);
		  xil_printf("On=%d \n",led_status);
		  for (i=0;i<=1000000;i++);
		  LED_Off(0);
		  xil_printf("Off=%d \n",led_status);
		  for (i=0;i<=1000000;i++);		
    }*/

return 0;
}



