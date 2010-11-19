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
*   Top level file of the PSB2PLB Bridge.
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/psb2plb_bridge.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: psb2plb_bridge.v,v $
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.4  2005/07/19 17:36:04  kuehner
* Bridge now passes 0 - 2FFFFFFF through to PLB bus (for flash/cpld accesses).
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
This module instantiates the psb2plb_psbside and the psb2plb_plbside modules.

** Port Declaration
** Definition of Generics:
**
** Definition of Ports:
**  clk             - bridge clock
**  reset           - bridge reset
**
**  PSBsl_aack_n	- --
**  PSBsl_artry_n	-   |
**  PSBsl_a			-   |
**  PSBsl_dbb_n	    -   |
**  PSBsl_d			-   |
**  PSBsl_ta_n		-   |-- PSB slave interface signals
**  PSBsl_tbst_n	-   |
**  PSBsl_tea_n		-	|
**  PSBsl_tsiz		-	|
**  PSBsl_ts_n		-	|
**  PSBsl_tt		- --
**
**  BGI_request     - --
**  BGI_ABus        -   |
**  BGI_RNW         -   |
**  BGI_BE          -   |
**  BGI_size        -   |
**  BGI_type        -   |
**  BGI_priority    -   |
**  BGI_rdBurst     -   |
**  BGI_wrBurst     -   |
**  BGI_busLock     -   |
**  BGI_abort       -   |
**  BGI_lockErr     -   |
**  BGI_mSize       -   |
**  BGI_ordered     -   |
**  BGI_compress    -   |-- PLB master interface signals
-*  BGI_guarded     -   |
**  BGI_wrDBus      -   |
**  PLB_RdWdAddr    -   |
**  PLB_RdDBus      -   |
**  PLB_AddrAck     -   |
**  PLB_RdDAck      -   |
**  PLB_WrDAck      -   |
**  PLB_rearbitrate -   |
**  PLB_Busy        -   |
**  PLB_Err         -   |
**  PLB_RdBTerm     -   |
**  PLB_WrBTerm     -   |
**  PLB_sSize       -   |
**  PLB_pendReq     -   |
**  PLB_pendPri     -   |
**  PLB_reqPri      - --
**
*******************************************************************************

************************************************************************/

module psb2plb_bridge (
                     // Inputs
					  // System
						clk				  ,
						reset			  ,

					  // PSB Slave
						PSBsl_a			  ,	 // already registered
						PSBsl_d_i		  ,	 // already registered
						PSBsl_dbb_n       ,  // already registered
						PSBsl_tbst_n	  ,	 // already registered
						PSBsl_tsiz		  ,	 // already registered
						PSBsl_ts_n		  ,	 // already registered
						PSBsl_tt		  ,	 // already registered

                      // PLB Master
						PLBma_RdWdAddr    ,
						PLBma_RdDBus      ,
						PLBma_AddrAck     ,
						PLBma_RdDAck      ,
						PLBma_WrDAck      ,
						PLBma_rearbitrate ,
						PLBma_Busy        ,
						PLBma_Err         ,
						PLBma_RdBTerm     ,
						PLBma_WrBTerm     ,
						PLBma_sSize       ,
						PLBma_pendReq     ,
						PLBma_pendPri     ,
						PLBma_reqPri      ,

                      // MCSR
					    mcsr_psb_read_data,

                      // PLB2PSB bridge
                        accept_psb        ,
						dont_aack_ps2     ,

                     // Outputs
					  // PSB Slave
						PSBsl_aack_n_o	  ,
						PSBsl_aack_n_en	  ,
						PSBsl_artry_n_o	  ,
						PSBsl_artry_n_en  ,
						PSBsl_d_o		  ,	
						PSBsl_d_en		  ,
						PSBsl_ta_n_o	  ,	
						PSBsl_ta_n_en	  ,	
						PSBsl_tea_n_o	  ,	
						PSBsl_tea_n_en	  ,

                      // PLB Master
						BGIma_request 	  ,
						BGIma_ABus    	  ,
						BGIma_RNW     	  ,
						BGIma_BE      	  ,
						BGIma_size    	  ,
						BGIma_type    	  ,
						BGIma_priority	  ,
						BGIma_rdBurst 	  ,
						BGIma_wrBurst 	  ,
						BGIma_busLock 	  ,
						BGIma_abort   	  ,
						BGIma_lockErr 	  ,
						BGIma_mSize   	  ,
						BGIma_ordered 	  ,
						BGIma_compress	  ,
						BGIma_guarded 	  ,
						BGIma_wrDBus	  ,

                      // PLB2PSB Bridge
                        accept_plb         ,

                      // MCSR
 					    psb_mcsr_rd_en_pulse, 
 					    psb_mcsr_wr_en_pulse, 
 					    psb_mcsr_addr       , 
 					    psb_mcsr_write_data ,
 					    
 					    psb2plb_psbside_debug   
                      );


