#------------------------------------------------------------------------------+
#
#       This source code has been made available to you by IBM on an AS-IS
#       basis.  Anyone receiving this source is licensed under IBM
#       copyrights to use it in any way he or she deems fit, including
#       copying it, modifying it, compiling it, and redistributing it either
#       with or without modifications.  No license under IBM patents or
#       patent applications is to be implied by the copyright license.
#
#       Any user of this software should understand that IBM cannot provide
#       technical support for this software and will not be responsible for
#       any consequences resulting from the use of this software.
#
#       Any person who transfers this source code or any derivative work
#       must include the IBM copyright notice, this paragraph, and the
#       preceding two paragraphs in the transferred software.
#
#       COPYRIGHT   I B M   CORPORATION 1995
#       LICENSED MATERIAL  -  PROGRAM PROPERTY OF I B M
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#  File Name:  crt0.s
#  Function:   Startup code for Walnut board.
#  
#  Change Activity-
# 
#  Date        Description of Change 
#  ---------   ---------------------                  
#  19-Jul-01   IBM code from Metaware compiler to Diab.
#  01-Aug-01   Added vector handling mechanisms. 
#-------------------------------------------------------------------------------
	.include "p405.inc"
	.include "board.inc"

	.file  "crt0.s"

#---------------------------------------------------------------------
# 	forward declarations
#---------------------------------------------------------------------
        .globl  set_vector			# setup an interrupt vector
        .globl  interrupt_save_registers	# save all reg's not already saved
        .globl  interrupt_restore_registers	# restore reg's and then rfi

#------------------------------------------------------------------
# RESET_ENTRY. (0xfffffffc). When the 405 resets, this is the
# location where the first instruction is executed. 
#------------------------------------------------------------------
    .org    RESET_ENTRY
    .global reset_entry

reset_entry:
    b _start

    .text
    .align      2

#------------------------------------------------------------------
# START OF BOOT CODE.
#------------------------------------------------------------------
    .text
    .globl      _start
    .align      2
    addi        r0,r0,0        

_start:
    addis       r11,r0,__SP_INIT@ha    # Initialize stack pointer r1 to
    addi        r1,r11,__SP_INIT@l     # value in linker command file.
    addis       r13,r0,_SDA_BASE_@ha   # Initialize r13 to sdata base
    addi        r13,r13,_SDA_BASE_@l   # (provided by linker).
    addis       r2,r0,_SDA2_BASE_@ha   # Initialize r2 to sdata2 base
    addi        r2,r2,_SDA2_BASE_@l    # (provided by linker).
    addi        r0,r0,0                # Clear r0.
    stwu        r0,-64(r1)             # Terminate stack.

    #---------------------------------------------------------------------
    # Setup initial value of MSR.
    #---------------------------------------------------------------------
    addis    r4,0,0x00000000@h
    ori      r4,r4,0x00000000@l
    mtmsr    r4

    #---------------------------------------------------------------------
    # invalidate icache.
    #---------------------------------------------------------------------
    iccci   r0,r0                # for 405, iccci invalidates the

    #---------------------------------------------------------------------
    # invalidate dcache
    #---------------------------------------------------------------------
    addi    r6,0,0x0000            # clear GPR 6
    addi    r7,r0, 128             # do loop for # of dcache lines
                                   # NOTE: dccci invalidates both
    mtctr   r7                     # ways in the D cache
