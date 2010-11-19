/***********************************************************************
*
* AMIRIX Systems Inc. 
* 77 Chain Lake Drive 
* Halifax, Nova Scotia B3S 1E1 
* 
* (C) 2002 AMIRIX Systems Inc. All rights reserved.
* The information contained herein includes information which is confidential
* and proprietary to AMIRIX Systems Inc. and may not be used or 
* disclosed without prior written consent of AMIRIX Systems Inc. 
*
* Content of this file:                                                 
*   This module is part of the opb_ext_bridge IP for the baseline platform FPGA.
*   This file contains the bridge for both the inward and the outward data path.
*   It interfaces up to the arbiter to make the complete opb/ext bridge solution.
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
* Author:   Adam De Roose  (adam.deroose@amirix.com)
* Date:     Jan 3, 2002
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/opbslave_ext_bridge_v3_10_a/hdl/verilog/bridge.v,v $                                
* Current Revision:        $Revision: 1.2 $                                
* Last Updated:            $Date: 2005/08/24 19:55:14 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                      
*                                                                       
*                                                                       
* Change History:                                                       
* $Log: bridge.v,v $
* Revision 1.2  2005/08/24 19:55:14  kuehner
* Changed MCSR so that if the User Switches are in the off position, the
* register bits will be '0' instead of '1'.
*
* Revision 1.1  2005/08/23 19:22:55  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.3  2005/07/19 17:34:44  kuehner
* Supporting half-word and word accesses to Flashes.
*
* Revision 1.2  2005/07/08 18:42:35  kuehner
* Added fpga_therm input (bit 13 in the switch/led/ppc405_reset register).
*
* Revision 1.1  2005/06/01 12:57:43  labuser
* Initial Revision
*
* Revision 1.2  2005/02/25 13:59:48  kuehner
* Updated to support the AP170/AP1100 Boards. Changed SCSR, LED and switch support.
*
* Revision 1.1  2005/01/22 02:58:01  young
* added parameterized widths to external address, data, switch, and LED
* buses from ver. 3.00.a
*
* Revision 1.1  2003/11/19 15:43:33  kuehner
* Changed FPGA revision register to be 32 bits. Fixed a problem that existed when accessing either of the 2 internal registers (revision or MSCR).
*
* Revision 1.1  2003/09/25 17:39:21  kuehner
* *** empty log message ***
*
* Revision 1.10  2003/09/03 17:48:42  kuehner
* Added config Flash related parameters
*
* Revision 1.9  2003/08/20 14:02:11  kuehner
* Added in functionality for choosing (within MHS file) whether PPC405s stay in reset or become active upon the PLBRST being released.
*
* Revision 1.8  2003/08/14 19:23:45  kuehner
* Added new CPU reset logic
*
* Revision 1.7  2003/07/30 14:52:39  kuehner
* Updated memory map to be as shown in HW03-036's Release 3 memory map
*
* Revision 1.6  2003/06/24 14:05:50  kuehner
* Changed C Flash so that upper quadrant is protected by base_cfg_enable. Added LED register.
*
* Revision 1.5  2003/06/19 15:29:25  kuehner
* Added a read only FPGA revision register (16-bits)
*
* Revision 1.4  2003/06/04 19:14:54  kuehner
* Made timeout timer 128 clock cycles; Drive tri-state control signals to '1' before tristating
*
* Revision 1.3  2003/06/04 17:21:17  kuehner
* Removed some old commented out code and fixed default state of main state machine
*
* Revision 1.2  2003/05/15 14:54:33  kuehner
* *** empty log message ***
*
* Revision 1.1  2003/05/02 17:21:58  smith
* from Jeremy, May 2
*
* Revision 1.14  2002/02/28 18:04:41  doiron
* Fixed up etherenet states
*
* Revision 1.13  2002/02/18 18:00:54  doiron
* Initial Check-In
*
* Revision 1.12  2002/02/12 19:36:48  deroose
* Fixed retry problem
*
* Revision 1.11  2002/02/06 21:00:31  deroose
* Added tea checking in wait_pci_ack state.  Made wait_pci_ack go back to
* pci_start if a retry_n occurs.
*
* Revision 1.10  2002/02/06 16:05:57  doiron
* Forced mn_abus to zero in opb_end state
*
* Revision 1.9  2002/02/05 14:57:25  doiron
* Added wait for pci_cs to go away before returning to idle in opb->pci access.
* Fixed ld bus direction when doing pci read.
*
* Revision 1.8  2002/02/01 18:11:46  deroose
* Added hold_ncycle state to FSM for timing purposes.
*
* Revision 1.7  2002/01/28 17:46:59  deroose
* Made changes to mn_select and sampling of on-chip inputs
*
* Revision 1.6  2002/01/25 17:46:42  doiron
* Fixed typo
*
* Revision 1.5  2002/01/24 20:02:43  deroose
* Removed double sampling of inputs.
*
* Revision 1.4  2002/01/17 20:57:21  deroose
* Removed flash state.  Any use of write enable (we) was replaced by rd/nwr
*
* Revision 1.3  2002/01/15 17:55:51  deroose
* Changed idle state transitions.  Was looking at active high chip selects, changed
* to active low.
*
* Revision 1.2  2002/01/15 17:16:43  deroose
* Changed OPB_Dbus to OPB_DbusM and OPB_DbusSl.  Added in logic to set both
* the Mn_Dbus and the Sln_Dbus to zero when not active.
*
* Revision 1.1  2002/01/14 21:01:44  deroose
* initial commit
*
*
*
***********************************************************************/

