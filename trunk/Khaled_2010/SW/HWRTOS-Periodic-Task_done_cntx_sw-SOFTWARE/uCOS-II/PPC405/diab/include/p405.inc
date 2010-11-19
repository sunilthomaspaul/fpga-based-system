#----------------------------------------------------------------
#
#  File Name:   p405.inc
#
#  Contains definitions specific to the PowerPC 405GP 
#  
#-----------------------------------------------------------------

.set RESET_ENTRY,          0xFFFFFFFC    # Reset Entry for PPC405GP.

## Vector Offsets

.set    crit_vector,    0x0100
.set    mach_vector,    0x0200
.set    prot_vector,    0x0300
.set    isi_vector,     0x0400
.set    ext_vector,     0x0500
.set    align_vector,   0x0600
.set    prog_vector,    0x0700
.set    fpu_vector,     0x0800
.set    sys_vector,     0x0C00
.set    pit_vector,     0x1000
.set    fit_vector,     0x1010
.set    wadt_vector,    0x1020
.set    dtlb_vector,    0x1100
.set    itlb_vector,    0x1200
.set    debug_vector,   0x2000

## On-chip Peripheral Controllers

.set EMAC_BASE,       0xef600500
.set GPIO_BASE,       0xef600700

## UART Controller (2 ports)

.set UART0,       0
.set UART1,       1

;/*-----------------------------------------------------------------------------+
; 405GP UART Base Address defines.                        
;+-----------------------------------------------------------------------------*/
.set UART0_BASE	,0xEF600300
.set UART1_BASE	,0xEF600400


# UART register offsets

.set DATA_REG,    0   # Data register
.set DLL,         0   # baud rate divisor latch LSB 
.set DLM,         1   # baud rate divisor latch MSB
.set IER,         1   # Interrupt Enable Register
.set IIR,         2   # Interrupt ID Register 
.set FCR,         2   # FIFO Control Register
.set LCR,         3   # Line Control Register
.set MCR,         4   # Modem Control Register
.set LSR,         5   # Line Status Register
.set MSR,         6   # Modem Status Register
.set SCR,         7   # Scratch Register

.set UART0LCR_DLA_SET, 0x80
.set UART0LCR_DLA_RSET,0x00
.set UART0LCR_8N1,     0x03    # 8 Data bits, No parity, 1 Stop bit.

.set UART1LCR_DLA_SET,  0x80    # Access the Baud Rate register
.set UART1LCR_DLA_RSET, 0x00    # 
.set UART1LCR_8N1,      0x03    # 8 Data bits, No parity, 1 Stop bit.

## I2C Controller

;/*-----------------------------------------------------------------------------+
;; 405GP IIC Base Address define.                        
;+-----------------------------------------------------------------------------*/
.set IIC0_BASE 	,0xEF600500
.set IIC_MASTER_ADDR, 0xef600500 

; IIC Register Offsets       
.set    IICMDBUF,         0x00
.set    IICSDBUF   ,      0x02
.set    IICLMADR,         0x04
.set    IICHMADR,         0x05
.set    IICCNTL ,         0x06
.set    IICMDCNTL,        0x07
.set    IICSTS  ,         0x08
.set    IICEXTSTS,        0x09
.set    IICLSADR ,        0x0A
.set    IICHSADR ,        0x0B
.set    IICCLKDIV,        0x0C
.set    IICINTRMSK,       0x0D
.set    IICXFRCNT ,       0x0E
.set    IICXTCNTLSS,      0x0F
.set    IICDIRECTCNTL,    0x10

## SDRAM Controller

.set SDRAM_DCR_BASE, 0x10

.set memcfga, (SDRAM_DCR_BASE+0x0)   # Memory configuration address reg 
.set memcfgd, (SDRAM_DCR_BASE+0x1)   # Memory configuration data    reg 

