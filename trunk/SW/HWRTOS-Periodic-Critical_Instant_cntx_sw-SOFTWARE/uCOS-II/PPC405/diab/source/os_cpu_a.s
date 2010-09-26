#*********************************************************************************************************
#                                               uC/OS-II
#                                         The Real-Time Kernel
#
#                        (c) Copyright 1992-1998, Jean J. Labrosse, Plantation, FL
#                                          All Rights Reserved
#
#
#                                       PowerPC Specific code
#
# File : os_cpu_a.s
#********************************************************************************************************
    .file       "os_cpu_a.s"

    .text

    .extern OSTCBHighRdy    ;pointer to highest priority ready task
    .extern OSTCBCur        ;pointer to current tasks TCB
    .extern OSIntNesting
    .extern OSPrioHighRdy
    .extern OSPrioCur
  
#########################################################################
#
#           POWERPC REGISTER DEFINITIONS
#
#########################################################################
XER              .equ   1       ;integer exception register
LR               .equ   8       ;link register
CTR              .equ   9       ;count register

EE               .equ   0x8000
STACK_ADJUSTMENT .equ   0x18

#########################################################################
#                                   
#           STACK FRAME DEFINITION
#
#########################################################################
XR1     .equ    0
XBLK1   .equ    XR1+4
XR0     .equ    XBLK1+4
XSRR0   .equ    XR0+4
XSRR1   .equ    XSRR0+4
XCTR    .equ    XSRR1+4
XXER    .equ    XCTR+4
XCR     .equ    XXER+4
XLR     .equ    XCR+4
XBLK2   .equ    XLR+4
XR2     .equ    XBLK2+4
XR3     .equ    XR2+4
XR4     .equ    XR3+4
XR5     .equ    XR4+4
XR6     .equ    XR5+4
XR7     .equ    XR6+4
XR8     .equ    XR7+4
XR9     .equ    XR8+4
XR10    .equ    XR9+4
XR11    .equ    XR10+4
XR12    .equ    XR11+4
XR13    .equ    XR12+4
XR14    .equ    XR13+4
XR15    .equ    XR14+4
XR16    .equ    XR15+4
XR17    .equ    XR16+4
XR18    .equ    XR17+4
XR19    .equ    XR18+4
XR20    .equ    XR19+4
XR21    .equ    XR20+4
XR22    .equ    XR21+4
XR23    .equ    XR22+4
XR24    .equ    XR23+4
XR25    .equ    XR24+4
XR26    .equ    XR25+4
XR27    .equ    XR26+4
XR28    .equ    XR27+4
XR29    .equ    XR28+4
XR30    .equ    XR29+4
XR31    .equ    XR30+4
XMSR    .equ    XR31+4
STACK_FRAME_SIZE .equ XMSR+4
CSTACK_SAVE_SIZE .equ 0x50


#########################################################################
#
#           START MULTITASKING              
#                                   
#  void OSStartHighRdy(void)                        
#                                   
#########################################################################
    .align  2
    .globl  OSStartHighRdy
OSStartHighRdy:
;; Clear R0
    xor     r0,r0,r0
;; get pointer to ready task TCB
    addis   r11,r0,OSTCBHighRdy@ha
    lwz r11,OSTCBHighRdy@l(r11)

;; save as current task TCB ptr.
    addis   r12,r0,OSTCBCur@ha
    stw r11,OSTCBCur@l(r12)

;; get new stack pointer
    lwz r1,0(r11)

