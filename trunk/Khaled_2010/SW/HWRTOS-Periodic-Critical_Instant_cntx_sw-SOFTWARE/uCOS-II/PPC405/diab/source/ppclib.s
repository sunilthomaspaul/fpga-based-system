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
#  File Name:   ppclib.s
#
#  Function:    PowerPC Book 1 architected instructions 
#
#-------------------------------------------------------------------------------
	.include "p405.inc" 
	.include "board.inc"

#-------------------------------------------------------------------------------
# Function:     ppcAbend
# Description:  Execute an invalid op code, causing a Program Check Interrupt
# Input:        none
# Output:       none
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcAbend
ppcAbend:
        .long   0

	.type ppcAbend,@function
	.size ppcAbend,.-ppcAbend

#-------------------------------------------------------------------------------
# Function:     ppcAndMsr
# Description:  AND With Machine State Register (MSR)
# Input:        r3 = value to AND with MSR
# Output:       r3 = old MSR contents
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcAndMsr
ppcAndMsr:
        mfmsr   r6
        and     r7,r6,r3
        mtmsr   r7
        ori     r3,r6,0x000
        blr

	.type ppcAndMsr,@function
	.size ppcAndMsr,.-ppcAndMsr

#-------------------------------------------------------------------------------
# Function:     ppcCntlzw
# Description:  Count Leading Zeros
# Input:        r3 = input value
# Output:       r3 = number of leading zeroes in the input value
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcCntlzw
ppcCntlzw:
        cntlzw  r3,r3
        blr

	.type ppcCntlzw,@function
	.size ppcCntlzw,.-ppcCntlzw

#-------------------------------------------------------------------------------
# Function:     ppcDcbi
# Description:  Data Cache block Invalidate
# Input:        r3 = effective address
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcDcbi
ppcDcbi:
        dcbi    r0,r3
        blr

	.type ppcDcbi,@function
	.size ppcDcbi,.-ppcDcbi

#-------------------------------------------------------------------------------
# Function:     ppcDcbf
# Description:  Data Cache block flush
# Input:        r3 = effective address
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcDcbf
ppcDcbf:
        dcbf    r0,r3
        blr

	.type ppcDcbf,@function
	.size ppcDcbf,.-ppcDcbf

#-------------------------------------------------------------------------------
# Function:     ppcDcbst
# Description:  Data Cache block Store
# Input:        r3 = effective address
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcDcbst
ppcDcbst:
        dcbst   r0,r3
        blr

	.type ppcDcbst,@function
	.size ppcDcbst,.-ppcDcbst

#-------------------------------------------------------------------------------
# Function:     ppcDcbz
# Description:  Data Cache Block set to Zero
# Input:        r3 = effective address
# Output:       none.
#-------------------------------------------------------------------------------
#ifndef PASS1_405GP
	.text
        .align  2
	.globl	ppcDcbz
ppcDcbz:
        dcbz    r0,r3
        blr

	.type ppcDcbz,@function
	.size ppcDcbz,.-ppcDcbz
#endif

#-------------------------------------------------------------------------------
# Function:     ppcHalt
# Description:  Halt Pseudo-Op
# Input:        none.
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcHalt
ppcHalt:
        addis   r3,0,0		# Init TCR to WP = 2^17 clks, no WD reset, all ints disabled
        ori     r3,r3,0
        mtspr   tcr,r3
ppcHaltloop:
        b       ppcHaltloop	# loop forever

	.type ppcHalt,@function
	.size ppcHalt,.-ppcHalt

#-------------------------------------------------------------------------------
# Function:     ppcIsync
# Description:  Instruction Cache Synchronize
# Input:        none.
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcIsync 
ppcIsync:
        isync
        blr

	.type ppcIsync,@function
	.size ppcIsync,.-ppcIsync

#-------------------------------------------------------------------------------
# Function:     ppcIcbi 
# Description:  Instruction Cache Block Invalidate
# Input:        r3 = effective address
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcIcbi
ppcIcbi:
        icbi    r0,r3
        blr

	.type ppcIcbi,@function
	.size ppcIcbi,.-ppcIcbi


#-------------------------------------------------------------------------------
# Function:     ppcMfmsr
# Description:  Move From Machine State Register
# Input:        none
# Output:       r3 = msr
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfmsr
ppcMfmsr:
        mfmsr   r3
        blr

	.type ppcMfmsr,@function
	.size ppcMfmsr,.-ppcMfmsr

#-------------------------------------------------------------------------------
# Function:     ppcMfsprg0
# Description:  Move From SPRG0
# Input:        none
# Output:       r3 = sprg0
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfsprg0
ppcMfsprg0:
	mfspr	r3,sprg0
	blr

	.type ppcMfsprg0,@function
	.size ppcMfsprg0,.-ppcMfsprg0

#-------------------------------------------------------------------------------
# Function:     ppcMfsprg1
# Description:  Move From SPRG1
# Input:        none
# Output:       r3 = sprg1
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfsprg1
ppcMfsprg1:
	mfspr	r3,sprg1
	blr

	.type ppcMfsprg1,@function
	.size ppcMfsprg1,.-ppcMfsprg1