..dcloop1:
    dccci   0,r6                   # invalidate line
    addi    r6,r6, 32              # bump to next line
    bdnz    ..dcloop1
    
    #----------------------------------------------------------------------
    # Turn off cache for all regions, for now.
    #----------------------------------------------------------------------
    addis   r4,r0, CACHE_DISABLED@h     # inst cache
    ori     r4,r4, CACHE_DISABLED@l
    mticcr  r4
    isync
    addis   r4,r0, CACHE_DISABLED@h     # data cache
    ori     r4,r4, CACHE_DISABLED@l
    mtdccr  r4
    isync

    #-----------------------------------------------------------------------
    # Initialize the External Bus Controller for external peripherals
    #-----------------------------------------------------------------------
    bl      ext_bus_cntlr_init

    #-----------------------------------------------------------------------
    # Initialize the Control 0 register for UART control. 
    # Set UART1 for CTS/RTS and set the UART0 and UART1 external
    # clock enable to use the external serial clock instead of an  
    # internally derived clock. Set the FPGA control reg for UART1 to
    # select CTS/RTS.              
    #-----------------------------------------------------------------------
    addis   r3,r0,0x0000            ; set CTS/RTS for UART1 and set ext
    ori     r3,r3,0x10C0	        ; clock for UART0 and UART1   

    mfdcr   r4,chcr0               ; read CNTRL0
    or      r3,r3,r4                ; read-modify-write
    mtdcr   chcr0,r3               ; set CNTRL0

    addis   r4,r0,FPGA_BRDC@h
    ori     r4,r4,FPGA_BRDC@l
    lbz     r3,0(r4)                ; get FPGA board control reg 
    eieio
    ori	r3,r3,0x01              ; set UART1 control to select CTS/RTS
    stb     r3,0(r4)

    #-----------------------------------------------------------------------
    # Initialise SPRs
    #-----------------------------------------------------------------------
    addi    r4,r0,0x0000
    mtsgr   r4                #no guarded memory
    mtsler    r4              #all memory is in big endian style
    mtspr    su0r,r4          #no storage compression
    mtesr   r4                #clear Exception Syndrome Reg
    mtxer   r4                #clear Fixed-Point Exception Reg
    addis   r4,r0,VECTOR_BASE@h    #set exception vector prefix
    ori    r4,r4,VECTOR_BASE@l
    mtevpr  r4                #Vector table address

    addi    r4,r0,0xFFFF      #set r4 to 0xFFFFFFFF (status in the
    mtdbsr  r4                #dbsr is cleared by setting bits to 1)
                              #clear/reset the dbsr

    #-----------------------------------------------------------------------
    # Initialise Timer
    #-----------------------------------------------------------------------
    # reset TBL & TBH
    addis   r4,0,0x0000       # set DC_EN=1
    ori     r4,r4,0x0000
    mttbl   r4                # reset lower 32 bit
    mttbu   r4                # reset upper 32 bit

    # timer control reg init
    addis   r4,0,0x0440       # Wdog period is 2^29 clocks, no watchdog reset
    ori     r4,r4,0x0000      # wdog and fit intr. disabled. pit intr enabled.
    mttcr   r4

    #-----------------------------------------------------------------------
    # Initialise SDRAM's DCR  (Indirect)
    #-----------------------------------------------------------------------
    bl      sdram_init

    #-----------------------------------------------------------------------
    # Jump to C ...
    #-----------------------------------------------------------------------
    bl      main 

..stop:  b           ..stop

#-----------------------------------------------------------------------------
# Function:     sdram_init
# Description:  Configures SDRAM memory banks.
#-----------------------------------------------------------------------------
    .text
    .align 2
    .globl  sdram_init

sdram_init:

    mflr    r31

    addi    r4,0,mem_mb0cf
    mtdcr   memcfga,r4
    addis   r4,0,SDRAM_BNK0_CF@h
    ori     r4,r4,SDRAM_BNK0_CF@l
    mtdcr   memcfgd,r4

    addi    r4,0,mem_mb1cf
    mtdcr   memcfga,r4
    addis   r4,0,SDRAM_BNK1_CF@h
    ori     r4,r4,SDRAM_BNK1_CF@l
    mtdcr   memcfgd,r4

    addi    r4,0,mem_mb2cf
    mtdcr   memcfga,r4
    addis   r4,0,SDRAM_BNK2_CF@h
    ori     r4,r4,SDRAM_BNK2_CF@l
    mtdcr   memcfgd,r4

    addi    r4,0,mem_mb3cf
    mtdcr   memcfga,r4
    addis   r4,0,SDRAM_BNK3_CF@h
    ori     r4,r4,SDRAM_BNK3_CF@l
    mtdcr   memcfgd,r4

    #-------------------------------------------------------------------
    # Set the SDRAM Timing reg, SDTR1 and the refresh timer reg, RTR.
    # To set the appropriate timings, we need to know the SDRAM speed.
    # We can use the PLB speed since the SDRAM speed is the same as
    # the PLB speed. The PLB speed is the FBK divider times the
    # 405GP reference clock, which on the Walnut board is 33Mhz.
    # Thus, if FBK div is 2, SDRAM is 66Mhz; if FBK div is 3, SDRAM is
    # 100Mhz; if FBK is 3, SDRAM is 133Mhz.
    # NOTE: The Walnut board supports SDRAM speeds of 66Mhz, 100Mhz, and
    # maybe 133Mhz.
    #-------------------------------------------------------------------
    addis   r6,0,0x0086               # SDTR1 value for 100Mhz
    ori     r6,r6,0x400D
    addis   r7,0,0x05F0               # RTR value for 100Mhz

