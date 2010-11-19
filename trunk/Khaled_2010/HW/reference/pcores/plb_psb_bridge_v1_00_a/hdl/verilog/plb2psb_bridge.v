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
*   Top level file of the PLB2PSB Bridge.
* 
* Project #: HW05-030
* Author:    Jeremy Kuehner
* Date:      February 21, 2005
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/plb_psb_bridge_v1_00_a/hdl/verilog/plb2psb_bridge.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                       
* Change History:                                                       
* $Log: plb2psb_bridge.v,v $
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
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
This module instantiates the plb2psb_plbside and plb2psb_psbside modules
************************************************************************/

module plb2psb_bridge (
                     // Inputs
					  // System
						clk				   ,
						reset			   ,

					  // PSB Master
					    PSBma_abb_n        ,
					    PSBma_dbb_n        ,
						PSBma_aack_n 	   ,
						PSBma_artry_n	   ,
						PSBma_d_i		   ,
						PSBma_ta_n		   ,
						PSBma_ta_n_unreg   ,
						PSBma_tea_n		   ,
						PSBma_tea_n_unreg  ,
						PSBma_bg_n         ,
						PSBma_dbg_n        ,
						PSBma_dbg_n_unreg  ,
						PSBma_dbb_n_unreg  ,
						PSBma_aack_n_unreg ,
						PSBma_bg_n_unreg   ,	
						PSBma_abb_n_unreg  ,	
						PSBma_artry_n_unreg,

                      // PLB Slave
						PLBsl_ABus    	   ,
						PLBsl_PAValid 	   ,
						PLBsl_SAValid 	   ,
						PLBsl_rdPrim  	   ,
						PLBsl_wrPrim  	   ,
						PLBsl_masterID	   ,
						PLBsl_abort   	   ,
						PLBsl_busLock 	   ,
						PLBsl_RNW     	   ,
						PLBsl_BE      	   ,
						PLBsl_MSize   	   ,
						PLBsl_size    	   ,
						PLBsl_type    	   ,
						PLBsl_compress	   ,
						PLBsl_guarded 	   ,
						PLBsl_ordered 	   ,
						PLBsl_lockErr 	   ,
						PLBsl_wrDBus  	   ,
						PLBsl_wrBurst 	   ,
						PLBsl_rdBurst 	   ,

                      // MCSR
					    mcsr_plb_read_data ,

                      // PSB2PLB bridge
                        accept_plb         ,

                     // Outputs
					  // PSB Master
						PSBma_a_o      	    ,
						PSBma_a_en     	    ,
						PSBma_abb_n_o       ,
						PSBma_abb_n_en      ,
						PSBma_dbb_n_o  	    ,
						PSBma_dbb_n_en 	    ,
						PSBma_d_o           ,
						PSBma_d_en          ,
						PSBma_tbst_n_o 	    ,
						PSBma_tbst_n_en	    ,
						PSBma_tsiz_o	    ,
						PSBma_tsiz_en  	    ,
						PSBma_ts_n_o	    ,
						PSBma_ts_n_en  	    ,
						PSBma_tt_o	  	    ,
						PSBma_tt_en		    ,
						PSBma_br_n          ,

                      // PLB Slave
						BGOsl_addrAck    	,
						BGOsl_SSize      	,
						BGOsl_wait       	,
						BGOsl_rearbitrate	,
						BGOsl_wrDAck     	,
						BGOsl_wrComp     	,
						BGOsl_wrBTerm    	,
						BGOsl_rdDBus     	,
						BGOsl_rdWdAddr   	,
						BGOsl_rdDAck     	,
						BGOsl_rdComp     	,
						BGOsl_rdBTerm    	,
						BGOsl_MBusy      	,
						BGOsl_MErr       	,

                      // PLB2PSB Bridge
                        accept_psb          ,
						dont_aack_ps2       ,

                      // MCSR
 					    plb_mcsr_addr       , 
 					    plb_mcsr_write_data , 
 					    plb_mcsr_wr_en_pulse, 
 					    plb_mcsr_rd_en_pulse,
 					    plb2psb_plbside_debug_bus,
 					    plb2psb_psbside_debug_bus  
                      );