#-------------------------------------------------------------------------------
# Function:     ppcMfsprg2
# Description:  Move From SPRG2
# Input:        none
# Output:       r3 = sprg2
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfsprg2
ppcMfsprg2:
	mfspr	r3,sprg2
	blr

	.type ppcMfsprg2,@function
	.size ppcMfsprg2,.-ppcMfsprg2

#-------------------------------------------------------------------------------
# Function:     ppcMfsprg3
# Description:  Move From SPRG3
# Input:        none
# Output:       r3 = sprg3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfsprg3
ppcMfsprg3:
	mfspr	r3,sprg3
	blr

	.type ppcMfsprg3,@function
	.size ppcMfsprg3,.-ppcMfsprg3

#-------------------------------------------------------------------------------
# Function:     ppcMfsrr0
# Description:  Move From SRR0
# Input:        none
# Output:       r3 = srr0
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfsrr0
ppcMfsrr0:
        mfsrr0  r3
        blr

	.type ppcMfsrr0,@function
	.size ppcMfsrr0,.-ppcMfsrr0

#-------------------------------------------------------------------------------
# Function:     ppcMfsrr1
# Description:  Move From SRR1
# Input:        none
# Output:       r3 = srr1
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfsrr1
ppcMfsrr1:
        mfsrr1  r3
        blr

	.type ppcMfsrr1,@function
	.size ppcMfsrr1,.-ppcMfsrr1

#-------------------------------------------------------------------------------
# Function:     ppcMfpvr
# Description:  Move From PVR
# Input:        none
# Output:       r3 = tid
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfpvr
ppcMfpvr:
        mfpvr   r3
        blr

	.type ppcMfpvr,@function
	.size ppcMfpvr,.-ppcMfpvr

#-------------------------------------------------------------------------------
# Function:     ppcMtmsr
# Description:  Move To Machine State Register
# Input:        none
# Output:       r3 = msr
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtmsr
ppcMtmsr:
        mtmsr   r3
        blr

	.type ppcMtmsr,@function
	.size ppcMtmsr,.-ppcMtmsr

#-------------------------------------------------------------------------------
# Function:	ppcMtsprg0
# Description:	Move To SPRG0
# Input:	r3 = value to be moved to sprg0
# Output:	none
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtsprg0
ppcMtsprg0:
	mtspr	sprg0,r3
	blr

	.type ppcMtsprg0,@function
	.size ppcMtsprg0,.-ppcMtsprg0

#-------------------------------------------------------------------------------
# Function:	ppcMtsprg1
# Description:	Move To SPRG1
# Input:	r3 = value to be moved to sprg1
# Output:	none
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtsprg1
ppcMtsprg1:
	mtspr	sprg1,r3
	blr

	.type ppcMtsprg1,@function
	.size ppcMtsprg1,.-ppcMtsprg1

#-------------------------------------------------------------------------------
# Function:	ppcMtsprg2
# Description:	Move To SPRG2
# Input:	r3 = value to be moved to sprg2
# Output:	none
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtsprg2
ppcMtsprg2:
	mtspr	sprg2,r3
	blr

	.type ppcMtsprg2,@function
	.size ppcMtsprg2,.-ppcMtsprg2

#-------------------------------------------------------------------------------
# Function:	ppcMtsprg3
# Description:	Move To SPRG3
# Input:	r3 = value to be moved to sprg3
# Output:	none
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtsprg3
ppcMtsprg3:
	mtspr	sprg3,r3
	blr

	.type ppcMtsprg3,@function
	.size ppcMtsprg3,.-ppcMtsprg3

#-------------------------------------------------------------------------------
# Function:     ppcMtsrr0
# Description:  Move To SRR0
# Input:        r3 = value to be moved to SRR0
# Output:       none
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtsrr0
ppcMtsrr0:
        mtsrr0  r3
        blr

	.type ppcMtsrr0,@function
	.size ppcMtsrr0,.-ppcMtsrr0

#-------------------------------------------------------------------------------
# Function:     ppcMtsrr1
# Description:  Move To SRR1
# Input:        r3 = value to be moved to SRR1
# Output:       none
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtsrr1
ppcMtsrr1:
        mtsrr1  r3
        blr

	.type ppcMtsrr1,@function
	.size ppcMtsrr1,.-ppcMtsrr1

#-------------------------------------------------------------------------------
# Function:     ppcOrMsr
# Description:  OR With Machine State Register (MSR)
# Input:        r3 = value to OR with MSR
# Output:       r3 = old MSR contents
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcOrMsr
ppcOrMsr:
        mfmsr   r6
        or      r7,r6,r3
        mtmsr   r7
        ori     r3,r6,0x0000
        blr

	.type ppcOrMsr,@function
	.size ppcOrMsr,.-ppcOrMsr