..sdram_ok:
   #-------------------------------------------------------------------
    # Set SDTR1
    #-------------------------------------------------------------------
    addi    r4,0,mem_sdtr1
    mtdcr   memcfga,r4
    mtdcr   memcfgd,r6

    #-------------------------------------------------------------------
    # Set RTR
    #-------------------------------------------------------------------
    addi    r4,0,mem_rtr
    mtdcr   memcfga,r4
    mtdcr   memcfgd,r7

    #-------------------------------------------------------------------
    # Delay to ensure 200usec have elapsed since reset. Assume worst
    # case that the core is running 200Mhz:
    #   200,000,000 (cycles/sec) X .000200 (sec) = 0x9C40 cycles
    #-------------------------------------------------------------------
    addis   r3,0,0x0000
    ori     r3,r3,0xA000          # ensure 200usec have passed since reset
    mtctr   r3
..spinlp2:
    bdnz    ..spinlp2             # spin loop

    #-------------------------------------------------------------------
    # Set memory controller options reg, MCOPT1.
    #-------------------------------------------------------------------
    addi    r4,0,mem_mcopt1
    mtdcr   memcfga,r4
    addis   r4,0,SDRAM_MCOPT1@h
    ori     r4,r4,SDRAM_MCOPT1@l
    mtdcr   memcfgd,r4

    #-------------------------------------------------------------------
    # Delay to ensure 10msec have elapsed since reset. This is
    # required for the MPC952 to stabalize. Assume worst
    # case that the core is running 200Mhz:
    #   200,000,000 (cycles/sec) X .010 (sec) = 0x1E8480 cycles
    # This delay should occur before accessing SDRAM.
    #-------------------------------------------------------------------
    addis   r3,0,0x001E
    ori     r3,r3,0x8480          # ensure 10msec have passed since reset
    mtctr   r3
..spinlp3:
    bdnz    ..spinlp3             # spin loop

    mtlr    r31                   # restore lr
    blr


;-----------------------------------------------------------------------------
; Function:     ext_bus_cntlr_init
; Description:  Initializes the External Bus Controller for the external 
;		peripherals. IMPORTANT: For pass1 this code must run from 
;		cache since you can not reliably change a peripheral banks
;		timing register (pbxap) while running code from that bank.
;		For ex., since we are running from ROM on bank 0, we can NOT 
;		execute the code that modifies bank 0 timings from ROM, so
;		we run it from cache.
;	Bank 0 - Flash/SRAM 
;	Bank 1 - NVRAM/RTC
;	Bank 2 - KYBD/Mouse Controller
;	Bank 3 - IRDA
;	Bank 4 - Pinned out to Expansion connector
;	Bank 5 - Pinned out to Expansion connector
;	Bank 6 - Pinned out to Expansion connector
;	Bank 7 - FPGA regs 
;-----------------------------------------------------------------------------
        .text
        .align 2
        .globl  ext_bus_cntlr_init

ext_bus_cntlr_init:

        addis   r4,r0, I_CACHEABLE_REGIONS@h
        ori     r4,r4, I_CACHEABLE_REGIONS@l

        mficcr  r9                     ; get iccr value
        cmp     cr0,0,r9,r4          ; check if caching already enabled
        beq     ..icache_on             ; if not,
        mticcr  r4                     ; enable caching 
