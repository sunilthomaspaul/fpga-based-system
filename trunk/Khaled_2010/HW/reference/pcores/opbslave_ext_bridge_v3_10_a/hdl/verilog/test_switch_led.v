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
*   This module does not really belong within the opb_ext_bridge but because it
*   has register bits that need to be accessible, this is the easiest place to
*   put it. It functions as follows:
*           if (switch pressed) or (fpga in reset) or (user r/w bit set)
*                led is on
*           else
*                led is off
*                      
*
* Structure:   
* 
*            -- top.v
*                 -- PPC405.v
*                 -- opb_ext_bridge.v
*                      -- bridge.v
*                      -- arbiter.v
*                      -- test_switch_led.v
*
*-----------------------------------------------------------------------------
*                                                                       
* 
* Author:   Jeremy Kuehner
* Date:     Jan 3, 2002
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/opbslave_ext_bridge_v3_10_a/hdl/verilog/test_switch_led.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:56 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                      
*                                                                       
*                                                                       
* Change History:                                                       
* $Log: test_switch_led.v,v $
* Revision 1.1  2005/08/23 19:22:56  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.1  2005/06/01 12:57:43  labuser
* Initial Revision
*
* Revision 1.3  2005/05/05 18:36:31  labuser
* Fixed bug related to using logical  negation instead of using bitwise negation.
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
* Revision 1.1  2003/06/24 14:05:50  kuehner
* Changed C Flash so that upper quadrant is protected by base_cfg_enable. Added LED register.
*
*
*
***********************************************************************/

`timescale 1 ns   / 1 ps

module test_switch_led (
                      // INPUTS
                        clk         ,   // i 
                        reset_n     ,   // i 
                        user_rw_bits,   // i
                        test_switch ,   // i

                        test_led        // o
                       );


/********************
* Module Parameters *
********************/

parameter test_swtch_width = 1;
parameter test_led_width   = 1; 


/*************
* Module I/O *
*************/
input                           clk;
input                           reset_n;
input  [0:test_swtch_width-1]   user_rw_bits;
input  [0:test_swtch_width-1]   test_switch;

output [0:test_led_width-1]     test_led;
reg    [0:test_led_width-1]     test_led;

/*****************************
* Internal Registers & Wires *
*****************************/

/*****************************
* Module Logic               *
*****************************/
// Switch pressed = '0' input
// LED on = '1' output
// user_rw_bit = '1' to turn on LED
always @(posedge clk or negedge reset_n)       
begin
    if (!reset_n) 
    begin
	    test_led <= {test_led_width{1'b1}};
	end

    else
	begin
	    test_led <= (~test_switch) | user_rw_bits;
	end
end	    
endmodule