/********************
* Module Parameters *
********************/
// Parameters for psb2plb_plbside
parameter C_PLB_AWIDTH   = 32;
parameter C_PLB_DWIDTH   = 64;
parameter C_PLB_PRIORITY = 2'b00;

// Parameters for psb2plb_psbside
parameter PLB_PSB_FPGA_REG_BASEADDR   = 32'h3000_2000; // 0x30002000 - 0x30003FFF
parameter PLB_PSB_FPGA_REG_LSB_DECODE = 18;
parameter PLB_MASTER_BASEADDR1        = 32'h0000_0000; // 0x00000000 - 0x1FFFFFFF
parameter PLB_MASTER_LSB_DECODE1      = 2;
parameter PLB_MASTER_BASEADDR2        = 32'h2000_0000; // 0x20000000 - 0x2FFFFFFF
parameter PLB_MASTER_LSB_DECODE2      = 3;

/*************
* Module I/O *
*************/
// Inputs
 // System
input                     clk			    ;
input                     reset			    ;

 // PSB Slave
input [0:31]              PSBsl_a		    ;	 
input [0:63]              PSBsl_d_i		    ;
input                     PSBsl_dbb_n       ;
input                     PSBsl_tbst_n	    ;
input [1:3]               PSBsl_tsiz	    ;
input                     PSBsl_ts_n	    ;
input [0:4]               PSBsl_tt		    ;

 // PLB Master
input [0:3]               PLBma_RdWdAddr    ;
input [0:C_PLB_DWIDTH-1]  PLBma_RdDBus      ;
input                     PLBma_AddrAck     ;
input                     PLBma_RdDAck      ;
input                     PLBma_WrDAck      ;
input                     PLBma_rearbitrate ;
input                     PLBma_Busy        ; 
input                     PLBma_Err         ;
input                     PLBma_RdBTerm     ;
input                     PLBma_WrBTerm     ;
input [0:1]               PLBma_sSize       ;
input                     PLBma_pendReq     ;
input [0:1]               PLBma_pendPri     ;
input [0:1]               PLBma_reqPri      ;

 // MCSR
input [0:63]              mcsr_psb_read_data;

 // PLB2PSB Bridge
input                     accept_psb        ;
input                     dont_aack_ps2     ;

// Outputs
 // PSB Slave
output                    PSBsl_aack_n_o   ;
output                    PSBsl_aack_n_en  ;
output                    PSBsl_artry_n_o  ;
output                    PSBsl_artry_n_en ;
output [0:63]             PSBsl_d_o		   ;
output                    PSBsl_d_en	   ;
output                    PSBsl_ta_n_o	   ;
output                    PSBsl_ta_n_en	   ;
output                    PSBsl_tea_n_o	   ;
output                    PSBsl_tea_n_en   ;

 // PLB Master
output                        BGIma_request    ;
output [0:C_PLB_AWIDTH-1]     BGIma_ABus       ;
output                        BGIma_RNW        ;
output [0:(C_PLB_DWIDTH/8)-1] BGIma_BE         ;
output [0:3]                  BGIma_size       ;
output [0:2]                  BGIma_type       ;
output [0:1]                  BGIma_priority   ;
output                        BGIma_rdBurst    ;
output                        BGIma_wrBurst    ;
output                        BGIma_busLock    ;
output                        BGIma_abort      ;
output                        BGIma_lockErr    ;
output [0:1]                  BGIma_mSize      ;
output                        BGIma_ordered    ;
output                        BGIma_compress   ;
output                        BGIma_guarded    ;
output [0:C_PLB_DWIDTH-1]     BGIma_wrDBus	   ;

 // PLB2PSB Bridge
output                    accept_plb       ;

 // MCSR
output                                           psb_mcsr_rd_en_pulse; 
output                                           psb_mcsr_wr_en_pulse; 
output wire	[(PLB_PSB_FPGA_REG_LSB_DECODE+1):31] psb_mcsr_addr       ; 
output [0:31]                                    psb_mcsr_write_data ; 