..icache_on:
        addis   r3,0,ext_bus_cntlr_init@h    ; store the address of the 
        ori     r3,r3,ext_bus_cntlr_init@l  ; ext_bus_cntlr_init functn in r3
        addi    r4,0,11                ; set ctr to 10; used to prefetch
        mtctr   r4                     ; 10 cache lines to fit this function
                                        ; in cache (gives us 8x10=80 instrctns)
..ebcloop:
        icbt    r0,r3                 ; prefetch cache line for addr in r3
        addi    r3,r3,32		; move to next cache line
        bdnz    ..ebcloop               ; continue for 10 cache lines

        ;-------------------------------------------------------------------
        ; Delay to ensure all accesses to ROM are complete before changing
	; bank 0 timings. 200usec should be enough.
        ;   200,000,000 (cycles/sec) X .000200 (sec) = 0x9C40 cycles
        ;-------------------------------------------------------------------
	addis	r3,0,0x0
        ori     r3,r3,0xA000          ; ensure 200usec have passed since reset
        mtctr   r3
..spinlp:
        bdnz    ..spinlp                ; spin loop

        ;-----------------------------------------------------------------------
        ; Memory Bank 0 (Flash/SRAM) initialization
        ;-----------------------------------------------------------------------
        addi    r4,0,pb0ap
        mtdcr   ebccfga,r4
        addis   r4,0,0x9B01
        ori     r4,r4,0x5480
        mtdcr   ebccfgd,r4

        addi    r4,0,pb0cr
        mtdcr   ebccfga,r4
        addis   r4,0,0xFFF1            ; BAS=0xFFF,BS=0x0(1MB),BU=0x3(R/W),
        ori     r4,r4,0x8000          ; BW=0x0(8 bits)
        mtdcr   ebccfgd,r4

        ;-----------------------------------------------------------------------
        ; Memory Bank 1 (NVRAM/RTC) initialization
        ;-----------------------------------------------------------------------
        addi    r4,0,pb1ap
        mtdcr   ebccfga,r4
        addis   r4,0,0x0281         
        ori     r4,r4,0x5480
        mtdcr   ebccfgd,r4

        addi    r4,0,pb1cr
        mtdcr   ebccfga,r4
        addis   r4,0,0xF001            ; BAS=0xF00,BS=0x0(1MB),BU=0x3(R/W),
        ori     r4,r4,0x8000            ; BW=0x0(8 bits)
        mtdcr   ebccfgd,r4

        ;-----------------------------------------------------------------------
        ; Memory Bank 2 (KYBD/Mouse) initialization
        ;-----------------------------------------------------------------------
        addi    r4,0,pb2ap
        mtdcr   ebccfga,r4
        addis   r4,0,0x0481
        ori     r4,r4,0x5A80
        mtdcr   ebccfgd,r4

        addi    r4,0,pb2cr
        mtdcr   ebccfga,r4
        addis   r4,0,0xF011            ; BAS=0xF01,BS=0x0(1MB),BU=0x3(R/W),
        ori     r4,r4,0x8000            ; BW=0x0(8 bits)
        mtdcr   ebccfgd,r4

        ;-----------------------------------------------------------------------
        ; Memory Bank 3 (IRDA) initialization
        ;-----------------------------------------------------------------------
        addi    r4,0,pb3ap
        mtdcr   ebccfga,r4
        addis   r4,0,0x0181         
        ori     r4,r4,0x5280
        mtdcr   ebccfgd,r4

        addi    r4,0,pb3cr
        mtdcr   ebccfga,r4
        addis   r4,0,0xF021            ; BAS=0xF02,BS=0x0(1MB),BU=0x3(R/W),
        ori     r4,r4,0x8000            ; BW=0x0(8 bits)
        mtdcr   ebccfgd,r4

        ;-----------------------------------------------------------------------
        ; Memory Bank 7 (FPGA regs) initialization
        ;-----------------------------------------------------------------------
        addi    r4,0,pb7ap
        mtdcr   ebccfga,r4
        addis   r4,0,0x0181            ; TWT=3  
        ori     r4,r4,0x5280
        mtdcr   ebccfgd,r4

        addi    r4,0,pb7cr
        mtdcr   ebccfga,r4
        addis   r4,0,0xF031            ; BAS=0xF03,BS=0x0(1MB),BU=0x3(R/W),
        ori     r4,r4,0x8000            ; BW=0x0(8 bits)
        mtdcr   ebccfgd,r4

        cmpi    cr0,0,r9,0x0 		; check if I cache was off when we
					; started 
        bne     ..ebc_done		; if it was on, leave on
        addis   r4,r0,0x0000		; if it was off, disable
        mticcr  r4                     ; restore iccr
        isync