;; restore registers r2 to r31
    lwz r3,XR3(r1)
    lwz r4,XR4(r1)
    lwz r5,XR5(r1)
    lwz r6,XR6(r1)
    lwz r7,XR7(r1)
    lwz r8,XR8(r1)
    lwz r9,XR9(r1)
    lwz r10,XR10(r1)
    lwz r11,XR11(r1)
    lwz r12,XR12(r1)
    lwz r14,XR14(r1)
    lwz r15,XR15(r1)
    lwz r16,XR16(r1)
    lwz r17,XR17(r1)
    lwz r18,XR18(r1)
    lwz r19,XR19(r1)
    lwz r20,XR20(r1)
    lwz r21,XR21(r1)
    lwz r22,XR22(r1)
    lwz r23,XR23(r1)
    lwz r24,XR24(r1)
    lwz r25,XR25(r1)
    lwz r26,XR26(r1)
    lwz r27,XR27(r1)
    lwz r28,XR28(r1)
    lwz r29,XR29(r1)
    lwz r30,XR30(r1)
    lwz r31,XR31(r1)
    lwz	    r0,XLR(r1)
    mtspr	LR,r0
    lwz	    r0,XCR(r1)
    mtcrf	255,r0
    lwz	    r0,XXER(r1)
    mtspr	XER,r0
    lwz	    r0,XCTR(r1)
    mtspr	CTR,r0
    lwz     r0,XMSR(r1)
    mtspr   SRR1,r0
    lwz     r0,XLR(r1)
    mtspr   SRR0,r0
    lwz	    r0,XR0(r1)
    addi    r1,r1,STACK_FRAME_SIZE
;; Perform task switch
    rfi

#########################################################################
#
#            PERFORM A CONTEXT SWITCH (From task level)
#
#                        void OSCtxSw(void)                         
#                                   
#########################################################################
    .align      2
    .globl      OSCtxSw
OSCtxSw:
;;
;; Save the current registers
    stwu	r1,-STACK_FRAME_SIZE(r1)
    stw	    r0,XR0(r1)
    mfspr	r0,LR
    stw	    r0,XSRR0(r1)
    mfmsr	r0
    stw	    r0,XSRR1(r1)
    mfspr	r0,CTR
    stw	    r0,XCTR(r1)
    mfspr	r0,XER
    stw	    r0,XXER(r1)
    mfcr	r0
    stw	    r0,XCR(r1)
    stw	    r3,XR3(r1)
    stw	    r4,XR4(r1)
    stw	    r5,XR5(r1)
    stw	    r6,XR6(r1)
    stw	    r7,XR7(r1)
    stw	    r8,XR8(r1)
    stw	    r9,XR9(r1)
    stw	    r10,XR10(r1)
    stw	    r11,XR11(r1)
    stw	    r12,XR12(r1)
    stw     r14,XR14(r1)
    stw     r15,XR15(r1)
    stw     r16,XR16(r1)
    stw     r17,XR17(r1)
    stw     r18,XR18(r1)
    stw     r19,XR19(r1)
    stw     r20,XR20(r1)
    stw     r21,XR21(r1)
    stw     r22,XR22(r1)
    stw     r23,XR23(r1)
    stw     r24,XR24(r1)
    stw     r25,XR25(r1)
    stw     r26,XR26(r1)
    stw     r27,XR27(r1)
    stw     r28,XR28(r1)
    stw     r29,XR29(r1)
    stw     r30,XR30(r1)
    stw     r31,XR31(r1)

;; Clear R0
    xor     r0,r0,r0

;; get pointer to current TCB
    addis   r11,r0,OSTCBCur@ha
    lwz r11,OSTCBCur@l(r11)

;; save stack pointer in current TCB
    stw r1,0(r11)

;; get pointer to ready task TCB
    addis   r11,r0,OSTCBHighRdy@ha
    lwz r11,OSTCBHighRdy@l(r11)

;; save as current task TCB ptr.
    addis   r12,r0,OSTCBCur@ha
    stw r11,OSTCBCur@l(r12)

;; get High Ready Priority
    lis		r12,OSPrioHighRdy@ha
    lbz		r10,OSPrioHighRdy@l(r12)

;; save as Current Priority
    lis		r12,OSPrioCur@ha
    stb		r10,OSPrioCur@l(r12)

;; get new stack pointer
    lwz r1,0(r11)

