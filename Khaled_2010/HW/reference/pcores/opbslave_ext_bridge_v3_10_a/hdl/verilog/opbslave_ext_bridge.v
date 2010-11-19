/***********************************************************************
*
* AMIRIX Systems Inc. 
``* 77 Chain Lake Drive 
* Halifax, Nova Scotia B3S 1E1 
* 
* (C) 2002 AMIRIX Systems Inc. All rights reserved.
* The information contained herein includes information which is confidential
* and proprietary to AMIRIX Systems Inc. and may not be used or 
* disclosed without prior written consent of AMIRIX Systems Inc. 
*
* Content of this file:                                                 
*    This is the top level of the OPB_EXT Bridge IP module. This bridge is 
*    bi-directional in that it takes care of both, transactions from the OPB Bus
*    to the External bus and transactions from the External bus to the OPB Bus.
*    This IP contains three files: opb_ext_bridge.v, bridge.v, arbiter.v
*
* Structure:   
* 
*            -- top.v
*                 -- PPC405.v
*                 -- opb_ext_bridge.v
*                      -- bridge.v
*                      -- arbiter.v
*
*-----------------------------------------------------------------------------
*
*                                                                       
* 
* Author:   Adam De Roose   (adam.deroose@amirix.com)
* Date:     Jan 9, 2002
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/opbslave_ext_bridge_v3_10_a/hdl/verilog/opbslave_ext_bridge.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:55 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                      
*                                                                       
*                                                                       
* Change History:                                                       
* $Log: opbslave_ext_bridge.v,v $
* Revision 1.1  2005/08/23 19:22:55  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.2  2005/07/08 18:42:35  kuehner
* Added fpga_therm input (bit 13 in the switch/led/ppc405_reset register).
*
* Revision 1.1  2005/06/01 12:57:43  labuser
* Initial Revision
*
* Revision 1.3  2005/05/05 18:33:13  labuser
* Changed addressing for local bus. Instead  of opb_abus[0:24] getting used,
* opb_abus[7:31] is used.
*
* Revision 1.2  2005/02/25 13:59:48  kuehner
* Updated to support the AP170/AP1100 Boards. Changed SCSR, LED and switch support.
*
* Revision 1.1  2005/01/22 02:58:01  young
* added parameterized widths to external address, data, switch, and LED
* buses from ver. 3.00.a
*
* Revision 1.1  2003/11/18 21:10:33  kuehner
* Initial Revision - updated from opb_ext_bridge_v2_00_a
*
* Revision 1.1  2003/09/25 17:39:21  kuehner
* *** empty log message ***
*
* Revision 1.9  2003/09/03 17:48:42  kuehner
* Added config Flash related parameters
*
* Revision 1.8  2003/08/20 14:02:11  kuehner
* Added in functionality for choosing (within MHS file) whether PPC405s stay in reset or become active upon the PLBRST being released.
*
* Revision 1.7  2003/08/14 19:23:51  kuehner
* Added new CPU reset logic
*
* Revision 1.6  2003/07/30 14:52:39  kuehner
* Updated memory map to be as shown in HW03-036's Release 3 memory map
*
* Revision 1.5  2003/07/03 14:44:39  kuehner
* Added an internal version of pci_bg_n so that EDK could properly handle DIR attribute for signal
*
* Revision 1.4  2003/06/24 14:05:50  kuehner
* Changed C Flash so that upper quadrant is protected by base_cfg_enable. Added LED register.
*
* Revision 1.3  2003/06/19 15:29:25  kuehner
* Added a read only FPGA revision register (16-bits)
*
* Revision 1.2  2003/06/18 18:35:30  kuehner
* Added support for guardian module within the plb2opb bridge that prevents deadlock from occuring (brought some signals that the guardian module needed out of the opb_ext bridge)
*
* Revision 1.1  2003/05/02 17:21:58  smith
* from Jeremy, May 2
*
* Revision 1.5  2002/01/28 20:23:45  deroose
* Fixed too few port connections warning.
*
* Revision 1.4  2002/01/17 20:55:58  deroose
* Removed write enable signal (we).  Going to use rd/nwr signal.
*
* Revision 1.3  2002/01/15 21:31:51  doiron
* Connected err_flash signal
*
* Revision 1.2  2002/01/15 17:54:56  deroose
* Changed OPB_Dbus to OPB_Dbusm and OPB_Dbussl
*
* Revision 1.1  2002/01/14 21:02:07  deroose
* initial commit
*
*
*
***********************************************************************/

