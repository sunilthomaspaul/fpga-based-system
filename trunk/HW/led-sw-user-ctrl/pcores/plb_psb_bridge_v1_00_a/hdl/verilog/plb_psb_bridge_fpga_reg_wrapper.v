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
*  Interface between the Miscellaneous control and status registers and the
*  PSB2PLB and PLB2PSB bridges. This module provides some glue logic to allow
*  both interfaces to read and write the MCSRs. It also instantiates the MCSR.
*
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/plb_psb_bridge_fpga_reg_wrapper.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: plb_psb_bridge_fpga_reg_wrapper.v,v $
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

module plb_psb_bridge_fpga_reg_wrapper (
                             // Inputs
					          // System
					          	clk				           ,
					          	reset			           ,
					          
                              // PSB read and write logic
					          	psb_mcsr_addr      		   ,
					          	psb_mcsr_write_data		   ,
					          	psb_mcsr_wr_en_pulse	   ,
					          	psb_mcsr_rd_en_pulse	   ,

                              // PLB read and write logic
                                plb_mcsr_addr			   ,
                                plb_mcsr_write_data	       ,
                                plb_mcsr_wr_en_pulse	   ,
                                plb_mcsr_rd_en_pulse	   ,
					          
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
                              // PSB Read Data
   					          	mcsr_psb_read_data 		   , // 64 bit PSB data
					          
                              // PLB Read Data
					          	mcsr_plb_read_data		   , // 64 bit PLB data

                              // UART 16550 Port 0 Registers
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

/*************
* Module I/O *
*************/
// Inputs
 // System
input            clk                         ;
input            reset			             ;

// Read and Write Control
input [PLB_PSB_FPGA_REG_LSB_DECODE+1:31]    psb_mcsr_addr;
input [0:31]     psb_mcsr_write_data		 ;
input            psb_mcsr_wr_en_pulse		 ;
input            psb_mcsr_rd_en_pulse		 ;

// PLB read and write logic
input [PLB_PSB_FPGA_REG_LSB_DECODE+1:31]    plb_mcsr_addr;
input [0:31]     plb_mcsr_write_data	     ;
input            plb_mcsr_wr_en_pulse	     ;
input            plb_mcsr_rd_en_pulse	     ;

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
 // PSB Read Data
output [0:63]    mcsr_psb_read_data      ;
 // PLB Read Data
output [0:63]    mcsr_plb_read_data      ;

 // UART 16550 Port 0 Registers
  // PPC405
output [7:0]  uart_ppc0_thr_thr                      ;
output        uart_ppc0_ier_edssi                    ;
output        uart_ppc0_ier_elsi                     ;
output        uart_ppc0_ier_etbei                    ;
output        uart_ppc0_ier_erbfi                    ;
output [1:0]  uart_ppc0_fcr_rfifo_tlevel             ;
output        uart_ppc0_fcr_dma_mode_sel             ;
output        uart_ppc0_fcr_tfifo_reset              ;
output        uart_ppc0_fcr_rfifo_reset              ;
output        uart_ppc0_fcr_fifo_en                  ;
output        uart_ppc0_lcr_dlab                     ;
output        uart_ppc0_lcr_set_break                ;
output        uart_ppc0_lcr_stick_parity             ;
output        uart_ppc0_lcr_eps                      ;
output        uart_ppc0_lcr_pen                      ;
output        uart_ppc0_lcr_stb                      ;
output [1:0]  uart_ppc0_lcr_wls                      ;
output        uart_ppc0_mcr_loop                     ;
output        uart_ppc0_mcr_out2                     ;
output        uart_ppc0_mcr_out1                     ;
output        uart_ppc0_mcr_rts                      ;
output        uart_ppc0_mcr_dtr                      ;
output		  uart_ppc0_lsr_err_in_rfifo_write_value ;
output		  uart_ppc0_lsr_temt_write_value         ;
output		  uart_ppc0_lsr_thre_write_value         ;
output		  uart_ppc0_lsr_bi_write_value           ;
output		  uart_ppc0_lsr_fe_write_value           ;
output		  uart_ppc0_lsr_pe_write_value           ;
output		  uart_ppc0_lsr_oe_write_value           ;
output		  uart_ppc0_lsr_dr_write_value           ;
output        uart_ppc0_msr_dcd_write_value          ;
output        uart_ppc0_msr_ri_write_value           ;
output        uart_ppc0_msr_dsr_write_value          ;
output        uart_ppc0_msr_cts_write_value          ;
output        uart_ppc0_msr_ddcd_write_value         ;
output        uart_ppc0_msr_teri_write_value         ;
output        uart_ppc0_msr_ddsr_write_value         ;
output        uart_ppc0_msr_dcts_write_value         ;
output [7:0]  uart_ppc0_scr_scr                      ;
output [7:0]  uart_ppc0_dll_dll                      ;
output [7:0]  uart_ppc0_dlm_dlm                      ;
output        uart_ppc0_thr_write_pulse              ;
output		  uart_ppc0_lsr_write_pulse              ;
output		  uart_ppc0_msr_write_pulse              ;
output		  uart_ppc0_rbr_read_pulse               ;
output		  uart_ppc0_msr_read_pulse               ;
  // HOST
output [7:0]  uart_host0_thr_thr                      ;
output        uart_host0_ier_edssi                    ;
output        uart_host0_ier_elsi                     ;
output        uart_host0_ier_etbei                    ;
output        uart_host0_ier_erbfi                    ;
output [1:0]  uart_host0_fcr_rfifo_tlevel             ;
output        uart_host0_fcr_dma_mode_sel             ;
output        uart_host0_fcr_tfifo_reset              ;
output        uart_host0_fcr_rfifo_reset              ;
output        uart_host0_fcr_fifo_en                  ;
output        uart_host0_lcr_dlab                     ;
output        uart_host0_lcr_set_break                ;
output        uart_host0_lcr_stick_parity             ;
output        uart_host0_lcr_eps                      ;
output        uart_host0_lcr_pen                      ;
output        uart_host0_lcr_stb                      ;
output [1:0]  uart_host0_lcr_wls                      ;
output        uart_host0_mcr_loop                     ;
output        uart_host0_mcr_out2                     ;
output        uart_host0_mcr_out1                     ;
output        uart_host0_mcr_rts                      ;
output        uart_host0_mcr_dtr                      ;
output		  uart_host0_lsr_err_in_rfifo_write_value ;
output		  uart_host0_lsr_temt_write_value         ;
output		  uart_host0_lsr_thre_write_value         ;
output		  uart_host0_lsr_bi_write_value           ;
output		  uart_host0_lsr_fe_write_value           ;
output		  uart_host0_lsr_pe_write_value           ;
output		  uart_host0_lsr_oe_write_value           ;
output		  uart_host0_lsr_dr_write_value           ;
output        uart_host0_msr_dcd_write_value          ;
output        uart_host0_msr_ri_write_value           ;
output        uart_host0_msr_dsr_write_value          ;
output        uart_host0_msr_cts_write_value          ;
output        uart_host0_msr_ddcd_write_value         ;
output        uart_host0_msr_teri_write_value         ;
output        uart_host0_msr_ddsr_write_value         ;
output        uart_host0_msr_dcts_write_value         ;
output [7:0]  uart_host0_scr_scr                      ;
output [7:0]  uart_host0_dll_dll                      ;
output [7:0]  uart_host0_dlm_dlm                      ;
output        uart_host0_thr_write_pulse              ;
output		  uart_host0_lsr_write_pulse              ;
output		  uart_host0_msr_write_pulse              ;
output		  uart_host0_rbr_read_pulse               ;
output		  uart_host0_msr_read_pulse               ;
     					    
 // UART 16550 Port 1 Registers
  // PPC405
output [7:0]  uart_ppc1_thr_thr                      ;
output        uart_ppc1_ier_edssi                    ;
output        uart_ppc1_ier_elsi                     ;
output        uart_ppc1_ier_etbei                    ;
output        uart_ppc1_ier_erbfi                    ;
output [1:0]  uart_ppc1_fcr_rfifo_tlevel             ;
output        uart_ppc1_fcr_dma_mode_sel             ;
output        uart_ppc1_fcr_tfifo_reset              ;
output        uart_ppc1_fcr_rfifo_reset              ;
output        uart_ppc1_fcr_fifo_en                  ;
output        uart_ppc1_lcr_dlab                     ;
output        uart_ppc1_lcr_set_break                ;
output        uart_ppc1_lcr_stick_parity             ;
output        uart_ppc1_lcr_eps                      ;
output        uart_ppc1_lcr_pen                      ;
output        uart_ppc1_lcr_stb                      ;
output [1:0]  uart_ppc1_lcr_wls                      ;
output        uart_ppc1_mcr_loop                     ;
output        uart_ppc1_mcr_out2                     ;
output        uart_ppc1_mcr_out1                     ;
output        uart_ppc1_mcr_rts                      ;
output        uart_ppc1_mcr_dtr                      ;
output		  uart_ppc1_lsr_err_in_rfifo_write_value ;
output		  uart_ppc1_lsr_temt_write_value         ;
output		  uart_ppc1_lsr_thre_write_value         ;
output		  uart_ppc1_lsr_bi_write_value           ;
output		  uart_ppc1_lsr_fe_write_value           ;
output		  uart_ppc1_lsr_pe_write_value           ;
output		  uart_ppc1_lsr_oe_write_value           ;
output		  uart_ppc1_lsr_dr_write_value           ;
output        uart_ppc1_msr_dcd_write_value          ;
output        uart_ppc1_msr_ri_write_value           ;
output        uart_ppc1_msr_dsr_write_value          ;
output        uart_ppc1_msr_cts_write_value          ;
output        uart_ppc1_msr_ddcd_write_value         ;
output        uart_ppc1_msr_teri_write_value         ;
output        uart_ppc1_msr_ddsr_write_value         ;
output        uart_ppc1_msr_dcts_write_value         ;
output [7:0]  uart_ppc1_scr_scr                      ;
output [7:0]  uart_ppc1_dll_dll                      ;
output [7:0]  uart_ppc1_dlm_dlm                      ;
output        uart_ppc1_thr_write_pulse              ;
output		  uart_ppc1_lsr_write_pulse              ;
output		  uart_ppc1_msr_write_pulse              ;
output		  uart_ppc1_rbr_read_pulse               ;
output		  uart_ppc1_msr_read_pulse               ;
  // HOST
output [7:0]  uart_host1_thr_thr                      ;
output        uart_host1_ier_edssi                    ;
output        uart_host1_ier_elsi                     ;
output        uart_host1_ier_etbei                    ;
output        uart_host1_ier_erbfi                    ;
output [1:0]  uart_host1_fcr_rfifo_tlevel             ;
output        uart_host1_fcr_dma_mode_sel             ;
output        uart_host1_fcr_tfifo_reset              ;
output        uart_host1_fcr_rfifo_reset              ;
output        uart_host1_fcr_fifo_en                  ;
output        uart_host1_lcr_dlab                     ;
output        uart_host1_lcr_set_break                ;
output        uart_host1_lcr_stick_parity             ;
output        uart_host1_lcr_eps                      ;
output        uart_host1_lcr_pen                      ;
output        uart_host1_lcr_stb                      ;
output [1:0]  uart_host1_lcr_wls                      ;
output        uart_host1_mcr_loop                     ;
output        uart_host1_mcr_out2                     ;
output        uart_host1_mcr_out1                     ;
output        uart_host1_mcr_rts                      ;
output        uart_host1_mcr_dtr                      ;
output		  uart_host1_lsr_err_in_rfifo_write_value ;
output		  uart_host1_lsr_temt_write_value         ;
output		  uart_host1_lsr_thre_write_value         ;
output		  uart_host1_lsr_bi_write_value           ;
output		  uart_host1_lsr_fe_write_value           ;
output		  uart_host1_lsr_pe_write_value           ;
output		  uart_host1_lsr_oe_write_value           ;
output		  uart_host1_lsr_dr_write_value           ;
output        uart_host1_msr_dcd_write_value          ;
output        uart_host1_msr_ri_write_value           ;
output        uart_host1_msr_dsr_write_value          ;
output        uart_host1_msr_cts_write_value          ;
output        uart_host1_msr_ddcd_write_value         ;
output        uart_host1_msr_teri_write_value         ;
output        uart_host1_msr_ddsr_write_value         ;
output        uart_host1_msr_dcts_write_value         ;
output [7:0]  uart_host1_scr_scr                      ;
output [7:0]  uart_host1_dll_dll                      ;
output [7:0]  uart_host1_dlm_dlm                      ;
output        uart_host1_thr_write_pulse              ;
output		  uart_host1_lsr_write_pulse              ;
output		  uart_host1_msr_write_pulse              ;
output		  uart_host1_rbr_read_pulse               ;
output		  uart_host1_msr_read_pulse               ;

/********************************
* Local Reg/Wire Instantiations *
********************************/
// Read and Write Control
wire [PLB_PSB_FPGA_REG_LSB_DECODE+1:31]    addr;
wire            wr_en_pulse                 ;
wire            rd_en_pulse                 ;
wire            plb_npsb                    ; // 1 indicates PLB access; 0 indicates PSB access
wire [0:31]     write_data                  ;
wire [0:31]     read_data                   ;

/********************************
* Module Logic                  *
********************************/
assign addr        = (psb_mcsr_wr_en_pulse | psb_mcsr_rd_en_pulse) ? psb_mcsr_addr : plb_mcsr_addr;
assign wr_en_pulse = psb_mcsr_wr_en_pulse | plb_mcsr_wr_en_pulse;
assign rd_en_pulse = psb_mcsr_rd_en_pulse | plb_mcsr_rd_en_pulse;
assign plb_npsb    = plb_mcsr_wr_en_pulse | plb_mcsr_rd_en_pulse;
assign write_data  = (psb_mcsr_wr_en_pulse) ? psb_mcsr_write_data : plb_mcsr_write_data;

assign mcsr_psb_read_data[0:63] = {read_data, read_data};
assign mcsr_plb_read_data[0:63] = {read_data, read_data};

/********************************
* Module Instantiations         *
********************************/
defparam plb_psb_bridge_fpga_reg.PLB_PSB_FPGA_REG_LSB_DECODE   = PLB_PSB_FPGA_REG_LSB_DECODE;

plb_psb_bridge_fpga_reg plb_psb_bridge_fpga_reg (
                             // Inputs
					          // System
					         	.clk				        (clk				      ),
					         	.reset			            (reset			          ),
					         
                              // Read and Write Control
					         	.addr                       (addr                     ), 
					         	.wr_en_pulse                (wr_en_pulse              ), 
					         	.rd_en_pulse                (rd_en_pulse              ), 
					         	.plb_npsb                   (plb_npsb                 ), 
					         	.write_data                 (write_data               ), 
					         
                              // UART 16550 Port 0 Registers
							   // PPC405
								.uart_ppc0_rbr_rbr         	 (uart_ppc0_rbr_rbr         	),
								.uart_ppc0_iir_fifoen      	 (uart_ppc0_iir_fifoen      	),
								.uart_ppc0_iir_intid2      	 (uart_ppc0_iir_intid2      	),
								.uart_ppc0_iir_intpend     	 (uart_ppc0_iir_intpend     	),
								.uart_ppc0_lsr_err_in_rfifo	 (uart_ppc0_lsr_err_in_rfifo	),
								.uart_ppc0_lsr_temt        	 (uart_ppc0_lsr_temt        	),
								.uart_ppc0_lsr_thre        	 (uart_ppc0_lsr_thre        	),
								.uart_ppc0_lsr_bi          	 (uart_ppc0_lsr_bi          	),
								.uart_ppc0_lsr_fe          	 (uart_ppc0_lsr_fe          	),
								.uart_ppc0_lsr_pe          	 (uart_ppc0_lsr_pe          	),
								.uart_ppc0_lsr_oe          	 (uart_ppc0_lsr_oe          	),
								.uart_ppc0_lsr_dr          	 (uart_ppc0_lsr_dr          	),
								.uart_ppc0_msr_dcd         	 (uart_ppc0_msr_dcd         	),
								.uart_ppc0_msr_ri          	 (uart_ppc0_msr_ri          	),
								.uart_ppc0_msr_dsr         	 (uart_ppc0_msr_dsr         	),
								.uart_ppc0_msr_cts         	 (uart_ppc0_msr_cts         	),
								.uart_ppc0_msr_ddcd        	 (uart_ppc0_msr_ddcd        	),
								.uart_ppc0_msr_teri        	 (uart_ppc0_msr_teri        	),
								.uart_ppc0_msr_ddsr        	 (uart_ppc0_msr_ddsr        	),
								.uart_ppc0_msr_dcts        	 (uart_ppc0_msr_dcts        	),
							   // HOST						 
								.uart_host0_rbr_rbr          (uart_host0_rbr_rbr         	),
								.uart_host0_iir_fifoen       (uart_host0_iir_fifoen      	),
								.uart_host0_iir_intid2       (uart_host0_iir_intid2      	),
								.uart_host0_iir_intpend      (uart_host0_iir_intpend     	),
								.uart_host0_lsr_err_in_rfifo (uart_host0_lsr_err_in_rfifo	),
								.uart_host0_lsr_temt         (uart_host0_lsr_temt        	),
								.uart_host0_lsr_thre         (uart_host0_lsr_thre        	),
								.uart_host0_lsr_bi           (uart_host0_lsr_bi          	),
								.uart_host0_lsr_fe           (uart_host0_lsr_fe          	),
								.uart_host0_lsr_pe           (uart_host0_lsr_pe          	),
								.uart_host0_lsr_oe           (uart_host0_lsr_oe          	),
								.uart_host0_lsr_dr           (uart_host0_lsr_dr          	),
								.uart_host0_msr_dcd          (uart_host0_msr_dcd         	),
								.uart_host0_msr_ri           (uart_host0_msr_ri          	),
								.uart_host0_msr_dsr          (uart_host0_msr_dsr         	),
								.uart_host0_msr_cts          (uart_host0_msr_cts         	),
								.uart_host0_msr_ddcd         (uart_host0_msr_ddcd        	),
								.uart_host0_msr_teri         (uart_host0_msr_teri        	),
								.uart_host0_msr_ddsr         (uart_host0_msr_ddsr        	),
								.uart_host0_msr_dcts         (uart_host0_msr_dcts        	),
					         
					          // UART 16550 Port 1 Registers
							   // PPC405
								.uart_ppc1_rbr_rbr         	 (uart_ppc1_rbr_rbr         	),
								.uart_ppc1_iir_fifoen      	 (uart_ppc1_iir_fifoen      	),
								.uart_ppc1_iir_intid2      	 (uart_ppc1_iir_intid2      	),
								.uart_ppc1_iir_intpend     	 (uart_ppc1_iir_intpend     	),
								.uart_ppc1_lsr_err_in_rfifo	 (uart_ppc1_lsr_err_in_rfifo	),
								.uart_ppc1_lsr_temt        	 (uart_ppc1_lsr_temt        	),
								.uart_ppc1_lsr_thre        	 (uart_ppc1_lsr_thre        	),
								.uart_ppc1_lsr_bi          	 (uart_ppc1_lsr_bi          	),
								.uart_ppc1_lsr_fe          	 (uart_ppc1_lsr_fe          	),
								.uart_ppc1_lsr_pe          	 (uart_ppc1_lsr_pe          	),
								.uart_ppc1_lsr_oe          	 (uart_ppc1_lsr_oe          	),
								.uart_ppc1_lsr_dr          	 (uart_ppc1_lsr_dr          	),
								.uart_ppc1_msr_dcd         	 (uart_ppc1_msr_dcd         	),
								.uart_ppc1_msr_ri          	 (uart_ppc1_msr_ri          	),
								.uart_ppc1_msr_dsr         	 (uart_ppc1_msr_dsr         	),
								.uart_ppc1_msr_cts         	 (uart_ppc1_msr_cts         	),
								.uart_ppc1_msr_ddcd        	 (uart_ppc1_msr_ddcd        	),
								.uart_ppc1_msr_teri        	 (uart_ppc1_msr_teri        	),
								.uart_ppc1_msr_ddsr        	 (uart_ppc1_msr_ddsr        	),
								.uart_ppc1_msr_dcts        	 (uart_ppc1_msr_dcts        	),
							   // HOST
								.uart_host1_rbr_rbr          (uart_host1_rbr_rbr         	),
								.uart_host1_iir_fifoen       (uart_host1_iir_fifoen      	),
								.uart_host1_iir_intid2       (uart_host1_iir_intid2      	),
								.uart_host1_iir_intpend      (uart_host1_iir_intpend     	),
								.uart_host1_lsr_err_in_rfifo (uart_host1_lsr_err_in_rfifo	),
								.uart_host1_lsr_temt         (uart_host1_lsr_temt        	),
								.uart_host1_lsr_thre         (uart_host1_lsr_thre        	),
								.uart_host1_lsr_bi           (uart_host1_lsr_bi          	),
								.uart_host1_lsr_fe           (uart_host1_lsr_fe          	),
								.uart_host1_lsr_pe           (uart_host1_lsr_pe          	),
								.uart_host1_lsr_oe           (uart_host1_lsr_oe          	),
								.uart_host1_lsr_dr           (uart_host1_lsr_dr          	),
								.uart_host1_msr_dcd          (uart_host1_msr_dcd         	),
								.uart_host1_msr_ri           (uart_host1_msr_ri          	),
								.uart_host1_msr_dsr          (uart_host1_msr_dsr         	),
								.uart_host1_msr_cts          (uart_host1_msr_cts         	),
								.uart_host1_msr_ddcd         (uart_host1_msr_ddcd        	),
								.uart_host1_msr_teri         (uart_host1_msr_teri        	),
								.uart_host1_msr_ddsr         (uart_host1_msr_ddsr        	),
								.uart_host1_msr_dcts         (uart_host1_msr_dcts        	),


					         
                             // Outputs
                              // Read and Write Control
                                .read_data                  (read_data                ), 

                              // UART 16550 Port 0 Registers
							   // PPC405
					            .uart_ppc0_thr_thr                       (uart_ppc0_thr_thr                     	),
					       	    .uart_ppc0_ier_edssi                     (uart_ppc0_ier_edssi                   	),
					            .uart_ppc0_ier_elsi                      (uart_ppc0_ier_elsi                    	),
					       	    .uart_ppc0_ier_etbei                     (uart_ppc0_ier_etbei                   	),
					            .uart_ppc0_ier_erbfi                     (uart_ppc0_ier_erbfi                   	),
					       	    .uart_ppc0_fcr_rfifo_tlevel              (uart_ppc0_fcr_rfifo_tlevel            	),
					            .uart_ppc0_fcr_dma_mode_sel              (uart_ppc0_fcr_dma_mode_sel            	),
					       	    .uart_ppc0_fcr_tfifo_reset               (uart_ppc0_fcr_tfifo_reset             	),
					            .uart_ppc0_fcr_rfifo_reset               (uart_ppc0_fcr_rfifo_reset             	),
					       	    .uart_ppc0_fcr_fifo_en                   (uart_ppc0_fcr_fifo_en                 	),
					            .uart_ppc0_lcr_dlab                      (uart_ppc0_lcr_dlab                    	),
					       	    .uart_ppc0_lcr_set_break                 (uart_ppc0_lcr_set_break               	),
					            .uart_ppc0_lcr_stick_parity              (uart_ppc0_lcr_stick_parity            	),
					       	    .uart_ppc0_lcr_eps                       (uart_ppc0_lcr_eps                     	),
					            .uart_ppc0_lcr_pen                       (uart_ppc0_lcr_pen                     	),
					       	    .uart_ppc0_lcr_stb                       (uart_ppc0_lcr_stb                     	),
					            .uart_ppc0_lcr_wls                       (uart_ppc0_lcr_wls                     	),
					       	    .uart_ppc0_mcr_loop                      (uart_ppc0_mcr_loop                    	),
					            .uart_ppc0_mcr_out2                      (uart_ppc0_mcr_out2                    	),
					       	    .uart_ppc0_mcr_out1                      (uart_ppc0_mcr_out1                    	),
					            .uart_ppc0_mcr_rts                       (uart_ppc0_mcr_rts                     	),
					       	    .uart_ppc0_mcr_dtr                       (uart_ppc0_mcr_dtr                     	),
					            .uart_ppc0_lsr_err_in_rfifo_write_value  (uart_ppc0_lsr_err_in_rfifo_write_value	),
					       	    .uart_ppc0_lsr_temt_write_value          (uart_ppc0_lsr_temt_write_value        	),
					            .uart_ppc0_lsr_thre_write_value          (uart_ppc0_lsr_thre_write_value        	),
					       	    .uart_ppc0_lsr_bi_write_value            (uart_ppc0_lsr_bi_write_value          	),
					            .uart_ppc0_lsr_fe_write_value            (uart_ppc0_lsr_fe_write_value          	),
					       	    .uart_ppc0_lsr_pe_write_value            (uart_ppc0_lsr_pe_write_value          	),
					            .uart_ppc0_lsr_oe_write_value            (uart_ppc0_lsr_oe_write_value          	),
					       	    .uart_ppc0_lsr_dr_write_value            (uart_ppc0_lsr_dr_write_value          	),
					            .uart_ppc0_msr_dcd_write_value           (uart_ppc0_msr_dcd_write_value         	),
					       	    .uart_ppc0_msr_ri_write_value            (uart_ppc0_msr_ri_write_value          	),
					            .uart_ppc0_msr_dsr_write_value           (uart_ppc0_msr_dsr_write_value         	),
					       	    .uart_ppc0_msr_cts_write_value           (uart_ppc0_msr_cts_write_value         	),
					            .uart_ppc0_msr_ddcd_write_value          (uart_ppc0_msr_ddcd_write_value        	),
					       	    .uart_ppc0_msr_teri_write_value          (uart_ppc0_msr_teri_write_value        	),
					            .uart_ppc0_msr_ddsr_write_value          (uart_ppc0_msr_ddsr_write_value        	),
					       	    .uart_ppc0_msr_dcts_write_value          (uart_ppc0_msr_dcts_write_value        	),
					            .uart_ppc0_scr_scr                       (uart_ppc0_scr_scr                     	),
					       	    .uart_ppc0_dll_dll                       (uart_ppc0_dll_dll                     	),
					            .uart_ppc0_dlm_dlm                       (uart_ppc0_dlm_dlm                     	),
					       	    .uart_ppc0_thr_write_pulse               (uart_ppc0_thr_write_pulse             	),
					            .uart_ppc0_lsr_write_pulse               (uart_ppc0_lsr_write_pulse             	),
					       	    .uart_ppc0_msr_write_pulse               (uart_ppc0_msr_write_pulse             	),
					            .uart_ppc0_rbr_read_pulse                (uart_ppc0_rbr_read_pulse              	),
					       	    .uart_ppc0_msr_read_pulse                (uart_ppc0_msr_read_pulse              	),
							   // HOST
					            .uart_host0_thr_thr                       (uart_host0_thr_thr                     	),
					       	    .uart_host0_ier_edssi                     (uart_host0_ier_edssi                   	),
					            .uart_host0_ier_elsi                      (uart_host0_ier_elsi                    	),
					       	    .uart_host0_ier_etbei                     (uart_host0_ier_etbei                   	),
					            .uart_host0_ier_erbfi                     (uart_host0_ier_erbfi                   	),
					       	    .uart_host0_fcr_rfifo_tlevel              (uart_host0_fcr_rfifo_tlevel            	),
					            .uart_host0_fcr_dma_mode_sel              (uart_host0_fcr_dma_mode_sel            	),
					       	    .uart_host0_fcr_tfifo_reset               (uart_host0_fcr_tfifo_reset             	),
					            .uart_host0_fcr_rfifo_reset               (uart_host0_fcr_rfifo_reset             	),
					       	    .uart_host0_fcr_fifo_en                   (uart_host0_fcr_fifo_en                 	),
					            .uart_host0_lcr_dlab                      (uart_host0_lcr_dlab                    	),
					       	    .uart_host0_lcr_set_break                 (uart_host0_lcr_set_break               	),
					            .uart_host0_lcr_stick_parity              (uart_host0_lcr_stick_parity            	),
					       	    .uart_host0_lcr_eps                       (uart_host0_lcr_eps                     	),
					            .uart_host0_lcr_pen                       (uart_host0_lcr_pen                     	),
					       	    .uart_host0_lcr_stb                       (uart_host0_lcr_stb                     	),
					            .uart_host0_lcr_wls                       (uart_host0_lcr_wls                     	),
					       	    .uart_host0_mcr_loop                      (uart_host0_mcr_loop                    	),
					            .uart_host0_mcr_out2                      (uart_host0_mcr_out2                    	),
					       	    .uart_host0_mcr_out1                      (uart_host0_mcr_out1                    	),
					            .uart_host0_mcr_rts                       (uart_host0_mcr_rts                     	),
					       	    .uart_host0_mcr_dtr                       (uart_host0_mcr_dtr                     	),
					            .uart_host0_lsr_err_in_rfifo_write_value  (uart_host0_lsr_err_in_rfifo_write_value	),
					       	    .uart_host0_lsr_temt_write_value          (uart_host0_lsr_temt_write_value        	),
					            .uart_host0_lsr_thre_write_value          (uart_host0_lsr_thre_write_value        	),
					       	    .uart_host0_lsr_bi_write_value            (uart_host0_lsr_bi_write_value          	),
					            .uart_host0_lsr_fe_write_value            (uart_host0_lsr_fe_write_value          	),
					       	    .uart_host0_lsr_pe_write_value            (uart_host0_lsr_pe_write_value          	),
					            .uart_host0_lsr_oe_write_value            (uart_host0_lsr_oe_write_value          	),
					       	    .uart_host0_lsr_dr_write_value            (uart_host0_lsr_dr_write_value          	),
					            .uart_host0_msr_dcd_write_value           (uart_host0_msr_dcd_write_value         	),
					       	    .uart_host0_msr_ri_write_value            (uart_host0_msr_ri_write_value          	),
					            .uart_host0_msr_dsr_write_value           (uart_host0_msr_dsr_write_value         	),
					       	    .uart_host0_msr_cts_write_value           (uart_host0_msr_cts_write_value         	),
					            .uart_host0_msr_ddcd_write_value          (uart_host0_msr_ddcd_write_value        	),
					       	    .uart_host0_msr_teri_write_value          (uart_host0_msr_teri_write_value        	),
					            .uart_host0_msr_ddsr_write_value          (uart_host0_msr_ddsr_write_value        	),
					       	    .uart_host0_msr_dcts_write_value          (uart_host0_msr_dcts_write_value        	),
					            .uart_host0_scr_scr                       (uart_host0_scr_scr                     	),
					       	    .uart_host0_dll_dll                       (uart_host0_dll_dll                     	),
					            .uart_host0_dlm_dlm                       (uart_host0_dlm_dlm                     	),
					       	    .uart_host0_thr_write_pulse               (uart_host0_thr_write_pulse             	),
					            .uart_host0_lsr_write_pulse               (uart_host0_lsr_write_pulse             	),
					       	    .uart_host0_msr_write_pulse               (uart_host0_msr_write_pulse             	),
					            .uart_host0_rbr_read_pulse                (uart_host0_rbr_read_pulse              	),
					       	    .uart_host0_msr_read_pulse                (uart_host0_msr_read_pulse              	),
							                                   					    					    
					          // UART 16550 Port 1 Registers
							   // PPC405
					            .uart_ppc1_thr_thr                       (uart_ppc1_thr_thr                     	),
					       	    .uart_ppc1_ier_edssi                     (uart_ppc1_ier_edssi                   	),
					            .uart_ppc1_ier_elsi                      (uart_ppc1_ier_elsi                    	),
					       	    .uart_ppc1_ier_etbei                     (uart_ppc1_ier_etbei                   	),
					            .uart_ppc1_ier_erbfi                     (uart_ppc1_ier_erbfi                   	),
					       	    .uart_ppc1_fcr_rfifo_tlevel              (uart_ppc1_fcr_rfifo_tlevel            	),
					            .uart_ppc1_fcr_dma_mode_sel              (uart_ppc1_fcr_dma_mode_sel            	),
					       	    .uart_ppc1_fcr_tfifo_reset               (uart_ppc1_fcr_tfifo_reset             	),
					            .uart_ppc1_fcr_rfifo_reset               (uart_ppc1_fcr_rfifo_reset             	),
					       	    .uart_ppc1_fcr_fifo_en                   (uart_ppc1_fcr_fifo_en                 	),
					            .uart_ppc1_lcr_dlab                      (uart_ppc1_lcr_dlab                    	),
					       	    .uart_ppc1_lcr_set_break                 (uart_ppc1_lcr_set_break               	),
					            .uart_ppc1_lcr_stick_parity              (uart_ppc1_lcr_stick_parity            	),
					       	    .uart_ppc1_lcr_eps                       (uart_ppc1_lcr_eps                     	),
					            .uart_ppc1_lcr_pen                       (uart_ppc1_lcr_pen                     	),
					       	    .uart_ppc1_lcr_stb                       (uart_ppc1_lcr_stb                     	),
					            .uart_ppc1_lcr_wls                       (uart_ppc1_lcr_wls                     	),
					       	    .uart_ppc1_mcr_loop                      (uart_ppc1_mcr_loop                    	),
					            .uart_ppc1_mcr_out2                      (uart_ppc1_mcr_out2                    	),
					       	    .uart_ppc1_mcr_out1                      (uart_ppc1_mcr_out1                    	),
					            .uart_ppc1_mcr_rts                       (uart_ppc1_mcr_rts                     	),
					       	    .uart_ppc1_mcr_dtr                       (uart_ppc1_mcr_dtr                     	),
					            .uart_ppc1_lsr_err_in_rfifo_write_value  (uart_ppc1_lsr_err_in_rfifo_write_value	),
					       	    .uart_ppc1_lsr_temt_write_value          (uart_ppc1_lsr_temt_write_value        	),
					            .uart_ppc1_lsr_thre_write_value          (uart_ppc1_lsr_thre_write_value        	),
					       	    .uart_ppc1_lsr_bi_write_value            (uart_ppc1_lsr_bi_write_value          	),
					            .uart_ppc1_lsr_fe_write_value            (uart_ppc1_lsr_fe_write_value          	),
					       	    .uart_ppc1_lsr_pe_write_value            (uart_ppc1_lsr_pe_write_value          	),
					            .uart_ppc1_lsr_oe_write_value            (uart_ppc1_lsr_oe_write_value          	),
					       	    .uart_ppc1_lsr_dr_write_value            (uart_ppc1_lsr_dr_write_value          	),
					            .uart_ppc1_msr_dcd_write_value           (uart_ppc1_msr_dcd_write_value         	),
					       	    .uart_ppc1_msr_ri_write_value            (uart_ppc1_msr_ri_write_value          	),
					            .uart_ppc1_msr_dsr_write_value           (uart_ppc1_msr_dsr_write_value         	),
					       	    .uart_ppc1_msr_cts_write_value           (uart_ppc1_msr_cts_write_value         	),
					            .uart_ppc1_msr_ddcd_write_value          (uart_ppc1_msr_ddcd_write_value        	),
					       	    .uart_ppc1_msr_teri_write_value          (uart_ppc1_msr_teri_write_value        	),
					            .uart_ppc1_msr_ddsr_write_value          (uart_ppc1_msr_ddsr_write_value        	),
					       	    .uart_ppc1_msr_dcts_write_value          (uart_ppc1_msr_dcts_write_value        	),
					            .uart_ppc1_scr_scr                       (uart_ppc1_scr_scr                     	),
					       	    .uart_ppc1_dll_dll                       (uart_ppc1_dll_dll                     	),
					            .uart_ppc1_dlm_dlm                       (uart_ppc1_dlm_dlm                     	),
					       	    .uart_ppc1_thr_write_pulse               (uart_ppc1_thr_write_pulse             	),
					            .uart_ppc1_lsr_write_pulse               (uart_ppc1_lsr_write_pulse             	),
					       	    .uart_ppc1_msr_write_pulse               (uart_ppc1_msr_write_pulse             	),
					            .uart_ppc1_rbr_read_pulse                (uart_ppc1_rbr_read_pulse              	),
					       	    .uart_ppc1_msr_read_pulse                (uart_ppc1_msr_read_pulse              	),
							   // HOST
					            .uart_host1_thr_thr                      (uart_host1_thr_thr                     	),
					       	    .uart_host1_ier_edssi                    (uart_host1_ier_edssi                   	),
					            .uart_host1_ier_elsi                     (uart_host1_ier_elsi                    	),
					       	    .uart_host1_ier_etbei                    (uart_host1_ier_etbei                   	),
					            .uart_host1_ier_erbfi                    (uart_host1_ier_erbfi                   	),
					       	    .uart_host1_fcr_rfifo_tlevel             (uart_host1_fcr_rfifo_tlevel            	),
					            .uart_host1_fcr_dma_mode_sel             (uart_host1_fcr_dma_mode_sel            	),
					       	    .uart_host1_fcr_tfifo_reset              (uart_host1_fcr_tfifo_reset             	),
					            .uart_host1_fcr_rfifo_reset              (uart_host1_fcr_rfifo_reset             	),
					       	    .uart_host1_fcr_fifo_en                  (uart_host1_fcr_fifo_en                 	),
					            .uart_host1_lcr_dlab                     (uart_host1_lcr_dlab                    	),
					       	    .uart_host1_lcr_set_break                (uart_host1_lcr_set_break               	),
					            .uart_host1_lcr_stick_parity             (uart_host1_lcr_stick_parity            	),
					       	    .uart_host1_lcr_eps                      (uart_host1_lcr_eps                     	),
					            .uart_host1_lcr_pen                      (uart_host1_lcr_pen                     	),
					       	    .uart_host1_lcr_stb                      (uart_host1_lcr_stb                     	),
					            .uart_host1_lcr_wls                      (uart_host1_lcr_wls                     	),
					       	    .uart_host1_mcr_loop                     (uart_host1_mcr_loop                    	),
					            .uart_host1_mcr_out2                     (uart_host1_mcr_out2                    	),
					       	    .uart_host1_mcr_out1                     (uart_host1_mcr_out1                    	),
					            .uart_host1_mcr_rts                      (uart_host1_mcr_rts                     	),
					       	    .uart_host1_mcr_dtr                      (uart_host1_mcr_dtr                     	),
					            .uart_host1_lsr_err_in_rfifo_write_value (uart_host1_lsr_err_in_rfifo_write_value	),
					       	    .uart_host1_lsr_temt_write_value         (uart_host1_lsr_temt_write_value        	),
					            .uart_host1_lsr_thre_write_value         (uart_host1_lsr_thre_write_value        	),
					       	    .uart_host1_lsr_bi_write_value           (uart_host1_lsr_bi_write_value          	),
					            .uart_host1_lsr_fe_write_value           (uart_host1_lsr_fe_write_value          	),
					       	    .uart_host1_lsr_pe_write_value           (uart_host1_lsr_pe_write_value          	),
					            .uart_host1_lsr_oe_write_value           (uart_host1_lsr_oe_write_value          	),
					       	    .uart_host1_lsr_dr_write_value           (uart_host1_lsr_dr_write_value          	),
					            .uart_host1_msr_dcd_write_value          (uart_host1_msr_dcd_write_value         	),
					       	    .uart_host1_msr_ri_write_value           (uart_host1_msr_ri_write_value          	),
					            .uart_host1_msr_dsr_write_value          (uart_host1_msr_dsr_write_value         	),
					       	    .uart_host1_msr_cts_write_value          (uart_host1_msr_cts_write_value         	),
					            .uart_host1_msr_ddcd_write_value         (uart_host1_msr_ddcd_write_value        	),
					       	    .uart_host1_msr_teri_write_value         (uart_host1_msr_teri_write_value        	),
					            .uart_host1_msr_ddsr_write_value         (uart_host1_msr_ddsr_write_value        	),
					       	    .uart_host1_msr_dcts_write_value         (uart_host1_msr_dcts_write_value        	),
					            .uart_host1_scr_scr                      (uart_host1_scr_scr                     	),
					       	    .uart_host1_dll_dll                      (uart_host1_dll_dll                     	),
					            .uart_host1_dlm_dlm                      (uart_host1_dlm_dlm                     	),
					       	    .uart_host1_thr_write_pulse              (uart_host1_thr_write_pulse             	),
					            .uart_host1_lsr_write_pulse              (uart_host1_lsr_write_pulse             	),
					       	    .uart_host1_msr_write_pulse              (uart_host1_msr_write_pulse             	),
					            .uart_host1_rbr_read_pulse               (uart_host1_rbr_read_pulse              	),
					       	    .uart_host1_msr_read_pulse               (uart_host1_msr_read_pulse              	)
);


endmodule
