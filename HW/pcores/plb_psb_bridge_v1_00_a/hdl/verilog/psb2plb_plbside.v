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
*   The PLB control logic for the PSB2PLB Bridge.
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/psb2plb_plbside.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: psb2plb_plbside.v,v $
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

This module provides control logic for the PLB side of the PSB2PLB bridge.
************************************************************************/

module psb2plb_plbside (
                      // Inputs
					   // System
					    clk	                    ,
					    reset	                ,

				       // PLB Master
					    PLBma_RdWdAddr    	    ,
					    PLBma_RdDBus      	    ,
					    PLBma_AddrAck     	    ,
					    PLBma_RdDAck      	    ,
					    PLBma_WrDAck      	    ,
					    PLBma_rearbitrate 	    ,
					    PLBma_Busy         	    ,
					    PLBma_Err         	    ,
					    PLBma_RdBTerm     	    ,
					    PLBma_WrBTerm     	    ,
					    PLBma_sSize       	    ,
					    PLBma_pendReq     	    ,
					    PLBma_pendPri     	    ,
					    PLBma_reqPri      	    ,

					   // PSB Side
					    psb_plb_start_access    ,
					    psb_plb_address         ,
					    psb_plb_burst           ,
					    psb_plb_tsiz            ,
					    psb_plb_rnw             ,
					    psb_plb_write_data      ,
					    psb_plb_wdata1_val      ,
					    psb_plb_wdata2_val      ,
					    psb_plb_wdata3_val      ,
					    psb_plb_wdata4_val      ,

				      // OUTPUTS
				       // PLB Master
				      	BGIma_request    		,
				      	BGIma_ABus       		,
				      	BGIma_RNW        		,
				      	BGIma_BE         		,
				      	BGIma_size       		,
				      	BGIma_type       		,
				      	BGIma_priority   		,
				      	BGIma_rdBurst    		,
				      	BGIma_wrBurst    		,
				      	BGIma_busLock    		,
				      	BGIma_abort      		,
				      	BGIma_lockErr    		,
				      	BGIma_mSize      		,
				      	BGIma_ordered    		,
				      	BGIma_compress   		,
				      	BGIma_guarded    		,
				      	BGIma_wrDBus	 		,
				      
				       // PSB Side
                        plb_psb_read_data       ,
				      	plb_psb_read_data_val   ,
				      	plb_psb_error           ,
				      	plb_psb_access_done     
                     );


/********************
* Module Parameters *
********************/
parameter    C_PLB_AWIDTH  = 32;
parameter    C_PLB_DWIDTH  = 64;
parameter    C_PLB_PRIORITY = 2'b00;


parameter    PLBM_RDY_FOR_REQ	 = 7'b000_0001;
parameter    PLBM_APHASE     	 = 7'b000_0010;
parameter    PLBM_DPHASE_WBURST	 = 7'b000_0100;
parameter    PLBM_DPHASE_RBURST	 = 7'b000_1000;
parameter    PLBM_DPHASE_WSINGLE = 7'b001_0000;
parameter    PLBM_DPHASE_RSINGLE = 7'b010_0000;
parameter    PLBM_COMPLETE_BURST = 7'b100_0000;

/*************
* Module I/O *
*************/
// Inputs
 // System
input                     clk			        ;
input                     reset			        ;

 // PLB Master
input [0:3]               PLBma_RdWdAddr        ; // not used
input [0:C_PLB_DWIDTH-1]  PLBma_RdDBus          ;
input                     PLBma_AddrAck         ;
input                     PLBma_RdDAck          ;
input                     PLBma_WrDAck          ;
input                     PLBma_rearbitrate     ; // not used
input                     PLBma_Busy            ; 
input                     PLBma_Err             ;
input                     PLBma_RdBTerm         ;
input                     PLBma_WrBTerm         ;
input [0:1]               PLBma_sSize           ; // not used
input                     PLBma_pendReq         ; // not used
input [0:1]               PLBma_pendPri         ; // not used
input [0:1]               PLBma_reqPri          ; // not used

 // PSB Side