`timescale 1 ns / 1 ps

/***********************************************************************
Module Description:
************************************************************************/
module opbslave_ext_bridge (
  // INPUTS
    clk                                ,    // i 
    reset                              ,    // i 

    fpga_test_switch                   ,    // i
	fpga_therm                         ,    // i
	fpga_test_led                      ,    // o

    opb_dbusm                         ,    // i 
    opb_abus                           ,    // i     
    opb_rnw                            ,    // i     
    opb_select                         ,    // i 
    opb_be                             ,    // i 
	opb_seqAddr                        ,    // i

    EXT_cpld_br_n                      ,    // i

	RSTCPU1							   ,    // i
	RSTCPU2                            ,	// i

  // INOUTS
	EXT_data_I						   ,	// i
	EXT_data_O						   ,	// o
	EXT_data_T						   ,	// t
	EXT_addr_I						   ,	// i
	EXT_addr_O						   ,	// o
	EXT_addr_T						   ,	// t
	EXT_we_n_I						   ,	// i
	EXT_we_n_O						   ,	// o
	EXT_we_n_T						   ,	// t
	EXT_oe_n_I                         ,    // i
	EXT_oe_n_O                         ,    // o
	EXT_oe_n_T                         ,    // o

	EXT_con_flash_cs_n_I               ,    // i
    EXT_con_flash_cs_n_O               ,    // o 
    EXT_con_flash_cs_n_T               ,    // o 


  // OUTPUTS                                     
    ppc1_sw_reset                      ,    // o
    ppc2_sw_reset                      ,    // o

    sl_dbus                            ,    // o 
    sl_retry                           ,    // o 
    sl_toutsup                         ,    // o 
    sl_errack                          ,    // o 
    sl_xferack                         ,    // o 

    EXT_cpld_bg_n                      ,    // o

    EXT_cpld_cs_n                      ,    // o 
    EXT_flash_cs_n                     ,    // o 
    EXT_sysace_cs_n                    ,    // o
	opb_ext_bridge_debug_bus
);


/********************
* Module Parameters *
********************/
// OPB BUS PARAMETERS
parameter C_OPB_DWIDTH = 32;
parameter C_OPB_AWIDTH = 32;

// BRIDGE PARAMETERS
parameter flash_wait_cycles      = 6;
parameter base_cfg_enable        = 1'b0;
parameter FPGA_revision          = 32'hdeadbeef;
parameter ppc1_reset_value       = 0;
parameter ppc2_reset_value       = 1;
parameter size_of_config_flash   = 4;
parameter size_of_protected_area = 1;

defparam bridge.flash_wait_cycles       = flash_wait_cycles;
defparam bridge.base_cfg_enable         = base_cfg_enable;
defparam bridge.FPGA_revision           = FPGA_revision;
defparam bridge.ppc1_reset_value        = ppc1_reset_value;
defparam bridge.ppc2_reset_value        = ppc2_reset_value;
defparam bridge.size_of_config_flash    = size_of_config_flash;
defparam bridge.size_of_protected_area  = size_of_protected_area;


// Address decoding parameters. Since the smallest address space is
// 32 MB, we are able to decode devices based on bits [0:6] of LA[0:31]
// or OPB_addr[0:31]. These parameters are the values that are used
// to decode on these 7 bits (we are not using the entire 32 bit address
// in our compare statements)

parameter sdram_addr_base     = 7'h00 ; // 32'h0000_0000  address for DDR SDRAM
parameter sdram_addr_size     = 7'h10 ; // 32'h2000_0000  512 MB

defparam bridge.sdram_addr_base   = sdram_addr_base;
defparam bridge.sdram_addr_size   = sdram_addr_size;



parameter flash_addr_base     = 7'h10 ; // 32'h2000_0000
parameter flash_addr_size     = 7'h02 ; // 32'h0400_0000  64 MB

defparam bridge.flash_addr_base   = flash_addr_base;
defparam bridge.flash_addr_size   = flash_addr_size;

parameter con_flash_addr_base = 7'h12 ; // 32'h2400_0000
parameter con_flash_addr_size = 7'h01 ; // 32'h0200_0000  32 MB

defparam bridge.con_flash_addr_base   = con_flash_addr_base;
defparam bridge.con_flash_addr_size   = con_flash_addr_size;

parameter cpld_addr_base      = 7'h13 ; // 32'h2600_0000
parameter cpld_addr_size      = 7'h01 ; // 32'h0200_0000  32 MB

defparam bridge.cpld_addr_base   = cpld_addr_base;
defparam bridge.cpld_addr_size   = cpld_addr_size;

parameter sys_ace_addr_base   = 8'h28 ; // 32'h2800_0000
parameter sys_ace_addr_size   = 8'h01 ; // 32'h0100_0000  16 MB

defparam bridge.sys_ace_addr_base   = sys_ace_addr_base;
defparam bridge.sys_ace_addr_size   = sys_ace_addr_size;

parameter fpga_register_base  = 8'h29 ; // 32'h2900_0000
parameter fpga_register_size  = 8'h01 ; // 32'h0100_0000  16 MB

defparam bridge.fpga_register_base  = fpga_register_base;
defparam bridge.fpga_register_size  = fpga_register_size;

parameter pci_reg_addr_base   = 7'h15 ; // 32'h2A00_0000
parameter pci_reg_addr_size   = 7'h01 ; // 32'h0200_0000  32 MB

defparam bridge.pci_reg_addr_base   = pci_reg_addr_base;
defparam bridge.pci_reg_addr_size   = pci_reg_addr_size;

parameter pci_addr_base       = 7'h16 ; // 32'h2C00_0000
parameter pci_addr_size       = 7'h10 ; // 32'h2000_0000  512 MB

defparam bridge.pci_addr_base   = pci_addr_base;
defparam bridge.pci_addr_size   = pci_addr_size;

// ARBITER PARAMETERS
parameter   opb_bridge_addr_base = 7'h10; // 32'h2000_0000
parameter   opb_bridge_addr_size = 7'h16; // 32'h2C00_0000	704 MB

defparam arbiter.opb_bridge_addr_base = opb_bridge_addr_base;
defparam arbiter.opb_bridge_addr_size = opb_bridge_addr_size;

// EXTERNAL INTERFACE PARAMETERS
parameter ext_dwidth = 32;
parameter ext_awidth = 32;

// TEST SIGNAL PARAMETERS
parameter test_swtch_width = 1;
parameter test_led_width   = 1; 

defparam test_switch_led.test_swtch_width = test_swtch_width;
defparam test_switch_led.test_led_width   = test_led_width  ;

defparam bridge.test_swtch_width = test_swtch_width;
defparam bridge.test_led_width   = test_led_width  ;
      

/*************
* Module I/O *
*************/
input                          clk;
input                          reset;

input  [0:test_swtch_width-1]  fpga_test_switch;
input                          fpga_therm;
output [0:test_led_width-1]    fpga_test_led;
						  
input [0:C_OPB_DWIDTH-1]       opb_dbusm;
input [0:C_OPB_AWIDTH-1]       opb_abus;
input                          opb_rnw;
input                          opb_select;
input [0:3]                    opb_be;
input                          opb_seqAddr;

output [0:C_OPB_DWIDTH-1]      sl_dbus;
output                         sl_retry;
output                         sl_toutsup;
output                         sl_errack;
output                         sl_xferack;

input                          EXT_cpld_br_n;
			  
input  [0:ext_dwidth-1]        EXT_data_I;
output [0:ext_dwidth-1]        EXT_data_O;	  
output		                   EXT_data_T;
input  [0:ext_awidth-1]        EXT_addr_I;
output [0:ext_awidth-1]        EXT_addr_O;	  
output		                   EXT_addr_T;
input                          EXT_we_n_I;
output                         EXT_we_n_O;	  
output		                   EXT_we_n_T;

input                          EXT_oe_n_I;
output                         EXT_oe_n_O;
output                         EXT_oe_n_T;
		  
output                         EXT_cpld_bg_n;
			  
output                         EXT_cpld_cs_n;
output                         EXT_flash_cs_n;
input                          EXT_con_flash_cs_n_I;
output                         EXT_con_flash_cs_n_O;
output                         EXT_con_flash_cs_n_T;
output                         EXT_sysace_cs_n;

input                          RSTCPU1;
input						   RSTCPU2;
output						   ppc1_sw_reset;
output						   ppc2_sw_reset;

output wire [60:0]             opb_ext_bridge_debug_bus;
		  
wire                           INT_pci_bg_n;

wire   [0:31]                  INT_data_I;
wire   [0:31]                  INT_data_O;	  
wire   [0:31]                  INT_addr_O;

wire   [0:test_swtch_width-1]  user_rw_bits;


	
// Assign internal-external data and address buses
// Note external buses can be smaller than 32 bits but not bigger
//assign EXT_data_O = INT_data_O[0:ext_dwidth-1];	
assign EXT_data_O = INT_data_O[32-ext_dwidth:31];	
assign INT_data_I = {EXT_data_I,{(32-ext_dwidth){1'b0}}};

//assign EXT_addr_O = INT_addr_O[0:ext_awidth-1];
assign EXT_addr_O = INT_addr_O[32-ext_awidth:31];

/*****************************
* Internal Registers & Wires *
*****************************/
wire          opb;
wire          reset_n;

assign reset_n = ~reset;

/*****************************
* Instantiate Wires for IOBs *
*****************************/

/*********************************************
* Instantiating Arbiter (OPB_Bridge_Arbiter) *
*********************************************/
    arbiter  arbiter (
       // INPUTS
        .clk                 (clk)           ,
        .reset_n             (reset_n)       ,				 
        .opb_select          (opb_select)    ,				 
        .opb_abus            (opb_abus)      ,				 
        .cpld_br_n           (EXT_cpld_br_n) ,				 
															 
       // OUTPUTS											 
        .cpld_bg_n           (EXT_cpld_bg_n) ,				 
        .sl_retry            (sl_retry)      ,				 
        .opb                 (opb)           
    );														 	
															 
															 
/************************************						 
* Instantiating Bridge (OPB_Bridge) *						 	
************************************/						 	
    bridge  bridge(											 	
       // INPUTS											 
        .clk                 (clk)               ,  
        .reset_n             (reset_n)           ,  

        .led_bits            (user_rw_bits)      ,
		.fpga_test_switch    (fpga_test_switch)  ,
		.fpga_therm          (fpga_therm)        ,

        .RSTCPU1             (RSTCPU1)           ,
		.RSTCPU2			 (RSTCPU2)           ,
        .ppc1_sw_reset       (ppc1_sw_reset)     ,
		.ppc2_sw_reset 		 (ppc2_sw_reset) 	 ,

        .opb_dbusm           (opb_dbusm)        ,
        .opb_abus            (opb_abus)          ,
        .opb_rnw             (opb_rnw)           ,
        .opb_be              (opb_be)            ,
                                                 
        .opb_select          (opb_select)        ,
        .opb                 (opb)               ,
		.sl_retry            (sl_retry)          ,
												 
        .EXTi_data           (INT_data_I)        ,	
                                                 		
       // OUTPUTS                                  	
        .sl_dbus             (sl_dbus)           ,		
        .sl_toutsup          (sl_toutsup)        ,		
        .sl_xferack          (sl_xferack)        ,		
        .sl_errack           (sl_errack)         ,	
												 				  
		.EXTt_data           (EXT_data_T)        , 
		.EXTt_addr           (EXT_addr_T)        , 
		.EXTt_we_n           (EXT_we_n_T)        , 
		.EXTo_data           (INT_data_O)        ,
		.EXTo_addr           (INT_addr_O)        ,
		.EXTo_we_n           (EXT_we_n_O)        ,

        .cpld_cs_n           (EXT_cpld_cs_n)     ,
        .flash_cs_n          (EXT_flash_cs_n)    ,
        .con_flash_cs_n      (EXT_con_flash_cs_n_O),
		.con_flash_cs_n_T    (EXT_con_flash_cs_n_T),
        .sysace_cs_n         (EXT_sysace_cs_n)   ,

        .EXTt_oe_n           (EXT_oe_n_T)        ,
		.EXTo_oe_n			 (EXT_oe_n_O)
    );

/************************************						 
* Instantiating Bridge (OPB_Bridge) *						 	
************************************/						 	
test_switch_led test_switch_led (
                                 .clk          (clk)              ,
								 .reset_n      (reset_n)          ,
								 .user_rw_bits (user_rw_bits)     ,
								 .test_switch  (fpga_test_switch) ,

								 .test_led     (fpga_test_led)
                                );

// CHIPSCOPE BUS
assign opb_ext_bridge_debug_bus[0]  = EXT_addr_O[24];
assign opb_ext_bridge_debug_bus[1]  = EXT_addr_O[23];
assign opb_ext_bridge_debug_bus[2]  = EXT_addr_O[22];
assign opb_ext_bridge_debug_bus[3]  = EXT_addr_O[21];
assign opb_ext_bridge_debug_bus[4]  = EXT_addr_O[20];
assign opb_ext_bridge_debug_bus[5]  = EXT_addr_O[19];
assign opb_ext_bridge_debug_bus[6]  = EXT_addr_O[18];
assign opb_ext_bridge_debug_bus[7]  = EXT_addr_O[17];
assign opb_ext_bridge_debug_bus[8]  = EXT_addr_O[16];
assign opb_ext_bridge_debug_bus[9]  = EXT_addr_O[15];
assign opb_ext_bridge_debug_bus[10] = EXT_addr_O[14];
assign opb_ext_bridge_debug_bus[11] = EXT_addr_O[13];
assign opb_ext_bridge_debug_bus[12] = EXT_addr_O[12];
assign opb_ext_bridge_debug_bus[13] = EXT_addr_O[11];
assign opb_ext_bridge_debug_bus[14] = EXT_addr_O[10];
assign opb_ext_bridge_debug_bus[15] = EXT_addr_O[9];
assign opb_ext_bridge_debug_bus[16] = EXT_addr_O[8];
assign opb_ext_bridge_debug_bus[17] = EXT_addr_O[7];
assign opb_ext_bridge_debug_bus[18] = EXT_addr_O[6];
assign opb_ext_bridge_debug_bus[19] = EXT_addr_O[5];
assign opb_ext_bridge_debug_bus[20] = EXT_addr_O[4];
assign opb_ext_bridge_debug_bus[21] = EXT_addr_O[3];
assign opb_ext_bridge_debug_bus[22] = EXT_addr_O[2];
assign opb_ext_bridge_debug_bus[23] = EXT_addr_O[1];
assign opb_ext_bridge_debug_bus[24] = EXT_addr_O[0];
assign opb_ext_bridge_debug_bus[25] = EXT_addr_T;
assign opb_ext_bridge_debug_bus[26] = EXT_data_O[15];
assign opb_ext_bridge_debug_bus[27] = EXT_data_O[14];
assign opb_ext_bridge_debug_bus[28] = EXT_data_O[13];
assign opb_ext_bridge_debug_bus[29] = EXT_data_O[12];
assign opb_ext_bridge_debug_bus[30] = EXT_data_O[11];
assign opb_ext_bridge_debug_bus[31] = EXT_data_O[10];
assign opb_ext_bridge_debug_bus[32] = EXT_data_O[9];
assign opb_ext_bridge_debug_bus[33] = EXT_data_O[8];
assign opb_ext_bridge_debug_bus[34] = EXT_data_O[7];
assign opb_ext_bridge_debug_bus[35] = EXT_data_O[6];
assign opb_ext_bridge_debug_bus[36] = EXT_data_O[5];
assign opb_ext_bridge_debug_bus[37] = EXT_data_O[4];
assign opb_ext_bridge_debug_bus[38] = EXT_data_O[3];
assign opb_ext_bridge_debug_bus[39] = EXT_data_O[2];
assign opb_ext_bridge_debug_bus[40] = EXT_data_O[1];
assign opb_ext_bridge_debug_bus[41] = EXT_data_O[0];
assign opb_ext_bridge_debug_bus[42] = EXT_data_T;
assign opb_ext_bridge_debug_bus[43] = EXT_con_flash_cs_n_O;
assign opb_ext_bridge_debug_bus[44] = EXT_flash_cs_n;
assign opb_ext_bridge_debug_bus[45] = EXT_data_I[15];
assign opb_ext_bridge_debug_bus[46] = EXT_data_I[14];
assign opb_ext_bridge_debug_bus[47] = EXT_data_I[13];
assign opb_ext_bridge_debug_bus[48] = EXT_data_I[12];
assign opb_ext_bridge_debug_bus[49] = EXT_data_I[11];
assign opb_ext_bridge_debug_bus[50] = EXT_data_I[10];
assign opb_ext_bridge_debug_bus[51] = EXT_data_I[9];
assign opb_ext_bridge_debug_bus[52] = EXT_data_I[8];
assign opb_ext_bridge_debug_bus[53] = EXT_data_I[7];
assign opb_ext_bridge_debug_bus[54] = EXT_data_I[6];
assign opb_ext_bridge_debug_bus[55] = EXT_data_I[5];
assign opb_ext_bridge_debug_bus[56] = EXT_data_I[4];
assign opb_ext_bridge_debug_bus[57] = EXT_data_I[3];
assign opb_ext_bridge_debug_bus[58] = EXT_data_I[2];
assign opb_ext_bridge_debug_bus[59] = EXT_data_I[1];
assign opb_ext_bridge_debug_bus[60] = EXT_data_I[0];

endmodule