#-------------------------------------------------------------------------------
# Function:     ppcSync
# Description:  Processor Synchronize
# Input:        none.
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcSync
ppcSync:
        sync
        blr

	.type ppcSync,@function
	.size ppcSync,.-ppcSync

#-------------------------------------------------------------------------------
# Function:     ppcEieio
# Description:  Enforce in-order execution of I/O
# Input:        none.
# Output:       none.
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcEieio
ppcEieio:
        eieio
        blr

	.type ppcEieio,@function
	.size ppcEieio,.-ppcEieio

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr0
# Description:  Move From gpr0
# Input:        none
# Output:       r3 = gpr0
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr0
ppcMfgpr0:
        ori     r3,r0,0x0000
        blr

	.type ppcMfgpr0,@function
	.size ppcMfgpr0,.-ppcMfgpr0

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr1
# Description:  Move From gpr1
# Input:        none
# Output:       r3 = gpr1
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr1
ppcMfgpr1:
        ori     r3,r1,0x0000
        blr

	.type ppcMfgpr1,@function
	.size ppcMfgpr1,.-ppcMfgpr1

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr2
# Description:  Move From gpr2
# Input:        none
# Output:       r3 = gpr2
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr2
ppcMfgpr2:
        ori     r3,r2,0x0000
        blr

	.type ppcMfgpr2,@function
	.size ppcMfgpr2,.-ppcMfgpr2

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr3
# Description:  Move From gpr3
# Input:        none
# Output:       r3 = gpr3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr3
ppcMfgpr3:
        ori     r3,r3,0x0000
        blr

	.type ppcMfgpr3,@function
	.size ppcMfgpr3,.-ppcMfgpr3

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr4
# Description:  Move From gpr4
# Input:        none
# Output:       r3 = gpr4
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr4
ppcMfgpr4:
        ori     r3,r4,0x0000
        blr

	.type ppcMfgpr4,@function
	.size ppcMfgpr4,.-ppcMfgpr4

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr5
# Description:  Move From gpr5
# Input:        none
# Output:       r3 = gpr5
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr5
ppcMfgpr5:
        ori     r3,r5,0x0000
        blr

	.type ppcMfgpr5,@function
	.size ppcMfgpr5,.-ppcMfgpr5


#-------------------------------------------------------------------------------
# Function:     ppcMfgpr6
# Description:  Move From gpr6
# Input:        none
# Output:       r3 = gpr6
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr6
ppcMfgpr6:
        ori     r3,r6,0x0000
        blr

	.type ppcMfgpr6,@function
	.size ppcMfgpr6,.-ppcMfgpr6

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr7
# Description:  Move From gpr7
# Input:        none
# Output:       r3 = gpr7
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr7
ppcMfgpr7:
        ori     r3,r7,0x0000
        blr

	.type ppcMfgpr7,@function
	.size ppcMfgpr7,.-ppcMfgpr7

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr8
# Description:  Move From gpr8
# Input:        none
# Output:       r3 = gpr8
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr8
ppcMfgpr8:
        ori     r3,r8,0x0000
        blr

	.type ppcMfgpr8,@function
	.size ppcMfgpr8,.-ppcMfgpr8

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr9
# Description:  Move From gpr9
# Input:        none
# Output:       r3 = gpr9
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr9
ppcMfgpr9:
        ori     r3,r9,0x0000
        blr

	.type ppcMfgpr9,@function
	.size ppcMfgpr9,.-ppcMfgpr9


#-------------------------------------------------------------------------------
# Function:     ppcMfgpr10
# Description:  Move From gpr10
# Input:        none
# Output:       r3 = gpr10
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr10
ppcMfgpr10:
        ori     r3,r10,0x0000
        blr

	.type ppcMfgpr10,@function
	.size ppcMfgpr10,.-ppcMfgpr10

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr11
# Description:  Move From gpr11
# Input:        none
# Output:       r3 = gpr11
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr11
ppcMfgpr11:
        ori     r3,r11,0x0000
        blr

	.type ppcMfgpr11,@function
	.size ppcMfgpr11,.-ppcMfgpr11

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr12
# Description:  Move From gpr12
# Input:        none
# Output:       r3 = gpr12
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr12
ppcMfgpr12:
        ori     r3,r12,0x0000
        blr

	.type ppcMfgpr12,@function
	.size ppcMfgpr12,.-ppcMfgpr12

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr13
# Description:  Move From gpr13
# Input:        none
# Output:       r3 = gpr13
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr13
ppcMfgpr13:
        ori     r3,r13,0x0000
        blr

	.type ppcMfgpr13,@function
	.size ppcMfgpr13,.-ppcMfgpr13

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr14
# Description:  Move From gpr14
# Input:        none
# Output:       r3 = gpr14
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr14
ppcMfgpr14:
        ori     r3,r14,0x0000
        blr

	.type ppcMfgpr14,@function
	.size ppcMfgpr14,.-ppcMfgpr14
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr15
# Description:  Move From gpr15
# Input:        none
# Output:       r3 = gpr15
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr15
ppcMfgpr15:
        ori     r3,r15,0x0000
        blr

	.type ppcMfgpr15,@function
	.size ppcMfgpr15,.-ppcMfgpr15
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr16
# Description:  Move From gpr16
# Input:        none
# Output:       r3 = gpr16
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr16
ppcMfgpr16:
        ori     r3,r16,0x0000
        blr

	.type ppcMfgpr16,@function
	.size ppcMfgpr16,.-ppcMfgpr16
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr17
# Description:  Move From gpr17
# Input:        none
# Output:       r3 = gpr17
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr17
ppcMfgpr17:
        ori     r3,r17,0x0000
        blr

	.type ppcMfgpr17,@function
	.size ppcMfgpr17,.-ppcMfgpr17
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr18
# Description:  Move From gpr18
# Input:        none
# Output:       r3 = gpr18
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr18
ppcMfgpr18:
        ori     r3,r18,0x0000
        blr

	.type ppcMfgpr18,@function
	.size ppcMfgpr18,.-ppcMfgpr18
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr19
# Description:  Move From gpr19
# Input:        none
# Output:       r3 = gpr19
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr19
ppcMfgpr19:
        ori     r3,r19,0x0000
        blr

	.type ppcMfgpr19,@function
	.size ppcMfgpr19,.-ppcMfgpr19

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr20
# Description:  Move From gpr20
# Input:        none
# Output:       r3 = gpr20
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr20
ppcMfgpr20:
        ori     r3,r20,0x0000
        blr

	.type ppcMfgpr20,@function
	.size ppcMfgpr20,.-ppcMfgpr20