/********************
* Module Parameters *
********************/
parameter  C_PLB_AWIDTH                  = 32;
parameter  C_PLB_DWIDTH                  = 64;
parameter  C_PLB_MID_WIDTH               = 4;
parameter  C_PLB_NUM_MASTERS             = 16;
parameter  C_BASEADDR                    = 32'h30000000;
parameter  PLB_SLAVE_LSB_DECODE          = 3;
parameter  PLB_PSB_FPGA_REG_BASEADDR   = 32'h30002000;
parameter  PLB_PSB_FPGA_REG_LSB_DECODE = 18;


/*************
* Module I/O *
*************/
// Inputs
 // System
  input                       clk			     ;
  input                       reset			     ;

 // PSB Master
  input                       PSBma_abb_n        ;
  input                       PSBma_aack_n       ;
  input                       PSBma_dbb_n        ;
  input                       PSBma_artry_n      ;
  input [0:63]                PSBma_d_i	         ;
  input                       PSBma_ta_n	     ;
  input                       PSBma_ta_n_unreg   ;
  input                       PSBma_tea_n	     ;
  input                       PSBma_tea_n_unreg  ;
  input                       PSBma_bg_n         ;
  input                       PSBma_dbg_n        ;
  input                       PSBma_dbg_n_unreg	 ;
  input                       PSBma_dbb_n_unreg	 ;
  input                       PSBma_aack_n_unreg ;
  input                       PSBma_bg_n_unreg   ;
  input                       PSBma_abb_n_unreg  ;
  input                       PSBma_artry_n_unreg;

 // PLB Slave
  input [0:C_PLB_AWIDTH-1]    PLBsl_ABus    	 ;
  input                       PLBsl_PAValid 	 ;
  input                       PLBsl_SAValid 	 ;
  input                       PLBsl_rdPrim  	 ;
  input                       PLBsl_wrPrim  	 ;
  input [0:C_PLB_MID_WIDTH-1] PLBsl_masterID	 ;
  input                       PLBsl_abort   	 ;
  input                       PLBsl_busLock 	 ;
  input                       PLBsl_RNW     	 ;
  input [0:C_PLB_DWIDTH/8-1]  PLBsl_BE      	 ;
  input [0:1]                 PLBsl_MSize   	 ;
  input [0:3]                 PLBsl_size    	 ;
  input [0:2]                 PLBsl_type    	 ;
  input                       PLBsl_compress	 ;
  input                       PLBsl_guarded 	 ;
  input                       PLBsl_ordered 	 ;
  input                       PLBsl_lockErr 	 ;
  input [0:C_PLB_DWIDTH-1]    PLBsl_wrDBus  	 ;
  input                       PLBsl_wrBurst 	 ;
  input                       PLBsl_rdBurst 	 ;

 // MCSR
  input [0:63]                mcsr_plb_read_data ;

 // PSB2PLB Bridge
  input                       accept_plb         ;

