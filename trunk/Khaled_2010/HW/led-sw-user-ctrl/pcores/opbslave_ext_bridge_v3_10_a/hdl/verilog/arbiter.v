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
*   This module handles the arbitration of the EXT bus. There are three
*   masters on this bus:
*       - OPB Bridge (asserts opb_select when it wants bus)
*       - PCI-Local Bridge (asserts pci_br_n when it wants bus)
*       - CPLD - asserts cpld_br_n when it wants bus
*
*   Note:  The pci_bg_n will become deasserted when the pci-local bridge
*          is granted the bus. The pci-local bridge will assert bus_busy
*          while it needs the bus.
*          The cpld_br_n will be held asserted by the CPLD for as long as
*          the cpld needs the bus. The CPLD does not use bus_busy signal.
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
* Author:   Adam De Roose   (adam.deroose@amirix.com)
* Date:     Jan 3, 2002
*
*
* Filename:                $Source: /usr/cvsroot/ap1000/pcores/opbslave_ext_bridge_v3_10_a/hdl/verilog/arbiter.v,v $                                
* Current Revision:        $Revision: 1.1 $                                
* Last Updated:            $Date: 2005/08/23 19:22:55 $                                
* Last Modified by:        $Author: kuehner $                                
* Currently Locked by:     $Locker:  $                                
*                                                                      
*                                                                       
*                                                                       
* Change History:                                                       
* $Log: arbiter.v,v $
* Revision 1.1  2005/08/23 19:22:55  kuehner
* Initial ap1000 commit (moved from hw05-030).
*
* Revision 1.1  2005/06/01 12:57:43  labuser
* Initial Revision
*
* Revision 1.1  2005/01/22 02:58:01  young
* added parameterized widths to external address, data, switch, and LED
* buses from ver. 3.00.a
*
* Revision 1.1  2003/11/18 21:10:33  kuehner
* Initial Revision - updated from opb_ext_bridge_v2_00_a
*
* Revision 1.2  2003/10/16 16:57:20  kuehner
* Fixed typo
*
* Revision 1.1  2003/09/25 17:39:21  kuehner
* *** empty log message ***
*
* Revision 1.4  2003/07/30 14:52:39  kuehner
* Updated memory map to be as shown in HW03-036's Release 3 memory map
*
* Revision 1.3  2003/06/18 18:35:30  kuehner
* Added support for guardian module within the plb2opb bridge that prevents deadlock from occuring (brought some signals that the guardian module needed out of the opb_ext bridge)
*
* Revision 1.2  2003/06/10 21:05:15  kuehner
* Wait for ext_bb_n levels as opposed to edges
*
* Revision 1.1  2003/05/02 17:21:57  smith
* from Jeremy, May 2
*
* Revision 1.7  2002/02/18 18:00:55  doiron
* Initial Check-In
*
* Revision 1.6  2002/02/07 17:51:47  deroose
* Changed FSM to park OPB on local bus
*
* Revision 1.5  2002/02/06 16:04:44  doiron
* - Removed OPB signal sampling
* - Forced sln_retry to be active during opb_select only.
*
* Revision 1.4  2002/01/24 20:02:43  deroose
* Removed double sampling of inputs.
*
* Revision 1.3  2002/01/23 20:57:08  deroose
* Fixed bus_busy_n assign statement
*
* Revision 1.2  2002/01/17 20:59:48  deroose
* Made a few coding changes after some testing was done.
*
* Revision 1.1  2002/01/14 21:05:22  deroose
* initial commit
*
*
*
***********************************************************************/

