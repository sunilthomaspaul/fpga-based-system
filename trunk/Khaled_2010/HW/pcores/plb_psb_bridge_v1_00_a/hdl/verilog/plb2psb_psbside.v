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
*   The PSB control logic for the PLB2PSB Bridge.
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/plb2psb_psbside.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: plb2psb_psbside.v,v $
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
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
* Revision 1.2  2005/03/08 18:11:44  kuehner
* Added an internal copy of PSBma_br_n register to allow IOB OFF to be used.
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
This module provides control logic for the PSB side of the PLB2PSB bridge.
************************************************************************/

module plb2psb_psbside (
                      // Inputs
					   // System
					    clk	                    ,
					    reset	                ,

				       // PSB Master
					    PSBma_abb_n             ,
					    PSBma_dbb_n             ,
						PSBma_aack_n 			,
						PSBma_artry_n			,
						PSBma_d_i				,
						PSBma_ta_n				,
						PSBma_ta_n_unreg        ,
						PSBma_tea_n				,
						PSBma_tea_n_unreg       ,
						PSBma_bg_n              ,
						PSBma_dbg_n             ,
						PSBma_dbg_n_unreg		,
						PSBma_dbb_n_unreg		,
						PSBma_aack_n_unreg      ,
						PSBma_bg_n_unreg		,
						PSBma_abb_n_unreg		,
						PSBma_artry_n_unreg		,

					   // PLB Side
						plb_psb_start_access	,
						plb_psb_address     	,
						plb_psb_burst       	,
						plb_psb_tsiz        	,
						plb_psb_rnw         	,
						plb_psb_write_data1  	,
						plb_psb_write_data2		,
						plb_psb_write_data3		,
						plb_psb_write_data4		,
						accept_psb              ,

				      // OUTPUTS
				       // PSB Master
						PSBma_a_o      			,
						PSBma_a_en     			,
						PSBma_abb_n_o 			,
						PSBma_abb_n_en			,
						PSBma_dbb_n_o  			,
						PSBma_dbb_n_en 			,
						PSBma_d_o               ,
						PSBma_d_en              ,
						PSBma_tbst_n_o 			,
						PSBma_tbst_n_en			,
						PSBma_tsiz_o	 		,
						PSBma_tsiz_en  			,
						PSBma_ts_n_o	 		,
						PSBma_ts_n_en  			,
						PSBma_tt_o	 			,
						PSBma_tt_en	 			,
						PSBma_br_n              ,
			      
				       // PLB Side
					    psb_plb_read_data    	,
						psb_plb_read_data_val	,
						psb_plb_error        	,
						psb_plb_access_done  	,
						dont_aack_ps2           ,
						plb2psb_psbside_debug_bus           
                     );


/********************
* Module Parameters *
********************/

/*************
* Module I/O *
*************/
// Inputs
 // System
input                      clk					;
input                      reset				;

 // PSB Master
input                      PSBma_abb_n          ;
input                      PSBma_dbb_n          ;
input                      PSBma_aack_n 	   	;
input                      PSBma_artry_n	   	;
input [0:63]               PSBma_d_i		   	;
input                      PSBma_ta_n		   	;
input                      PSBma_ta_n_unreg     ;
input                      PSBma_tea_n		   	;
input                      PSBma_tea_n_unreg    ;
input                      PSBma_bg_n           ;
input                      PSBma_dbg_n          ;
input                      PSBma_dbg_n_unreg	;
input                      PSBma_dbb_n_unreg	;
input                      PSBma_aack_n_unreg   ;
input                      PSBma_bg_n_unreg		;
input                      PSBma_abb_n_unreg	;
input                      PSBma_artry_n_unreg	;

 // PLB Side
input                      plb_psb_start_access	;
input [0:31]               plb_psb_address     	;
input                      plb_psb_burst       	;
input [1:3]                plb_psb_tsiz        	;
input                      plb_psb_rnw         	;
input [0:63]               plb_psb_write_data1  ;
input [0:63]               plb_psb_write_data2  ;
input [0:63]               plb_psb_write_data3  ;
input [0:63]               plb_psb_write_data4  ;
input                      accept_psb           ;


// OUTPUTS
 // PSB Master