output [99:0]             psb2plb_psbside_debug; 
/********************************
* Internal wires and registers  *
********************************/
// outputs from psb2plb_psbside (inputs to psb2plb_plbside)
wire	     psb_plb_start_access   ;
wire [0:31]  psb_plb_address        ;
wire         psb_plb_burst          ;
wire [1:3]   psb_plb_tsiz           ;
wire	     psb_plb_rnw            ;
wire [0:63]  psb_plb_write_data     ;
wire		 psb_plb_wdata1_val     ;
wire		 psb_plb_wdata2_val     ;
wire		 psb_plb_wdata3_val     ;
wire		 psb_plb_wdata4_val     ;

// outputs from psb2plb_plbside (inputs to psb2plb_psbside)
wire [0:63]  plb_psb_read_data      ;
wire         plb_psb_read_data_val  ;
wire         plb_psb_error          ;
wire         plb_psb_access_done    ;

/********************************
* Module Instantiations			*
********************************/
defparam psb2plb_psbside.PLB_PSB_FPGA_REG_BASEADDR   = PLB_PSB_FPGA_REG_BASEADDR;
defparam psb2plb_psbside.PLB_PSB_FPGA_REG_LSB_DECODE = PLB_PSB_FPGA_REG_LSB_DECODE;
defparam psb2plb_psbside.PLB_MASTER_BASEADDR1        = PLB_MASTER_BASEADDR1;
defparam psb2plb_psbside.PLB_MASTER_LSB_DECODE1      = PLB_MASTER_LSB_DECODE1;
defparam psb2plb_psbside.PLB_MASTER_BASEADDR2        = PLB_MASTER_BASEADDR2;
defparam psb2plb_psbside.PLB_MASTER_LSB_DECODE2      = PLB_MASTER_LSB_DECODE2;

	psb2plb_psbside	psb2plb_psbside (
	               // INPUTS
					// System
					 .clk	                 (clk		  		     ),
					 .reset	                 (reset	  			     ),

                    // PSB slave
					 .PSBsl_a		         (PSBsl_a        	     ),
					 .PSBsl_d_i	             (PSBsl_d_i  		     ),
					 .PSBsl_dbb_n            (PSBsl_dbb_n            ),
					 .PSBsl_tbst_n	         (PSBsl_tbst_n		     ),
					 .PSBsl_tsiz	         (PSBsl_tsiz[1:3]	     ),
					 .PSBsl_ts_n	         (PSBsl_ts_n 		     ),
					 .PSBsl_tt		         (PSBsl_tt	  		     ),

                    // MCSR
                     .mcsr_psb_read_data     (mcsr_psb_read_data     ),
                   
                    // PLB Side
                     .plb_psb_read_data      (plb_psb_read_data      ),
					 .plb_psb_read_data_val  (plb_psb_read_data_val  ),
					 .plb_psb_error          (plb_psb_error          ),
					 .plb_psb_access_done    (plb_psb_access_done    ),

                    // plb2psb bridge
					 .accept_psb             (accept_psb             ),
					 .dont_aack_ps2          (dont_aack_ps2          ),

				   // OUTPUTS
					// PSB Slave
					 .PSBsl_aack_n_o         (PSBsl_aack_n_o         ),
					 .PSBsl_aack_n_en        (PSBsl_aack_n_en        ),
					 .PSBsl_artry_n_o        (PSBsl_artry_n_o        ),
					 .PSBsl_artry_n_en       (PSBsl_artry_n_en       ),
					 .PSBsl_ta_n_o	         (PSBsl_ta_n_o           ),	
					 .PSBsl_ta_n_en	         (PSBsl_ta_n_en          ),	
					 .PSBsl_d_o		         (PSBsl_d_o     	     ),	
					 .PSBsl_d_en		     (PSBsl_d_en             ),
					 .PSBsl_tea_n_o	         (PSBsl_tea_n_o	         ),	
					 .PSBsl_tea_n_en	     (PSBsl_tea_n_en         ),

					// MCSR
					 .psb_mcsr_rd_en_pulse   (psb_mcsr_rd_en_pulse   ),
					 .psb_mcsr_wr_en_pulse   (psb_mcsr_wr_en_pulse   ),
					 .psb_mcsr_addr          (psb_mcsr_addr          ),
					 .psb_mcsr_write_data    (psb_mcsr_write_data    ),

                     .accept_plb             (accept_plb             ),

                    // PLB Side
					 .psb_plb_start_access   (psb_plb_start_access   ),
					 .psb_plb_address        (psb_plb_address        ),
					 .psb_plb_burst          (psb_plb_burst          ),
					 .psb_plb_tsiz           (psb_plb_tsiz           ),
					 .psb_plb_rnw            (psb_plb_rnw            ),
					 .psb_plb_write_data     (psb_plb_write_data     ),
					 .psb_plb_wdata1_val     (psb_plb_wdata1_val	 ),
					 .psb_plb_wdata2_val     (psb_plb_wdata2_val	 ),
					 .psb_plb_wdata3_val     (psb_plb_wdata3_val	 ),
					 .psb_plb_wdata4_val     (psb_plb_wdata4_val	 ),

                     .psb2plb_psbside_debug  (psb2plb_psbside_debug  )
	);																  
																	  