..ebc_done:
	nop				; pass2 DCR errata #8
        blr

        .type  ext_bus_cntlr_init,@function
        .size  ext_bus_cntlr_init,.-ext_bus_cntlr_init


#------------------------------------------------------------------------
# Interrupt related functions begin here.
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# Function: system call handler
# Description: Handles context swicth
#------------------------------------------------------------------------
    .text
    .align 2
    .globl  sc_vect

sc_vect:
    bl    OSCtxSw

    .type sc_vect,@function
    .size sc_vect,.-sc_vect

#------------------------------------------------------------------------
# Function: timer handler
# Description: Handles periodic timer
#------------------------------------------------------------------------
    .text
    .align 2
    .globl  timer_vect

timer_vect:
# clear this interrupt.
    mftsr   r3
    mttsr   r3
# invoke the handler.
    bl    interrupt_save_registers
    bl    OSTimeTick
    bl    interrupt_restore_registers 
    isync
    rfi

    .type timer_vect,@function
    .size timer_vect,.-timer_vect


#------------------------------------------------------------------------
# Function: External interrupt handler
# Description: Handles all external interrupts
#------------------------------------------------------------------------
    .text
    .align 2
    .globl  ext_vect

ext_vect:
    bl    interrupt_save_registers
    bl    external_interrupt
    bl    interrupt_restore_registers 
    isync
    rfi


    .type ext_vect,@function
    .size ext_vect,.-ext_vect


#************************************************************************
#   Install a vector                                                    *
#                                                                       *
#   CALL BY:    void set_vector(addr, handler, type, enable_mask        *
#                        long enable_mask);                             *
#                                                                       *
#               uint32    addr;         address of vector to install    *
#               void(*)() handler;      address of handler              *
#               sint32    type;         type of vector to install       *
#               	zero = VT_DIRECT - "handler" is actually vector     *
#                       code and is copied to the specified vector      *
#                                                                       *
#               	10 = VT_INTR - Interrupt exception handler, link    *
#						to it rather than copy lcoally                  *
#                                                                       *
#               uint32    enable_mask;   bit mask to "or" w/ the MSR    *
#                                        *after* SRR0/1 are saved.      *
#               This can be used to quickly re-enable other             *
#               types of exceptions.                                    *
#                                                                       *
#   AT EXIT:    The vector is installed                                 *
#                                                                       *
#************************************************************************

        .text
        .align 2
        .globl  set_vector
#
set_vector:
        stw     r4, V_HANDLER(r3)       # Store handler address
        stw     r6, V_ENABLE_MASK(r3)   # Store bit mask for MSR
#
#------------------------------------------------------------------------
# Load the address of the vector code to copy into r5                   *
#------------------------------------------------------------------------
#
        rlwinm  r8, r5, 16, 16, 31      # number of bytes of code for VT_DIRECT
        rlwinm. r5, r5,  2, 16, 31      # r5: Offset in TC.VECTORS
        bne     NotDirect
#
        cmpwi   r8, 0x0                 # number of instructions to copy
        bne     DirectLen
        li      r8, 0x40
DirectLen:
        mr      r5, r4                  # Code to copy is "handler"
        b       Ready
#
NotDirect:
        li      r8, V_ENDCODE/4         # r8: # instructions to copy
        lis     r6, TC.VECTORS@ha
        addi    r6, r6, TC.VECTORS@l    # r6-> TC.VECTORS
        add     r6, r6, r5              # r6-> TC.VECTORS[type]
        lwz     r5, 0(r6)               # r5-> vector code to copy