input                     psb_plb_start_access  ;
input [0:31]              psb_plb_address       ;
input                     psb_plb_burst         ;
input [1:3]               psb_plb_tsiz          ;
input                     psb_plb_rnw           ;
input [0:63]              psb_plb_write_data    ;
input                     psb_plb_wdata1_val	;
input                     psb_plb_wdata2_val	;
input                     psb_plb_wdata3_val	;
input                     psb_plb_wdata4_val	;

// Outputs
 // PLB Master
output reg                         BGIma_request    ;
output wire [0:C_PLB_AWIDTH-1]     BGIma_ABus       ;
output wire                        BGIma_RNW        ;
output reg  [0:(C_PLB_DWIDTH/8)-1] BGIma_BE         ;
output wire [0:3]                  BGIma_size       ;
output wire [0:2]                  BGIma_type       ;
output wire [0:1]                  BGIma_priority   ;
output reg                         BGIma_rdBurst    ;
output reg                         BGIma_wrBurst    ;
output wire                        BGIma_busLock    ;
output wire                        BGIma_abort      ;
output wire                        BGIma_lockErr    ;
output wire [0:1]                  BGIma_mSize      ;
output wire                        BGIma_ordered    ;
output wire                        BGIma_compress   ;
output wire                        BGIma_guarded    ;
output reg  [0:C_PLB_DWIDTH-1]     BGIma_wrDBus	    ;

 // PSB Side
output reg [0:63]         plb_psb_read_data     ;
output reg				  plb_psb_read_data_val ;
output wire               plb_psb_error         ; // 'or' of plb_timeout_error and TBD
output wire                plb_psb_access_done   ;


/*******************************
* Module Reg/Wire Declarations *
*******************************/
reg [0:7]  single_access_be;
 // Write data holding registers
reg [0:63]                wdata_hold1;
reg [0:63]                wdata_hold2;
reg [0:63]                wdata_hold3;
reg [0:63]                wdata_hold4;

 // PLB FSM Signals
reg [6:0]                 plbm_state;
reg[1:0]                  num_WrDAcks;
reg[1:0]                  num_RdDAcks;
reg                       psb_plb_start_access_sticky;
reg                       psb_plb_wdata1_val_sticky;
reg                       psb_plb_wdata1_val_d1;

// Error registers
//reg                       PLB_timeout_error;
reg                       PLBma_Err_sticky;

reg                       plb_psb_write_access_done;
reg                       plb_write_timeout_error;
reg                       plb_psb_read_access_done;
reg                       plb_read_timeout_error;

/********************************
* Module Logic      			*
********************************/
// PSB Read data
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    plb_psb_read_data     <= 1'b0;
		plb_psb_read_data_val <= 1'b0;
	end
	else
	begin
	    plb_psb_read_data     <= (PLBma_RdDAck) ? PLBma_RdDBus : plb_psb_read_data;
		plb_psb_read_data_val <= PLBma_RdDAck;
	end
end

//assign plb_psb_read_data     = (PLBma_RdDAck) ? PLBma_RdDBus : plb_psb_read_data;
//assign plb_psb_read_data_val = PLBma_RdDAck;