;; restore registers r2 to r31
    lwz r3,XR3(r1)
    lwz r4,XR4(r1)
    lwz r5,XR5(r1)
    lwz r6,XR6(r1)
    lwz r7,XR7(r1)
    lwz r8,XR8(r1)
    lwz r9,XR9(r1)
    lwz r10,XR10(r1)
    lwz r11,XR11(r1)
    lwz r12,XR12(r1)
    lwz r14,XR14(r1)
    lwz r15,XR15(r1)
    lwz r16,XR16(r1)
    lwz r17,XR17(r1)
    lwz r18,XR18(r1)
    lwz r19,XR19(r1)
    lwz r20,XR20(r1)
    lwz r21,XR21(r1)
    lwz r22,XR22(r1)
    lwz r23,XR23(r1)
    lwz r24,XR24(r1)
    lwz r25,XR25(r1)
    lwz r26,XR26(r1)
    lwz r27,XR27(r1)
    lwz r28,XR28(r1)
    lwz r29,XR29(r1)
    lwz r30,XR30(r1)
    lwz r31,XR31(r1)
    lwz	    r0,XLR(r1)
    mtspr	LR,r0
    lwz	    r0,XCR(r1)
    mtcrf	255,r0
    lwz	    r0,XXER(r1)
    mtspr	XER,r0
    lwz	    r0,XCTR(r1)
    mtspr	CTR,r0
    lwz     r0,XSRR1(r1)
    mtspr   SRR1,r0
    lwz     r0,XSRR0(r1)
    mtspr   SRR0,r0
    lwz	    r0,XR0(r1)
    addi    r1,r1,STACK_FRAME_SIZE
;; Perform task switch
    rfi

#########################################################################
#
#            PERFORM A CONTEXT SWITCH (From an ISR)
#
#                        void OSIntCtxSw(void)                          
#                                   
#########################################################################
    .align      2
    .globl      OSIntCtxSw
OSIntCtxSw:
;;Ignore calls to OSIntExit,
;;OSIntCtxSw and locals.
    addi    r1,r1,STACK_ADJUSTMENT


;; Clear R0
    xor     r0,r0,r0

;; get pointer to current TCB
    addis   r11,r0,OSTCBCur@ha
    lwz r11,OSTCBCur@l(r11)

;; save stack pointer in current TCB 
    stw r1,0(r11)

;; get pointer to ready task TCB
    addis   r11,r0,OSTCBHighRdy@ha
    lwz r11,OSTCBHighRdy@l(r11)

;; save as current task TCB ptr.
    addis   r12,r0,OSTCBCur@ha
    stw r11,OSTCBCur@l(r12)

;; get High Ready Priority
    lis		r12,OSPrioHighRdy@ha
    lbz		r10,OSPrioHighRdy@l(r12)

;; save as Current Priority
    lis		r12,OSPrioCur@ha
    stb		r10,OSPrioCur@l(r12)

;; get new stack pointer
    lwz r1,0(r11)

;; restore registers r2 to r31
    lwz r3,XR3(r1)
    lwz r4,XR4(r1)
    lwz r5,XR5(r1)
    lwz r6,XR6(r1)
    lwz r7,XR7(r1)
    lwz r8,XR8(r1)
    lwz r9,XR9(r1)
    lwz r10,XR10(r1)
    lwz r11,XR11(r1)
    lwz r12,XR12(r1)
    lwz r14,XR14(r1)
    lwz r15,XR15(r1)
    lwz r16,XR16(r1)
    lwz r17,XR17(r1)
    lwz r18,XR18(r1)
    lwz r19,XR19(r1)
    lwz r20,XR20(r1)
    lwz r21,XR21(r1)
    lwz r22,XR22(r1)
    lwz r23,XR23(r1)
    lwz r24,XR24(r1)
    lwz r25,XR25(r1)
    lwz r26,XR26(r1)
    lwz r27,XR27(r1)
    lwz r28,XR28(r1)
    lwz r29,XR29(r1)
    lwz r30,XR30(r1)
    lwz r31,XR31(r1)
    lwz	    r0,XLR(r1)
    mtspr	LR,r0
    lwz	    r0,XCR(r1)
    mtcrf	255,r0
    lwz	    r0,XXER(r1)
    mtspr	XER,r0
    lwz	    r0,XCTR(r1)
    mtspr	CTR,r0
    lwz     r0,XSRR1(r1)
    mtspr   SRR1,r0
    lwz     r0,XSRR0(r1)
    mtspr   SRR0,r0 
    lwz	    r0,XR0(r1)
    addi    r1,r1,STACK_FRAME_SIZE
;; Perform task switch
    rfi
