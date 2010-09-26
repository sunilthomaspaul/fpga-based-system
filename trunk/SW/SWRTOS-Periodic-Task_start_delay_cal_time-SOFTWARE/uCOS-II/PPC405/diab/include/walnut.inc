#----------------------------------------------------------------
#
#  File Name:   walnut.inc
#
#  Contains definitions specific to the walnut board.
#  
#-----------------------------------------------------------------

.set BOOT_START,           0x00026000    # Entry point for the boot code
.set VECTOR_BASE,          0x00000000    # The Vector table base

;/*-----------------------------------------------------------------------------+
; Timer resolution
;+-----------------------------------------------------------------------------*/
.set BUS_CLOCK_FREQ      , 200000000
.set BUS_RATE_IN_MHZ     ,(BUS_CLOCK_FREQ / 1000000)  
.set TICKS_PER_USEC      ,BUS_RATE_IN_MHZ             # ticks per usec
.set TICKS_PER_MSEC      ,(BUS_RATE_IN_MHZ * 1000)    # ticks per ms

;/*-----------------------------------------------------------------------------+
; Machine State Register bits
;+-----------------------------------------------------------------------------*/
MSR_PM       = 0x00000004
MSR_DR       = 0x00000010
MSR_IR       = 0x00000020
MSR_FE1      = 0x00000100
MSR_BE       = 0x00000200
MSR_SE       = 0x00000400
MSR_FE0      = 0x00000800
MSR_ME       = 0x00001000
MSR_FP       = 0x00002000
MSR_PR       = 0x00004000
MSR_EE       = 0x00008000

;/*-----------------------------------------------------------------------------+
; Cache parameters
;+-----------------------------------------------------------------------------*/
.set CACHE_DISABLED,       0x00000000    # Disable cache for all regions
.set I_CACHEABLE_REGIONS,  0x80000001    # instruction cache
.set D_CACHEABLE_REGIONS,  0x80000000    # data cache
.set STORE_MISS_LINE_FILL, 0x00000000    # 
.set COPY_BACK_WRITE_THRU, 0xffffffff    # write through is enabled for all memory

;/*-----------------------------------------------------------------------------+
; UART0 configuration values
;+-----------------------------------------------------------------------------*/
.set UART0DLL_WORD,    0x48    # To get a baudrate of 19200 bps at 
                               # 6.646 Mhz. (0x48 for walnut board)
.set UART0DLM_WORD,    0x00    # 
.set UART0IER_WORD,    0x00
.set UART0FCR_WORD,    0x07    # FIFO Enable, TX/RX FIFO reset, Rx FIFO Trig at 1.
.set UART0MCR_WORD,    0x03    # RTS and DTR active - Required for a Null modem connection.

;/*-----------------------------------------------------------------------------+
; UART1 configuration values
;+-----------------------------------------------------------------------------*/
.set UART1DLL_WORD,     0x07
.set UART1DLM_WORD,     0x00
.set UART1IER_WORD,     0x00    #  
.set UART1FCR_WORD,     0x07    #  

;/*-----------------------------------------------------------------------------+
; UIC-Interrupt controller(direct DCRs)
;+-----------------------------------------------------------------------------*/
.set UICER_WORD,    0x00000033
.set UICCR_WORD,    0x00000000
.set UICPR_WORD,    0xffffe001
.set UICTR_WORD,    0x10000001
.set UICVCR_WORD,   0x00000000