#-------------------------------------------------------------------------------
# Function:     ppcMfgpr21
# Description:  Move From gpr21
# Input:        none
# Output:       r3 = gpr21
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr21
ppcMfgpr21:
        ori     r3,r21,0x0000
        blr

	.type ppcMfgpr21,@function
	.size ppcMfgpr21,.-ppcMfgpr21
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr22
# Description:  Move From gpr22
# Input:        none
# Output:       r3 = gpr22
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr22
ppcMfgpr22:
        ori     r3,r22,0x0000
        blr

	.type ppcMfgpr22,@function
	.size ppcMfgpr22,.-ppcMfgpr22
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr23
# Description:  Move From gpr23
# Input:        none
# Output:       r3 = gpr23
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr23
ppcMfgpr23:
        ori     r3,r23,0x0000
        blr

	.type ppcMfgpr23,@function
	.size ppcMfgpr23,.-ppcMfgpr23
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr24
# Description:  Move From gpr24
# Input:        none
# Output:       r3 = gpr24
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr24
ppcMfgpr24:
        ori     r3,r24,0x0000
        blr

	.type ppcMfgpr24,@function
	.size ppcMfgpr24,.-ppcMfgpr24
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr25
# Description:  Move From gpr25
# Input:        none
# Output:       r3 = gpr25
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr25
ppcMfgpr25:
        ori     r3,r25,0x0000
        blr

	.type ppcMfgpr25,@function
	.size ppcMfgpr25,.-ppcMfgpr25
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr26
# Description:  Move From gpr26
# Input:        none
# Output:       r3 = gpr26
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr26
ppcMfgpr26:
        ori     r3,r26,0x0000
        blr

	.type ppcMfgpr26,@function
	.size ppcMfgpr26,.-ppcMfgpr26
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr27
# Description:  Move From gpr27
# Input:        none
# Output:       r3 = gpr27
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr27
ppcMfgpr27:
        ori     r3,r27,0x0000
        blr

	.type ppcMfgpr27,@function
	.size ppcMfgpr27,.-ppcMfgpr27
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr28
# Description:  Move From gpr28
# Input:        none
# Output:       r3 = gpr28
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr28
ppcMfgpr28:
        ori     r3,r28,0x0000
        blr

	.type ppcMfgpr28,@function
	.size ppcMfgpr28,.-ppcMfgpr28
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr29
# Description:  Move From gpr29
# Input:        none
# Output:       r3 = gpr29
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr29
ppcMfgpr29:
        ori     r3,r29,0x0000
        blr

	.type ppcMfgpr29,@function
	.size ppcMfgpr29,.-ppcMfgpr29
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr30
# Description:  Move From gpr30
# Input:        none
# Output:       r3 = gpr30
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr30
ppcMfgpr30:
        ori     r3,r30,0x0000
        blr

	.type ppcMfgpr30,@function
	.size ppcMfgpr30,.-ppcMfgpr30
#-------------------------------------------------------------------------------
# Function:     ppcMfgpr31
# Description:  Move From gpr31
# Input:        none
# Output:       r3 = gpr31
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMfgpr31
ppcMfgpr31:
        ori     r3,r31,0x0000
        blr

	.type ppcMfgpr31,@function
	.size ppcMfgpr31,.-ppcMfgpr31

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr0
# Description:  Move to gpr0
# Input:        none
# Output:       gpr0=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMtgpr0
ppcMtgpr0:
        ori     r0,r3,0x0000
        blr

        .type ppcMtgpr0,@function
        .size ppcMtgpr0,.-ppcMtgpr0