// Outputs
 // PSB Master
  output [0:31]               PSBma_a_o        	 ;
  output                      PSBma_a_en       	 ;
  output					  PSBma_abb_n_o      ;
  output                      PSBma_abb_n_en     ;
  output                      PSBma_dbb_n_o    	 ;
  output                      PSBma_dbb_n_en   	 ;
  output [0:63]				  PSBma_d_o          ;
  output					  PSBma_d_en         ;
  output                      PSBma_tbst_n_o   	 ;
  output                      PSBma_tbst_n_en  	 ;
  output [0:3]                PSBma_tsiz_o	   	 ;
  output                      PSBma_tsiz_en    	 ;
  output                      PSBma_ts_n_o	   	 ;
  output                      PSBma_ts_n_en    	 ;
  output [0:4]                PSBma_tt_o	   	 ;
  output                      PSBma_tt_en	   	 ;
  output                      PSBma_br_n         ;

 // PLB Slave
  output                          BGOsl_addrAck      ;
  output [0:1]                    BGOsl_SSize        ;
  output                          BGOsl_wait         ;
  output                          BGOsl_rearbitrate  ;
  output                          BGOsl_wrDAck       ;
  output                          BGOsl_wrComp       ;
  output                          BGOsl_wrBTerm      ;
  output [0:C_PLB_DWIDTH-1]       BGOsl_rdDBus       ;
  output [0:3]                    BGOsl_rdWdAddr     ;
  output                          BGOsl_rdDAck       ;
  output                          BGOsl_rdComp       ;
  output                          BGOsl_rdBTerm      ;
  output [0:C_PLB_NUM_MASTERS-1]  BGOsl_MBusy        ;
  output [0:C_PLB_NUM_MASTERS-1]  BGOsl_MErr         ;

 // PSB2PLB Bridge
  output wire                 accept_psb          ;
  output wire                 dont_aack_ps2       ;

 // MCSR
  output [PLB_PSB_FPGA_REG_LSB_DECODE+1:31] plb_mcsr_addr       ; 
  output [0:31]               plb_mcsr_write_data ; 
  output                      plb_mcsr_wr_en_pulse; 
  output                      plb_mcsr_rd_en_pulse;

  output [4:0]                plb2psb_plbside_debug_bus;
  output [82:0]               plb2psb_psbside_debug_bus; 
  

/********************************
* Internal wires and registers  *
********************************/
// outputs from plb2psb_plbside (inputs to plb2psb_psbside)
wire	     plb_psb_start_access   ;
wire [0:31]  plb_psb_address        ;
wire         plb_psb_burst          ;
wire [1:3]   plb_psb_tsiz           ;
wire	     plb_psb_rnw            ;
wire [0:63]  plb_psb_write_data1    ;
wire [0:63]  plb_psb_write_data2    ;
wire [0:63]  plb_psb_write_data3    ;
wire [0:63]  plb_psb_write_data4    ;

// outputs from plb2psb_psbside (inputs to plb2psb_plbside)
wire [0:63]  psb_plb_read_data      ;
wire         psb_plb_read_data_val  ;
wire         psb_plb_error          ;
wire         psb_plb_access_done    ;
wire [4:0]   plb2psb_plbside_debug_bus;

