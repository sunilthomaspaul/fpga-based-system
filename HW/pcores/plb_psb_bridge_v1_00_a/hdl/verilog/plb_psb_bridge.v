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
*   This is the top level of the bidirectional PLB/PSB bridge. It instantiates
*   the psb2plb_bridge, plb2psb_bridge and the PLB_PSB_Bridge_FPGA_Reg block.
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/plb_psb_bridge.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: plb_psb_bridge.v,v $
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.6  2005/07/19 17:35:38  kuehner
* Bridge now passes 0 - 2FFFFFFF through to PLB bus (for flash/cpld accesses).
*
* Revision 1.5  2005/06/21 17:36:31  kuehner
* Added in chipscope debug bus.
*
* Revision 1.4  2005/05/03 18:47:24  kuehner
* Updated bridge to incorporate all the changes that were made
* during HW05-019 lab debugging.
*
* Revision 1.3  2005/03/10 17:44:30  kuehner
* Removed local clocking situations.
*
* Revision 1.2  2005/03/08 18:12:44  kuehner
* Added some synthesis attributes to allow PSB tristate enables to make
* use of the registers within the IOBs.
*
* Revision 1.1  2005/02/25 14:09:34  kuehner
* Initial Revision.
*
*
*
***********************************************************************/

`timescale 1 ns / 1 ps

module plb_psb_bridge (
                     // Inputs
                      // System
                         clk                       ,
                         reset                     ,

                      // PSB External Port
                         PSB_a_I                   ,
                         PSB_abb_n_I               ,
                         PSB_dbb_n_I               ,
                         PSB_tbst_n_I              ,
                         PSB_tsiz_I                ,
                         PSB_ts_n_I                ,
                         PSB_tt_I                  ,
                         PSB_aack_n_I              ,
                         PSB_artry_n_I             ,
                         PSB_d_I                   ,
                         PSB_ta_n_I                ,
                         PSB_tea_n_I               ,
                         PSB_bg_n                  ,
                         PSB_dbg_n                 ,

                      // PLB Master (for psb2plb bridge)
                         PLBma_RdWdAddr            ,
                         PLBma_RdDBus              ,
                         PLBma_AddrAck             ,
                         PLBma_RdDAck              ,
                         PLBma_WrDAck              ,
                         PLBma_rearbitrate         ,
                         PLBma_Busy                ,
                         PLBma_Err                 ,
                         PLBma_RdBTerm             ,
                         PLBma_WrBTerm             ,
                         PLBma_sSize               ,
                         PLBma_pendReq             ,
                         PLBma_pendPri             ,
                         PLBma_reqPri              ,

                      // PLB Slave (for plb2psb bridge)
                         PLBsl_ABus                ,
                         PLBsl_PAValid             ,
                         PLBsl_SAValid             ,
                         PLBsl_rdPrim              ,
                         PLBsl_wrPrim              ,
                         PLBsl_masterID            ,
                         PLBsl_abort               ,
                         PLBsl_busLock             ,
                         PLBsl_RNW                 ,
                         PLBsl_BE                  ,
                         PLBsl_MSize               ,
                         PLBsl_size                ,
                         PLBsl_type                ,
                         PLBsl_compress            ,
                         PLBsl_guarded             ,
                         PLBsl_ordered             ,
                         PLBsl_lockErr             ,
                         PLBsl_wrDBus              ,
                         PLBsl_wrBurst             ,
                         PLBsl_rdBurst             ,

                      // UART 16550 PPC0 Registers
                         ppc0_uart_to_reg_bus      ,
                        
                      // UART 16550 HOST0 Registers
                         host0_uart_to_reg_bus     ,
                        
                      // UART 16550 PPC1 Registers
                         ppc1_uart_to_reg_bus      ,
                                                   
                      // UART 16550 HOST1 Registers
                         host1_uart_to_reg_bus     ,

                     // Outputs                                    
                      // PSB External Port                         
                         PSB_a_O                    ,
                         PSB_a_T                    ,
                         PSB_abb_n_O                ,
                         PSB_abb_n_T                ,
                         PSB_dbb_n_O                ,
                         PSB_dbb_n_T                ,
                         PSB_tbst_n_O               ,
                         PSB_tbst_n_T               ,
                         PSB_tsiz_O                 ,
                         PSB_tsiz_T                 ,
                         PSB_ts_n_O                 ,
                         PSB_ts_n_T                 ,
                         PSB_tt_O                   ,
                         PSB_tt_T                   ,
                         PSB_aack_n_O               ,
                         PSB_aack_n_T               ,
                         PSB_artry_n_O              ,
                         PSB_artry_n_T              ,
                         PSB_d_O                    ,
                         PSB_d_T                    ,
                         PSB_ta_n_O                 ,
                         PSB_ta_n_T                 ,
                         PSB_tea_n_O                ,
                         PSB_tea_n_T                ,
                         PSB_br_n                   ,

                      // PLB Master (for psb2plb bridge)            
                         BGIma_request              ,
                         BGIma_ABus                 ,
                         BGIma_RNW                  ,
                         BGIma_BE                   ,
                         BGIma_size                 ,
                         BGIma_type                 ,
                         BGIma_priority             ,
                         BGIma_rdBurst              ,
                         BGIma_wrBurst              ,
                         BGIma_busLock              ,
                         BGIma_abort                ,
                         BGIma_lockErr              ,
                         BGIma_mSize                ,
                         BGIma_ordered              ,
                         BGIma_compress             ,
                         BGIma_guarded              ,
                         BGIma_wrDBus                ,
                                                                
                      // PLB Slave (for plb2psb bridge)         
                         BGOsl_addrAck              ,
                         BGOsl_SSize                ,
                         BGOsl_wait                 ,
                         BGOsl_rearbitrate          ,
                         BGOsl_wrDAck               ,
                         BGOsl_wrComp               ,
                         BGOsl_wrBTerm              ,
                         BGOsl_rdDBus               ,
                         BGOsl_rdWdAddr             ,
                         BGOsl_rdDAck               ,
                         BGOsl_rdComp               ,
                         BGOsl_rdBTerm              ,
                         BGOsl_MBusy                ,
                         BGOsl_MErr                 ,
                                                                
                      // PLB_PSB_BRIDGE_FPGA_REGISTERS
                      // UART 16550 Port 0 Registers
                      // PPC405
                         ppc0_reg_to_uart_bus       ,
                      // Host
                         host0_reg_to_uart_bus      ,
                                            
                      // UART 16550 Port 1 Registers
                      // PPC405
                         ppc1_reg_to_uart_bus       ,
                      // Host
                         host1_reg_to_uart_bus      ,
					  // Chipscope
                         debug_bus
);


/********************
* Module Parameters *
********************/
// Parameters for psb2plb_bridge
parameter PLB_MASTER_BASEADDR1   = 32'h0000_0000; // 0x00000000 - 0x1FFFFFFF
parameter PLB_MASTER_LSB_DECODE1 = 2;
parameter PLB_MASTER_BASEADDR2   = 32'h2000_0000; // 0x20000000 - 0x2FFFFFFF
parameter PLB_MASTER_LSB_DECODE2 = 3;

parameter C_PLB_PRIORITY    = 2'b00;

// Parameters for plb2psb_bridge
parameter C_BASEADDR = 32'h30000000; // This is the base and high address for the
parameter C_HIGHADDR = 32'h3FFFFFFF; // PLB slave (it covers all PLB accesses
parameter PLB_SLAVE_LSB_DECODE = 3;  // that go through the PLB2PSB bridge.)
                                     // C_HIGHADDR is not used - only for EDK

parameter C_PLB_MID_WIDTH   = 4;
parameter C_PLB_NUM_MASTERS = 16;

// Parameters for plb2psb_bridge AND psb2plb_bridge
parameter C_PLB_AWIDTH      = 32;
parameter C_PLB_DWIDTH      = 64;

parameter PLB_PSB_FPGA_REG_BASEADDR   =	32'h30002000; // 32'h30002000 - 32'h30003FFF
parameter PLB_PSB_FPGA_REG_LSB_DECODE = 18;

// Parameters that don't go anywhere (here for the sake of Xilinx EDK)
parameter C_FAMILY          = "virtex2p";

/*************
* Module I/O *
*************/
// Inputs
 // System
  input            clk                             ;
  input            reset                           ;

 // PSB External Port
  input [0:31]                PSB_a_I              ;
  input                       PSB_abb_n_I          ;
  input                       PSB_dbb_n_I          ;
  input                       PSB_tbst_n_I         ;
  input [0:3]                 PSB_tsiz_I           ;
  input                       PSB_ts_n_I           ;
  input [0:4]                 PSB_tt_I             ;
  input                       PSB_aack_n_I         ;
  input                       PSB_artry_n_I        ;
  input [0:63]                PSB_d_I              ;
  input                       PSB_ta_n_I           ;
  input                       PSB_tea_n_I          ;
  input                       PSB_bg_n             ;
  input                       PSB_dbg_n            ;

 // PLB Master (for psb2plb bridge)
  input [0:3]                 PLBma_RdWdAddr       ;
  input [0:C_PLB_DWIDTH-1]    PLBma_RdDBus         ;
  input                       PLBma_AddrAck        ;
  input                       PLBma_RdDAck         ;
  input                       PLBma_WrDAck         ;
  input                       PLBma_rearbitrate    ;
  input                       PLBma_Busy           ;
  input                       PLBma_Err            ;
  input                       PLBma_RdBTerm        ;
  input                       PLBma_WrBTerm        ;
  input [0:1]                 PLBma_sSize          ;
  input                       PLBma_pendReq        ;
  input [0:1]                 PLBma_pendPri        ;
  input [0:1]                 PLBma_reqPri         ;

 // PLB Slave (for plb2psb bridge)
  input [0:C_PLB_AWIDTH-1]    PLBsl_ABus           ;
  input                       PLBsl_PAValid        ;
  input                       PLBsl_SAValid        ;
  input                       PLBsl_rdPrim         ;
  input                       PLBsl_wrPrim         ;
  input [0:C_PLB_MID_WIDTH-1] PLBsl_masterID       ;
  input                       PLBsl_abort          ;
  input                       PLBsl_busLock        ;
  input                       PLBsl_RNW            ;
  input [0:C_PLB_DWIDTH/8-1]  PLBsl_BE             ;
  input [0:1]                 PLBsl_MSize          ;
  input [0:3]                 PLBsl_size           ;
  input [0:2]                 PLBsl_type           ;
  input                       PLBsl_compress       ;
  input                       PLBsl_guarded        ;
  input                       PLBsl_ordered        ;
  input                       PLBsl_lockErr        ;
  input [0:C_PLB_DWIDTH-1]    PLBsl_wrDBus         ;
  input                       PLBsl_wrBurst        ;
  input                       PLBsl_rdBurst        ;

 // PLB_PSB_BRIDGE_FPGA_REGISTERS
 // UART 16550 Port 0 Registers
  // PPC405
  input [29:0]     ppc0_uart_to_reg_bus            ;
                             
  // HOST
  input [29:0]     host0_uart_to_reg_bus           ;

 // UART 16550 Port 1 Registers
  // PPC405
  input [29:0]     ppc1_uart_to_reg_bus            ;

  // HOST
  input [29:0]     host1_uart_to_reg_bus           ;

// Outputs
 // PSB External Port
  output reg [0:31]       PSB_a_O         ;  // synthesis attribute equivalent_register_removal of PSB_a_O is no
  output reg [0:31]       PSB_a_T         ;  // synthesis attribute equivalent_register_removal of PSB_a_T is no
  output reg              PSB_abb_n_O     ;  // synthesis attribute equivalent_register_removal of PSB_abb_n_O is no
  output reg              PSB_abb_n_T     ;	 // synthesis attribute equivalent_register_removal of PSB_abb_n_T is no
  output reg              PSB_dbb_n_O     ;	 // synthesis attribute equivalent_register_removal of PSB_dbb_n_O is no
  output reg              PSB_dbb_n_T     ;	 // synthesis attribute equivalent_register_removal of PSB_dbb_n_T is no
  output reg              PSB_tbst_n_O    ;	 // synthesis attribute equivalent_register_removal of PSB_tbst_n_O is no
  output reg              PSB_tbst_n_T    ;	 // synthesis attribute equivalent_register_removal of PSB_tbst_n_T is no
  output reg [0:3]        PSB_tsiz_O      ;	 // synthesis attribute equivalent_register_removal of PSB_tsiz_O is no
  output reg [0:3]        PSB_tsiz_T      ;	 // synthesis attribute equivalent_register_removal of PSB_tsiz_T is no
  output reg              PSB_ts_n_O      ;	 // synthesis attribute equivalent_register_removal of PSB_ts_n_O is no
  output reg              PSB_ts_n_T      ;	 // synthesis attribute equivalent_register_removal of PSB_ts_n_T is no
  output reg [0:4]        PSB_tt_O        ;	 // synthesis attribute equivalent_register_removal of PSB_tt_O is no
  output reg [0:4]        PSB_tt_T        ;	 // synthesis attribute equivalent_register_removal of PSB_tt_T is no
  output reg              PSB_aack_n_O    ;	 // synthesis attribute equivalent_register_removal of PSB_aack_n_O is no
  output reg              PSB_aack_n_T    ;	 // synthesis attribute equivalent_register_removal of PSB_aack_n_T is no
  output reg              PSB_artry_n_O   ;	 // synthesis attribute equivalent_register_removal of PSB_artry_n_O is no
  output reg              PSB_artry_n_T   ;	 // synthesis attribute equivalent_register_removal of PSB_artry_n_T is no
  output reg [0:63]       PSB_d_O         ;	 // synthesis attribute equivalent_register_removal of PSB_d_O is no
  output reg [0:63]       PSB_d_T         ;	 // synthesis attribute equivalent_register_removal of PSB_d_T is no
  output reg              PSB_ta_n_O      ;	 // synthesis attribute equivalent_register_removal of PSB_ta_n_O is no
  output reg              PSB_ta_n_T      ;	 // synthesis attribute equivalent_register_removal of PSB_ta_n_T is no
  output reg              PSB_tea_n_O     ;	 // synthesis attribute equivalent_register_removal of PSB_tea_n_O is no
  output reg              PSB_tea_n_T     ;	 // synthesis attribute equivalent_register_removal of PSB_tea_n_T is no
  output wire             PSB_br_n        ;

 // PLB Master (for psb2plb bridge)
  output                        BGIma_request      ;
  output [0:C_PLB_AWIDTH-1]     BGIma_ABus         ;
  output                        BGIma_RNW          ;
  output [0:(C_PLB_DWIDTH/8)-1] BGIma_BE           ;
  output [0:3]                  BGIma_size         ;
  output [0:2]                  BGIma_type         ;
  output [0:1]                  BGIma_priority     ;
  output                        BGIma_rdBurst      ;
  output                        BGIma_wrBurst      ;
  output                        BGIma_busLock      ;
  output                        BGIma_abort        ;
  output                        BGIma_lockErr      ;
  output [0:1]                  BGIma_mSize        ;
  output                        BGIma_ordered      ;
  output                        BGIma_compress     ;
  output                        BGIma_guarded      ;
  output [0:C_PLB_DWIDTH-1]     BGIma_wrDBus       ;

 // PLB Slave (for plb2psb bridge)
  output                         BGOsl_addrAck      ;
  output [0:1]                   BGOsl_SSize        ;
  output                         BGOsl_wait         ;
  output                         BGOsl_rearbitrate  ;
  output                         BGOsl_wrDAck       ;
  output                         BGOsl_wrComp       ;
  output                         BGOsl_wrBTerm      ;
  output [0:C_PLB_DWIDTH-1]      BGOsl_rdDBus       ;
  output [0:3]                   BGOsl_rdWdAddr     ;
  output                         BGOsl_rdDAck       ;
  output                         BGOsl_rdComp       ;
  output                         BGOsl_rdBTerm      ;
  output [0:C_PLB_NUM_MASTERS-1] BGOsl_MBusy        ;
  output [0:C_PLB_NUM_MASTERS-1] BGOsl_MErr         ;

 // PLB_PSB_BRIDGE_FPGA_REGISTERS
 // UART 16550 Port 0 Registers
  // PPC405
  output [75:0] ppc0_reg_to_uart_bus       ;

  // HOST
  output [75:0] host0_reg_to_uart_bus      ;
                            
 // UART 16550 Port 1 Registers
  // PPC405
  output [75:0] ppc1_reg_to_uart_bus       ;

  // HOST
  output [75:0] host1_reg_to_uart_bus      ;

  // Chipscope
  output wire [254:0]    debug_bus;
  wire [63:0]            psb_plb_bridge_debug;

/********************************
* Local Reg/Wire Instantiations *
********************************/
// outputs from user_fpga_mcsr_wrapper
  // to psb2plb_bridge
  wire [0:63]  mcsr_psb_read_data;

  // to plb2psb_bridge
  wire [0:63]  mcsr_plb_read_data;

// outputs from psb2plb_bridge
  // to user_fpga_mcsr_wrapper
  wire         psb_mcsr_rd_en_pulse;
  wire         psb_mcsr_wr_en_pulse;
  wire [PLB_PSB_FPGA_REG_LSB_DECODE+1:31] psb_mcsr_addr;       
  wire [0:31]  psb_mcsr_write_data;

  // to plb2psb_bridge
  wire         accept_plb;

  // stay in this module
  wire         PSBsl_aack_n_o;  
  wire         PSBsl_aack_n_en;
  wire         PSBsl_artry_n_o;
  wire         PSBsl_artry_n_en;
  wire [0:63]  PSBsl_d_o;
  wire         PSBsl_d_en;
  wire         PSBsl_ta_n_o;
  wire         PSBsl_ta_n_en;
  wire         PSBsl_tea_n_o;
  wire         PSBsl_tea_n_en;

// outputs from plb2psb_bridge
  // to user_fpga_mcsr_wrapper
  wire         plb_mcsr_rd_en_pulse;
  wire         plb_mcsr_wr_en_pulse;
  wire [PLB_PSB_FPGA_REG_LSB_DECODE+1:31] plb_mcsr_addr;
  wire [0:31]  plb_mcsr_write_data;

  // to psb2plb_bridge
  wire         accept_psb;
  wire         dont_aack_ps2;

  // stay in this module
  wire [0:31]  PSBma_a_o;      
  wire         PSBma_a_en;     
  wire         PSBma_abb_n_o;      
  wire         PSBma_abb_n_en;     
  wire         PSBma_dbb_n_o;  
  wire         PSBma_dbb_n_en;
  wire [0:63]  PSBma_d_o;
  wire         PSBma_d_en;
  wire         PSBma_tbst_n_o; 
  wire         PSBma_tbst_n_en;
  wire [0:3]   PSBma_tsiz_o;      
  wire         PSBma_tsiz_en;  
  wire         PSBma_ts_n_o;      
  wire         PSBma_ts_n_en;  
  wire [0:4]   PSBma_tt_o;    
  wire         PSBma_tt_en;   

// wires that connect PSB external ports to internal ports of bridges
 // Inputs to PSB Slave
  reg [0:31]  PSBsl_a;     
  reg         PSBsl_tbst_n;
  reg [1:3]   PSBsl_tsiz;  
  reg         PSBsl_ts_n;  
  reg [0:4]   PSBsl_tt;    

 // Inputs to PSB Master
  reg         PSBma_aack_n;
  reg         PSBma_artry_n;
  reg         PSBma_ta_n;
  reg         PSBma_tea_n;
  reg         PSBma_abb_n;
  reg         PSBma_bg_n;
  reg         PSBma_dbg_n;

 // Inputs to PSB Slave AND PSB Master
  reg         PSBslma_dbb_n;
  reg [0:63]  PSBslma_d_i;

 // chipscope debug bus
  wire [4:0]  plb2psb_plbside_debug_bus;
  wire [82:0] plb2psb_psbside_debug_bus;
  wire [99:0] psb2plb_psbside_debug;

 // Wires for top-level assignment (to provide a single uart bus for mhs file)
  wire [7:0]   uart_ppc0_rbr_rbr               ;
  wire [1:0]   uart_ppc0_iir_fifoen            ;
  wire [2:0]   uart_ppc0_iir_intid2            ;
  wire         uart_ppc0_iir_intpend           ;
  wire         uart_ppc0_lsr_err_in_rfifo      ;
  wire         uart_ppc0_lsr_temt              ;
  wire         uart_ppc0_lsr_thre              ;
  wire         uart_ppc0_lsr_bi                ;
  wire         uart_ppc0_lsr_fe                ;
  wire         uart_ppc0_lsr_pe                ;
  wire         uart_ppc0_lsr_oe                ;
  wire         uart_ppc0_lsr_dr                ;
  wire         uart_ppc0_msr_dcd               ;
  wire         uart_ppc0_msr_ri                ;
  wire         uart_ppc0_msr_dsr               ;
  wire         uart_ppc0_msr_cts               ;
  wire         uart_ppc0_msr_ddcd              ;
  wire         uart_ppc0_msr_teri              ;
  wire         uart_ppc0_msr_ddsr              ;
  wire         uart_ppc0_msr_dcts              ;

  wire [7:0]   uart_host0_rbr_rbr              ;
  wire [1:0]   uart_host0_iir_fifoen           ;
  wire [2:0]   uart_host0_iir_intid2           ;
  wire         uart_host0_iir_intpend          ;
  wire         uart_host0_lsr_err_in_rfifo     ;
  wire         uart_host0_lsr_temt             ;
  wire         uart_host0_lsr_thre             ;
  wire         uart_host0_lsr_bi               ;
  wire         uart_host0_lsr_fe               ;
  wire         uart_host0_lsr_pe               ;
  wire         uart_host0_lsr_oe               ;
  wire         uart_host0_lsr_dr               ;
  wire         uart_host0_msr_dcd              ;
  wire         uart_host0_msr_ri               ;
  wire         uart_host0_msr_dsr              ;
  wire         uart_host0_msr_cts              ;
  wire         uart_host0_msr_ddcd             ;
  wire         uart_host0_msr_teri             ;
  wire         uart_host0_msr_ddsr             ;
  wire         uart_host0_msr_dcts             ;

  wire [7:0]   uart_ppc1_rbr_rbr               ;
  wire [1:0]   uart_ppc1_iir_fifoen            ;
  wire [2:0]   uart_ppc1_iir_intid2            ;
  wire         uart_ppc1_iir_intpend           ;
  wire         uart_ppc1_lsr_err_in_rfifo      ;
  wire         uart_ppc1_lsr_temt              ;
  wire         uart_ppc1_lsr_thre              ;
  wire         uart_ppc1_lsr_bi                ;
  wire         uart_ppc1_lsr_fe                ;
  wire         uart_ppc1_lsr_pe                ;
  wire         uart_ppc1_lsr_oe                ;
  wire         uart_ppc1_lsr_dr                ;
  wire         uart_ppc1_msr_dcd               ;
  wire         uart_ppc1_msr_ri                ;
  wire         uart_ppc1_msr_dsr               ;
  wire         uart_ppc1_msr_cts               ;
  wire         uart_ppc1_msr_ddcd              ;
  wire         uart_ppc1_msr_teri              ;
  wire         uart_ppc1_msr_ddsr              ;
  wire         uart_ppc1_msr_dcts              ;

  wire [7:0]  uart_host1_rbr_rbr              ;
  wire [1:0]  uart_host1_iir_fifoen           ;
  wire [2:0]  uart_host1_iir_intid2           ;
  wire        uart_host1_iir_intpend          ;
  wire        uart_host1_lsr_err_in_rfifo     ;
  wire        uart_host1_lsr_temt             ;
  wire        uart_host1_lsr_thre             ;
  wire        uart_host1_lsr_bi               ;
  wire        uart_host1_lsr_fe               ;
  wire        uart_host1_lsr_pe               ;
  wire        uart_host1_lsr_oe               ;
  wire        uart_host1_lsr_dr               ;
  wire        uart_host1_msr_dcd              ;
  wire        uart_host1_msr_ri               ;
  wire        uart_host1_msr_dsr              ;
  wire        uart_host1_msr_cts              ;
  wire        uart_host1_msr_ddcd             ;
  wire        uart_host1_msr_teri             ;
  wire        uart_host1_msr_ddsr             ;
  wire        uart_host1_msr_dcts             ;

 // UART 16550 Port 0 Registers
  // PPC405
  wire [7:0]  uart_ppc0_thr_thr                      ;
  wire        uart_ppc0_ier_edssi                    ;
  wire        uart_ppc0_ier_elsi                     ;
  wire        uart_ppc0_ier_etbei                    ;
  wire        uart_ppc0_ier_erbfi                    ;
  wire [1:0]  uart_ppc0_fcr_rfifo_tlevel             ;
  wire        uart_ppc0_fcr_dma_mode_sel             ;
  wire        uart_ppc0_fcr_tfifo_reset              ;
  wire        uart_ppc0_fcr_rfifo_reset              ;
  wire        uart_ppc0_fcr_fifo_en                  ;
  wire        uart_ppc0_lcr_dlab                     ;
  wire        uart_ppc0_lcr_set_break                ;
  wire        uart_ppc0_lcr_stick_parity             ;
  wire        uart_ppc0_lcr_eps                      ;
  wire        uart_ppc0_lcr_pen                      ;
  wire        uart_ppc0_lcr_stb                      ;
  wire [1:0]  uart_ppc0_lcr_wls                      ;
  wire        uart_ppc0_mcr_loop                     ;
  wire        uart_ppc0_mcr_out2                     ;
  wire        uart_ppc0_mcr_out1                     ;
  wire        uart_ppc0_mcr_rts                      ;
  wire        uart_ppc0_mcr_dtr                      ;
  wire        uart_ppc0_lsr_err_in_rfifo_write_value ;
  wire        uart_ppc0_lsr_temt_write_value         ;
  wire        uart_ppc0_lsr_thre_write_value         ;
  wire        uart_ppc0_lsr_bi_write_value           ;
  wire        uart_ppc0_lsr_fe_write_value           ;
  wire        uart_ppc0_lsr_pe_write_value           ;
  wire        uart_ppc0_lsr_oe_write_value           ;
  wire        uart_ppc0_lsr_dr_write_value           ;
  wire        uart_ppc0_msr_dcd_write_value          ;
  wire        uart_ppc0_msr_ri_write_value           ;
  wire        uart_ppc0_msr_dsr_write_value          ;
  wire        uart_ppc0_msr_cts_write_value          ;
  wire        uart_ppc0_msr_ddcd_write_value         ;
  wire        uart_ppc0_msr_teri_write_value         ;
  wire        uart_ppc0_msr_ddsr_write_value         ;
  wire        uart_ppc0_msr_dcts_write_value         ;
  wire [7:0]  uart_ppc0_scr_scr                      ;
  wire [7:0]  uart_ppc0_dll_dll                      ;
  wire [7:0]  uart_ppc0_dlm_dlm                      ;
  wire        uart_ppc0_thr_write_pulse              ;
  wire        uart_ppc0_lsr_write_pulse              ;
  wire        uart_ppc0_msr_write_pulse              ;
  wire        uart_ppc0_rbr_read_pulse               ;
  wire        uart_ppc0_msr_read_pulse               ;

  // HOST
  wire [7:0]  uart_host0_thr_thr                      ;
  wire        uart_host0_ier_edssi                    ;
  wire        uart_host0_ier_elsi                     ;
  wire        uart_host0_ier_etbei                    ;
  wire        uart_host0_ier_erbfi                    ;
  wire [1:0]  uart_host0_fcr_rfifo_tlevel             ;
  wire        uart_host0_fcr_dma_mode_sel             ;
  wire        uart_host0_fcr_tfifo_reset              ;
  wire        uart_host0_fcr_rfifo_reset              ;
  wire        uart_host0_fcr_fifo_en                  ;
  wire        uart_host0_lcr_dlab                     ;
  wire        uart_host0_lcr_set_break                ;
  wire        uart_host0_lcr_stick_parity             ;
  wire        uart_host0_lcr_eps                      ;
  wire        uart_host0_lcr_pen                      ;
  wire        uart_host0_lcr_stb                      ;
  wire [1:0]  uart_host0_lcr_wls                      ;
  wire        uart_host0_mcr_loop                     ;
  wire        uart_host0_mcr_out2                     ;
  wire        uart_host0_mcr_out1                     ;
  wire        uart_host0_mcr_rts                      ;
  wire        uart_host0_mcr_dtr                      ;
  wire        uart_host0_lsr_err_in_rfifo_write_value ;
  wire        uart_host0_lsr_temt_write_value         ;
  wire        uart_host0_lsr_thre_write_value         ;
  wire        uart_host0_lsr_bi_write_value           ;
  wire        uart_host0_lsr_fe_write_value           ;
  wire        uart_host0_lsr_pe_write_value           ;
  wire        uart_host0_lsr_oe_write_value           ;
  wire        uart_host0_lsr_dr_write_value           ;
  wire        uart_host0_msr_dcd_write_value          ;
  wire        uart_host0_msr_ri_write_value           ;
  wire        uart_host0_msr_dsr_write_value          ;
  wire        uart_host0_msr_cts_write_value          ;
  wire        uart_host0_msr_ddcd_write_value         ;
  wire        uart_host0_msr_teri_write_value         ;
  wire        uart_host0_msr_ddsr_write_value         ;
  wire        uart_host0_msr_dcts_write_value         ;
  wire [7:0]  uart_host0_scr_scr                      ;
  wire [7:0]  uart_host0_dll_dll                      ;
  wire [7:0]  uart_host0_dlm_dlm                      ;
  wire        uart_host0_thr_write_pulse              ;
  wire        uart_host0_lsr_write_pulse              ;
  wire        uart_host0_msr_write_pulse              ;
  wire        uart_host0_rbr_read_pulse               ;
  wire        uart_host0_msr_read_pulse               ;
                            
 // UART 16550 Port 1 Registers
  // PPC405
  wire [7:0]  uart_ppc1_thr_thr                      ;
  wire        uart_ppc1_ier_edssi                    ;
  wire        uart_ppc1_ier_elsi                     ;
  wire        uart_ppc1_ier_etbei                    ;
  wire        uart_ppc1_ier_erbfi                    ;
  wire [1:0]  uart_ppc1_fcr_rfifo_tlevel             ;
  wire        uart_ppc1_fcr_dma_mode_sel             ;
  wire        uart_ppc1_fcr_tfifo_reset              ;
  wire        uart_ppc1_fcr_rfifo_reset              ;
  wire        uart_ppc1_fcr_fifo_en                  ;
  wire        uart_ppc1_lcr_dlab                     ;
  wire        uart_ppc1_lcr_set_break                ;
  wire        uart_ppc1_lcr_stick_parity             ;
  wire        uart_ppc1_lcr_eps                      ;
  wire        uart_ppc1_lcr_pen                      ;
  wire        uart_ppc1_lcr_stb                      ;
  wire [1:0]  uart_ppc1_lcr_wls                      ;
  wire        uart_ppc1_mcr_loop                     ;
  wire        uart_ppc1_mcr_out2                     ;
  wire        uart_ppc1_mcr_out1                     ;
  wire        uart_ppc1_mcr_rts                      ;
  wire        uart_ppc1_mcr_dtr                      ;
  wire        uart_ppc1_lsr_err_in_rfifo_write_value ;
  wire        uart_ppc1_lsr_temt_write_value         ;
  wire        uart_ppc1_lsr_thre_write_value         ;
  wire        uart_ppc1_lsr_bi_write_value           ;
  wire        uart_ppc1_lsr_fe_write_value           ;
  wire        uart_ppc1_lsr_pe_write_value           ;
  wire        uart_ppc1_lsr_oe_write_value           ;
  wire        uart_ppc1_lsr_dr_write_value           ;
  wire        uart_ppc1_msr_dcd_write_value          ;
  wire        uart_ppc1_msr_ri_write_value           ;
  wire        uart_ppc1_msr_dsr_write_value          ;
  wire        uart_ppc1_msr_cts_write_value          ;
  wire        uart_ppc1_msr_ddcd_write_value         ;
  wire        uart_ppc1_msr_teri_write_value         ;
  wire        uart_ppc1_msr_ddsr_write_value         ;
  wire        uart_ppc1_msr_dcts_write_value         ;
  wire [7:0]  uart_ppc1_scr_scr                      ;
  wire [7:0]  uart_ppc1_dll_dll                      ;
  wire [7:0]  uart_ppc1_dlm_dlm                      ;
  wire        uart_ppc1_thr_write_pulse              ;
  wire        uart_ppc1_lsr_write_pulse              ;
  wire        uart_ppc1_msr_write_pulse              ;
  wire        uart_ppc1_rbr_read_pulse               ;
  wire        uart_ppc1_msr_read_pulse               ;
  // HOST
  wire [7:0]  uart_host1_thr_thr                      ;
  wire        uart_host1_ier_edssi                    ;
  wire        uart_host1_ier_elsi                     ;
  wire        uart_host1_ier_etbei                    ;
  wire        uart_host1_ier_erbfi                    ;
  wire [1:0]  uart_host1_fcr_rfifo_tlevel             ;
  wire        uart_host1_fcr_dma_mode_sel             ;
  wire        uart_host1_fcr_tfifo_reset              ;
  wire        uart_host1_fcr_rfifo_reset              ;
  wire        uart_host1_fcr_fifo_en                  ;
  wire        uart_host1_lcr_dlab                     ;
  wire        uart_host1_lcr_set_break                ;
  wire        uart_host1_lcr_stick_parity             ;
  wire        uart_host1_lcr_eps                      ;
  wire        uart_host1_lcr_pen                      ;
  wire        uart_host1_lcr_stb                      ;
  wire [1:0]  uart_host1_lcr_wls                      ;
  wire        uart_host1_mcr_loop                     ;
  wire        uart_host1_mcr_out2                     ;
  wire        uart_host1_mcr_out1                     ;
  wire        uart_host1_mcr_rts                      ;
  wire        uart_host1_mcr_dtr                      ;
  wire        uart_host1_lsr_err_in_rfifo_write_value ;
  wire        uart_host1_lsr_temt_write_value         ;
  wire        uart_host1_lsr_thre_write_value         ;
  wire        uart_host1_lsr_bi_write_value           ;
  wire        uart_host1_lsr_fe_write_value           ;
  wire        uart_host1_lsr_pe_write_value           ;
  wire        uart_host1_lsr_oe_write_value           ;
  wire        uart_host1_lsr_dr_write_value           ;
  wire        uart_host1_msr_dcd_write_value          ;
  wire        uart_host1_msr_ri_write_value           ;
  wire        uart_host1_msr_dsr_write_value          ;
  wire        uart_host1_msr_cts_write_value          ;
  wire        uart_host1_msr_ddcd_write_value         ;
  wire        uart_host1_msr_teri_write_value         ;
  wire        uart_host1_msr_ddsr_write_value         ;
  wire        uart_host1_msr_dcts_write_value         ;
  wire [7:0]  uart_host1_scr_scr                      ;
  wire [7:0]  uart_host1_dll_dll                      ;
  wire [7:0]  uart_host1_dlm_dlm                      ;
  wire        uart_host1_thr_write_pulse              ;
  wire        uart_host1_lsr_write_pulse              ;
  wire        uart_host1_msr_write_pulse              ;
  wire        uart_host1_rbr_read_pulse               ;
  wire        uart_host1_msr_read_pulse               ;


/********************************
* Module Logic                  *
********************************/
// Inputs from Uart pcore (make assignments from big input buses)
  assign  uart_ppc0_rbr_rbr               = ppc0_uart_to_reg_bus[7:0];
  assign  uart_ppc0_iir_fifoen            = ppc0_uart_to_reg_bus[9:8];
  assign  uart_ppc0_iir_intid2            = ppc0_uart_to_reg_bus[12:10];
  assign  uart_ppc0_iir_intpend           = ppc0_uart_to_reg_bus[13];
  assign  uart_ppc0_lsr_err_in_rfifo      = ppc0_uart_to_reg_bus[14];
  assign  uart_ppc0_lsr_temt              = ppc0_uart_to_reg_bus[15];
  assign  uart_ppc0_lsr_thre              = ppc0_uart_to_reg_bus[16];
  assign  uart_ppc0_lsr_bi                = ppc0_uart_to_reg_bus[17];
  assign  uart_ppc0_lsr_fe                = ppc0_uart_to_reg_bus[18];
  assign  uart_ppc0_lsr_pe                = ppc0_uart_to_reg_bus[19];
  assign  uart_ppc0_lsr_oe                = ppc0_uart_to_reg_bus[20];
  assign  uart_ppc0_lsr_dr                = ppc0_uart_to_reg_bus[21];
  assign  uart_ppc0_msr_dcd               = ppc0_uart_to_reg_bus[22];
  assign  uart_ppc0_msr_ri                = ppc0_uart_to_reg_bus[23];
  assign  uart_ppc0_msr_dsr               = ppc0_uart_to_reg_bus[24];
  assign  uart_ppc0_msr_cts               = ppc0_uart_to_reg_bus[25];
  assign  uart_ppc0_msr_ddcd              = ppc0_uart_to_reg_bus[26];
  assign  uart_ppc0_msr_teri              = ppc0_uart_to_reg_bus[27];
  assign  uart_ppc0_msr_ddsr              = ppc0_uart_to_reg_bus[28];
  assign  uart_ppc0_msr_dcts              = ppc0_uart_to_reg_bus[29];

  assign  uart_host0_rbr_rbr              = host0_uart_to_reg_bus[7:0];
  assign  uart_host0_iir_fifoen           = host0_uart_to_reg_bus[9:8];
  assign  uart_host0_iir_intid2           = host0_uart_to_reg_bus[12:10];
  assign  uart_host0_iir_intpend          = host0_uart_to_reg_bus[13];
  assign  uart_host0_lsr_err_in_rfifo     = host0_uart_to_reg_bus[14];
  assign  uart_host0_lsr_temt             = host0_uart_to_reg_bus[15];
  assign  uart_host0_lsr_thre             = host0_uart_to_reg_bus[16];
  assign  uart_host0_lsr_bi               = host0_uart_to_reg_bus[17];
  assign  uart_host0_lsr_fe               = host0_uart_to_reg_bus[18];
  assign  uart_host0_lsr_pe               = host0_uart_to_reg_bus[19];
  assign  uart_host0_lsr_oe               = host0_uart_to_reg_bus[20];
  assign  uart_host0_lsr_dr               = host0_uart_to_reg_bus[21];
  assign  uart_host0_msr_dcd              = host0_uart_to_reg_bus[22];
  assign  uart_host0_msr_ri               = host0_uart_to_reg_bus[23];
  assign  uart_host0_msr_dsr              = host0_uart_to_reg_bus[24];
  assign  uart_host0_msr_cts              = host0_uart_to_reg_bus[25];
  assign  uart_host0_msr_ddcd             = host0_uart_to_reg_bus[26];
  assign  uart_host0_msr_teri             = host0_uart_to_reg_bus[27];
  assign  uart_host0_msr_ddsr             = host0_uart_to_reg_bus[28];
  assign  uart_host0_msr_dcts             = host0_uart_to_reg_bus[29];

  assign  uart_ppc1_rbr_rbr               = ppc1_uart_to_reg_bus[7:0];
  assign  uart_ppc1_iir_fifoen            = ppc1_uart_to_reg_bus[9:8];
  assign  uart_ppc1_iir_intid2            = ppc1_uart_to_reg_bus[12:10];
  assign  uart_ppc1_iir_intpend           = ppc1_uart_to_reg_bus[13];
  assign  uart_ppc1_lsr_err_in_rfifo      = ppc1_uart_to_reg_bus[14];
  assign  uart_ppc1_lsr_temt              = ppc1_uart_to_reg_bus[15];
  assign  uart_ppc1_lsr_thre              = ppc1_uart_to_reg_bus[16];
  assign  uart_ppc1_lsr_bi                = ppc1_uart_to_reg_bus[17];
  assign  uart_ppc1_lsr_fe                = ppc1_uart_to_reg_bus[18];
  assign  uart_ppc1_lsr_pe                = ppc1_uart_to_reg_bus[19];
  assign  uart_ppc1_lsr_oe                = ppc1_uart_to_reg_bus[20];
  assign  uart_ppc1_lsr_dr                = ppc1_uart_to_reg_bus[21];
  assign  uart_ppc1_msr_dcd               = ppc1_uart_to_reg_bus[22];
  assign  uart_ppc1_msr_ri                = ppc1_uart_to_reg_bus[23];
  assign  uart_ppc1_msr_dsr               = ppc1_uart_to_reg_bus[24];
  assign  uart_ppc1_msr_cts               = ppc1_uart_to_reg_bus[25];
  assign  uart_ppc1_msr_ddcd              = ppc1_uart_to_reg_bus[26];
  assign  uart_ppc1_msr_teri              = ppc1_uart_to_reg_bus[27];
  assign  uart_ppc1_msr_ddsr              = ppc1_uart_to_reg_bus[28];
  assign  uart_ppc1_msr_dcts              = ppc1_uart_to_reg_bus[29];

  assign  uart_host1_rbr_rbr              = host1_uart_to_reg_bus[7:0];
  assign  uart_host1_iir_fifoen           = host1_uart_to_reg_bus[9:8];
  assign  uart_host1_iir_intid2           = host1_uart_to_reg_bus[12:10];
  assign  uart_host1_iir_intpend          = host1_uart_to_reg_bus[13];
  assign  uart_host1_lsr_err_in_rfifo     = host1_uart_to_reg_bus[14];
  assign  uart_host1_lsr_temt             = host1_uart_to_reg_bus[15];
  assign  uart_host1_lsr_thre             = host1_uart_to_reg_bus[16];
  assign  uart_host1_lsr_bi               = host1_uart_to_reg_bus[17];
  assign  uart_host1_lsr_fe               = host1_uart_to_reg_bus[18];
  assign  uart_host1_lsr_pe               = host1_uart_to_reg_bus[19];
  assign  uart_host1_lsr_oe               = host1_uart_to_reg_bus[20];
  assign  uart_host1_lsr_dr               = host1_uart_to_reg_bus[21];
  assign  uart_host1_msr_dcd              = host1_uart_to_reg_bus[22];
  assign  uart_host1_msr_ri               = host1_uart_to_reg_bus[23];
  assign  uart_host1_msr_dsr              = host1_uart_to_reg_bus[24];
  assign  uart_host1_msr_cts              = host1_uart_to_reg_bus[25];
  assign  uart_host1_msr_ddcd             = host1_uart_to_reg_bus[26];
  assign  uart_host1_msr_teri             = host1_uart_to_reg_bus[27];
  assign  uart_host1_msr_ddsr             = host1_uart_to_reg_bus[28];
  assign  uart_host1_msr_dcts             = host1_uart_to_reg_bus[29];

// Outputs to Uart pcore (make assignments from individual signals to bug bus)
  assign   ppc0_reg_to_uart_bus[7:0]   = uart_ppc0_thr_thr                      ;
  assign   ppc0_reg_to_uart_bus[8]     = uart_ppc0_ier_edssi                    ;
  assign   ppc0_reg_to_uart_bus[9]     = uart_ppc0_ier_elsi                     ;
  assign   ppc0_reg_to_uart_bus[10]    = uart_ppc0_ier_etbei                    ;
  assign   ppc0_reg_to_uart_bus[11]    = uart_ppc0_ier_erbfi                    ;
  assign   ppc0_reg_to_uart_bus[13:12] = uart_ppc0_fcr_rfifo_tlevel             ;
  assign   ppc0_reg_to_uart_bus[14]    = uart_ppc0_fcr_dma_mode_sel             ;
  assign   ppc0_reg_to_uart_bus[15]    = uart_ppc0_fcr_tfifo_reset              ;
  assign   ppc0_reg_to_uart_bus[16]    = uart_ppc0_fcr_rfifo_reset              ;
  assign   ppc0_reg_to_uart_bus[17]    = uart_ppc0_fcr_fifo_en                  ;
  assign   ppc0_reg_to_uart_bus[18]    = uart_ppc0_lcr_dlab                     ;
  assign   ppc0_reg_to_uart_bus[19]    = uart_ppc0_lcr_set_break                ;
  assign   ppc0_reg_to_uart_bus[20]    = uart_ppc0_lcr_stick_parity             ;
  assign   ppc0_reg_to_uart_bus[21]    = uart_ppc0_lcr_eps                      ;
  assign   ppc0_reg_to_uart_bus[22]    = uart_ppc0_lcr_pen                      ;
  assign   ppc0_reg_to_uart_bus[23]    = uart_ppc0_lcr_stb                      ;
  assign   ppc0_reg_to_uart_bus[25:24] = uart_ppc0_lcr_wls                      ;
  assign   ppc0_reg_to_uart_bus[26]    = uart_ppc0_mcr_loop                     ;
  assign   ppc0_reg_to_uart_bus[27]    = uart_ppc0_mcr_out2                     ;
  assign   ppc0_reg_to_uart_bus[28]    = uart_ppc0_mcr_out1                     ;
  assign   ppc0_reg_to_uart_bus[29]    = uart_ppc0_mcr_rts                      ;
  assign   ppc0_reg_to_uart_bus[30]    = uart_ppc0_mcr_dtr                      ;
  assign   ppc0_reg_to_uart_bus[31]    = uart_ppc0_lsr_err_in_rfifo_write_value ;
  assign   ppc0_reg_to_uart_bus[32]    = uart_ppc0_lsr_temt_write_value         ;
  assign   ppc0_reg_to_uart_bus[33]    = uart_ppc0_lsr_thre_write_value         ;
  assign   ppc0_reg_to_uart_bus[34]    = uart_ppc0_lsr_bi_write_value           ;
  assign   ppc0_reg_to_uart_bus[35]    = uart_ppc0_lsr_fe_write_value           ;
  assign   ppc0_reg_to_uart_bus[36]    = uart_ppc0_lsr_pe_write_value           ;
  assign   ppc0_reg_to_uart_bus[37]    = uart_ppc0_lsr_oe_write_value           ;
  assign   ppc0_reg_to_uart_bus[38]    = uart_ppc0_lsr_dr_write_value           ;
  assign   ppc0_reg_to_uart_bus[39]    = uart_ppc0_msr_dcd_write_value          ;
  assign   ppc0_reg_to_uart_bus[40]    = uart_ppc0_msr_ri_write_value           ;
  assign   ppc0_reg_to_uart_bus[41]    = uart_ppc0_msr_dsr_write_value          ;
  assign   ppc0_reg_to_uart_bus[42]    = uart_ppc0_msr_cts_write_value          ;
  assign   ppc0_reg_to_uart_bus[43]    = uart_ppc0_msr_ddcd_write_value         ;
  assign   ppc0_reg_to_uart_bus[44]    = uart_ppc0_msr_teri_write_value         ;
  assign   ppc0_reg_to_uart_bus[45]    = uart_ppc0_msr_ddsr_write_value         ;
  assign   ppc0_reg_to_uart_bus[46]    = uart_ppc0_msr_dcts_write_value         ;
  assign   ppc0_reg_to_uart_bus[54:47] = uart_ppc0_scr_scr                      ;
  assign   ppc0_reg_to_uart_bus[62:55] = uart_ppc0_dll_dll                      ;
  assign   ppc0_reg_to_uart_bus[70:63] = uart_ppc0_dlm_dlm                      ;
  assign   ppc0_reg_to_uart_bus[71]    = uart_ppc0_thr_write_pulse              ;
  assign   ppc0_reg_to_uart_bus[72]    = uart_ppc0_lsr_write_pulse              ;
  assign   ppc0_reg_to_uart_bus[73]    = uart_ppc0_msr_write_pulse              ;
  assign   ppc0_reg_to_uart_bus[74]    = uart_ppc0_rbr_read_pulse               ;
  assign   ppc0_reg_to_uart_bus[75]    = uart_ppc0_msr_read_pulse               ;

  assign   host0_reg_to_uart_bus[7:0]   = uart_host0_thr_thr                      ;
  assign   host0_reg_to_uart_bus[8]     = uart_host0_ier_edssi                    ;
  assign   host0_reg_to_uart_bus[9]     = uart_host0_ier_elsi                     ;
  assign   host0_reg_to_uart_bus[10]    = uart_host0_ier_etbei                    ;
  assign   host0_reg_to_uart_bus[11]    = uart_host0_ier_erbfi                    ;
  assign   host0_reg_to_uart_bus[13:12] = uart_host0_fcr_rfifo_tlevel             ;
  assign   host0_reg_to_uart_bus[14]    = uart_host0_fcr_dma_mode_sel             ;
  assign   host0_reg_to_uart_bus[15]    = uart_host0_fcr_tfifo_reset              ;
  assign   host0_reg_to_uart_bus[16]    = uart_host0_fcr_rfifo_reset              ;
  assign   host0_reg_to_uart_bus[17]    = uart_host0_fcr_fifo_en                  ;
  assign   host0_reg_to_uart_bus[18]    = uart_host0_lcr_dlab                     ;
  assign   host0_reg_to_uart_bus[19]    = uart_host0_lcr_set_break                ;
  assign   host0_reg_to_uart_bus[20]    = uart_host0_lcr_stick_parity             ;
  assign   host0_reg_to_uart_bus[21]    = uart_host0_lcr_eps                      ;
  assign   host0_reg_to_uart_bus[22]    = uart_host0_lcr_pen                      ;
  assign   host0_reg_to_uart_bus[23]    = uart_host0_lcr_stb                      ;
  assign   host0_reg_to_uart_bus[25:24] = uart_host0_lcr_wls                      ;
  assign   host0_reg_to_uart_bus[26]    = uart_host0_mcr_loop                     ;
  assign   host0_reg_to_uart_bus[27]    = uart_host0_mcr_out2                     ;
  assign   host0_reg_to_uart_bus[28]    = uart_host0_mcr_out1                     ;
  assign   host0_reg_to_uart_bus[29]    = uart_host0_mcr_rts                      ;
  assign   host0_reg_to_uart_bus[30]    = uart_host0_mcr_dtr                      ;
  assign   host0_reg_to_uart_bus[31]    = uart_host0_lsr_err_in_rfifo_write_value ;
  assign   host0_reg_to_uart_bus[32]    = uart_host0_lsr_temt_write_value         ;
  assign   host0_reg_to_uart_bus[33]    = uart_host0_lsr_thre_write_value         ;
  assign   host0_reg_to_uart_bus[34]    = uart_host0_lsr_bi_write_value           ;
  assign   host0_reg_to_uart_bus[35]    = uart_host0_lsr_fe_write_value           ;
  assign   host0_reg_to_uart_bus[36]    = uart_host0_lsr_pe_write_value           ;
  assign   host0_reg_to_uart_bus[37]    = uart_host0_lsr_oe_write_value           ;
  assign   host0_reg_to_uart_bus[38]    = uart_host0_lsr_dr_write_value           ;
  assign   host0_reg_to_uart_bus[39]    = uart_host0_msr_dcd_write_value          ;
  assign   host0_reg_to_uart_bus[40]    = uart_host0_msr_ri_write_value           ;
  assign   host0_reg_to_uart_bus[41]    = uart_host0_msr_dsr_write_value          ;
  assign   host0_reg_to_uart_bus[42]    = uart_host0_msr_cts_write_value          ;
  assign   host0_reg_to_uart_bus[43]    = uart_host0_msr_ddcd_write_value         ;
  assign   host0_reg_to_uart_bus[44]    = uart_host0_msr_teri_write_value         ;
  assign   host0_reg_to_uart_bus[45]    = uart_host0_msr_ddsr_write_value         ;
  assign   host0_reg_to_uart_bus[46]    = uart_host0_msr_dcts_write_value         ;
  assign   host0_reg_to_uart_bus[54:47] = uart_host0_scr_scr                      ;
  assign   host0_reg_to_uart_bus[62:55] = uart_host0_dll_dll                      ;
  assign   host0_reg_to_uart_bus[70:63] = uart_host0_dlm_dlm                      ;
  assign   host0_reg_to_uart_bus[71]    = uart_host0_thr_write_pulse              ;
  assign   host0_reg_to_uart_bus[72]    = uart_host0_lsr_write_pulse              ;
  assign   host0_reg_to_uart_bus[73]    = uart_host0_msr_write_pulse              ;
  assign   host0_reg_to_uart_bus[74]    = uart_host0_rbr_read_pulse               ;
  assign   host0_reg_to_uart_bus[75]    = uart_host0_msr_read_pulse               ;

  assign   ppc1_reg_to_uart_bus[7:0]   = uart_ppc1_thr_thr                      ;
  assign   ppc1_reg_to_uart_bus[8]     = uart_ppc1_ier_edssi                    ;
  assign   ppc1_reg_to_uart_bus[9]     = uart_ppc1_ier_elsi                     ;
  assign   ppc1_reg_to_uart_bus[10]    = uart_ppc1_ier_etbei                    ;
  assign   ppc1_reg_to_uart_bus[11]    = uart_ppc1_ier_erbfi                    ;
  assign   ppc1_reg_to_uart_bus[13:12] = uart_ppc1_fcr_rfifo_tlevel             ;
  assign   ppc1_reg_to_uart_bus[14]    = uart_ppc1_fcr_dma_mode_sel             ;
  assign   ppc1_reg_to_uart_bus[15]    = uart_ppc1_fcr_tfifo_reset              ;
  assign   ppc1_reg_to_uart_bus[16]    = uart_ppc1_fcr_rfifo_reset              ;
  assign   ppc1_reg_to_uart_bus[17]    = uart_ppc1_fcr_fifo_en                  ;
  assign   ppc1_reg_to_uart_bus[18]    = uart_ppc1_lcr_dlab                     ;
  assign   ppc1_reg_to_uart_bus[19]    = uart_ppc1_lcr_set_break                ;
  assign   ppc1_reg_to_uart_bus[20]    = uart_ppc1_lcr_stick_parity             ;
  assign   ppc1_reg_to_uart_bus[21]    = uart_ppc1_lcr_eps                      ;
  assign   ppc1_reg_to_uart_bus[22]    = uart_ppc1_lcr_pen                      ;
  assign   ppc1_reg_to_uart_bus[23]    = uart_ppc1_lcr_stb                      ;
  assign   ppc1_reg_to_uart_bus[25:24] = uart_ppc1_lcr_wls                      ;
  assign   ppc1_reg_to_uart_bus[26]    = uart_ppc1_mcr_loop                     ;
  assign   ppc1_reg_to_uart_bus[27]    = uart_ppc1_mcr_out2                     ;
  assign   ppc1_reg_to_uart_bus[28]    = uart_ppc1_mcr_out1                     ;
  assign   ppc1_reg_to_uart_bus[29]    = uart_ppc1_mcr_rts                      ;
  assign   ppc1_reg_to_uart_bus[30]    = uart_ppc1_mcr_dtr                      ;
  assign   ppc1_reg_to_uart_bus[31]    = uart_ppc1_lsr_err_in_rfifo_write_value ;
  assign   ppc1_reg_to_uart_bus[32]    = uart_ppc1_lsr_temt_write_value         ;
  assign   ppc1_reg_to_uart_bus[33]    = uart_ppc1_lsr_thre_write_value         ;
  assign   ppc1_reg_to_uart_bus[34]    = uart_ppc1_lsr_bi_write_value           ;
  assign   ppc1_reg_to_uart_bus[35]    = uart_ppc1_lsr_fe_write_value           ;
  assign   ppc1_reg_to_uart_bus[36]    = uart_ppc1_lsr_pe_write_value           ;
  assign   ppc1_reg_to_uart_bus[37]    = uart_ppc1_lsr_oe_write_value           ;
  assign   ppc1_reg_to_uart_bus[38]    = uart_ppc1_lsr_dr_write_value           ;
  assign   ppc1_reg_to_uart_bus[39]    = uart_ppc1_msr_dcd_write_value          ;
  assign   ppc1_reg_to_uart_bus[40]    = uart_ppc1_msr_ri_write_value           ;
  assign   ppc1_reg_to_uart_bus[41]    = uart_ppc1_msr_dsr_write_value          ;
  assign   ppc1_reg_to_uart_bus[42]    = uart_ppc1_msr_cts_write_value          ;
  assign   ppc1_reg_to_uart_bus[43]    = uart_ppc1_msr_ddcd_write_value         ;
  assign   ppc1_reg_to_uart_bus[44]    = uart_ppc1_msr_teri_write_value         ;
  assign   ppc1_reg_to_uart_bus[45]    = uart_ppc1_msr_ddsr_write_value         ;
  assign   ppc1_reg_to_uart_bus[46]    = uart_ppc1_msr_dcts_write_value         ;
  assign   ppc1_reg_to_uart_bus[54:47] = uart_ppc1_scr_scr                      ;
  assign   ppc1_reg_to_uart_bus[62:55] = uart_ppc1_dll_dll                      ;
  assign   ppc1_reg_to_uart_bus[70:63] = uart_ppc1_dlm_dlm                      ;
  assign   ppc1_reg_to_uart_bus[71]    = uart_ppc1_thr_write_pulse              ;
  assign   ppc1_reg_to_uart_bus[72]    = uart_ppc1_lsr_write_pulse              ;
  assign   ppc1_reg_to_uart_bus[73]    = uart_ppc1_msr_write_pulse              ;
  assign   ppc1_reg_to_uart_bus[74]    = uart_ppc1_rbr_read_pulse               ;
  assign   ppc1_reg_to_uart_bus[75]    = uart_ppc1_msr_read_pulse               ;

  assign   host1_reg_to_uart_bus[7:0]   = uart_host1_thr_thr                      ;
  assign   host1_reg_to_uart_bus[8]     = uart_host1_ier_edssi                    ;
  assign   host1_reg_to_uart_bus[9]     = uart_host1_ier_elsi                     ;
  assign   host1_reg_to_uart_bus[10]    = uart_host1_ier_etbei                    ;
  assign   host1_reg_to_uart_bus[11]    = uart_host1_ier_erbfi                    ;
  assign   host1_reg_to_uart_bus[13:12] = uart_host1_fcr_rfifo_tlevel             ;
  assign   host1_reg_to_uart_bus[14]    = uart_host1_fcr_dma_mode_sel             ;
  assign   host1_reg_to_uart_bus[15]    = uart_host1_fcr_tfifo_reset              ;
  assign   host1_reg_to_uart_bus[16]    = uart_host1_fcr_rfifo_reset              ;
  assign   host1_reg_to_uart_bus[17]    = uart_host1_fcr_fifo_en                  ;
  assign   host1_reg_to_uart_bus[18]    = uart_host1_lcr_dlab                     ;
  assign   host1_reg_to_uart_bus[19]    = uart_host1_lcr_set_break                ;
  assign   host1_reg_to_uart_bus[20]    = uart_host1_lcr_stick_parity             ;
  assign   host1_reg_to_uart_bus[21]    = uart_host1_lcr_eps                      ;
  assign   host1_reg_to_uart_bus[22]    = uart_host1_lcr_pen                      ;
  assign   host1_reg_to_uart_bus[23]    = uart_host1_lcr_stb                      ;
  assign   host1_reg_to_uart_bus[25:24] = uart_host1_lcr_wls                      ;
  assign   host1_reg_to_uart_bus[26]    = uart_host1_mcr_loop                     ;
  assign   host1_reg_to_uart_bus[27]    = uart_host1_mcr_out2                     ;
  assign   host1_reg_to_uart_bus[28]    = uart_host1_mcr_out1                     ;
  assign   host1_reg_to_uart_bus[29]    = uart_host1_mcr_rts                      ;
  assign   host1_reg_to_uart_bus[30]    = uart_host1_mcr_dtr                      ;
  assign   host1_reg_to_uart_bus[31]    = uart_host1_lsr_err_in_rfifo_write_value ;
  assign   host1_reg_to_uart_bus[32]    = uart_host1_lsr_temt_write_value         ;
  assign   host1_reg_to_uart_bus[33]    = uart_host1_lsr_thre_write_value         ;
  assign   host1_reg_to_uart_bus[34]    = uart_host1_lsr_bi_write_value           ;
  assign   host1_reg_to_uart_bus[35]    = uart_host1_lsr_fe_write_value           ;
  assign   host1_reg_to_uart_bus[36]    = uart_host1_lsr_pe_write_value           ;
  assign   host1_reg_to_uart_bus[37]    = uart_host1_lsr_oe_write_value           ;
  assign   host1_reg_to_uart_bus[38]    = uart_host1_lsr_dr_write_value           ;
  assign   host1_reg_to_uart_bus[39]    = uart_host1_msr_dcd_write_value          ;
  assign   host1_reg_to_uart_bus[40]    = uart_host1_msr_ri_write_value           ;
  assign   host1_reg_to_uart_bus[41]    = uart_host1_msr_dsr_write_value          ;
  assign   host1_reg_to_uart_bus[42]    = uart_host1_msr_cts_write_value          ;
  assign   host1_reg_to_uart_bus[43]    = uart_host1_msr_ddcd_write_value         ;
  assign   host1_reg_to_uart_bus[44]    = uart_host1_msr_teri_write_value         ;
  assign   host1_reg_to_uart_bus[45]    = uart_host1_msr_ddsr_write_value         ;
  assign   host1_reg_to_uart_bus[46]    = uart_host1_msr_dcts_write_value         ;
  assign   host1_reg_to_uart_bus[54:47] = uart_host1_scr_scr                      ;
  assign   host1_reg_to_uart_bus[62:55] = uart_host1_dll_dll                      ;
  assign   host1_reg_to_uart_bus[70:63] = uart_host1_dlm_dlm                      ;
  assign   host1_reg_to_uart_bus[71]    = uart_host1_thr_write_pulse              ;
  assign   host1_reg_to_uart_bus[72]    = uart_host1_lsr_write_pulse              ;
  assign   host1_reg_to_uart_bus[73]    = uart_host1_msr_write_pulse              ;
  assign   host1_reg_to_uart_bus[74]    = uart_host1_rbr_read_pulse               ;
  assign   host1_reg_to_uart_bus[75]    = uart_host1_msr_read_pulse               ;

// Connect the PSB External Ports to the Internal core signals
// Inputs
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
    // Assign a reset value
    begin
        // Inputs to PSB Slave
        PSBsl_a       <= 0;
        PSBsl_tbst_n  <= 1;
        PSBsl_tsiz    <= 0;
        PSBsl_ts_n    <= 1;
        PSBsl_tt      <= 0; 

        // Inputs to PSB Master
        PSBma_abb_n   <= 1;
        PSBma_bg_n    <= 1;
        PSBma_dbg_n   <= 1;
        PSBma_aack_n  <= 1;
        PSBma_artry_n <= 1;
        PSBma_ta_n    <= 1;
        PSBma_tea_n   <= 1;

        // Inputs to PSB Slave and PSB Master
        PSBslma_dbb_n <= 1;
        PSBslma_d_i   <= 0;
    end

    else
    // Clock in new value
    begin
        // Inputs to PSB Slave
        PSBsl_a       <= PSB_a_I      ;
        PSBsl_tbst_n  <= PSB_tbst_n_I ;
        PSBsl_tsiz    <= PSB_tsiz_I[1:3];
        PSBsl_ts_n    <= PSB_ts_n_I   ;
        PSBsl_tt      <= PSB_tt_I     ; 

        // Inputs to PSB Master
        PSBma_abb_n   <= PSB_abb_n_I  ;
        PSBma_bg_n    <= PSB_bg_n     ;
        PSBma_dbg_n   <= PSB_dbg_n    ;
        PSBma_aack_n  <= PSB_aack_n_I ;
        PSBma_artry_n <= PSB_artry_n_I;
        PSBma_ta_n    <= PSB_ta_n_I   ;
        PSBma_tea_n   <= PSB_tea_n_I  ;

        // Inputs to PSB Slave and PSB Master
        PSBslma_dbb_n <= PSB_dbb_n_I  ;
        PSBslma_d_i   <= PSB_d_I      ;
    end
end

// Outputs
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
    // Assign a reset value
    begin
        PSB_aack_n_O  <= 1;
        PSB_aack_n_T  <= 1;
        PSB_artry_n_O <= 1;
        PSB_artry_n_T <= 1;
        PSB_d_O       <= 0;
        PSB_d_T       <= {64{1'b1}};
        PSB_ta_n_O    <= 1;
        PSB_ta_n_T    <= 1;
        PSB_tea_n_O   <= 1;
        PSB_tea_n_T   <= 1;

        PSB_a_O       <= 0;
        PSB_a_T       <= {32{1'b1}};
        PSB_abb_n_O   <= 1;
        PSB_abb_n_T   <= 1;
        PSB_dbb_n_O   <= 1;
        PSB_dbb_n_T   <= 1;
        PSB_tbst_n_O  <= 1;
        PSB_tbst_n_T  <= 1;
        PSB_tsiz_O    <= 0;
        PSB_tsiz_T    <= {4{1'b1}};
        PSB_ts_n_O    <= 1;
        PSB_ts_n_T    <= 1;
        PSB_tt_O      <= 0;
        PSB_tt_T      <= {5{1'b1}};
    end

    else
    // Clock in new value
    begin
        PSB_aack_n_O  <=  PSBsl_aack_n_en  ? PSBsl_aack_n_o  : 1;
        PSB_aack_n_T  <= ~PSBsl_aack_n_en;
        PSB_artry_n_O <=  PSBsl_artry_n_en ? PSBsl_artry_n_o : 1;
        PSB_artry_n_T <= ~PSBsl_artry_n_en;
        PSB_d_O       <=  PSBsl_d_en       ? PSBsl_d_o       : (PSBma_d_en ? PSBma_d_o : 64'b0);    
        PSB_d_T       <= {64{~(PSBsl_d_en || PSBma_d_en)}};
        PSB_ta_n_O    <=  PSBsl_ta_n_en    ? PSBsl_ta_n_o    : 1;
        PSB_ta_n_T    <= ~PSBsl_ta_n_en;    
        PSB_tea_n_O   <=  PSBsl_tea_n_en   ? PSBsl_tea_n_o   : 1;
        PSB_tea_n_T   <= ~PSBsl_tea_n_en;   

        PSB_a_O       <=  PSBma_a_en      ? PSBma_a_o      : 0;
        PSB_a_T       <= {32{~PSBma_a_en}};
        PSB_abb_n_O   <=  PSBma_abb_n_en  ? PSBma_abb_n_o  : 1;
        PSB_abb_n_T   <= ~PSBma_abb_n_en;
        PSB_dbb_n_O   <=  PSBma_dbb_n_en  ? PSBma_dbb_n_o  : 1;
        PSB_dbb_n_T   <= ~PSBma_dbb_n_en;
        PSB_tbst_n_O  <=  PSBma_tbst_n_en ? PSBma_tbst_n_o : 1;
        PSB_tbst_n_T  <= ~PSBma_tbst_n_en;
        PSB_tsiz_O    <=  PSBma_tsiz_en   ? PSBma_tsiz_o   : 0;
        PSB_tsiz_T    <= {4{~PSBma_tsiz_en}};
        PSB_ts_n_O    <=  PSBma_ts_n_en   ? PSBma_ts_n_o   : 1;
        PSB_ts_n_T    <= ~PSBma_ts_n_en;
        PSB_tt_O      <=  PSBma_tt_en     ? PSBma_tt_o     : 0;
        PSB_tt_T      <= {5{~PSBma_tt_en}};
    end
end


/********************************
* Module Instantiations         *
********************************/

/******************************************************************************                   
* user_fpga_mcsr_wrapper                                                                        
*    This module contains the PLB_PSB Bridge FPGA Registers.
******************************************************************************/         
defparam plb_psb_bridge_fpga_reg_wrapper.PLB_PSB_FPGA_REG_LSB_DECODE = PLB_PSB_FPGA_REG_LSB_DECODE;

plb_psb_bridge_fpga_reg_wrapper plb_psb_bridge_fpga_reg_wrapper (
                             // Inputs                                                  
                              // System                                                 
                                .clk                        (clk                      ),
                                .reset                      (reset                    ),
                                                                                        
                              // PSB Read and Write Control                             
                                .psb_mcsr_addr              (psb_mcsr_addr            ),
                                .psb_mcsr_write_data        (psb_mcsr_write_data      ),
                                .psb_mcsr_wr_en_pulse       (psb_mcsr_wr_en_pulse     ),
                                .psb_mcsr_rd_en_pulse       (psb_mcsr_rd_en_pulse     ),

                              // PLB read and write logic
                                .plb_mcsr_addr              (plb_mcsr_addr            ),
                                .plb_mcsr_write_data        (plb_mcsr_write_data      ),
                                .plb_mcsr_wr_en_pulse       (plb_mcsr_wr_en_pulse     ),
                                .plb_mcsr_rd_en_pulse       (plb_mcsr_rd_en_pulse     ),
                                                                                        
                              // UART 16550 Port 0 Registers
                               // PPC405
                                .uart_ppc0_rbr_rbr           (uart_ppc0_rbr_rbr             ),
                                .uart_ppc0_iir_fifoen        (uart_ppc0_iir_fifoen          ),
                                .uart_ppc0_iir_intid2        (uart_ppc0_iir_intid2          ),
                                .uart_ppc0_iir_intpend       (uart_ppc0_iir_intpend         ),
                                .uart_ppc0_lsr_err_in_rfifo  (uart_ppc0_lsr_err_in_rfifo    ),
                                .uart_ppc0_lsr_temt          (uart_ppc0_lsr_temt            ),
                                .uart_ppc0_lsr_thre          (uart_ppc0_lsr_thre            ),
                                .uart_ppc0_lsr_bi            (uart_ppc0_lsr_bi              ),
                                .uart_ppc0_lsr_fe            (uart_ppc0_lsr_fe              ),
                                .uart_ppc0_lsr_pe            (uart_ppc0_lsr_pe              ),
                                .uart_ppc0_lsr_oe            (uart_ppc0_lsr_oe              ),
                                .uart_ppc0_lsr_dr            (uart_ppc0_lsr_dr              ),
                                .uart_ppc0_msr_dcd           (uart_ppc0_msr_dcd             ),
                                .uart_ppc0_msr_ri            (uart_ppc0_msr_ri              ),
                                .uart_ppc0_msr_dsr           (uart_ppc0_msr_dsr             ),
                                .uart_ppc0_msr_cts           (uart_ppc0_msr_cts             ),
                                .uart_ppc0_msr_ddcd          (uart_ppc0_msr_ddcd            ),
                                .uart_ppc0_msr_teri          (uart_ppc0_msr_teri            ),
                                .uart_ppc0_msr_ddsr          (uart_ppc0_msr_ddsr            ),
                                .uart_ppc0_msr_dcts          (uart_ppc0_msr_dcts            ),
                               // HOST                       
                                .uart_host0_rbr_rbr          (uart_host0_rbr_rbr            ),
                                .uart_host0_iir_fifoen       (uart_host0_iir_fifoen         ),
                                .uart_host0_iir_intid2       (uart_host0_iir_intid2         ),
                                .uart_host0_iir_intpend      (uart_host0_iir_intpend        ),
                                .uart_host0_lsr_err_in_rfifo (uart_host0_lsr_err_in_rfifo   ),
                                .uart_host0_lsr_temt         (uart_host0_lsr_temt           ),
                                .uart_host0_lsr_thre         (uart_host0_lsr_thre           ),
                                .uart_host0_lsr_bi           (uart_host0_lsr_bi             ),
                                .uart_host0_lsr_fe           (uart_host0_lsr_fe             ),
                                .uart_host0_lsr_pe           (uart_host0_lsr_pe             ),
                                .uart_host0_lsr_oe           (uart_host0_lsr_oe             ),
                                .uart_host0_lsr_dr           (uart_host0_lsr_dr             ),
                                .uart_host0_msr_dcd          (uart_host0_msr_dcd            ),
                                .uart_host0_msr_ri           (uart_host0_msr_ri             ),
                                .uart_host0_msr_dsr          (uart_host0_msr_dsr            ),
                                .uart_host0_msr_cts          (uart_host0_msr_cts            ),
                                .uart_host0_msr_ddcd         (uart_host0_msr_ddcd           ),
                                .uart_host0_msr_teri         (uart_host0_msr_teri           ),
                                .uart_host0_msr_ddsr         (uart_host0_msr_ddsr           ),
                                .uart_host0_msr_dcts         (uart_host0_msr_dcts           ),
                             
                              // UART 16550 Port 1 Registers
                               // PPC405
                                .uart_ppc1_rbr_rbr           (uart_ppc1_rbr_rbr             ),
                                .uart_ppc1_iir_fifoen        (uart_ppc1_iir_fifoen          ),
                                .uart_ppc1_iir_intid2        (uart_ppc1_iir_intid2          ),
                                .uart_ppc1_iir_intpend       (uart_ppc1_iir_intpend         ),
                                .uart_ppc1_lsr_err_in_rfifo  (uart_ppc1_lsr_err_in_rfifo    ),
                                .uart_ppc1_lsr_temt          (uart_ppc1_lsr_temt            ),
                                .uart_ppc1_lsr_thre          (uart_ppc1_lsr_thre            ),
                                .uart_ppc1_lsr_bi            (uart_ppc1_lsr_bi              ),
                                .uart_ppc1_lsr_fe            (uart_ppc1_lsr_fe              ),
                                .uart_ppc1_lsr_pe            (uart_ppc1_lsr_pe              ),
                                .uart_ppc1_lsr_oe            (uart_ppc1_lsr_oe              ),
                                .uart_ppc1_lsr_dr            (uart_ppc1_lsr_dr              ),
                                .uart_ppc1_msr_dcd           (uart_ppc1_msr_dcd             ),
                                .uart_ppc1_msr_ri            (uart_ppc1_msr_ri              ),
                                .uart_ppc1_msr_dsr           (uart_ppc1_msr_dsr             ),
                                .uart_ppc1_msr_cts           (uart_ppc1_msr_cts             ),
                                .uart_ppc1_msr_ddcd          (uart_ppc1_msr_ddcd            ),
                                .uart_ppc1_msr_teri          (uart_ppc1_msr_teri            ),
                                .uart_ppc1_msr_ddsr          (uart_ppc1_msr_ddsr            ),
                                .uart_ppc1_msr_dcts          (uart_ppc1_msr_dcts            ),
                               // HOST
                                .uart_host1_rbr_rbr          (uart_host1_rbr_rbr            ),
                                .uart_host1_iir_fifoen       (uart_host1_iir_fifoen         ),
                                .uart_host1_iir_intid2       (uart_host1_iir_intid2         ),
                                .uart_host1_iir_intpend      (uart_host1_iir_intpend        ),
                                .uart_host1_lsr_err_in_rfifo (uart_host1_lsr_err_in_rfifo   ),
                                .uart_host1_lsr_temt         (uart_host1_lsr_temt           ),
                                .uart_host1_lsr_thre         (uart_host1_lsr_thre           ),
                                .uart_host1_lsr_bi           (uart_host1_lsr_bi             ),
                                .uart_host1_lsr_fe           (uart_host1_lsr_fe             ),
                                .uart_host1_lsr_pe           (uart_host1_lsr_pe             ),
                                .uart_host1_lsr_oe           (uart_host1_lsr_oe             ),
                                .uart_host1_lsr_dr           (uart_host1_lsr_dr             ),
                                .uart_host1_msr_dcd          (uart_host1_msr_dcd            ),
                                .uart_host1_msr_ri           (uart_host1_msr_ri             ),
                                .uart_host1_msr_dsr          (uart_host1_msr_dsr            ),
                                .uart_host1_msr_cts          (uart_host1_msr_cts            ),
                                .uart_host1_msr_ddcd         (uart_host1_msr_ddcd           ),
                                .uart_host1_msr_teri         (uart_host1_msr_teri           ),
                                .uart_host1_msr_ddsr         (uart_host1_msr_ddsr           ),
                                .uart_host1_msr_dcts         (uart_host1_msr_dcts           ),
                                                                                        
                             // Outputs                                                 
                              // PSB Read Data                                          
                                .mcsr_psb_read_data         (mcsr_psb_read_data       ),

                              // PLB Read Data
                                .mcsr_plb_read_data         (mcsr_plb_read_data       ),                                                          
                                                                                        
                              // UART 16550 Port 0 Registers
                               // PPC405
                                .uart_ppc0_thr_thr                       (uart_ppc0_thr_thr                         ),
                                .uart_ppc0_ier_edssi                     (uart_ppc0_ier_edssi                       ),
                                .uart_ppc0_ier_elsi                      (uart_ppc0_ier_elsi                        ),
                                .uart_ppc0_ier_etbei                     (uart_ppc0_ier_etbei                       ),
                                .uart_ppc0_ier_erbfi                     (uart_ppc0_ier_erbfi                       ),
                                .uart_ppc0_fcr_rfifo_tlevel              (uart_ppc0_fcr_rfifo_tlevel                ),
                                .uart_ppc0_fcr_dma_mode_sel              (uart_ppc0_fcr_dma_mode_sel                ),
                                .uart_ppc0_fcr_tfifo_reset               (uart_ppc0_fcr_tfifo_reset                 ),
                                .uart_ppc0_fcr_rfifo_reset               (uart_ppc0_fcr_rfifo_reset                 ),
                                .uart_ppc0_fcr_fifo_en                   (uart_ppc0_fcr_fifo_en                     ),
                                .uart_ppc0_lcr_dlab                      (uart_ppc0_lcr_dlab                        ),
                                .uart_ppc0_lcr_set_break                 (uart_ppc0_lcr_set_break                   ),
                                .uart_ppc0_lcr_stick_parity              (uart_ppc0_lcr_stick_parity                ),
                                .uart_ppc0_lcr_eps                       (uart_ppc0_lcr_eps                         ),
                                .uart_ppc0_lcr_pen                       (uart_ppc0_lcr_pen                         ),
                                .uart_ppc0_lcr_stb                       (uart_ppc0_lcr_stb                         ),
                                .uart_ppc0_lcr_wls                       (uart_ppc0_lcr_wls                         ),
                                .uart_ppc0_mcr_loop                      (uart_ppc0_mcr_loop                        ),
                                .uart_ppc0_mcr_out2                      (uart_ppc0_mcr_out2                        ),
                                .uart_ppc0_mcr_out1                      (uart_ppc0_mcr_out1                        ),
                                .uart_ppc0_mcr_rts                       (uart_ppc0_mcr_rts                         ),
                                .uart_ppc0_mcr_dtr                       (uart_ppc0_mcr_dtr                         ),
                                .uart_ppc0_lsr_err_in_rfifo_write_value  (uart_ppc0_lsr_err_in_rfifo_write_value    ),
                                .uart_ppc0_lsr_temt_write_value          (uart_ppc0_lsr_temt_write_value            ),
                                .uart_ppc0_lsr_thre_write_value          (uart_ppc0_lsr_thre_write_value            ),
                                .uart_ppc0_lsr_bi_write_value            (uart_ppc0_lsr_bi_write_value              ),
                                .uart_ppc0_lsr_fe_write_value            (uart_ppc0_lsr_fe_write_value              ),
                                .uart_ppc0_lsr_pe_write_value            (uart_ppc0_lsr_pe_write_value              ),
                                .uart_ppc0_lsr_oe_write_value            (uart_ppc0_lsr_oe_write_value              ),
                                .uart_ppc0_lsr_dr_write_value            (uart_ppc0_lsr_dr_write_value              ),
                                .uart_ppc0_msr_dcd_write_value           (uart_ppc0_msr_dcd_write_value             ),
                                .uart_ppc0_msr_ri_write_value            (uart_ppc0_msr_ri_write_value              ),
                                .uart_ppc0_msr_dsr_write_value           (uart_ppc0_msr_dsr_write_value             ),
                                .uart_ppc0_msr_cts_write_value           (uart_ppc0_msr_cts_write_value             ),
                                .uart_ppc0_msr_ddcd_write_value          (uart_ppc0_msr_ddcd_write_value            ),
                                .uart_ppc0_msr_teri_write_value          (uart_ppc0_msr_teri_write_value            ),
                                .uart_ppc0_msr_ddsr_write_value          (uart_ppc0_msr_ddsr_write_value            ),
                                .uart_ppc0_msr_dcts_write_value          (uart_ppc0_msr_dcts_write_value            ),
                                .uart_ppc0_scr_scr                       (uart_ppc0_scr_scr                         ),
                                .uart_ppc0_dll_dll                       (uart_ppc0_dll_dll                         ),
                                .uart_ppc0_dlm_dlm                       (uart_ppc0_dlm_dlm                         ),
                                .uart_ppc0_thr_write_pulse               (uart_ppc0_thr_write_pulse                 ),
                                .uart_ppc0_lsr_write_pulse               (uart_ppc0_lsr_write_pulse                 ),
                                .uart_ppc0_msr_write_pulse               (uart_ppc0_msr_write_pulse                 ),
                                .uart_ppc0_rbr_read_pulse                (uart_ppc0_rbr_read_pulse                  ),
                                .uart_ppc0_msr_read_pulse                (uart_ppc0_msr_read_pulse                  ),
                               // HOST
                                .uart_host0_thr_thr                       (uart_host0_thr_thr                       ),
                                .uart_host0_ier_edssi                     (uart_host0_ier_edssi                     ),
                                .uart_host0_ier_elsi                      (uart_host0_ier_elsi                      ),
                                .uart_host0_ier_etbei                     (uart_host0_ier_etbei                     ),
                                .uart_host0_ier_erbfi                     (uart_host0_ier_erbfi                     ),
                                .uart_host0_fcr_rfifo_tlevel              (uart_host0_fcr_rfifo_tlevel              ),
                                .uart_host0_fcr_dma_mode_sel              (uart_host0_fcr_dma_mode_sel              ),
                                .uart_host0_fcr_tfifo_reset               (uart_host0_fcr_tfifo_reset               ),
                                .uart_host0_fcr_rfifo_reset               (uart_host0_fcr_rfifo_reset               ),
                                .uart_host0_fcr_fifo_en                   (uart_host0_fcr_fifo_en                   ),
                                .uart_host0_lcr_dlab                      (uart_host0_lcr_dlab                      ),
                                .uart_host0_lcr_set_break                 (uart_host0_lcr_set_break                 ),
                                .uart_host0_lcr_stick_parity              (uart_host0_lcr_stick_parity              ),
                                .uart_host0_lcr_eps                       (uart_host0_lcr_eps                       ),
                                .uart_host0_lcr_pen                       (uart_host0_lcr_pen                       ),
                                .uart_host0_lcr_stb                       (uart_host0_lcr_stb                       ),
                                .uart_host0_lcr_wls                       (uart_host0_lcr_wls                       ),
                                .uart_host0_mcr_loop                      (uart_host0_mcr_loop                      ),
                                .uart_host0_mcr_out2                      (uart_host0_mcr_out2                      ),
                                .uart_host0_mcr_out1                      (uart_host0_mcr_out1                      ),
                                .uart_host0_mcr_rts                       (uart_host0_mcr_rts                       ),
                                .uart_host0_mcr_dtr                       (uart_host0_mcr_dtr                       ),
                                .uart_host0_lsr_err_in_rfifo_write_value  (uart_host0_lsr_err_in_rfifo_write_value  ),
                                .uart_host0_lsr_temt_write_value          (uart_host0_lsr_temt_write_value          ),
                                .uart_host0_lsr_thre_write_value          (uart_host0_lsr_thre_write_value          ),
                                .uart_host0_lsr_bi_write_value            (uart_host0_lsr_bi_write_value            ),
                                .uart_host0_lsr_fe_write_value            (uart_host0_lsr_fe_write_value            ),
                                .uart_host0_lsr_pe_write_value            (uart_host0_lsr_pe_write_value            ),
                                .uart_host0_lsr_oe_write_value            (uart_host0_lsr_oe_write_value            ),
                                .uart_host0_lsr_dr_write_value            (uart_host0_lsr_dr_write_value            ),
                                .uart_host0_msr_dcd_write_value           (uart_host0_msr_dcd_write_value           ),
                                .uart_host0_msr_ri_write_value            (uart_host0_msr_ri_write_value            ),
                                .uart_host0_msr_dsr_write_value           (uart_host0_msr_dsr_write_value           ),
                                .uart_host0_msr_cts_write_value           (uart_host0_msr_cts_write_value           ),
                                .uart_host0_msr_ddcd_write_value          (uart_host0_msr_ddcd_write_value          ),
                                .uart_host0_msr_teri_write_value          (uart_host0_msr_teri_write_value          ),
                                .uart_host0_msr_ddsr_write_value          (uart_host0_msr_ddsr_write_value          ),
                                .uart_host0_msr_dcts_write_value          (uart_host0_msr_dcts_write_value          ),
                                .uart_host0_scr_scr                       (uart_host0_scr_scr                       ),
                                .uart_host0_dll_dll                       (uart_host0_dll_dll                       ),
                                .uart_host0_dlm_dlm                       (uart_host0_dlm_dlm                       ),
                                .uart_host0_thr_write_pulse               (uart_host0_thr_write_pulse               ),
                                .uart_host0_lsr_write_pulse               (uart_host0_lsr_write_pulse               ),
                                .uart_host0_msr_write_pulse               (uart_host0_msr_write_pulse               ),
                                .uart_host0_rbr_read_pulse                (uart_host0_rbr_read_pulse                ),
                                .uart_host0_msr_read_pulse                (uart_host0_msr_read_pulse                ),
                                                                                                            
                              // UART 16550 Port 1 Registers
                               // PPC405
                                .uart_ppc1_thr_thr                       (uart_ppc1_thr_thr                         ),
                                .uart_ppc1_ier_edssi                     (uart_ppc1_ier_edssi                       ),
                                .uart_ppc1_ier_elsi                      (uart_ppc1_ier_elsi                        ),
                                .uart_ppc1_ier_etbei                     (uart_ppc1_ier_etbei                       ),
                                .uart_ppc1_ier_erbfi                     (uart_ppc1_ier_erbfi                       ),
                                .uart_ppc1_fcr_rfifo_tlevel              (uart_ppc1_fcr_rfifo_tlevel                ),
                                .uart_ppc1_fcr_dma_mode_sel              (uart_ppc1_fcr_dma_mode_sel                ),
                                .uart_ppc1_fcr_tfifo_reset               (uart_ppc1_fcr_tfifo_reset                 ),
                                .uart_ppc1_fcr_rfifo_reset               (uart_ppc1_fcr_rfifo_reset                 ),
                                .uart_ppc1_fcr_fifo_en                   (uart_ppc1_fcr_fifo_en                     ),
                                .uart_ppc1_lcr_dlab                      (uart_ppc1_lcr_dlab                        ),
                                .uart_ppc1_lcr_set_break                 (uart_ppc1_lcr_set_break                   ),
                                .uart_ppc1_lcr_stick_parity              (uart_ppc1_lcr_stick_parity                ),
                                .uart_ppc1_lcr_eps                       (uart_ppc1_lcr_eps                         ),
                                .uart_ppc1_lcr_pen                       (uart_ppc1_lcr_pen                         ),
                                .uart_ppc1_lcr_stb                       (uart_ppc1_lcr_stb                         ),
                                .uart_ppc1_lcr_wls                       (uart_ppc1_lcr_wls                         ),
                                .uart_ppc1_mcr_loop                      (uart_ppc1_mcr_loop                        ),
                                .uart_ppc1_mcr_out2                      (uart_ppc1_mcr_out2                        ),
                                .uart_ppc1_mcr_out1                      (uart_ppc1_mcr_out1                        ),
                                .uart_ppc1_mcr_rts                       (uart_ppc1_mcr_rts                         ),
                                .uart_ppc1_mcr_dtr                       (uart_ppc1_mcr_dtr                         ),
                                .uart_ppc1_lsr_err_in_rfifo_write_value  (uart_ppc1_lsr_err_in_rfifo_write_value    ),
                                .uart_ppc1_lsr_temt_write_value          (uart_ppc1_lsr_temt_write_value            ),
                                .uart_ppc1_lsr_thre_write_value          (uart_ppc1_lsr_thre_write_value            ),
                                .uart_ppc1_lsr_bi_write_value            (uart_ppc1_lsr_bi_write_value              ),
                                .uart_ppc1_lsr_fe_write_value            (uart_ppc1_lsr_fe_write_value              ),
                                .uart_ppc1_lsr_pe_write_value            (uart_ppc1_lsr_pe_write_value              ),
                                .uart_ppc1_lsr_oe_write_value            (uart_ppc1_lsr_oe_write_value              ),
                                .uart_ppc1_lsr_dr_write_value            (uart_ppc1_lsr_dr_write_value              ),
                                .uart_ppc1_msr_dcd_write_value           (uart_ppc1_msr_dcd_write_value             ),
                                .uart_ppc1_msr_ri_write_value            (uart_ppc1_msr_ri_write_value              ),
                                .uart_ppc1_msr_dsr_write_value           (uart_ppc1_msr_dsr_write_value             ),
                                .uart_ppc1_msr_cts_write_value           (uart_ppc1_msr_cts_write_value             ),
                                .uart_ppc1_msr_ddcd_write_value          (uart_ppc1_msr_ddcd_write_value            ),
                                .uart_ppc1_msr_teri_write_value          (uart_ppc1_msr_teri_write_value            ),
                                .uart_ppc1_msr_ddsr_write_value          (uart_ppc1_msr_ddsr_write_value            ),
                                .uart_ppc1_msr_dcts_write_value          (uart_ppc1_msr_dcts_write_value            ),
                                .uart_ppc1_scr_scr                       (uart_ppc1_scr_scr                         ),
                                .uart_ppc1_dll_dll                       (uart_ppc1_dll_dll                         ),
                                .uart_ppc1_dlm_dlm                       (uart_ppc1_dlm_dlm                         ),
                                .uart_ppc1_thr_write_pulse               (uart_ppc1_thr_write_pulse                 ),
                                .uart_ppc1_lsr_write_pulse               (uart_ppc1_lsr_write_pulse                 ),
                                .uart_ppc1_msr_write_pulse               (uart_ppc1_msr_write_pulse                 ),
                                .uart_ppc1_rbr_read_pulse                (uart_ppc1_rbr_read_pulse                  ),
                                .uart_ppc1_msr_read_pulse                (uart_ppc1_msr_read_pulse                  ),
                               // HOST
                                .uart_host1_thr_thr                      (uart_host1_thr_thr                        ),
                                .uart_host1_ier_edssi                    (uart_host1_ier_edssi                      ),
                                .uart_host1_ier_elsi                     (uart_host1_ier_elsi                       ),
                                .uart_host1_ier_etbei                    (uart_host1_ier_etbei                      ),
                                .uart_host1_ier_erbfi                    (uart_host1_ier_erbfi                      ),
                                .uart_host1_fcr_rfifo_tlevel             (uart_host1_fcr_rfifo_tlevel               ),
                                .uart_host1_fcr_dma_mode_sel             (uart_host1_fcr_dma_mode_sel               ),
                                .uart_host1_fcr_tfifo_reset              (uart_host1_fcr_tfifo_reset                ),
                                .uart_host1_fcr_rfifo_reset              (uart_host1_fcr_rfifo_reset                ),
                                .uart_host1_fcr_fifo_en                  (uart_host1_fcr_fifo_en                    ),
                                .uart_host1_lcr_dlab                     (uart_host1_lcr_dlab                       ),
                                .uart_host1_lcr_set_break                (uart_host1_lcr_set_break                  ),
                                .uart_host1_lcr_stick_parity             (uart_host1_lcr_stick_parity               ),
                                .uart_host1_lcr_eps                      (uart_host1_lcr_eps                        ),
                                .uart_host1_lcr_pen                      (uart_host1_lcr_pen                        ),
                                .uart_host1_lcr_stb                      (uart_host1_lcr_stb                        ),
                                .uart_host1_lcr_wls                      (uart_host1_lcr_wls                        ),
                                .uart_host1_mcr_loop                     (uart_host1_mcr_loop                       ),
                                .uart_host1_mcr_out2                     (uart_host1_mcr_out2                       ),
                                .uart_host1_mcr_out1                     (uart_host1_mcr_out1                       ),
                                .uart_host1_mcr_rts                      (uart_host1_mcr_rts                        ),
                                .uart_host1_mcr_dtr                      (uart_host1_mcr_dtr                        ),
                                .uart_host1_lsr_err_in_rfifo_write_value (uart_host1_lsr_err_in_rfifo_write_value   ),
                                .uart_host1_lsr_temt_write_value         (uart_host1_lsr_temt_write_value           ),
                                .uart_host1_lsr_thre_write_value         (uart_host1_lsr_thre_write_value           ),
                                .uart_host1_lsr_bi_write_value           (uart_host1_lsr_bi_write_value             ),
                                .uart_host1_lsr_fe_write_value           (uart_host1_lsr_fe_write_value             ),
                                .uart_host1_lsr_pe_write_value           (uart_host1_lsr_pe_write_value             ),
                                .uart_host1_lsr_oe_write_value           (uart_host1_lsr_oe_write_value             ),
                                .uart_host1_lsr_dr_write_value           (uart_host1_lsr_dr_write_value             ),
                                .uart_host1_msr_dcd_write_value          (uart_host1_msr_dcd_write_value            ),
                                .uart_host1_msr_ri_write_value           (uart_host1_msr_ri_write_value             ),
                                .uart_host1_msr_dsr_write_value          (uart_host1_msr_dsr_write_value            ),
                                .uart_host1_msr_cts_write_value          (uart_host1_msr_cts_write_value            ),
                                .uart_host1_msr_ddcd_write_value         (uart_host1_msr_ddcd_write_value           ),
                                .uart_host1_msr_teri_write_value         (uart_host1_msr_teri_write_value           ),
                                .uart_host1_msr_ddsr_write_value         (uart_host1_msr_ddsr_write_value           ),
                                .uart_host1_msr_dcts_write_value         (uart_host1_msr_dcts_write_value           ),
                                .uart_host1_scr_scr                      (uart_host1_scr_scr                        ),
                                .uart_host1_dll_dll                      (uart_host1_dll_dll                        ),
                                .uart_host1_dlm_dlm                      (uart_host1_dlm_dlm                        ),
                                .uart_host1_thr_write_pulse              (uart_host1_thr_write_pulse                ),
                                .uart_host1_lsr_write_pulse              (uart_host1_lsr_write_pulse                ),
                                .uart_host1_msr_write_pulse              (uart_host1_msr_write_pulse                ),
                                .uart_host1_rbr_read_pulse               (uart_host1_rbr_read_pulse                 ),
                                .uart_host1_msr_read_pulse               (uart_host1_msr_read_pulse                 )
);                                                                                                
                                                                                                  
/******************************************************************************                   
* psb2plb_bridge                                                                        
*    This module supports inward traffic flow from the PSB bus to the PLB bus           
*    and the PLB_PSB FPGA Registers. This bridge was designed to handle accesses that          
*    the PowerSpan2 device initiates (PS2 device is the master).                        
******************************************************************************/         
defparam psb2plb_bridge.C_PLB_AWIDTH    = C_PLB_AWIDTH;
defparam psb2plb_bridge.C_PLB_DWIDTH    = C_PLB_DWIDTH;
defparam psb2plb_bridge.C_PLB_PRIORITY  = C_PLB_PRIORITY;
													   
defparam psb2plb_bridge.PLB_PSB_FPGA_REG_BASEADDR   = PLB_PSB_FPGA_REG_BASEADDR;
defparam psb2plb_bridge.PLB_PSB_FPGA_REG_LSB_DECODE = PLB_PSB_FPGA_REG_LSB_DECODE;
defparam psb2plb_bridge.PLB_MASTER_BASEADDR1        = PLB_MASTER_BASEADDR1;
defparam psb2plb_bridge.PLB_MASTER_LSB_DECODE1      = PLB_MASTER_LSB_DECODE1;
defparam psb2plb_bridge.PLB_MASTER_BASEADDR2        = PLB_MASTER_BASEADDR2;
defparam psb2plb_bridge.PLB_MASTER_LSB_DECODE2      = PLB_MASTER_LSB_DECODE2;

psb2plb_bridge psb2plb_bridge (
                             // Inputs
                              // System
                                .clk                  (clk                  ),
                                .reset                (reset                ),
                             
                              // PSB Slave
                                .PSBsl_a              (PSBsl_a              ),
                                .PSBsl_d_i            (PSBslma_d_i          ),
                                .PSBsl_dbb_n          (PSBslma_dbb_n        ),
                                .PSBsl_tbst_n         (PSBsl_tbst_n         ),
                                .PSBsl_tsiz           (PSBsl_tsiz           ),
                                .PSBsl_ts_n           (PSBsl_ts_n           ),
                                .PSBsl_tt             (PSBsl_tt             ),
                             
                               // PLB Master
                                .PLBma_RdWdAddr       (PLBma_RdWdAddr       ),
                                .PLBma_RdDBus         (PLBma_RdDBus         ),
                                .PLBma_AddrAck        (PLBma_AddrAck        ),
                                .PLBma_RdDAck         (PLBma_RdDAck         ),
                                .PLBma_WrDAck         (PLBma_WrDAck         ),
                                .PLBma_rearbitrate    (PLBma_rearbitrate    ),
                                .PLBma_Busy           (PLBma_Busy           ),
                                .PLBma_Err            (PLBma_Err            ),
                                .PLBma_RdBTerm        (PLBma_RdBTerm        ),
                                .PLBma_WrBTerm        (PLBma_WrBTerm        ),
                                .PLBma_sSize          (PLBma_sSize          ),
                                .PLBma_pendReq        (PLBma_pendReq        ),
                                .PLBma_pendPri        (PLBma_pendPri        ),
                                .PLBma_reqPri         (PLBma_reqPri         ),
                             
                               // PLB2PSB bridge
                                .accept_psb           (accept_psb           ),

                               // MCSR
                                .mcsr_psb_read_data   (mcsr_psb_read_data   ),
                             
                              // Outputs
                               // PSB Slave
                                .PSBsl_aack_n_o       (PSBsl_aack_n_o       ),
                                .PSBsl_aack_n_en      (PSBsl_aack_n_en      ),
                                .PSBsl_artry_n_o      (PSBsl_artry_n_o      ),
                                .PSBsl_artry_n_en     (PSBsl_artry_n_en     ),
                                .PSBsl_d_o            (PSBsl_d_o            ),  
                                .PSBsl_d_en           (PSBsl_d_en           ),
                                .PSBsl_ta_n_o         (PSBsl_ta_n_o         ),  
                                .PSBsl_ta_n_en        (PSBsl_ta_n_en        ),  
                                .PSBsl_tea_n_o        (PSBsl_tea_n_o        ),  
                                .PSBsl_tea_n_en       (PSBsl_tea_n_en       ),
                             
                               // PLB Master
                                .BGIma_request        (BGIma_request        ),
                                .BGIma_ABus           (BGIma_ABus           ),
                                .BGIma_RNW            (BGIma_RNW            ),
                                .BGIma_BE             (BGIma_BE             ),
                                .BGIma_size           (BGIma_size           ),
                                .BGIma_type           (BGIma_type           ),
                                .BGIma_priority       (BGIma_priority       ),
                                .BGIma_rdBurst        (BGIma_rdBurst        ),
                                .BGIma_wrBurst        (BGIma_wrBurst        ),
                                .BGIma_busLock        (BGIma_busLock        ),
                                .BGIma_abort          (BGIma_abort          ),
                                .BGIma_lockErr        (BGIma_lockErr        ),
                                .BGIma_mSize          (BGIma_mSize          ),
                                .BGIma_ordered        (BGIma_ordered        ),
                                .BGIma_compress       (BGIma_compress       ),
                                .BGIma_guarded        (BGIma_guarded        ),
                                .BGIma_wrDBus         (BGIma_wrDBus         ),

                               // PLB2PSB Bridge
                                .accept_plb           (accept_plb           ),
								.dont_aack_ps2        (dont_aack_ps2        ),

                               // MCSR
                                .psb_mcsr_rd_en_pulse (psb_mcsr_rd_en_pulse ),
                                .psb_mcsr_wr_en_pulse (psb_mcsr_wr_en_pulse ),
                                .psb_mcsr_addr        (psb_mcsr_addr        ),
                                .psb_mcsr_write_data  (psb_mcsr_write_data  ),

                                .psb2plb_psbside_debug (psb2plb_psbside_debug)
                               );


/******************************************************************************                   
* plb2psb_bridge                                                                        
*    This module supports outward traffic flow from the PLB bus to the PSB bus          
*    and the User FPGA MCSRs. This bridge was designed to handle accesses that          
*    come from 64-bit Masters on the PLB bus. It supports single accesses that
*    are from 1 to 8 bytes and it also supports bursts of 4 double words.
******************************************************************************/         
defparam  plb2psb_bridge.C_PLB_AWIDTH                = C_PLB_AWIDTH;
defparam  plb2psb_bridge.C_PLB_DWIDTH                = C_PLB_DWIDTH;
defparam  plb2psb_bridge.C_PLB_MID_WIDTH             = C_PLB_MID_WIDTH;
defparam  plb2psb_bridge.C_PLB_NUM_MASTERS           = C_PLB_NUM_MASTERS;
defparam  plb2psb_bridge.C_BASEADDR                  = C_BASEADDR; 
defparam  plb2psb_bridge.PLB_SLAVE_LSB_DECODE        = PLB_SLAVE_LSB_DECODE;       
defparam  plb2psb_bridge.PLB_PSB_FPGA_REG_BASEADDR   = PLB_PSB_FPGA_REG_BASEADDR;
defparam  plb2psb_bridge.PLB_PSB_FPGA_REG_LSB_DECODE = PLB_PSB_FPGA_REG_LSB_DECODE;

plb2psb_bridge plb2psb_bridge (
                             // Inputs
                              // System
                                .clk                  (clk                  ),
                                .reset                (reset                ),
                             
                              // PSB Master
                                .PSBma_abb_n          (PSBma_abb_n          ),
                                .PSBma_dbb_n          (PSBslma_dbb_n        ),
                                .PSBma_aack_n         (PSBma_aack_n         ),
                                .PSBma_artry_n        (PSBma_artry_n        ),
                                .PSBma_d_i            (PSBslma_d_i          ),
                                .PSBma_ta_n           (PSBma_ta_n           ),
                                .PSBma_ta_n_unreg     (PSB_ta_n_I           ),
                                .PSBma_tea_n          (PSBma_tea_n          ),
                                .PSBma_tea_n_unreg    (PSB_tea_n_I          ),
                                .PSBma_bg_n           (PSBma_bg_n           ),
                                .PSBma_dbg_n          (PSBma_dbg_n          ),
                                .PSBma_dbg_n_unreg    (PSB_dbg_n            ),
                                .PSBma_dbb_n_unreg    (PSB_dbb_n_I          ),
                                .PSBma_aack_n_unreg   (PSB_aack_n_I         ), //rev35
                                .PSBma_bg_n_unreg     (PSB_bg_n             ), //rev35
                                .PSBma_abb_n_unreg    (PSB_abb_n_I          ), //rev35
                                .PSBma_artry_n_unreg  (PSB_artry_n_I        ), //rev35
                         
                              // PLB Slave
                                .PLBsl_ABus           (PLBsl_ABus           ),
                                .PLBsl_PAValid        (PLBsl_PAValid        ),
                                .PLBsl_SAValid        (PLBsl_SAValid        ),
                                .PLBsl_rdPrim         (PLBsl_rdPrim         ),
                                .PLBsl_wrPrim         (PLBsl_wrPrim         ),
                                .PLBsl_masterID       (PLBsl_masterID       ),
                                .PLBsl_abort          (PLBsl_abort          ),
                                .PLBsl_busLock        (PLBsl_busLock        ),
                                .PLBsl_RNW            (PLBsl_RNW            ),
                                .PLBsl_BE             (PLBsl_BE             ),
                                .PLBsl_MSize          (PLBsl_MSize          ),
                                .PLBsl_size           (PLBsl_size           ),
                                .PLBsl_type           (PLBsl_type           ),
                                .PLBsl_compress       (PLBsl_compress       ),
                                .PLBsl_guarded        (PLBsl_guarded        ),
                                .PLBsl_ordered        (PLBsl_ordered        ),
                                .PLBsl_lockErr        (PLBsl_lockErr        ),
                                .PLBsl_wrDBus         (PLBsl_wrDBus         ),
                                .PLBsl_wrBurst        (PLBsl_wrBurst        ),
                                .PLBsl_rdBurst        (PLBsl_rdBurst        ),
                             
                              // MCSR
                                .mcsr_plb_read_data   (mcsr_plb_read_data   ),

                              // PSB2PLB bridge
                                .accept_plb           (accept_plb           ),
                             
                             // Outputs
                              // PSB Master
                                .PSBma_a_o            (PSBma_a_o            ),
                                .PSBma_a_en           (PSBma_a_en           ),
                                .PSBma_abb_n_o        (PSBma_abb_n_o        ),
                                .PSBma_abb_n_en       (PSBma_abb_n_en       ),
                                .PSBma_dbb_n_o        (PSBma_dbb_n_o        ),
                                .PSBma_dbb_n_en       (PSBma_dbb_n_en       ),
                                .PSBma_d_o            (PSBma_d_o            ),
                                .PSBma_d_en           (PSBma_d_en           ),
                                .PSBma_tbst_n_o       (PSBma_tbst_n_o       ),
                                .PSBma_tbst_n_en      (PSBma_tbst_n_en      ),
                                .PSBma_tsiz_o         (PSBma_tsiz_o         ),
                                .PSBma_tsiz_en        (PSBma_tsiz_en        ),
                                .PSBma_ts_n_o         (PSBma_ts_n_o         ),
                                .PSBma_ts_n_en        (PSBma_ts_n_en        ),
                                .PSBma_tt_o           (PSBma_tt_o           ),
                                .PSBma_tt_en          (PSBma_tt_en          ),
                                .PSBma_br_n           (PSB_br_n             ),
                             
                              // PLB Slave
                                .BGOsl_addrAck        (BGOsl_addrAck        ),
                                .BGOsl_SSize          (BGOsl_SSize          ),
                                .BGOsl_wait           (BGOsl_wait           ),
                                .BGOsl_rearbitrate    (BGOsl_rearbitrate    ),
                                .BGOsl_wrDAck         (BGOsl_wrDAck         ),
                                .BGOsl_wrComp         (BGOsl_wrComp         ),
                                .BGOsl_wrBTerm        (BGOsl_wrBTerm        ),
                                .BGOsl_rdDBus         (BGOsl_rdDBus         ),
                                .BGOsl_rdWdAddr       (BGOsl_rdWdAddr       ),
                                .BGOsl_rdDAck         (BGOsl_rdDAck         ),
                                .BGOsl_rdComp         (BGOsl_rdComp         ),
                                .BGOsl_rdBTerm        (BGOsl_rdBTerm        ),
                                .BGOsl_MBusy          (BGOsl_MBusy          ),
                                .BGOsl_MErr           (BGOsl_MErr           ),

                              // PLB2PSB Bridge
                                .accept_psb           (accept_psb           ),
								.dont_aack_ps2        (dont_aack_ps2        ),

                              // MCSR
                                .plb_mcsr_addr        (plb_mcsr_addr        ),
                                .plb_mcsr_write_data  (plb_mcsr_write_data  ),
                                .plb_mcsr_wr_en_pulse (plb_mcsr_wr_en_pulse ),
                                .plb_mcsr_rd_en_pulse (plb_mcsr_rd_en_pulse ),
                                .plb2psb_plbside_debug_bus (plb2psb_plbside_debug_bus),
                                .plb2psb_psbside_debug_bus (plb2psb_psbside_debug_bus)
                               );

assign psb_plb_bridge_debug[0]   = PSBma_bg_n     ;
assign psb_plb_bridge_debug[1]   = PSBsl_ts_n     ;
assign psb_plb_bridge_debug[2]   = PSBma_abb_n    ;
assign psb_plb_bridge_debug[3]   = PSBma_aack_n   ;
assign psb_plb_bridge_debug[4]   = PSBma_artry_n  ;
assign psb_plb_bridge_debug[5]   = PSBsl_tbst_n   ;
assign psb_plb_bridge_debug[6]   = PSBma_dbg_n    ;
assign psb_plb_bridge_debug[7]   = PSBslma_dbb_n  ;
assign psb_plb_bridge_debug[8]   = PSBma_ta_n     ;
assign psb_plb_bridge_debug[9]   = PSBma_tea_n    ;
assign psb_plb_bridge_debug[10]  = PSBsl_tt[1]    ;
assign psb_plb_bridge_debug[11]  = PSBsl_a[0]     ;
assign psb_plb_bridge_debug[12]  = PSBsl_a[1]     ;
assign psb_plb_bridge_debug[13]  = PSBsl_a[2]     ;
assign psb_plb_bridge_debug[14]  = PSBsl_a[3]     ;
assign psb_plb_bridge_debug[15]  = PSBsl_a[4]     ;
assign psb_plb_bridge_debug[16]  = PSBsl_a[5]     ;
assign psb_plb_bridge_debug[17]  = PSBsl_a[6]     ;
assign psb_plb_bridge_debug[18]  = PSBsl_a[7]     ;
assign psb_plb_bridge_debug[19]  = PSBsl_a[8]     ;
assign psb_plb_bridge_debug[20]  = PSBsl_a[9]     ;
assign psb_plb_bridge_debug[21]  = PSBsl_a[10]    ;
assign psb_plb_bridge_debug[22]  = PSBsl_a[11]    ;
assign psb_plb_bridge_debug[23]  = PSBsl_a[12]    ;
assign psb_plb_bridge_debug[24]  = PSBsl_a[13]    ;
assign psb_plb_bridge_debug[25]  = PSBsl_a[14]    ;
assign psb_plb_bridge_debug[26]  = PSBsl_a[15]    ;
assign psb_plb_bridge_debug[27]  = PSBsl_a[16]    ;
assign psb_plb_bridge_debug[28]  = PSBsl_a[17]    ;
assign psb_plb_bridge_debug[29]  = PSBsl_a[18]    ;
assign psb_plb_bridge_debug[30]  = PSBsl_a[19]    ;
assign psb_plb_bridge_debug[31]  = PSBsl_a[20]    ;
assign psb_plb_bridge_debug[32]  = PSBsl_a[21]    ;
assign psb_plb_bridge_debug[33]  = PSBsl_a[22]    ;
assign psb_plb_bridge_debug[34]  = PSBsl_a[23]    ;
assign psb_plb_bridge_debug[35]  = PSBsl_a[24]    ;
assign psb_plb_bridge_debug[36]  = PSBsl_a[25]    ;
assign psb_plb_bridge_debug[37]  = PSBsl_a[26]    ;
assign psb_plb_bridge_debug[38]  = PSBsl_a[27]    ;
assign psb_plb_bridge_debug[39]  = PSBsl_a[28]    ;
assign psb_plb_bridge_debug[40]  = PSBsl_a[29]    ;
assign psb_plb_bridge_debug[41]  = PSBsl_a[30]    ;
assign psb_plb_bridge_debug[42]  = PSBsl_a[31]    ;
assign psb_plb_bridge_debug[43]  = PSBslma_d_i[0] ;
assign psb_plb_bridge_debug[44]  = PSBslma_d_i[1] ;
assign psb_plb_bridge_debug[45]  = PSBslma_d_i[2] ;
assign psb_plb_bridge_debug[46]  = PSBslma_d_i[3] ;
assign psb_plb_bridge_debug[47]  = PSBslma_d_i[24];
assign psb_plb_bridge_debug[48]  = PSBslma_d_i[25];
assign psb_plb_bridge_debug[49]  = PSBslma_d_i[26];
assign psb_plb_bridge_debug[50]  = PSBslma_d_i[27];
assign psb_plb_bridge_debug[51]  = PSBslma_d_i[28];
assign psb_plb_bridge_debug[52]  = PSBslma_d_i[29];
assign psb_plb_bridge_debug[53]  = PSBslma_d_i[30];
assign psb_plb_bridge_debug[54]  = PSBslma_d_i[31];
assign psb_plb_bridge_debug[55]  = PSBslma_d_i[60];
assign psb_plb_bridge_debug[56]  = PSBslma_d_i[61];
assign psb_plb_bridge_debug[57]  = PSBslma_d_i[62];
assign psb_plb_bridge_debug[58]  = PSBslma_d_i[63];
assign psb_plb_bridge_debug[59]  = PSBsl_tsiz[1]  ;
assign psb_plb_bridge_debug[60]  = PSBsl_tsiz[2]  ;
assign psb_plb_bridge_debug[61]  = PSBsl_tsiz[3]  ;
assign psb_plb_bridge_debug[62]  = 0              ;
assign psb_plb_bridge_debug[63]  = 0              ;


assign debug_bus[254:0] = {psb_plb_bridge_debug[63:0], psb2plb_psbside_debug[99:0], 3'b0, plb2psb_plbside_debug_bus[4:0], plb2psb_psbside_debug_bus[82:0]};

endmodule