`timescale 1 ns / 1 ps

/***********************************************************************
Module Description:

text_to_change

************************************************************************/


module arbiter (
    clk                                ,    // i 
    reset_n                            ,    // i 
    opb_select                         ,    // i 
    opb_abus                           ,    // i     5
    cpld_br_n                          ,    // i
     
    cpld_bg_n                          ,    // o     10 
    sl_retry                           ,    // o 
    opb                                     // o 
);


/********************
* Module Parameters *
********************/
// Address decoding parameters. Since the smallest address space is
// 32 MB, we are able to decode devices based on bits [0:6] of LA[0:31]
// or OPB_addr[0:31]. These parameters are the values that are used
// to decode on these 7 bits (we are not using the entire 32 bit address
// in our compare statements)

parameter   opb_bridge_addr_base = 7'h10; // 32'h2000_0000
parameter   opb_bridge_addr_size = 7'h16; // 32'h2C00_0000	704 MB

/*************
* Module I/O *
*************/
input clk;
input reset_n;

input        opb_select;
input [0:31] opb_abus;
input        cpld_br_n;

output       cpld_bg_n;
output       sl_retry;
output       opb;
/*****************************
* Internal Registers & Wires *
*****************************/
reg cpld_bg_n;
reg sl_retry;
reg opb;  

reg cpld_br_n_s;

// Register the FPGA external inputs
always@(posedge clk or negedge reset_n)
begin
    if(!reset_n)   
    begin
        cpld_br_n_s    <= 1;
    end
    else
    begin
        cpld_br_n_s    <= cpld_br_n;
    end
end


/**************************************************************************************************
* FSM:      arbiter
* Author:   Adam De Roose   (adam.deroose@amirix.com)
* Date:     Jan 3, 2002
***************************************************************************************************
**************************************************************************************************/

reg [1:0] arbiter_state;    // State Register

/********************
* State Definitions *
********************/
parameter park_opb                  = 2'b01;
parameter cpld                      = 2'b10;

always @(posedge clk or negedge reset_n)            
begin
    if (!reset_n) 
    begin                                     
        arbiter_state <= park_opb;
        cpld_bg_n     <= 1;
        opb           <= 0;
		sl_retry      <= 0;
    end
    else
    begin
        case (arbiter_state)

        /***************************************************************
        * park_opb - This state parks the OPB on the EXT bus and       *
        *            monitors the br's from the devices.               *
        ***************************************************************/
        park_opb:
        begin
            sl_retry <= 0;
            if ((!cpld_br_n_s) &&
                !(opb_select &
                 (opb_abus[0:6] >= opb_bridge_addr_base) &
                 (opb_abus[0:6] <= (opb_bridge_addr_base + opb_bridge_addr_size-1)))
                )
            // CPLD wants the EXT bus and OPB is not requesting it
            begin
                arbiter_state <= cpld;
                cpld_bg_n     <= 0;
                opb           <= 0;
            end

            else
            // Since the CPLD doesn't want the EXT bus,
            // park the OPB on it
            begin
                arbiter_state <= park_opb;
                cpld_bg_n     <= 1;
                opb           <= 1;
            end
        end

        /***************************************************************
        * cpld - In this state, the CPLD has been granted the EXT bus. *
        *        We should stay in this state until the CPLD has       *
        *        deasserted cpld_br_n_s which indicates that the CPLD  *
        *        is finished with the bus.                             *
        ***************************************************************/                
        cpld:
        begin
            if (!cpld_br_n_s)
            // The cpld is not done with the bus so stay here
                arbiter_state <= cpld;
            else
            // The cpld is done with the bus so go back to park_opb
                arbiter_state <= park_opb;

            cpld_bg_n     <= 0;
            opb           <= 0;

            if(opb_select & 
              (opb_abus[0:6] <= (opb_bridge_addr_base + opb_bridge_addr_size-1)) &
              (opb_abus[0:6] >= opb_bridge_addr_base))
            // The OPB wants the bus but the CPLD has it so assert sl_retry
            // until opb_select is deasserted to force the OPB master off the bus.
                sl_retry <= 1;
            else
                sl_retry <= 0;
        end

        /***************************************************************
        * Default State                                                *
        ***************************************************************/
        default:
        begin
            arbiter_state <= park_opb;
            cpld_bg_n     <= 1;
            opb           <= 1;
            sl_retry      <= 0;
        end

        endcase
    end
end
                                                                                                                                             
endmodule