#
#------------------------------------------------------------------------
# Now copy the vector code                                              *
#------------------------------------------------------------------------
#
Ready:
        addi    r7, r3, -4              # r7-> dest addr (sub 4 to start)
        addi    r5, r5, -4              # r5-> src addr (sub 4 to start)
        mtctr   r8                      # CTR: # instrs (words) to move
#
Loop:
        lwzu    r0, 4(r5)
        stwu    r0, 4(r7)
        bc      0x10, 0, Loop

        blr                             # All done!
#
        .align  2
#
TC.VECTORS:
        .long   0                       # dummy entry!
        .long   VT_INTR
#
        .text
#
#************************************************************************
#      VT_INTR: Interrupt exception vector                              *
#                                                                       *
#      NOTE(S): It is necessary to save SRR0 and SRR1 in the vector's   *
#       "register save area" before extending the stack and storing     *
#       them there, because accessing the stack might cause a TLB miss  *
#       exception, which will change SRR0 and SRR1.                     *
#                                                                       *
#************************************************************************
VT_INTR:
#------------------------------------------------------------------------
# Set r31 to point to the beginning of this vector.  In order to do this*
# it is necessary to first save the current values of LR and r31 in     *
# SPRG2 and SPRG3 respectively.                                         *
#------------------------------------------------------------------------
        mtspr   SPRG3, r31              # SPRG3: saved value of r31
        mflr    r31
        mtspr   SPRG2, r31              # SPRG2: saved value of LR
 
        bl      1f                      # LR: current IP
1:
        mflr    r31                     # r31: current IP
        rlwinm  r31, r31, 0, 0, 23      # r31->beginning of vector
#
#------------------------------------------------------------------------
# Store values of r30 and SRR0 & SRR1 in the vector's save area
#------------------------------------------------------------------------
        stw     r30, V_SAVE_AREA+8(r31) # save r30
#
        mfsrr0  r30
        stw     r30, V_SAVE_AREA+36(r31)# Save SRR0
        mfsrr1  r30
        stw     r30, V_SAVE_AREA+40(r31)# Save SRR1

#------------------------------------------------------------------------
# Create a stack frame and put r29-r31, LR, CR, SRR0 and SRR1 on it.    *
#------------------------------------------------------------------------
        stwu    sp,  SC_STK_FRAME(sp)   # Allocate a stack frame
        stw     r29, SC_STK_R29(sp)     # Save r29

        lwz     r29, V_SAVE_AREA+8(r31) # 
        stw     r29, SC_STK_R30(sp)     # Save r30

        mfspr   r29, SPRG3
        stw     r29, SC_STK_R31(sp)     # Save r31

        lwz     r29, V_SAVE_AREA+36(r31)    
        stw     r29, SC_STK_SRR0(sp)    # Save SRR0

        mfspr   r29, SPRG2
        stw     r29, SC_STK_LR(sp)      # Save LR
        lwz     r30, V_SAVE_AREA+40(r31)
        stw     r30, SC_STK_SRR1(sp)    # Save SRR1
        mfcr    r29                     # r29: CR
        stw     r29, SC_STK_CR(sp)      # Save CR
		mfxer	r29						# r29: XER
		stw		r29, SC_STK_XER(sp)		# save XER
		mfctr	r29						# r29: CTR
		stw		r29, SC_STK_CTR(sp)		# save CTR
		
#
#------------------------------------------------------------------------
# SRR0 & SRR1 are now saved, so exceptions can be re-enabled now if     *
# need be.                                                              *
# Pick up "enable_mask" value and "or" it with the MSR, thus re-enabling*
# desired exceptions.                                                   *
#                                                                       *
# The value of MSR_IR and MSR_DR will be restored to the values         *
# prior to the exception.                                               *
#------------------------------------------------------------------------
        lis     r29, (MSR_IR|MSR_DR)@ha # restore MSR_IR & MSR_DR
        addi    r29, r29, (MSR_IR|MSR_DR)@l     # restore MSR_IR & MSR_DR
        and     r30, r30, r29           # restore MSR_IR & MSR_DR
        mfmsr   r29                     # r29: MSR
        or      r29, r29, r30           # 