;/*-----------------------------------------------------------------------------+
; EBC configuration values
;+-----------------------------------------------------------------------------*/
.set EBC_BNK0_AP, 0x9B015480    
.set EBC_BNK0_CF, 0xFFF18000   #BAS=0xFFF,BS=0x0(1MB),BU=0x3(R/W),BW=0x0(8bit)
.set EBC_BNK1_AP, 0x02815480    
.set EBC_BNK1_CF, 0xF0018000   #BAS=0xF00,BS=0x0(1MB),BU=0x3(R/W),BW=0x0(8bit)
.set EBC_BNK2_AP, 0x04815A80    
.set EBC_BNK2_CF, 0xF0118000   #BAS=0xF01,BS=0x0(1MB),BU=0x3(R/W),BW=0x0(8bit)
.set EBC_BNK3_AP, 0x01815280    
.set EBC_BNK3_CF, 0xF0218000   #BAS=0xF02,BS=0x0(1MB),BU=0x3(R/W),BW=0x0(8bit)
.set EBC_BNK7_AP, 0x01815280    
.set EBC_BNK7_CF, 0xF0318000   #BAS=0xF03,BS=0x0(1MB),BU=0x3(R/W),BW=0x0(8 bit)

;/*-----------------------------------------------------------------------------+
; SDRAM configuration values
;+-----------------------------------------------------------------------------*/
.set SDRAM_BNK0_CF, 0x00046001
.set SDRAM_BNK1_CF, 0x00000000
.set SDRAM_BNK2_CF, 0x01046001
.set SDRAM_BNK3_CF, 0x00000001
.set SDRAM_MCOPT1, 0x80800000   #Set DC_EN to '1' and BRD_PRF to '01' for 16 byte PLB Burst read/prefetch 

;/*-----------------------------------------------------------------------------+
; 405GP PVR.
;+-----------------------------------------------------------------------------*/
.set PVR_405GP       ,0x40110000 
.set PVR_405GP_PASS1 ,0x40110000 
.set PVR_405GP_PASS2 ,0x40110040 

;/*----------------------------------------------------------------------------+
; 405GP PCI core memory map defines.
;+----------------------------------------------------------------------------*/
.set MIN_PCI_MEMADDR1    ,0x80000000
.set MIN_PCI_MEMADDR2    ,0x00000000
.set MIN_PLB_PCI_IOADDR  ,0xE8000000  ;/* PLB side of PCI I/O address space */
.set MIN_PCI_PCI_IOADDR  ,0x00000000  ;* PCI side of PCI I/O address space */
.set MAX_PCI_DEVICES,     5

;/*----------------------------------------------------------------------------+
; Defines for the 405GP PCI Config address and data registers followed by
; defines for the standard PCI device configuration header.
;+----------------------------------------------------------------------------*/
.set PCICFGADR       ,0xEEC00000
.set PCICFGDATA      ,0xEEC00004

.set PCIVENDORID     ,0x00
.set PCIDEVICEID     ,0x02
.set PCICMD          ,0x04
.set SERR_EN       ,0x0100
.set BM_EN         ,0x0004
.set MEM_EN        ,0x0002
.set IO_EN         ,0x0001
.set PCISTATUS       ,0x06
.set CAPABLE_66MHZ ,0x0020
.set PCIREVID        ,0x08
.set PCICLASSPI      ,0x09
.set PCICLASSCODE    ,0x0A
.set PCICACHELINE    ,0x0C
.set PCILATENCYTIM   ,0x0D
.set PCIHEADERTYPE   ,0x0E
.set PCIBIST         ,0x0F
.set PCIBASEADDR0    ,0x10
.set PCIBASEADDR1    ,0x14
.set PCIBASEADDR2    ,0x18
.set PCIINTLINE      ,0x3C
.set PCIINTPIN       ,0x3D
.set PCIMINGRANT     ,0x3E
.set PCIMAXLATENCY   ,0x3F

.set PCIBUSNUM       ,0x40        ; /* 405GP specific parameters */
.set PCISUBBUSNUM    ,0x41
.set PCIDISCOUNT     ,0x42
.set PCIBRDGOPT1     ,0x4A
.set PCIBRDGOPT2     ,0x60

