#-----------------------------------------------------------------------------+
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
#-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#  File Name:   ppcmal.s
#
#  Function:    405GP MAL register access functions.
#
#-------------------------------------------------------------------------------

# MAL Registers
.set MAL_DCR_BASE, 0x180

.set malmcr,   (MAL_DCR_BASE+0x00)    # MAL Config reg               
.set malesr,  (MAL_DCR_BASE+0x01)     # Error Status reg (Read/Clear)       
.set malier,  (MAL_DCR_BASE+0x02)     # Interrupt enable reg                
.set maldbr,  (MAL_DCR_BASE+0x03)     # Mal Debug reg (Read only)           
.set maltxcasr,  (MAL_DCR_BASE+0x04)  # TX Channel active reg (set)      
.set maltxcarr,  (MAL_DCR_BASE+0x05)  # TX Channel active reg (Reset)    
.set maltxeobisr, (MAL_DCR_BASE+0x06) # TX End of buffer int status reg 
.set maltxdeir,  (MAL_DCR_BASE+0x07)  # TX Descr. Error Int reg         
.set malrxcasr,  (MAL_DCR_BASE+0x10)  # RX Channel active reg (set)     
.set malrxcarr,  (MAL_DCR_BASE+0x11)  # RX Channel active reg (Reset)   
.set malrxeobisr, (MAL_DCR_BASE+0x12) # RX End of buffer int status reg 
.set malrxdeir,  (MAL_DCR_BASE+0x13)  # RX Descr. Error Int reg         
.set maltxctp0r, (MAL_DCR_BASE+0x20)  # TX 0 Channel table pointer reg  
.set maltxctp1r, (MAL_DCR_BASE+0x21)  # TX 1 Channel table pointer reg  
.set malrxctp0r, (MAL_DCR_BASE+0x40)  # RX 0 Channel table pointer reg  
.set malrcbs0,   (MAL_DCR_BASE+0x60)  # RX 0 Channel buffer size reg    

#-------------------------------------------------------------------------------
# Function:     ppcMtmalcr
# Description:  Move to MALMCR register
# Input:        r3 - new value of MALMCR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
	.align	2
        .globl  ppcMtmalcr
ppcMtmalcr:
	mtdcr	malmcr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalcr,@function
        .size  ppcMtmalcr,.-ppcMtmalcr

#-------------------------------------------------------------------------------
# Function:     ppcMfmalcr
# Description:  Move from MALMCR register
# Input:        none
# Output:       r3 - value of MALMCR.
#-------------------------------------------------------------------------------
        .text
	.align	2
        .globl  ppcMfmalcr
ppcMfmalcr:
	mfdcr	r3, malmcr
        blr

        .type  ppcMfmalcr,@function
        .size  ppcMfmalcr,.-ppcMfmalcr

#-------------------------------------------------------------------------------
# Function:     ppcMfmalesr
# Description:  Move from MALESR register
# Input:        none
# Output:       r3 - value of MALESR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalesr
ppcMfmalesr:
        mfdcr   r3,malesr
        nop
        nop
        nop
        blr

        .type  ppcMfmalesr,@function
        .size  ppcMfmalesr,.-ppcMfmalesr

#-------------------------------------------------------------------------------
# Function:     ppcMtmalesr
# Description:  Move to MALESR register
# Input:        r3 - new value of MALESR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalesr
ppcMtmalesr:
        mtdcr   malesr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalesr,@function
        .size  ppcMtmalesr,.-ppcMtmalesr

#-------------------------------------------------------------------------------
# Function:     ppcMfmalier
# Description:  Move from MALIER register
# Input:        none
# Output:       r3 - value of MALIER.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalier
ppcMfmalier:
        mfdcr   r3,malier
        nop
        nop
        nop
        blr

        .type  ppcMfmalier,@function
        .size  ppcMfmalier,.-ppcMfmalier

#-------------------------------------------------------------------------------
# Function:     ppcMtmalier
# Description:  Move to MALIER register
# Input:        r3 - new value of MALIER.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalier
ppcMtmalier:
        mtdcr   malier,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalier,@function
        .size  ppcMtmalier,.-ppcMtmalier


#-------------------------------------------------------------------------------
# Function:     ppcMfmaldbr
# Description:  Move from MALDBR register
# Input:        none
# Output:       r3 - value of MALDBR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmaldbr
ppcMfmaldbr:
        mfdcr   r3,maldbr
        nop
        nop
        nop
        blr

        .type  ppcMfmaldbr,@function
        .size  ppcMfmaldbr,.-ppcMfmaldbr

#-------------------------------------------------------------------------------
# Function:     ppcMfmaltxcasr
# Description:  Move from MALTXCASR register
# Input:        none
# Output:       r3 - value of MALTXCASR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmaltxcasr
ppcMfmaltxcasr:
        mfdcr   r3,maltxcasr
        nop
        nop
        nop
        blr

        .type  ppcMfmaltxcasr,@function
        .size  ppcMfmaltxcasr,.-ppcMfmaltxcasr