#
        lwz     r30, V_ENABLE_MASK(r31)
        or      r29, r30, r29           # r29: MSR | V_ENABLE_MASK
        mtmsr   r29                     # store new MSR
        isync
#
#------------------------------------------------------------------------
# Finish filling in the stack frame: save CR and format/offset word.    *
# Then transfer control to the specified handler.                       *
#------------------------------------------------------------------------
        oris    r30, r31, 2             # r30: format (2) & vect offset
        lwz     r29, V_HANDLER(r31)     # r29-> handler
        stw     r30, SC_STK_VECTOR(sp)  # Save format/offset word
        mtlr    r29                     # LR-> handler
        blr                             # jump to handler


#Vector information. Vectors are 256 bytes long.
    V_CODE          =   0
    V_ENDCODE       =   184
    V_ENABLE_MASK   =   192
    V_HANDLER       =   196
    V_SAVE_AREA     =   200
    SC_STK_FRAME    =   -184
    SC_STK_LINK     =   0x00
    SC_STK_R0       =   (SC_STK_LINK + 16)
    SC_STK_R1       =   (SC_STK_R0 + 4)
    SC_STK_R2       =   (SC_STK_R1 + 4)
    SC_STK_R3       =   (SC_STK_R2 + 4)
    SC_STK_R4       =   (SC_STK_R3 + 4)
    SC_STK_R5       =   (SC_STK_R4 + 4)
    SC_STK_R6       =   (SC_STK_R5 + 4)
    SC_STK_R7       =   (SC_STK_R6 + 4)
    SC_STK_R8       =   (SC_STK_R7 + 4)
    SC_STK_R9       =   (SC_STK_R8 + 4)
    SC_STK_R10      =   (SC_STK_R9 + 4)
    SC_STK_R11      =   (SC_STK_R10 + 4)
    SC_STK_R12      =   (SC_STK_R11 + 4)
    SC_STK_R13      =   (SC_STK_R12 + 4)
    SC_STK_R14      =   (SC_STK_R13 + 4)
    SC_STK_R15      =   (SC_STK_R14 + 4)
    SC_STK_R16      =   (SC_STK_R15 + 4)
    SC_STK_R17      =   (SC_STK_R16 + 4)
    SC_STK_R18      =   (SC_STK_R17 + 4)
    SC_STK_R19      =   (SC_STK_R18 + 4)
    SC_STK_R20      =   (SC_STK_R19 + 4)
    SC_STK_R21      =   (SC_STK_R20 + 4)
    SC_STK_R22      =   (SC_STK_R21 + 4)
    SC_STK_R23      =   (SC_STK_R22 + 4)
    SC_STK_R24      =   (SC_STK_R23 + 4)
    SC_STK_R25      =   (SC_STK_R24 + 4)
    SC_STK_R26      =   (SC_STK_R25 + 4)
    SC_STK_R27      =   (SC_STK_R26 + 4)
    SC_STK_R28      =   (SC_STK_R27 + 4)
    SC_STK_R29      =   (SC_STK_R28 + 4)
    SC_STK_R30      =   (SC_STK_R29 + 4)
    SC_STK_R31      =   (SC_STK_R30 + 4)
    SC_STK_CR       =   (SC_STK_R31 + 4)
    SC_STK_MQ       =   (SC_STK_CR + 4)
    SC_STK_XER      =   (SC_STK_MQ + 4)
    SC_STK_LR       =   (SC_STK_XER + 4)
    SC_STK_CTR      =   (SC_STK_LR + 4)
    SC_STK_SRR0     =   (SC_STK_CTR + 4)
    SC_STK_SRR1     =   (SC_STK_SRR0 + 4)
    SC_STK_SRR2     =   (SC_STK_SRR1 + 4)
    SC_STK_SRR3     =   (SC_STK_SRR2 + 4)
    SC_STK_VECTOR       =   (SC_STK_SRR3 + 4)

# The stack pointer register.
    sp  =   r1

        .align 2
        .globl  interrupt_save_registers

