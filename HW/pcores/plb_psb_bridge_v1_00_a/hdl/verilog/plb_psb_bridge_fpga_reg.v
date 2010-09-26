/***********************************************************************
*
* AMIRIX Systems Inc. 
* 77 Chain Lake Drive 
* Halifax, Nova Scotia B3S 1E1 
* 
* (C) 2005 AMIRIX Systems Inc. All rights reserved.
* The information contained herein includes information which is confidential
* and proprietary to AMIRIX Systems Inc. and may not be used or 
* disclosed without prior written consent of AMIRIX Systems Inc. 
*
* Content of this file:                                                 
*  PLB_PSB FPGA Internal Registers (a space that can be easily accessed
*  on the PLB Bus to allow for registers to be address mapped)
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/plb_psb_bridge_fpga_reg.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: plb_psb_bridge_fpga_reg.v,v $
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.1  2005/02/25 14:09:34  kuehner
* Initial Revision.
*
*
*
*
***********************************************************************/

`timescale 1 ns	/ 1 ps

/***********************************************************************
Module Description:
This module contains the control and status registers for the User FPGA.

************************************************************************/

module plb_psb_bridge_fpga_reg (
                     // Inputs
					  // System
						clk				           ,
						reset			           ,

                      // Read and Write Control
						addr                       , // either from PLB addr or PSB addr
						wr_en_pulse                , // active high for 1 cc
						rd_en_pulse                , // active high pulse to enable read mux
						plb_npsb                   , // 1 indicates PLB access; 0 indicates PSB access
						write_data                 , // 32 bits of data to be written to register

                      // UART 16550 PPC0 Registers
						uart_ppc0_rbr_rbr         	,
						uart_ppc0_iir_fifoen      	,
						uart_ppc0_iir_intid2      	,
						uart_ppc0_iir_intpend     	,
						uart_ppc0_lsr_err_in_rfifo	,
						uart_ppc0_lsr_temt        	,
						uart_ppc0_lsr_thre        	,
						uart_ppc0_lsr_bi          	,
						uart_ppc0_lsr_fe          	,
						uart_ppc0_lsr_pe          	,
						uart_ppc0_lsr_oe          	,
						uart_ppc0_lsr_dr          	,
						uart_ppc0_msr_dcd         	,
						uart_ppc0_msr_ri          	,
						uart_ppc0_msr_dsr         	,
						uart_ppc0_msr_cts         	,
						uart_ppc0_msr_ddcd        	,
						uart_ppc0_msr_teri        	,
						uart_ppc0_msr_ddsr        	,
						uart_ppc0_msr_dcts        	,

					  // UART 16550 HOST0 Registers
						uart_host0_rbr_rbr         	,
						uart_host0_iir_fifoen      	,
						uart_host0_iir_intid2      	,
						uart_host0_iir_intpend     	,
						uart_host0_lsr_err_in_rfifo	,
						uart_host0_lsr_temt        	,
						uart_host0_lsr_thre        	,
						uart_host0_lsr_bi          	,
						uart_host0_lsr_fe          	,
						uart_host0_lsr_pe          	,
						uart_host0_lsr_oe          	,
						uart_host0_lsr_dr          	,
						uart_host0_msr_dcd         	,
						uart_host0_msr_ri          	,
						uart_host0_msr_dsr         	,
						uart_host0_msr_cts         	,
						uart_host0_msr_ddcd        	,
						uart_host0_msr_teri        	,
						uart_host0_msr_ddsr        	,
						uart_host0_msr_dcts        	,

					  // UART 16550 PPC1 Registers
						uart_ppc1_rbr_rbr         	,
						uart_ppc1_iir_fifoen      	,
						uart_ppc1_iir_intid2      	,
						uart_ppc1_iir_intpend     	,
						uart_ppc1_lsr_err_in_rfifo	,
						uart_ppc1_lsr_temt        	,
						uart_ppc1_lsr_thre        	,
						uart_ppc1_lsr_bi          	,
						uart_ppc1_lsr_fe          	,
						uart_ppc1_lsr_pe          	,
						uart_ppc1_lsr_oe          	,
						uart_ppc1_lsr_dr          	,
						uart_ppc1_msr_dcd         	,
						uart_ppc1_msr_ri          	,
						uart_ppc1_msr_dsr         	,
						uart_ppc1_msr_cts         	,
						uart_ppc1_msr_ddcd        	,
						uart_ppc1_msr_teri        	,
						uart_ppc1_msr_ddsr        	,
						uart_ppc1_msr_dcts        	,

					  // UART 16550 HOST1 Registers
						uart_host1_rbr_rbr         	,
						uart_host1_iir_fifoen      	,
						uart_host1_iir_intid2      	,
						uart_host1_iir_intpend     	,
						uart_host1_lsr_err_in_rfifo	,
						uart_host1_lsr_temt        	,
						uart_host1_lsr_thre        	,
						uart_host1_lsr_bi          	,
						uart_host1_lsr_fe          	,
						uart_host1_lsr_pe          	,
						uart_host1_lsr_oe          	,
						uart_host1_lsr_dr          	,
						uart_host1_msr_dcd         	,
						uart_host1_msr_ri          	,
						uart_host1_msr_dsr         	,
						uart_host1_msr_cts         	,
						uart_host1_msr_ddcd        	,
						uart_host1_msr_teri        	,
						uart_host1_msr_ddsr        	,
						uart_host1_msr_dcts        	,

                     // Outputs
                      // Read and Write Control
                        read_data                  , // 32 bits of data to be read from register

                      // UART 16550 Port 0 Registers
					   // PPC405
						uart_ppc0_thr_thr                      ,
						uart_ppc0_ier_edssi                    ,
						uart_ppc0_ier_elsi                     ,
						uart_ppc0_ier_etbei                    ,
						uart_ppc0_ier_erbfi                    ,
						uart_ppc0_fcr_rfifo_tlevel             ,
						uart_ppc0_fcr_dma_mode_sel             ,
						uart_ppc0_fcr_tfifo_reset              ,
						uart_ppc0_fcr_rfifo_reset              ,
						uart_ppc0_fcr_fifo_en                  ,
						uart_ppc0_lcr_dlab                     ,
						uart_ppc0_lcr_set_break                ,
						uart_ppc0_lcr_stick_parity             ,
						uart_ppc0_lcr_eps                      ,
						uart_ppc0_lcr_pen                      ,
						uart_ppc0_lcr_stb                      ,
						uart_ppc0_lcr_wls                      ,
						uart_ppc0_mcr_loop                     ,
						uart_ppc0_mcr_out2                     ,
						uart_ppc0_mcr_out1                     ,
						uart_ppc0_mcr_rts                      ,
						uart_ppc0_mcr_dtr                      ,
						uart_ppc0_lsr_err_in_rfifo_write_value ,
						uart_ppc0_lsr_temt_write_value         ,
						uart_ppc0_lsr_thre_write_value         ,
						uart_ppc0_lsr_bi_write_value           ,
						uart_ppc0_lsr_fe_write_value           ,
						uart_ppc0_lsr_pe_write_value           ,
						uart_ppc0_lsr_oe_write_value           ,
						uart_ppc0_lsr_dr_write_value           ,
						uart_ppc0_msr_dcd_write_value          ,
						uart_ppc0_msr_ri_write_value           ,
						uart_ppc0_msr_dsr_write_value          ,
						uart_ppc0_msr_cts_write_value          ,
						uart_ppc0_msr_ddcd_write_value         ,
						uart_ppc0_msr_teri_write_value         ,
						uart_ppc0_msr_ddsr_write_value         ,
						uart_ppc0_msr_dcts_write_value         ,
						uart_ppc0_scr_scr                      ,
						uart_ppc0_dll_dll                      ,
						uart_ppc0_dlm_dlm                      ,
						uart_ppc0_thr_write_pulse              ,
						uart_ppc0_lsr_write_pulse              ,
						uart_ppc0_msr_write_pulse              ,
						uart_ppc0_rbr_read_pulse               ,
						uart_ppc0_msr_read_pulse               ,
					   // Host
						uart_host0_thr_thr                      ,
						uart_host0_ier_edssi                    ,
						uart_host0_ier_elsi                     ,
						uart_host0_ier_etbei                    ,
						uart_host0_ier_erbfi                    ,
						uart_host0_fcr_rfifo_tlevel             ,
						uart_host0_fcr_dma_mode_sel             ,
						uart_host0_fcr_tfifo_reset              ,
						uart_host0_fcr_rfifo_reset              ,
						uart_host0_fcr_fifo_en                  ,
						uart_host0_lcr_dlab                     ,
						uart_host0_lcr_set_break                ,
						uart_host0_lcr_stick_parity             ,
						uart_host0_lcr_eps                      ,
						uart_host0_lcr_pen                      ,
						uart_host0_lcr_stb                      ,
						uart_host0_lcr_wls                      ,
						uart_host0_mcr_loop                     ,
						uart_host0_mcr_out2                     ,
						uart_host0_mcr_out1                     ,
						uart_host0_mcr_rts                      ,
						uart_host0_mcr_dtr                      ,
						uart_host0_lsr_err_in_rfifo_write_value ,
						uart_host0_lsr_temt_write_value         ,
						uart_host0_lsr_thre_write_value         ,
						uart_host0_lsr_bi_write_value           ,
						uart_host0_lsr_fe_write_value           ,
						uart_host0_lsr_pe_write_value           ,
						uart_host0_lsr_oe_write_value           ,
						uart_host0_lsr_dr_write_value           ,
						uart_host0_msr_dcd_write_value          ,
						uart_host0_msr_ri_write_value           ,
						uart_host0_msr_dsr_write_value          ,
						uart_host0_msr_cts_write_value          ,
						uart_host0_msr_ddcd_write_value         ,
						uart_host0_msr_teri_write_value         ,
						uart_host0_msr_ddsr_write_value         ,
						uart_host0_msr_dcts_write_value         ,
						uart_host0_scr_scr                      ,
						uart_host0_dll_dll                      ,
						uart_host0_dlm_dlm                      ,
						uart_host0_thr_write_pulse              ,
						uart_host0_lsr_write_pulse              ,
						uart_host0_msr_write_pulse              ,
						uart_host0_rbr_read_pulse               ,
						uart_host0_msr_read_pulse               ,
									    
					  // UART 16550 Port 1 Registers
					   // PPC405
						uart_ppc1_thr_thr                      ,
						uart_ppc1_ier_edssi                    ,
						uart_ppc1_ier_elsi                     ,
						uart_ppc1_ier_etbei                    ,
						uart_ppc1_ier_erbfi                    ,
						uart_ppc1_fcr_rfifo_tlevel             ,
						uart_ppc1_fcr_dma_mode_sel             ,
						uart_ppc1_fcr_tfifo_reset              ,
						uart_ppc1_fcr_rfifo_reset              ,
						uart_ppc1_fcr_fifo_en                  ,
						uart_ppc1_lcr_dlab                     ,
						uart_ppc1_lcr_set_break                ,
						uart_ppc1_lcr_stick_parity             ,
						uart_ppc1_lcr_eps                      ,
						uart_ppc1_lcr_pen                      ,
						uart_ppc1_lcr_stb                      ,
						uart_ppc1_lcr_wls                      ,
						uart_ppc1_mcr_loop                     ,
						uart_ppc1_mcr_out2                     ,
						uart_ppc1_mcr_out1                     ,
						uart_ppc1_mcr_rts                      ,
						uart_ppc1_mcr_dtr                      ,
						uart_ppc1_lsr_err_in_rfifo_write_value ,
						uart_ppc1_lsr_temt_write_value         ,
						uart_ppc1_lsr_thre_write_value         ,
						uart_ppc1_lsr_bi_write_value           ,
						uart_ppc1_lsr_fe_write_value           ,
						uart_ppc1_lsr_pe_write_value           ,
						uart_ppc1_lsr_oe_write_value           ,
						uart_ppc1_lsr_dr_write_value           ,
						uart_ppc1_msr_dcd_write_value          ,
						uart_ppc1_msr_ri_write_value           ,
						uart_ppc1_msr_dsr_write_value          ,
						uart_ppc1_msr_cts_write_value          ,
						uart_ppc1_msr_ddcd_write_value         ,
						uart_ppc1_msr_teri_write_value         ,
						uart_ppc1_msr_ddsr_write_value         ,
						uart_ppc1_msr_dcts_write_value         ,
						uart_ppc1_scr_scr                      ,
						uart_ppc1_dll_dll                      ,
						uart_ppc1_dlm_dlm                      ,
						uart_ppc1_thr_write_pulse              ,
						uart_ppc1_lsr_write_pulse              ,
						uart_ppc1_msr_write_pulse              ,
						uart_ppc1_rbr_read_pulse               ,
						uart_ppc1_msr_read_pulse               ,
					   // Host
						uart_host1_thr_thr                      ,
						uart_host1_ier_edssi                    ,
						uart_host1_ier_elsi                     ,
						uart_host1_ier_etbei                    ,
						uart_host1_ier_erbfi                    ,
						uart_host1_fcr_rfifo_tlevel             ,
						uart_host1_fcr_dma_mode_sel             ,
						uart_host1_fcr_tfifo_reset              ,
						uart_host1_fcr_rfifo_reset              ,
						uart_host1_fcr_fifo_en                  ,
						uart_host1_lcr_dlab                     ,
						uart_host1_lcr_set_break                ,
						uart_host1_lcr_stick_parity             ,
						uart_host1_lcr_eps                      ,
						uart_host1_lcr_pen                      ,
						uart_host1_lcr_stb                      ,
						uart_host1_lcr_wls                      ,
						uart_host1_mcr_loop                     ,
						uart_host1_mcr_out2                     ,
						uart_host1_mcr_out1                     ,
						uart_host1_mcr_rts                      ,
						uart_host1_mcr_dtr                      ,
						uart_host1_lsr_err_in_rfifo_write_value ,
						uart_host1_lsr_temt_write_value         ,
						uart_host1_lsr_thre_write_value         ,
						uart_host1_lsr_bi_write_value           ,
						uart_host1_lsr_fe_write_value           ,
						uart_host1_lsr_pe_write_value           ,
						uart_host1_lsr_oe_write_value           ,
						uart_host1_lsr_dr_write_value           ,
						uart_host1_msr_dcd_write_value          ,
						uart_host1_msr_ri_write_value           ,
						uart_host1_msr_dsr_write_value          ,
						uart_host1_msr_cts_write_value          ,
						uart_host1_msr_ddcd_write_value         ,
						uart_host1_msr_teri_write_value         ,
						uart_host1_msr_ddsr_write_value         ,
						uart_host1_msr_dcts_write_value         ,
						uart_host1_scr_scr                      ,
						uart_host1_dll_dll                      ,
						uart_host1_dlm_dlm                      ,
						uart_host1_thr_write_pulse              ,
						uart_host1_lsr_write_pulse              ,
						uart_host1_msr_write_pulse              ,
						uart_host1_rbr_read_pulse               ,
						uart_host1_msr_read_pulse               
);


/********************
* Module Parameters *
********************/
parameter           PLB_PSB_FPGA_REG_LSB_DECODE = 18;

// Register Memory Space must be  2^n and the least sig. n bits of baseaddr 
// must be 0 (2000-3FFF = 2^13; 4000-7FFF = 2^14)
//   and the bottom n bits must be 
// Register Memory Map (Base Addr = 0x3000_2000) - Only Uart 1 (Baseline)
// Register Memory Map (Base Addr = 0x3000_4000) - Uart 1 and Uart 2
// Uart P0 - Baseaddr = 0x0000
parameter           UART_0_RBR_REG	   = 32'h0000_1000;  // RO (LCR(7) = 0
parameter           UART_0_THR_REG	   = 32'h0000_1000;  // WO (LCR(7) = 0
parameter           UART_0_IER_REG	   = 32'h0000_1004;  // RW (LCR(7) = 0
parameter           UART_0_IIR_REG	   = 32'h0000_1008;  // RO (LCR(7) = 0
parameter           UART_0_FCR_REG	   = 32'h0000_1008;  // WO if LCR(7) = 0; RO if LCR(7) = 1
parameter           UART_0_LCR_REG	   = 32'h0000_100C;  // RW (LCR(7) = X
parameter           UART_0_MCR_REG	   = 32'h0000_1010;  // RW (LCR(7) = X
parameter           UART_0_LSR_REG	   = 32'h0000_1014;  // RW (LCR(7) = X
parameter           UART_0_MSR_REG	   = 32'h0000_1018;  // RW (LCR(7) = X
parameter           UART_0_SCR_REG	   = 32'h0000_101C;  // RW (LCR(7) = X
parameter           UART_0_DLL_REG	   = 32'h0000_1000;  // RW (LCR(7) = 1
parameter           UART_0_DLM_REG	   = 32'h0000_1004;  // RW (LCR(7) = 1
// Uart P1 - Baseaddr = 0x2000
parameter           UART_1_RBR_REG 	   = 32'h0000_3000;  // RO (LCR(7) = 0
parameter           UART_1_THR_REG	   = 32'h0000_3000;  // WO (LCR(7) = 0
parameter           UART_1_IER_REG	   = 32'h0000_3004;  // RW (LCR(7) = 0
parameter           UART_1_IIR_REG	   = 32'h0000_3008;  // RO (LCR(7) = 0
parameter           UART_1_FCR_REG	   = 32'h0000_3008;  // WO if LCR(7) = 0; RO if LCR(7) = 1
parameter           UART_1_LCR_REG	   = 32'h0000_300C;  // RW (LCR(7) = X
parameter           UART_1_MCR_REG	   = 32'h0000_3010;  // RW (LCR(7) = X
parameter           UART_1_LSR_REG	   = 32'h0000_3014;  // RW (LCR(7) = X
parameter           UART_1_MSR_REG	   = 32'h0000_3018;  // RW (LCR(7) = X
parameter           UART_1_SCR_REG	   = 32'h0000_301C;  // RW (LCR(7) = X
parameter           UART_1_DLL_REG	   = 32'h0000_3000;  // RW (LCR(7) = 1
parameter           UART_1_DLM_REG	   = 32'h0000_3004;  // RW (LCR(7) = 1


/*************
* Module I/O *
*************/
// Inputs
 // System
input            clk                         ;
input            reset			             ;

// Read and Write Control
input [(PLB_PSB_FPGA_REG_LSB_DECODE+1):31]  addr;
input            wr_en_pulse                 ;
input            rd_en_pulse                 ;
input            plb_npsb                    ; // 1 indicates PLB access; 0 indicates PSB access
input [0:31]     write_data                  ;

 // UART 16550 Port 0 Registers
  // PPC405
input [7:0]      uart_ppc0_rbr_rbr         	   ;
input [1:0]      uart_ppc0_iir_fifoen      	   ;
input [2:0]      uart_ppc0_iir_intid2      	   ;
input            uart_ppc0_iir_intpend     	   ;
input       	 uart_ppc0_lsr_err_in_rfifo	   ;
input       	 uart_ppc0_lsr_temt        	   ;
input       	 uart_ppc0_lsr_thre        	   ;
input       	 uart_ppc0_lsr_bi          	   ;
input       	 uart_ppc0_lsr_fe          	   ;
input       	 uart_ppc0_lsr_pe          	   ;
input       	 uart_ppc0_lsr_oe          	   ;
input       	 uart_ppc0_lsr_dr          	   ;
input     	     uart_ppc0_msr_dcd         	   ;
input     	     uart_ppc0_msr_ri          	   ;
input     	     uart_ppc0_msr_dsr         	   ;
input     	     uart_ppc0_msr_cts         	   ;
input     	     uart_ppc0_msr_ddcd        	   ;
input     	     uart_ppc0_msr_teri        	   ;
input     	     uart_ppc0_msr_ddsr        	   ;
input     	     uart_ppc0_msr_dcts        	   ;

  // HOST
input [7:0]      uart_host0_rbr_rbr         	   ;
input [1:0]      uart_host0_iir_fifoen      	   ;
input [2:0]      uart_host0_iir_intid2      	   ;
input            uart_host0_iir_intpend     	   ;
input       	 uart_host0_lsr_err_in_rfifo	   ;
input       	 uart_host0_lsr_temt        	   ;
input       	 uart_host0_lsr_thre        	   ;
input       	 uart_host0_lsr_bi          	   ;
input       	 uart_host0_lsr_fe          	   ;
input       	 uart_host0_lsr_pe          	   ;
input       	 uart_host0_lsr_oe          	   ;
input       	 uart_host0_lsr_dr          	   ;
input     	     uart_host0_msr_dcd         	   ;
input     	     uart_host0_msr_ri          	   ;
input     	     uart_host0_msr_dsr         	   ;
input     	     uart_host0_msr_cts         	   ;
input     	     uart_host0_msr_ddcd        	   ;
input     	     uart_host0_msr_teri        	   ;
input     	     uart_host0_msr_ddsr        	   ;
input     	     uart_host0_msr_dcts        	   ;

 // UART 16550 Port 1 Registers
  // PPC405
input [7:0]      uart_ppc1_rbr_rbr         	   ;
input [1:0]      uart_ppc1_iir_fifoen      	   ;
input [2:0]      uart_ppc1_iir_intid2      	   ;
input            uart_ppc1_iir_intpend     	   ;
input       	 uart_ppc1_lsr_err_in_rfifo	   ;
input       	 uart_ppc1_lsr_temt        	   ;
input       	 uart_ppc1_lsr_thre        	   ;
input       	 uart_ppc1_lsr_bi          	   ;
input       	 uart_ppc1_lsr_fe          	   ;
input       	 uart_ppc1_lsr_pe          	   ;
input       	 uart_ppc1_lsr_oe          	   ;
input       	 uart_ppc1_lsr_dr          	   ;
input     	     uart_ppc1_msr_dcd         	   ;
input     	     uart_ppc1_msr_ri          	   ;
input     	     uart_ppc1_msr_dsr         	   ;
input     	     uart_ppc1_msr_cts         	   ;
input     	     uart_ppc1_msr_ddcd        	   ;
input     	     uart_ppc1_msr_teri        	   ;
input     	     uart_ppc1_msr_ddsr        	   ;
input     	     uart_ppc1_msr_dcts        	   ;

  // HOST
input [7:0]      uart_host1_rbr_rbr         	   ;
input [1:0]      uart_host1_iir_fifoen      	   ;
input [2:0]      uart_host1_iir_intid2      	   ;
input            uart_host1_iir_intpend     	   ;
input       	 uart_host1_lsr_err_in_rfifo	   ;
input       	 uart_host1_lsr_temt        	   ;
input       	 uart_host1_lsr_thre        	   ;
input       	 uart_host1_lsr_bi          	   ;
input       	 uart_host1_lsr_fe          	   ;
input       	 uart_host1_lsr_pe          	   ;
input       	 uart_host1_lsr_oe          	   ;
input       	 uart_host1_lsr_dr          	   ;
input     	     uart_host1_msr_dcd         	   ;
input     	     uart_host1_msr_ri          	   ;
input     	     uart_host1_msr_dsr         	   ;
input     	     uart_host1_msr_cts         	   ;
input     	     uart_host1_msr_ddcd        	   ;
input     	     uart_host1_msr_teri        	   ;
input     	     uart_host1_msr_ddsr        	   ;
input     	     uart_host1_msr_dcts        	   ;

// Outputs
// Read and Write Control
output reg [0:31] read_data                  ;

 // UART 16550 Port 0 Registers
  // PPC405
output reg[7:0]  uart_ppc0_thr_thr                      ;
output reg       uart_ppc0_ier_edssi                    ;
output reg       uart_ppc0_ier_elsi                     ;
output reg       uart_ppc0_ier_etbei                    ;
output reg       uart_ppc0_ier_erbfi                    ;
output reg[1:0]  uart_ppc0_fcr_rfifo_tlevel             ;
output reg       uart_ppc0_fcr_dma_mode_sel             ;
output reg       uart_ppc0_fcr_tfifo_reset              ;
output reg       uart_ppc0_fcr_rfifo_reset              ;
output reg       uart_ppc0_fcr_fifo_en                  ;
output reg       uart_ppc0_lcr_dlab                     ;
output reg       uart_ppc0_lcr_set_break                ;
output reg       uart_ppc0_lcr_stick_parity             ;
output reg       uart_ppc0_lcr_eps                      ;
output reg       uart_ppc0_lcr_pen                      ;
output reg       uart_ppc0_lcr_stb                      ;
output reg[1:0]  uart_ppc0_lcr_wls                      ;
output reg       uart_ppc0_mcr_loop                     ;
output reg       uart_ppc0_mcr_out2                     ;
output reg       uart_ppc0_mcr_out1                     ;
output reg       uart_ppc0_mcr_rts                      ;
output reg       uart_ppc0_mcr_dtr                      ;
output 		     uart_ppc0_lsr_err_in_rfifo_write_value ;
output 		     uart_ppc0_lsr_temt_write_value         ;
output 		     uart_ppc0_lsr_thre_write_value         ;
output 		     uart_ppc0_lsr_bi_write_value           ;
output 		     uart_ppc0_lsr_fe_write_value           ;
output 		     uart_ppc0_lsr_pe_write_value           ;
output 		     uart_ppc0_lsr_oe_write_value           ;
output 		     uart_ppc0_lsr_dr_write_value           ;
output           uart_ppc0_msr_dcd_write_value          ;
output           uart_ppc0_msr_ri_write_value           ;
output           uart_ppc0_msr_dsr_write_value          ;
output           uart_ppc0_msr_cts_write_value          ;
output           uart_ppc0_msr_ddcd_write_value         ;
output           uart_ppc0_msr_teri_write_value         ;
output           uart_ppc0_msr_ddsr_write_value         ;
output           uart_ppc0_msr_dcts_write_value         ;
output reg[7:0]  uart_ppc0_scr_scr                      ;
output reg[7:0]  uart_ppc0_dll_dll                      ;
output reg[7:0]  uart_ppc0_dlm_dlm                      ;
output           uart_ppc0_thr_write_pulse              ;
output 		     uart_ppc0_lsr_write_pulse              ;
output 		     uart_ppc0_msr_write_pulse              ;
output 		     uart_ppc0_rbr_read_pulse               ;
output 		     uart_ppc0_msr_read_pulse               ;
  // HOST
output reg[7:0]  uart_host0_thr_thr                      ;
output reg       uart_host0_ier_edssi                    ;
output reg       uart_host0_ier_elsi                     ;
output reg       uart_host0_ier_etbei                    ;
output reg       uart_host0_ier_erbfi                    ;
output reg[1:0]  uart_host0_fcr_rfifo_tlevel             ;
output reg       uart_host0_fcr_dma_mode_sel             ;
output reg       uart_host0_fcr_tfifo_reset              ;
output reg       uart_host0_fcr_rfifo_reset              ;
output reg       uart_host0_fcr_fifo_en                  ;
output reg       uart_host0_lcr_dlab                     ;
output reg       uart_host0_lcr_set_break                ;
output reg       uart_host0_lcr_stick_parity             ;
output reg       uart_host0_lcr_eps                      ;
output reg       uart_host0_lcr_pen                      ;
output reg       uart_host0_lcr_stb                      ;
output reg[1:0]  uart_host0_lcr_wls                      ;
output reg       uart_host0_mcr_loop                     ;
output reg       uart_host0_mcr_out2                     ;
output reg       uart_host0_mcr_out1                     ;
output reg       uart_host0_mcr_rts                      ;
output reg       uart_host0_mcr_dtr                      ;
output 		     uart_host0_lsr_err_in_rfifo_write_value ;
output 		     uart_host0_lsr_temt_write_value         ;
output 		     uart_host0_lsr_thre_write_value         ;
output 		     uart_host0_lsr_bi_write_value           ;
output 		     uart_host0_lsr_fe_write_value           ;
output 		     uart_host0_lsr_pe_write_value           ;
output 		     uart_host0_lsr_oe_write_value           ;
output 		     uart_host0_lsr_dr_write_value           ;
output           uart_host0_msr_dcd_write_value          ;
output           uart_host0_msr_ri_write_value           ;
output           uart_host0_msr_dsr_write_value          ;
output           uart_host0_msr_cts_write_value          ;
output           uart_host0_msr_ddcd_write_value         ;
output           uart_host0_msr_teri_write_value         ;
output           uart_host0_msr_ddsr_write_value         ;
output           uart_host0_msr_dcts_write_value         ;
output reg[7:0]  uart_host0_scr_scr                      ;
output reg[7:0]  uart_host0_dll_dll                      ;
output reg[7:0]  uart_host0_dlm_dlm                      ;
output           uart_host0_thr_write_pulse              ;
output 		     uart_host0_lsr_write_pulse              ;
output 		     uart_host0_msr_write_pulse              ;
output 		     uart_host0_rbr_read_pulse               ;
output 		     uart_host0_msr_read_pulse               ;
     					    
 // UART 16550 Port 1 Registers
  // PPC405
output reg[7:0]  uart_ppc1_thr_thr                      ;
output reg       uart_ppc1_ier_edssi                    ;
output reg       uart_ppc1_ier_elsi                     ;
output reg       uart_ppc1_ier_etbei                    ;
output reg       uart_ppc1_ier_erbfi                    ;
output reg[1:0]  uart_ppc1_fcr_rfifo_tlevel             ;
output reg       uart_ppc1_fcr_dma_mode_sel             ;
output reg       uart_ppc1_fcr_tfifo_reset              ;
output reg       uart_ppc1_fcr_rfifo_reset              ;
output reg       uart_ppc1_fcr_fifo_en                  ;
output reg       uart_ppc1_lcr_dlab                     ;
output reg       uart_ppc1_lcr_set_break                ;
output reg       uart_ppc1_lcr_stick_parity             ;
output reg       uart_ppc1_lcr_eps                      ;
output reg       uart_ppc1_lcr_pen                      ;
output reg       uart_ppc1_lcr_stb                      ;
output reg[1:0]  uart_ppc1_lcr_wls                      ;
output reg       uart_ppc1_mcr_loop                     ;
output reg       uart_ppc1_mcr_out2                     ;
output reg       uart_ppc1_mcr_out1                     ;
output reg       uart_ppc1_mcr_rts                      ;
output reg       uart_ppc1_mcr_dtr                      ;
output 		     uart_ppc1_lsr_err_in_rfifo_write_value ;
output 		     uart_ppc1_lsr_temt_write_value         ;
output 		     uart_ppc1_lsr_thre_write_value         ;
output 		     uart_ppc1_lsr_bi_write_value           ;
output 		     uart_ppc1_lsr_fe_write_value           ;
output 		     uart_ppc1_lsr_pe_write_value           ;
output 		     uart_ppc1_lsr_oe_write_value           ;
output 		     uart_ppc1_lsr_dr_write_value           ;
output           uart_ppc1_msr_dcd_write_value          ;
output           uart_ppc1_msr_ri_write_value           ;
output           uart_ppc1_msr_dsr_write_value          ;
output           uart_ppc1_msr_cts_write_value          ;
output           uart_ppc1_msr_ddcd_write_value         ;
output           uart_ppc1_msr_teri_write_value         ;
output           uart_ppc1_msr_ddsr_write_value         ;
output           uart_ppc1_msr_dcts_write_value         ;
output reg[7:0]  uart_ppc1_scr_scr                      ;
output reg[7:0]  uart_ppc1_dll_dll                      ;
output reg[7:0]  uart_ppc1_dlm_dlm                      ;
output           uart_ppc1_thr_write_pulse              ;
output 		     uart_ppc1_lsr_write_pulse              ;
output 		     uart_ppc1_msr_write_pulse              ;
output 		     uart_ppc1_rbr_read_pulse               ;
output 		     uart_ppc1_msr_read_pulse               ;
  // HOST
output reg[7:0]  uart_host1_thr_thr                      ;
output reg       uart_host1_ier_edssi                    ;
output reg       uart_host1_ier_elsi                     ;
output reg       uart_host1_ier_etbei                    ;
output reg       uart_host1_ier_erbfi                    ;
output reg[1:0]  uart_host1_fcr_rfifo_tlevel             ;
output reg       uart_host1_fcr_dma_mode_sel             ;
output reg       uart_host1_fcr_tfifo_reset              ;
output reg       uart_host1_fcr_rfifo_reset              ;
output reg       uart_host1_fcr_fifo_en                  ;
output reg       uart_host1_lcr_dlab                     ;
output reg       uart_host1_lcr_set_break                ;
output reg       uart_host1_lcr_stick_parity             ;
output reg       uart_host1_lcr_eps                      ;
output reg       uart_host1_lcr_pen                      ;
output reg       uart_host1_lcr_stb                      ;
output reg[1:0]  uart_host1_lcr_wls                      ;
output reg       uart_host1_mcr_loop                     ;
output reg       uart_host1_mcr_out2                     ;
output reg       uart_host1_mcr_out1                     ;
output reg       uart_host1_mcr_rts                      ;
output reg       uart_host1_mcr_dtr                      ;
output 		     uart_host1_lsr_err_in_rfifo_write_value ;
output 		     uart_host1_lsr_temt_write_value         ;
output 		     uart_host1_lsr_thre_write_value         ;
output 		     uart_host1_lsr_bi_write_value           ;
output 		     uart_host1_lsr_fe_write_value           ;
output 		     uart_host1_lsr_pe_write_value           ;
output 		     uart_host1_lsr_oe_write_value           ;
output 		     uart_host1_lsr_dr_write_value           ;
output           uart_host1_msr_dcd_write_value          ;
output           uart_host1_msr_ri_write_value           ;
output           uart_host1_msr_dsr_write_value          ;
output           uart_host1_msr_cts_write_value          ;
output           uart_host1_msr_ddcd_write_value         ;
output           uart_host1_msr_teri_write_value         ;
output           uart_host1_msr_ddsr_write_value         ;
output           uart_host1_msr_dcts_write_value         ;
output reg[7:0]  uart_host1_scr_scr                      ;
output reg[7:0]  uart_host1_dll_dll                      ;
output reg[7:0]  uart_host1_dlm_dlm                      ;
output           uart_host1_thr_write_pulse              ;
output 		     uart_host1_lsr_write_pulse              ;
output 		     uart_host1_msr_write_pulse              ;
output 		     uart_host1_rbr_read_pulse               ;
output 		     uart_host1_msr_read_pulse               ;

/********************************
* Local Reg/Wire Instantiations *
********************************/
// write enable wires
wire we_uppc0thr;
wire we_uppc0ier;
wire we_uppc0fcr;
wire we_uppc0lcr;
wire we_uppc0mcr;
wire we_uppc0lsr;
wire we_uppc0msr;
wire we_uppc0scr;
wire we_uppc0dll;
wire we_uppc0dlm;
wire we_uppc1thr;
wire we_uppc1ier;
wire we_uppc1fcr;
wire we_uppc1lcr;
wire we_uppc1mcr;
wire we_uppc1lsr;
wire we_uppc1msr;
wire we_uppc1scr;
wire we_uppc1dll;
wire we_uppc1dlm;
wire we_uhost0thr;
wire we_uhost0ier;
wire we_uhost0fcr;
wire we_uhost0lcr;
wire we_uhost0mcr;
wire we_uhost0lsr;
wire we_uhost0msr;
wire we_uhost0scr;
wire we_uhost0dll;
wire we_uhost0dlm;
wire we_uhost1thr;
wire we_uhost1ier;
wire we_uhost1fcr;
wire we_uhost1lcr;
wire we_uhost1mcr;
wire we_uhost1lsr;
wire we_uhost1msr;
wire we_uhost1scr;
wire we_uhost1dll;
wire we_uhost1dlm;

assign we_uppc0thr  = (addr == UART_0_THR_REG  && plb_npsb == 1'b1 && uart_ppc0_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uppc0ier  = (addr == UART_0_IER_REG  && plb_npsb == 1'b1 && uart_ppc0_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uppc0fcr  = (addr == UART_0_FCR_REG  && plb_npsb == 1'b1 && uart_ppc0_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uppc0lcr  = (addr == UART_0_LCR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc0mcr  = (addr == UART_0_MCR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc0lsr  = (addr == UART_0_LSR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc0msr  = (addr == UART_0_MSR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc0scr  = (addr == UART_0_SCR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc0dll  = (addr == UART_0_DLL_REG  && plb_npsb == 1'b1 && uart_ppc0_lcr_dlab == 1'b1 && wr_en_pulse);
assign we_uppc0dlm  = (addr == UART_0_DLM_REG  && plb_npsb == 1'b1 && uart_ppc0_lcr_dlab == 1'b1 && wr_en_pulse);
assign we_uhost0thr = (addr == UART_0_THR_REG  && plb_npsb == 1'b0 && uart_host0_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uhost0ier = (addr == UART_0_IER_REG  && plb_npsb == 1'b0 && uart_host0_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uhost0fcr = (addr == UART_0_FCR_REG  && plb_npsb == 1'b0 && uart_host0_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uhost0lcr = (addr == UART_0_LCR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost0mcr = (addr == UART_0_MCR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost0lsr = (addr == UART_0_LSR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost0msr = (addr == UART_0_MSR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost0scr = (addr == UART_0_SCR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost0dll = (addr == UART_0_DLL_REG  && plb_npsb == 1'b0 && uart_host0_lcr_dlab == 1'b1 && wr_en_pulse);
assign we_uhost0dlm = (addr == UART_0_DLM_REG  && plb_npsb == 1'b0 && uart_host0_lcr_dlab == 1'b1 && wr_en_pulse);

assign we_uppc1thr  = (addr == UART_1_THR_REG  && plb_npsb == 1'b1 && uart_ppc1_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uppc1ier  = (addr == UART_1_IER_REG  && plb_npsb == 1'b1 && uart_ppc1_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uppc1fcr  = (addr == UART_1_FCR_REG  && plb_npsb == 1'b1 && uart_ppc1_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uppc1lcr  = (addr == UART_1_LCR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc1mcr  = (addr == UART_1_MCR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc1lsr  = (addr == UART_1_LSR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc1msr  = (addr == UART_1_MSR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc1scr  = (addr == UART_1_SCR_REG  && plb_npsb == 1'b1 && wr_en_pulse);
assign we_uppc1dll  = (addr == UART_1_DLL_REG  && plb_npsb == 1'b1 && uart_ppc1_lcr_dlab == 1'b1 && wr_en_pulse);
assign we_uppc1dlm  = (addr == UART_1_DLM_REG  && plb_npsb == 1'b1 && uart_ppc1_lcr_dlab == 1'b1 && wr_en_pulse);
assign we_uhost1thr = (addr == UART_1_THR_REG  && plb_npsb == 1'b0 && uart_host1_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uhost1ier = (addr == UART_1_IER_REG  && plb_npsb == 1'b0 && uart_host1_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uhost1fcr = (addr == UART_1_FCR_REG  && plb_npsb == 1'b0 && uart_host1_lcr_dlab == 1'b0 && wr_en_pulse);
assign we_uhost1lcr = (addr == UART_1_LCR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost1mcr = (addr == UART_1_MCR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost1lsr = (addr == UART_1_LSR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost1msr = (addr == UART_1_MSR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost1scr = (addr == UART_1_SCR_REG  && plb_npsb == 1'b0 && wr_en_pulse);
assign we_uhost1dll = (addr == UART_1_DLL_REG  && plb_npsb == 1'b0 && uart_host1_lcr_dlab == 1'b1 && wr_en_pulse);
assign we_uhost1dlm = (addr == UART_1_DLM_REG  && plb_npsb == 1'b0 && uart_host1_lcr_dlab == 1'b1 && wr_en_pulse);


// assign write values for registers that are kept in the UART core (lsr and msr)
assign uart_ppc0_lsr_err_in_rfifo_write_value = write_data[24];
assign uart_ppc0_lsr_temt_write_value         = write_data[25];
assign uart_ppc0_lsr_thre_write_value         = write_data[26];
assign uart_ppc0_lsr_bi_write_value           = write_data[27];
assign uart_ppc0_lsr_fe_write_value           = write_data[28];
assign uart_ppc0_lsr_pe_write_value           = write_data[29];
assign uart_ppc0_lsr_oe_write_value           = write_data[30];
assign uart_ppc0_lsr_dr_write_value           = write_data[31];
assign uart_ppc0_msr_dcd_write_value          = write_data[24];
assign uart_ppc0_msr_ri_write_value           = write_data[25];
assign uart_ppc0_msr_dsr_write_value          = write_data[26];
assign uart_ppc0_msr_cts_write_value          = write_data[27];
assign uart_ppc0_msr_ddcd_write_value         = write_data[28];
assign uart_ppc0_msr_teri_write_value         = write_data[29];
assign uart_ppc0_msr_ddsr_write_value         = write_data[30];
assign uart_ppc0_msr_dcts_write_value         = write_data[31];

assign uart_host0_lsr_err_in_rfifo_write_value = write_data[24];
assign uart_host0_lsr_temt_write_value         = write_data[25];
assign uart_host0_lsr_thre_write_value         = write_data[26];
assign uart_host0_lsr_bi_write_value           = write_data[27];
assign uart_host0_lsr_fe_write_value           = write_data[28];
assign uart_host0_lsr_pe_write_value           = write_data[29];
assign uart_host0_lsr_oe_write_value           = write_data[30];
assign uart_host0_lsr_dr_write_value           = write_data[31];
assign uart_host0_msr_dcd_write_value          = write_data[24];
assign uart_host0_msr_ri_write_value           = write_data[25];
assign uart_host0_msr_dsr_write_value          = write_data[26];
assign uart_host0_msr_cts_write_value          = write_data[27];
assign uart_host0_msr_ddcd_write_value         = write_data[28];
assign uart_host0_msr_teri_write_value         = write_data[29];
assign uart_host0_msr_ddsr_write_value         = write_data[30];
assign uart_host0_msr_dcts_write_value         = write_data[31];

assign uart_ppc1_lsr_err_in_rfifo_write_value = write_data[24];
assign uart_ppc1_lsr_temt_write_value         = write_data[25];
assign uart_ppc1_lsr_thre_write_value         = write_data[26];
assign uart_ppc1_lsr_bi_write_value           = write_data[27];
assign uart_ppc1_lsr_fe_write_value           = write_data[28];
assign uart_ppc1_lsr_pe_write_value           = write_data[29];
assign uart_ppc1_lsr_oe_write_value           = write_data[30];
assign uart_ppc1_lsr_dr_write_value           = write_data[31];
assign uart_ppc1_msr_dcd_write_value          = write_data[24];
assign uart_ppc1_msr_ri_write_value           = write_data[25];
assign uart_ppc1_msr_dsr_write_value          = write_data[26];
assign uart_ppc1_msr_cts_write_value          = write_data[27];
assign uart_ppc1_msr_ddcd_write_value         = write_data[28];
assign uart_ppc1_msr_teri_write_value         = write_data[29];
assign uart_ppc1_msr_ddsr_write_value         = write_data[30];
assign uart_ppc1_msr_dcts_write_value         = write_data[31];

assign uart_host1_lsr_err_in_rfifo_write_value = write_data[24];
assign uart_host1_lsr_temt_write_value         = write_data[25];
assign uart_host1_lsr_thre_write_value         = write_data[26];
assign uart_host1_lsr_bi_write_value           = write_data[27];
assign uart_host1_lsr_fe_write_value           = write_data[28];
assign uart_host1_lsr_pe_write_value           = write_data[29];
assign uart_host1_lsr_oe_write_value           = write_data[30];
assign uart_host1_lsr_dr_write_value           = write_data[31];
assign uart_host1_msr_dcd_write_value          = write_data[24];
assign uart_host1_msr_ri_write_value           = write_data[25];
assign uart_host1_msr_dsr_write_value          = write_data[26];
assign uart_host1_msr_cts_write_value          = write_data[27];
assign uart_host1_msr_ddcd_write_value         = write_data[28];
assign uart_host1_msr_teri_write_value         = write_data[29];
assign uart_host1_msr_ddsr_write_value         = write_data[30];
assign uart_host1_msr_dcts_write_value         = write_data[31];

//assign write pulses for registers that are kept in the UART core
assign uart_ppc0_thr_write_pulse              = we_uppc0thr;
assign uart_ppc0_lsr_write_pulse              = we_uppc0lsr;
assign uart_ppc0_msr_write_pulse              = we_uppc0msr;

assign uart_host0_thr_write_pulse             = we_uhost0thr;
assign uart_host0_lsr_write_pulse             = we_uhost0lsr;
assign uart_host0_msr_write_pulse             = we_uhost0msr;

assign uart_ppc1_thr_write_pulse              = we_uppc1thr;
assign uart_ppc1_lsr_write_pulse              = we_uppc1lsr;
assign uart_ppc1_msr_write_pulse              = we_uppc1msr;

assign uart_host1_thr_write_pulse             = we_uhost1thr;
assign uart_host1_lsr_write_pulse             = we_uhost1lsr;
assign uart_host1_msr_write_pulse             = we_uhost1msr;

//assign read pulses for registers that are kept in the UART core
assign uart_ppc0_rbr_read_pulse  = (rd_en_pulse && (addr == UART_0_RBR_REG) && 
                                       plb_npsb && (uart_ppc0_lcr_dlab == 0) ) ? 1 : 0;
assign uart_ppc0_msr_read_pulse  = (rd_en_pulse && (addr == UART_0_MSR_REG) && plb_npsb) ? 1 : 0;

assign uart_host0_rbr_read_pulse = (rd_en_pulse && (addr == UART_0_RBR_REG) && 
                                       !plb_npsb && (uart_host0_lcr_dlab == 0) ) ? 1 : 0;
assign uart_host0_msr_read_pulse = (rd_en_pulse && (addr == UART_0_MSR_REG) && !plb_npsb) ? 1 : 0;

assign uart_ppc1_rbr_read_pulse  = (rd_en_pulse && (addr == UART_1_RBR_REG) && 
                                       plb_npsb && (uart_ppc1_lcr_dlab == 0) ) ? 1 : 0;
assign uart_ppc1_msr_read_pulse  = (rd_en_pulse && (addr == UART_1_MSR_REG) && plb_npsb) ? 1 : 0;

assign uart_host1_rbr_read_pulse = (rd_en_pulse && (addr == UART_1_RBR_REG) && 
                                       !plb_npsb && (uart_host1_lcr_dlab == 0) ) ? 1 : 0;
assign uart_host1_msr_read_pulse = (rd_en_pulse && (addr == UART_1_MSR_REG) && !plb_npsb) ? 1 : 0;
                                                
// Procedure / Case-Statement (Multiplexer) to READ from all registers
always @ (posedge clk or posedge reset) 
begin
    if (reset == 1'b1)
	begin
	    read_data <= 32'b0;
	end

	else
	begin
        if (rd_en_pulse)
        begin
            case (addr)

            UART_0_RBR_REG: // RBG - RO (LCR[7] = 0); DLL - RW (LCR[7] = 1)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc0_lcr_dlab == 0)
			            read_data <= {24'b0, uart_ppc0_rbr_rbr};                // 0:31
				    else
				        read_data <= {24'b0, uart_ppc0_dll_dll};                // 0:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host0_lcr_dlab == 0)
			            read_data <= {24'b0, uart_host0_rbr_rbr};               // 0:31
				    else
				        read_data <= {24'b0, uart_host0_dll_dll};               // 0:31
				end
			end

            UART_0_IER_REG: // IER - RW (LCR[7] = 0); DLM - RW (LCR[7] = 1)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc0_lcr_dlab == 0)
			            read_data <= {24'b0, 4'b0, uart_ppc0_ier_edssi,         // 0:28
			                          uart_ppc0_ier_elsi, uart_ppc0_ier_etbei, 	// 29:30
			                          uart_ppc0_ier_erbfi};						// 31
				    else
			            read_data <= {24'b0, uart_ppc0_dlm_dlm};                // 0:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host0_lcr_dlab == 0)
			            read_data <= {24'b0, 4'b0, uart_host0_ier_edssi,        // 0:28
			                          uart_host0_ier_elsi, uart_host0_ier_etbei,// 29:30
			                          uart_host0_ier_erbfi};					// 31
				    else
			            read_data <= {24'b0, uart_host0_dlm_dlm};               // 0:31
				end
			end


            UART_0_IIR_REG: // RO (LCR[7] = 0)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc0_lcr_dlab == 0)
			            read_data <= {24'b0, uart_ppc0_iir_fifoen, 2'b0,            // 0:27
			                          uart_ppc0_iir_intid2, uart_ppc0_iir_intpend}; // 28:31
				    else
				        read_data <= 32'b0;
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host0_lcr_dlab == 0)
			            read_data <= {24'b0, uart_host0_iir_fifoen, 2'b0,            // 0:27
			                          uart_host0_iir_intid2, uart_host0_iir_intpend};// 28:31
				    else
				        read_data <= 32'b0;
				end
			end


            UART_0_FCR_REG: // RO (WO if LCR[7] = 0; RO if LCR[7] = 1)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc0_lcr_dlab == 1)
			            read_data <= {24'b0, uart_ppc0_fcr_rfifo_tlevel,			// 0:25
			                          2'b0, uart_ppc0_fcr_dma_mode_sel,				// 26:28
			                          uart_ppc0_fcr_tfifo_reset,					// 29
			                          uart_ppc0_fcr_rfifo_reset,					// 30
			                          uart_ppc0_fcr_fifo_en};						// 31
				    else
				        read_data <= 32'b0;
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host0_lcr_dlab == 1)
			            read_data <= {24'b0, uart_host0_fcr_rfifo_tlevel,			// 0:25
			                          2'b0, uart_host0_fcr_dma_mode_sel,			// 26:28
			                          uart_host0_fcr_tfifo_reset,					// 29
			                          uart_host0_fcr_rfifo_reset,					// 30
			                          uart_host0_fcr_fifo_en};						// 31
				    else
				        read_data <= 32'b0;
				end
			end

            UART_0_LCR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc0_lcr_dlab,							// 0:24
			                      uart_ppc0_lcr_set_break, uart_ppc0_lcr_stick_parity,	// 25:26
			                      uart_ppc0_lcr_eps, uart_ppc0_lcr_pen,					// 27:28
			                      uart_ppc0_lcr_stb, uart_ppc0_lcr_wls};				// 29:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host0_lcr_dlab,							// 0:24
			                      uart_host0_lcr_set_break, uart_host0_lcr_stick_parity,// 25:26
			                      uart_host0_lcr_eps, uart_host0_lcr_pen,				// 27:28
			                      uart_host0_lcr_stb, uart_host0_lcr_wls};				// 29:31
				end
			end

            UART_0_MCR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, 3'b0, uart_ppc0_mcr_loop,					// 0:27
			                      uart_ppc0_mcr_out2, uart_ppc0_mcr_out1,			// 28:29
			                      uart_ppc0_mcr_rts, uart_ppc0_mcr_dtr};			// 30:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, 3'b0, uart_host0_mcr_loop,					// 0:27
			                      uart_host0_mcr_out2, uart_host0_mcr_out1,			// 28:29
			                      uart_host0_mcr_rts, uart_host0_mcr_dtr};			// 30:31
				end
			end

            UART_0_LSR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc0_lsr_err_in_rfifo, 				// 0:24
			                      uart_ppc0_lsr_temt, uart_ppc0_lsr_thre,			// 25:26
			                      uart_ppc0_lsr_bi, uart_ppc0_lsr_fe, 				// 27:28
			                      uart_ppc0_lsr_pe, uart_ppc0_lsr_oe,				// 29:30
			                      uart_ppc0_lsr_dr};								// 31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host0_lsr_err_in_rfifo, 				// 0:24
			                      uart_host0_lsr_temt, uart_host0_lsr_thre,			// 25:26
			                      uart_host0_lsr_bi, uart_host0_lsr_fe, 			// 27:28
			                      uart_host0_lsr_pe, uart_host0_lsr_oe,				// 29:30
			                      uart_host0_lsr_dr};								// 31
				end
			end

            UART_0_MSR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc0_msr_dcd,                         // 0:24
			                      uart_ppc0_msr_ri, uart_ppc0_msr_dsr,				// 25:26
			                      uart_ppc0_msr_cts, uart_ppc0_msr_ddcd, 			// 27:28
			                      uart_ppc0_msr_teri, uart_ppc0_msr_ddsr,			// 29:30
			                      uart_ppc0_msr_dcts};								// 31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host0_msr_dcd,                        // 0:24
			                      uart_host0_msr_ri, uart_host0_msr_dsr,			// 25:26
			                      uart_host0_msr_cts, uart_host0_msr_ddcd, 			// 27:28
			                      uart_host0_msr_teri, uart_host0_msr_ddsr,			// 29:30
			                      uart_host0_msr_dcts};								// 31
				end
			end

            UART_0_SCR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc0_scr_scr};                        // 0:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host0_scr_scr};                       // 0:31
				end
			end

            UART_1_RBR_REG: // RBG - RO (LCR[7] = 0); DLL - RW (LCR[7] = 1)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc1_lcr_dlab == 0)
			            read_data <= {24'b0, uart_ppc1_rbr_rbr};                // 0:31
				    else
				        read_data <= {24'b0, uart_ppc1_dll_dll};                // 0:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host1_lcr_dlab == 0)
			            read_data <= {24'b0, uart_host1_rbr_rbr};               // 0:31
				    else
				        read_data <= {24'b0, uart_host1_dll_dll};               // 0:31
				end
			end

            UART_1_IER_REG: // IER - RW (LCR[7] = 0); DLM - RW (LCR[7] = 1)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc1_lcr_dlab == 0)
			            read_data <= {24'b0, 4'b0, uart_ppc1_ier_edssi,         // 0:28
			                          uart_ppc1_ier_elsi, uart_ppc1_ier_etbei, 	// 29:30
			                          uart_ppc1_ier_erbfi};						// 31
				    else
			            read_data <= {24'b0, uart_ppc1_dlm_dlm};                // 0:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host1_lcr_dlab == 0)
			            read_data <= {24'b0, 4'b0, uart_host1_ier_edssi,        // 0:28
			                          uart_host1_ier_elsi, uart_host1_ier_etbei,// 29:30
			                          uart_host1_ier_erbfi};					// 31
				    else
			            read_data <= {24'b0, uart_host1_dlm_dlm};               // 0:31
				end
			end


            UART_1_IIR_REG: // RO (LCR[7] = 0)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc1_lcr_dlab == 0)
			            read_data <= {24'b0, uart_ppc1_iir_fifoen, 2'b0,            // 0:27
			                          uart_ppc1_iir_intid2, uart_ppc1_iir_intpend}; // 28:31
				    else
				        read_data <= 32'b0;
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host1_lcr_dlab == 0)
			            read_data <= {24'b0, uart_host1_iir_fifoen, 2'b0,            // 0:27
			                          uart_host1_iir_intid2, uart_host1_iir_intpend};// 28:31
				    else
				        read_data <= 32'b0;
				end
			end


            UART_1_FCR_REG: // RO (WO if LCR[7] = 0; RO if LCR[7] = 1)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        if (uart_ppc1_lcr_dlab == 1)
			            read_data <= {24'b0, uart_ppc1_fcr_rfifo_tlevel,			// 0:25
			                          2'b0, uart_ppc1_fcr_dma_mode_sel,				// 26:28
			                          uart_ppc1_fcr_tfifo_reset,					// 29
			                          uart_ppc1_fcr_rfifo_reset,					// 30
			                          uart_ppc1_fcr_fifo_en};						// 31
				    else
				        read_data <= 32'b0;
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        if (uart_host1_lcr_dlab == 1)
			            read_data <= {24'b0, uart_host1_fcr_rfifo_tlevel,			// 0:25
			                          2'b0, uart_host1_fcr_dma_mode_sel,			// 26:28
			                          uart_host1_fcr_tfifo_reset,					// 29
			                          uart_host1_fcr_rfifo_reset,					// 30
			                          uart_host1_fcr_fifo_en};						// 31
				    else
				        read_data <= 32'b0;
				end
			end

            UART_1_LCR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc1_lcr_dlab,							// 0:24
			                      uart_ppc1_lcr_set_break, uart_ppc1_lcr_stick_parity,	// 25:26
			                      uart_ppc1_lcr_eps, uart_ppc1_lcr_pen,					// 27:28
			                      uart_ppc1_lcr_stb, uart_ppc1_lcr_wls};				// 29:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host1_lcr_dlab,							// 0:24
			                      uart_host1_lcr_set_break, uart_host1_lcr_stick_parity,// 25:26
			                      uart_host1_lcr_eps, uart_host1_lcr_pen,				// 27:28
			                      uart_host1_lcr_stb, uart_host1_lcr_wls};				// 29:31
				end
			end

            UART_1_MCR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, 3'b0, uart_ppc1_mcr_loop,					// 0:27
			                      uart_ppc1_mcr_out2, uart_ppc1_mcr_out1,			// 28:29
			                      uart_ppc1_mcr_rts, uart_ppc1_mcr_dtr};			// 30:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, 3'b0, uart_host1_mcr_loop,					// 0:27
			                      uart_host1_mcr_out2, uart_host1_mcr_out1,			// 28:29
			                      uart_host1_mcr_rts, uart_host1_mcr_dtr};			// 30:31
				end
			end

            UART_1_LSR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc1_lsr_err_in_rfifo, 				// 0:24
			                      uart_ppc1_lsr_temt, uart_ppc1_lsr_thre,			// 25:26
			                      uart_ppc1_lsr_bi, uart_ppc1_lsr_fe, 				// 27:28
			                      uart_ppc1_lsr_pe, uart_ppc1_lsr_oe,				// 29:30
			                      uart_ppc1_lsr_dr};								// 31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host1_lsr_err_in_rfifo, 				// 0:24
			                      uart_host1_lsr_temt, uart_host1_lsr_thre,			// 25:26
			                      uart_host1_lsr_bi, uart_host1_lsr_fe, 			// 27:28
			                      uart_host1_lsr_pe, uart_host1_lsr_oe,				// 29:30
			                      uart_host1_lsr_dr};								// 31
				end
			end

            UART_1_MSR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc1_msr_dcd,                         // 0:24
			                      uart_ppc1_msr_ri, uart_ppc1_msr_dsr,				// 25:26
			                      uart_ppc1_msr_cts, uart_ppc1_msr_ddcd, 			// 27:28
			                      uart_ppc1_msr_teri, uart_ppc1_msr_ddsr,			// 29:30
			                      uart_ppc1_msr_dcts};								// 31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host1_msr_dcd,                        // 0:24
			                      uart_host1_msr_ri, uart_host1_msr_dsr,			// 25:26
			                      uart_host1_msr_cts, uart_host1_msr_ddcd, 			// 27:28
			                      uart_host1_msr_teri, uart_host1_msr_ddsr,			// 29:30
			                      uart_host1_msr_dcts};								// 31
				end
			end

            UART_1_SCR_REG: // RW (LCR[7] = X)
			begin
			    if (plb_npsb == 1'b1)
				// PLB access so must be the uart_ppc registers
				begin
			        read_data <= {24'b0, uart_ppc1_scr_scr};                        // 0:31
				end
				else
				// PSB access so must be the uart_host registers
				begin
			        read_data <= {24'b0, uart_host1_scr_scr};                       // 0:31
				end
			end

            default:
                read_data <= 32'b0;

            endcase
		end

        else // (rd_en_pulse == 0)
	    begin
		    read_data <= 32'b0;
		end
	end // reset if block
end // always block


// Procedure to WRITE to S/W Registers that are of type Read-Write (RW)
always @ (posedge clk or posedge reset)
begin
    if (reset == 1'b1)
    begin
        uart_ppc0_thr_thr           <= 8'b11111111;
		uart_ppc0_ier_edssi         <= 1'b0;
		uart_ppc0_ier_elsi          <= 1'b0;
		uart_ppc0_ier_etbei         <= 1'b0;
		uart_ppc0_ier_erbfi         <= 1'b0;
		uart_ppc0_fcr_rfifo_tlevel  <= 2'b00;
		uart_ppc0_fcr_dma_mode_sel  <= 1'b0;
		uart_ppc0_fcr_tfifo_reset   <= 1'b0;
		uart_ppc0_fcr_rfifo_reset   <= 1'b0;
		uart_ppc0_fcr_fifo_en       <= 1'b0;
		uart_ppc0_lcr_dlab          <= 1'b0;
		uart_ppc0_lcr_set_break     <= 1'b0;
		uart_ppc0_lcr_stick_parity  <= 1'b0;
		uart_ppc0_lcr_eps           <= 1'b0;
		uart_ppc0_lcr_pen           <= 1'b0;
		uart_ppc0_lcr_stb           <= 1'b0;
		uart_ppc0_lcr_wls           <= 2'b00;
		uart_ppc0_mcr_loop          <= 1'b0;
		uart_ppc0_mcr_out2          <= 1'b0;
		uart_ppc0_mcr_out1          <= 1'b0;
		uart_ppc0_mcr_rts           <= 1'b0;
		uart_ppc0_mcr_dtr           <= 1'b0;
		uart_ppc0_scr_scr           <= 8'b00000000;
		uart_ppc0_dll_dll           <= 8'b00000000;
		uart_ppc0_dlm_dlm           <= 8'b00000000;

        uart_host0_thr_thr           <= 8'b11111111;
		uart_host0_ier_edssi         <= 1'b0;
		uart_host0_ier_elsi          <= 1'b0;
		uart_host0_ier_etbei         <= 1'b0;
		uart_host0_ier_erbfi         <= 1'b0;
		uart_host0_fcr_rfifo_tlevel  <= 2'b00;
		uart_host0_fcr_dma_mode_sel  <= 1'b0;
		uart_host0_fcr_tfifo_reset   <= 1'b0;
		uart_host0_fcr_rfifo_reset   <= 1'b0;
		uart_host0_fcr_fifo_en       <= 1'b0;
		uart_host0_lcr_dlab          <= 1'b0;
		uart_host0_lcr_set_break     <= 1'b0;
		uart_host0_lcr_stick_parity  <= 1'b0;
		uart_host0_lcr_eps           <= 1'b0;
		uart_host0_lcr_pen           <= 1'b0;
		uart_host0_lcr_stb           <= 1'b0;
		uart_host0_lcr_wls           <= 2'b00;
		uart_host0_mcr_loop          <= 1'b0;
		uart_host0_mcr_out2          <= 1'b0;
		uart_host0_mcr_out1          <= 1'b0;
		uart_host0_mcr_rts           <= 1'b0;
		uart_host0_mcr_dtr           <= 1'b0;
		uart_host0_scr_scr           <= 8'b00000000;
		uart_host0_dll_dll           <= 8'b00000000;
		uart_host0_dlm_dlm           <= 8'b00000000;

        uart_ppc1_thr_thr           <= 8'b11111111;
		uart_ppc1_ier_edssi         <= 1'b0;
		uart_ppc1_ier_elsi          <= 1'b0;
		uart_ppc1_ier_etbei         <= 1'b0;
		uart_ppc1_ier_erbfi         <= 1'b0;
		uart_ppc1_fcr_rfifo_tlevel  <= 2'b00;
		uart_ppc1_fcr_dma_mode_sel  <= 1'b0;
		uart_ppc1_fcr_tfifo_reset   <= 1'b0;
		uart_ppc1_fcr_rfifo_reset   <= 1'b0;
		uart_ppc1_fcr_fifo_en       <= 1'b0;
		uart_ppc1_lcr_dlab          <= 1'b0;
		uart_ppc1_lcr_set_break     <= 1'b0;
		uart_ppc1_lcr_stick_parity  <= 1'b0;
		uart_ppc1_lcr_eps           <= 1'b0;
		uart_ppc1_lcr_pen           <= 1'b0;
		uart_ppc1_lcr_stb           <= 1'b0;
		uart_ppc1_lcr_wls           <= 2'b00;
		uart_ppc1_mcr_loop          <= 1'b0;
		uart_ppc1_mcr_out2          <= 1'b0;
		uart_ppc1_mcr_out1          <= 1'b0;
		uart_ppc1_mcr_rts           <= 1'b0;
		uart_ppc1_mcr_dtr           <= 1'b0;
		uart_ppc1_scr_scr           <= 8'b00000000;
		uart_ppc1_dll_dll           <= 8'b00000000;
		uart_ppc1_dlm_dlm           <= 8'b00000000;

        uart_host1_thr_thr           <= 8'b11111111;
		uart_host1_ier_edssi         <= 1'b0;
		uart_host1_ier_elsi          <= 1'b0;
		uart_host1_ier_etbei         <= 1'b0;
		uart_host1_ier_erbfi         <= 1'b0;
		uart_host1_fcr_rfifo_tlevel  <= 2'b00;
		uart_host1_fcr_dma_mode_sel  <= 1'b0;
		uart_host1_fcr_tfifo_reset   <= 1'b0;
		uart_host1_fcr_rfifo_reset   <= 1'b0;
		uart_host1_fcr_fifo_en       <= 1'b0;
		uart_host1_lcr_dlab          <= 1'b0;
		uart_host1_lcr_set_break     <= 1'b0;
		uart_host1_lcr_stick_parity  <= 1'b0;
		uart_host1_lcr_eps           <= 1'b0;
		uart_host1_lcr_pen           <= 1'b0;
		uart_host1_lcr_stb           <= 1'b0;
		uart_host1_lcr_wls           <= 2'b00;
		uart_host1_mcr_loop          <= 1'b0;
		uart_host1_mcr_out2          <= 1'b0;
		uart_host1_mcr_out1          <= 1'b0;
		uart_host1_mcr_rts           <= 1'b0;
		uart_host1_mcr_dtr           <= 1'b0;
		uart_host1_scr_scr           <= 8'b00000000;
		uart_host1_dll_dll           <= 8'b00000000;
		uart_host1_dlm_dlm           <= 8'b00000000;

    end
    else
    begin							 
        uart_ppc0_thr_thr           <= (we_uppc0thr) ? write_data[24:31] : uart_ppc0_thr_thr         ;
		uart_ppc0_ier_edssi         <= (we_uppc0ier) ? write_data[28]	 : uart_ppc0_ier_edssi       ;
		uart_ppc0_ier_elsi          <= (we_uppc0ier) ? write_data[29]	 : uart_ppc0_ier_elsi        ;
		uart_ppc0_ier_etbei         <= (we_uppc0ier) ? write_data[30]	 : uart_ppc0_ier_etbei       ;
		uart_ppc0_ier_erbfi         <= (we_uppc0ier) ? write_data[31]	 : uart_ppc0_ier_erbfi       ;
		uart_ppc0_fcr_rfifo_tlevel  <= (we_uppc0fcr) ? write_data[24:25] : uart_ppc0_fcr_rfifo_tlevel;
		uart_ppc0_fcr_dma_mode_sel  <= (we_uppc0fcr) ? write_data[28]	 : uart_ppc0_fcr_dma_mode_sel;
		uart_ppc0_fcr_tfifo_reset   <= (we_uppc0fcr) ? write_data[29]	 : uart_ppc0_fcr_tfifo_reset ;
		uart_ppc0_fcr_rfifo_reset   <= (we_uppc0fcr) ? write_data[30]	 : uart_ppc0_fcr_rfifo_reset ;
		uart_ppc0_fcr_fifo_en       <= (we_uppc0fcr) ? write_data[31]	 : uart_ppc0_fcr_fifo_en     ;
		uart_ppc0_lcr_dlab          <= (we_uppc0lcr) ? write_data[24]	 : uart_ppc0_lcr_dlab        ;
		uart_ppc0_lcr_set_break     <= (we_uppc0lcr) ? write_data[25]	 : uart_ppc0_lcr_set_break   ;
		uart_ppc0_lcr_stick_parity  <= (we_uppc0lcr) ? write_data[26]	 : uart_ppc0_lcr_stick_parity;
		uart_ppc0_lcr_eps           <= (we_uppc0lcr) ? write_data[27]	 : uart_ppc0_lcr_eps         ;
		uart_ppc0_lcr_pen           <= (we_uppc0lcr) ? write_data[28]	 : uart_ppc0_lcr_pen         ;
		uart_ppc0_lcr_stb           <= (we_uppc0lcr) ? write_data[29]	 : uart_ppc0_lcr_stb         ;
		uart_ppc0_lcr_wls           <= (we_uppc0lcr) ? write_data[30:31] : uart_ppc0_lcr_wls         ;
		uart_ppc0_mcr_loop          <= (we_uppc0mcr) ? write_data[27]	 : uart_ppc0_mcr_loop        ;
		uart_ppc0_mcr_out2          <= (we_uppc0mcr) ? write_data[28]	 : uart_ppc0_mcr_out2        ;
		uart_ppc0_mcr_out1          <= (we_uppc0mcr) ? write_data[29]	 : uart_ppc0_mcr_out1        ;
		uart_ppc0_mcr_rts           <= (we_uppc0mcr) ? write_data[30]	 : uart_ppc0_mcr_rts         ;
		uart_ppc0_mcr_dtr           <= (we_uppc0mcr) ? write_data[31]	 : uart_ppc0_mcr_dtr         ;
		uart_ppc0_scr_scr           <= (we_uppc0scr) ? write_data[24:31] : uart_ppc0_scr_scr         ;
		uart_ppc0_dll_dll           <= (we_uppc0dll) ? write_data[24:31] : uart_ppc0_dll_dll         ;
		uart_ppc0_dlm_dlm           <= (we_uppc0dlm) ? write_data[24:31] : uart_ppc0_dlm_dlm         ;

        uart_host0_thr_thr           <= (we_uhost0thr) ? write_data[24:31] : uart_host0_thr_thr         ;
		uart_host0_ier_edssi         <= (we_uhost0ier) ? write_data[28]	   : uart_host0_ier_edssi       ;
		uart_host0_ier_elsi          <= (we_uhost0ier) ? write_data[29]	   : uart_host0_ier_elsi        ;
		uart_host0_ier_etbei         <= (we_uhost0ier) ? write_data[30]	   : uart_host0_ier_etbei       ;
		uart_host0_ier_erbfi         <= (we_uhost0ier) ? write_data[31]	   : uart_host0_ier_erbfi       ;
		uart_host0_fcr_rfifo_tlevel  <= (we_uhost0fcr) ? write_data[24:25] : uart_host0_fcr_rfifo_tlevel;
		uart_host0_fcr_dma_mode_sel  <= (we_uhost0fcr) ? write_data[28]	   : uart_host0_fcr_dma_mode_sel;
		uart_host0_fcr_tfifo_reset   <= (we_uhost0fcr) ? write_data[29]	   : uart_host0_fcr_tfifo_reset ;
		uart_host0_fcr_rfifo_reset   <= (we_uhost0fcr) ? write_data[30]	   : uart_host0_fcr_rfifo_reset ;
		uart_host0_fcr_fifo_en       <= (we_uhost0fcr) ? write_data[31]	   : uart_host0_fcr_fifo_en     ;
		uart_host0_lcr_dlab          <= (we_uhost0lcr) ? write_data[24]	   : uart_host0_lcr_dlab        ;
		uart_host0_lcr_set_break     <= (we_uhost0lcr) ? write_data[25]	   : uart_host0_lcr_set_break   ;
		uart_host0_lcr_stick_parity  <= (we_uhost0lcr) ? write_data[26]	   : uart_host0_lcr_stick_parity;
		uart_host0_lcr_eps           <= (we_uhost0lcr) ? write_data[27]	   : uart_host0_lcr_eps         ;
		uart_host0_lcr_pen           <= (we_uhost0lcr) ? write_data[28]	   : uart_host0_lcr_pen         ;
		uart_host0_lcr_stb           <= (we_uhost0lcr) ? write_data[29]	   : uart_host0_lcr_stb         ;
		uart_host0_lcr_wls           <= (we_uhost0lcr) ? write_data[30:31] : uart_host0_lcr_wls         ;
		uart_host0_mcr_loop          <= (we_uhost0mcr) ? write_data[27]	   : uart_host0_mcr_loop        ;
		uart_host0_mcr_out2          <= (we_uhost0mcr) ? write_data[28]	   : uart_host0_mcr_out2        ;
		uart_host0_mcr_out1          <= (we_uhost0mcr) ? write_data[29]	   : uart_host0_mcr_out1        ;
		uart_host0_mcr_rts           <= (we_uhost0mcr) ? write_data[30]	   : uart_host0_mcr_rts         ;
		uart_host0_mcr_dtr           <= (we_uhost0mcr) ? write_data[31]	   : uart_host0_mcr_dtr         ;
		uart_host0_scr_scr           <= (we_uhost0scr) ? write_data[24:31] : uart_host0_scr_scr         ;
		uart_host0_dll_dll           <= (we_uhost0dll) ? write_data[24:31] : uart_host0_dll_dll         ;
		uart_host0_dlm_dlm           <= (we_uhost0dlm) ? write_data[24:31] : uart_host0_dlm_dlm         ;

        uart_ppc1_thr_thr           <= (we_uppc1thr) ? write_data[24:31] : uart_ppc1_thr_thr         ;
		uart_ppc1_ier_edssi         <= (we_uppc1ier) ? write_data[28]	 : uart_ppc1_ier_edssi       ;
		uart_ppc1_ier_elsi          <= (we_uppc1ier) ? write_data[29]	 : uart_ppc1_ier_elsi        ;
		uart_ppc1_ier_etbei         <= (we_uppc1ier) ? write_data[30]	 : uart_ppc1_ier_etbei       ;
		uart_ppc1_ier_erbfi         <= (we_uppc1ier) ? write_data[31]	 : uart_ppc1_ier_erbfi       ;
		uart_ppc1_fcr_rfifo_tlevel  <= (we_uppc1fcr) ? write_data[24:25] : uart_ppc1_fcr_rfifo_tlevel;
		uart_ppc1_fcr_dma_mode_sel  <= (we_uppc1fcr) ? write_data[28]	 : uart_ppc1_fcr_dma_mode_sel;
		uart_ppc1_fcr_tfifo_reset   <= (we_uppc1fcr) ? write_data[29]	 : uart_ppc1_fcr_tfifo_reset ;
		uart_ppc1_fcr_rfifo_reset   <= (we_uppc1fcr) ? write_data[30]	 : uart_ppc1_fcr_rfifo_reset ;
		uart_ppc1_fcr_fifo_en       <= (we_uppc1fcr) ? write_data[31]	 : uart_ppc1_fcr_fifo_en     ;
		uart_ppc1_lcr_dlab          <= (we_uppc1lcr) ? write_data[24]	 : uart_ppc1_lcr_dlab        ;
		uart_ppc1_lcr_set_break     <= (we_uppc1lcr) ? write_data[25]	 : uart_ppc1_lcr_set_break   ;
		uart_ppc1_lcr_stick_parity  <= (we_uppc1lcr) ? write_data[26]	 : uart_ppc1_lcr_stick_parity;
		uart_ppc1_lcr_eps           <= (we_uppc1lcr) ? write_data[27]	 : uart_ppc1_lcr_eps         ;
		uart_ppc1_lcr_pen           <= (we_uppc1lcr) ? write_data[28]	 : uart_ppc1_lcr_pen         ;
		uart_ppc1_lcr_stb           <= (we_uppc1lcr) ? write_data[29]	 : uart_ppc1_lcr_stb         ;
		uart_ppc1_lcr_wls           <= (we_uppc1lcr) ? write_data[30:31] : uart_ppc1_lcr_wls         ;
		uart_ppc1_mcr_loop          <= (we_uppc1mcr) ? write_data[27]	 : uart_ppc1_mcr_loop        ;
		uart_ppc1_mcr_out2          <= (we_uppc1mcr) ? write_data[28]	 : uart_ppc1_mcr_out2        ;
		uart_ppc1_mcr_out1          <= (we_uppc1mcr) ? write_data[29]	 : uart_ppc1_mcr_out1        ;
		uart_ppc1_mcr_rts           <= (we_uppc1mcr) ? write_data[30]	 : uart_ppc1_mcr_rts         ;
		uart_ppc1_mcr_dtr           <= (we_uppc1mcr) ? write_data[31]	 : uart_ppc1_mcr_dtr         ;
		uart_ppc1_scr_scr           <= (we_uppc1scr) ? write_data[24:31] : uart_ppc1_scr_scr         ;
		uart_ppc1_dll_dll           <= (we_uppc1dll) ? write_data[24:31] : uart_ppc1_dll_dll         ;
		uart_ppc1_dlm_dlm           <= (we_uppc1dlm) ? write_data[24:31] : uart_ppc1_dlm_dlm         ;

        uart_host1_thr_thr          <= (we_uhost1thr) ? write_data[24:31] : uart_host1_thr_thr         ;
		uart_host1_ier_edssi        <= (we_uhost1ier) ? write_data[28]	  : uart_host1_ier_edssi       ;
		uart_host1_ier_elsi         <= (we_uhost1ier) ? write_data[29]	  : uart_host1_ier_elsi        ;
		uart_host1_ier_etbei        <= (we_uhost1ier) ? write_data[30]	  : uart_host1_ier_etbei       ;
		uart_host1_ier_erbfi        <= (we_uhost1ier) ? write_data[31]	  : uart_host1_ier_erbfi       ;
		uart_host1_fcr_rfifo_tlevel <= (we_uhost1fcr) ? write_data[24:25] : uart_host1_fcr_rfifo_tlevel;
		uart_host1_fcr_dma_mode_sel <= (we_uhost1fcr) ? write_data[28]	  : uart_host1_fcr_dma_mode_sel;
		uart_host1_fcr_tfifo_reset  <= (we_uhost1fcr) ? write_data[29]	  : uart_host1_fcr_tfifo_reset ;
		uart_host1_fcr_rfifo_reset  <= (we_uhost1fcr) ? write_data[30]	  : uart_host1_fcr_rfifo_reset ;
		uart_host1_fcr_fifo_en      <= (we_uhost1fcr) ? write_data[31]	  : uart_host1_fcr_fifo_en     ;
		uart_host1_lcr_dlab         <= (we_uhost1lcr) ? write_data[24]	  : uart_host1_lcr_dlab        ;
		uart_host1_lcr_set_break    <= (we_uhost1lcr) ? write_data[25]	  : uart_host1_lcr_set_break   ;
		uart_host1_lcr_stick_parity <= (we_uhost1lcr) ? write_data[26]	  : uart_host1_lcr_stick_parity;
		uart_host1_lcr_eps          <= (we_uhost1lcr) ? write_data[27]	  : uart_host1_lcr_eps         ;
		uart_host1_lcr_pen          <= (we_uhost1lcr) ? write_data[28]	  : uart_host1_lcr_pen         ;
		uart_host1_lcr_stb          <= (we_uhost1lcr) ? write_data[29]	  : uart_host1_lcr_stb         ;
		uart_host1_lcr_wls          <= (we_uhost1lcr) ? write_data[30:31] : uart_host1_lcr_wls         ;
		uart_host1_mcr_loop         <= (we_uhost1mcr) ? write_data[27]	  : uart_host1_mcr_loop        ;
		uart_host1_mcr_out2         <= (we_uhost1mcr) ? write_data[28]	  : uart_host1_mcr_out2        ;
		uart_host1_mcr_out1         <= (we_uhost1mcr) ? write_data[29]	  : uart_host1_mcr_out1        ;
		uart_host1_mcr_rts          <= (we_uhost1mcr) ? write_data[30]	  : uart_host1_mcr_rts         ;
		uart_host1_mcr_dtr          <= (we_uhost1mcr) ? write_data[31]	  : uart_host1_mcr_dtr         ;
		uart_host1_scr_scr          <= (we_uhost1scr) ? write_data[24:31] : uart_host1_scr_scr         ;
		uart_host1_dll_dll          <= (we_uhost1dll) ? write_data[24:31] : uart_host1_dll_dll         ;
		uart_host1_dlm_dlm          <= (we_uhost1dlm) ? write_data[24:31] : uart_host1_dlm_dlm         ;
	end // reset if block
end // always block

endmodule