/********************************
* Module Instantiations			*
********************************/
defparam    plb2psb_plbside.C_PLB_AWIDTH                = C_PLB_AWIDTH;
defparam    plb2psb_plbside.C_PLB_DWIDTH                = C_PLB_DWIDTH;
defparam    plb2psb_plbside.C_PLB_MID_WIDTH             = C_PLB_MID_WIDTH;
defparam    plb2psb_plbside.C_PLB_NUM_MASTERS           = C_PLB_NUM_MASTERS;
defparam    plb2psb_plbside.C_BASEADDR                  = C_BASEADDR; 
defparam    plb2psb_plbside.PLB_SLAVE_LSB_DECODE        = PLB_SLAVE_LSB_DECODE;
defparam    plb2psb_plbside.PLB_PSB_FPGA_REG_BASEADDR   = PLB_PSB_FPGA_REG_BASEADDR;
defparam    plb2psb_plbside.PLB_PSB_FPGA_REG_LSB_DECODE = PLB_PSB_FPGA_REG_LSB_DECODE;

	plb2psb_plbside	plb2psb_plbside (
	               // INPUTS
					// System
					 .clk	                 (clk		  		     ),
					 .reset	                 (reset	  			     ),

                    // PLB Slave
					 .PLBsl_ABus    		 (PLBsl_ABus    		 ),
					 .PLBsl_PAValid 		 (PLBsl_PAValid 		 ),
					 .PLBsl_SAValid 		 (PLBsl_SAValid 		 ),
					 .PLBsl_rdPrim  		 (PLBsl_rdPrim  		 ),
					 .PLBsl_wrPrim  		 (PLBsl_wrPrim  		 ),
					 .PLBsl_masterID		 (PLBsl_masterID		 ),
					 .PLBsl_abort   		 (PLBsl_abort   		 ),
					 .PLBsl_busLock 		 (PLBsl_busLock 		 ),
					 .PLBsl_RNW     		 (PLBsl_RNW     		 ),
					 .PLBsl_BE      		 (PLBsl_BE      		 ),
					 .PLBsl_MSize   		 (PLBsl_MSize   		 ),
					 .PLBsl_size    		 (PLBsl_size    		 ),
					 .PLBsl_type    		 (PLBsl_type    		 ),
					 .PLBsl_compress		 (PLBsl_compress		 ),
					 .PLBsl_guarded 		 (PLBsl_guarded 		 ),
					 .PLBsl_ordered 		 (PLBsl_ordered 		 ),
					 .PLBsl_lockErr 		 (PLBsl_lockErr 		 ),
					 .PLBsl_wrDBus  		 (PLBsl_wrDBus  		 ),
					 .PLBsl_wrBurst 		 (PLBsl_wrBurst 		 ),
					 .PLBsl_rdBurst 		 (PLBsl_rdBurst 		 ),

                    // MCSR
                     .mcsr_plb_read_data     (mcsr_plb_read_data     ),
                   
                    // PSB Side
                     .psb_plb_read_data      (psb_plb_read_data      ),
					 .psb_plb_read_data_val  (psb_plb_read_data_val  ),
					 .psb_plb_error          (psb_plb_error          ),
					 .psb_plb_access_done    (psb_plb_access_done    ),

                    // PSB2PLB Bridge
					 .accept_plb             (accept_plb             ),

				   // OUTPUTS
					// PLB Slave
					 .BGOsl_addrAck    	     (BGOsl_addrAck    	     ),
					 .BGOsl_SSize      	     (BGOsl_SSize      	     ),
					 .BGOsl_wait       	     (BGOsl_wait       	     ),
					 .BGOsl_rearbitrate	     (BGOsl_rearbitrate	     ),
					 .BGOsl_wrDAck     	     (BGOsl_wrDAck     	     ),
					 .BGOsl_wrComp     	     (BGOsl_wrComp     	     ),
					 .BGOsl_wrBTerm    	     (BGOsl_wrBTerm    	     ),
					 .BGOsl_rdDBus     	     (BGOsl_rdDBus     	     ),
					 .BGOsl_rdWdAddr   	     (BGOsl_rdWdAddr   	     ),
					 .BGOsl_rdDAck     	     (BGOsl_rdDAck     	     ),
					 .BGOsl_rdComp     	     (BGOsl_rdComp     	     ),
					 .BGOsl_rdBTerm    	     (BGOsl_rdBTerm    	     ),
					 .BGOsl_MBusy      	     (BGOsl_MBusy      	     ),
					 .BGOsl_MErr       	     (BGOsl_MErr       	     ),

					// MCSR
					 .plb_mcsr_rd_en_pulse   (plb_mcsr_rd_en_pulse   ),
					 .plb_mcsr_wr_en_pulse   (plb_mcsr_wr_en_pulse   ),
					 .plb_mcsr_addr          (plb_mcsr_addr          ),
					 .plb_mcsr_write_data    (plb_mcsr_write_data    ),

                    // PSB2PLB Bridge
					 .accept_psb             (accept_psb             ),

                    // PSB Side
					 .plb_psb_start_access   (plb_psb_start_access   ),
					 .plb_psb_address        (plb_psb_address        ),
					 .plb_psb_burst          (plb_psb_burst          ),
					 .plb_psb_tsiz           (plb_psb_tsiz           ),
					 .plb_psb_rnw            (plb_psb_rnw            ),
					 .plb_psb_write_data1    (plb_psb_write_data1    ),
					 .plb_psb_write_data2    (plb_psb_write_data2    ),
					 .plb_psb_write_data3    (plb_psb_write_data3    ),
					 .plb_psb_write_data4    (plb_psb_write_data4    ),
					 .plb2psb_plbside_debug_bus (plb2psb_plbside_debug_bus)
	);																  
																	  
																	  
	plb2psb_psbside	plb2psb_psbside (
	               // INPUTS
					// System
					 .clk	                 (clk		  		     ),
					 .reset	                 (reset	  			     ),

				    // PSB Master
					 .PSBma_abb_n            (PSBma_abb_n            ),
					 .PSBma_dbb_n            (PSBma_dbb_n            ),
					 .PSBma_aack_n 			 (PSBma_aack_n 		  	 ),
					 .PSBma_artry_n			 (PSBma_artry_n		  	 ),
					 .PSBma_d_i				 (PSBma_d_i			  	 ),
					 .PSBma_ta_n			 (PSBma_ta_n		  	 ),
					 .PSBma_ta_n_unreg       (PSBma_ta_n_unreg       ),
					 .PSBma_tea_n			 (PSBma_tea_n		  	 ),
					 .PSBma_tea_n_unreg      (PSBma_tea_n_unreg      ),
					 .PSBma_bg_n             (PSBma_bg_n             ),
					 .PSBma_dbg_n            (PSBma_dbg_n            ),
					 .PSBma_dbg_n_unreg		 (PSBma_dbg_n_unreg		 ),
					 .PSBma_dbb_n_unreg		 (PSBma_dbb_n_unreg		 ),
					 .PSBma_aack_n_unreg     (PSBma_aack_n_unreg     ),
					 .PSBma_bg_n_unreg		 (PSBma_bg_n_unreg		 ),
					 .PSBma_abb_n_unreg		 (PSBma_abb_n_unreg		 ),
					 .PSBma_artry_n_unreg	 (PSBma_artry_n_unreg	 ),

					// PLB Side
					 .plb_psb_start_access   (plb_psb_start_access   ),
					 .plb_psb_address        (plb_psb_address        ),
					 .plb_psb_burst          (plb_psb_burst          ),
					 .plb_psb_tsiz           (plb_psb_tsiz           ),
					 .plb_psb_rnw            (plb_psb_rnw            ),
					 .plb_psb_write_data1    (plb_psb_write_data1    ),
					 .plb_psb_write_data2    (plb_psb_write_data2    ),
					 .plb_psb_write_data3    (plb_psb_write_data3    ),
					 .plb_psb_write_data4    (plb_psb_write_data4    ),
					 .accept_psb             (accept_psb             ),

				   // OUTPUTS
				    // PSB Master
					 .PSBma_a_o      		 (PSBma_a_o      	     ),
					 .PSBma_a_en     		 (PSBma_a_en     	     ),
					 .PSBma_abb_n_o          (PSBma_abb_n_o          ),
					 .PSBma_abb_n_en         (PSBma_abb_n_en         ),
					 .PSBma_dbb_n_o  		 (PSBma_dbb_n_o  	     ),
					 .PSBma_dbb_n_en 		 (PSBma_dbb_n_en 	     ),
					 .PSBma_d_o              (PSBma_d_o              ),
					 .PSBma_d_en             (PSBma_d_en             ),
					 .PSBma_tbst_n_o 		 (PSBma_tbst_n_o 	     ),
					 .PSBma_tbst_n_en		 (PSBma_tbst_n_en	     ),
					 .PSBma_tsiz_o	 		 (PSBma_tsiz_o	 	     ),
					 .PSBma_tsiz_en  		 (PSBma_tsiz_en  	     ),
					 .PSBma_ts_n_o	 		 (PSBma_ts_n_o	 	     ),
					 .PSBma_ts_n_en  		 (PSBma_ts_n_en  	     ),
					 .PSBma_tt_o	 		 (PSBma_tt_o	 	     ),
					 .PSBma_tt_en	 		 (PSBma_tt_en	 	     ),
					 .PSBma_br_n             (PSBma_br_n             ),

					// PLB Side
                     .psb_plb_read_data      (psb_plb_read_data      ),
					 .psb_plb_read_data_val  (psb_plb_read_data_val  ),
					 .psb_plb_error          (psb_plb_error          ),
					 .psb_plb_access_done    (psb_plb_access_done    ),
					 .dont_aack_ps2          (dont_aack_ps2          ),
					 .plb2psb_psbside_debug_bus (plb2psb_psbside_debug_bus)
	);

                                                
endmodule
