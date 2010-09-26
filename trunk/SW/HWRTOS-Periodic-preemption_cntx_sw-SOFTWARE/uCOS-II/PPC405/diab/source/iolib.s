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
#  File Name:   iolib.s
#
#  Function:    C-callable assembler functions for I/O.
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Function:     in8
# Description:  Input 8 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  in8
in8:
        lbz     r3,0x0000(r3)
        blr

        .type in8,@function
        .size in8,.-in8

#-------------------------------------------------------------------------------
# Function:     in16
# Description:  Input 16 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  in16
in16:
        lhz     r3,0x0000(r3)
        blr

        .type in16,@function
        .size in16,.-in16

#-------------------------------------------------------------------------------
# Function:     in16r
# Description:  Input 16 bits and byte reverse
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  in16r
in16r:
        lhbrx   r3,r0,r3
        blr

        .type in16r,@function
        .size in16r,.-in16r


#-------------------------------------------------------------------------------
# Function:     in32
# Description:  Input 32 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  in32
in32:
        lwz     r3,0x0000(r3)
        blr

        .type in32,@function
        .size in32,.-in32

#-------------------------------------------------------------------------------
# Function:     in32r
# Description:  Input 32 bits and byte reverse
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  in32r
in32r:
        lwbrx   r3,r0,r3
        blr

        .type in32r,@function
        .size in32r,.-in32r

#-------------------------------------------------------------------------------
# Function:     out8
# Description:  Output 8 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  out8
out8:
        mflr    r6
        stb     r4,0x0000(r3)
        mtlr    r6
        blr

        .type out8,@function
        .size out8,.-out8

#-------------------------------------------------------------------------------
# Function:     out16
# Description:  Output 16 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  out16
out16:
        sth     r4,0x0000(r3)
        blr

        .type out16,@function
        .size out16,.-out16

#-------------------------------------------------------------------------------
# Function:     out16r
# Description:  Byte reverse and output 16 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  out16r
out16r:
        sthbrx  r4,r0,r3
        blr

        .type out16r,@function
        .size out16r,.-out16r

#-------------------------------------------------------------------------------
# Function:     out32
# Description:  Output 32 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  out32
out32:
        stw     r4,0x0000(r3)
        blr

        .type out32,@function
        .size out32,.-out32

#-------------------------------------------------------------------------------
# Function:     out32r
# Description:  Byte reverse and output 32 bits
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  out32r
out32r:
        stwbrx  r4,r0,r3
        blr

        .type out32r,@function
        .size out32r,.-out32r

#-------------------------------------------------------------------------------
# Function:     int_disable
# Description:  Disable external interrupts
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  int_disable
int_disable:
        mfmsr   r3                      # pull msr
        addi    r4,r0,0x8000            # set bit for external exceptions
        andi.   r4,r4,0xffff            # clear sign extended bits
        andc    r3,r3,r4                # disable external interrupts
        mtmsr   r3                      # modify msr
        blr

        .type int_disable,@function
        .size int_disable,.-int_disable

#-------------------------------------------------------------------------------
# Function:     int_enable
# Description:  Enable external interrupts
#-------------------------------------------------------------------------------
        .text
        .align  2
        .globl  int_enable
int_enable:
        mfmsr   r3                      # pull msr
        ori     r3,r3,0x8000            # enable external interrupts
        mtmsr   r3                      # modify msr
        blr

        .type int_enable,@function
        .size int_enable,.-int_enable