.set mem_besra,   0x00    # bus error syndrome reg a	
.set mem_besrsa,  0x04    # bus error syndrome reg set a
.set mem_besrb,   0x08    # bus error syndrome reg b
.set mem_besrsb,  0x0c    # bus error syndrome reg set b
.set mem_bear,    0x10    # bus error address reg
.set mem_mcopt1,  0x20    # memory controller options 1
.set mem_rtr,     0x30    # refresh timer reg	
.set mem_pmit,    0x34    # power management idle timer
.set mem_mb0cf,   0x40    # memory bank 0 configuration
.set mem_mb1cf,   0x44    # memory bank 1 configuration
.set mem_mb2cf,   0x48    # memory bank 2 configuration
.set mem_mb3cf,   0x4c    # memory bank 3 configuration
.set mem_sdtr1,   0x80    # timing reg 1		
.set mem_ecccf,   0x94    # ECC configuration		
.set mem_eccerr,  0x98    # ECC error status		


## Chip Controller

.set CNTRL_DCR_BASE, 0x0B0

.set pllmd,   (CNTRL_DCR_BASE+0x0)  # PLL mode  register                 
.set chcr0,   (CNTRL_DCR_BASE+0x1)  # Chip control register 0            
.set chcr1,   (CNTRL_DCR_BASE+0x2)  # Chip control register 1	    

.set sprg0,   272		    # special general reg 0         
.set sprg1,   273               # special general reg 1         
.set sprg2,   274               # special general reg 2          
.set sprg3,   275               # special general reg 3          


## External Bus Controller 

.set EBC_DCR_BASE, 0x12

.set ebccfga, (EBC_DCR_BASE+0x0)   # External bus controller addr reg  
.set ebccfgd, (EBC_DCR_BASE+0x1)   # External bus controller data reg  

.set pb0ap,   (0x10)
.set pb1ap,   (0x11)
.set pb2ap,   (0x12)
.set pb3ap,   (0x13)
.set pb4ap,   (0x14)
.set pb5ap,   (0x15)
.set pb6ap,   (0x16)
.set pb7ap,   (0x17)

.set	pb0cr,	(0x00)
.set	pb1cr,	(0x01)
.set	pb2cr,	(0x02)
.set	pb3cr,	(0x03)
.set	pb4cr,	(0x04)
.set	pb7cr,	(0x07)


## On Chip Memory Controller

.set OCM_DCR_BASE, 0x018

.set ocmisarc,  (OCM_DCR_BASE+0x00)  # OCM I-side Addr Comp Reg       
.set ocmiscntl, (OCM_DCR_BASE+0x01)  # OCM I-side Control Reg         
.set ocmdsarc,  (OCM_DCR_BASE+0x02)  # OCM D-side Addr Comp Reg       
.set ocmdscntl, (OCM_DCR_BASE+0x03)  # OCM D-side Control Reg         

## Power Management Unit

.set POWERMAN_DCR_BASE, 0xB8

.set cpmsr, (POWERMAN_DCR_BASE+0x0) # Power management status   
.set cpmer, (POWERMAN_DCR_BASE+0x1) # Power management enable  
.set cpmfr, (POWERMAN_DCR_BASE+0x2) # Power management force    


# Universal interrupt controller

.set UIC_DCR_BASE,  0xC0

.set uicsr,        (UIC_DCR_BASE+0x0)  # UIC status
.set uicsrs,       (UIC_DCR_BASE+0x1)  # UIC status set
.set uicer,        (UIC_DCR_BASE+0x2)  # UIC enable 
.set uiccr,        (UIC_DCR_BASE+0x3)  # UIC critical 
.set uicpr,        (UIC_DCR_BASE+0x4)  # UIC polarity 
.set uictr,        (UIC_DCR_BASE+0x5)  # UIC triggering 
.set uicmsr,       (UIC_DCR_BASE+0x6)  # UIC masked status 
.set uicvr,        (UIC_DCR_BASE+0x7)  # UIC vector     
.set uicvcr,       (UIC_DCR_BASE+0x8)  # UIC vector configuration  