interrupt_save_registers:
#------------------------------------------------------------------------
# r1,r29-31 already saved in vector code and have been changed          *
#------------------------------------------------------------------------
        stw     r0 , SC_STK_R0(sp)
        stw     r2 , SC_STK_R2(sp)
        stw     r3 , SC_STK_R3(sp)
        stw     r4 , SC_STK_R4(sp)
        stw     r5 , SC_STK_R5(sp)
        stw     r6 , SC_STK_R6(sp)
        stw     r7 , SC_STK_R7(sp)
        stw     r8 , SC_STK_R8(sp)
        stw     r9 , SC_STK_R9(sp)
        stw     r10, SC_STK_R10(sp)
        stw     r11, SC_STK_R11(sp)
        stw     r12, SC_STK_R12(sp)
        stw     r13, SC_STK_R13(sp)
        stw     r14, SC_STK_R14(sp)
        stw     r15, SC_STK_R15(sp)
        stw     r16, SC_STK_R16(sp)
        stw     r17, SC_STK_R17(sp)
        stw     r18, SC_STK_R18(sp)
        stw     r19, SC_STK_R19(sp)
        stw     r20, SC_STK_R20(sp)
        stw     r21, SC_STK_R21(sp)
        stw     r22, SC_STK_R22(sp)
        stw     r23, SC_STK_R23(sp)
        stw     r24, SC_STK_R24(sp)
        stw     r25, SC_STK_R25(sp)
        stw     r26, SC_STK_R26(sp)
        stw     r27, SC_STK_R27(sp)
        stw     r28, SC_STK_R28(sp)
        isync
        blr


        .align 2
        .globl  interrupt_restore_registers
#
interrupt_restore_registers:


        lwz     r0 , SC_STK_R0(sp)
        lwz     r2 , SC_STK_R2(sp)
        lwz     r3 , SC_STK_R3(sp)
        lwz     r4 , SC_STK_R4(sp)
        lwz     r5 , SC_STK_R5(sp)
        lwz     r6 , SC_STK_R6(sp)
        lwz     r7 , SC_STK_R7(sp)
        lwz     r8 , SC_STK_R8(sp)
        lwz     r9 , SC_STK_R9(sp)
        lwz     r10, SC_STK_R10(sp)
        lwz     r11, SC_STK_R11(sp)
        lwz     r12, SC_STK_R12(sp)
        lwz     r13, SC_STK_R13(sp)
        lwz     r14, SC_STK_R14(sp)
        lwz     r15, SC_STK_R15(sp)
        lwz     r16, SC_STK_R16(sp)
        lwz     r17, SC_STK_R17(sp)
        lwz     r18, SC_STK_R18(sp)
        lwz     r19, SC_STK_R19(sp)
        lwz     r20, SC_STK_R20(sp)
        lwz     r21, SC_STK_R21(sp)
        lwz     r22, SC_STK_R22(sp)
        lwz     r23, SC_STK_R23(sp)
        lwz     r24, SC_STK_R24(sp)
        lwz     r25, SC_STK_R25(sp)
        lwz     r26, SC_STK_R26(sp)
        lwz     r27, SC_STK_R27(sp)
        lwz     r28, SC_STK_R28(sp)
        lwz     r29, SC_STK_R29(sp)
        lwz     r30, SC_STK_R30(sp)

#************************************************************************
#       Use r31 as a swap reg to reload the SRR0, SRR1, CR, LR, then r31*
#************************************************************************
        lwz     r31,SC_STK_SRR0(sp)
        mtsrr0  r31

        lwz     r31,SC_STK_SRR1(sp)
        mtsrr1  r31

        lwz     r31,SC_STK_CR(sp)
        mtcr    r31

        lwz     r31,SC_STK_CTR(sp)
        mtctr   r31

        lwz     r31,SC_STK_XER(sp)
        mtxer   r31

        lwz     r31,SC_STK_LR(sp)
        mtlr    r31

        lwz     r31, SC_STK_R31(sp)

        subi    sp, sp, SC_STK_FRAME    # dealloc the stack frame

        isync
        rfi