#-------------------------------------------------------------------------------
# Function:     ppcMtmaltxcasr
# Description:  Move to MALTXCASR register
# Input:        r3 - new value of MALTXCASR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmaltxcasr
ppcMtmaltxcasr:
        mtdcr   maltxcasr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmaltxcasr,@function
        .size  ppcMtmaltxcasr,.-ppcMtmaltxcasr

#-------------------------------------------------------------------------------
# Function:     ppcMfmaltxcarr
# Description:  Move from MALTXCARR register
# Input:        none
# Output:       r3 - value of MALTXCARR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmaltxcarr
ppcMfmaltxcarr:
        mfdcr   r3,maltxcarr
        nop
        nop
        nop
        blr

        .type  ppcMfmaltxcarr,@function
        .size  ppcMfmaltxcarr,.-ppcMfmaltxcarr

#-------------------------------------------------------------------------------
# Function:     ppcMtmaltxcarr
# Description:  Move to MALTXCARR register
# Input:        r3 - new value of MALTXCARR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmaltxcarr
ppcMtmaltxcarr:
        mtdcr   maltxcarr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmaltxcarr,@function
        .size  ppcMtmaltxcarr,.-ppcMtmaltxcarr


#-------------------------------------------------------------------------------
# Function:     ppcMfmaltxeobisr
# Description:  Move from MALTXEOBISR register
# Input:        none
# Output:       r3 - value of MALTXEOBISR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmaltxeobisr
ppcMfmaltxeobisr:
        mfdcr   r3,maltxeobisr
        nop
        nop
        nop
        blr

        .type  ppcMfmaltxeobisr,@function
        .size  ppcMfmaltxeobisr,.-ppcMfmaltxeobisr


#-------------------------------------------------------------------------------
# Function:     ppcMtmaltxeobisr
# Description:  Move to MALTXEOBISR register
# Input:        r3 - new value of MALTXEOBISR register
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmaltxeobisr
ppcMtmaltxeobisr:
        mtdcr   maltxeobisr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmaltxeobisr,@function
        .size  ppcMtmaltxeobisr,.-ppcMtmaltxeobisr


#-------------------------------------------------------------------------------
# Function:     ppcMfmaltxdeir  
# Description:  Move from MALTXDEIR register
# Input:        none
# Output:       r3 - value of MALTXDEIR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmaltxdeir  
ppcMfmaltxdeir:
        mfdcr   r3,maltxdeir
        nop
        nop
        nop
        blr

        .type  ppcMfmaltxdeir,@function
        .size  ppcMfmaltxdeir,.-ppcMfmaltxdeir

#-------------------------------------------------------------------------------
# Function:     ppcMtmaltxdeir
# Description:  Move to MALTXDEIR register
# Input:        r3 - new value of MALTXDEIR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmaltxdeir
ppcMtmaltxdeir:
        mtdcr   maltxdeir,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmaltxdeir,@function
        .size  ppcMtmaltxdeir,.-ppcMtmaltxdeir

#-------------------------------------------------------------------------------
# Function:     ppcMfmalrxcasr
# Description:  Move from MALRXCASR register
# Input:        none
# Output:       r3 - value of MALRXCASR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalrxcasr
ppcMfmalrxcasr:
        mfdcr   r3,malrxcasr
        nop
        nop
        nop
        blr

        .type  ppcMfmalrxcasr,@function
        .size  ppcMfmalrxcasr,.-ppcMfmalrxcasr

#-------------------------------------------------------------------------------
# Function:     ppcMtmalrxcasr
# Description:  Move to MALRXCASR register
# Input:        r3 - new value of MALRXCASR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalrxcasr
ppcMtmalrxcasr:
        mtdcr   malrxcasr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalrxcasr,@function
        .size  ppcMtmalrxcasr,.-ppcMtmalrxcasr

#-------------------------------------------------------------------------------
# Function:     ppcMfmalrxcarr
# Description:  Move from MALRXCARR register
# Input:        none
# Output:       r3 - value of MALRXCARR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalrxcarr
ppcMfmalrxcarr:
        mfdcr   r3,malrxcarr
        nop
        nop
        nop
        blr

        .type  ppcMfmalrxcarr,@function
        .size  ppcMfmalrxcarr,.-ppcMfmalrxcarr

#-------------------------------------------------------------------------------
# Function:     ppcMtmalrxcarr
# Description:  Move to MALRXCARR register
# Input:        r3 - new value of MALRXCARR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalrxcarr
ppcMtmalrxcarr:
        mtdcr   malrxcarr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalrxcarr,@function
        .size  ppcMtmalrxcarr,.-ppcMtmalrxcarr

#-------------------------------------------------------------------------------
# Function:     ppcMfmalrxeobisr
# Description:  Move from MALRXEOBISR register
# Input:        none
# Output:       r3 - value of MALRXEOBISR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalrxeobisr
ppcMfmalrxeobisr:
        mfdcr   r3,malrxeobisr
        nop
        nop
        nop
        blr

        .type  ppcMfmalrxeobisr,@function
        .size  ppcMfmalrxeobisr,.-ppcMfmalrxeobisr

