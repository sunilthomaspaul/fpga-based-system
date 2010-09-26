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
*   The PSB control logic for the PSB2PLB Bridge.
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/psb2plb_psbside.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: psb2plb_psbside.v,v $
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.8  2005/07/25 18:37:25  kuehner
* Fixed psb_plb_write_data mirroring (problem existed when bursting because
* tsiz is 'b010 during burst.
*
* Revision 1.7  2005/07/19 17:36:48  kuehner
* Bridge now passes 0 - 2FFFFFFF through to PLB bus (for flash/cpld accesses).
* Mirroring data bus when writing to PLB bus space now.
*
* Revision 1.6  2005/06/27 20:14:27  kuehner
* Changed PS2 address pipelining logic so that the second address phase
* is not acknowledged until the first data phase is complete (trying to avoid
* the PS2 incorrectly dealing with dbb_n).
*
* Revision 1.5  2005/06/27 12:24:34  kuehner
* More changes related to PS2 pipelining more than 1 address phase.
*
* Revision 1.4  2005/06/24 20:39:51  kuehner
* Added in logic to deal with PS2 pipelining more than 1 address stage
* within a data phase. Added ufpga_ahit_outstanding to PSB Address FSM.
*
* Revision 1.3  2005/06/21 17:36:31  kuehner
* Added in chipscope debug bus.
*
* Revision 1.2  2005/05/03 18:47:24  kuehner
* Updated bridge to incorporate all the changes that were made
* during HW05-019 lab debugging.
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

This module provides control logic for the PSB side of the PSB2PLB bridge.
************************************************************************/

module psb2plb_psbside (
                      // Inputs
					   // System
						 clk			  ,
						 reset			  ,

					   // PSB Slave
						 PSBsl_a		  ,	 // already registered
						 PSBsl_d_i		  ,	 // already registered
						 PSBsl_dbb_n      ,  // already registered
						 PSBsl_tbst_n	  ,	 // already registered
						 PSBsl_tsiz		  ,	 // already registered
						 PSBsl_ts_n		  ,	 // already registered
						 PSBsl_tt		  ,	 // already registered

                        // MCSR
                         mcsr_psb_read_data,
                         
                        // PLB
                         plb_psb_read_data    ,
						 plb_psb_read_data_val,
						 plb_psb_error        ,
						 plb_psb_access_done  ,

                       // Misc control
					     accept_psb       ,
						 dont_aack_ps2    ,

                      // Outputs
						 PSBsl_aack_n_o   ,
						 PSBsl_aack_n_en  ,
						 PSBsl_artry_n_o  ,
						 PSBsl_artry_n_en ,
						 PSBsl_ta_n_o	  ,
						 PSBsl_ta_n_en	  ,
						 PSBsl_tea_n_o 	  ,
						 PSBsl_tea_n_en	  ,
						 PSBsl_d_o		  ,
						 PSBsl_d_en		  ,

						// MCSR
						 psb_mcsr_rd_en_pulse ,
						 psb_mcsr_wr_en_pulse ,
						 psb_mcsr_addr        ,
						 psb_mcsr_write_data  ,

                        // PLB2PSB Bridge     
                         accept_plb           ,

                        // PLB
						 psb_plb_start_access  ,
						 psb_plb_address       ,
						 psb_plb_burst         ,
						 psb_plb_tsiz          ,
						 psb_plb_rnw           ,
						 psb_plb_write_data    ,
						 psb_plb_wdata1_val	   ,
						 psb_plb_wdata2_val	   ,
						 psb_plb_wdata3_val	   ,
						 psb_plb_wdata4_val		   ,
						 psb2plb_psbside_debug
);


/********************
* Module Parameters *
********************/
// Address Decoding
parameter PLB_PSB_FPGA_REG_BASEADDR   = 32'h3000_2000;  // 0x30000000 - 0x30003FFF
parameter PLB_PSB_FPGA_REG_LSB_DECODE = 18;

parameter PSB2PLB_MCSR_VUART0_BITS_DECODE = 19;
parameter PSB2PLB_MCSR_VUART1_BITS_DECODE = 18;

parameter PLB_MASTER_BASEADDR1   = 32'h0000_0000; // 0x00000000 - 0x1FFFFFFF
parameter PLB_MASTER_LSB_DECODE1 = 2;

parameter PLB_MASTER_BASEADDR2   = 32'h2000_0000; // 0x20000000 - 0x2FFFFFFF
parameter PLB_MASTER_LSB_DECODE2 = 3;

// 1 = this core will decode for vuart accesses
// 0 = this core won't decode for vuart accesses
parameter VUART_PRESENT = 0;


// PSB Address FSM
parameter  PSBA_IDLE            = 8'b0000_0001;
parameter  PSBA_WAIT_BEFORE_AACK =8'b0000_0010;
parameter  PSBA_RETRY           = 8'b0000_0100;
parameter  PSBA_ACCEPT          = 8'b0000_1000;
parameter  PSBA_DIP_IDLE        = 8'b0001_0000;
parameter  PSBA_DIP_RETRY       = 8'b0010_0000;
parameter  PSBA_DIP_ACCEPT      = 8'b0100_0000;
parameter  PSBA_DIP_ACCEPT_IDLE = 8'b1000_0000;

// PSB Databus FSM
parameter  PSBD_IDLE            = 3'b001;
parameter  PSBD_AHIT			= 3'b010;
parameter  PSBD_DATA_PHASE		= 3'b100;

// PSB Read Data FSM
parameter  PSBR_IDLE              = 7'b000_0001;
parameter  PSBR_WAIT_FOR_RD1      = 7'b000_0010;
parameter  PSBR_WAIT_FOR_RD2      = 7'b000_0100;
parameter  PSBR_WAIT_FOR_RD3      = 7'b000_1000;
parameter  PSBR_WAIT_FOR_RD4      = 7'b001_0000;
parameter  PSBR_DEASSERT_TA_TEA   = 7'b010_0000;
parameter  PSBR_WAIT_FOR_DBB_HIGH = 7'b100_0000;

/*************
* Module I/O *
*************/
// Inputs
 // System
input                     clk			   ;
input                     reset			   ;

 // PSB Slave
input [0:31]              PSBsl_a		   ;	 
input [0:63]              PSBsl_d_i		   ;
input                     PSBsl_dbb_n      ;
input                     PSBsl_tbst_n	   ;
input [1:3]               PSBsl_tsiz	   ; // Note: tsiz[0] is unused by FPGA
input                     PSBsl_ts_n	   ;
input [0:4]               PSBsl_tt		   ;

 // Misc control
input                     accept_psb       ;
input                     dont_aack_ps2    ;

 // MCSR
input [0:63]              mcsr_psb_read_data;

 // PLB Side
input [0:63]              plb_psb_read_data    ;
input 					  plb_psb_read_data_val;
input                     plb_psb_error        ;
input                     plb_psb_access_done  ;

// Outputs
 // PSB Slave
output reg                PSBsl_aack_n_o   ;	// pulled high on board
output reg                PSBsl_aack_n_en  ;	//
output reg                PSBsl_artry_n_o  ;	// pulled high on board
output reg                PSBsl_artry_n_en ;	// 
output wire				  PSBsl_ta_n_o	   ;
output wire				  PSBsl_ta_n_en	   ;
output wire               PSBsl_tea_n_o    ;
output wire               PSBsl_tea_n_en   ;
output wire [0:63]        PSBsl_d_o	       ;
output wire               PSBsl_d_en	   ;

 // MCSR
output wire	[(PLB_PSB_FPGA_REG_LSB_DECODE+1):31]  psb_mcsr_addr       ;
output wire	[0:31]		                          psb_mcsr_write_data ;
output reg				                          psb_mcsr_rd_en_pulse;
output reg				                          psb_mcsr_wr_en_pulse;

// PLB2PSB Bridge     
output reg                accept_plb          ;

 // PLB	Side
output wire               psb_plb_start_access  ;
output wire [0:31]        psb_plb_address       ;
output wire               psb_plb_burst         ;
output wire [1:3]         psb_plb_tsiz          ;
output wire               psb_plb_rnw           ;
output reg [0:63]         psb_plb_write_data    ;
output wire               psb_plb_wdata1_val    ;
output reg                psb_plb_wdata2_val    ;
output reg                psb_plb_wdata3_val    ;
output reg                psb_plb_wdata4_val    ;

output wire [99:0]        psb2plb_psbside_debug ;
/*******************************
* Module Reg/Wire Declarations *
*******************************/
// Address Phase FSM
reg [7:0] psba_state;
reg       deassert_aack_sig;
reg       deassert_artry_sig;
reg       plb_nmcsr; // 1 = plb access; 0 = mcsr access
reg       mcsr_vuart; // 1 = vuart access
wire      data_phase_done;
wire	  mcsr_ahit ;
wire      mcsr_vuart_ahit;
wire	  plb_ahit 	;
wire      ufpga_ahit;
wire      ufpga_aonly_hit; // helps determine need for pulsing start_plb_access
reg       ufpga_ahit_outstanding;
reg [7:0] PSBsl_current_debug_cnt;
reg [7:0] PSBsl_newest_debug_cnt;

// Address Phase Info
reg [0:31] PSBsl_newest_a	   ;
reg		   PSBsl_newest_tbst_n ;
reg	[1:3]  PSBsl_newest_tsiz   ;
reg        PSBsl_newest_tt_rnw ; // PSBsl_tt[1] (0 = write    ; 1 = read)

reg [0:31] PSBsl_current_a	   ;
reg		   PSBsl_current_tbst_n;
reg	[1:3]  PSBsl_current_tsiz  ;
reg	       PSBsl_current_tt_rnw;

// Data Phase Info
//reg [2:0]  psbd_state;
//reg        own_dbus;
reg        PSBsl_dbb_n_d1;
wire       dbb_falling_asynch;
wire       dbb_rising_asynch;
reg        mcsr_start_dphase_asynch;  // asynch
reg        mcsr_vuart_start_dphase_asynch; // asynch
reg        plb_start_dphase_asynch;   // asynch
reg        db_ready_for_rdata_asynch; // asynch
reg        db_ready_for_rdata_reg;

// MCSR Access Logic
reg		   psb_mcsr_rd_wr_en_pulse_err;   
reg		   psb_mcsr_rd_wr_en_pulse_err_d1;
wire       psb_mcsr_en_pulse;
reg        psb_mcsr_en_pulse_d1;
reg        psb_mcsr_en_pulse_d2;
reg        start_mcsr_access ;
reg        start_mcsr_vuart_access;
reg        start_mcsr_access_sticky;
reg        start_mcsr_vuart_access_sticky;

// PLB Access Logic
reg        start_plb_access ;
reg        start_plb_access_sticky;
reg        start_plb_access_sticky_d1;
reg        adv_psb_burst_wdata;
reg        adv_psb_burst_wdata_d1;
reg        adv_psb_burst_wdata_d2;
wire       advance_psb_burst_wdata;

// PSB output signals
wire        mcsr_psb_access_ta_o  ;
wire        mcsr_psb_access_ta_en ;
wire [0:63] mcsr_psb_access_d_o   ;
wire        mcsr_psb_access_d_en  ;	 
wire        mcsr_psb_access_tea_o ;
wire        mcsr_psb_access_tea_en;

wire        plb_psb_access_ta_o	  ;
wire        plb_psb_access_ta_en  ;	 
wire [0:63] plb_psb_access_d_o	  ;
wire        plb_psb_access_d_en	  ;
wire        plb_psb_access_tea_o  ;	 
wire        plb_psb_access_tea_en ;

// PSB read data registers
reg [0:63] psb_read_data;
reg        psb_read_ta;
reg        psb_read_tea;
reg        deassert_rdata1_hold_val;
reg 	   deassert_rdata2_hold_val;
reg		   deassert_rdata3_hold_val;
reg		   deassert_rdata4_hold_val;
reg		   psb_read_data_frame;
reg [6:0]  psbr_state;
reg [1:0]  plb_psb_read_data_val_counter;
reg [0:63] rdata1_hold;    
reg        rdata1_hold_val;
reg [0:63] rdata2_hold;    
reg        rdata2_hold_val;
reg [0:63] rdata3_hold;    
reg        rdata3_hold_val;
reg [0:63] rdata4_hold;    
reg        rdata4_hold_val;
reg        read_tea_hold;
reg        deassert_read_tea_hold;

// delaying aack to avoid PS2 lockup
wire ufpga_ahit_sticky;
reg	 ufpga_ahit_sticky_reg;
wire plb_ahit_sticky;
reg	 plb_ahit_sticky_reg;
wire mcsr_ahit_sticky;
reg	 mcsr_ahit_sticky_reg;
wire mcsr_vuart_ahit_sticky;
reg	 mcsr_vuart_ahit_sticky_reg;


/********************************
* Module Logic      			*
********************************/

/******************************************************************************
* PSB Address FSM
* inputs:
*  addr_match - asserted if PSBsl_a falls within SDRAM or PLB_PSB Bridge Registers
*  accept_psb - asserted if PLB master is not currently doing access to PLB2PSB
*               and secondary PLB address request is not for PLB2PSB
*  
*
* outputs
*  PSBsl_aack_n_o
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
    begin
	    PSBsl_aack_n_o         <= 1'b1;
	    PSBsl_aack_n_en        <= 1'b0;
	    PSBsl_artry_n_o        <= 1'b1;
	    PSBsl_artry_n_en       <= 1'b0;

        plb_nmcsr              <= 1'b0;
		mcsr_vuart             <= 1'b0;
        deassert_aack_sig      <= 1'b0;
        deassert_artry_sig     <= 1'b0;

		ufpga_ahit_outstanding <= 0;
		accept_plb             <= 1'b1;
        psba_state             <= PSBA_IDLE;
    end

    else
    begin
		PSBsl_aack_n_o         <= 1'b1;
	    PSBsl_aack_n_en        <= 1'b0;
	    PSBsl_artry_n_o        <= 1'b1;
	    PSBsl_artry_n_en       <= 1'b0;
		ufpga_ahit_outstanding <= 0;

        plb_nmcsr              <= plb_nmcsr;
		mcsr_vuart             <= mcsr_vuart;
        deassert_aack_sig      <= 1'b0;
        deassert_artry_sig     <= 1'b0;

        case (psba_state)
        /*********************************************************************
        * State 1: PSBA_IDLE
        *              No access is taking place although this is where the
        *              start of an access is detected. It is either retried
        *              or accepted but in either case, the aack signal must
		*              be asserted to the PSII device.
        *********************************************************************/
        PSBA_IDLE:
        begin
		    if (ufpga_aonly_hit == 1)
			begin
		        PSBsl_aack_n_o    <= 1'b0;
	            PSBsl_aack_n_en   <= 1'b1;
				deassert_aack_sig <= 1'b1;
				accept_plb        <= 1'b1;

				psba_state       <= PSBA_IDLE;
			end

            else if ( (ufpga_ahit == 1) && (dont_aack_ps2 == 1) )
			// PS2 is targetting FPGA but outward read is taking place
			// so dont aack the PS2 until PSB is allowed to come in
			begin
				accept_plb       <= 1'b1;

				psba_state       <= PSBA_WAIT_BEFORE_AACK;
			end

		    else if ( (ufpga_ahit == 1) && (accept_psb == 1) )
		    // PSB access to PLB or MCSR and accepting accesses
			begin
		        PSBsl_aack_n_o   <= 1'b0;
	            PSBsl_aack_n_en  <= 1'b1;
				accept_plb       <= 1'b0;

				psba_state       <= PSBA_ACCEPT;
			end

			else if ( (ufpga_ahit == 1) && (accept_psb == 0) )
			// PSB access to PLB or MCSR but not accepting accesses
			begin
		        PSBsl_aack_n_o   <= 1'b0;
	            PSBsl_aack_n_en  <= 1'b1;
				accept_plb       <= 1'b1;

				psba_state       <= PSBA_RETRY;
			end

			else
			// No PSB access to PLB or MCSR
			begin
		        PSBsl_aack_n_o   <= 1'b1;
	            PSBsl_aack_n_en  <= deassert_aack_sig;
	            PSBsl_artry_n_o  <= 1'b1;
	            PSBsl_artry_n_en <= deassert_artry_sig;
				accept_plb       <= 1'b1;

				psba_state       <= PSBA_IDLE;
			end
        end

        /*********************************************************************
        * State 2: PSBA_WAIT_BEFORE_AACK
        *              The PS2 has the address bus and is waiting for aack
		*              but FPGA does not want to issue retry because the PS2
		*              will lockup. Instead, the FPGA holds off on aack
		*              until accept_psb is asserted by the outward bridge.
        *********************************************************************/
		PSBA_WAIT_BEFORE_AACK:
		begin
		    if (accept_psb == 1)
			// it is okay to aack the inward access now
			begin
				PSBsl_aack_n_o   <= 1'b0;
	            PSBsl_aack_n_en  <= 1'b1;
				accept_plb       <= 1'b0;
				psba_state       <= PSBA_ACCEPT;
			end
			else
			// still waiting for accept_psb to be asserted
			begin
				accept_plb       <= 1'b1;
				psba_state       <= PSBA_WAIT_BEFORE_AACK;
			end
		end

        /*********************************************************************
        * State 3: PSBA_RETRY
        *              The PSB protocol says that the artry signal must be
		*              asserted 1 cc after aack. This state asserts it and 
		*              sets a signal that will cause the next state to deassert
		*              it before it goes back to hi-z.
        *********************************************************************/
        PSBA_RETRY:
        begin
		    PSBsl_aack_n_o   <= 1'b1;
	        PSBsl_aack_n_en  <= 1'b1;
	        PSBsl_artry_n_o  <= 1'b0;
	        PSBsl_artry_n_en <= 1'b1;
			accept_plb       <= 1'b1;

            deassert_artry_sig <= 1;    // need to deassert PLBsl_artry_n_o
		    psba_state         <= PSBA_IDLE;
        end

        /*********************************************************************
        * State 4: PSBA_ACCEPT
        *              The previous state asserted aack so this state needs to
		*              deassert it. Then go to the next state and monitor the
		*              PSB address input signals again because the bus allows
		*              for pipelined accesses.
        *********************************************************************/
        PSBA_ACCEPT:
        begin
		    PSBsl_aack_n_o     <= 1'b1; // deassert PSBsl_aack_n_o
            PSBsl_aack_n_en    <= 1'b1;
            PSBsl_artry_n_o    <= 1'b1;
            PSBsl_artry_n_en   <= 1'b0;
			deassert_artry_sig <= 0;
			accept_plb         <= 1'b0;
			psba_state         <= PSBA_DIP_IDLE;
        end

        /*********************************************************************
        * State 5: PSBA_DIP_IDLE
        *              An access is ongoing and the address bus is being
        *              monitored for new address phases starting. If the
        *              ongoing access finished before the next address phase
        *              begins the FSM moves back to the idle state. If another
        *              address phase begins before the current ongoing access
        *              is finished, the address phase is accepted or retried
        *              depending on the state of the PLB bus (as indicated by
        *              the accept_psb signal). 
        *********************************************************************/
        PSBA_DIP_IDLE:
        begin
			accept_plb <= 1'b0;
		    if (data_phase_done == 1'b0)
			// first data_phase is not yet finished
			begin
			    if (ufpga_aonly_hit == 1)
			    // PSB requesting an address only transaction so ack it and stay
				begin
		            PSBsl_aack_n_o         <= 1'b0;
	                PSBsl_aack_n_en        <= 1'b1;
					deassert_aack_sig      <= 1'b1;
				    ufpga_ahit_outstanding <= ufpga_ahit_outstanding;
				end

			    else if (ufpga_ahit == 1)
			    // PSB access to PLB or MCSR and accepting accesses
				begin
					plb_nmcsr              <= plb_ahit;
					mcsr_vuart             <= mcsr_vuart_ahit;
				    ufpga_ahit_outstanding <= 1;
				end

                else
			    // No PSB access to PLB or MCSR
				begin
		            PSBsl_aack_n_o         <= 1'b1;
	                PSBsl_aack_n_en        <= deassert_aack_sig;
				    ufpga_ahit_outstanding <= ufpga_ahit_outstanding;
				end
			    psba_state <= PSBA_DIP_IDLE;
			end

            else
			// first data_phase is finished
			begin
			    ufpga_ahit_outstanding <= ufpga_ahit_outstanding;

			    if (ufpga_aonly_hit == 1)
			    // PSB requesting an address only transaction so ack it and move
				// to PSBA_IDLE (because current data phase is done)
				begin
		            PSBsl_aack_n_o    <= 1'b0;
	                PSBsl_aack_n_en   <= 1'b1;
					deassert_aack_sig <= 1'b1;
				    
				    psba_state        <= PSBA_IDLE;
				end

                else if ( (ufpga_ahit == 1) || (ufpga_ahit_outstanding == 1) )
			    // PSB access to PLB or MCSR and accepting accesses
				begin
		            PSBsl_aack_n_o   <= 1'b0;
	                PSBsl_aack_n_en  <= 1'b1;

				    psba_state       <= PSBA_ACCEPT;
				end

				else
				// No PSB access to PLB or MCSR
				begin
		            PSBsl_aack_n_o   <= 1'b1;
	                PSBsl_aack_n_en  <= deassert_aack_sig;

                    psba_state       <= PSBA_IDLE;
				end
			end
        end

        /*********************************************************************
        * Default State
        *********************************************************************/
        default:
        begin
			accept_plb <= 1'b1;
            psba_state <= PSBA_IDLE;
        end
        endcase
    end
end

// Decode PSB address to determine if it falls within PLB or MCSR address range
assign plb_ahit = ( ((PSBsl_a[0:PLB_MASTER_LSB_DECODE1] == PLB_MASTER_BASEADDR1[31:31-(PLB_MASTER_LSB_DECODE1)]) || 
                     (PSBsl_a[0:PLB_MASTER_LSB_DECODE2] == PLB_MASTER_BASEADDR2[31:31-(PLB_MASTER_LSB_DECODE2)])) && 
                    (PSBsl_ts_n == 0) ) ? 1'b1 : 1'b0;

// No registers in psb2plb bridge // assign mcsr_ahit = ( (PSBsl_a[0:PLB_PSB_FPGA_REG_LSB_DECODE] ==
// No registers in psb2plb bridge //                       PLB_PSB_FPGA_REG_BASEADDR[31:31-PLB_PSB_FPGA_REG_LSB_DECODE]) && (PSBsl_ts_n == 0) ) ?
// No registers in psb2plb bridge //                                   1'b1 : 1'b0;
assign mcsr_ahit = 0;

// No registers in psb2plb bridge // assign mcsr_vuart_ahit = ( (PSBsl_a[0:PLB_MASTER_LSB_DECODE] == PLB_MASTER_BASEADDR[31:31-(PLB_MASTER_LSB_DECODE)]) &&
// No registers in psb2plb bridge //                            (PSBsl_a[PSB2PLB_MCSR_VUART0_BITS_DECODE]) || (PSBsl_a[PSB2PLB_MCSR_VUART1_BITS_DECODE]) && 
// No registers in psb2plb bridge //                            (PSBsl_ts_n == 0) && (VUART_PRESENT == 1)) ? 1'b1 : 1'b0;
assign mcsr_vuart_ahit = 0;

assign ufpga_ahit = plb_ahit || mcsr_ahit;

assign ufpga_ahit_sticky = ( (ufpga_ahit == 1) && (dont_aack_ps2 == 1) ) ? 1'b1 :
                            ( ((start_plb_access == 1) | (start_mcsr_access == 1)) ? 1'b0 : 
                             ufpga_ahit_sticky_reg);

assign plb_ahit_sticky = ( (plb_ahit == 1) && (dont_aack_ps2 == 1) ) ? 1'b1 :
                            ( (start_plb_access == 1) ? 1'b0 : plb_ahit_sticky_reg);

assign mcsr_ahit_sticky = ( (mcsr_ahit == 1) && (dont_aack_ps2 == 1) ) ? 1'b1 :
                            ( (start_mcsr_access == 1) ? 1'b0 : mcsr_ahit_sticky_reg);

assign mcsr_vuart_ahit_sticky = ( (mcsr_vuart_ahit == 1) && (dont_aack_ps2 == 1) ) ? 1'b1 :
                                ( (start_mcsr_access == 1) ? 1'b0 : mcsr_vuart_ahit_sticky_reg);

assign ufpga_aonly_hit = ( (ufpga_ahit == 1) && (PSBsl_tt[3] == 0) ) ? 1'b1 : 1'b0;

assign data_phase_done = dbb_rising_asynch;

always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    ufpga_ahit_sticky_reg      <= 1'b0;
		plb_ahit_sticky_reg	       <= 1'b0;
		mcsr_ahit_sticky_reg       <= 1'b0;
		mcsr_vuart_ahit_sticky_reg <= 0;
	end
	else
	begin
	    ufpga_ahit_sticky_reg      <= ufpga_ahit_sticky;
		plb_ahit_sticky_reg	       <= plb_ahit_sticky;
		mcsr_ahit_sticky_reg       <= mcsr_ahit_sticky;
		mcsr_vuart_ahit_sticky_reg <= mcsr_vuart_ahit_sticky;
	end
end


/******************************************************************************
* PSB Address Phase Pipeline
* inputs:					
*							
* outputs					
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
    begin
        start_plb_access        <= 1'b0;
		start_mcsr_access       <= 1'b0;
		start_mcsr_vuart_access <= 1'b0;

        PSBsl_newest_a	        <= 32'b0;
        PSBsl_newest_tbst_n     <= 1'b1;
        PSBsl_newest_tsiz       <= 4'b0;
        PSBsl_newest_tt_rnw     <= 1'b0;
		PSBsl_newest_debug_cnt  <= 0;

        PSBsl_current_a	        <= 32'b0;
        PSBsl_current_tbst_n    <= 1'b1;
        PSBsl_current_tsiz      <= 3'b0;
		PSBsl_current_tt_rnw    <= 1'b0;
		PSBsl_current_debug_cnt <= 0;
	end

	else
	begin
	    // Latch the newest PSB address phase info when ts is asserted
		// and the address matches the User FPGA memory space
        if ( (ufpga_ahit == 1) && ( (accept_psb == 1) || (dont_aack_ps2 == 1) ) )
	    // PSB requesting an access to SDRAM, SRAM or MCSR within UFPGA
	    begin
            PSBsl_newest_a	      <= PSBsl_a;
            PSBsl_newest_tbst_n   <= PSBsl_tbst_n;
            PSBsl_newest_tsiz     <= PSBsl_tsiz;
            PSBsl_newest_tt_rnw   <= PSBsl_tt[1];
			PSBsl_newest_debug_cnt <= PSBsl_newest_debug_cnt + 1;
	    end
	    else
	    // PSB not requesting an access to User FPGA
	    begin
            PSBsl_newest_a	      <= PSBsl_newest_a;	  
            PSBsl_newest_tbst_n   <= PSBsl_newest_tbst_n;
            PSBsl_newest_tsiz     <= PSBsl_newest_tsiz;
            PSBsl_newest_tt_rnw   <= PSBsl_newest_tt_rnw;
			PSBsl_newest_debug_cnt <= PSBsl_newest_debug_cnt;
	    end

	    // Latch the current PSB address phase info when a new access
	    // that will involve a data phase is kicked
		if ( (psba_state == PSBA_IDLE) && (PSBsl_tt[3] == 1'b1) &&
		     (ufpga_ahit == 1) && (accept_psb == 1) )
		// Starting a new access (that will involve a data cycle) from
		// idle state (no ongoing access) so valid address phase info
		// is in the input registers
		begin
		    start_plb_access        <= plb_ahit; 
			start_mcsr_access       <= mcsr_ahit;
			start_mcsr_vuart_access <= mcsr_vuart_ahit;

            PSBsl_current_a	        <= PSBsl_a;
            PSBsl_current_tbst_n    <= PSBsl_tbst_n;
            PSBsl_current_tsiz      <= PSBsl_tsiz;
            PSBsl_current_tt_rnw    <= PSBsl_tt[1];
			PSBsl_current_debug_cnt <= PSBsl_current_debug_cnt + 1;
		end

        else if ( (psba_state == PSBA_WAIT_BEFORE_AACK) && (accept_psb == 1) )
		begin
		    start_plb_access        <= plb_ahit_sticky;
			start_mcsr_access       <= mcsr_ahit_sticky;
			start_mcsr_vuart_access <= mcsr_vuart_ahit_sticky;

            PSBsl_current_a	        <= PSBsl_a;
            PSBsl_current_tbst_n    <= PSBsl_tbst_n;
            PSBsl_current_tsiz      <= PSBsl_tsiz;
            PSBsl_current_tt_rnw    <= PSBsl_tt[1];
			PSBsl_current_debug_cnt <= PSBsl_current_debug_cnt + 1;
		end

        else if ( (psba_state == PSBA_DIP_IDLE) &&
                  (ufpga_ahit == 1) && (PSBsl_tt[3] == 1'b1) && 
                  (accept_psb == 1) && (data_phase_done == 1'b1) )
		// Starting a new access (that will involve a data cycle) from
		// DIP state (ongoing access) so valid address phase info
		// is in the holding registers (newest)
		begin
		    start_plb_access        <= plb_ahit;
			start_mcsr_access       <= mcsr_ahit;
			start_mcsr_vuart_access <= mcsr_vuart_ahit;

            PSBsl_current_a	        <= PSBsl_a;
            PSBsl_current_tbst_n    <= PSBsl_tbst_n;
            PSBsl_current_tsiz      <= PSBsl_tsiz;
            PSBsl_current_tt_rnw    <= PSBsl_tt[1];
			PSBsl_current_debug_cnt <= PSBsl_current_debug_cnt + 1;
		end

        else if ( (psba_state == PSBA_DIP_IDLE) &&
		          (ufpga_ahit_outstanding == 1) &&
                  (data_phase_done == 1'b1) )
		// Starting a new access (that will involve a data cycle) from
		// DIP state (ongoing access) so valid address phase info
		// is in the holding registers (newest)
		begin
		    start_plb_access        <= plb_nmcsr;  
			start_mcsr_access       <= ~plb_nmcsr; 
			start_mcsr_vuart_access <= mcsr_vuart;

            PSBsl_current_a	        <= PSBsl_a;
            PSBsl_current_tbst_n    <= PSBsl_tbst_n;
            PSBsl_current_tsiz      <= PSBsl_tsiz;
            PSBsl_current_tt_rnw    <= PSBsl_tt[1];
			PSBsl_current_debug_cnt <= PSBsl_current_debug_cnt + 1;
		end

        else
		begin
		    start_plb_access        <= 0;
			start_mcsr_access       <= 0;
			start_mcsr_vuart_access <= 0;

            PSBsl_current_a	        <= PSBsl_current_a;
            PSBsl_current_tbst_n    <= PSBsl_current_tbst_n;
            PSBsl_current_tsiz      <= PSBsl_current_tsiz;
            PSBsl_current_tt_rnw    <= PSBsl_current_tt_rnw;
			PSBsl_current_debug_cnt <= PSBsl_current_debug_cnt;
		end
	end
end

/******************************************************************************
* PSB Data FSM
* inputs:
*
* outputs:
******************************************************************************/
assign dbb_falling_asynch = ( (PSBsl_dbb_n == 0) && (PSBsl_dbb_n_d1 == 1) ) ?
                                              1'b1 : 1'b0;
assign dbb_rising_asynch  = ( (PSBsl_dbb_n == 1) && (PSBsl_dbb_n_d1 == 0) ) ?
                                              1'b1 : 1'b0;
always @(posedge clk or posedge reset)       
begin
    if (reset)
	    PSBsl_dbb_n_d1 <= 1'b1;
	else
	    PSBsl_dbb_n_d1 <= PSBsl_dbb_n;
end

always @(posedge clk or posedge reset)       
begin
    if (reset)
	    db_ready_for_rdata_reg <= 1'b0;
	else
	    db_ready_for_rdata_reg <= db_ready_for_rdata_asynch;
end

/******************************************************************************
* Determine when data phases can begin (when data phase is available for 
* current access).
* Separate out PLB access and MCSR accesses.
******************************************************************************/
always @(start_plb_access or start_plb_access_sticky or
         start_mcsr_access or start_mcsr_access_sticky or 
		 start_mcsr_vuart_access or start_mcsr_vuart_access_sticky or
         dbb_falling_asynch or plb_start_dphase_asynch or
         PSBsl_current_tt_rnw or db_ready_for_rdata_reg or
         dbb_rising_asynch)
begin
    if ( (start_mcsr_access || start_mcsr_access_sticky) &&
		 dbb_falling_asynch )
        mcsr_start_dphase_asynch <= 1'b1;
    else
	    mcsr_start_dphase_asynch <= 1'b0;

    if ( (start_mcsr_vuart_access || start_mcsr_vuart_access_sticky) &&
		 dbb_falling_asynch )
        mcsr_vuart_start_dphase_asynch <= 1'b1;
    else
	    mcsr_vuart_start_dphase_asynch <= 1'b0;

    if ( (start_plb_access  || start_plb_access_sticky) &&
		 dbb_falling_asynch )
        plb_start_dphase_asynch <= 1'b1;
    else
	    plb_start_dphase_asynch <= 1'b0;
		
    if ( (plb_start_dphase_asynch == 1) && (PSBsl_current_tt_rnw == 1'b1) )
	    db_ready_for_rdata_asynch <= 1;
	else if (dbb_rising_asynch)
	    db_ready_for_rdata_asynch <= 0;
	else
	    db_ready_for_rdata_asynch <= db_ready_for_rdata_reg;
end

/******************************************************************************
* MCSR Interface Signals
*      Need to create:
*        psb_mcsr_addr
*        psb_mcsr_wr_en_pulse (active high)
*        psb_mcsr_rd_en_pulse (active high)
*        psb_mcsr_write_data
******************************************************************************/
assign psb_mcsr_addr       = PSBsl_current_a[(PLB_PSB_FPGA_REG_LSB_DECODE+1):31];
assign psb_mcsr_write_data = (PSBsl_current_a[29:31] == 3'b000) ?
                                   PSBsl_d_i[0:31] : PSBsl_d_i[32:63];

always @(posedge clk or posedge reset)       
begin
    if (reset)
    begin
        psb_mcsr_wr_en_pulse           <= 1'b0;
		psb_mcsr_rd_en_pulse           <= 1'b0;
		psb_mcsr_rd_wr_en_pulse_err    <= 1'b0;
		psb_mcsr_rd_wr_en_pulse_err_d1 <= 1'b0;
		start_mcsr_access_sticky       <= 1'b0;
		start_mcsr_vuart_access_sticky <= 1'b0;
    end

    else
    begin
	    if (start_mcsr_access)
		    start_mcsr_access_sticky <= 1'b1;
		else if (psb_mcsr_wr_en_pulse || psb_mcsr_rd_en_pulse)
 		    start_mcsr_access_sticky <= 1'b0;
		else
		    start_mcsr_access_sticky <= start_mcsr_access_sticky;

        if (start_mcsr_vuart_access)
		    start_mcsr_vuart_access_sticky <= 1'b1;
		else if (psb_mcsr_wr_en_pulse || psb_mcsr_rd_en_pulse)
		    start_mcsr_vuart_access_sticky <= 0;
		else
		    start_mcsr_vuart_access_sticky <= start_mcsr_vuart_access_sticky;

	    if ( (mcsr_start_dphase_asynch == 1) &&
	     	 (PSBsl_current_tt_rnw == 0) &&
	         (PSBsl_current_tbst_n == 1'b1) &&
	         ( (PSBsl_current_tsiz == 3'b100) || 
	           ( (PSBsl_current_tsiz == 3'b001) && (mcsr_vuart_start_dphase_asynch == 1) ) ) )
		// Either word access to mcsr or word/byte access to VUART
		    psb_mcsr_wr_en_pulse <= 1'b1;
		else
		    psb_mcsr_wr_en_pulse <= 1'b0;

	    if ( (mcsr_start_dphase_asynch == 1) &&
	     	 (PSBsl_current_tt_rnw == 1) &&
	         (PSBsl_current_tbst_n == 1'b1) &&
	         ( (PSBsl_current_tsiz == 3'b100) || 
	           ( (PSBsl_current_tsiz == 3'b001) && (mcsr_vuart_start_dphase_asynch == 1) ) ) )
		// Either word access to mcsr or word/byte access to VUART
		    psb_mcsr_rd_en_pulse <= 1'b1;
		else
		    psb_mcsr_rd_en_pulse <= 1'b0;

		// Create signals to help terminate the access on the PSB bus
		// if trying to burst or do a single-beat non-word access to
		// the MCSRs
	    if ( (mcsr_start_dphase_asynch == 1) &&
	     	 ( (PSBsl_current_tbst_n == 1'b0) || ((PSBsl_current_tsiz != 3'b100) && !mcsr_vuart_start_dphase_asynch) ) 
	       )
			psb_mcsr_rd_wr_en_pulse_err <= 1'b1;
		else
			psb_mcsr_rd_wr_en_pulse_err <= 1'b0;

		psb_mcsr_rd_wr_en_pulse_err_d1 <= psb_mcsr_rd_wr_en_pulse_err;

	end
end

/******************************************************************************
* Ensuring that ta_n and tea_n get deasserted before going back to hi-z state
* during PLB accesses.
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    start_plb_access_sticky_d1 <= 0;
	end
	else
	begin
	    start_plb_access_sticky_d1 <= start_plb_access_sticky;
	end
end


/******************************************************************************
* Advancing data during Write Burst to PLB bus
*   Need to assert PSB TA signal 3 times in order to clock in the write data
*   that needs to be written on the PLB bus. The fourth PSB TA assertion will be
*   performed by the PLB side when the access has completed on the PLB bus.
*   NOTE: There are TBD clock cycles between asserting advance_psb_burst_wdata
*         and valid data being present on psb_plb_write_data.
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    start_plb_access_sticky <= 0;
		adv_psb_burst_wdata     <= 0;
	    adv_psb_burst_wdata_d1  <= 0;
	    adv_psb_burst_wdata_d2  <= 0;
	end
	else
	begin
	    if (start_plb_access)
	        start_plb_access_sticky <= 1;
		else if (plb_psb_access_done == 1'b1)
		    start_plb_access_sticky <= 0;
		else
		    start_plb_access_sticky <= start_plb_access_sticky;

        if ( (plb_start_dphase_asynch == 1'b1) &&
             (PSBsl_current_tt_rnw    == 1'b0)/* &&
			 (PSBsl_current_tbst_n    == 1'b0)*/
		   )
		// Performing a PSB-->PLB write and the databus is
		// owned by this access
		    adv_psb_burst_wdata <= 1'b1;
		else
		    adv_psb_burst_wdata <= 1'b0;

	    adv_psb_burst_wdata_d1  <= adv_psb_burst_wdata;
	    adv_psb_burst_wdata_d2  <= adv_psb_burst_wdata_d1;
	end
end

assign advance_psb_burst_wdata = adv_psb_burst_wdata | adv_psb_burst_wdata_d1 | 
 							     adv_psb_burst_wdata_d2;
/******************************************************************************
* PLB Interface Signals
*	 psb_plb_start_access
*	 psb_plb_address
*	 psb_plb_burst
*	 psb_plb_tsiz
*	 psb_plb_rnw
*	 psb_plb_write_data
*    psb_plb_wdata1_val
*    psb_plb_wdata2_val
*    psb_plb_wdata3_val
*    psb_plb_wdata4_val
******************************************************************************/
assign psb_plb_start_access	= start_plb_access;
assign psb_plb_address     	= PSBsl_current_a[0:31];
assign psb_plb_burst       	= ~PSBsl_current_tbst_n;
assign psb_plb_tsiz        	= PSBsl_current_tsiz[1:3];
assign psb_plb_rnw         	= PSBsl_current_tt_rnw;

always @(psb_plb_address or psb_plb_tsiz or PSBsl_d_i)
begin
    case (psb_plb_tsiz)
    3'b001:
	begin
	    case (psb_plb_address[29:31])
		3'b000: psb_plb_write_data <= {8{PSBsl_d_i[0:7]}};
		3'b001: psb_plb_write_data <= {8{PSBsl_d_i[8:15]}};
		3'b010: psb_plb_write_data <= {8{PSBsl_d_i[16:23]}};
		3'b011: psb_plb_write_data <= {8{PSBsl_d_i[24:31]}};
		3'b100: psb_plb_write_data <= {8{PSBsl_d_i[32:39]}};
		3'b101: psb_plb_write_data <= {8{PSBsl_d_i[40:47]}};
		3'b110: psb_plb_write_data <= {8{PSBsl_d_i[48:55]}};
		3'b111: psb_plb_write_data <= {8{PSBsl_d_i[56:63]}};
		default: psb_plb_write_data <= PSBsl_d_i[0:63];
		endcase
	end

	3'b010:
	begin
	    if (psb_plb_burst)
		// Bursting so must be Double-word in size
		begin
		    psb_plb_write_data <= PSBsl_d_i[0:63];		    
		end
		else
		// Not bursting so must be Half-word in size
		begin
	        case (psb_plb_address[29:31])
		    3'b000: psb_plb_write_data <= {4{PSBsl_d_i[0:15]}};
		    3'b001: psb_plb_write_data <= {2{PSBsl_d_i[0:31]}};
		    3'b010: psb_plb_write_data <= {4{PSBsl_d_i[16:31]}};
		    3'b100: psb_plb_write_data <= {4{PSBsl_d_i[32:47]}};
		    3'b101: psb_plb_write_data <= {2{PSBsl_d_i[32:63]}};
		    3'b110: psb_plb_write_data <= {4{PSBsl_d_i[48:63]}};
		   default: psb_plb_write_data <= PSBsl_d_i[0:63];
		   endcase
		end
	end

	3'b011:
	begin
	    case (psb_plb_address[29:31])
		3'b000: psb_plb_write_data <= {2{PSBsl_d_i[0:31]}};
		3'b001: psb_plb_write_data <= {2{PSBsl_d_i[0:31]}};
		3'b100: psb_plb_write_data <= {2{PSBsl_d_i[32:63]}};
		3'b101: psb_plb_write_data <= {2{PSBsl_d_i[32:63]}};
		default: psb_plb_write_data <= PSBsl_d_i[0:63];
		endcase
	end

	3'b100:
	begin
	    case (psb_plb_address[29:31])
		3'b000: psb_plb_write_data <= {2{PSBsl_d_i[0:31]}};
		3'b100: psb_plb_write_data <= {2{PSBsl_d_i[32:63]}};
		default: psb_plb_write_data <= PSBsl_d_i[0:63];
		endcase
	end

	3'b101, 3'b110, 3'b111:
	begin
        psb_plb_write_data <= PSBsl_d_i[0:63];
	end

	default: psb_plb_write_data <= PSBsl_d_i[0:63];
	endcase
end

assign psb_plb_wdata1_val = adv_psb_burst_wdata;
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
		psb_plb_wdata2_val <= 1'b0;
		psb_plb_wdata3_val <= 1'b0;
		psb_plb_wdata4_val <= 1'b0;
    end
	else
	begin
		psb_plb_wdata2_val <= adv_psb_burst_wdata_d2;
		psb_plb_wdata3_val <= psb_plb_wdata2_val;
		psb_plb_wdata4_val <= psb_plb_wdata3_val;
	end
end

/******************************************************************************
* PSB Read Data FSM
* Inputs:
*  db_ready_for_rdata_asynch - asserted for 1cc when PSB dbus is owned by
*                              current master
*  rdata1_hold_valid         - asserted if rdata1_hold contains first beat of
*  (similar for 2, 3, 4)       read data to be placed on the PSB dbus
*  rdata1_hold               - contains first beat of read data if the PLB
*                              bus finished read access before PSB dbus was ready
*  psb_plb_burst             - 1 = burst access; 0 = single beat access
*  plb_psb_read_data_val              - PLB read acknowledge (asserted high to signal
*                              that valid read data is available on plb_psb_read_data
*  plb_psb_read_data              - PLB read data bus
*  
*  accept_psb - asserted if PLB master is not currently doing access to PLB2PSB
*               and secondary PLB address request is not for PLB2PSB
*  read_tea_hold             - asserted if PLB encountered an error during
*                              read to PLB slave device
*
* Outputs
*  psb_read_ta               - asserted high to indicate that read data is valid
*  psb_read_data             - PSB read data to be placed on PSB data bus
*  deassert_rdata1_hold_val  - asserted after rdata1_hold_data has been used
*  (similar for 2, 3, 4)       in order to clear the valid bit
*  psb_read_tea              - asserted high to indicate on PSB that error occured
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    psb_read_data            <= 64'b0;
		psb_read_ta              <= 0;
		psb_read_tea             <= 0;
		deassert_rdata1_hold_val <= 0;
		deassert_rdata2_hold_val <= 0;
		deassert_rdata3_hold_val <= 0;
		deassert_rdata4_hold_val <= 0;
		deassert_read_tea_hold   <= 0;
		psb_read_data_frame      <= 0;
	    psbr_state               <= PSBR_IDLE;
    end

    else
    begin
		deassert_rdata1_hold_val <= 0;
		deassert_rdata2_hold_val <= 0;
		deassert_rdata3_hold_val <= 0;
		deassert_rdata4_hold_val <= 0;
		deassert_read_tea_hold   <= 0;
		psb_read_data_frame      <= psb_read_data_frame;

        case (psbr_state)

        /*********************************************************************
        * State 1: PSBR_IDLE
        *           Wait here for the start of a PSB to PLB read access.
        *********************************************************************/
		PSBR_IDLE:
		begin
	        psb_read_data            <= 64'b0;
		    psb_read_ta              <= 0;
		    psb_read_tea             <= 0;
		    deassert_rdata1_hold_val <= 1;
		    deassert_rdata2_hold_val <= 1;
		    deassert_rdata3_hold_val <= 1;
		    deassert_rdata4_hold_val <= 1;
		    deassert_read_tea_hold   <= 1;
			psb_read_data_frame      <= 0;

		    if ( (psb_plb_start_access) && (psb_plb_rnw == 1) )
			    psbr_state <= PSBR_WAIT_FOR_RD1;
			else
			    psbr_state <= PSBR_IDLE;
		end

        /*********************************************************************
        * State 2: PSBR_WAIT_FOR_RD1
        *           Either waiting for PSB data bus to be available during
        *           a read access or waiting for PLB read data to be
        *           available.
        *********************************************************************/
        PSBR_WAIT_FOR_RD1:
        begin
		    if (db_ready_for_rdata_asynch == 1)
			// The PSB data bus is owned by the current master (PS2)
			begin
    			psb_read_data_frame <= 1;

				if ( (read_tea_hold == 1) || 
				     ((plb_psb_error == 1) && (plb_psb_access_done == 1)) )
				// plb error occured during read
				begin
				    psb_read_data            <= 0;
				    psb_read_ta              <= 0;
				    psb_read_tea             <= 1;
					deassert_rdata1_hold_val <= 0;
				    psbr_state               <= PSBR_DEASSERT_TA_TEA;
				end

			    else if (rdata1_hold_val == 1)
                // The read data has already arrived and been stored in
				// the holding registers so place the 1st beat of data
				// on the PSB data bus.
				begin
	                psb_read_data            <= rdata1_hold;
		            psb_read_ta              <= 1;
					psb_read_tea             <= 0;
		            deassert_rdata1_hold_val <= 1;
					if (psb_plb_burst == 1)
					// access is a burst so must deal with beats 2, 3, 4
	                    psbr_state           <= PSBR_WAIT_FOR_RD2;
					else
	                    psbr_state           <= PSBR_DEASSERT_TA_TEA;
				end
				else if (plb_psb_read_data_val == 1)
				// Since the 1st holding register is not valid and 
				// plb_psb_read_data_val is now asserted, this must be the first beat
				// so place it on the PSB data bus.
				begin
	                psb_read_data            <= plb_psb_read_data;
		            psb_read_ta              <= 1;
					psb_read_tea             <= 0;
		            deassert_rdata1_hold_val <= 1;
					if (psb_plb_burst == 1)
					// access is a burst so must deal with beats 2, 3, 4
	                    psbr_state           <= PSBR_WAIT_FOR_RD2;
					else
	                    psbr_state           <= PSBR_DEASSERT_TA_TEA;
				end
				else
				// The 1st holding register is not valid and plb_psb_read_data_val
				// is not asserted so data has not arrived yet (wait here)
				begin
	                psb_read_data            <= 0;
		            psb_read_ta              <= 0;
					psb_read_tea             <= 0;
		            deassert_rdata1_hold_val <= 0;
	                psbr_state               <= PSBR_WAIT_FOR_RD1;
				end
            end

			else
			// The PSB data bus is not yet owned by current master (PS2)
			// so stay here and wait for it to be owned (db goes low)
			begin
			    psb_read_data_frame      <= 0;
	            psb_read_data            <= 64'b0;
		        psb_read_ta              <= 0;
				psb_read_tea             <= 0;
		        deassert_rdata1_hold_val <= 0;
                psbr_state               <= PSBR_WAIT_FOR_RD1;
			end
		end

        /*********************************************************************
        * State 3: PSBR_WAIT_FOR_RD2
        *           Waiting for the second beat to be valid during a burst read.
        *********************************************************************/
        PSBR_WAIT_FOR_RD2:
        begin
			if ( (read_tea_hold == 1) || 
				 ((plb_psb_error == 1) && (plb_psb_access_done == 1)) )
			// plb error occured during read
			begin
			    psb_read_data            <= 0;
			    psb_read_ta              <= 0;
			    psb_read_tea             <= 1;
				deassert_rdata2_hold_val <= 0;
			    psbr_state               <= PSBR_DEASSERT_TA_TEA;
			end

		    else if (rdata2_hold_val == 1)
			// The 2nd beat of data is in the hold2_data register so place
			// it on the PSB data bus
			begin
	            psb_read_data            <= rdata2_hold;
		        psb_read_ta              <= 1;
		        deassert_rdata2_hold_val <= 1;
                psbr_state               <= PSBR_WAIT_FOR_RD3;
			end

            else if (plb_psb_read_data_val == 1)
			// Since the 2nd holding register is not valid and 
			// plb_psb_read_data_val is now asserted, this must be the second beat
			// so place it on the PSB data bus.
			begin
                psb_read_data            <= plb_psb_read_data;
	            psb_read_ta              <= 1;
	            deassert_rdata1_hold_val <= 1;
                psbr_state               <= PSBR_WAIT_FOR_RD3;
			end

            else
			// The 2nd beat of read data has not arrived from the PLB bus yet
			begin
	            psb_read_data            <= 64'b0;
		        psb_read_ta              <= 0;
		        deassert_rdata2_hold_val <= 0;
                psbr_state               <= PSBR_WAIT_FOR_RD2;
			end
        end

        /*********************************************************************
        * State 4: PSBR_WAIT_FOR_RD3
        *           Waiting for the third beat to be valid during a burst read.
        *********************************************************************/
        PSBR_WAIT_FOR_RD3:
        begin
			if ( (read_tea_hold == 1) ||
				 ((plb_psb_error == 1) && (plb_psb_access_done == 1)) )
			// plb error occured during read
			begin
			    psb_read_data            <= 0;
			    psb_read_ta              <= 0;
			    psb_read_tea             <= 1;
				deassert_rdata3_hold_val <= 0;
			    psbr_state               <= PSBR_DEASSERT_TA_TEA;
			end

		    else if (rdata3_hold_val == 1)
			// The 3rd beat of data is in the hold3_data register so place
			// it on the PSB data bus
			begin
	            psb_read_data            <= rdata3_hold;
		        psb_read_ta              <= 1;
		        deassert_rdata3_hold_val <= 1;
                psbr_state               <= PSBR_WAIT_FOR_RD4;
			end

            else if (plb_psb_read_data_val == 1)
			// Since the 3rd holding register is not valid and 
			// plb_psb_read_data_val is now asserted, this must be the third beat
			// so place it on the PSB data bus.
			begin
                psb_read_data            <= plb_psb_read_data;
	            psb_read_ta              <= 1;
	            deassert_rdata1_hold_val <= 1;
                psbr_state               <= PSBR_WAIT_FOR_RD4;
			end

            else
			// The 3rd beat of read data has not arrived from the PLB bus yet
			begin
	            psb_read_data            <= 64'b0;
		        psb_read_ta              <= 0;
		        deassert_rdata3_hold_val <= 0;
                psbr_state               <= PSBR_WAIT_FOR_RD3;
			end
        end

        /*********************************************************************
        * State 5: PSBR_WAIT_FOR_RD4
		*           Waiting for the fourth beat to be valid during a burst read.
        *********************************************************************/
        PSBR_WAIT_FOR_RD4:
        begin
			if ( (read_tea_hold == 1) ||
				 ((plb_psb_error == 1) && (plb_psb_access_done == 1)) )
			// plb error occured during read
			begin
			    psb_read_data            <= 0;
			    psb_read_ta              <= 0;
			    psb_read_tea             <= 1;
				deassert_rdata4_hold_val <= 0;
			    psbr_state               <= PSBR_DEASSERT_TA_TEA;
			end

		    else if (rdata4_hold_val == 1)
			// The 4th beat of data is in the hold4_data register so place
			// it on the PSB data bus
			begin
	            psb_read_data            <= rdata4_hold;
		        psb_read_ta              <= 1;
		        deassert_rdata4_hold_val <= 1;
                psbr_state               <= PSBR_DEASSERT_TA_TEA;
			end

            else if (plb_psb_read_data_val == 1)
			// Since the 4th holding register is not valid and 
			// plb_psb_read_data_val is now asserted, this must be the fourth beat
			// so place it on the PSB data bus.
			begin
                psb_read_data            <= plb_psb_read_data;
	            psb_read_ta              <= 1;
	            deassert_rdata1_hold_val <= 1;
                psbr_state               <= PSBR_DEASSERT_TA_TEA;
			end

            else
			// The 4th beat of read data has not arrived from the PLB bus yet
			begin
	            psb_read_data            <= 64'b0;
		        psb_read_ta              <= 0;
		        deassert_rdata4_hold_val <= 0;
                psbr_state               <= PSBR_WAIT_FOR_RD4;
			end
        end

        /*********************************************************************
        * State 6: PSBR_DEASSERT_TA_TEA
        *           Deassert the PSB TA signal for 1cc before tri-stating it.  
        *********************************************************************/
        PSBR_DEASSERT_TA_TEA:
        begin
            psb_read_data       <= psb_read_data;
	        psb_read_ta         <= 0;
			psb_read_tea        <= 0;
			psb_read_data_frame <= 1;

		    deassert_rdata1_hold_val <= 1;
		    deassert_rdata2_hold_val <= 1;
		    deassert_rdata3_hold_val <= 1;
		    deassert_rdata4_hold_val <= 1;
			deassert_read_tea_hold   <= 1;

		    if (dbb_rising_asynch == 1)
			// access is finished
			begin
		        psbr_state     <= PSBR_IDLE;
			end
			else
			// access is not finished because dbb is not high
			begin
		        psbr_state     <= PSBR_WAIT_FOR_DBB_HIGH;
			end
        end


        /*********************************************************************
        * State 7: PSBR_WAIT_FOR_DB_HIGH
        *           Waiting for the db signal to go high again (access is done).  
        *********************************************************************/
        PSBR_WAIT_FOR_DBB_HIGH:
        begin
            psb_read_data       <= 64'b0;
	        psb_read_ta         <= 0;
			psb_read_tea        <= 0;
			psb_read_data_frame <= 0;

		    if (dbb_rising_asynch == 1)
			// access is finished
			begin
		        psbr_state     <= PSBR_IDLE;
			end
			else
			// access is not finished because dbb is not high
			begin
		        psbr_state     <= PSBR_WAIT_FOR_DBB_HIGH;
			end
        end

        /*********************************************************************
        * Default State
        *********************************************************************/
        default:
        begin
            psb_read_data <= 64'b0;
	        psb_read_ta   <= 0;
			psb_read_tea  <= 0;

            psbr_state    <= PSBR_IDLE;
        end
        endcase
    end
end

/******************************************************************************
* plb_psb_read_data_val counter - This counter is used to determine when to place
*                        PLBma_RdData into appropriate holding register.
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    plb_psb_read_data_val_counter <= 0;
	end
	else
	begin
	    if (psbr_state == PSBR_DEASSERT_TA_TEA)
		// read access is finished so clear the counter
		    plb_psb_read_data_val_counter <= 0;
		else if (plb_psb_read_data_val == 1)
		// received read ack from PLB bus so increment counter
		    plb_psb_read_data_val_counter <= plb_psb_read_data_val_counter + 1;
		else
            plb_psb_read_data_val_counter <= plb_psb_read_data_val_counter;
	end
end

/******************************************************************************
* Read Data Holding Registers - These registers are used to hold the PLB read
*                               data until the data is placed on the PSB bus.
*                               These are needed in case the PLB passes the
*                               read data to this bridge before the PSB databus
*                               has been granted to the master.
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
        rdata1_hold     <= 0;
    	rdata1_hold_val <= 0;

        rdata2_hold     <= 0;
    	rdata2_hold_val <= 0;

        rdata3_hold     <= 0;
    	rdata3_hold_val <= 0;

        rdata4_hold     <= 0;
    	rdata4_hold_val <= 0;
	end

	else
	begin
	    //***** rdata1 *****//
        if ( (plb_psb_read_data_val ==1) && 
             (plb_psb_read_data_val_counter == 2'b00) )
        // Received first plb_psb_read_data_val
        begin
            rdata1_hold     <= plb_psb_read_data;
	    	rdata1_hold_val <= 1;
	    end

	    else if (deassert_rdata1_hold_val == 1)
	    // This holding register has been used so it can be invalidated
	    begin
            rdata1_hold     <= 0;
	    	rdata1_hold_val <= 0;
	    end

	    else
	    begin
            rdata1_hold     <= rdata1_hold    ;
	    	rdata1_hold_val <= rdata1_hold_val;
	    end

	    //***** rdata2 *****//
        if ( (plb_psb_read_data_val ==1) && 
             (plb_psb_read_data_val_counter == 2'b01) )
        // Received second plb_psb_read_data_val
        begin
            rdata2_hold     <= plb_psb_read_data;
	    	rdata2_hold_val <= 1;
	    end

	    else if (deassert_rdata2_hold_val == 1)
	    // This holding register has been used so it can be invalidated
	    begin
            rdata2_hold     <= 0;
	    	rdata2_hold_val <= 0;
	    end

	    else
	    begin
            rdata2_hold     <= rdata2_hold    ;
	    	rdata2_hold_val <= rdata2_hold_val;
	    end

	    //***** rdata3 *****//
        if ( (plb_psb_read_data_val == 1) && 
             (plb_psb_read_data_val_counter == 2'b10) )
        // Received third plb_psb_read_data_val
        begin
            rdata3_hold     <= plb_psb_read_data;
	    	rdata3_hold_val <= 1;
	    end

	    else if (deassert_rdata3_hold_val == 1)
	    // This holding register has been used so it can be invalidated
	    begin
            rdata3_hold     <= 0;
	    	rdata3_hold_val <= 0;
	    end

	    else
	    begin
            rdata3_hold     <= rdata3_hold    ;
	    	rdata3_hold_val <= rdata3_hold_val;
	    end

	    //***** rdata4 *****//
        if ( (plb_psb_read_data_val ==1) && 
             (plb_psb_read_data_val_counter == 2'b11) )
        // Received fourth plb_psb_read_data_val
        begin
            rdata4_hold     <= plb_psb_read_data;
	    	rdata4_hold_val <= 1;
	    end

	    else if (deassert_rdata4_hold_val == 1)
	    // This holding register has been used so it can be invalidated
	    begin
            rdata4_hold     <= 0;
	    	rdata4_hold_val <= 0;
	    end

	    else
	    begin
            rdata4_hold     <= rdata4_hold    ;
	    	rdata4_hold_val <= rdata4_hold_val;
	    end
	end
end

/******************************************************************************
* Read tea holding register - This register is used to hold the plb_psb_error
*                             until the data bus has been granted to the PSB
*                             master that is performing the current access.
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    read_tea_hold <= 0;
	end
	else
	begin
	    if ( (plb_psb_error == 1) && (PSBsl_current_tt_rnw == 1) &&
	         (plb_psb_access_done == 1) )
		// Received an error from the PLB bus while performing a read
		    read_tea_hold <= 1;
		else if (deassert_read_tea_hold)
		// tea has been asserted if there was an error so clear the holding reg
		    read_tea_hold <= 0;
		else
		    read_tea_hold <= read_tea_hold;
	end
end

/******************************************************************************
* MCSR access PSB Data Interface Signals  (all active high)
******************************************************************************/
// Create signal to allow PSBsl_ta_n_o to be deasserted in cc after it is asserted
assign psb_mcsr_en_pulse = psb_mcsr_wr_en_pulse | psb_mcsr_rd_en_pulse;
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    psb_mcsr_en_pulse_d1 <= 1'b0;
	    psb_mcsr_en_pulse_d2 <= 1'b0;
	end
	else
	begin
	    psb_mcsr_en_pulse_d1 <= psb_mcsr_en_pulse;
	    psb_mcsr_en_pulse_d2 <= psb_mcsr_en_pulse_d1;
	end
end

//***** PSBls_ta_n *********//
assign mcsr_psb_access_ta_o = ( (psb_mcsr_en_pulse_d1 == 1       ) || 
                                (psb_mcsr_rd_wr_en_pulse_err == 1) ) ? 1'b1 : 1'b0;

assign mcsr_psb_access_ta_en  = ( (psb_mcsr_en_pulse_d1 == 1       ) || 
                                  (psb_mcsr_en_pulse_d2 == 1       ) || 
                                  (psb_mcsr_rd_wr_en_pulse_err == 1) ||
                                  (psb_mcsr_rd_wr_en_pulse_err_d1 == 1) ) ? 1'b1 : 1'b0;

assign mcsr_psb_access_d_o    = ( (psb_mcsr_en_pulse_d1 == 1) || (psb_mcsr_en_pulse_d2 == 1) ) ?
                                       mcsr_psb_read_data : 64'b0;
assign mcsr_psb_access_d_en	  = (PSBsl_current_tt_rnw && psb_mcsr_en_pulse_d1);

// anything other than a single word access to MCSR
assign mcsr_psb_access_tea_o  = (psb_mcsr_rd_wr_en_pulse_err == 1'b1) ? 1'b1 : 1'b0; 

assign mcsr_psb_access_tea_en  = ( (psb_mcsr_rd_wr_en_pulse_err == 1   ) ||
								   (psb_mcsr_rd_wr_en_pulse_err_d1 == 1) ) ? 1'b1 : 1'b0;


/******************************************************************************
* PLB access PSB Data Interface Signals (all active high)
******************************************************************************/
//***** PSBls_ta_n *********//
//changed_rdata_path//  assign plb_psb_access_ta_o	 = (plb_psb_read_data_val |
//changed_rdata_path//                                  (advance_psb_burst_wdata && psb_plb_burst) |
//changed_rdata_path//                                  plb_psb_access_done);
//changed_rdata_path//  assign plb_psb_access_ta_en	 = start_plb_access_sticky | start_plb_access_sticky_d1;
//changed_rdata_path//  
//changed_rdata_path//  assign plb_psb_access_d_o	 = plb_psb_read_data;
//changed_rdata_path//  assign plb_psb_access_d_en	 = (start_plb_access_sticky && PSBsl_current_tt_rnw);
//changed_rdata_path//  
//changed_rdata_path//  assign plb_psb_access_tea_o	 = plb_psb_error && plb_psb_access_done && 
//changed_rdata_path//                                 ~(~start_plb_access_sticky && start_plb_access_sticky_d1);
//changed_rdata_path//  assign plb_psb_access_tea_en = start_plb_access_sticky | start_plb_access_sticky_d1;

assign plb_psb_access_ta_o	 = (psb_read_ta |								       /* read access */
                                (advance_psb_burst_wdata && psb_plb_burst) |       /* write burst */
                                (plb_psb_access_done && !PSBsl_current_tt_rnw ));  /* write - final beat */
assign plb_psb_access_ta_en	 = (PSBsl_current_tt_rnw == 0) ?
                                   (start_plb_access_sticky | start_plb_access_sticky_d1) :	 /* write access */
                                   psb_read_data_frame;                            /* read access  */

assign plb_psb_access_d_o	 = psb_read_data;
assign plb_psb_access_d_en	 = psb_read_data_frame;

assign plb_psb_access_tea_o	 = (PSBsl_current_tt_rnw == 0) ?
                                   (plb_psb_error && plb_psb_access_done) :        /* write access */
                                   (psb_read_tea);                                 /* read access  */
assign plb_psb_access_tea_en = (PSBsl_current_tt_rnw == 0) ?
                                   (start_plb_access_sticky | start_plb_access_sticky_d1) :	 /* write access */
								   (psb_read_data_frame);                          /* read access) */

/******************************************************************************
* PSB Data Interface Signals (enables are active high; outputs are active low)
******************************************************************************/
assign PSBsl_ta_n_o	  = mcsr_psb_access_ta_en ? ~mcsr_psb_access_ta_o :
                         (plb_psb_access_ta_en ? ~plb_psb_access_ta_o : 1'b1);
assign PSBsl_ta_n_en  = mcsr_psb_access_ta_en | plb_psb_access_ta_en;

assign PSBsl_d_o      = mcsr_psb_access_d_en ? mcsr_psb_access_d_o : plb_psb_access_d_o;
assign PSBsl_d_en	  = mcsr_psb_access_d_en | plb_psb_access_d_en;

assign PSBsl_tea_n_o  =	mcsr_psb_access_tea_en ? ~mcsr_psb_access_tea_o :
                         (plb_psb_access_tea_en ? ~plb_psb_access_tea_o : 1'b1);

assign PSBsl_tea_n_en =	mcsr_psb_access_tea_en | plb_psb_access_tea_en;


// original chipscope signals //assign psb2plb_psbside_debug[0]  = start_plb_access              ;
// original chipscope signals //assign psb2plb_psbside_debug[1]  = psba_state[0]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[2]  = psba_state[1]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[3]  = psba_state[2]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[4]  = psba_state[3]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[5]  = psba_state[4]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[6]  = psba_state[5]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[7]  = psba_state[6]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[8]  = psba_state[7]                 ;
// original chipscope signals //assign psb2plb_psbside_debug[9]  = PSBsl_artry_n_o               ;
// original chipscope signals //assign psb2plb_psbside_debug[10] = PSBsl_artry_n_en              ;
// original chipscope signals //assign psb2plb_psbside_debug[11] = PSBsl_aack_n_o                ;
// original chipscope signals //assign psb2plb_psbside_debug[12] = PSBsl_aack_n_en               ;
// original chipscope signals //assign psb2plb_psbside_debug[13] = ufpga_ahit                    ;
// original chipscope signals //assign psb2plb_psbside_debug[14] = start_plb_access_sticky       ;
// original chipscope signals //assign psb2plb_psbside_debug[15] = start_plb_access_sticky_d1    ;
// original chipscope signals //assign psb2plb_psbside_debug[16] = dbb_falling_asynch            ;
// original chipscope signals //assign psb2plb_psbside_debug[17] = plb_start_dphase_asynch       ;
// original chipscope signals //assign psb2plb_psbside_debug[18] = plb_psb_access_ta_en          ;
// original chipscope signals //assign psb2plb_psbside_debug[19] = plb_psb_access_ta_o           ;
// original chipscope signals //assign psb2plb_psbside_debug[20] = plb_psb_read_data_val         ;
// original chipscope signals //assign psb2plb_psbside_debug[21] = plb_psb_access_done           ;
// original chipscope signals //assign psb2plb_psbside_debug[22] = psb_plb_rnw                   ;
// original chipscope signals //assign psb2plb_psbside_debug[23] = plb_psb_read_data[0]          ;
// original chipscope signals //assign psb2plb_psbside_debug[24] = plb_psb_read_data[1]          ;
// original chipscope signals //assign psb2plb_psbside_debug[25] = plb_psb_read_data[2]          ;
// original chipscope signals //assign psb2plb_psbside_debug[26] = plb_psb_read_data[3]          ;
// original chipscope signals //assign psb2plb_psbside_debug[27] = plb_psb_read_data[24]         ;
// original chipscope signals //assign psb2plb_psbside_debug[28] = plb_psb_read_data[25]         ;
// original chipscope signals //assign psb2plb_psbside_debug[29] = plb_psb_read_data[26]         ;
// original chipscope signals //assign psb2plb_psbside_debug[30] = plb_psb_read_data[27]         ; 
// original chipscope signals //assign psb2plb_psbside_debug[31] = plb_psb_read_data[28]         ; 
// original chipscope signals //assign psb2plb_psbside_debug[32] = plb_psb_read_data[29]         ; 
// original chipscope signals //assign psb2plb_psbside_debug[33] = plb_psb_read_data[30]         ; 
// original chipscope signals //assign psb2plb_psbside_debug[34] = plb_psb_read_data[31]         ;
// original chipscope signals //assign psb2plb_psbside_debug[35] = plb_psb_read_data[60]         ; 
// original chipscope signals //assign psb2plb_psbside_debug[36] = plb_psb_read_data[61]         ; 
// original chipscope signals //assign psb2plb_psbside_debug[37] = plb_psb_read_data[62]         ; 
// original chipscope signals //assign psb2plb_psbside_debug[38] = plb_psb_read_data[63]         ;					  
// original chipscope signals //assign psb2plb_psbside_debug[39] = plb_psb_access_d_en           ;
// original chipscope signals //assign psb2plb_psbside_debug[40] = data_phase_done               ;
// original chipscope signals //assign psb2plb_psbside_debug[41] = accept_psb                    ;
// original chipscope signals //assign psb2plb_psbside_debug[42] = mcsr_psb_access_ta_o          ;
// original chipscope signals //assign psb2plb_psbside_debug[43] = mcsr_psb_access_ta_en         ;
// original chipscope signals //assign psb2plb_psbside_debug[44] = mcsr_psb_access_tea_o         ;
// original chipscope signals //assign psb2plb_psbside_debug[45] = mcsr_psb_access_tea_en        ;
// original chipscope signals //assign psb2plb_psbside_debug[46] = mcsr_psb_access_d_en          ;
// original chipscope signals //assign psb2plb_psbside_debug[47] = start_mcsr_access             ;
// original chipscope signals //assign psb2plb_psbside_debug[48] = PSBsl_current_tbst_n          ;
// original chipscope signals //assign psb2plb_psbside_debug[49] = PSBsl_current_tsiz[1]         ;
// original chipscope signals //assign psb2plb_psbside_debug[50] = PSBsl_current_tsiz[2]         ;	 
// original chipscope signals //assign psb2plb_psbside_debug[51] = PSBsl_current_tsiz[3]         ;	 
// original chipscope signals //assign psb2plb_psbside_debug[52] = PSBsl_current_tt_rnw          ;	 
// original chipscope signals //assign psb2plb_psbside_debug[53] = psb_mcsr_rd_en_pulse          ;
// original chipscope signals //assign psb2plb_psbside_debug[54] = psb_mcsr_wr_en_pulse          ;   
// original chipscope signals //assign psb2plb_psbside_debug[55] = start_mcsr_access_sticky      ;	 
// original chipscope signals //assign psb2plb_psbside_debug[56] = psb_mcsr_rd_wr_en_pulse_err   ;
// original chipscope signals //assign psb2plb_psbside_debug[57] = psb_mcsr_rd_wr_en_pulse_err_d1;	 
// original chipscope signals //assign psb2plb_psbside_debug[58] = mcsr_ahit                     ;
// original chipscope signals //assign psb2plb_psbside_debug[59] = plb_ahit                      ; 
// original chipscope signals //assign psb2plb_psbside_debug[60] = mcsr_start_dphase_asynch      ;
// original chipscope signals //assign psb2plb_psbside_debug[61] = psb_mcsr_en_pulse             ;
// original chipscope signals //assign psb2plb_psbside_debug[62] = psb_mcsr_en_pulse_d1          ;
// original chipscope signals //assign psb2plb_psbside_debug[63] = psb_mcsr_en_pulse_d2          ;
// original chipscope signals //assign psb2plb_psbside_debug[64] = plb_psb_access_tea_en         ;			
// original chipscope signals //assign psb2plb_psbside_debug[65] = plb_psb_access_tea_o          ;		
// original chipscope signals //assign psb2plb_psbside_debug[66] = PSBsl_ta_n_o                  ;
// original chipscope signals //assign psb2plb_psbside_debug[67] = PSBsl_ta_n_en                 ;			 
// original chipscope signals //assign psb2plb_psbside_debug[68] = PSBsl_d_en                    ;		              
// original chipscope signals //assign psb2plb_psbside_debug[69] = PSBsl_tea_n_o                 ;		 
// original chipscope signals //assign psb2plb_psbside_debug[70] = PSBsl_tea_n_en                ;
// original chipscope signals //assign psb2plb_psbside_debug[71] = ufpga_ahit_sticky             ;
// original chipscope signals //assign psb2plb_psbside_debug[72] = plb_ahit_sticky               ;
// original chipscope signals //assign psb2plb_psbside_debug[73] = mcsr_ahit_sticky              ;
// original chipscope signals //assign psb2plb_psbside_debug[74] = psb_plb_wdata1_val            ;				         
// original chipscope signals //assign psb2plb_psbside_debug[75] = psb_plb_wdata2_val            ;
// original chipscope signals //assign psb2plb_psbside_debug[76] = psb_plb_wdata3_val            ;									
// original chipscope signals //assign psb2plb_psbside_debug[77] = psb_plb_wdata4_val            ;
// original chipscope signals //assign psb2plb_psbside_debug[78] = psb_plb_write_data[0]         ;
// original chipscope signals //assign psb2plb_psbside_debug[79] = psb_plb_write_data[1]         ;
// original chipscope signals //assign psb2plb_psbside_debug[80] = psb_plb_write_data[2]         ;
// original chipscope signals //assign psb2plb_psbside_debug[81] = psb_plb_write_data[3]         ;
// original chipscope signals //assign psb2plb_psbside_debug[82] = psb_plb_write_data[28]        ;
// original chipscope signals //assign psb2plb_psbside_debug[83] = psb_plb_write_data[29]        ;
// original chipscope signals //assign psb2plb_psbside_debug[84] = psb_plb_write_data[30]        ;
// original chipscope signals //assign psb2plb_psbside_debug[85] = psb_plb_write_data[31]        ;
// original chipscope signals //assign psb2plb_psbside_debug[86] = PSBsl_d_o[0]		             ;
// original chipscope signals //assign psb2plb_psbside_debug[87] = PSBsl_d_o[1]		             ;
// original chipscope signals //assign psb2plb_psbside_debug[88] = PSBsl_d_o[2]		             ;
// original chipscope signals //assign psb2plb_psbside_debug[89] = PSBsl_d_o[3]		             ;
// original chipscope signals //assign psb2plb_psbside_debug[90] = PSBsl_d_o[24]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[91] = PSBsl_d_o[25]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[92] = PSBsl_d_o[26]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[93] = PSBsl_d_o[27]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[94] = PSBsl_d_o[28]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[95] = PSBsl_d_o[29]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[96] = PSBsl_d_o[30]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[97] = PSBsl_d_o[31]		         ;
// original chipscope signals //assign psb2plb_psbside_debug[98] = psb_read_ta					 ;
// original chipscope signals //assign psb2plb_psbside_debug[99] = psb_read_data_frame           ;

assign psb2plb_psbside_debug[0]  = psba_state[0]                 ;
assign psb2plb_psbside_debug[1]  = psba_state[1]                 ;
assign psb2plb_psbside_debug[2]  = psba_state[2]                 ;      
assign psb2plb_psbside_debug[3]  = psba_state[3]                 ;
assign psb2plb_psbside_debug[4]  = psba_state[4]                 ;
assign psb2plb_psbside_debug[5]  = psba_state[5]                 ; 
assign psb2plb_psbside_debug[6]  = psba_state[6]                 ;
assign psb2plb_psbside_debug[7]  = psba_state[7]                 ;
assign psb2plb_psbside_debug[8]  = PSBsl_artry_n_o               ;
assign psb2plb_psbside_debug[9]  = PSBsl_artry_n_en              ;
assign psb2plb_psbside_debug[10] = PSBsl_aack_n_o                ; 
assign psb2plb_psbside_debug[11] = PSBsl_aack_n_en               ;
assign psb2plb_psbside_debug[12] = psb_plb_rnw                   ;
assign psb2plb_psbside_debug[13] = plb_nmcsr                     ;
assign psb2plb_psbside_debug[14] = mcsr_vuart                    ;
assign psb2plb_psbside_debug[15] = 0                             ;
assign psb2plb_psbside_debug[16] = 0                             ;
assign psb2plb_psbside_debug[17] = deassert_aack_sig             ;
assign psb2plb_psbside_debug[18] = deassert_artry_sig            ;
assign psb2plb_psbside_debug[19] = ufpga_ahit_outstanding        ;
assign psb2plb_psbside_debug[20] = ufpga_ahit                    ;
assign psb2plb_psbside_debug[21] = start_plb_access              ;
assign psb2plb_psbside_debug[22] = start_mcsr_access             ;
assign psb2plb_psbside_debug[23] = start_mcsr_vuart_access       ;
assign psb2plb_psbside_debug[24] = PSBsl_current_debug_cnt[0]    ;
assign psb2plb_psbside_debug[25] = PSBsl_current_debug_cnt[1]    ;
assign psb2plb_psbside_debug[26] = PSBsl_current_debug_cnt[2]    ;
assign psb2plb_psbside_debug[27] = PSBsl_current_debug_cnt[3]    ;
assign psb2plb_psbside_debug[28] = PSBsl_current_debug_cnt[4]    ;
assign psb2plb_psbside_debug[29] = PSBsl_current_debug_cnt[5]    ;
assign psb2plb_psbside_debug[30] = PSBsl_current_debug_cnt[6]    ; 
assign psb2plb_psbside_debug[31] = PSBsl_current_debug_cnt[7]    ; 
assign psb2plb_psbside_debug[32] = PSBsl_newest_debug_cnt[0]     ; 
assign psb2plb_psbside_debug[33] = PSBsl_newest_debug_cnt[1]     ; 
assign psb2plb_psbside_debug[34] = PSBsl_newest_debug_cnt[2]     ;
assign psb2plb_psbside_debug[35] = PSBsl_newest_debug_cnt[3]     ; 
assign psb2plb_psbside_debug[36] = PSBsl_newest_debug_cnt[4]     ; 
assign psb2plb_psbside_debug[37] = PSBsl_newest_debug_cnt[5]     ; 
assign psb2plb_psbside_debug[38] = PSBsl_newest_debug_cnt[6]     ;					  
assign psb2plb_psbside_debug[39] = PSBsl_newest_debug_cnt[7]     ;
assign psb2plb_psbside_debug[40] = 0                             ;
assign psb2plb_psbside_debug[41] = 0                             ;
assign psb2plb_psbside_debug[42] = 0                             ;
assign psb2plb_psbside_debug[43] = 0                             ;
assign psb2plb_psbside_debug[44] = 0                             ;
assign psb2plb_psbside_debug[45] = 0                             ;
assign psb2plb_psbside_debug[46] = 0                             ;
assign psb2plb_psbside_debug[47] = 0                             ;
assign psb2plb_psbside_debug[48] = 0                             ;
assign psb2plb_psbside_debug[49] = 0                             ;
assign psb2plb_psbside_debug[50] = 0                             ;	 
assign psb2plb_psbside_debug[51] = 0                             ;	 
assign psb2plb_psbside_debug[52] = start_plb_access_sticky       ;	 
assign psb2plb_psbside_debug[53] = start_plb_access_sticky_d1    ;
assign psb2plb_psbside_debug[54] = dbb_falling_asynch            ;   
assign psb2plb_psbside_debug[55] = plb_start_dphase_asynch       ;	 
assign psb2plb_psbside_debug[56] = plb_psb_access_ta_en          ;
assign psb2plb_psbside_debug[57] = plb_psb_access_ta_o           ;	 
assign psb2plb_psbside_debug[58] = plb_psb_read_data_val         ;
assign psb2plb_psbside_debug[59] = plb_psb_access_done           ; 
assign psb2plb_psbside_debug[60] = plb_psb_access_d_en           ;
assign psb2plb_psbside_debug[61] = data_phase_done               ;
assign psb2plb_psbside_debug[62] = accept_psb                    ;
assign psb2plb_psbside_debug[63] = mcsr_psb_access_ta_o          ;
assign psb2plb_psbside_debug[64] = mcsr_psb_access_ta_en         ;			
assign psb2plb_psbside_debug[65] = mcsr_psb_access_tea_o         ;		
assign psb2plb_psbside_debug[66] = mcsr_psb_access_tea_en        ;
assign psb2plb_psbside_debug[67] = mcsr_psb_access_d_en          ;			 
assign psb2plb_psbside_debug[68] = PSBsl_current_tbst_n          ;		              
assign psb2plb_psbside_debug[69] = PSBsl_current_tsiz[1]         ;		 
assign psb2plb_psbside_debug[70] = PSBsl_current_tsiz[2]         ;
assign psb2plb_psbside_debug[71] = PSBsl_current_tsiz[3]         ;
assign psb2plb_psbside_debug[72] = PSBsl_current_tt_rnw          ;
assign psb2plb_psbside_debug[73] = psb_mcsr_rd_en_pulse          ;
assign psb2plb_psbside_debug[74] = psb_mcsr_wr_en_pulse          ;				         
assign psb2plb_psbside_debug[75] = start_mcsr_access_sticky      ;
assign psb2plb_psbside_debug[76] = psb_mcsr_rd_wr_en_pulse_err   ;									
assign psb2plb_psbside_debug[77] = psb_mcsr_rd_wr_en_pulse_err_d1;
assign psb2plb_psbside_debug[78] = mcsr_ahit                     ;
assign psb2plb_psbside_debug[79] = plb_ahit                      ;
assign psb2plb_psbside_debug[80] = mcsr_start_dphase_asynch      ;
assign psb2plb_psbside_debug[81] = psb_mcsr_en_pulse             ;
assign psb2plb_psbside_debug[82] = psb_mcsr_en_pulse_d1          ;
assign psb2plb_psbside_debug[83] = psb_mcsr_en_pulse_d2          ;
assign psb2plb_psbside_debug[84] = plb_psb_access_tea_en         ;
assign psb2plb_psbside_debug[85] = plb_psb_access_tea_o          ;
assign psb2plb_psbside_debug[86] = PSBsl_ta_n_o                  ;
assign psb2plb_psbside_debug[87] = PSBsl_ta_n_en                 ;
assign psb2plb_psbside_debug[88] = PSBsl_d_en                    ;
assign psb2plb_psbside_debug[89] = PSBsl_tea_n_o                 ;
assign psb2plb_psbside_debug[90] = PSBsl_tea_n_en                ;
assign psb2plb_psbside_debug[91] = ufpga_ahit_sticky             ;
assign psb2plb_psbside_debug[92] = plb_ahit_sticky               ;
assign psb2plb_psbside_debug[93] = ufpga_ahit_outstanding        ;
assign psb2plb_psbside_debug[94] = psb_plb_wdata1_val            ;
assign psb2plb_psbside_debug[95] = psb_plb_wdata2_val            ;
assign psb2plb_psbside_debug[96] = psb_plb_wdata3_val            ;
assign psb2plb_psbside_debug[97] = psb_plb_wdata4_val            ;
assign psb2plb_psbside_debug[98] = psb_read_ta					 ;
assign psb2plb_psbside_debug[99] = psb_read_data_frame           ;

endmodule