#-------------------------------------------------------------------------------
# Function:     ppcMtgpr1
# Description:  Move to gpr1
# Input:        none
# Output:       gpr1=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMtgpr1
ppcMtgpr1:
        ori     r1,r3,0x0000
        blr

        .type ppcMtgpr1,@function
        .size ppcMtgpr1,.-ppcMtgpr1

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr2
# Description:  Move to gpr2
# Input:        none
# Output:       gpr2=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMtgpr2
ppcMtgpr2:
        ori     r2,r3,0x0000
        blr

        .type ppcMtgpr2,@function
        .size ppcMtgpr2,.-ppcMtgpr2
#-------------------------------------------------------------------------------
# Function:     ppcMtgpr3
# Description:  Move to gpr3
# Input:        none
# Output:       gpr3=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMtgpr3
ppcMtgpr3:
        ori     r3,r3,0x0000
        blr

        .type ppcMtgpr3,@function
        .size ppcMtgpr3,.-ppcMtgpr3
#-------------------------------------------------------------------------------
# Function:     ppcMtgpr4
# Description:  Move to gpr4
# Input:        none
# Output:       gpr4=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMtgpr4
ppcMtgpr4:
        ori     r4,r3,0x0000
        blr

        .type ppcMtgpr4,@function
        .size ppcMtgpr4,.-ppcMtgpr4
#-------------------------------------------------------------------------------
# Function:     ppcMtgpr5
# Description:  Move to gpr5
# Input:        none
# Output:       gpr5=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMtgpr5
ppcMtgpr5:
        ori     r5,r3,0x0000
        blr

        .type ppcMtgpr5,@function
        .size ppcMtgpr5,.-ppcMtgpr5

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr6
# Description:  Move to gpr6
# Input:        none
# Output:       gpr6=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr6
ppcMtgpr6:
        ori     r6,r3,0x0000
        blr

	.type ppcMtgpr6,@function
	.size ppcMtgpr6,.-ppcMtgpr6