defparam psb2plb_plbside.C_PLB_AWIDTH   = C_PLB_AWIDTH;
defparam psb2plb_plbside.C_PLB_DWIDTH   = C_PLB_DWIDTH;
defparam psb2plb_plbside.C_PLB_PRIORITY = C_PLB_PRIORITY;

	psb2plb_plbside	psb2plb_plbside (
	               // INPUTS
					// System
					 .clk	                 (clk		  		     ),
					 .reset	                 (reset	  			     ),

				    // PLB Master
					 .PLBma_RdWdAddr    	 (PLBma_RdWdAddr   		 ),
					 .PLBma_RdDBus      	 (PLBma_RdDBus     		 ),
					 .PLBma_AddrAck     	 (PLBma_AddrAck    		 ),
					 .PLBma_RdDAck      	 (PLBma_RdDAck     		 ),
					 .PLBma_WrDAck      	 (PLBma_WrDAck     		 ),
					 .PLBma_rearbitrate 	 (PLBma_rearbitrate		 ),
					 .PLBma_Busy         	 (PLBma_Busy       		 ),
					 .PLBma_Err         	 (PLBma_Err        		 ),
					 .PLBma_RdBTerm     	 (PLBma_RdBTerm    		 ),
					 .PLBma_WrBTerm     	 (PLBma_WrBTerm    		 ),
					 .PLBma_sSize       	 (PLBma_sSize      		 ),
					 .PLBma_pendReq     	 (PLBma_pendReq    		 ),
					 .PLBma_pendPri     	 (PLBma_pendPri    		 ),
					 .PLBma_reqPri      	 (PLBma_reqPri     		 ),

					// PSB Side
					 .psb_plb_start_access   (psb_plb_start_access   ),
					 .psb_plb_address        (psb_plb_address        ),
					 .psb_plb_burst          (psb_plb_burst          ),
					 .psb_plb_tsiz           (psb_plb_tsiz           ),
					 .psb_plb_rnw            (psb_plb_rnw            ),
					 .psb_plb_write_data     (psb_plb_write_data     ),
					 .psb_plb_wdata1_val     (psb_plb_wdata1_val	 ),
					 .psb_plb_wdata2_val     (psb_plb_wdata2_val	 ),
					 .psb_plb_wdata3_val     (psb_plb_wdata3_val	 ),
					 .psb_plb_wdata4_val     (psb_plb_wdata4_val	 ),

				   // OUTPUTS
				    // PLB Master
					 .BGIma_request    		 (BGIma_request 		 ),
					 .BGIma_ABus       		 (BGIma_ABus    		 ),
					 .BGIma_RNW        		 (BGIma_RNW     		 ),
					 .BGIma_BE         		 (BGIma_BE      		 ),
					 .BGIma_size       		 (BGIma_size    		 ),
					 .BGIma_type       		 (BGIma_type    		 ),
					 .BGIma_priority   		 (BGIma_priority		 ),
					 .BGIma_rdBurst    		 (BGIma_rdBurst 		 ),
					 .BGIma_wrBurst    		 (BGIma_wrBurst 		 ),
					 .BGIma_busLock    		 (BGIma_busLock 		 ),
					 .BGIma_abort      		 (BGIma_abort   		 ),
					 .BGIma_lockErr    		 (BGIma_lockErr 		 ),
					 .BGIma_mSize      		 (BGIma_mSize   		 ),
					 .BGIma_ordered    		 (BGIma_ordered 		 ),
					 .BGIma_compress   		 (BGIma_compress		 ),
					 .BGIma_guarded    		 (BGIma_guarded 		 ),
					 .BGIma_wrDBus	 		 (BGIma_wrDBus			 ),

					// PSB Side
                     .plb_psb_read_data      (plb_psb_read_data      ),
					 .plb_psb_read_data_val  (plb_psb_read_data_val  ),
					 .plb_psb_error          (plb_psb_error          ),
					 .plb_psb_access_done    (plb_psb_access_done    )
	);

                                                
endmodule