#-------------------------------------------------------------------------------
# Function:     ppcMtmalrxeobisr
# Description:  Move to MALRXEOBISR register
# Input:        r3 - new value of MALRXEOBISR register
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalrxeobisr
ppcMtmalrxeobisr:
        mtdcr   malrxeobisr,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalrxeobisr,@function
        .size  ppcMtmalrxeobisr,.-ppcMtmalrxeobisr


#-------------------------------------------------------------------------------
# Function:     ppcMfmalrxdeir
# Description:  Move from MALRXDEIR register
# Input:        none
# Output:       r3 - value of MALRXDEIR.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalrxdeir
ppcMfmalrxdeir:
        mfdcr   r3,malrxdeir
        nop
        nop
        nop
        blr

        .type  ppcMfmalrxdeir,@function
        .size  ppcMfmalrxdeir,.-ppcMfmalrxdeir

#-------------------------------------------------------------------------------
# Function:     ppcMtmalrxdeir
# Description:  Move to MALRXDEIR register
# Input:        r3 - new value of MALRXDEIR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalrxdeir
ppcMtmalrxdeir:
        mtdcr   malrxdeir,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalrxdeir,@function
        .size  ppcMtmalrxdeir,.-ppcMtmalrxdeir


#-------------------------------------------------------------------------------
# Function:     ppcMfmaltxctp0r
# Description:  Move from MALTXCTP0R register
# Input:        none
# Output:       r3 - value of MALTXCTP0R.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmaltxctp0r
ppcMfmaltxctp0r:
        mfdcr   r3,maltxctp0r
        nop
        nop
        nop
        blr

        .type  ppcMfmaltxctp0r,@function
        .size  ppcMfmaltxctp0r,.-ppcMfmaltxctp0r

#-------------------------------------------------------------------------------
# Function:     ppcMtmaltxctp0r
# Description:  Move to MALTXCTP0R register
# Input:        r3 - new value of MALTXCTP0R.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmaltxctp0r
ppcMtmaltxctp0r:
        mtdcr   maltxctp0r,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmaltxctp0r,@function
        .size  ppcMtmaltxctp0r,.-ppcMtmaltxctp0r

#-------------------------------------------------------------------------------
# Function:     ppcMfmaltxctp1r
# Description:  Move from MALTXCTP1R register
# Input:        none
# Output:       r3 - value of MALTXCTP1R.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmaltxctp1r
ppcMfmaltxctp1r:
        mfdcr   r3,maltxctp1r
        nop
        nop
        nop
        blr

        .type  ppcMfmaltxctp1r,@function
        .size  ppcMfmaltxctp1r,.-ppcMfmaltxctp1r

#-------------------------------------------------------------------------------
# Function:     ppcMtmaltxctp1r
# Description:  Move to MALTXCTP1R register
# Input:        r3 - new value of MALTXCTP1R.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmaltxctp1r
ppcMtmaltxctp1r:
        mtdcr   maltxctp1r,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmaltxctp1r,@function
        .size  ppcMtmaltxctp1r,.-ppcMtmaltxctp1r

#-------------------------------------------------------------------------------
# Function:     ppcMfmalrxctp0r
# Description:  Move from MALRXCTP0R register
# Input:        none
# Output:       r3 - value of MALRXCTP0R.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalrxctp0r
ppcMfmalrxctp0r:
        mfdcr   r3,malrxctp0r
        nop
        nop
        nop
        blr

        .type  ppcMfmalrxctp0r,@function
        .size  ppcMfmalrxctp0r,.-ppcMfmalrxctp0r

#-------------------------------------------------------------------------------
# Function:     ppcMtmalrxctp0r
# Description:  Move to MALRXCTP0R register
# Input:        r3 - new value of MALRXCTP0R.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalrxctp0r
ppcMtmalrxctp0r:
        mtdcr   malrxctp0r,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalrxctp0r,@function
        .size  ppcMtmalrxctp0r,.-ppcMtmalrxctp0r

#-------------------------------------------------------------------------------
# Function:     ppcMfmalrcbs0  
# Description:  Move from MALRCBS0 register
# Input:        none
# Output:       r3 - value of MALRCBS0.
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfmalrcbs0
ppcMfmalrcbs0:
        mfdcr   r3,malrcbs0
        nop
        nop
        nop
        blr

        .type  ppcMfmalrcbs0,@function
        .size  ppcMfmalrcbs0,.-ppcMfmalrcbs0

#-------------------------------------------------------------------------------
# Function:     ppcMtmalrcbs0
# Description:  Move to MALRCBS0 register
# Input:        r3 - new value of MALRCBS0.
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtmalrcbs0
ppcMtmalrcbs0:
        mtdcr   malrcbs0,r3
        nop
        nop
        nop
        blr

        .type  ppcMtmalrcbs0,@function
        .size  ppcMtmalrcbs0,.-ppcMtmalrcbs0