#-------------------------------------------------------------------------------
# Function:     ppcMtgpr7
# Description:  Move to gpr7
# Input:        none
# Output:       gpr7=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr7
ppcMtgpr7:
        ori     r7,r3,0x0000
        blr

	.type ppcMtgpr7,@function
	.size ppcMtgpr7,.-ppcMtgpr7

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr8
# Description:  Move to gpr8
# Input:        none
# Output:       gpr8=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr8
ppcMtgpr8:
        ori     r8,r3,0x0000
        blr

	.type ppcMtgpr8,@function
	.size ppcMtgpr8,.-ppcMtgpr8

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr9
# Description:  Move to gpr9
# Input:        none
# Output:       gpr9=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr9
ppcMtgpr9:
        ori     r9,r3,0x0000
        blr

	.type ppcMtgpr9,@function
	.size ppcMtgpr9,.-ppcMtgpr9

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr10
# Description:  Move to gpr10
# Input:        none
# Output:       gpr10=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr10
ppcMtgpr10:
        ori     r10,r3,0x0000
        blr

	.type ppcMtgpr10,@function
	.size ppcMtgpr10,.-ppcMtgpr10

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr11
# Description:  Move to gpr11
# Input:        none
# Output:       gpr11=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr11
ppcMtgpr11:
        ori     r11,r3,0x0000
        blr

	.type ppcMtgpr11,@function
	.size ppcMtgpr11,.-ppcMtgpr11

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr12
# Description:  Move to gpr12
# Input:        none
# Output:       gpr12=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr12
ppcMtgpr12:
        ori     r12,r3,0x0000
        blr

	.type ppcMtgpr12,@function
	.size ppcMtgpr12,.-ppcMtgpr12

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr13
# Description:  Move to gpr13
# Input:        none
# Output:       gpr13=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr13
ppcMtgpr13:
        ori     r13,r3,0x0000
        blr

	.type ppcMtgpr13,@function
	.size ppcMtgpr13,.-ppcMtgpr13

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr14
# Description:  Move to gpr14
# Input:        none
# Output:       gpr14=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr14
ppcMtgpr14:
        ori     r14,r3,0x0000
        blr

	.type ppcMtgpr14,@function
	.size ppcMtgpr14,.-ppcMtgpr14

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr15
# Description:  Move to gpr15
# Input:        none
# Output:       gpr15=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr15
ppcMtgpr15:
        ori     r15,r3,0x0000
        blr

	.type ppcMtgpr15,@function
	.size ppcMtgpr15,.-ppcMtgpr15

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr16
# Description:  Move to gpr16
# Input:        none
# Output:       gpr16=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr16
ppcMtgpr16:
        ori     r16,r3,0x0000
        blr

	.type ppcMtgpr16,@function
	.size ppcMtgpr16,.-ppcMtgpr16

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr17
# Description:  Move to gpr17
# Input:        none
# Output:       gpr17=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr17
ppcMtgpr17:
        ori     r17,r3,0x0000
        blr

	.type ppcMtgpr17,@function
	.size ppcMtgpr17,.-ppcMtgpr17

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr18
# Description:  Move to gpr18
# Input:        none
# Output:       gpr18=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr18
ppcMtgpr18:
        ori     r18,r3,0x0000
        blr

	.type ppcMtgpr18,@function
	.size ppcMtgpr18,.-ppcMtgpr18

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr19
# Description:  Move to gpr19
# Input:        none
# Output:       gpr19=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr19
ppcMtgpr19:
        ori     r19,r3,0x0000
        blr

	.type ppcMtgpr19,@function
	.size ppcMtgpr19,.-ppcMtgpr19

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr20
# Description:  Move to gpr20
# Input:        none
# Output:       gpr20=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr20
ppcMtgpr20:
        ori     r20,r3,0x0000
        blr

	.type ppcMtgpr20,@function
	.size ppcMtgpr20,.-ppcMtgpr20

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr21
# Description:  Move to gpr21
# Input:        none
# Output:       gpr21=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr21
ppcMtgpr21:
        ori     r21,r3,0x0000
        blr

	.type ppcMtgpr21,@function
	.size ppcMtgpr21,.-ppcMtgpr21

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr22
# Description:  Move to gpr22
# Input:        none
# Output:       gpr22=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr22
ppcMtgpr22:
        ori     r22,r3,0x0000
        blr

	.type ppcMtgpr22,@function
	.size ppcMtgpr22,.-ppcMtgpr22

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr23
# Description:  Move to gpr23
# Input:        none
# Output:       gpr23=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr23
ppcMtgpr23:
        ori     r23,r3,0x0000
        blr

	.type ppcMtgpr23,@function
	.size ppcMtgpr23,.-ppcMtgpr23

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr24
# Description:  Move to gpr24
# Input:        none
# Output:       gpr24=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr24
ppcMtgpr24:
        ori     r24,r3,0x0000
        blr

	.type ppcMtgpr24,@function
	.size ppcMtgpr24,.-ppcMtgpr24

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr25
# Description:  Move to gpr25
# Input:        none
# Output:       gpr25=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr25
ppcMtgpr25:
        ori     r25,r3,0x0000
        blr

	.type ppcMtgpr25,@function
	.size ppcMtgpr25,.-ppcMtgpr25

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr26
# Description:  Move to gpr26
# Input:        none
# Output:       gpr26=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr26
ppcMtgpr26:
        ori     r26,r3,0x0000
        blr

	.type ppcMtgpr26,@function
	.size ppcMtgpr26,.-ppcMtgpr26

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr27
# Description:  Move to gpr27
# Input:        none
# Output:       gpr27=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr27
ppcMtgpr27:
        ori     r27,r3,0x0000
        blr

	.type ppcMtgpr27,@function
	.size ppcMtgpr27,.-ppcMtgpr27

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr28
# Description:  Move to gpr28
# Input:        none
# Output:       gpr28=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr28
ppcMtgpr28:
        ori     r28,r3,0x0000
        blr

	.type ppcMtgpr28,@function
	.size ppcMtgpr28,.-ppcMtgpr28

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr29
# Description:  Move to gpr29
# Input:        none
# Output:       gpr29=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr29
ppcMtgpr29:
        ori     r29,r3,0x0000
        blr

	.type ppcMtgpr29,@function
	.size ppcMtgpr29,.-ppcMtgpr29

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr30
# Description:  Move to gpr30
# Input:        none
# Output:       gpr30=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr30
ppcMtgpr30:
        ori     r30,r3,0x0000
        blr

	.type ppcMtgpr30,@function
	.size ppcMtgpr30,.-ppcMtgpr30

#-------------------------------------------------------------------------------
# Function:     ppcMtgpr31
# Description:  Move to gpr31
# Input:        none
# Output:       gpr31=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
	.globl  ppcMtgpr31
ppcMtgpr31:
        ori     r31,r3,0x0000
        blr

	.type ppcMtgpr31,@function
	.size ppcMtgpr31,.-ppcMtgpr31


#-------------------------------------------------------------------------------
# Function:     ppcMfuart0iir
# Description:  Move from uart0 reg. 
# Input:        none
# Output:       r3=uart0(iir)
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfuart0iir
ppcMfuart0iir:
   	addis   r6,r0,0x0302 
        ori     r6,r6,0xef60
	stw	r3,0(r6)
        blr

        .type ppcMfuart0iir,@function
        .size ppcMfuart0iir,.-ppcMfuart0iir


#-------------------------------------------------------------------------------
# Function:     ppcMfuart1iir
# Description:  Move from uart1 reg.
# Input:        none
# Output:       r3=uart1(iir)
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfuart1iir
ppcMfuart1iir:
        addis   r6,r0,0x0402
        ori     r6,r6,0xef60
        stw     r3,0(r6)
        blr

        .type ppcMfuart1iir,@function
        .size ppcMfuart1iir,.-ppcMfuart1iir