output [0:31]              PSBma_a_o      	   	;
output                     PSBma_a_en     	   	;
output					   PSBma_abb_n_o 		;
output					   PSBma_abb_n_en		;
output                     PSBma_dbb_n_o  	   	;
output                     PSBma_dbb_n_en 	   	;
output [0:63]              PSBma_d_o            ;
output                     PSBma_d_en           ;
output                     PSBma_tbst_n_o 	   	;
output                     PSBma_tbst_n_en	   	;
output [0:3]               PSBma_tsiz_o	 	   	;
output                     PSBma_tsiz_en  	   	;
output                     PSBma_ts_n_o	 	   	;
output                     PSBma_ts_n_en  	   	;
output [0:4]               PSBma_tt_o	 	   	;
output                     PSBma_tt_en	 	   	;
output reg                 PSBma_br_n           ; // synthesis attribute equivalent_register_removal of PSB_br_n is no

 // PLB Side
output [0:63]              psb_plb_read_data   	;
output                     psb_plb_read_data_val;
output                     psb_plb_error       	;
output                     psb_plb_access_done 	;
output reg                 dont_aack_ps2        ;

output wire [82:0]         plb2psb_psbside_debug_bus;

/*******************************
* Module Reg/Wire Declarations *
*******************************/
reg  PSBma_abb_n_en_s;// synthesis attribute equivalent_register_removal of PSBma_abb_n_en_s is no
reg  retry_occured;
reg  PSBma_br_n_int;  // synthesis attribute equivalent_register_removal of PSBma_br_n_int is no
wire qual_bg;
reg  PSBma_aack_n_s;
reg  qual_bg_s;


reg  PSBma_dbg_n_s;
reg  PSBma_dbg_n_sticky;
wire qual_dbg;
reg  PSBma_dbb_n_o_s;  // synthesis attribute equivalent_register_removal of PSBma_dbb_n_o_s is no
reg  PSBma_dbb_n_o_ss;

reg [0:1] PSBma_ta_cnt;
reg [0:1] PSBma_ta_unreg_cnt;
reg       deassert_dbb_no_error;
reg       deassert_dbb_no_error_reg;
reg[0:63] PSBma_d_o_reg;      // synthesis attribute equivalent_register_removal of PSBma_d_o_reg is no
reg[0:63] PSBma_d_o_prereg;
reg       PSBma_ts_n_en_reg;  // synthesis attribute equivalent_register_removal of PSBma_ts_n_en_reg is no
reg       PSBma_dbb_n_en_reg; // synthesis attribute equivalent_register_removal of PSBma_dbb_n_en_reg is no
reg       PSBma_abb_n_o_reg;  // synthesis attribute equivalent_register_removal of PSBma_abb_n_o_reg is no
reg       PSBma_d_en_reg;     // synthesis attribute equivalent_register_removal of PSBma_d_en_reg is no

reg       outward_access_frame;
wire      assert_d_en;

/********************************
* Module Logic      			*
********************************/
// create a frame signal that is high while outward accesses are taking place
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
        outward_access_frame <= 0;
	end

	else
	begin
	    if (plb_psb_start_access)
		    outward_access_frame <= 1;
		else if (psb_plb_access_done || psb_plb_error)
		    outward_access_frame <= 0;
		else
		    outward_access_frame <= outward_access_frame;
	end
end

// bus request logic (assert when starting access or after a retry occurred)			                  
always @(posedge clk or posedge reset)													                  
begin																					                  
    if (reset == 1)																		                  
	begin																				                  
		PSBma_abb_n_en_s  <= 0;															                  
	    retry_occured     <= 0;															                  
	    PSBma_br_n        <= 1;															                  
		PSBma_br_n_int    <= 1;															                  
	end																					                  
	else																				                  
	begin																				                  
		PSBma_abb_n_en_s  <= PSBma_abb_n_en;												              
																						                  
        if ( (PSBma_aack_n == 0) && (PSBma_artry_n_unreg == 0) && PSBma_abb_n_en_s)		                  
		    retry_occured <= 1;															                  
		else																			                  
		    retry_occured <= 0;															                  
																						                  
	    if (plb_psb_start_access || retry_occured)										                  
		begin																			                  
		    PSBma_br_n     <= 0;														                  
			PSBma_br_n_int <= 0;														                  
		end																				                  

		else if ( (PSBma_bg_n_unreg == 0) && (PSBma_abb_n_unreg == 1) && (PSBma_artry_n_unreg == 1) )	  
		// this access was accepted
		begin																			                  
		    PSBma_br_n     <= 1;														                  
			PSBma_br_n_int <= 1;													                      
		end																			                      

		else																			                  
		begin																			                  
            PSBma_br_n     <= PSBma_br_n;												                  
			PSBma_br_n_int <= PSBma_br_n_int;											                  
		end																				                  
	end																					                  