`timescale 1 ns   / 1 ps

module bridge (
// INPUTS
   clk                               ,   // i 
   reset_n                           ,   // i 

   led_bits                          ,   // o
   fpga_test_switch                  ,   // i
   fpga_therm                        ,   // i

   RSTCPU1							 ,   // i
   RSTCPU2                           ,	 // i

   opb_dbusm                        ,   // i 
   opb_abus                          ,   // i
   opb_rnw                           ,   // i
   opb_be                            ,   // i

   opb_select                        ,   // i
   opb                               ,   // i

   sl_retry                          ,   // i
                                                    
   EXTi_data                         ,   // i
                                              
// OUTPUTS 
   sl_dbus                           ,    // o 
   sl_toutsup                        ,    // o 
   sl_xferack                        ,    // o 
   sl_errack                         ,    // o

   EXTo_data                         ,    // o
   EXTo_addr                         ,    // o
   EXTo_we_n                         ,    // o
   EXTt_data                         ,    // o
   EXTt_addr                         ,    // o
   EXTt_we_n                         ,    // o
                                          
   cpld_cs_n                         ,    // o
   flash_cs_n                        ,    // o
   con_flash_cs_n                    ,    // o
   con_flash_cs_n_T                  ,    // o
   sysace_cs_n                       ,    // o

   EXTt_oe_n                         ,    // o
   EXTo_oe_n                         ,    // o

   ppc1_sw_reset                     ,    // o
   ppc2_sw_reset				          // o
);


/********************
* Module Parameters *
********************/
parameter flash_wait_cycles      = 6;
parameter base_cfg_enable        = 1'b0;
parameter FPGA_revision          = 0;
parameter ppc1_reset_value       = 0;
parameter ppc2_reset_value       = 1;
parameter size_of_config_flash   = 4;
parameter size_of_protected_area = 1;

// Address decoding parameters. Since the smallest address space is
// 16 MB, we are able to decode devices based on bits [0:7] of LA[0:31]
// or OPB_addr[0:31]. These parameters are the values that are used
// to decode on these 8 bits (we are not using the entire 32 bit address
// in our compare statements)

parameter sdram_addr_base     = 7'h00 ; // 32'h0000_0000  address for DDR SDRAM
parameter sdram_addr_size     = 7'h10 ; // 32'h2000_0000  512 MB

parameter flash_addr_base     = 7'h10 ; // 32'h2000_0000
parameter flash_addr_size     = 7'h02 ; // 32'h0400_0000  64 MB

parameter con_flash_addr_base = 7'h12 ; // 32'h2400_0000
parameter con_flash_addr_size = 7'h01 ; // 32'h0200_0000  32 MB

parameter cpld_addr_base      = 7'h13 ; // 32'h2600_0000
parameter cpld_addr_size      = 7'h01 ; // 32'h0200_0000  32 MB

parameter sys_ace_addr_base   = 8'h28 ; // 32'h2800_0000
parameter sys_ace_addr_size   = 8'h01 ; // 32'h0100_0000  16 MB

parameter fpga_register_base  = 8'h29 ; // 32'h2900_0000
parameter fpga_register_size  = 8'h01 ; // 32'h0100_0000  16 MB

parameter pci_reg_addr_base   = 7'h15 ; // 32'h2A00_0000
parameter pci_reg_addr_size   = 7'h01 ; // 32'h0200_0000  32 MB

parameter pci_addr_base       = 7'h16 ; // 32'h2C00_0000
parameter pci_addr_size       = 7'h10 ; // 32'h2000_0000  512 MB

// TEST SIGNAL PARAMETERS
parameter test_swtch_width = 1;
parameter test_led_width   = 1; 

/*************
* Module I/O *
*************/
input        clk;
input        reset_n;

input [0:31] opb_dbusm;
input [0:31] opb_abus;
input        opb_rnw;
input [0:3]  opb_be;
input        opb_select;
input        opb;

input        sl_retry;

input [0:31] EXTi_data;                      

input        RSTCPU1;
input        RSTCPU2;

output [0:31] sl_dbus;
output        sl_toutsup;
output        sl_xferack;
output        sl_errack;

output [0:31] EXTo_data;    
output [0:31] EXTo_addr;    
output        EXTo_we_n;    
output        EXTt_data;             // 1 = tri-stated; 0 = enabled
output        EXTt_addr; 			 // 1 = tri-stated; 0 = enabled
output        EXTt_we_n; 			 // 1 = tri-stated; 0 = enabled

output        cpld_cs_n;
output        flash_cs_n;
output        con_flash_cs_n;
output        con_flash_cs_n_T;
output        sysace_cs_n;

output        EXTo_oe_n;
output        EXTt_oe_n;			 // 1 = tri-stated; 0 = enabled

input [0:test_swtch_width-1]  fpga_test_switch;
input                         fpga_therm;
output[0:test_led_width-1]    led_bits;
output                        ppc1_sw_reset;
output		                  ppc2_sw_reset;

/*****************************
* Internal Registers & Wires *
*****************************/
// output registers
reg [0:31] sl_dbus;
reg        sl_toutsup;
reg        sl_xferack;
reg        sl_errack;

reg        cpld_cs_n;
reg        flash_cs_n;
reg        con_flash_cs_n;
reg        con_flash_cs_n_T;
reg        sysace_cs_n;

reg [0:31] EXTo_data; 
reg        EXTo_we_n;
reg [0:31] EXTo_addr;
reg        EXTo_oe_n;

reg        EXTt_data;
reg        opb_master_en;

// sampled inputs
reg [0:31] EXTi_data_s;

// internal logic registers
reg[2:0]   count;

reg        opb_access_out;
reg[0:31]  opb_out_read_data;
reg        opb_ext_access_done;

reg        cpld_access;
reg        flash_access;
reg        fpga_register_access;
reg        con_flash_access;
reg        sysace_access;
reg        err_flash;

reg[2:0]   num_ext_accesses;
reg[2:0]   current_ext_access;

reg[0:test_led_width-1] led_bits;
reg                     ppc1_sw_reset;
reg                     ppc2_sw_reset;

// Assign tri-state for inouts and tristateable outputs
assign EXTt_we_n  = !opb_master_en;
assign EXTt_addr  = !opb_master_en;
assign EXTt_oe_n  = !opb_master_en;


// Sample the FPGA external inputs
always@(posedge clk or negedge reset_n)
begin
    if(!reset_n)
        EXTi_data_s    <=  0;
    else 										 
        EXTi_data_s    <=  EXTi_data;
end


/******************************************************************************
* EXT_INTERFACE_FSM - This FSM bridges looks after the EXT bus control signals
*                     including the PCI-Local Bridge.  It is the top controller
*                     for this bridge module. It takes the address decoder
*                     signals as inputs and either kicks the EXT_OPB_Bridge_OUT
*                     or handles the access itself.
* Author:   Jeremy Kuehner
* Date:     Feb 3, 2003
*******************************************************************************
******************************************************************************/
reg[8:0] ext_interface_state;

parameter ext_interface_idle             = 9'b0_0000_0001;
parameter service_cpld_access            = 9'b0_0000_0010;
parameter service_flash_access           = 9'b0_0000_0100;
parameter service_con_flash_access       = 9'b0_0000_1000;
parameter service_sysace_access          = 9'b0_0001_0000;
parameter ext_interface_wait             = 9'b0_0010_0000;
parameter end_cpld_flash_ace_access      = 9'b0_0100_0000;
parameter wait_for_opb_master_done       = 9'b0_1000_0000;
parameter service_fpga_register_access   = 9'b1_0000_0000;


/*********************************************************************
* State 1: ext_inteface_idle
*                    
*                    
*********************************************************************/

always @(posedge clk or negedge reset_n)       
begin
    if (!reset_n) 
    begin
        opb_access_out      <= 0;
        opb_out_read_data   <= 0;
        opb_ext_access_done <= 0;

        cpld_cs_n           <= 1;
        flash_cs_n          <= 1;
        con_flash_cs_n      <= 1;
        con_flash_cs_n_T    <= 1;  // allow CPLD to control the con flash
        sysace_cs_n         <= 1;

        opb_master_en       <= 0;
        EXTo_addr           <= 0;
        EXTo_we_n           <= 1;
        EXTo_oe_n           <= 1;
        EXTt_data           <= 1;
        EXTo_data           <= 0;

        num_ext_accesses    <= 0;
		current_ext_access  <= 0;

        led_bits            <= 0;
		ppc1_sw_reset       <= ppc1_reset_value; // by default, '0'
		ppc2_sw_reset       <= ppc2_reset_value; // by default, '1'

        count               <= 0;
        
        ext_interface_state <= ext_interface_idle;
    end

    else
    begin
		con_flash_cs_n_T <= 0; // if not in reset, FPGA drives con_flash_cs_n
		led_bits         <= led_bits;
		ppc1_sw_reset    <= ppc1_sw_reset;
   		ppc2_sw_reset	 <=	ppc2_sw_reset;

        case (ext_interface_state)

/*********************************************************************
* State 1: ext_interface_idle
*                    This state waits for a kick from the address
*                    decoder logic. It then performs the proper
*                    access and acknowledges the approp. master
*                    after the access is complete.
*********************************************************************/
        ext_interface_idle:
        begin
            opb_access_out      <= 0;
            opb_out_read_data   <= 0;
            opb_ext_access_done <= 0;

            cpld_cs_n           <= 1;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 1;

            opb_master_en       <= 0;
            EXTo_addr           <= 0;
            EXTo_we_n           <= 1;
            EXTo_oe_n           <= 1;
            EXTt_data           <= 1;
            EXTo_data           <= 0;

            num_ext_accesses    <= 1;
		    current_ext_access  <= 1;

            count               <= 0;
            
            if (cpld_access)
                ext_interface_state <= service_cpld_access;
            else if (flash_access)
                ext_interface_state <= service_flash_access;
            else if (con_flash_access)
                ext_interface_state <= service_con_flash_access;
            else if (sysace_access)
                ext_interface_state <= service_sysace_access;
			else if (fpga_register_access)
			    ext_interface_state <= service_fpga_register_access;
            else
                ext_interface_state <= ext_interface_idle;
        end

/*********************************************************************
* State 2: service_cpld_access
*                    This state asserts the CPLD cs and ensures that
*                    all of the CPLD EXT interface signals are set
*                    properly. It then proceeds to the next state to 
*                    wait several clock cycles and terminate the access
*                    while latching the read data if the access was a read.
*********************************************************************/
        service_cpld_access:
        begin
            opb_access_out      <= 1;
            opb_out_read_data   <= opb_out_read_data;
            opb_ext_access_done <= 0;

            cpld_cs_n           <= 0;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 1;

            opb_master_en       <= 1; // enabled if opb is master
			case(current_ext_access)
			1: EXTo_addr[30:31] <= opb_abus[30:31];
			2: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b01;
			3: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b10;
			4: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b11;
			default: EXTo_addr[30:31] <= opb_abus[30:31];
			endcase
            EXTo_addr[0:29]     <= opb_abus[0:29];
            EXTo_we_n           <= opb_rnw;
		    EXTo_oe_n           <= ~opb_rnw;
            EXTt_data           <= opb_rnw; // opb is writing

            // Need to perform data bus byte switching (due to the OPB bus
			// use of the Data bus when not doing 32 bit transfers)
            case(opb_be)
            4'b1111: EXTo_data <= opb_dbusm;
            4'b1100: EXTo_data <= { 2{opb_dbusm[0:15]} };
            4'b0011: EXTo_data <= { 2{opb_dbusm[16:31]} };
            4'b1000: EXTo_data <= { 4{opb_dbusm[0:7]} };
            4'b0100: EXTo_data <= { 4{opb_dbusm[8:15]} };
            4'b0010: EXTo_data <= { 4{opb_dbusm[16:23]} };
            4'b0001: EXTo_data <= { 4{opb_dbusm[24:31]} };
            default: EXTo_data <= opb_dbusm;
            endcase

            num_ext_accesses    <= 1;
		    current_ext_access  <= current_ext_access;

            count               <= 0;

            ext_interface_state <= ext_interface_wait;
        end

/*********************************************************************
* State 3: service_flash_access
*                    This state asserts the FLASH cs and ensures that
*                    all of the FLASH EXT interface signals are set
*                    properly. It then proceeds to the next state to 
*                    wait several clock cycles and terminate the access
*                    while latching the read data if the access was a read.
*********************************************************************/
        service_flash_access:
        begin
            opb_access_out      <= 1;
            opb_out_read_data   <= opb_out_read_data;
            opb_ext_access_done <= 0;

            cpld_cs_n           <= 1;
            flash_cs_n          <= 0;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 1;

            opb_master_en       <= 1; // enabled if opb is master
			case(current_ext_access)
			1: EXTo_addr[30:31] <= opb_abus[30:31];
			2: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b10;
			default: EXTo_addr[30:31] <= opb_abus[30:31];
			endcase
            EXTo_addr[0:29]     <= opb_abus[0:29];
            EXTo_we_n           <= opb_rnw;
		    EXTo_oe_n           <= ~opb_rnw;
            EXTt_data           <= opb_rnw; // opb is writing

            // Need to perform data bus byte switching (due to the OPB bus
			// use of the Data bus when not doing 32 bit transfers)
            case(opb_be)
            4'b1111: EXTo_data <= opb_dbusm;
            4'b1100: EXTo_data <= { 2{opb_dbusm[0:15]} };
            4'b0011: EXTo_data <= { 2{opb_dbusm[16:31]} };
            4'b1000: EXTo_data <= { 4{opb_dbusm[0:7]} };
            4'b0100: EXTo_data <= { 4{opb_dbusm[8:15]} };
            4'b0010: EXTo_data <= { 4{opb_dbusm[16:23]} };
            4'b0001: EXTo_data <= { 4{opb_dbusm[24:31]} };
            default: EXTo_data <= opb_dbusm;
            endcase

            // Need to determine how many Flash accesses to perform
			// based on size of opb access (only for reads since
			// writes must be byte to config flash and byte/half-word
			// to program flash)
            if ( (opb_rnw == 1) && (opb_be == 4'b1111) )
			// OPB Word Read
                num_ext_accesses <= 2;
			else
			// OPB Write or OPB non-word Read
			    num_ext_accesses <= 1;
		    current_ext_access   <= current_ext_access;

            count               <= 0;

            ext_interface_state <= ext_interface_wait;
        end

/*********************************************************************
* State 4: service_con_flash_access
*                    This state asserts the FLASH cs and ensures that
*                    all of the FLASH EXT interface signals are set
*                    properly. It then proceeds to the next state to 
*                    wait several clock cycles and terminate the access
*                    while latching the read data if the access was a read.
*********************************************************************/
        service_con_flash_access:
        begin
            opb_access_out      <= 1;             
            opb_out_read_data   <= opb_out_read_data;                    
            opb_ext_access_done <= 0;                    

            cpld_cs_n           <= 1;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= err_flash; // assert if access is allowed
            sysace_cs_n         <= 1;

            opb_master_en       <= 1; // enabled if opb is master
			case(current_ext_access)
			1: EXTo_addr[30:31] <= opb_abus[30:31];
			2: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b01;
			3: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b10;
			4: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b11;
			default: EXTo_addr[30:31] <= opb_abus[30:31];
			endcase
            EXTo_addr[0:29]     <= opb_abus[0:29];
            EXTo_we_n           <= opb_rnw;
		    EXTo_oe_n           <= ~opb_rnw;
            EXTt_data           <= opb_rnw; // opb is writing

            // Need to perform data bus byte switching (due to the OPB bus
			// use of the Data bus when not doing 32 bit transfers)
            case(opb_be)
            4'b1111: EXTo_data <= opb_dbusm;
            4'b1100: EXTo_data <= { 2{opb_dbusm[0:15]} };
            4'b0011: EXTo_data <= { 2{opb_dbusm[16:31]} };
            4'b1000: EXTo_data <= { 4{opb_dbusm[0:7]} };
            4'b0100: EXTo_data <= { 4{opb_dbusm[8:15]} };
            4'b0010: EXTo_data <= { 4{opb_dbusm[16:23]} };
            4'b0001: EXTo_data <= { 4{opb_dbusm[24:31]} };
            default: EXTo_data <= opb_dbusm;
            endcase

            // Need to determine how many Config Flash accesses to perform
			// based on size of opb access (only for reads since
			// writes must be byte to config flash and byte/half-word
			// to program flash)
            if ( (opb_rnw == 1) && (opb_be == 4'b1111) )
			// OPB Word Read
                num_ext_accesses <= 4;
			else if ( (opb_rnw == 1) && ((opb_be == 4'b1100) || (opb_be == 4'b0011)))
			// OPB Half-Word Read
			    num_ext_accesses <= 2;
			else
			// OPB Byte Read or OPB Write
			    num_ext_accesses <= 1;
		    current_ext_access   <= current_ext_access;

            count               <= 0;

            ext_interface_state <= ext_interface_wait;
        end

/*********************************************************************
* State 5: service_sysace_access - This state asserts the system
*                    ace cs and control signals.
*********************************************************************/
        service_sysace_access:
        begin
            opb_access_out      <= 1;
            opb_out_read_data   <= opb_out_read_data;
            opb_ext_access_done <= 0;

            cpld_cs_n           <= 1;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 0;

            opb_master_en       <= 1; // enabled if opb is master
			case(current_ext_access)
			1: EXTo_addr[30:31] <= opb_abus[30:31];
			2: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b01;
			3: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b10;
			4: EXTo_addr[30:31] <= opb_abus[30:31] + 2'b11;
			default: EXTo_addr[30:31] <= opb_abus[30:31];
			endcase
            EXTo_addr[0:29]     <= opb_abus[0:29];
            EXTo_we_n           <= opb_rnw;
		    EXTo_oe_n           <= ~opb_rnw;
            EXTt_data           <= opb_rnw; // opb is writing

            // Need to perform data bus byte switching (due to the OPB bus
			// use of the Data bus when not doing 32 bit transfers)
            case(opb_be)
            4'b1111: EXTo_data <= opb_dbusm;
            4'b1100: EXTo_data <= { 2{opb_dbusm[0:15]} };
            4'b0011: EXTo_data <= { 2{opb_dbusm[16:31]} };
            4'b1000: EXTo_data <= { 4{opb_dbusm[0:7]} };
            4'b0100: EXTo_data <= { 4{opb_dbusm[8:15]} };
            4'b0010: EXTo_data <= { 4{opb_dbusm[16:23]} };
            4'b0001: EXTo_data <= { 4{opb_dbusm[24:31]} };
            default: EXTo_data <= opb_dbusm;
            endcase

            // Need to determine how many System Ace accesses to perform
			// based on size of opb access (only for reads since
			// writes must be byte to config flash and byte/half-word
			// to program flash)
            if ( (opb_rnw == 1) && (opb_be == 4'b1111) )
			// OPB Word Read
                num_ext_accesses <= 4;
			else if ( (opb_rnw == 1) && ((opb_be == 4'b1100) || (opb_be == 4'b0011)))
			// OPB Half-Word Read
			    num_ext_accesses <= 2;
			else
			// OPB Byte Read or OPB Write
			    num_ext_accesses <= 1;
		    current_ext_access   <= current_ext_access;

            count               <= 0;

            ext_interface_state <= ext_interface_wait;
        end

/*********************************************************************
* State 6: service_fpga_register_access
*                    This state returns the FPGA revision number back
*                    to the Master if the access is for the Revision register
*                    If the access is for the LED register, then
*                    the led bit is returned if it is a read, otherwise
*                    the led bit is updated from the opb data bus.
*********************************************************************/
		service_fpga_register_access:
		begin
            opb_access_out      <= 1;
			if (opb_abus[29:31] == 3'b000)
			// Accessing FPGA revision register
			begin
                opb_out_read_data[0:31]  <= FPGA_revision;

			    led_bits      <= led_bits;
				ppc1_sw_reset <= ppc1_sw_reset;
				ppc2_sw_reset <= ppc2_sw_reset;
			end

            else if (opb_abus[29:31] == 3'b100)
			// Accessing RESET/LED/SWITCH register
			begin
				opb_out_read_data[0:12]  <= 13'b0;
				opb_out_read_data[13]    <= fpga_therm;
				opb_out_read_data[14]    <= RSTCPU1;
				opb_out_read_data[15]    <= RSTCPU2;
				opb_out_read_data[16:23] <= ~fpga_test_switch;
				opb_out_read_data[24:31] <= led_bits;

				if ( (!opb_rnw) && (opb_be == 4'b1111) )
				// 32-bit Write to RESET/LED/SWITCH register
				begin
	   	        	led_bits      <= opb_dbusm[32-test_led_width:31];
					ppc1_sw_reset <= opb_dbusm[14];
					ppc2_sw_reset <= opb_dbusm[15];
				end

				else
				begin
				    led_bits      <= led_bits;
					ppc1_sw_reset <= ppc1_sw_reset;
					ppc2_sw_reset <= ppc2_sw_reset;
				end
			end

            else
			// Accessing empty address space
			begin
                opb_out_read_data[0:31]  <= 32'b0;

			    led_bits      <= led_bits;
				ppc1_sw_reset <= ppc1_sw_reset;
				ppc2_sw_reset <= ppc2_sw_reset;
			end

            opb_ext_access_done <= 0;

            cpld_cs_n           <= 1;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 1;

            opb_master_en       <= 0;
            EXTo_addr           <= 0;
            EXTo_we_n           <= 1;
            EXTo_oe_n           <= 1;
            EXTt_data           <= 1;
            EXTo_data           <= 0;

		    num_ext_accesses    <= 1;
		    current_ext_access  <= current_ext_access;

            count               <= 0;
            
            ext_interface_state <= end_cpld_flash_ace_access;
		end

/*********************************************************************
* State 7: ext_interface_wait
*                    This state keeps the CPLD/Flash/Con_Flash control
*                    signals asserted and waits for 6 clock cycles to
*                    meet timing of these devices.
*********************************************************************/
        ext_interface_wait:
        begin
            opb_access_out      <= 0;
            case(opb_be)
                4'b1111: 
                begin
				    if (flash_cs_n == 0)
					// Program Flash access (16 bytes on the Ext Bus)
					begin
					    case (current_ext_access)
						1:
						begin
						    opb_out_read_data[0:15]  <= EXTi_data_s[0:15];
                            opb_out_read_data[16:31] <= opb_out_read_data[16:31];
						end
						2:
						begin
						    opb_out_read_data[0:15]  <= opb_out_read_data[0:15];
                            opb_out_read_data[16:31] <= EXTi_data_s[0:15];
						end
						default: opb_out_read_data <= opb_out_read_data;
						endcase
					end
					else
					// Not Program Flash access (8 bytes on the Ext Bus)
					begin
					    case (current_ext_access)
						1:
						begin
						    opb_out_read_data[0:7]   <= EXTi_data_s[0:7];
                            opb_out_read_data[8:31]  <= opb_out_read_data[8:31];
						end
						2:
						begin
                            opb_out_read_data[0:7]   <= opb_out_read_data[0:7];
						    opb_out_read_data[8:15]  <= EXTi_data_s[0:7];
                            opb_out_read_data[16:31] <= opb_out_read_data[16:31];
						end
						3:
						begin
                            opb_out_read_data[0:15]  <= opb_out_read_data[0:15];
						    opb_out_read_data[16:23] <= EXTi_data_s[0:7];
                            opb_out_read_data[24:31] <= opb_out_read_data[24:31];
						end
						4:
						begin
						    opb_out_read_data[0:23]  <= opb_out_read_data[0:23];
                            opb_out_read_data[24:31] <= EXTi_data_s[0:7];
						end
						default: opb_out_read_data <= opb_out_read_data;
						endcase
					end
                end

                4'b1100, 4'b0011:
				begin
				    if (flash_cs_n == 0)
					// Program Flash access (16 bytes on the Ext Bus)
					begin
					    case (current_ext_access)
						1:       opb_out_read_data <= { 2{EXTi_data_s[0:15]} };
						default: opb_out_read_data <= opb_out_read_data;
						endcase
					end
					else
					// Not Program Flash access (8 bytes on the Ext Bus)
					begin
					    case (current_ext_access)
						1:
						begin
						    opb_out_read_data[0:7]   <= EXTi_data_s[0:7];
                            opb_out_read_data[8:15]  <= opb_out_read_data[8:15];
						    opb_out_read_data[16:23] <= EXTi_data_s[0:7];
						    opb_out_read_data[24:31] <= opb_out_read_data[24:31];
						end
						2:
						begin
						    opb_out_read_data[0:7]   <= opb_out_read_data[0:7];
                            opb_out_read_data[8:15]  <= EXTi_data_s[0:7];
						    opb_out_read_data[16:23] <= opb_out_read_data[16:23];
						    opb_out_read_data[24:31] <= EXTi_data_s[0:7];
						end

						default: opb_out_read_data <= opb_out_read_data;
						endcase
					end
				end

                4'b1000, 4'b0100, 4'b0010, 4'b0001:
                begin
				    if (flash_cs_n == 0)
					// byte access to program flash so return the proper byte
					begin
					    if (opb_abus[31] == 0)
						// reading lsbyte so return [0:7]
				            opb_out_read_data <= { 4{EXTi_data_s[0:7]} };
						else
						// reading msbyte so return [8:15]
						    opb_out_read_data <= { 4{EXTi_data_s[8:15]} };
					end
					else
					// not program flash so return the ls byte of external bus
					begin
					    opb_out_read_data <= { 4{EXTi_data_s[0:7]} };
					end
                end

                default: opb_out_read_data <= EXTi_data_s;
            endcase

            opb_ext_access_done <= 0;

            cpld_cs_n           <= cpld_cs_n;
            flash_cs_n          <= flash_cs_n;
            con_flash_cs_n      <= con_flash_cs_n;
            sysace_cs_n         <= sysace_cs_n;

            opb_master_en       <= opb_master_en;
            EXTo_addr           <= EXTo_addr;
            EXTo_we_n           <= EXTo_we_n;
            EXTo_oe_n           <= EXTo_oe_n;
            EXTt_data           <= EXTt_data;
            EXTo_data           <= EXTo_data;

		    num_ext_accesses    <= num_ext_accesses;
		    current_ext_access  <= current_ext_access;

            count               <= count + 1;

            if (count == flash_wait_cycles - 1)
            begin
                ext_interface_state <= end_cpld_flash_ace_access;
            end
            else
            begin
                ext_interface_state <= ext_interface_wait;
            end
        end

/*********************************************************************
* State 8: end_cpld_flash_ace_access
*                    This state finishes the access to the CPLD,the flash
*                    or sysace device. If reading, the read data is latched
*                    for the master.
*********************************************************************/
        end_cpld_flash_ace_access:
        begin
            opb_access_out      <= 0;
            opb_out_read_data   <= opb_out_read_data;

            cpld_cs_n           <= 1;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 1;

            opb_master_en       <= opb_master_en;
            EXTo_addr           <= EXTo_addr;
            EXTo_we_n           <= 1;
            EXTo_oe_n           <= 1;
            EXTt_data           <= 1;
            EXTo_data           <= EXTo_data;

		    num_ext_accesses    <= num_ext_accesses;

            count               <= 0;

            if (current_ext_access == num_ext_accesses)
			// All of the Ext Bus accesses have taken place so wait for
			// OPB master to complete
			begin
	            opb_ext_access_done <= 1;
    		    current_ext_access  <= current_ext_access;
                ext_interface_state <= wait_for_opb_master_done;
			end
			else
			// Not all of the Ext Bus accesses have taken place so 
			// go back and start the next Ext Bus access (based on
			// which cs is asserted)
			begin
                opb_ext_access_done <= 0;
    		    current_ext_access  <= current_ext_access + 1;
			    if (cpld_cs_n == 0)
				// CPLD access
				    ext_interface_state <= service_cpld_access;
				else if (flash_cs_n == 0)
				// Program Flash access
				    ext_interface_state <= service_flash_access;
				else if (con_flash_cs_n == 0)
				// Config Flash access
				    ext_interface_state <= service_con_flash_access;
				else
				// SystemAce access
				    ext_interface_state <= service_sysace_access;
			end

        end

/*********************************************************************
* State 9: wait_for_opb_master_done
*                    This state waits for the OPB Bus to finish before
*                    going back to the idle state. If we go back to 
*                    idle state before OPB master is finished, the 
*                    address decoder will trigger another access which
*                    shouldn't occur.
*********************************************************************/
        wait_for_opb_master_done:
        begin
            opb_access_out      <= 0;
            opb_out_read_data   <= opb_out_read_data;
            opb_ext_access_done <= 0;

            cpld_cs_n           <= 1;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 1;

            opb_master_en       <= 0;
            EXTo_addr           <= 0;
            EXTo_we_n           <= 1;
            EXTo_oe_n           <= 1;
            EXTt_data           <= 1;
            EXTo_data           <= 0;

		    num_ext_accesses    <= num_ext_accesses;
		    current_ext_access  <= current_ext_access;

            count               <= 0;

            if (opb_select)
            // OPB is master and it still is asserted
                ext_interface_state <= wait_for_opb_master_done;
            else
                ext_interface_state <= ext_interface_idle;
        end


/*********************************************************************
* Default State
*********************************************************************/
        default:
        begin
            opb_access_out      <= 0;
            opb_out_read_data   <= 0;
            opb_ext_access_done <= 0;

            cpld_cs_n           <= 1;
            flash_cs_n          <= 1;
            con_flash_cs_n      <= 1;
            sysace_cs_n         <= 1;

            opb_master_en       <= 0;
            EXTo_addr           <= 0;
            EXTo_we_n           <= 1;
            EXTo_oe_n           <= 1;
            EXTt_data           <= 1;
            EXTo_data           <= 0;

		    num_ext_accesses    <= 0;
		    current_ext_access  <= 0;

            count               <= 0;
            
            ext_interface_state <= ext_interface_idle;
        end
        endcase
    end
end


/******************************************************************************
* EXT_OPB_Bridge_OUT - This FSM bridges the OPB bus logic to the EXT bus logic
*                      for OPB accesses to the EXT bus.
*                      The OPB Bridge is a slave on the OPB Bus.
* Author:   Jeremy Kuehner
* Date:     Feb 3, 2003
*******************************************************************************
******************************************************************************/
reg[1:0]  opb_bridge_out_state;

parameter opb_bridge_out_idle   = 2'b01;
parameter wait_for_ext_response = 2'b10;

always @(posedge clk or negedge reset_n)       
begin
    if (!reset_n) 
    begin
        sl_xferack           <= 0;
        sl_dbus              <= 0;
        sl_toutsup           <= 0;
        sl_errack            <= 0;
        opb_bridge_out_state <= opb_bridge_out_idle;
    end

    else
    begin
        sl_toutsup <= 1; // suppressing opb timeouts when accessing external bus
        sl_errack  <= 0; // never asserting sl_errack

        case (opb_bridge_out_state)

/*****************************************************************
* State  1: opb_bridge_out_idle - Stay in idle state until an    *
*                                 access begins. (Triggered by   *
*                                 address decoder.)              *
*****************************************************************/
        opb_bridge_out_idle:
        begin
            sl_xferack <= 0;
            sl_dbus    <= 0;
            if (opb_access_out)
                opb_bridge_out_state <= wait_for_ext_response;
            else 
                opb_bridge_out_state <= opb_bridge_out_idle;
        end

/**********************************************************************
* State  2: wait_for_ext_response - Stay in this state until the      *
*                                   EXT bus device has been accessed  *
*                                   and is finished. (Either data has *
*                                   been written or read data is      *
*                                   available for the OPB bus.        *
**********************************************************************/
        wait_for_ext_response:
        begin
            if (opb_ext_access_done)
            // The access has finished so handshake back to the OPB master
            begin
			    if (sl_retry)
				// A retry ended the access so don't assert sl_xferack
				// or sl_dbus
				begin
                    sl_xferack <= 0;
					sl_dbus    <= 0;
				end

                else
				// The access completed without a retry so acknowledge
				// the OPB master appropriately (with sl_xferack)
				begin
                    sl_xferack <= 1;

                    if (opb_rnw)
                    // read access so place data on opb data bus
                        sl_dbus <= opb_out_read_data;
                    else
                    // write access
                        sl_dbus <= 0;
				end

                opb_bridge_out_state <= opb_bridge_out_idle;
            end

            else
            // The access has not finished so wait
            begin
                sl_xferack <= 0;
                sl_dbus    <= 0;
                opb_bridge_out_state <= wait_for_ext_response;
            end
        end

/***************************************************************
* Default State                                                *
***************************************************************/
        default:
        begin
            sl_xferack           <= 0;
            sl_dbus              <= 0;
            opb_bridge_out_state <= opb_bridge_out_idle;
        end
        endcase
    end
end


/******************************************************************************
* Decode_logic - This logic decodes the OPB address bus or the EXT address bus
*                and asserts a signal that can be used to trigger the proper
*                access to take place in the OPB Bridge FSM.
* Author:   Jeremy Kuehner
* Date:     Feb 3, 2003
*******************************************************************************
******************************************************************************/

// Decode the OPB and EXT address busses and
// assert appropriate chip selects for devices.
always@(posedge clk or negedge reset_n)
begin
    if(!reset_n)
    begin
        cpld_access            <= 0;
		fpga_register_access   <= 0;
        sysace_access          <= 0;
        flash_access           <= 0;                                     
        con_flash_access       <= 0;                                     
        err_flash              <= 0;
    end

    else
    begin
        if(opb & opb_select)
        begin
        // OPB Bridge has the EXT bus
            if((opb_abus[0:6] >= cpld_addr_base) &
               (opb_abus[0:6] <= (cpld_addr_base + cpld_addr_size-1)))
            begin
            // OPB access to the CPLD
                cpld_access            <= 1;
				fpga_register_access   <= 0;
                sysace_access          <= 0;
                flash_access           <= 0;
                con_flash_access       <= 0;
                err_flash              <= 0;
            end

            else if((opb_abus[0:7] >= fpga_register_base) &
                    (opb_abus[0:7] <= (fpga_register_base + fpga_register_size-1)))
            begin
            // OPB access to the FPGA revision register
                cpld_access            <= 0;
				fpga_register_access   <= 1;
                sysace_access          <= 0;
                flash_access           <= 0;
                con_flash_access       <= 0;
                err_flash              <= 0;
            end


            else if((opb_abus[0:6] >= flash_addr_base) &
                    (opb_abus[0:6] <= (flash_addr_base + flash_addr_size-1)))
            begin
            // OPB access to the flash
                cpld_access            <= 0;
				fpga_register_access   <= 0;
                sysace_access          <= 0;
                flash_access           <= 1;
                con_flash_access       <= 0;
                err_flash              <= 0;
            end

            else if((opb_abus[0:6] >= con_flash_addr_base) &
                    (opb_abus[0:6] <= (con_flash_addr_base + con_flash_addr_size-1)))
            begin
            // OPB access to the configuration flash
                cpld_access            <= 0;
				fpga_register_access   <= 0;
                sysace_access          <= 0;
                flash_access           <= 0;
                con_flash_access       <= 1;

                case (size_of_config_flash)

                // Flash is 4MB device
                4:
				begin
				    if (size_of_protected_area == 2)
					// Protecting top 2MB of Flash
					begin
                        if ( (opb_abus[10:11] >= 2'b10) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else if (size_of_protected_area == 4)
					// Protecting top 4MB of Flash
					begin
                        if ( (opb_abus[10:11] >= 2'b00) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else
					// Protecting top 1MB of Flash
					begin
                        if ( (opb_abus[10:11] >= 2'b11) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
				end

                // Flash is 8MB device
				8:
				begin
				    if (size_of_protected_area == 2)
					// Protecting top 2MB of Flash
					begin
                        if ( (opb_abus[9:11] >= 3'b110) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else if (size_of_protected_area == 4)
					// Protecting top 4MB of Flash
					begin
                        if ( (opb_abus[9:11] >= 3'b100) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else
					// Protecting top 1MB of Flash
					begin
                        if ( (opb_abus[9:11] >= 3'b111) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
				end

                // Flash is 16MB device
				16:
				begin
				    if (size_of_protected_area == 2)
					// Protecting top 2MB of Flash
					begin
                        if ( (opb_abus[8:11] >= 4'b1110) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else if (size_of_protected_area == 4)
					// Protecting top 4MB of Flash
					begin
                        if ( (opb_abus[8:11] >= 4'b1100) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else
					// Protecting top 1MB of Flash
					begin
                        if ( (opb_abus[8:11] >= 4'b1111) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
				end

                // Flash is 32MB device
				32:
				begin
				    if (size_of_protected_area == 2)
					// Protecting top 2MB of Flash
					begin
                        if ( (opb_abus[7:11] >= 5'b11110) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else if (size_of_protected_area == 4)
					// Protecting top 4MB of Flash
					begin
                        if ( (opb_abus[7:11] >= 5'b11100) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else
					// Protecting top 1MB of Flash
					begin
                        if ( (opb_abus[7:11] >= 5'b11111) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
				end

                // Flash is unknown size (assume 4MB device)
				default:
				begin
				    if (size_of_protected_area == 2)
					// Protecting top 2MB of Flash
					begin
                        if ( (opb_abus[10:11] >= 2'b10) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else if (size_of_protected_area == 4)
					// Protecting top 4MB of Flash
					begin
                        if ( (opb_abus[10:11] >= 2'b00) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
					else
					// Protecting top 1MB of Flash
					begin
                        if ( (opb_abus[10:11] >= 2'b11) & (base_cfg_enable == 1'b0) )
                        // OPB is trying to access boot sector and boot sector
                        // access is denied
                            err_flash <= 1;
                        else
                        // Either the boot sector is not being accessed or 
                        // boot sector access is allowed
                            err_flash <= 0;
					end
				end
				endcase
            end

            else if((opb_abus[0:7] >= sys_ace_addr_base) &
                    (opb_abus[0:7] <= (sys_ace_addr_base + sys_ace_addr_size-1)))
            begin
            // OPB access to the system ace
                cpld_access            <= 0;
				fpga_register_access   <= 0;
                sysace_access          <= 1;
                flash_access           <= 0;
                con_flash_access       <= 0;
                err_flash              <= 0;
            end

            else
            begin
            // OPB access to unmapped address space
                cpld_access            <= 0;
				fpga_register_access   <= 0;
                sysace_access          <= 0;
                flash_access           <= 0;
                con_flash_access       <= 0;
                err_flash              <= 0;
            end                                               
        end                                                   

        else
        begin
        // No one has the EXT bus so don't decode
            cpld_access            <= 0;
			fpga_register_access   <= 0;
            sysace_access          <= 0;
            flash_access           <= 0;
            con_flash_access       <= 0;
            err_flash              <= 0;
        end
    end
end

endmodule