#------------------------------------------------------------------------------
# Function:     ppcMfem0mr0
# Description:  Move from mode register 0.
# Input:        none
# Output:       r3= mode reg0
#------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfem0mr0
ppcMfem0mr0:
        addis   r4,0,EMAC_BASE@h
        ori     r4,r4,EMAC_BASE@l
        lwz     r3,0(r4)
        blr

        .type ppcMfem0mr0,@function
        .size ppcMfem0mr0,.-ppcMfem0mr0

#------------------------------------------------------------------------------
# Function:     ppcMfiic0mdbuf
# Description:  Move from iic0 master data buffer.
# Input:        none
# Output:       r3=iic0mdbuf 
#------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfiic0mdbuf
ppcMfiic0mdbuf:
        addis   r4,0,IIC_MASTER_ADDR@h
        ori     r4,r4,IIC_MASTER_ADDR@l
        lwz     r3,0(r4)
        blr

        .type ppcMfiic0mdbuf,@function
        .size ppcMfiic0mdbuf,.-ppcMfiic0mdbuf

#------------------------------------------------------------------------------
# Function:     ppcMfgpo
# Description:  Move from gpio output register.
# Input:        none
# Output:       r3=gpo
#------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfgpo
ppcMfgpo:
        addis   r4,0,GPIO_BASE@h
        ori     r4,r4,GPIO_BASE@l
        lwz     r3,0(r4)
        blr

        .type ppcMfgpo,@function
        .size ppcMfgpo,.-ppcMfgpo

#------------------------------------------------------------------------------
# Function:     ppcMfpb1ap
# Description:  Move from peripheral bank1 access reg.
# Input:        none
# Output:       r3=pb1ap
#------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfpb1ap
ppcMfpb1ap:
        addi    r4,0,pb1ap     ##pb1ap configuration 
        mtdcr   ebccfga,r4
        ori     r3,0,ebccfgd
	blr

       .type ppcMfpb1ap,@function
        .size ppcMfpb1ap,.-ppcMfpb1ap


#-------------------------------------------------------------------------------
# Function:     ppcMt_gpr8
# Description:  Move to (@gpr8);gpr8 is having addr, mov r3 to addr
# Input:        none
# Output:       (@gpr8)=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMt_gpr8
ppcMt_gpr8:
        stw     r3,0(r8)
        blr

        .type ppcMt_gpr8,@function
        .size ppcMt_gpr8,.-ppcMt_gpr8

#-------------------------------------------------------------------------------
# Function:     ppcMt_gpr9
# Description:  Move to @gpr9
# Input:        none
# Output:       @gpr9=r3
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMt_gpr9
ppcMt_gpr9:
        stw     r3,0(r9)
        blr

        .type ppcMt_gpr9,@function
        .size ppcMt_gpr9,.-ppcMt_gpr9


#-------------------------------------------------------------------------------
# Function:     ppcMf_gpr8
# Description:  Move From @gpr8
# Input:        none
# Output:       r3 = @gpr8
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMf_gpr8
ppcMf_gpr8:
        lwz     r3,0(r8)
        blr

        .type ppcMf_gpr8,@function
        .size ppcMf_gpr8,.-ppcMf_gpr8

#-------------------------------------------------------------------------------
# Function:     ppcMf_gpr9
# Description:  Move From @gpr9
# Input:        none
# Output:       r3 = @gpr9
#-------------------------------------------------------------------------------
	.text
        .align  2
        .globl  ppcMf_gpr9
ppcMf_gpr9:
        lwz     r3,0(r9)
        blr

        .type ppcMf_gpr9,@function
        .size ppcMf_gpr9,.-ppcMf_gpr9

#-----------------------------------------------------------------------------
# Function:     ppcMftcr
# Description:  Move from TCR register
# Input:        none.
# Output:       r3 = contents of TCR register
#-----------------------------------------------------------------------------
	.text
	.align	2
        .globl  ppcMftcr
ppcMftcr:
	mftcr	r3
        blr

	.type ppcMftcr,@function
        .size ppcMftcr,.-ppcMftcr

#-----------------------------------------------------------------------------
# Function:     ppcMttcr
# Description:  Move to TCR register
# Input:        r3 - new value of TCR.
# Output:       none
#-----------------------------------------------------------------------------
	.text
	.align	2
        .globl  ppcMttcr
ppcMttcr:
	mttcr	r3
        blr 

	.type ppcMttcr,@function
        .size ppcMttcr,.-ppcMttcr

#-----------------------------------------------------------------------------
# Function:     ppcMftsr
# Description:  Move from TSR register
# Input:        none.
# Output:       r3 = contents of TSR register
#-----------------------------------------------------------------------------
	.text
	.align	2
        .globl  ppcMftsr
ppcMftsr:
	mftsr	r3
        blr

	.type ppcMftsr,@function
        .size ppcMftsr,.-ppcMftsr

#-----------------------------------------------------------------------------
# Function:     ppcMttsr
# Description:  Move to TSR register
# Input:        r3 - new value of TSR.
# Output:       none
#-----------------------------------------------------------------------------
	.text
	.align	2
        .globl  ppcMttsr
