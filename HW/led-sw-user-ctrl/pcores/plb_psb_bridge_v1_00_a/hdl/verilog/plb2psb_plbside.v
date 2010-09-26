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
*   The PLB control logic for the PLB2PSB Bridge.
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/plb2psb_plbside.v,v $                                
* Current Revision:        $Revision: 1.2 $                                
* Last Updated:            $Date: 2005/08/24 16:11:11 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: plb2psb_plbside.v,v $
* Revision 1.2  2005/08/24 16:11:11  kuehner
* Removed logic to trigger a PSB register access (including VUART accesses).
*
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.4  2005/06/21 17:36:31  kuehner
* Added in chipscope debug bus.
*
* Revision 1.3  2005/05/03 18:47:24  kuehner
* Updated bridge to incorporate all the changes that were made
* during HW05-019 lab debugging.
*
* Revision 1.2  2005/03/10 17:44:30  kuehner
* Removed local clocking situations.
*
* Revision 1.1  2005/02/25 14:09:34  kuehner
* Initial Revision.
*
*
*
*
***********************************************************************/

`timescale 1 ns / 1 ps

/***********************************************************************
Module Description:

This module provides control logic for the PLB side of the PLB2PSB bridge.
************************************************************************/

module plb2psb_plbside (
                      // Inputs
                       // System
                        clk                  ,
                        reset                ,

                       // PLB Slave
                        PLBsl_ABus           ,
                        PLBsl_PAValid        ,
                        PLBsl_SAValid        ,
                        PLBsl_rdPrim         ,
                        PLBsl_wrPrim         ,
                        PLBsl_masterID       ,
                        PLBsl_abort          ,
                        PLBsl_busLock        ,
                        PLBsl_RNW            ,
                        PLBsl_BE             ,
                        PLBsl_MSize          ,
                        PLBsl_size           ,
                        PLBsl_type           ,
                        PLBsl_compress       ,
                        PLBsl_guarded        ,
                        PLBsl_ordered        ,
                        PLBsl_lockErr        ,
                        PLBsl_wrDBus         ,
                        PLBsl_wrBurst        ,
                        PLBsl_rdBurst        ,

                       // PSB Side
                        psb_plb_read_data    ,
                        psb_plb_read_data_val,
                        psb_plb_error        ,
                        psb_plb_access_done  ,

                       // PLB_PSB FPGA Registers
                        mcsr_plb_read_data   ,

                       // PSB2PLB Bridge
                        accept_plb           ,

                      // Outputs
                       // PLB Slave
                        BGOsl_addrAck        ,
                        BGOsl_SSize          ,
                        BGOsl_wait           ,
                        BGOsl_rearbitrate    ,
                        BGOsl_wrDAck         ,
                        BGOsl_wrComp         ,
                        BGOsl_wrBTerm        ,
                        BGOsl_rdDBus         ,
                        BGOsl_rdWdAddr       ,
                        BGOsl_rdDAck         ,
                        BGOsl_rdComp         ,
                        BGOsl_rdBTerm        ,
                        BGOsl_MBusy          ,
                        BGOsl_MErr           ,

                       // PLB_PSB FPGA Registers
                        plb_mcsr_addr        , 
                        plb_mcsr_write_data  , 
                        plb_mcsr_wr_en_pulse , 
                        plb_mcsr_rd_en_pulse ,
                                             
                       // PSB2PLB Bridge     
                        accept_psb           ,

                       // PSB Side
                        plb_psb_start_access ,
                        plb_psb_address      ,
                        plb_psb_burst        ,
                        plb_psb_tsiz         ,
                        plb_psb_rnw          ,
                        plb_psb_write_data1  ,
                        plb_psb_write_data2  ,
                        plb_psb_write_data3  ,
                        plb_psb_write_data4		 ,
						plb2psb_plbside_debug_bus
);


/********************
* Module Parameters *
********************/
// Address Decoding
parameter  C_PLB_AWIDTH                = 32;
parameter  C_PLB_DWIDTH                = 64;
parameter  C_PLB_MID_WIDTH             = 4;
parameter  C_PLB_NUM_MASTERS           = 16;
parameter  C_BASEADDR                  = 32'h30000000; // allowable addresses = 00000000;10000000;20000000;...
parameter  PLB_SLAVE_LSB_DECODE        = 3; // Least significant bit (counting from 0)  to decode address on
parameter  PLB_PSB_FPGA_REG_BASEADDR   = 32'h30002000; // 0x30002000 - 0x30003FFF
parameter  PLB_PSB_FPGA_REG_LSB_DECODE = 18;
parameter  VUART0_UPPER_BIT_DECODE  = 19;
parameter  VUART1_UPPER_BIT_DECODE  = 18;

parameter  SLAVE_SIZE = 2'b01; // 64-bit slave

/*************
* Module I/O *
*************/
// Inputs
 // System
input                        clk                  ;
input                        reset                ;

 // PLB Slave
input  [0:C_PLB_AWIDTH-1]    PLBsl_ABus           ;
input                        PLBsl_PAValid        ;
input                        PLBsl_SAValid        ;
input                        PLBsl_rdPrim         ;
input                        PLBsl_wrPrim         ;
input  [0:C_PLB_MID_WIDTH-1] PLBsl_masterID       ;
input                        PLBsl_abort          ;
input                        PLBsl_busLock        ;
input                        PLBsl_RNW            ;
input  [0:C_PLB_DWIDTH/8-1]  PLBsl_BE             ;
input  [0:1]                 PLBsl_MSize          ;
input  [0:3]                 PLBsl_size           ;
input  [0:2]                 PLBsl_type           ;
input                        PLBsl_compress       ;
input                        PLBsl_guarded        ;
input                        PLBsl_ordered        ;
input                        PLBsl_lockErr        ;
input  [0:C_PLB_DWIDTH-1]    PLBsl_wrDBus         ;
input                        PLBsl_wrBurst        ;
input                        PLBsl_rdBurst        ;

 // PSB Side
input [0:63]                 psb_plb_read_data    ;
input                        psb_plb_read_data_val;
input                        psb_plb_error        ;
input                        psb_plb_access_done  ;

 // PLB_PSB FPGA Registers
input [0:63]                 mcsr_plb_read_data   ;

 // PSB2PLB Bridge
input                        accept_plb           ;

// Outputs
 // PLB Slave
output reg                          BGOsl_addrAck        ;
output reg [0:1]                    BGOsl_SSize          ;
output wire                         BGOsl_wait           ;
output reg                          BGOsl_rearbitrate    ;
output wire                         BGOsl_wrDAck         ;
output wire                         BGOsl_wrComp         ;
output wire                         BGOsl_wrBTerm        ;
output wire [0:C_PLB_DWIDTH-1]      BGOsl_rdDBus         ;
output wire [0:3]                   BGOsl_rdWdAddr       ;
output wire                         BGOsl_rdDAck         ;
output wire                         BGOsl_rdComp         ;
output wire                         BGOsl_rdBTerm        ;
output wire [0:C_PLB_NUM_MASTERS-1] BGOsl_MBusy          ;
output wire [0:C_PLB_NUM_MASTERS-1] BGOsl_MErr           ;

 // PLB_PSB FPGA Registers
output [(PLB_PSB_FPGA_REG_LSB_DECODE+1):31] plb_mcsr_addr        ;
output [0:31]                               plb_mcsr_write_data  ;
output                                      plb_mcsr_wr_en_pulse ;
output                                      plb_mcsr_rd_en_pulse ;

 // PSB2PLB Bridge   
output reg                   accept_psb           ;

 // PSB Side
output wire                  plb_psb_start_access ;
output [0:31]                plb_psb_address      ;
output                       plb_psb_burst        ;
output [1:3]                 plb_psb_tsiz         ;
output                       plb_psb_rnw          ;
output reg [0:63]            plb_psb_write_data1  ;
output reg [0:63]            plb_psb_write_data2  ;
output reg [0:63]            plb_psb_write_data3  ;
output reg [0:63]            plb_psb_write_data4  ;

output wire [4:0]            plb2psb_plbside_debug_bus;
/*******************************
* Module Reg/Wire Declarations *
*******************************/
wire [0:31]					C_BASEADDR_wire;

reg                         allowable_transfer_size; // asynch
reg							mcsr_access;			 // asynch
reg                         mcsr_vuart_access;       // asynch
reg                         non32_mcsr_access;		 // asynch
reg                         accept_access;           // asynch

reg[0:3]                    PLBsl_masterID_int;      // asynch

reg                         pa1_full         ;
reg                         burst_1          ;
reg                         rnw_1            ;
reg [0:7]                   be_1             ;
reg [0:C_PLB_AWIDTH - 1]    addr_1           ;
reg [0:3]                   master_id_1      ;
reg                         master_64bit_1   ;
reg                         mcsr_access_1    ;

reg                         pa2_full         ;
reg                         burst_2          ;
reg                         rnw_2            ;
reg [0:7]                   be_2             ;
reg [0:C_PLB_AWIDTH - 1]    addr_2           ;
reg [0:3]                   master_id_2      ;
reg                         master_64bit_2   ;
reg                         mcsr_access_2    ;

reg [0:3]                   master_id_1_s    ;
reg                         BGOsl_rdComp_s   ;
reg [0:15]                  busy_a           ;
reg [0:15]                  busy_d           ;
reg [0:15]                  BGOsl_MBusy_int  ;
reg [0:15]                  busy             ;

reg [0:15]                  BGOsl_MErr_int   ;

reg                         plb_mcsr_rd_en_pulse_d1;
reg							plb_mcsr_wr_en_pulse_d1;

reg                         pa1_full_s       ;
reg [0:2]                   tsiz_asynch_1    ;       // asynch
reg							plb_psb_s_acc_d1;
reg							plb_psb_s_acc_d2;
reg							plb_psb_s_acc_d3;
reg [0:1]                   DAck_cnt         ;

reg                         psb_plb_error_d1;
reg                         psb_plb_error_sticky;
reg                         plb_psb_s_acc_d3_sticky;
reg                         writeburst_error_done;

reg							rburst_err_rdAck1;
reg							rburst_err_rdAck2;
reg							rburst_err_rdAck3;
reg							rburst_err_rdAck4;
reg                         rburst_err_rdAck;

wire                        mcsr_BGOsl_rdDAck;
wire [0:C_PLB_DWIDTH-1]     mcsr_BGOsl_rdDBus;  	
wire                        mcsr_BGOsl_rdComp;  	                       
wire [0:3]                  mcsr_BGOsl_rdWdAddr;	                       
wire                        mcsr_BGOsl_rdBTerm; 	                       
wire                        mcsr_BGOsl_wrDAck;
wire                        mcsr_BGOsl_wrComp;
wire                        mcsr_BGOsl_wrBTerm; 

wire [0:63]                 psb_plb_read_data_trans;
wire [0:2]                  DAck_cnt_plus_addr1;
wire                        psb_BGOsl_rdDAck;  
wire [0:C_PLB_DWIDTH-1]     psb_BGOsl_rdDBus;  
wire                        psb_BGOsl_rdComp;  
wire [0:3]                  psb_BGOsl_rdWdAddr;
wire                        psb_BGOsl_rdBTerm; 
wire                        psb_BGOsl_wrComp;  
wire                        psb_BGOsl_wrDAck;
wire                        psb_BGOsl_wrBTerm; 

reg [0:31]                  plb_psb_address_reg;
reg                         plb_psb_burst_reg;
reg [1:3]                   plb_psb_tsiz_reg;
reg                         plb_psb_rnw_reg;
reg                         accept_psb_reg;

/********************************
* Module Logic                  *
********************************/
// assignments to PLB signals that never get asserted;
assign BGOsl_wait    = 0;

// assign parameter to wire to allow range to go from 0 to 31
assign C_BASEADDR_wire[0:31] = C_BASEADDR;

// Determine if the current access is an allowable size
// Allowable sizes for 64 bit masters are:
//  1. Single beat accesses of 1-8 bytes
//  2. 8-word line transfer (transferred on PSB as burst of 4 DWORDS)
// Allowable sizes for 32-bit masters are:
//  1. Single beat accesses of 1-4 bytes
always @(PLBsl_size or PLBsl_BE or PLBsl_MSize)
    if ( (PLBsl_size[0:3] == 4'b0000) ||                                // Single Beat Access 
         ((PLBsl_size[0:3] == 4'b0010) && (PLBsl_MSize == 2'b01)) )   	// 64-bit master; 8-word line
        allowable_transfer_size <= 1'b1;
	else
	    allowable_transfer_size <= 1'b0;

// Determine if the access is to the USER FPGA MCSRs (and if so, is it to the VUART)
// Note: Accesses to the VUART are allowed to be non-word accesses (software driver uses byte)
// Not supporting PSB Bridge registers or VUART// always @(PLBsl_ABus or PLBsl_PAValid)
// Not supporting PSB Bridge registers or VUART// begin
// Not supporting PSB Bridge registers or VUART//     if ( (PLBsl_PAValid == 1) && 
// Not supporting PSB Bridge registers or VUART//          (PLBsl_ABus[0:PLB_PSB_FPGA_REG_LSB_DECODE] == PLB_PSB_FPGA_REG_BASEADDR[31:(31-PLB_PSB_FPGA_REG_LSB_DECODE)]) )
// Not supporting PSB Bridge registers or VUART// 	// access is to the PLB_PSB FPGA REGISTERS
// Not supporting PSB Bridge registers or VUART// 	begin
// Not supporting PSB Bridge registers or VUART// 	    mcsr_access <= 1;
// Not supporting PSB Bridge registers or VUART// 		if ( (PLBsl_ABus[VUART0_UPPER_BIT_DECODE] == 1) || 
// Not supporting PSB Bridge registers or VUART// 		     (PLBsl_ABus[VUART1_UPPER_BIT_DECODE] == 1) )
// Not supporting PSB Bridge registers or VUART// 		    mcsr_vuart_access <= 1;
// Not supporting PSB Bridge registers or VUART// 		else
// Not supporting PSB Bridge registers or VUART// 		    mcsr_vuart_access <= 0;
// Not supporting PSB Bridge registers or VUART// 	end
// Not supporting PSB Bridge registers or VUART// 	else
// Not supporting PSB Bridge registers or VUART// 	begin
// Not supporting PSB Bridge registers or VUART// 	    mcsr_access       <= 0;
// Not supporting PSB Bridge registers or VUART// 	    mcsr_vuart_access <= 0;
// Not supporting PSB Bridge registers or VUART// 	end
// Not supporting PSB Bridge registers or VUART// end
/* Not supporting PSB Bridge registers or VUART*/always @(PLBsl_ABus or PLBsl_PAValid)
/* Not supporting PSB Bridge registers or VUART*/begin
/* Not supporting PSB Bridge registers or VUART*/    mcsr_access       <= 0;
/* Not supporting PSB Bridge registers or VUART*/    mcsr_vuart_access <= 0;
/* Not supporting PSB Bridge registers or VUART*/end

// Flag accesses to USER FPGA MCSRs that are not single word accesses
always @(mcsr_access or mcsr_vuart_access or PLBsl_MSize or PLBsl_BE)
begin
    if ( (mcsr_access == 1) && (mcsr_vuart_access == 0) && (PLBsl_MSize == 2'b01) )
	// 64-bit PLB Master accessing the USER FPGA MCSRs (but not the VUART
	// which now allows non-32 bit accesses)
	begin
	    if ( (PLBsl_BE[0:7] == 8'b11110000) ||
	         (PLBsl_BE[0:7] == 8'b00001111) )
            non32_mcsr_access <= 0;
		else
		    non32_mcsr_access <= 1;
	end

	else if ( (mcsr_access == 1) && (mcsr_vuart_access == 0) && (PLBsl_MSize == 2'b00) )
	// 32-bit PLB Master accessing the USER FPGA MCSRs (but not the VUART
	// which now allows non-32 bit accesses)
	begin
	    if (PLBsl_BE[0:3] == 4'b1111)
		    non32_mcsr_access <= 0;
		else
		    non32_mcsr_access <= 1;
	end

    else
	    non32_mcsr_access <= 0;
end


// Determine if this slave is going to accept the access
// Several factors come into play here:
//   1. PLBsl_ABus has to be within proper range (512 MB window on PLB bus starting on 2 MB window)
//   2. PSB has to be available (accept_plb determines this)
//   3. Type of transaction: this slave only responds to single beat, or 8-word line transfers
//                           (if access is to mcsr, it must be a single 32-bit access)
always @(PLBsl_ABus or accept_plb or allowable_transfer_size or non32_mcsr_access or C_BASEADDR_wire)
begin
    if ( (PLBsl_ABus[0:PLB_SLAVE_LSB_DECODE] == C_BASEADDR_wire[0:PLB_SLAVE_LSB_DECODE]) &&
		  allowable_transfer_size                               &&
		  !non32_mcsr_access                                    &&
		  accept_plb             
	   )
	begin
        accept_access       <= 1'b1;
	end

	else
	begin
	    accept_access       <= 1'b0;
	end
end

// Create an internal version of PLBsl_masterID with a fixed width of 4
always @(PLBsl_masterID)
begin
    case (C_PLB_MID_WIDTH)
	1:       PLBsl_masterID_int <= {3'b0, PLBsl_masterID};
	2:       PLBsl_masterID_int <= {2'b0, PLBsl_masterID};
	3:       PLBsl_masterID_int <= {1'b0, PLBsl_masterID};
    4:       PLBsl_masterID_int <= PLBsl_masterID;
	default: PLBsl_masterID_int <= PLBsl_masterID;
	endcase
end

// PA1 Address Info
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
    begin
        pa1_full       <= 0;
		rnw_1          <= 0;
        burst_1        <= 0;
        be_1           <= 0;
        addr_1         <= 0;
        master_id_1    <= 0;
        master_64bit_1 <= 0;
		mcsr_access_1  <= 0;
    end

    else
    begin
        if (pa2_full && !pa1_full)
		// The buffered pa access is becoming the current access
		begin
            pa1_full       <= pa2_full; 
			rnw_1          <= rnw_2; 
            burst_1        <= burst_2; 
            be_1           <= be_2; 
            addr_1         <= addr_2; 
            master_id_1    <= master_id_2; 
            master_64bit_1 <= master_64bit_2; 
    		mcsr_access_1  <= mcsr_access_2;
		end

        else if (PLBsl_PAValid && accept_access && !PLBsl_abort && !pa1_full)
        // Accepting a primary access so latch its addr info
        begin
            pa1_full       <= 1;
			rnw_1          <= PLBsl_RNW;
            burst_1        <= PLBsl_size[2];
            be_1           <= (PLBsl_MSize == 2'b01) ? PLBsl_BE : {PLBsl_BE[0:3], 4'b0};
            addr_1         <= PLBsl_ABus;
            master_id_1    <= PLBsl_masterID_int;
            master_64bit_1 <= (PLBsl_MSize == 2'b01) ? 1 : 0;
    		mcsr_access_1  <= mcsr_access; // asynch signal based on PLBsl_* signals
        end

        else if ( (pa1_full && rnw_1 && BGOsl_rdComp) || (pa1_full && !rnw_1 && BGOsl_wrComp) )
		// Current access has completed so clear the 1 holding registers
		begin
            pa1_full       <= 0;
			rnw_1          <= 0;
            burst_1        <= 0;
            be_1           <= 0;
            addr_1         <= 0;
            master_id_1    <= 0;
            master_64bit_1 <= 0;
    		mcsr_access_1  <= 0;
		end

        else
		begin
            pa1_full       <= pa1_full;
			rnw_1          <= rnw_1;
            burst_1        <= burst_1;
            be_1           <= be_1;
            addr_1         <= addr_1;
            master_id_1    <= master_id_1;
            master_64bit_1 <= master_64bit_1;
		    mcsr_access_1  <= mcsr_access_1;
		end
	end
end



// PA2 Address Info
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
    begin
        pa2_full       <= 0;
		rnw_2          <= 0;
        burst_2        <= 0;
        be_2           <= 0;
        addr_2         <= 0;
        master_id_2    <= 0;
        master_64bit_2 <= 0;
		mcsr_access_2  <= 0;
    end

    else
    begin
        if (pa2_full && !pa1_full)
        // The second primary access is becoming the current access
        begin
            pa2_full       <= 0;
		    rnw_2          <= 0;
            burst_2        <= 0;
            be_2           <= 0;
            addr_2         <= 0;
            master_id_2    <= 0;
            master_64bit_2 <= 0;
		    mcsr_access_2  <= 0;
        end

        else if (PLBsl_PAValid && accept_access && !PLBsl_abort && pa1_full && !pa2_full)
        // Accepting second primary access so latch its addr info
        begin
            pa2_full       <= 1;
			rnw_2          <= PLBsl_RNW;
            burst_2        <= PLBsl_size[2];
            be_2           <= (PLBsl_MSize == 2'b01) ? PLBsl_BE : {PLBsl_BE[0:3], 4'b0};
            addr_2         <= PLBsl_ABus;
            master_id_2    <= PLBsl_masterID_int;
            master_64bit_2 <= (PLBsl_MSize == 2'b01) ? 1 : 0;
		    mcsr_access_2  <= mcsr_access;
        end

        else
        // Hold data
        begin
            pa2_full       <= pa2_full;
		    rnw_2          <= rnw_2;
            burst_2        <= burst_2;
            be_2           <= be_2;
            addr_2         <= addr_2;
            master_id_2    <= master_id_2;
            master_64bit_2 <= master_64bit_2;
		    mcsr_access_2  <= mcsr_access_2;
        end

    end
end

// BGOsl_addrAck and BGOsl_SSize
always @(PLBsl_PAValid or PLBsl_abort or accept_access or pa2_full)
begin
    if (PLBsl_PAValid && !PLBsl_abort && accept_access && !pa2_full)
	// Acknowledge any primary addr request where pa2_full is not asserted
	// unless the master aborts or the access is not accepted (wrong addr,
	// wrong transaction size or PSB busy)
	begin
	    BGOsl_addrAck       <= 1;
   		BGOsl_SSize	        <= SLAVE_SIZE;
	end
    else
	begin
	    BGOsl_addrAck       <= 0;
   		BGOsl_SSize	        <= 0;
	end
end

always @(posedge clk or posedge reset)
begin
    if (reset == 1)
    begin
	    accept_psb_reg <= 1;
    end
	else
	begin
	    accept_psb_reg <= accept_psb;
	end
end

always @(reset or PLBsl_PAValid or PLBsl_abort or accept_access or pa1_full or pa2_full or BGOsl_MBusy_int or accept_psb_reg)
begin
    if (reset)
	    accept_psb <= 1;
    else if ( (PLBsl_PAValid && !PLBsl_abort && accept_access && !pa2_full) ||
              (|BGOsl_MBusy_int == 1) )
	// Either a PLB access is starting or a PLB access is in progress
	    accept_psb <= 0;
	else if (!pa1_full && !pa2_full)
	// Bridge Out is not performing any PLB slave accesses
	    accept_psb <= 1;
	else
	// Leave it alone
	    accept_psb <= accept_psb_reg;
end

// BGOsl_rearbitrate
always @(PLBsl_PAValid or PLBsl_ABus or allowable_transfer_size or PLBsl_abort or accept_plb or pa2_full or C_BASEADDR_wire)
begin
    if (PLBsl_PAValid && 
        (PLBsl_ABus[0:PLB_SLAVE_LSB_DECODE] == C_BASEADDR_wire[0:PLB_SLAVE_LSB_DECODE]) &&
        allowable_transfer_size &&
        !PLBsl_abort && 
        (!accept_plb || pa2_full)
	   )
        BGOsl_rearbitrate <= 1'b1;
	else
	    BGOsl_rearbitrate <= 1'b0;
end

// BGOsl_MBusy
  // busy assertion
always @(PLBsl_PAValid or PLBsl_abort or accept_access or pa2_full or PLBsl_masterID_int)
begin
    if (PLBsl_PAValid && !PLBsl_abort && accept_access && !pa2_full)
	begin
	    case (PLBsl_masterID_int)
        4'h0:    busy_a <= 16'b1000000000000000;
        4'h1:    busy_a <= 16'b0100000000000000;
        4'h2:    busy_a <= 16'b0010000000000000;
        4'h3:    busy_a <= 16'b0001000000000000;
        4'h4:    busy_a <= 16'b0000100000000000;
        4'h5:    busy_a <= 16'b0000010000000000;
        4'h6:    busy_a <= 16'b0000001000000000;
        4'h7:    busy_a <= 16'b0000000100000000;
        4'h8:    busy_a <= 16'b0000000010000000;
        4'h9:    busy_a <= 16'b0000000001000000;
        4'ha:    busy_a <= 16'b0000000000100000;
        4'hb:    busy_a <= 16'b0000000000010000;
        4'hc:    busy_a <= 16'b0000000000001000;
        4'hd:    busy_a <= 16'b0000000000000100;
        4'he:    busy_a <= 16'b0000000000000010;
        4'hf:    busy_a <= 16'b0000000000000001;
		default: busy_a <= 16'b0;
		endcase
	end

    else
	begin
		busy_a <= 16'b0;
	end
end

  // resample some signals used for the busy deassertion
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
    begin
	    master_id_1_s <= 0;
		BGOsl_rdComp_s <= 0;
	end
	else
	begin
	    master_id_1_s <= master_id_1;
		BGOsl_rdComp_s <= BGOsl_rdComp;
	end
end

  // busy deassertion
always @(BGOsl_rdComp or pa2_full or BGOsl_wrComp or master_id_1 or master_id_2)
begin
    if ( (BGOsl_rdComp == 1) && 
         !( (pa2_full == 1) && (master_id_1 == master_id_2) )
	   )
	begin
	    case (master_id_1)
        4'h0:    busy_d <= 16'b0111111111111111;
        4'h1:    busy_d <= 16'b1011111111111111;
        4'h2:    busy_d <= 16'b1101111111111111;
        4'h3:    busy_d <= 16'b1110111111111111;
        4'h4:    busy_d <= 16'b1111011111111111;
        4'h5:    busy_d <= 16'b1111101111111111;
        4'h6:    busy_d <= 16'b1111110111111111;
        4'h7:    busy_d <= 16'b1111111011111111;
        4'h8:    busy_d <= 16'b1111111101111111;
        4'h9:    busy_d <= 16'b1111111110111111;
        4'ha:    busy_d <= 16'b1111111111011111;
        4'hb:    busy_d <= 16'b1111111111101111;
        4'hc:    busy_d <= 16'b1111111111110111;
        4'hd:    busy_d <= 16'b1111111111111011;
        4'he:    busy_d <= 16'b1111111111111101;
        4'hf:    busy_d <= 16'b1111111111111110;
		default: busy_d <= 16'b1111111111111111;
		endcase
	end
	else if ( (BGOsl_wrComp) && 
         !( (pa2_full == 1) && (master_id_1 == master_id_2) )
	   )
	begin
	    case (master_id_1)
        4'h0:    busy_d <= 16'b0111111111111111;
        4'h1:    busy_d <= 16'b1011111111111111;
        4'h2:    busy_d <= 16'b1101111111111111;
        4'h3:    busy_d <= 16'b1110111111111111;
        4'h4:    busy_d <= 16'b1111011111111111;
        4'h5:    busy_d <= 16'b1111101111111111;
        4'h6:    busy_d <= 16'b1111110111111111;
        4'h7:    busy_d <= 16'b1111111011111111;
        4'h8:    busy_d <= 16'b1111111101111111;
        4'h9:    busy_d <= 16'b1111111110111111;
        4'ha:    busy_d <= 16'b1111111111011111;
        4'hb:    busy_d <= 16'b1111111111101111;
        4'hc:    busy_d <= 16'b1111111111110111;
        4'hd:    busy_d <= 16'b1111111111111011;
        4'he:    busy_d <= 16'b1111111111111101;
        4'hf:    busy_d <= 16'b1111111111111110;
		default: busy_d <= 16'b1111111111111111;
		endcase
	end

    else
	begin
		busy_d <= 16'b1111111111111111;
	end
end
		
  // One hot encoding for busy signals
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
        busy <= 0;
	else
	    busy <= (busy & busy_d) | busy_a;
end

  // One hot encoding for 16-bit internal busy signal
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
    begin
        BGOsl_MBusy_int <= 0;
	end
	else
	begin
	    BGOsl_MBusy_int <= (busy & busy_d) | busy_a;
	end
end

always @(posedge clk or posedge reset)
begin
    if (reset == 1)
        psb_plb_error_d1 <= 0;
	else
        psb_plb_error_d1 <= psb_plb_error;
end

// BGOsl_MErr
always @(plb_psb_burst or plb_psb_rnw or psb_plb_error_d1 or 
         psb_plb_error or master_id_1)
begin
    if (plb_psb_burst && plb_psb_rnw)
    begin
    // For read bursts, the PLB Slave asserts the rdDAck signal
    // delayed 1 cc when an error occurs so we should delay the
    // error signal by 1cc as well so that it is asserted the
    // same time as rdDAck
	    if (psb_plb_error_d1)
	    begin
	        case (master_id_1)
            4'h0:    BGOsl_MErr_int <= 16'b1000000000000000;
            4'h1:    BGOsl_MErr_int <= 16'b0100000000000000;
            4'h2:    BGOsl_MErr_int <= 16'b0010000000000000;
            4'h3:    BGOsl_MErr_int <= 16'b0001000000000000;
            4'h4:    BGOsl_MErr_int <= 16'b0000100000000000;
            4'h5:    BGOsl_MErr_int <= 16'b0000010000000000;
            4'h6:    BGOsl_MErr_int <= 16'b0000001000000000;
            4'h7:    BGOsl_MErr_int <= 16'b0000000100000000;
            4'h8:    BGOsl_MErr_int <= 16'b0000000010000000;
            4'h9:    BGOsl_MErr_int <= 16'b0000000001000000;
            4'ha:    BGOsl_MErr_int <= 16'b0000000000100000;
            4'hb:    BGOsl_MErr_int <= 16'b0000000000010000;
            4'hc:    BGOsl_MErr_int <= 16'b0000000000001000;
            4'hd:    BGOsl_MErr_int <= 16'b0000000000000100;
            4'he:    BGOsl_MErr_int <= 16'b0000000000000010;
            4'hf:    BGOsl_MErr_int <= 16'b0000000000000001;
		    default: BGOsl_MErr_int <= 16'b0;
		    endcase
	    end
		else
		begin
    	    BGOsl_MErr_int <= 0;
		end
	end

    else if (psb_plb_error)
	begin
	    case (master_id_1)
        4'h0:    BGOsl_MErr_int <= 16'b1000000000000000;
        4'h1:    BGOsl_MErr_int <= 16'b0100000000000000;
        4'h2:    BGOsl_MErr_int <= 16'b0010000000000000;
        4'h3:    BGOsl_MErr_int <= 16'b0001000000000000;
        4'h4:    BGOsl_MErr_int <= 16'b0000100000000000;
        4'h5:    BGOsl_MErr_int <= 16'b0000010000000000;
        4'h6:    BGOsl_MErr_int <= 16'b0000001000000000;
        4'h7:    BGOsl_MErr_int <= 16'b0000000100000000;
        4'h8:    BGOsl_MErr_int <= 16'b0000000010000000;
        4'h9:    BGOsl_MErr_int <= 16'b0000000001000000;
        4'ha:    BGOsl_MErr_int <= 16'b0000000000100000;
        4'hb:    BGOsl_MErr_int <= 16'b0000000000010000;
        4'hc:    BGOsl_MErr_int <= 16'b0000000000001000;
        4'hd:    BGOsl_MErr_int <= 16'b0000000000000100;
        4'he:    BGOsl_MErr_int <= 16'b0000000000000010;
        4'hf:    BGOsl_MErr_int <= 16'b0000000000000001;
		default: BGOsl_MErr_int <= 16'b0;
		endcase
	end
	else
	begin
	    BGOsl_MErr_int <= 0;
	end
end


// Indicate the positive edge of pa1_full
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	    pa1_full_s <= 0;
	else
	    pa1_full_s <= pa1_full;
end

// determine value of plb_psb_tsiz
always @(be_1 or burst_1)
begin
    if (burst_1)
	    tsiz_asynch_1 <= 3'b010;
	else
	begin
        case (be_1)
		8'b11111111: tsiz_asynch_1 <= 3'b000;

		8'b11111110: tsiz_asynch_1 <= 3'b111;
		8'b01111111: tsiz_asynch_1 <= 3'b111;

        8'b11111100: tsiz_asynch_1 <= 3'b110;
		8'b01111110: tsiz_asynch_1 <= 3'b110;
		8'b00111111: tsiz_asynch_1 <= 3'b110;

        8'b11111000: tsiz_asynch_1 <= 3'b101;
		8'b01111100: tsiz_asynch_1 <= 3'b101;
		8'b00111110: tsiz_asynch_1 <= 3'b101;
		8'b00011111: tsiz_asynch_1 <= 3'b101;

        8'b11110000: tsiz_asynch_1 <= 3'b100;
		8'b01111000: tsiz_asynch_1 <= 3'b100;
		8'b00111100: tsiz_asynch_1 <= 3'b100;
		8'b00011110: tsiz_asynch_1 <= 3'b100;
		8'b00001111: tsiz_asynch_1 <= 3'b100;

        8'b11100000: tsiz_asynch_1 <= 3'b011;
		8'b01110000: tsiz_asynch_1 <= 3'b011;
		8'b00111000: tsiz_asynch_1 <= 3'b011;
		8'b00011100: tsiz_asynch_1 <= 3'b011;
		8'b00001110: tsiz_asynch_1 <= 3'b011;
		8'b00000111: tsiz_asynch_1 <= 3'b011;

        8'b11000000: tsiz_asynch_1 <= 3'b010;
		8'b01100000: tsiz_asynch_1 <= 3'b010;
		8'b00110000: tsiz_asynch_1 <= 3'b010;
		8'b00011000: tsiz_asynch_1 <= 3'b010;
		8'b00001100: tsiz_asynch_1 <= 3'b010;
		8'b00000110: tsiz_asynch_1 <= 3'b010;
		8'b00000011: tsiz_asynch_1 <= 3'b010;

        8'b10000000: tsiz_asynch_1 <= 3'b001;
		8'b01000000: tsiz_asynch_1 <= 3'b001;
        8'b00100000: tsiz_asynch_1 <= 3'b001;
        8'b00010000: tsiz_asynch_1 <= 3'b001;
        8'b00001000: tsiz_asynch_1 <= 3'b001;
        8'b00000100: tsiz_asynch_1 <= 3'b001;
        8'b00000010: tsiz_asynch_1 <= 3'b001;
		8'b00000001: tsiz_asynch_1 <= 3'b001;

        default:	 tsiz_asynch_1 <= 3'b000;
	    endcase
	end
end

// Register the plb_mcsr_rd_en_pulse to be used for PLB read acknowledge
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
        plb_mcsr_rd_en_pulse_d1 <= 0;
        plb_mcsr_wr_en_pulse_d1 <= 0;
	end

	else
	begin
        plb_mcsr_rd_en_pulse_d1 <= plb_mcsr_rd_en_pulse;
        plb_mcsr_wr_en_pulse_d1 <= plb_mcsr_wr_en_pulse;
	end
end

//********************* PLB - MCSR Interface *********************//
// PLB to MCSR signals 
assign plb_mcsr_wr_en_pulse = (pa1_full & !pa1_full_s) & mcsr_access_1 & !rnw_1;
assign plb_mcsr_rd_en_pulse = (pa1_full & !pa1_full_s) & mcsr_access_1 & rnw_1;
assign plb_mcsr_addr        = addr_1[(PLB_PSB_FPGA_REG_LSB_DECODE+1):31];
assign plb_mcsr_write_data  = (addr_1[29:31] == 3'b000) ? 
                                   PLBsl_wrDBus[0:31] : PLBsl_wrDBus[32:63];

// MCSR-to-PLB Read Data Bus Signals (only asserted during MCSR accesses)
assign mcsr_BGOsl_rdDAck   = plb_mcsr_rd_en_pulse_d1;
assign mcsr_BGOsl_rdDBus   = plb_mcsr_rd_en_pulse_d1 ? mcsr_plb_read_data : 64'b0;
assign mcsr_BGOsl_rdComp   = plb_mcsr_rd_en_pulse_d1;
assign mcsr_BGOsl_rdWdAddr = 4'b0; // Line Transfers do not take place to MCSR
assign mcsr_BGOsl_rdBTerm  = 0;    // Bursts do not take place to MCSR

// MCSR-to-PLB Write Data Bus Signals (only asserted during MCSR accesses)
assign mcsr_BGOsl_wrDAck  = plb_mcsr_wr_en_pulse_d1;
assign mcsr_BGOsl_wrComp  = plb_mcsr_wr_en_pulse_d1;
assign mcsr_BGOsl_wrBTerm = 0;     // Bursts do not take place to MCSR

//********************* PLB - PSB Interface *********************//
// PLB to PSB signals
assign plb_psb_start_access = (pa1_full & !pa1_full_s) & !mcsr_access_1;


always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
		plb_psb_address_reg	<= 0;
		plb_psb_burst_reg  	<= 0;
		plb_psb_tsiz_reg   	<= 0;
		plb_psb_rnw_reg    	<= 0;
    end
	else
	begin
		plb_psb_address_reg	<= plb_psb_address;
		plb_psb_burst_reg  	<= plb_psb_burst;  
		plb_psb_tsiz_reg   	<= plb_psb_tsiz;   
		plb_psb_rnw_reg    	<= plb_psb_rnw;    
	end
end

//assign plb_psb_start_access = (pa1_full & !pa1_full_s) & !mcsr_access_1;
assign plb_psb_address      = plb_psb_start_access ? addr_1        : plb_psb_address_reg;
assign plb_psb_burst        = plb_psb_start_access ? burst_1       : plb_psb_burst_reg;
assign plb_psb_tsiz         = plb_psb_start_access ? tsiz_asynch_1 : plb_psb_tsiz_reg;
assign plb_psb_rnw          = plb_psb_start_access ? rnw_1         : plb_psb_rnw_reg;

// Register the write data going from PLB to PSB
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    plb_psb_write_data1 <= 0;
		plb_psb_write_data2 <= 0;
		plb_psb_write_data3 <= 0;
		plb_psb_write_data4 <= 0;
	end
	else
	    if (master_64bit_1)
		// 64-bit PLB master
	    begin
	        plb_psb_write_data1 <= (plb_psb_start_access    && !rnw_1) ? PLBsl_wrDBus : plb_psb_write_data1;
		    plb_psb_write_data2 <= (plb_psb_s_acc_d1 && !rnw_1) ? PLBsl_wrDBus : plb_psb_write_data2;
		    plb_psb_write_data3 <= (plb_psb_s_acc_d2 && !rnw_1) ? PLBsl_wrDBus : plb_psb_write_data3;
		    plb_psb_write_data4 <= (plb_psb_s_acc_d3 && !rnw_1) ? PLBsl_wrDBus : plb_psb_write_data4;
	    end
		else
		// 32-bit PLB master so only use PLBsl_wrDBus[0:31]
		begin
	        plb_psb_write_data1 <= (plb_psb_start_access    && !rnw_1) ? {PLBsl_wrDBus[0:31], PLBsl_wrDBus[0:31]} : plb_psb_write_data1;
		    plb_psb_write_data2 <= (plb_psb_s_acc_d1 && !rnw_1) ? {PLBsl_wrDBus[0:31], PLBsl_wrDBus[0:31]} : plb_psb_write_data2;
		    plb_psb_write_data3 <= (plb_psb_s_acc_d2 && !rnw_1) ? {PLBsl_wrDBus[0:31], PLBsl_wrDBus[0:31]} : plb_psb_write_data3;
		    plb_psb_write_data4 <= (plb_psb_s_acc_d3 && !rnw_1) ? {PLBsl_wrDBus[0:31], PLBsl_wrDBus[0:31]} : plb_psb_write_data4;
		end
end


// Generate signal to be used for write acks during bursts
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    plb_psb_s_acc_d1 <= 0;
		plb_psb_s_acc_d2 <= 0;
		plb_psb_s_acc_d3 <= 0;
	end
	else
	begin
	    plb_psb_s_acc_d1 <= plb_psb_start_access;
		plb_psb_s_acc_d2 <= plb_psb_s_acc_d1;
		plb_psb_s_acc_d3 <= plb_psb_s_acc_d2;
	end
end

// Keep track of which PLB beat is taking place during bursts
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	    DAck_cnt <= 0;
	else
	    if (!burst_1)
	        DAck_cnt <= 0;
		else if (BGOsl_rdDAck)
		    DAck_cnt <= DAck_cnt + 1;
		else
		    DAck_cnt <= DAck_cnt;
end

// Keep track of whether an error occurred during access (for errors during write bursts)
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
        psb_plb_error_sticky    <= 0;
        plb_psb_s_acc_d3_sticky <= 0;
	end

	else
	begin
        if (psb_BGOsl_wrComp | psb_BGOsl_rdComp)
	        psb_plb_error_sticky <= 0;
	    else if (psb_plb_error)
       	    psb_plb_error_sticky <= 1;
       	else
       		psb_plb_error_sticky <= psb_plb_error_sticky;

        if (plb_psb_start_access)
	        plb_psb_s_acc_d3_sticky <= 0;
        else if (plb_psb_s_acc_d3)
	        plb_psb_s_acc_d3_sticky <= 1;
	    else
	     	plb_psb_s_acc_d3_sticky <= plb_psb_s_acc_d3_sticky;
	end
end

always @(plb_psb_s_acc_d3_sticky or psb_plb_error or psb_plb_error_sticky or plb_psb_s_acc_d3)
begin
    writeburst_error_done <= (plb_psb_s_acc_d3_sticky & psb_plb_error) | // error occurred later on
	                         ((psb_plb_error_sticky | psb_plb_error) & plb_psb_s_acc_d3);  // error occurred early on
end

// Determine how many psb_BGOsl_rdDAcks need to be issued if a psb_plb_error occured during a burst
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    rburst_err_rdAck1 <= 0;
		rburst_err_rdAck2 <= 0;
		rburst_err_rdAck3 <= 0;
		rburst_err_rdAck4 <= 0;
	end
	else
	begin
	    if (psb_plb_error & rnw_1)
		begin
		    case (DAck_cnt)
			0:
			// Need to assert psb_GBOsl_rdAck 4 times
			begin
	            rburst_err_rdAck1 <= 1;
		        rburst_err_rdAck2 <= 1;
		        rburst_err_rdAck3 <= 1;
		        rburst_err_rdAck4 <= 1;
			end
			 
			1:
			// Need to assert psb_GBOsl_rdAck 3 times
			begin
	            rburst_err_rdAck1 <= 0;
		        rburst_err_rdAck2 <= 1;
		        rburst_err_rdAck3 <= 1;
		        rburst_err_rdAck4 <= 1;
			end

			2:
			// Need to assert psb_GBOsl_rdAck 2 times
			begin
	            rburst_err_rdAck1 <= 0;
		        rburst_err_rdAck2 <= 0;
		        rburst_err_rdAck3 <= 1;
		        rburst_err_rdAck4 <= 1;
			end

			3:
			// Need to assert psb_GBOsl_rdAck 1 time
			begin
	            rburst_err_rdAck1 <= 0;
		        rburst_err_rdAck2 <= 0;
		        rburst_err_rdAck3 <= 0;
		        rburst_err_rdAck4 <= 1;
			end

			default:
			begin
	            rburst_err_rdAck1 <= 0;
		        rburst_err_rdAck2 <= 0;
		        rburst_err_rdAck3 <= 0;
		        rburst_err_rdAck4 <= 0;
			end
			endcase
		end

		else if (BGOsl_rdComp)
        begin
	            rburst_err_rdAck1 <= 0;
		        rburst_err_rdAck2 <= 0;
		        rburst_err_rdAck3 <= 0;
		        rburst_err_rdAck4 <= 0;
		end

		else
		begin
            rburst_err_rdAck1 <= 0;
	        rburst_err_rdAck2 <= rburst_err_rdAck1;
	        rburst_err_rdAck3 <= rburst_err_rdAck2;
	        rburst_err_rdAck4 <= rburst_err_rdAck3;
		end
	end
end

always @(rburst_err_rdAck1 or rburst_err_rdAck2 or rburst_err_rdAck3 or rburst_err_rdAck4)
begin
    rburst_err_rdAck <= rburst_err_rdAck1 | rburst_err_rdAck2 | rburst_err_rdAck3 | rburst_err_rdAck4;
end

// Properly allign read data when access is from a 32-bit PLB Master
assign psb_plb_read_data_trans = addr_1[29] ? ({psb_plb_read_data[32:63], 32'b0}) : ({psb_plb_read_data[0:31], 32'b0});
assign DAck_cnt_plus_addr1 = DAck_cnt[0:1] + addr_1[27:28];

// PSB-to-PLB Read Data Bus Signals (only asserted during PSB accesses)
assign psb_BGOsl_rdComp   = !rnw_1 ? 0 : 
                               (burst_1 ? DAck_cnt == 2'b11 & (psb_plb_read_data_val | rburst_err_rdAck) : 
                                  psb_plb_read_data_val | psb_plb_error);
assign psb_BGOsl_rdDAck   = !rnw_1 ? 0 :
                               (burst_1 ? psb_plb_read_data_val | rburst_err_rdAck :
                                  psb_plb_read_data_val | psb_plb_error);
assign psb_BGOsl_rdDBus   = psb_plb_read_data_val ? (master_64bit_1 ? psb_plb_read_data : psb_plb_read_data_trans) : 64'b0;
assign psb_BGOsl_rdWdAddr = (burst_1 & psb_BGOsl_rdDAck) ? {1'b0, DAck_cnt_plus_addr1[1:2], 1'b0} : 4'b0;
assign psb_BGOsl_rdBTerm  = 0;

// PSB-to-PLB Write Data Bus Signals (only asserted during PSB accesses)
assign psb_BGOsl_wrComp  = rnw_1 ? 0 :
                             (burst_1 ? psb_plb_access_done | writeburst_error_done  : 
                                 psb_plb_access_done | psb_plb_error);
assign psb_BGOsl_wrDAck  = rnw_1 ? 0 : 
                             (burst_1 ? plb_psb_start_access | plb_psb_s_acc_d1 | plb_psb_s_acc_d2 | psb_plb_access_done | writeburst_error_done :
                                 psb_plb_access_done | psb_plb_error);
assign psb_BGOsl_wrBTerm = 0;


//********************* PLB - PSB/MCSR Interface *********************//
// Combined signals from MCSR and PSB Interfaces ('or' of the two interfaces)
assign BGOsl_rdDAck   = mcsr_BGOsl_rdDAck | psb_BGOsl_rdDAck;
assign BGOsl_rdDBus   = mcsr_BGOsl_rdDBus | psb_BGOsl_rdDBus;
assign BGOsl_rdComp   = mcsr_BGOsl_rdComp | psb_BGOsl_rdComp;
assign BGOsl_rdWdAddr = mcsr_BGOsl_rdWdAddr | psb_BGOsl_rdWdAddr;
assign BGOsl_rdBTerm  = mcsr_BGOsl_rdBTerm | psb_BGOsl_rdBTerm;

// Combined signals from MCSR and PSB Interfaces ('or' of the two interfaces)
assign BGOsl_wrComp  = mcsr_BGOsl_wrComp  | psb_BGOsl_wrComp;
assign BGOsl_wrDAck  = mcsr_BGOsl_wrDAck  | psb_BGOsl_wrDAck;
assign BGOsl_wrBTerm = mcsr_BGOsl_wrBTerm | psb_BGOsl_wrBTerm;

// Extra PLB Signals
assign BGOsl_MBusy = BGOsl_MBusy_int[0:C_PLB_NUM_MASTERS-1];
assign BGOsl_MErr  = BGOsl_MErr_int[0:C_PLB_NUM_MASTERS-1];

assign plb2psb_plbside_debug_bus[0]  = BGOsl_wrDAck;
assign plb2psb_plbside_debug_bus[1]  = accept_psb;
assign plb2psb_plbside_debug_bus[2]  = accept_plb;
assign plb2psb_plbside_debug_bus[3]  = plb_psb_start_access;
assign plb2psb_plbside_debug_bus[4]  = psb_plb_access_done;

endmodule
