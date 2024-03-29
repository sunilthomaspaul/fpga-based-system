
 PARAMETER VERSION = 2.2.0


BEGIN OS 
 PARAMETER OS_NAME = standalone 
 PARAMETER OS_VER = 1.00.a 
 PARAMETER PROC_INSTANCE = ppc405_i 
 PARAMETER STDOUT = RS232_1 
 PARAMETER STDIN = RS232_1 
END 

BEGIN PROCESSOR 
 PARAMETER HW_INSTANCE = ppc405_i 
 PARAMETER DRIVER_NAME = cpu_ppc405 
 PARAMETER DRIVER_VER = 1.00.a 
 PARAMETER ARCHIVER = powerpc-eabi-ar 
 PARAMETER CORE_CLOCK_FREQ_HZ = 240000000 
 PARAMETER COMPILER = powerpc-eabi-gcc 
END 

BEGIN DRIVER 
 PARAMETER HW_INSTANCE = plb2opb_bridge_i 
 PARAMETER DRIVER_NAME = plb2opb 
 PARAMETER DRIVER_VER = 1.00.a 
END 

BEGIN DRIVER 
 PARAMETER HW_INSTANCE = opb_intc_i 
 PARAMETER DRIVER_NAME = intc 
 PARAMETER DRIVER_VER = 1.00.c 
 PARAMETER USE_DCR = 0 
END 

BEGIN DRIVER 
 PARAMETER DRIVER_NAME = uartlite 
 PARAMETER DRIVER_VER = 1.00.b 
 PARAMETER HW_INSTANCE = RS232_1 
END 

BEGIN DRIVER 
 PARAMETER HW_INSTANCE = plb_bus 
 PARAMETER DRIVER_NAME = plbarb 
 PARAMETER DRIVER_VER = 1.01.a 
END 

BEGIN DRIVER 
 PARAMETER HW_INSTANCE = opb_bus 
 PARAMETER DRIVER_NAME = opbarb 
 PARAMETER DRIVER_VER = 1.02.a 
END 

BEGIN DRIVER 
 PARAMETER DRIVER_NAME = ms_rst_4regs 
 PARAMETER DRIVER_VER = 1.00.a 
 PARAMETER HW_INSTANCE = ms_rst_4regs_0 
END 

BEGIN DRIVER 
 PARAMETER DRIVER_NAME = opb_slave1 
 PARAMETER DRIVER_VER = 1.00.a 
 PARAMETER HW_INSTANCE = opb_slave1_0 
END 