ppcMttsr:
	mttsr	r3
        blr

	.type ppcMttsr,@function
        .size ppcMttsr,.-ppcMttsr


	#-------------------------------------------------------------------------------
# Function:     ppcMfbear
# Description:  Move from BEAR register
# Input:        none
# Output:       r3 - value of BEAR.
#-------------------------------------------------------------------------------
        .text
	.align	2
        .globl  ppcMfbear
ppcMfbear:
        addi    r4,r0,mem_bear
	mtdcr	memcfga,r4
	mfdcr	r3,memcfgd
        nop
        nop
        nop
        blr

        .type  ppcMfbear,@function
        .size  ppcMfbear,.-ppcMfbear

#-------------------------------------------------------------------------------
# Function:     ppcMtbear
# Description:  Move to BEAR register
# Input:        r3 - new value of BEAR.
# Output:       none
#-------------------------------------------------------------------------------
        .text
	.align	2
        .globl  ppcMtbear
ppcMtbear:
        addi    r4,r0,mem_bear
	mtdcr	memcfga,r4
	mtdcr	memcfgd,r3
#ifdef PASS2_405GP
        nop
        nop
        nop
#endif
        blr

        .type  ppcMtbear,@function
        .size  ppcMtbear,.-ppcMtbear

#-----------------------------------------------------------------------------
# Function:     ppcMfpit
# Description:  Move from PIT register
# Input:        none                  
# Output:       r3 - value of PIT.
#-----------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMfpit
ppcMfpit:
        mfpit   r3
        blr

        .type ppcMfpit,@function
        .size ppcMfpit,.-ppcMfpit

#-----------------------------------------------------------------------------
# Function:     ppcMtpit
# Description:  Move to PIT register
# Input:        r3 - new value of PIT.
# Output:       none
#-----------------------------------------------------------------------------
	.text
	.align	2
        .globl  ppcMtpit
ppcMtpit:
	mtpit	r3
        blr

	.type ppcMtpit,@function
        .size ppcMtpit,.-ppcMtpit

#************************************************************************
#   Jump to the start the address in r3                                 *
#                                                                       *
#   CALL BY:    jump_to_func(start_address);                            *
#               uint32 start_address;   address to jump to              *
#   ON EXIT:    Doesn't return                                          *
#                                                                       *
#************************************************************************
    .align  2
    .globl  jump_to_func

jump_to_func:
    stwu    r1,-4(r1)
    mfspr   r0,8              # Load the return address(LR) in R0
    stw     r0,4(r1)          # Store the return address on the stack
    mtspr   8,r3              # Load the address into Link Register
    bclrl   20,0
    lwz     r0,4(r1)          # Get return address into R0
    mtspr   8,r0              # Put return address into Link Register
    addi    r1,r1,4           # Update the stack pointer
    blr

#-------------------------------------------------------------------------------
# Function:     ppcMtchcr0
# Description:  Move to Chip control register 0
# Input:        r3 - new value of CHCR0.
# Output:       none
#-------------------------------------------------------------------------------
        .text
	.align	2
        .globl  ppcMtchcr0
ppcMtchcr0:
	mtdcr	chcr0,r3
        nop
        nop
        nop
        blr

        .type  ppcMtchcr0,@function
        .size  ppcMtchcr0,.-ppcMtchcr0
#-------------------------------------------------------------------------------
# Function:     ppcMtpb2ap
# Description:  Move to Peripheral Bank 2 Access Parameters
# Input:        r3 - new value of PB2AP
# Output:       none
#-------------------------------------------------------------------------------
        .text
    	.align  2
        .globl  ppcMtpb2ap
ppcMtpb2ap:
    addi    r4,0,pb2ap
    mtdcr   ebccfga,r4
   	mtdcr   ebccfgd,r3
    blr
		.type  ppcMtpb2ap,@function
        .size  ppcMtpb2ap,.-ppcMtpb2ap
#-------------------------------------------------------------------------------
# Function:     ppcMtpb2cr
# Description:  Move to Peripheral Bank 2 Configuration Registers
# Input:        r3 - new value of PB2CR
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  ppcMtpb2cr
ppcMtpb2cr:
    addi    r4,0,pb2cr
    mtdcr   ebccfga,r4
    mtdcr   ebccfgd,r3
    blr
        .type  ppcMtpb2cr,@function
        .size  ppcMtpb2cr,.-ppcMtpb2cr

#-------------------------------------------------------------------------------
# Function:     restartPPC
# Description:  Restart the system by forcing a watchdog timer reset
# Input:        none
# Output:       none
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  restartPPC

restartPPC:

        addis   r3,0,0x3000     # Init TCR to WP = 2^17 clks, force sys reset, all ints disabled
        ori     r3,r3,0
        mtspr   tcr,r3
wd_loop:
        b       wd_loop         # Loop endlessly until the wdt resets the system

        .type  restartPPC,@function
        .size  restartPPC,.-restartPPC