;/*----------------------------------------------------------------------------+
; Defines for 405GP PCI Master local configuration regs.
;+----------------------------------------------------------------------------*/
.set PMM0LA          ,0xEF400000
.set PMM0MA          ,0xEF400004
.set PMM0PCILA       ,0xEF400008
.set PMM0PCIHA       ,0xEF40000C
.set PMM1LA          ,0xEF400010
.set PMM1MA          ,0xEF400014
.set PMM1PCILA       ,0xEF400018
.set PMM1PCIHA       ,0xEF40001C
.set PMM2LA          ,0xEF400020
.set PMM2MA          ,0xEF400024
.set PMM2PCILA       ,0xEF400028
.set PMM2PCIHA       ,0xEF40002C

;/*----------------------------------------------------------------------------+
; Defines for 405GP PCI Target local configuration regs.
;+----------------------------------------------------------------------------*/
.set PTM1MS          ,0xEF400030
.set PTM1LA          ,0xEF400034
.set PTM2MS          ,0xEF400038
.set PTM2LA          ,0xEF40003C

;/*-----------------------------------------------------------------------------+
;       PCI-PCI bridge header
;+-----------------------------------------------------------------------------*/
.set PCIPCI_PRIMARYBUS       ,0x18
.set PCIPCI_SECONDARYBUS     ,0x19
.set PCIPCI_SUBORDINATEBUS   ,0x1A
.set PCIPCI_SECONDARYLATENCY ,0x1B
.set PCIPCI_IOBASE           ,0x1C
.set PCIPCI_IOLIMIT          ,0x1D
.set PCIPCI_SECONDARYSTATUS  ,0x1E
.set PCIPCI_MEMBASE          ,0x20
.set PCIPCI_MEMLIMIT         ,0x22
.set PCIPCI_PREFETCHMEMBASE  ,0x24
.set PCIPCI_PREFETCHMEMLIMIT ,0x26
.set PCIPCI_IOBASEUPPER16    ,0x30
.set PCIPCI_IOLIMITUPPER16   ,0x32

;/*----------------------------------------------------------------------------+
; Universal Interrupt Controller (UIC) events for the Walnut board.
;+----------------------------------------------------------------------------*/
;/* Walnut board external IRQs */
.set EXT_IRQ_FPGA,      	UIC_EXT0  ;	/* IRQ 25 */ 
.set EXT_IRQ_SMI ,     	UIC_EXT1          ;/* IRQ 26 */
.set EXT_IRQ_UNUSED 	,UIC_EXT2  ; 	/* IRQ 27 */ 
.set EXT_IRQ_PCI_SLOT3 	,UIC_EXT3        ;/* IRQ 28 */
.set EXT_IRQ_PCI_SLOT2 	,UIC_EXT4        ;/* IRQ 29 */
.set EXT_IRQ_PCI_SLOT1 	,UIC_EXT5        ;/* IRQ 30 */
.set EXT_IRQ_PCI_SLOT0 	,UIC_EXT6        ;/* IRQ 31 */

.set EXT_IRQ_CASCADE  	,EXT_IRQ_FPGA 
.set EXT_IRQ_EXPANSION	,EXT_IRQ_FPGA 
.set EXT_IRQ_IR       	,EXT_IRQ_FPGA
.set EXT_IRQ_KEYBOARD	,EXT_IRQ_FPGA
.set EXT_IRQ_MOUSE  	,EXT_IRQ_FPGA

;/*-----------------------------------------------------------------------------+
; Defines for the RTC/NVRAM.
;+-----------------------------------------------------------------------------*/
.set NVRAM_BASE      ,0xF0000000
.set RTC_CONTROL     ,0xF0001FF8
.set RTC_SECONDS     ,0xF0001FF9
.set RTC_MINUTES     ,0xF0001FFA
.set RTC_HOURS       ,0xF0001FFB
.set RTC_DAY         ,0xF0001FFC
.set RTC_DATE        ,0xF0001FFD
.set RTC_MONTH       ,0xF0001FFE
.set RTC_YEAR        ,0xF0001FFF