// Write data holding registers and sticky bits
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
		wdata_hold1	<= 64'b0;
		wdata_hold2	<= 64'b0;
		wdata_hold3	<= 64'b0;
		wdata_hold4	<= 64'b0;
		psb_plb_wdata1_val_d1 <= 1'b0;
		psb_plb_wdata1_val_sticky   <= 1'b0;
		psb_plb_start_access_sticky <= 1'b0;
    end
	else
	begin
	    wdata_hold1	<= (psb_plb_wdata1_val) ? psb_plb_write_data : wdata_hold1;
		wdata_hold2	<= (psb_plb_wdata2_val) ? psb_plb_write_data : wdata_hold2;
		wdata_hold3	<= (psb_plb_wdata3_val) ? psb_plb_write_data : wdata_hold3;
		wdata_hold4	<= (psb_plb_wdata4_val) ? psb_plb_write_data : wdata_hold4;
		psb_plb_wdata1_val_d1 <= psb_plb_wdata1_val;
        if (psb_plb_wdata1_val)
		    psb_plb_wdata1_val_sticky <= 1'b1;
		else if (PLBma_WrDAck || PLBma_RdDAck)
		    psb_plb_wdata1_val_sticky <= 1'b0;
		else
		    psb_plb_wdata1_val_sticky <= psb_plb_wdata1_val_sticky;

		if (psb_plb_start_access)
		    psb_plb_start_access_sticky <= 1'b1;
		else if (PLBma_WrDAck || PLBma_RdDAck)
		    psb_plb_start_access_sticky <= 1'b0;
		else
		    psb_plb_start_access_sticky <= psb_plb_start_access_sticky;
	end
end