end																						                  
																						                  
// qualified bus grant																	                  
assign qual_bg = !PSBma_br_n_int & !PSBma_bg_n_unreg & PSBma_abb_n_unreg & PSBma_artry_n_unreg;			  

// Sample PSBma_aack_n (to determine when to tristate the abb signal)
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	    PSBma_aack_n_s <= 1;
	else
	    PSBma_aack_n_s <= PSBma_aack_n;
end

// Sample qual_bg (to determine when to tristate the ts signal)
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	    qual_bg_s <= 0;
	else
	    qual_bg_s <= qual_bg;
end

// Create a signal that gets asserted when the data phase has begun
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    PSBma_dbg_n_s      <= 1;
		PSBma_dbg_n_sticky <= 1;
	end
	else
	begin
	    PSBma_dbg_n_s <= PSBma_dbg_n;

        // PSBma_dbg_n_sticky is used if data bus grant is issued and db is still
		// busy from another ongoing access (this master must wait for data bus
		// to become idle).
        if ( (PSBma_dbg_n == 1'b0) && (PSBma_dbb_n == 1'b0) && (outward_access_frame == 1'b1) )
		// data bus is granted but data bus is still busy
            PSBma_dbg_n_sticky <= 0;
		else if ( (PSBma_dbb_n == 1'b1) || (outward_access_frame == 1'b0) )
            PSBma_dbg_n_sticky <= 1;
		else
		    PSBma_dbg_n_sticky <= PSBma_dbg_n_sticky;
	end																			 
end

// qualified databus grant
assign qual_dbg = !PSBma_dbg_n & PSBma_dbb_n & PSBma_artry_n & outward_access_frame;

// drive PSB databus
assign assert_d_en = !PSBma_dbg_n_unreg & PSBma_dbb_n_unreg & !plb_psb_rnw & outward_access_frame;	

// sample PSBma_dbb_n_o to determine when to tristate dbb signal
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    PSBma_dbb_n_o_s  <= 1;
		PSBma_dbb_n_o_ss <= 1;
	end
	else
	begin
	    PSBma_dbb_n_o_s  <= PSBma_dbb_n_o;
		PSBma_dbb_n_o_ss <= PSBma_dbb_n_o_s;
	end
end

// PSBma_ta_cnt
always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    PSBma_ta_cnt       <= 0;
		PSBma_ta_unreg_cnt <= 0;
	end
	else
	begin
	    if (PSBma_dbb_n_o == 1)
	        PSBma_ta_cnt <= 0;
		else if (PSBma_ta_n == 0)
		    PSBma_ta_cnt <= PSBma_ta_cnt + 1;
		else
		    PSBma_ta_cnt <= PSBma_ta_cnt;

        if (PSBma_dbb_n_o == 1)
		    PSBma_ta_unreg_cnt <= 0;
		else if (PSBma_ta_n_unreg == 0)
		    PSBma_ta_unreg_cnt <= PSBma_ta_unreg_cnt + 1;
		else
		    PSBma_ta_unreg_cnt <= PSBma_ta_unreg_cnt;
	 end
end

// deassert_dbb_no_error
always @(PSBma_tea_n_unreg or PSBma_ta_unreg_cnt or plb_psb_burst or PSBma_ta_n_unreg)
begin
    if ( ( (plb_psb_burst == 1) && (PSBma_ta_unreg_cnt == 3) && 
           (PSBma_ta_n_unreg == 0) && (PSBma_tea_n_unreg == 1) ) ||
		 ( (plb_psb_burst == 0) && (PSBma_ta_n_unreg == 0) &&
		   (PSBma_tea_n_unreg == 1)) )
	// finished access without error
	    deassert_dbb_no_error <= 1;
	else
	    deassert_dbb_no_error <= 0;
end

always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    PSBma_d_o_reg             <= 0;
		PSBma_abb_n_o_reg         <= 1; 
		PSBma_ts_n_en_reg         <= 0;
		PSBma_dbb_n_en_reg        <= 0;
		PSBma_d_en_reg            <= 0;
		deassert_dbb_no_error_reg <= 0;
	end
	else
	begin
	    PSBma_d_o_reg             <= PSBma_d_o_prereg;
		PSBma_abb_n_o_reg         <= PSBma_abb_n_o; 
		PSBma_ts_n_en_reg         <= PSBma_ts_n_en;
		PSBma_dbb_n_en_reg        <= PSBma_dbb_n_en; 
		PSBma_d_en_reg            <= PSBma_d_en;
		deassert_dbb_no_error_reg <= deassert_dbb_no_error;
	end
end

// PSBma_d_o_prereg
always @(PSBma_ta_unreg_cnt or PSBma_ta_n_unreg or plb_psb_write_data1 or plb_psb_write_data2 or 
         plb_psb_write_data3 or plb_psb_write_data4 or PSBma_d_o_reg)
begin
    if ( (PSBma_ta_unreg_cnt == 2'b00) && (PSBma_ta_n_unreg == 0) )
	    PSBma_d_o_prereg <= plb_psb_write_data2;
	else if (PSBma_ta_unreg_cnt == 2'b00)
	    PSBma_d_o_prereg <= plb_psb_write_data1;
	else if ( (PSBma_ta_unreg_cnt == 2'b01) && (PSBma_ta_n_unreg == 0) )
	    PSBma_d_o_prereg <= plb_psb_write_data3;
	else if ( (PSBma_ta_unreg_cnt == 2'b10) && (PSBma_ta_n_unreg == 0) )
	    PSBma_d_o_prereg <= plb_psb_write_data4;
	else
	    PSBma_d_o_prereg <= PSBma_d_o_reg;
end

always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	    dont_aack_ps2 <= 0;
	end
	else
	begin
	    if ( (PSBma_abb_n_o_reg == 0) && (plb_psb_rnw == 1) )
		// plb2psb_bridge has started PSB read access so dont aack any
		// PS2 accesses to the FPGA (to avoid lockup due to PS2 behavoiur)
    	    dont_aack_ps2 <= 1;
		else if (accept_psb == 1'b1)
		// plb2psb_bridge has obviously finished the access so it is safe to
		// aack the PS2
		    dont_aack_ps2 <= 0;
		else
		    dont_aack_ps2 <= dont_aack_ps2;
	end
end


// PSB Port Signals
assign PSBma_abb_n_en  = qual_bg ? 1 : (!PSBma_aack_n ? 0 : PSBma_abb_n_en_s);
assign PSBma_ts_n_en   = qual_bg ? 1 : (!qual_bg_s ? 0 : PSBma_ts_n_en_reg);
assign PSBma_a_en      = !PSBma_abb_n_o;
assign PSBma_tbst_n_en = !PSBma_abb_n_o;
assign PSBma_tsiz_en   = !PSBma_abb_n_o;
assign PSBma_tt_en     = !PSBma_abb_n_o;
assign PSBma_dbb_n_en  = (qual_dbg & !retry_occured & !deassert_dbb_no_error & PSBma_tea_n_unreg) ? 1 :
                         ( (deassert_dbb_no_error | !PSBma_tea_n_unreg | retry_occured) ? 0 : PSBma_dbb_n_en_reg);
assign PSBma_d_en      = (assert_d_en) ? 1 : ((deassert_dbb_no_error_reg | !PSBma_tea_n | retry_occured) ? 0 : PSBma_d_en_reg);

assign PSBma_abb_n_o  = qual_bg ? 0 : (!PSBma_aack_n_unreg ? 1 : PSBma_abb_n_o_reg);
assign PSBma_ts_n_o   = qual_bg ? 0 : 1;
assign PSBma_a_o      = plb_psb_address;
assign PSBma_tbst_n_o = ~plb_psb_burst;
assign PSBma_tsiz_o   = {1'b0, plb_psb_tsiz};
assign PSBma_tt_o     = plb_psb_rnw ? 5'b01010 : 5'b00010;
assign PSBma_dbb_n_o  = (qual_dbg & !retry_occured & !deassert_dbb_no_error & PSBma_tea_n_unreg) ? 0 :
                        ( (deassert_dbb_no_error | !PSBma_tea_n_unreg | retry_occured) ? 1 : PSBma_dbb_n_o_s);
assign PSBma_d_o      = PSBma_d_o_prereg;

// PSB to PLB Signal
assign psb_plb_read_data   	 = PSBma_d_i;
assign psb_plb_read_data_val = plb_psb_rnw ? (!PSBma_ta_n & !PSBma_dbb_n_o_ss & PSBma_tea_n) : 0;
assign psb_plb_error       	 = !PSBma_tea_n & !PSBma_dbb_n_o_ss;
assign psb_plb_access_done 	 = deassert_dbb_no_error_reg & !PSBma_dbb_n_o_ss;


assign plb2psb_psbside_debug_bus[0]  = reset				;
assign plb2psb_psbside_debug_bus[1]  = qual_bg			    ;
assign plb2psb_psbside_debug_bus[2]  = qual_dbg			    ;
assign plb2psb_psbside_debug_bus[3]  = deassert_dbb_no_error;
assign plb2psb_psbside_debug_bus[4]  = PSBma_dbb_n_o		;
assign plb2psb_psbside_debug_bus[5]  = PSBma_dbb_n_o_s	    ;
assign plb2psb_psbside_debug_bus[6]  = PSBma_ta_n		    ;
assign plb2psb_psbside_debug_bus[7]  = PSBma_dbg_n_sticky   ;
assign plb2psb_psbside_debug_bus[8]  = PSBma_aack_n		    ;
assign plb2psb_psbside_debug_bus[9]  = PSBma_dbb_n_en       ;  
assign plb2psb_psbside_debug_bus[10] = PSBma_br_n_int       ; 
assign plb2psb_psbside_debug_bus[11] = PSBma_dbb_n_en_reg   ;
assign plb2psb_psbside_debug_bus[12] = PSBma_dbg_n          ;
assign plb2psb_psbside_debug_bus[13] = PSBma_dbb_n          ;
assign plb2psb_psbside_debug_bus[14] = outward_access_frame ;
assign plb2psb_psbside_debug_bus[15] = PSBma_abb_n_o        ;
assign plb2psb_psbside_debug_bus[16] = PSBma_a_o[0] 	    ;
assign plb2psb_psbside_debug_bus[17] = PSBma_a_o[1] 	    ;
assign plb2psb_psbside_debug_bus[18] = PSBma_a_o[2] 	    ;
assign plb2psb_psbside_debug_bus[19] = PSBma_a_o[3] 	    ;
assign plb2psb_psbside_debug_bus[20] = PSBma_a_o[4] 	    ;
assign plb2psb_psbside_debug_bus[21] = PSBma_a_o[5] 	    ;
assign plb2psb_psbside_debug_bus[22] = PSBma_a_o[6] 	    ;
assign plb2psb_psbside_debug_bus[23] = PSBma_a_o[7] 	    ;
assign plb2psb_psbside_debug_bus[24] = PSBma_a_o[8] 	    ;
assign plb2psb_psbside_debug_bus[25] = PSBma_a_o[9] 	    ;
assign plb2psb_psbside_debug_bus[26] = PSBma_a_o[10]	    ;
assign plb2psb_psbside_debug_bus[27] = PSBma_a_o[11]	    ;
assign plb2psb_psbside_debug_bus[28] = PSBma_a_o[12]	    ;
assign plb2psb_psbside_debug_bus[29] = PSBma_a_o[13]	    ;
assign plb2psb_psbside_debug_bus[30] = PSBma_a_o[14]	    ;
assign plb2psb_psbside_debug_bus[31] = PSBma_a_o[15]	    ;
assign plb2psb_psbside_debug_bus[32] = PSBma_a_o[16]	    ;
assign plb2psb_psbside_debug_bus[33] = PSBma_a_o[17]	    ;
assign plb2psb_psbside_debug_bus[34] = PSBma_a_o[18]	    ;
assign plb2psb_psbside_debug_bus[35] = PSBma_a_o[19]	    ;
assign plb2psb_psbside_debug_bus[36] = PSBma_a_o[20]	    ;
assign plb2psb_psbside_debug_bus[37] = PSBma_a_o[21]	    ;
assign plb2psb_psbside_debug_bus[38] = PSBma_a_o[22]	    ;
assign plb2psb_psbside_debug_bus[39] = PSBma_a_o[23]	    ;
assign plb2psb_psbside_debug_bus[40] = PSBma_a_o[24]	    ;
assign plb2psb_psbside_debug_bus[41] = PSBma_a_o[25]	    ;
assign plb2psb_psbside_debug_bus[42] = PSBma_a_o[26]	    ;
assign plb2psb_psbside_debug_bus[43] = PSBma_a_o[27]	    ;
assign plb2psb_psbside_debug_bus[44] = PSBma_a_o[28]	    ;
assign plb2psb_psbside_debug_bus[45] = PSBma_a_o[29]	    ;
assign plb2psb_psbside_debug_bus[46] = PSBma_a_o[30]	    ;
assign plb2psb_psbside_debug_bus[47] = PSBma_a_o[31]	    ;
assign plb2psb_psbside_debug_bus[48] = PSBma_a_en		    ;
assign plb2psb_psbside_debug_bus[49] = PSBma_d_o[0] 	    ;
assign plb2psb_psbside_debug_bus[50] = PSBma_d_o[1] 	    ;
assign plb2psb_psbside_debug_bus[51] = PSBma_d_o[2] 	    ;
assign plb2psb_psbside_debug_bus[52] = PSBma_d_o[3] 	    ;
assign plb2psb_psbside_debug_bus[53] = PSBma_d_o[4] 	    ;
assign plb2psb_psbside_debug_bus[54] = PSBma_d_o[5] 	    ;
assign plb2psb_psbside_debug_bus[55] = PSBma_d_o[6] 	    ;
assign plb2psb_psbside_debug_bus[56] = PSBma_d_o[7] 	    ; 
assign plb2psb_psbside_debug_bus[57] = PSBma_d_o[56]	    ; 
assign plb2psb_psbside_debug_bus[58] = PSBma_d_o[57]	    ;
assign plb2psb_psbside_debug_bus[59] = PSBma_d_o[58]	    ;
assign plb2psb_psbside_debug_bus[60] = PSBma_d_o[59]	    ;
assign plb2psb_psbside_debug_bus[61] = PSBma_d_o[60]	    ;
assign plb2psb_psbside_debug_bus[62] = PSBma_d_o[61]	    ;
assign plb2psb_psbside_debug_bus[63] = PSBma_d_o[62]	    ;
assign plb2psb_psbside_debug_bus[64] = PSBma_d_o[63]	    ;
assign plb2psb_psbside_debug_bus[65] = PSBma_d_en           ;
assign plb2psb_psbside_debug_bus[66] = psb_plb_read_data_val;
assign plb2psb_psbside_debug_bus[67] = psb_plb_read_data[0] ;
assign plb2psb_psbside_debug_bus[68] = psb_plb_read_data[1] ;
assign plb2psb_psbside_debug_bus[69] = psb_plb_read_data[2] ;
assign plb2psb_psbside_debug_bus[70] = psb_plb_read_data[3] ;
assign plb2psb_psbside_debug_bus[71] = psb_plb_read_data[4] ;
assign plb2psb_psbside_debug_bus[72] = psb_plb_read_data[5] ;
assign plb2psb_psbside_debug_bus[73] = psb_plb_read_data[6] ;
assign plb2psb_psbside_debug_bus[74] = psb_plb_read_data[7] ;
assign plb2psb_psbside_debug_bus[75] = psb_plb_read_data[56];
assign plb2psb_psbside_debug_bus[76] = psb_plb_read_data[57];
assign plb2psb_psbside_debug_bus[77] = psb_plb_read_data[58];
assign plb2psb_psbside_debug_bus[78] = psb_plb_read_data[59];
assign plb2psb_psbside_debug_bus[79] = psb_plb_read_data[60];
assign plb2psb_psbside_debug_bus[80] = psb_plb_read_data[61];
assign plb2psb_psbside_debug_bus[81] = psb_plb_read_data[62];
assign plb2psb_psbside_debug_bus[82] = psb_plb_read_data[63];

endmodule