;/*-----------------------------------------------------------------------------+
; Defines for the Keyboard/Mouse controller.
;+-----------------------------------------------------------------------------*/
.set KEY_MOUSE_BASE  ,0xF0100000
.set KEY_MOUSE_DATA  ,0xF0100000
.set KEY_MOUSE_CMD   ,0xF0100001  ;/* write only */
.set KEY_MOUSE_STAT  ,0xF0100001  ;/* read only */

;/*-----------------------------------------------------------------------------+
; Defines for FPGA regs.
;+-----------------------------------------------------------------------------*/
.set FPGA_INT_STATUS ,0xF0300000  ;  /* Int status - read only 	*/
.set FPGA_INT_ENABLE ,0xF0300001  ;  /* Int enable 			*/
.set FPGA_INT_POL    ,0xF0300002  ;  /* Int polarity 			*/
.set FPGA_INT_TRIG   ,0xF0300003  ;  /* Int type 			*/
.set FPGA_BRDC       ,0xF0300004  ;  /* Board controls 		*/
.set FPGA_BRDS1      ,0xF0300005  ;  /* Board status - read only 	*/
.set FPGA_BRDS2      ,0xF0300006  ;  /* Board status - read only       */
.set SW_CLK_SRC1     ,0x40        ;  /* if async pci, ext or int clk   */
.set FSEL_A          ,0x03        ;  /* use for mask                   */
.set FSEL_INVALID1   ,0x00        ;  /* invalid FSEL_A0, FSEL_A1 settings*/
.set FSEL_INVALID2   ,0x02        ;  /* invalid FSEL_A0, FSEL_A1 settings*/
.set FSEL_66         ,0x01        ;  /* select 66Mhz async int PCI	*/
.set FSEL_33         ,0x03        ;  /* select 33Mhz async int PCI     */   
.set FPGA_SPARE1     ,0xF030000E  ;  /* Spare inputs - read only       */
.set FPGA_SPARE2     ,0xF030000F  ;  /* Spare outputs                  */

;/*-----------------------------------------------------------------------------+
; Misc defines
;+-----------------------------------------------------------------------------*/
.set STACK_SIZE 	,0x2000   ;       /* ROM Monitor stack size */
.set ONE_BILLION,	1000000000
.set ONE_MILLION,	1000000
.set HWADDRLEN     ,  6
.set MAXDEVICES    ,  6
.set ENTRY_PT_MIN    ,0x25000     ;    /* min entry point for an application */
				;	/* loaded by the ROM Monitor */
.set MAXPACKET     ,  1518
.set ENET_MINPACKET,  64
.set SRAM_START_ADDR ,0xFFF00000;      /* SRAM starting addr */
.set SRAM_SIZE 	,0x80000        ; /* SRAM size - 512K */
.set VPD_ADDR        ,0xFFFFFE00 ;     /* Vital Product Data area in ROM */
;.set TEXTADDR        ,0xFFFE0000 ;     /* start of ROM Monitor text in ROM */
.set TEXTADDR        ,0x00000000 ;     /* start of ROM Monitor text in ROM */
.set DATAADDR        ,0x00006000 ;     /* start of ROM Monitor data in RAM */
.set NO_BAUD  	,0
.set S1_BAUD  	,1
.set NVRVFY1 	,0x4f532d4f    ;/* used to determine if state data in */
.set NVRVFY2 	,0x50454e00    ;/* NVRAM initialized (ascii for OS-OPEN)*/
.set RFI             ,0x4c000064  ;  /* RFI instruction */
.set PCIDEVID_405GP 	,0x0
.set PCI_SLOT0_DEVID ,0x4         ;  /* Note: on Walnut slot 0 is furthest */ 
.set PCI_SLOT1_DEVID ,0x3         ;  /* slot away from the processor card */
.set PCI_SLOT2_DEVID ,0x2
.set PCI_SLOT3_DEVID ,0x1
.set VCO_MIN,		400       ;    /* VCO min frequency in MHz */
.set VCO_MAX,		800       ;    /* VCO max frequency in MHz */
.set asyncClockRate,  11059200     ; /* ext serial clock for UARTs */