// PLB Write Data
always @(posedge clk or posedge reset)       
begin
    if (reset)
	begin
	    BGIma_wrDBus <= 64'b0;
	end
	else
	begin
	    if (psb_plb_wdata1_val_d1 == 1'b1)
		    BGIma_wrDBus <= wdata_hold1;
		else if (PLBma_WrDAck)
		begin
		    case (num_WrDAcks)
			// NOTE: the wdata_hold2, 3, 4 must be valid before we get
			//       the first PLBma_WrDAck back or else incorrect
			//       data will be presented on the PLB Write data bus
			2'b00: BGIma_wrDBus <= wdata_hold2;
			2'b01: BGIma_wrDBus <= wdata_hold3;
			2'b10: BGIma_wrDBus <= wdata_hold4;
			default: BGIma_wrDBus <= 64'b0;
			endcase
		end
		else
		    BGIma_wrDBus <= BGIma_wrDBus;
	end
end


//----------------------------------------------------------------
// PLB Master outputs that are tied off									  
//----------------------------------------------------------------
assign BGIma_abort    = 1'b0          ; // Never issue aborts			  
assign BGIma_busLock  = 1'b0          ; // Never lock bus				  
assign BGIma_compress = 1'b0          ; // Data is not compressed		  
assign BGIma_mSize    = 2'b01         ; // 64-bit data bus				  
assign BGIma_type     = 3'b000        ; // Memory transfers			  
assign BGIma_guarded  = 1'b0		  ; // Never guarded
assign BGIma_lockErr  = 1'b0		  ; // No lock errors
assign BGIma_ordered  = 1'b0		  ; // Not ordered
assign BGIma_priority = C_PLB_PRIORITY; // whatever is decided at compile time

//----------------------------------------------------------------
// PLB Master outputs that depend on state of psb_plb signals
//----------------------------------------------------------------
assign BGIma_ABus = psb_plb_address[0:31];
assign BGIma_RNW  = psb_plb_rnw; // Taken straight from PSB side
// Perform burst transfers of double words (4'b1011)
// Perform single access transfers of 1 to 8 bytes if not bursting (4'b0000)
assign BGIma_size = (psb_plb_burst) ? 4'b1011 : 4'b0000;
always @(psb_plb_address[29:31] or psb_plb_tsiz[1:3] or psb_plb_burst or
         single_access_be)
begin
    if (psb_plb_burst == 1'b1)
	    BGIma_BE <= 8'h30;
	else
	    BGIma_BE <= single_access_be;

    case (psb_plb_tsiz[1:3])
    3'b001:
	begin
	    case (psb_plb_address[29:31])
		3'b000 : single_access_be <= 8'b1000_0000; 
		3'b001 : single_access_be <= 8'b0100_0000; 
		3'b010 : single_access_be <= 8'b0010_0000; 
		3'b011 : single_access_be <= 8'b0001_0000; 
		3'b100 : single_access_be <= 8'b0000_1000; 
		3'b101 : single_access_be <= 8'b0000_0100; 
		3'b110 : single_access_be <= 8'b0000_0010; 
		3'b111 : single_access_be <= 8'b0000_0001; 
		default: single_access_be <= 8'b0000_0000; 
		endcase
	end

    3'b010:
	begin
	    case (psb_plb_address[29:31])
		3'b000 : single_access_be <= 8'b1100_0000; 
		3'b001 : single_access_be <= 8'b0110_0000; 
		3'b010 : single_access_be <= 8'b0011_0000; 
		3'b011 : single_access_be <= 8'b0001_1000; 
		3'b100 : single_access_be <= 8'b0000_1100; 
		3'b101 : single_access_be <= 8'b0000_0110; 
		3'b110 : single_access_be <= 8'b0000_0011; 
		default: single_access_be <= 8'b0000_0000; 
		endcase
	end

    3'b011:
	begin
	    case (psb_plb_address[29:31])
		3'b000 : single_access_be <= 8'b1110_0000; 
		3'b001 : single_access_be <= 8'b0111_0000; 
		3'b010 : single_access_be <= 8'b0011_1000; 
		3'b011 : single_access_be <= 8'b0001_1100; 
		3'b100 : single_access_be <= 8'b0000_1110; 
		3'b101 : single_access_be <= 8'b0000_0111; 
		default: single_access_be <= 8'b0000_0000; 
		endcase
	end

    3'b100:
	begin
	    case (psb_plb_address[29:31])
 		3'b000 : single_access_be <= 8'b1111_0000; 
		3'b001 : single_access_be <= 8'b0111_1000; 
		3'b010 : single_access_be <= 8'b0011_1100; 
		3'b011 : single_access_be <= 8'b0001_1110; 
		3'b100 : single_access_be <= 8'b0000_1111; 
 		default: single_access_be <= 8'b0000_0000; 
		endcase
	end

    3'b101:
	begin
	    case (psb_plb_address[29:31])
 		3'b000 : single_access_be <= 8'b1111_1000; 
		3'b001 : single_access_be <= 8'b0111_1100; 
		3'b010 : single_access_be <= 8'b0011_1110; 
		3'b011 : single_access_be <= 8'b0001_1111; 
 		default: single_access_be <= 8'b0000_0000; 
		endcase
	end

    3'b110:
	begin
	    case (psb_plb_address[29:31])
 		3'b000 : single_access_be <= 8'b1111_1100; 
		3'b001 : single_access_be <= 8'b0111_1110; 
		3'b010 : single_access_be <= 8'b0011_1111; 
 		default: single_access_be <= 8'b0000_0000; 
		endcase
	end

    3'b111:
	begin
	    case (psb_plb_address[29:31])
 		3'b000 : single_access_be <= 8'b1111_1110; 
		3'b001 : single_access_be <= 8'b0111_1111; 
 		default: single_access_be <= 8'b0000_0000; 
		endcase
	end

    default:
	begin
	    single_access_be <= 8'b1111_1111;
	end
	endcase
end 

/******************************************************************************
* plb_psb_error logic
*  Possible ways that PLBma_Err can be asserted:
*   1. by slave for some reason (in this case it should be qualified with 
*      PLBma_Busy)
*   2. by PLB arbiter if no slave acknowledges the address phase (the arbiter will
*      terminate the access with PLBma_RdDAcks or PLBma_WrDAcks along with PLBma_Err)
*
*
******************************************************************************/

// plb_psb_error logic
always @(posedge clk or posedge reset)       
begin
    if (reset)
    begin
	    PLBma_Err_sticky <= 0;
	end
	else
	begin
	    if ((PLBma_Err & PLBma_Busy) || (PLBma_Err & PLBma_AddrAck) )
		// set the sticky bit if there is an error while the slave is busy
		// (or if there is an error during the AddrAck stage - I did not think
		// it was legal for the slave to do this but the PLB Slave BFM does it
		// so better to be safe)
	        PLBma_Err_sticky <= 1;
		else if (PLBma_AddrAck == 1)
		// clear the sticky bit at the start of the next access
	        PLBma_Err_sticky <= 0;
		else
		    PLBma_Err_sticky <= PLBma_Err_sticky;
	end
end


assign plb_psb_error = plb_write_timeout_error | plb_read_timeout_error | 
                       PLBma_Err_sticky | (PLBma_Err & PLBma_Busy);

/******************************************************************************
* PLB Master FSM
* outputs
*  	 BGIma_request
*	 BGIma_rdBurst
*	 BGIma_wrBurst
*
*    PLB_timeout_error  
*	 plb_psb_access_done
******************************************************************************/
always @(posedge clk or posedge reset)       
begin
    if (reset)
    begin
	    BGIma_request <= 0;
		BGIma_wrBurst <= 0;
		BGIma_rdBurst <= 0;

	    num_WrDAcks   <= 0;
		num_RdDAcks   <= 0;

		//PLB_timeout_error   <= 0;
		//plb_psb_access_done <= 0;

	    plbm_state <= PLBM_RDY_FOR_REQ;
    end

    else
    begin
		//PLB_timeout_error   <= 0;
		//plb_psb_access_done <= 0;

        case (plbm_state)
		/*********************************************************************	  
		* State 1: PLBM_RDY_FOR_REQ
		*             This state waits for a request from the psb2plb_psbside.
		*             Upon receiving a request, this state issues a request
		*             for the PLB bus.									  
		*********************************************************************/	  
        PLBM_RDY_FOR_REQ:
        begin
		    num_WrDAcks     <= 0;
			num_RdDAcks     <= 0;

			if ( (psb_plb_start_access || psb_plb_start_access_sticky) &&
			     ( (psb_plb_rnw == 1) || (psb_plb_wdata1_val_d1 || psb_plb_wdata1_val_sticky) )
			   )
			// psb2plb_psbside is requesting a PLB access and either:
			//  1. it is a read so the PSB data bus does not yet have to be granted, or
			//  2. it is a write access and the PSB data bus has been granted.
			begin
			    BGIma_request <= 1;
				BGIma_wrBurst <= psb_plb_burst & (~psb_plb_rnw);
				BGIma_rdBurst <= psb_plb_burst & psb_plb_rnw;
				plbm_state    <= PLBM_APHASE;
			end
			else
			begin
			    BGIma_request <= 0;
				BGIma_wrBurst <= 0;
				BGIma_rdBurst <= 0;
				plbm_state    <= PLBM_RDY_FOR_REQ;
			end
		end

		/*********************************************************************	  
		* State 2: PLBM_APHASE															
		*             This state waits until the PLB bus has been				
		*             granted to the master and the slave has acknowledged		
		*             acceptance of the access with PLB_AddrAck. Once			
		*             the slave has accepted the access, this state				
		*             deasserts BGIma_request along with various other PLB signals.
		*********************************************************************/	  
        PLBM_APHASE:
        begin
			BGIma_wrBurst <= BGIma_wrBurst;
			BGIma_rdBurst <= BGIma_rdBurst;

            num_WrDAcks <= PLBma_WrDAck ? 2'b01 : 2'b00;
            num_RdDAcks <= PLBma_RdDAck ? 2'b01 : 2'b00;

		    if (PLBma_AddrAck)
			begin
		        BGIma_request <= 0;
				if ( (psb_plb_rnw == 0) && (psb_plb_burst == 1) )
				// burst write
				    plbm_state <= PLBM_DPHASE_WBURST;

				else if ( (psb_plb_rnw == 1) && (psb_plb_burst == 1) )
				// burst read
			        plbm_state <= PLBM_DPHASE_RBURST;

				else if ( (psb_plb_rnw == 0) && (psb_plb_burst == 0) )
				// single write
				    if (PLBma_WrDAck)
					    plbm_state <= PLBM_RDY_FOR_REQ;
					else
				        plbm_state <= PLBM_DPHASE_WSINGLE;
				else
				// single read
				    if (PLBma_RdDAck)
					    plbm_state <= PLBM_RDY_FOR_REQ;
					else
				        plbm_state <= PLBM_DPHASE_RSINGLE;
			end

			else
			begin
		        BGIma_request <= 1;
			    plbm_state    <= PLBM_APHASE;
			end
		end

		/*********************************************************************	  
		* State 3: PLBM_DPHASE_WBURST
        *             This state monitors PLB_WrDAck and places next 64-bits	
        *             of data on BGIma_wrDBus when necessary. After the 3rd		
        *             PLB_WrDAck or upon detection of PLB_wrBTerm, BGIma_wrBurst	
        *             is deasserted and this state is exited.				
		*********************************************************************/	  
        PLBM_DPHASE_WBURST:
        begin
	        BGIma_request <= 0;
			BGIma_rdBurst <= 0;

            num_WrDAcks <= PLBma_WrDAck ? (num_WrDAcks + 1) : num_WrDAcks;

            if ((PLBma_WrDAck && (num_WrDAcks[1] == 1)) || (PLBma_WrBTerm))
			// the 3rd PLBma_WrDAck has just occurred or the slave
			// is ending the burst so must deassert BGIma_wrBurst
			begin
			    BGIma_wrBurst <= 0;
				plbm_state    <= PLBM_COMPLETE_BURST;
			end
			else
			begin
			    BGIma_wrBurst <= 1;
				plbm_state    <= PLBM_DPHASE_WBURST;
			end
		end

		/*********************************************************************	  
		* State 4: PLBM_DPHASE_RBURST
		*             This state monitors PLB_RdAck to determine when
		*             to deassert BGIma_rdBurst. After the 3rd
		*             PLB_RdAck or upon detection of PLB_RdBTerm,
		*             BGIma_rdBurst is deasserted and this state is
		*             exited.
		*********************************************************************/	  
        PLBM_DPHASE_RBURST:
        begin
	        BGIma_request <= 0;
			BGIma_wrBurst <= 0;

			num_RdDAcks <= PLBma_RdDAck ? (num_RdDAcks + 1) : num_RdDAcks;

            if ((PLBma_RdDAck && (num_RdDAcks[1] == 1)) || (PLBma_RdBTerm))
			// the 3rd PLBma_RdDAck has just occurred or the slave
			// is ending the burst so must deassert BGIma_rdBurst
			begin
			    BGIma_rdBurst <= 0;
				plbm_state    <= PLBM_COMPLETE_BURST;
			end
			else
			begin
			    BGIma_rdBurst <= 1;
				plbm_state    <= PLBM_DPHASE_RBURST;
			end
		end

		/*********************************************************************	  
		* State 5: PLBM_DPHASE_WSINGLE
		*             This state monitors PLBma_WrDAck and when so, this state is
		*             exited.
		*********************************************************************/	  
        PLBM_DPHASE_WSINGLE:
        begin
	        BGIma_request <= 0;
		    BGIma_wrBurst <= 0;
		    BGIma_rdBurst <= 0;
		    
	        num_WrDAcks   <= 0;
		    num_RdDAcks   <= 0;

			if (PLBma_WrDAck)
			// The write ack has been received
			begin
		        //PLB_timeout_error   <= PLBma_Err;
			    //plb_psb_access_done <= 1;
			    plbm_state          <= PLBM_RDY_FOR_REQ;
			end
			else
			begin
		        //PLB_timeout_error   <= 0;
			    //plb_psb_access_done <= 0;
			    plbm_state          <= PLBM_DPHASE_WSINGLE;
			end
		end

		/*********************************************************************	  
		* State 6: PLBM_DPHASE_RSINGLE
		*             This state monitors PLBma_RdDAck and when so, this state is
		*             exited.
		*********************************************************************/	  
        PLBM_DPHASE_RSINGLE:
        begin
	        BGIma_request <= 0;
		    BGIma_wrBurst <= 0;
		    BGIma_rdBurst <= 0;
		    
	        num_WrDAcks   <= 0;
		    num_RdDAcks   <= 0;

			if (PLBma_RdDAck)
			// The read ack has been received
			begin
		        //PLB_timeout_error   <= PLBma_Err;
			    //plb_psb_access_done <= 1;
			    plbm_state          <= PLBM_RDY_FOR_REQ;
			end
			else
			begin
		        //PLB_timeout_error   <= 0;
			    //plb_psb_access_done <= 0;
			    plbm_state          <= PLBM_DPHASE_RSINGLE;
			end
		end

		/*********************************************************************	  
		* State 6: PLBM_COMPLETE_BURST													
		*             This state waits for assertion of PLB_RdAck or PLB_Wrack
		*             which	indicates that the PLB access has completed. It then
		*		      moves back to the PLBM_RDY_FOR_REQ state.			
		*********************************************************************/	  
        PLBM_COMPLETE_BURST:
        begin
		    BGIma_request <= 0;
			BGIma_wrBurst <= 0;
			BGIma_rdBurst <= 0;

			num_WrDAcks <= num_WrDAcks;
			num_RdDAcks <= num_RdDAcks;

            //if ( (PLBma_WrDAck || PLBma_RdDAck) & PLBma_Err)
			    //PLB_timeout_error <= 1;
			//else
			    //PLB_timeout_error <= 0;

			if (PLBma_WrDAck || PLBma_RdDAck)
			// The final DAck (write or read) has been received
			begin
			    //plb_psb_access_done <= 1;
			    plbm_state          <= PLBM_RDY_FOR_REQ;
			end
			else
			begin
			    //plb_psb_access_done <= 0;
			    plbm_state          <= PLBM_COMPLETE_BURST;
			end
		end

        /*********************************************************************
        * Default State
        *********************************************************************/
        default:
        begin
            plbm_state <= PLBM_RDY_FOR_REQ;
        end
        endcase
	end
end

always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	   plb_psb_write_access_done <= 0;
	   plb_write_timeout_error   <= 0;
	end

    else if ( ((plbm_state == PLBM_COMPLETE_BURST) && PLBma_WrDAck) ||
	   	      ((plbm_state == PLBM_DPHASE_WSINGLE) && PLBma_WrDAck) ||
		      ((plbm_state == PLBM_APHASE) && (psb_plb_burst == 0) && PLBma_WrDAck)
	   )
	begin
	   plb_psb_write_access_done <= 1;
	   plb_write_timeout_error   <= PLBma_Err;
	end

	else
	begin
	   plb_psb_write_access_done <= 0;
	   plb_write_timeout_error   <= 0;
	end
end

always @(posedge clk or posedge reset)
begin
    if (reset == 1)
	begin
	   plb_psb_read_access_done <= 0;
	   plb_read_timeout_error   <= 0;
	end

    else if ( ((plbm_state == PLBM_COMPLETE_BURST) && PLBma_RdDAck) ||
	   	 ((plbm_state == PLBM_DPHASE_RSINGLE) && PLBma_RdDAck) ||
		 ((plbm_state == PLBM_APHASE) && (psb_plb_burst == 0) && PLBma_RdDAck)
	   )
	begin
	   plb_psb_read_access_done <= 1;
	   plb_read_timeout_error   <= PLBma_Err;
	end

	else
	begin
	   plb_psb_read_access_done <= 0;
	   plb_read_timeout_error   <= 0;
	end
end

assign plb_psb_access_done = plb_psb_write_access_done | plb_psb_read_access_done;

endmodule
