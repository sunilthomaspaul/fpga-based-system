-------------------------------------------------------------------------------
-- $Id: plb_ipif.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- plb_ipif.vhd -  Version v1.00b           
-------------------------------------------------------------------------------
--
--                  ****************************
--                  ** Copyright Xilinx, Inc. **
--                  ** All rights reserved.   **
--                  ****************************
--
-------------------------------------------------------------------------------
-- Filename:        plb_ipif.vhd
--
-- Description:     This is the top level design file for the Mauna Loa 
--                  plb_ipif function It provides a standardized interface 
--                  between the IP and the PLB Bus. This version supports 
--                  cacheln and burst transfers at 1 clock per data beat.
--                  It does not provide address pipelining and simultaneous
--                  read and write operations.
--
-------------------------------------------------------------------------------
-- Structure:   
--
--                  plb_ipif.vhd
--                    \
--                    \-- proc_common_v1_00_b.vhd
--                    \       family.vhd
--                    \       or_muxcy.vhd
--                    \       or_gate.vhd
--                    \       pselect.vhd
--                    \       inferred_lut4.vhd
--                    \       srl_fifo2.vhd
--                    \
--                    \-- ipif_common_v1_00_b
--                    \       ipif_pkg.vhd
--                    \       ipif_steer.vhd
--                    \       interrupt_control.vhd
--                    \       
--                    \
--                    \-- ipif_reset.vhd
--                    \
--                    \
--                    \-- plb_sesr_sear.vhd
--                    \
--                    \
--                    \-- plb_slave_attachment_dtime.vhd                     
--                    \       address_decoder.vhd
--                    \       addr_reg_cntr_brst.vhd
--                    \       determinate_timer.vhd
--                    \             pf_counter_top.vhd
--                    \                 pf_counter.vhd
--                    \                     pf_counter_bit.vhd
--                    \
--                    \
--                    \   
--                    \-- rdfifo.vhd                      
--                    \      rpfifo_top.vhd             
--                    \          ipif_control_rd.vhd      
--                    \          rdpfifo_dp_cntl.vhd        
--                    \                pf_counter_top.vhd                     
--                    \                     pf_counter.vhd                
--                    \                           pf_counter_bit.vhd   
--                    \                pf_occ_counter_top.vhd                    
--                    \                     pf_occ_counter.vhd               
--                    \                           pf_counter_bit.vhd   
--                    \                pf_adder.vhd                           
--                    \                     pf_adder_bit.vhd               
--                    \                pf_dly1_mux.vhd                    
--                    \           pf_dpram.vhd
--                    \           srl16_fifo.vhd
--                    \                pf_counter_top.vhd                     
--                    \                     pf_counter.vhd                
--                    \                              pf_counter_bit.vhd   
--                    \                pf_occ_counter_top.vhd                    
--                    \                     pf_occ_counter.vhd               
--                    \                              pf_counter_bit.vhd   
--                    \                pf_adder.vhd                           
--                    \                     pf_adder_bit.vhd               
--                    \                  
--                    \                      
--                    \-- wrfifo.vhd                            
--                          wpfifo_top.vhd                   
--                               ipif_control_wr.vhd
--                               wrpfifo_dp_cntl.vhd
--                                    pf_counter_top.vhd                     
--                                         pf_counter.vhd                
--                                               pf_counter_bit.vhd   
--                                    pf_occ_counter_top.vhd                    
--                                         pf_occ_counter.vhd               
--                                               pf_counter_bit.vhd   
--                                    pf_adder.vhd                           
--                                         pf_adder_bit.vhd               
--                                    pf_dly1_mux.vhd                    
--                               pf_dpram.vhd
--                               srl16_fifo.vhd
--                                    pf_counter_top.vhd                     
--                                         pf_counter.vhd                
--                                                  pf_counter_bit.vhd   
--                                    pf_occ_counter_top.vhd                    
--                                         pf_occ_counter.vhd               
--                                                  pf_counter_bit.vhd   
--                                    pf_adder.vhd                           
--                                         pf_adder_bit.vhd               
--                              
--                                                  
-------------------------------------------------------------------------------
-- Author:      <Doug Thorpe>
--
-- History:
--
--
--  DET     12-19-01   V1_00_a
--          - Conversion to PLB IPIF from OPB v1_23_c IPIF
--
--     DET     4/24/2002     v1_00_b
-- ~~~~~~
--     - Converted to the 64 bit ARD_ADDR_RANGE_ARRAY.
--     - Added Burst Support (Indeterminate timing only).
--     - Added parameter C_IPIF_AWIDTH.
--     - Modified IPIC ports to be sized relative to C_IPIF_DWIDTH
--       and C_IPIF_AWIDTH.
--     - Removed temporary IPIC signals Bus2IP_AValid, IP2Bus_AddrSel
--     - Modified the MIR Version constants to reflect version V1.00.b
-- ^^^^^^
--
--     DET     5/22/2002     v1_00_b
-- ~~~~~~
--     - Added determinate timing parameterization and corresponding
--       slave attachment module.
-- ^^^^^^
--
--     DET     6/17/2002     v1_00_b
-- ~~~~~~
--     - Added the input signal IP2Bus_PostedWrInh to the IPIC signal set.
--       Implementation is TBD. The signal is currently not used.
-- ^^^^^^
--
--     DET     6/19/2002     v1_00_b
-- ~~~~~~
--     - Updated the header block files information.
-- ^^^^^^
--     DET     11/19/2002     Library change for PLB IPIF V1.00c
-- ~~~~~~
--     - Changed the ipif_common library reference to ipif_common_v1_00_b.
--     - Changed the plb_ipif library reference to plb_ipif_v1_00_d.
--     - Changed the IPIF MIR value to reflect plb_ipif_v1_00_d.
-- ^^^^^^
--
--
--     DET     12/2/2002     Update to plb_ipif_v1_00_d
-- ~~~~~~
--     - Modified the generation of the Sl_ssize output signal to be based 
--       upon the input parameter C_PLB_DWIDTH instead of dynamically created
--       from the data width of each individual target address space decoded
--       by the IPIF.
-- ^^^^^^
--
--     DET     12/24/2002     V1.00.c
-- ~~~~~~
--     - Included Sub-bus Width access support Packet FIFOs
-- ^^^^^^
--
--     DET     3/17/2003     V1.00.d
-- ~~~~~~
--     - Incorporated various Slave Attachment changes to increase Fmax.
-- ^^^^^^
--
--
--     DET     3/31/2003      V1.00.d
-- ~~~~~~
--     - Added the C_DEV_FAST_DATA_XFER parameter.
--     - Incorporated the updated slave_attachment_dtime module
-- ^^^^^^
--
--     DET     4/16/2003     V1.00.d
-- ~~~~~~
--     - Added Spartan III to list of Virtex-II 'like' devices (BRAM) for
--       packet FIFO parameterization.
-- ^^^^^^
--
--     DET     6/5/2003     v1.00.e
-- ~~~~~~
--     - Changed the ipif library callout to plb_ipif_v1_00_e from 
--       plb_ipif_v1_00_d.
-- ^^^^^^
--
--     DET     6/5/2003     v1.00.e PCI
-- ~~~~~~
--     - Updated MIR Revision Value.
--     - Added IP2Bus_Busy signal to IPIC signal set (for PCI)
-- ^^^^^^
--
--
--     DET     6/20/2003     v1.00.e PCI 
-- ~~~~~~
--     - Added IP2Bus_PselHit and Bus2IP_RNW_Early to IPIC signal set (for PCI)
--     - Added IP2Bus_AddrAck to IPIC to support indeterminate bursts and 
--       removal of determinate timing service.
--     - Added Bus2IP_IBurst to IPIC interface to indicate that an indeterminate
--       burst operation is in progress.
--     - Added IP2Bus_BTerm to IPIC for future use.
-- ^^^^^^
--
--     DET     6/23/2003     v1.00.e PCI
-- ~~~~~~
--     - Modified the default port widths of the IP2RFIFO_Data and WFIFO2IP_Data
--       from 32 to the C_IPIF_DWIDTH parameter value. This is only used when
--       the packet FIFOs are not present in the IPIF.
-- ^^^^^^
--
--
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------- 
-- Special information
--
--  The input Generic C_IP_INTR_MODE_ARRAY is an unconstrained array
--  of integers. The number of entries specifies how many IP interrupts
--  are to be processed. Each entry in the array specifies the type of input 
--  processing for each IP interrupt input. The following table
--  lists the defined values for entries in the array. You can use these 
--  predefined constants:
-- 
--         INTR_PASS_THRU      
--         INTR_PASS_THRU_INV  
--         INTR_REG_EVENT      
--         INTR_REG_EVENT_INV  
--         INTR_POS_EDGE_DETECT
--         INTR_NEG_EDGE_DETECT
--
--  or these integer values:
--
--          1   =   Level Pass through (non-inverted)
--          2   =   Level Pass through (invert input)
--          3   =   Registered Event   (non-inverted)
--          4   =   Registered Event   (inverted input)
--          5   =   Rising Edge Detect
--          6   =   Falling Edge Detect
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_arith.all;



library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.proc_common_pkg.all;
use modified_plb_ddr_controller_v1_00_c.family.all;
use modified_plb_ddr_controller_v1_00_c.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.ipif_pkg.all;
use modified_plb_ddr_controller_v1_00_c.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.all;


-------------------------------------------------------------------------------


entity plb_ipif is
  generic (
        
        C_ARD_ID_ARRAY :  INTEGER_ARRAY_TYPE :=
                --see ipif_pkg.vhd for reserved ID definitions
                (
                 IPIF_INTR,         -- ipif interrupt (pre-defined keyword)
                 USER_00,           -- user ID (pre-defined keyword)
                 USER_01,           -- user ID (pre-defined keyword) 
                 USER_02,           -- user ID (pre-defined keyword) 
                 IPIF_RST,          -- ipif reset (pre-defined keyword)
                 IPIF_WRFIFO_REG,   -- ipif wrfifo registers (pre-defined keyword)
                 IPIF_WRFIFO_DATA,  -- ipif wrfifo data (pre-defined keyword)
                 IPIF_RDFIFO_REG,   -- ipif rdfifo registers (pre-defined keyword)
                 IPIF_RDFIFO_DATA,  -- ipif rdfifo data (pre-defined keyword)
                 IPIF_SESR_SEAR     -- IPIF SESR/SEAR Registers
                );
                
        C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE :=
               -- Base address and high address pairs.
                (
                 X"0000_0000_1000_0000", -- IPIF Interrupt base address
                 X"0000_0000_1000_01FF", -- IPIF Interrupt high address
                 X"0000_0000_7000_0000", -- IP user0 base address  
                 X"0000_0000_7000_00FF", -- IP user0 high address  
                 X"0000_0000_8000_0000", -- IP user1 base address
                 X"0000_0000_8FFF_FFFF", -- IP user1 high address
                 X"0000_0000_9000_0000", -- IP user2 base address
                 X"0000_0000_9FFF_FFFF", -- IP user2 high address
                 X"0000_0000_1000_0200", -- IPIF Reset base address
                 X"0000_0000_1000_02FF", -- IPIF Reset high address
                 X"0000_0000_1000_2000", -- IPIF WrFIFO Registers base address
                 X"0000_0000_1000_20FF", -- IPIF WrFIFO Registers high address
                 X"0000_0000_1000_2100", -- IPIF WrFIFO Data base address 
                 X"0000_0000_1000_21ff", -- IPIF WrFIFO Data high address 
                 X"0000_0000_1000_2200", -- IPIF RdFIFO Registers base address
                 X"0000_0000_1000_22FF", -- IPIF RdFIFO Registers high address
                 X"0000_0000_1000_2300", -- IPIF RdFIFO Data base address     
                 X"0000_0000_1000_23FF", -- IPIF RdFIFO Data high address
                 X"0000_0000_1000_2400", -- IPIF SESR/SEAR Register base address 
                 X"0000_0000_1000_241F"  -- IPIF SESR/SEAR Register high address      
                );
                
        C_ARD_DWIDTH_ARRAY     : INTEGER_ARRAY_TYPE :=
              -- This array specifies the data bus width of the memory address
              -- range specified for the cooresponding baseaddr pair.
                (
                 32,    -- IPIF Interrupt data width
                 32,    -- User0 data width
                 64,    -- User1 data width
                 8,     -- User2 data width
                 32,    -- IPIF Reset data width
                 32,    -- IPIF WrFIFO Registers data width
                 16,    -- IPIF WrFIFO Data data width
                 32,    -- IPIF RdFIFO Registers data width
                 8,     -- IPIF RdFIFO Data width
                 32     -- IPIF SESR/SEAR Register data width
                );
                
        C_ARD_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE :=
              -- This array spcifies the number of Chip Enables (CE) that is 
              -- required by the cooresponding baseaddr pair.
                (
                 16,    -- IPIF Interrupt CE Number
                 8,     -- User0 CE Number
                 1,     -- User1 CE Number
                 1,     -- User2 CE Number
                 1,     -- IPIF Reset CE Number
                 2,     -- IPIF WrFIFO Registers CE Number
                 1,     -- IPIF WrFIFO Data data CE Number
                 2,     -- IPIF RdFIFO Registers CE Number
                 1,     -- IPIF RdFIFO Data CE Number
                 2      -- IPIF SESR/SEAR Register CE Number
                );
  
        -- Obsoleted   C_ARD_DTIME_READ_ARRAY   : INTEGER_ARRAY_TYPE :=
        -- Obsoleted           -- Mode, Latency, Wait States
        -- Obsoleted           (
        -- Obsoleted            0,0,0, -- IPIF Interrupt Determinate Read Params        
        -- Obsoleted            0,0,0, -- User0 Determinate Read Params                  
        -- Obsoleted            0,0,0, -- User1 Determinate Read Params                  
        -- Obsoleted            0,0,0, -- User2 Determinate Read Params                  
        -- Obsoleted            0,0,0, -- IPIF Reset Determinate Read Params             
        -- Obsoleted            0,0,0, -- IPIF WrFIFO Registers Determinate Read Params  
        -- Obsoleted            0,0,0, -- IPIF WrFIFO Data data Determinate Read Params  
        -- Obsoleted            0,0,0, -- IPIF RdFIFO Registers Determinate Read Params  
        -- Obsoleted            0,0,0, -- IPIF RdFIFO Data Determinate Read Params       
        -- Obsoleted            0,0,0  -- IPIF SESR/SEAR Register Determinate Read Params
        -- Obsoleted           );
        -- Obsoleted
        -- Obsoleted   C_ARD_DTIME_WRITE_ARRAY   : INTEGER_ARRAY_TYPE :=
        -- Obsoleted           -- Mode, Latency, Wait States
        -- Obsoleted           (
        -- Obsoleted            0,0,0, -- IPIF Interrupt Determinate Write Params         
        -- Obsoleted            0,0,0, -- User0 Determinate Write Params                  
        -- Obsoleted            0,0,0, -- User1 Determinate Write Params                  
        -- Obsoleted            0,0,0, -- User2 Determinate Write Params                  
        -- Obsoleted            0,0,0, -- IPIF Reset Determinate Write Params             
        -- Obsoleted            0,0,0, -- IPIF WrFIFO Registers Determinate Write Params  
        -- Obsoleted            0,0,0, -- IPIF WrFIFO Data data Determinate Write Params  
        -- Obsoleted            0,0,0, -- IPIF RdFIFO Registers Determinate Write Params  
        -- Obsoleted            0,0,0, -- IPIF RdFIFO Data Determinate Write Params       
        -- Obsoleted            0,0,0  -- IPIF SESR/SEAR Register Determinate Write Params
        -- Obsoleted           );
        
           C_DEV_BLK_ID : INTEGER := 1;  
              --  Platform Builder Assiged Device ID number (unique
              --  for each device)
                    
           C_DEV_MIR_ENABLE : BOOLEAN := true;  
              --  Used to Enable/Disable Module ID functions
                    
           C_DEV_BURST_ENABLE : BOOLEAN := true;  
              -- Burst Enable for IPIF Interface
                    
           C_DEV_FAST_DATA_XFER : Boolean := false;
               -- If Burst is enabled, then this parameter will allow the selection 
               -- of a fast data transfer mode (1 clk per databeat but FPGA resource
               -- intensive) or a slower multi-clock per databeat transfer mode
               -- (but saves FPGA resources).
           
           C_DEV_MAX_BURST_SIZE : INTEGER := 64;  
               -- Maximum burst size to be supported (in bytes)
               
           C_DEV_BURST_PAGE_SIZE : Integer := 1024;
               -- Maximum supported burst address page size (bytes).
               -- Crossing a page boundry during a single burst  
               -- transaction will result in address wrapping.
                    
           C_DEV_DPHASE_TIMEOUT : Integer := 64;
               -- The number of bus clocks to use as a timeout of 
               -- data acknowledges within the device. If this parameter
               -- is set to 0, the WDT function is removed.
                    
           C_INCLUDE_DEV_ISC : BOOLEAN := true;
               -- 'true' specifies that the full device interrupt
               -- source controller structure will be included;
               -- 'false' specifies that only the global interrupt
               -- enable is present in the device interrupt source
               -- controller and that the only source of interrupts
               -- in the device is the IP interrupt source controller

           C_INCLUDE_DEV_PENCODER : BOOLEAN := true;  
               -- 'true' will include the Device IID in the IPIF Interrupt
               -- function
                    
           C_IP_INTR_MODE_ARRAY   : INTEGER_ARRAY_TYPE :=
               -- If an IPIF interrupt module is specified, this array 
               -- specifies the type of interrupt capture mode for each
               -- interrupt input from the IP design. Note: The number
               -- of entries in the array denotes how many IP interrupts
               -- are needed.
                (
                 INTR_PASS_THRU,        -- pass through (non-inverting)
                 INTR_PASS_THRU_INV,    -- pass through (inverting)
                 INTR_REG_EVENT,        -- registered level (non-inverting)
                 INTR_REG_EVENT_INV,    -- registered level (inverting)
                 INTR_POS_EDGE_DETECT,  -- positive edge detect
                 INTR_NEG_EDGE_DETECT,  -- negative edge detect
                 INTR_NEG_EDGE_DETECT,  -- negative edge detect
                 INTR_POS_EDGE_DETECT   -- positive edge detect
                );
           
           C_IP_MASTER_PRESENT : BOOLEAN := false;  
                -- 'true' specifies that the IP has Bus Master capability
                    
           C_WRFIFO_DEPTH    : Integer range 4 to 16384 := 512;     
                -- If a WRFIFO is specified, then this is
                -- the number of storage locations for the 
    	        -- WRFIFO. Should be a power of 2.
                
           C_WRFIFO_INCLUDE_PACKET_MODE : Boolean := false;
                -- If a WRFIFO is specified, then this is
                -- the selection of inclusion of packet mode features            
                -- on the IP interface
           
           C_WRFIFO_INCLUDE_VACANCY     : Boolean := true;
                -- If a WRFIFO is specified, then this is
                -- the selection of inclusion of vacancy calculation
                -- on the 'Write' interface of FIFO.                           
           
           C_RDFIFO_DEPTH    : Integer range 4 to 16384 := 512;     
                -- If a RDFIFO is specified, then this is
                -- the number of storage locations for the 
    	        -- RDFIFO. Should be a power of 2.
                
           C_RDFIFO_INCLUDE_PACKET_MODE : Boolean := false;
                -- If a RDFIFO is specified, then this is
                -- the selection of inclusion of packet mode features            
                -- on the IP interface
           
           C_RDFIFO_INCLUDE_VACANCY     : Boolean := true;
                -- If a RDFIFO is specified, then this is
                -- the selection of inclusion of vacancy calculation
                -- on the 'Write' interface of FIFO.                           
           
           C_PLB_MID_WIDTH : Integer := 3;
                -- The width of the Master ID bus 
                -- This is set to log2(C_PLB_NUM_MASTERS)
           
           C_PLB_NUM_MASTERS : Integer := 8;
                -- The number of Master Devices connected to the PLB bus
                -- Research this to find out default value
           
           C_PLB_AWIDTH : INTEGER := 32;  
                --  width of OPB Address Bus (in bits)
                    
           C_PLB_DWIDTH : INTEGER := 64;  
                --  Width of the OPB Data Bus (in bits)
                    
           C_PLB_CLK_PERIOD_PS : INTEGER := 10000;  
               --  The period of the OPB Bus clock in ps (10000 = 10ns)
                    
           C_IPIF_DWIDTH : INTEGER := 64;  
               --  Set this equal to largest data bus width needed by IPIF
               --  and IP elements.
                    
           C_IPIF_AWIDTH : INTEGER := 32;  
               --  Set this equal to C_PLB_AWIDTH
                    
           C_FAMILY : String := virtex2
               -- Select the target architecture type
               -- see the family.vhd package in the proc_common
               -- library
           );
  port (
  
    -- System signals ---------------------------------------------------------
    
        PLB_clk                 : in std_logic; 
                                
        Reset                   : in std_logic;
                                
        Freeze                  : in std_logic;
                                
        IP2INTC_Irpt            : out std_logic;
        
        
    -- Bus Slave signals ------------------------------------------------------   
    
        PLB_ABus                : in  std_logic_vector(0 to 
                                                       C_PLB_AWIDTH-1);
                                
        PLB_PAValid             : in  std_logic;
                                
        PLB_SAValid             : in  std_logic;
                                
        PLB_rdPrim              : in  std_logic;
                                
        PLB_wrPrim              : in  std_logic;
                                
        PLB_masterID            : in  std_logic_vector(0 to C_PLB_MID_WIDTH-1);
                                
        PLB_abort               : in  std_logic;
                                
        PLB_busLock             : in  std_logic;
                                
        PLB_RNW                 : in  std_logic;
                                
        PLB_BE                  : in  std_logic_vector(0 to 
                                                     (C_PLB_DWIDTH/8) - 1);
                                
        PLB_MSize               : in  std_logic_vector(0 to 1);
                                
        PLB_size                : in  std_logic_vector(0 to 3);
                                
        PLB_type                : in  std_logic_vector(0 to 2);
                                
        PLB_compress            : in  std_logic;
                                
        PLB_guarded             : in  std_logic;
                                
        PLB_ordered             : in  std_logic;
                                
        PLB_lockErr             : in  std_logic;
                                
        PLB_wrDBus              : in  std_logic_vector(0 to 
                                                       C_PLB_DWIDTH-1);
                                
        PLB_wrBurst             : in  std_logic;
                                
        PLB_rdBurst             : in  std_logic;
                                
        PLB_pendReq             : in  std_logic;
        
        PLB_pendPri             : in  std_logic_vector(0 to 1);
        
        PLB_reqPri              : in  std_logic_vector(0 to 1);
                                
        Sl_addrAck              : out std_logic;
                                
        Sl_SSize                : out std_logic_vector(0 to 1);
                                
        Sl_wait                 : out std_logic;
                                
        Sl_rearbitrate          : out std_logic;
                                
        Sl_wrDAck               : out std_logic;
                                
        Sl_wrComp               : out std_logic;
                                
        Sl_wrBTerm              : out std_logic;
                                
        Sl_rdDBus               : out std_logic_vector(0 to 
                                                       C_PLB_DWIDTH-1);
                                
        Sl_rdWdAddr             : out std_logic_vector(0 to 3);
                                
        Sl_rdDAck               : out std_logic;
                                
        Sl_rdComp               : out std_logic;
                                
        Sl_rdBTerm              : out std_logic;
                                
        Sl_MBusy                : out std_logic_vector(0 to 
                                                       C_PLB_NUM_MASTERS-1);
                                
        Sl_MErr                 : out std_logic_vector(0 to 
                                                       C_PLB_NUM_MASTERS-1);
        
        
    -- Bus Master Signals -----------------------------------------------------
        
        PLB_MAddrAck            : in  std_logic;
                                
        PLB_MSSize              : in  std_logic_vector(0 to 1);
                                
        PLB_MRearbitrate        : in  std_logic;
                                
        PLB_MBusy               : in  std_logic;
                                
        PLB_MErr                : in  std_logic;
                                
        PLB_MWrDAck             : in  std_logic;
                                
        PLB_MRdDBus             : in  std_logic_vector(0 to 
                                                      (C_PLB_DWIDTH-1));
                                
        PLB_MRdWdAddr           : in  std_logic_vector(0 to 3);
                                
        PLB_MRdDAck             : in  std_logic;
                                
        PLB_MRdBTerm            : in  std_logic;
                                
        PLB_MWrBTerm            : in  std_logic;
                                
        --PLB_pendReq             : in  std_logic;                  -- duplicate of Slave port ?????????
        
        --PLB_pendPri             : in  std_logic_vector(0 to 1);   -- duplicate of Slave port ?????????
        
        --PLB_reqPri              : in  std_logic_vector(0 to 1);   -- duplicate of Slave port ?????????
        
        M_request               : out std_logic;
                                
        M_priority              : out std_logic_vector(0 to 1);
                                
        M_buslock               : out std_logic;
                                
        M_RNW                   : out std_logic;
                                
        M_BE                    : out std_logic_vector(0 to 
                                                      (C_PLB_DWIDTH/8)-1);
                                
        M_MSize                 : out std_logic_vector(0 to 1);
                                
        M_size                  : out std_logic_vector(0 to 3);
                                
        M_type                  : out std_logic_vector(0 to 2);
                                
        M_compress              : out std_logic;
                                
        M_guarded               : out std_logic;
                                
        M_ordered               : out std_logic;
                                
        M_lockErr               : out std_logic;
                                
        M_abort                 : out std_logic;
                                                              
        M_ABus                  : out std_logic_vector(0 to C_PLB_AWIDTH-1);
                                
        M_wrDBus                : out std_logic_vector(0 to C_PLB_DWIDTH-1);
                                
        M_wrBurst               : out std_logic;
                                
        M_rdBurst               : out std_logic;
        
        
        
    -- IP Interconnect (IPIC) port signals -----------------------------------------
        
        
        --System Signals
        IP2Bus_Clk              : in  std_logic;
        
        Bus2IP_Clk              : out std_logic;
        
        Bus2IP_Reset            : out std_logic;
        
        Bus2IP_Freeze           : out std_logic;
        
        
        -- IP Slave signals
        IP2Bus_IntrEvent        : in  std_logic_vector(0 to C_IP_INTR_MODE_ARRAY'length - 1 );
        
        IP2Bus_Data             : in  std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
                                
        IP2Bus_WrAck            : in  std_logic;
                                
        IP2Bus_RdAck            : in  std_logic;
        
        IP2Bus_Retry            : in  std_logic;
        
        IP2Bus_Error            : in  std_logic;
        
        IP2Bus_ToutSup          : in  std_logic;
        
        IP2Bus_PostedWrInh      : In  std_logic;
        
        IP2Bus_Busy             : In  std_logic; -- new  PCI v1.00.e
        
        IP2Bus_AddrAck          : In std_logic;  -- new  PCI v1.00.e
        
        IP2Bus_BTerm            : In std_logic;  -- new  PCI v1.00.e
        
        Bus2IP_Addr             : out std_logic_vector(0 to C_IPIF_AWIDTH - 1 );
                                
        Bus2IP_Data             : out std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
                                
        Bus2IP_RNW              : out std_logic; 
        
        Bus2IP_BE               : out std_logic_vector(0 to (C_IPIF_DWIDTH/8) - 1 );
        
        Bus2IP_Burst            : out std_logic;
        
        Bus2IP_IBurst           : Out std_logic; -- new  PCI v1.00.e
        
        Bus2IP_WrReq            : out std_logic;
        
        Bus2IP_RdReq            : out std_logic;
        
        Bus2IP_RNW_Early        : Out std_logic; -- new  PCI v1.00.e
        
        Bus2IP_PselHit          : Out std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1); -- new  PCI v1.00.e
        
        Bus2IP_CS               : Out std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);

        Bus2IP_Des_sig          : Out std_logic;--JTK Dual DDR Hack--

        Bus2IP_CE               : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);  
        
        Bus2IP_RdCE             : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);  
        
        Bus2IP_WrCE             : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);   
      
        
        -- IP to DMA Support Signals (Length and Status FIFO I/O)
        IP2DMA_RxLength_Empty   : in  std_logic;
        
        IP2DMA_RxStatus_Empty   : in  std_logic;
        
        IP2DMA_TxLength_Full    : in  std_logic;
        
        IP2DMA_TxStatus_Empty   : in  std_logic;
        
        
        
        
        -- IP Master Signals
        IP2Bus_Addr             : in std_logic_vector(0 to C_IPIF_AWIDTH - 1 );
        
        IP2Bus_MstBE            : in std_logic_vector(0 to (C_IPIF_DWIDTH/8) - 1 );
        
        IP2IP_Addr              : in std_logic_vector(0 to C_IPIF_AWIDTH - 1 );
        
        IP2Bus_MstWrReq         : in std_logic;
        
        IP2Bus_MstRdReq         : in std_logic;
        
        IP2Bus_MstBurst         : in std_logic;
        
        IP2Bus_MstBusLock       : in std_logic;
        
        Bus2IP_MstWrAck         : out std_logic;
        
        Bus2IP_MstRdAck         : out std_logic;
        
        Bus2IP_MstRetry         : out std_logic;
        
        Bus2IP_MstError         : out std_logic;
        
        Bus2IP_MstTimeOut       : out std_logic;
        
        Bus2IP_MstLastAck       : out std_logic;
        
        
        -- RdPFIFO Signals
        IP2RFIFO_WrReq          : in std_logic;
        
        IP2RFIFO_Data           : in std_logic_vector(0 to find_id_dwidth(C_ARD_ID_ARRAY,
                                                                          C_ARD_DWIDTH_ARRAY,
                                                                          IPIF_RDFIFO_DATA,
                                                                          C_IPIF_DWIDTH)-1);
        
        IP2RFIFO_WrMark         : in std_logic;
        
        IP2RFIFO_WrRelease      : in std_logic;
        
        IP2RFIFO_WrRestore      : in std_logic;
        
        RFIFO2IP_WrAck          : out std_logic;
        
        RFIFO2IP_AlmostFull     : out std_logic;
        
        RFIFO2IP_Full           : out std_logic;
        
        RFIFO2IP_Vacancy        : out std_logic_vector(0 to log2(C_RDFIFO_DEPTH));
        
        
        
        -- WrPFIFO signals
        IP2WFIFO_RdReq          : in std_logic;
        
        IP2WFIFO_RdMark         : in std_logic;
        
        IP2WFIFO_RdRelease      : in std_logic;
        
        IP2WFIFO_RdRestore      : in std_logic;
        
        WFIFO2IP_Data           : out std_logic_vector(0 to find_id_dwidth(C_ARD_ID_ARRAY,
                                                                           C_ARD_DWIDTH_ARRAY,
                                                                           IPIF_WRFIFO_DATA,
                                                                           C_IPIF_DWIDTH)-1 );
        
        WFIFO2IP_RdAck          : out std_logic;
        
        WFIFO2IP_AlmostEmpty    : out std_logic;
        
        WFIFO2IP_Empty          : out std_logic;
        
        WFIFO2IP_Occupancy      : out std_logic_vector(0 to log2(C_WRFIFO_DEPTH) );
        
        
        -- IP DMA signals
        IP2Bus_DMA_Req          : in std_logic;
        
        Bus2IP_DMA_Ack          : out std_logic
        
        );
 
 
end plb_ipif;

 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Architecture


 
architecture implementation of plb_ipif is

 
 
 -- Functions
   -- (also see ipif_pkg and proc_common_pkg for other functions)
 
  
   -----------------------------------------------------------------------------
   -- Function set_ssize
   --
   -- This function is used to set the value of size based
   -- on the size of the input bus width parameter.
   -----------------------------------------------------------------------------
    function set_ssize (bus_width : integer) return integer is

       Variable size : Integer := 0;
       
    begin

       case bus_width is
         when 32 =>
             size := 0;
         when 64 =>
             size := 1;
         when 128 =>
             size := 2;
         when 256 =>
             size := 3;
         when others =>
             size := 0;
       end case;
              
       return(size);
                     
    end function set_ssize;

    
                   
                   
                   
 -- MIR Constants
  
  constant IPIF_MAJOR_VERSION : INTEGER range 0 to 15 := 1;  
            --  set Major Version of this IPIF here (reflected in IPIF MIR)
            --  Now set to Major Version 1 for v1
  
  constant IPIF_MINOR_VERSION : INTEGER range 0 to 127:= 0;  
            --  set Minor Version of this IPIF here (reflected in IPIF MIR)
            --  Example: 21(dec) = minor version '21'
            --  Now set to 00 for v1.00
  
  constant IPIF_REVISION : INTEGER := 4;  
            --  set Revision of this IPIF here (reflected in IPIF MIR)
            --  0 = a, 1 = b, 2 = c, etc.
            --  Now set to 4 (which is e) for v1.00.e
            
  constant IPIF_TYPE : INTEGER := 8;  
            --  set interface type for this IPIF here (reflected in IPIF MIR)
            --  Always 8 for PLB ipif interface type
  
  
  
 -- Other constants 
  
  constant LOGIC_LOW  : std_logic := '0';
  constant LOGIC_HIGH : std_logic := '0';

  Constant TARGET_VIRTEX_II : boolean := equalIgnoreCase(C_FAMILY, virtex2) or
                                         equalIgnoreCase(C_FAMILY, virtex2p) or
                                         equalIgnoreCase(C_FAMILY, spartan3);
           -- Detirmine the target device architecture from the C_FAMILY
           -- input Generic string. 
           -- A result of True = Virtex II type
           -- A result of false = Vertex and VirtexE                             
                                         
  Constant SSIZE_RESPONSE : integer := set_ssize(C_PLB_DWIDTH);
           -- The integer value of the encoded PLB Bus size to be returned
           -- on the Sl_Ssize output bus.
                                            
                                         
  Constant MIN_DBUS_WIDTH : integer := get_min_dwidth(C_ARD_DWIDTH_ARRAY);
           -- the smallest dbus width needing to be supported by byte steering
  
  Constant MAX_DBUS_WIDTH : integer := get_max_dwidth(C_ARD_DWIDTH_ARRAY);
           -- the largest dbus width needing to be supported by byte steering
  
                                             
                                             
  --constant SLN_BUFFER_DEPTH : INTEGER := C_DEV_MAX_BURST_SIZE / 4;  
  
  constant SLN_BUFFER_DEPTH  : INTEGER := C_DEV_MAX_BURST_SIZE / 8;  
            --  IPIF read buffer size for Burst reads (in bus words)
  
 --constant INT_DMA_REG_SIZE : INTEGER := C_DMA_CHAN_NUM * 64;
  
                        
 -- IPIF module inclusion constants derived from ARD name array
  Constant RESET_PRESENT     : boolean := find_ard_id(C_ARD_ID_ARRAY,
                                                      IPIF_RST);
  
  Constant INTERRUPT_PRESENT : boolean := find_ard_id(C_ARD_ID_ARRAY,
                                                      IPIF_INTR);
  
  Constant SESR_SEAR_PRESENT : boolean := find_ard_id(C_ARD_ID_ARRAY,
                                                      IPIF_SESR_SEAR);
  
  Constant DMA_PRESENT       : boolean := find_ard_id(C_ARD_ID_ARRAY,
                                                      IPIF_DMA_SG);
  
  Constant WRFIFO_PRESENT    : boolean := find_ard_id(C_ARD_ID_ARRAY,
                                                      IPIF_WRFIFO_DATA);
  
  Constant RDFIFO_PRESENT    : boolean := find_ard_id(C_ARD_ID_ARRAY,
                                                      IPIF_RDFIFO_DATA);
  
  
  
  Constant NUM_IPIF_IRPT_SRC : integer := 4;
               --  Number of IPIF Interrupts (DMA and FIFO)  (fixed at 4)
     

  -- Unconstrained generic array size calculations
  constant NUM_BASEADDRS     : integer := (C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2; 
  constant NUM_CE            : integer := calc_num_ce(C_ARD_NUM_CE_ARRAY);   
  
  
  -- Resolve other conditions based on presence of functions                      
  constant DEV_IS_SLAVE_ONLY : BOOLEAN := not(DMA_PRESENT or
                                          C_IP_MASTER_PRESENT);
  
  constant DEV_NEEDS_MASTER : BOOLEAN := DMA_PRESENT or C_IP_MASTER_PRESENT;
  
  -- DMA_REMOVAL!!   constant DMA_USE_BURST : BOOLEAN := C_DMA_ALLOW_BURST and C_DEV_BURST_ENABLE;
  
  Constant STEER_ADDR_SIZE : integer := 10;
  
  
-------------------------------------------------------------------------------                                                                               
-- Constants and types for autohookup of the read dbus and status reply  
-- bus from each of the read data and status sources.                                                                               
-------------------------------------------------------------------------------  
  Constant NUM_STATUS_REPLY_ELEMENTS : integer := 8;
  
  Constant ADDRACK_BIT : integer := 7;
  Constant BUSY_BIT    : integer := 6;
  Constant BTERM_BIT   : integer := 5;
  
  Constant ERROR_BIT   : integer := 4;
  Constant TOUTSUP_BIT : integer := 3;
  Constant RETRY_BIT   : integer := 2;
  Constant RDACK_BIT   : integer := 1;
  Constant WRACK_BIT   : integer := 0;
  
  Constant NUM_IPIF_RD_DBUSES : integer := cnt_ipif_id_blks(C_ARD_ID_ARRAY);
  
  -- declare a special type for read data bus hookup
  Type IPIF_READ_DBUS_TYPE  is ARRAY(0 TO NUM_IPIF_RD_DBUSES) of 
                                        std_logic_vector(0 to C_IPIF_DWIDTH-1);
                                        
  Type IPIF_STATUS_REPLY_TYPE is ARRAY(0 TO NUM_IPIF_RD_DBUSES) of 
                                        std_logic_vector(0 to 
                                        NUM_STATUS_REPLY_ELEMENTS-1);

 
 
 
 
-------------------------------------------------------------------------------   
-- XST workaround for port width constraint requirement in component declarations
   Constant CS_BUS_WIDTH : integer := NUM_BASEADDRS;
   Constant CE_BUS_WIDTH : integer := calc_num_ce(C_ARD_NUM_CE_ARRAY);
   
   
 
  
-------------------------------------------------------------------------------
-- Chipscope can be optioned in or out by setting this constant. 
--
-- /////////// Warning //////////////
--
-- If it is enabled, it must be properly specified and
-- connected at the bottom of this file. No other ICON blocks
-- can be present in the FPGA.
-------------------------------------------------------------------------------
  constant INCLUDE_CHIPSCOPE        : boolean   := false;
  
-------------------------------------------------------------------------------
 -- Signal declarations
 
  signal Sl_addrAck_i           : std_logic;
  signal Sl_SSize_i             : std_logic_vector(0 to 1);
  signal Sl_wait_i              : std_logic;
  signal Sl_rearbitrate_i       : std_logic;
  signal Sl_wrDAck_i            : std_logic;
  signal Sl_wrComp_i            : std_logic;
  signal Sl_wrBTerm_i           : std_logic;
  signal Sl_rdDBus_i            : std_logic_vector(0 to 
                                                   C_PLB_DWIDTH-1);
  signal Sl_rdWdAddr_i          : std_logic_vector(0 to 3);
  signal Sl_rdDAck_i            : std_logic;
  signal Sl_rdComp_i            : std_logic;
  signal Sl_rdBTerm_i           : std_logic;
  signal Sl_MBusy_i             : std_logic_vector(0 to 
                                                   C_PLB_NUM_MASTERS-1);
  signal Sl_MErr_i              : std_logic_vector(0 to 
                                                   C_PLB_NUM_MASTERS-1);
  
  --signal rdwdaddr_sa            : std_logic_vector(0 to 3);
  --signal SA2MUX_M_size_i        : std_logic_vector(0 to 3);
  --signal SA2MUX_ALoad_i         : std_logic;
  --signal Addr_Cntr_ClkEN_sa     : std_logic;
  --signal Addr_sel_sa            : std_logic_vector(0 to 1 );
  --signal Asyn_SRAM_RdCE         : std_logic;
  --signal Asyn_SRAM_WrCE         : std_logic;
  --signal Bus2IP_AValid_i        : std_logic;
  signal Bus2IP_Addr_i          : std_logic_vector(0 to C_IPIF_AWIDTH - 1 );
  Signal IP2Bus_AddrSel_i       : std_logic;
  --signal Bus2IP_Addr_full       : std_logic_vector(0 to C_PLB_AWIDTH - 1 );
  --signal Bus2IP_Addr_sa         : std_logic_vector(0 to C_PLB_AWIDTH - 1 );
  signal Bus2IP_BE_i            : std_logic_vector(0 to C_IPIF_DWIDTH/8 - 1 );
  signal SA2Steer_BE_i          : std_logic_vector(0 to C_IPIF_DWIDTH/8 - 1 );
  signal SA2Steer_Addr_full_i   : std_logic_vector(0 to C_IPIF_AWIDTH - 1 );
  signal SA2Steer_Addr_i        : std_logic_vector(0 to STEER_ADDR_SIZE - 1 );
  signal Bus2IP_BE_sa           : std_logic_vector(0 to C_IPIF_DWIDTH/8 - 1 );
  signal Bus2IP_Burst_i         : std_logic;
  signal Bus2IP_IBurst_i        : std_logic;
  signal Bus2IP_Clk_i           : std_logic;
  signal Bus2IP_Data_i          : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
  signal SA2Steer_Data_i        : std_logic_vector(0 to C_PLB_DWIDTH - 1 );
  signal Steer2SA_Data_i        : std_logic_vector(0 to C_PLB_DWIDTH - 1 );
  signal Bus2IP_Freeze_i        : std_logic;
  signal Bus2IP_MstError_i      : std_logic;
  signal Bus2IP_MstLastAck_i    : std_logic;
  signal Bus2IP_MstRdAck_i      : std_logic;
  signal Bus2IP_MstRetry_i      : std_logic;
  signal Bus2IP_MstTimeOut_i    : std_logic;
  signal Bus2IP_MstWrAck_i      : std_logic;
  --signal Bus2IP_RangeSel_i      : std_logic;
  signal Bus2IP_RdReq_i         : std_logic;
  signal Bus2IP_Reset_i         : std_logic;
  signal Bus2IP_RNW_i           : std_logic;
  signal Bus2IP_WrReq_i         : std_logic;
  signal Bus_MnGrant            : std_logic;
  signal Bus_Reset_i            : std_logic;
  --signal const_zero             : std_logic := '0';
  signal DMA2Bus_Addr           : std_logic_vector(0 to C_PLB_AWIDTH - 1 );
  signal DMA2Bus_Data           : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
  signal DMA2Intr_Intr          : std_logic_vector(0 to 1 );
  signal DMA2IP_Addr            : std_logic_vector(0 to C_PLB_AWIDTH - 1 );
  signal DMA_MstBE              : std_logic_vector(0 to (C_PLB_DWIDTH/8) - 1 );
  signal DMA_MstBurst           : std_logic;
  signal DMA_MstBusLock         : std_logic;
  signal DMA_MstRdReq           : std_logic;
  signal DMA_MstWrReq           : std_logic;
  signal DMA_SG_Error           : std_logic;
  signal DMA_SG_RdAck           : std_logic;
  signal DMA_SG_Retry           : std_logic;
  signal DMA_SG_ToutSup         : std_logic;
  signal DMA_SG_WrAck           : std_logic;
  signal IRPT2Bus_Data          : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
  signal Intr2Bus_DevIntr       : std_logic;
  signal Intr2Bus_Error         : std_logic;
  signal Intr2Bus_RdAck         : std_logic;
  signal Intr2Bus_Retry         : std_logic;
  signal Intr2Bus_ToutSup       : std_logic;
  signal Intr2Bus_WrAck         : std_logic;
  --signal MUX2Steer_Data_i       : std_logic_vector(0 to C_PLB_DWIDTH - 1 );
  --signal MUX2SA_Error_i         : std_logic;
  --signal MUX2SA_RdAck_i         : std_logic;
  --signal MUX2SA_Retry_i         : std_logic;
  --signal MUX2SA_ToutSup_i       : std_logic;
  --signal MUX2SA_WrAck_i         : std_logic;
  signal IPIF_Lvl_Interrupts    : std_logic_vector(0 to NUM_IPIF_IRPT_SRC-1);
  signal IPIF_Reg_Interrupts    : std_logic_vector(0 to 1 );
  signal MA2SA_num              : std_logic_vector(0 to 3 );
  signal MA2SA_Rd               : std_logic;
  signal MA2SA_select           : std_logic;
  signal MA2SA_XferAck          : std_logic;
  signal Mstr_sel_ma            : std_logic;
  --signal RdFIFO2Bus_Data        : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
  signal RdFIFO2Intr_DeadLock   : std_logic;
  signal RFIFO2DMA_AlmostEmpty  : std_logic;
  signal RFIFO2DMA_Empty        : std_logic;
  signal RFIFO2DMA_Occupancy    : std_logic_vector(0 to log2(C_RDFIFO_DEPTH));
  --signal RFIFO_Error            : std_logic;
  --signal RFIFO_RdAck            : std_logic;
  --signal RFIFO_Retry            : std_logic;
  --signal RFIFO_ToutSup          : std_logic;
  --signal RFIFO_WrAck            : std_logic;
  --signal Reset2Bus_DBus         : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
  --signal Rst2Bus_Error          : std_logic;
  --signal Rst2Bus_RdAck          : std_logic;
  --signal Rst2Bus_Retry          : std_logic;
  --signal Rst2Bus_ToutSup        : std_logic;
  --signal Rst2Bus_WrAck          : std_logic;
  signal SA2MA_RdRdy            : std_logic;
  signal SA2MA_WrAck            : std_ulogic;
  signal SA2MA_Retry            : std_logic;
  signal SA2MA_ErrAck           : std_logic;
  --Signal SesrSear2Bus_DBus      : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
  --Signal SesrSear2Bus_RdAck     : std_logic;
  --Signal SesrSear2Bus_WrACK     : std_logic;
  --Signal SesrSear2Bus_Error     : std_logic;
  --Signal SesrSear2Bus_ToutSup   : std_logic;
  --Signal SesrSear2Bus_Retry     : std_logic;
  signal WFIFO2DMA_AlmostFull   : std_logic;
  signal WFIFO2DMA_Full         : std_logic;
  signal WFIFO2DMA_Vacancy      : std_logic_vector(0 to log2(C_WRFIFO_DEPTH));
  --signal WFIFO_Error            : std_logic;
  --signal WFIFO_RdAck            : std_logic;
  --signal WFIFO_Retry            : std_logic;
  --signal WFIFO_ToutSup          : std_logic;
  --signal WFIFO_WrAck            : std_logic;
  --signal WrFIFO2Bus_Data        : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
  signal WrFIFO2Intr_DeadLock   : std_logic;
  
  -- PLB added signals
  signal SA2INT_DAck_Timeout_i  : std_logic;
  Signal Bus2IP_DWidth_i        : std_logic_vector(0 to 2);
  Signal Bus2IP_size_i          : std_logic_vector(0 to 3);
  Signal Bus2IP_SSize_i         : std_logic_vector(0 to 1);
  Signal Bus2IP_RNW_Early_i     : std_logic; -- new PCI
  Signal Bus2IP_PselHit_i       : std_logic_vector(0 to NUM_BASEADDRS-1); -- new PCI
  signal Bus2IP_CS_i            : std_logic_vector(0 to NUM_BASEADDRS-1);
  signal Bus2IP_Des_sig_i       : std_logic; --JTK Dual DDR Hack--
  signal Bus2IP_CE_i            : std_logic_vector(0 to NUM_CE-1);  
  signal Bus2IP_RdCE_i          : std_logic_vector(0 to NUM_CE-1);  
  signal Bus2IP_WrCE_i          : std_logic_vector(0 to NUM_CE-1);   
  Signal Bus2IP_masterID_i      : std_logic_vector(0 to C_PLB_MID_WIDTH-1);
  Signal Bus2IP_type_i          : std_logic_vector(0 to 2);
  
  -- Auto hookup support for read dbus and status reply
  Signal read_dbus_array    : IPIF_READ_DBUS_TYPE;
  Signal status_reply_array : IPIF_STATUS_REPLY_TYPE;
  Signal ip_status_reply    : std_logic_vector(0 to 
                                               NUM_STATUS_REPLY_ELEMENTS-1);
  Signal status_reply_bus   : std_logic_vector(0 to 
                                    ((NUM_IPIF_RD_DBUSES+1)*
                                      NUM_STATUS_REPLY_ELEMENTS)-1);
  Signal status_reply_or    : std_logic_vector(0 to 
                                               NUM_STATUS_REPLY_ELEMENTS-1);
  Signal rd_data_wide_bus   : std_logic_vector(0 to 
                                      ((NUM_IPIF_RD_DBUSES+1)*
                                      C_IPIF_DWIDTH)-1);
  Signal read_data_or       : std_logic_vector(0 to C_IPIF_DWIDTH-1);
  
  
-------------------------------------------------------------------------------  
-- components 
  
--   component plb_slave_attachment_wrbuf is
--       generic (
--           C_REG_CS_CE             : Boolean;
--           C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE;
--           C_ARD_DWIDTH_ARRAY      : INTEGER_ARRAY_TYPE;
--           C_ARD_NUM_CE_ARRAY      : INTEGER_ARRAY_TYPE;
--           C_PLB_NUM_MASTERS       : integer; --*** PLB
--           C_PLB_MID_WIDTH         : integer; --*** PLB
--           C_PLB_ABUS_WIDTH        : integer; --*** PLB
--           C_PLB_DBUS_WIDTH        : integer; --*** PLB
--           C_IPIF_ABUS_WIDTH       : integer;
--           C_IPIF_DBUS_WIDTH       : integer;
--           C_SL_ATT_ADDR_SEL_WIDTH : integer;
--           C_SUPPORT_BURST         : boolean;
--           C_BURST_PAGE_SIZE       : Integer;
--           C_MA2SA_NUM_WIDTH       : integer;
--           C_SLN_BUFFER_DEPTH      : integer;
--           C_DPHASE_TIMEOUT        : Integer   --*** PLB
--           );
--       port(
--           --System signals
--           Bus_Reset       : in std_logic;
--           Bus_Clk         : in std_logic;
--
--           -- PLB Bus signals
--           PLB_ABus        : in  std_logic_vector(0 to C_PLB_ABUS_WIDTH-1);
--           PLB_PAValid     : in  std_logic;
--           PLB_SAValid     : in  std_logic;
--           PLB_rdPrim      : in  std_logic;
--           PLB_wrPrim      : in  std_logic;
--           PLB_masterID    : in  std_logic_vector(0 to C_PLB_MID_WIDTH-1);
--           PLB_abort       : in  std_logic;
--           PLB_busLock     : in  std_logic;
--           PLB_RNW         : in  std_logic;
--           PLB_BE          : in  std_logic_vector(0 to (C_PLB_DBUS_WIDTH/8)-1);
--           PLB_Msize       : in  std_logic_vector(0 to 1);
--           PLB_size        : in  std_logic_vector(0 to 3);
--           PLB_type        : in  std_logic_vector(0 to 2);
--           PLB_compress    : in  std_logic;
--           PLB_guarded     : in  std_logic;
--           PLB_ordered     : in  std_logic;
--           PLB_lockErr     : in  std_logic;
--           PLB_wrDBus      : in  std_logic_vector(0 to C_PLB_DBUS_WIDTH-1);
--           PLB_wrBurst     : in  std_logic;
--           PLB_rdBurst     : in  std_logic;
--           PLB_pendReq     : in  std_logic;
--           PLB_pendPri     : in  std_logic_vector(0 to 1);
--           PLB_reqPri      : in  std_logic_vector(0 to 1);
--           Sl_addrAck      : out std_logic;
--           Sl_SSize        : out std_logic_vector(0 to 1);
--           Sl_wait         : out std_logic;
--           Sl_rearbitrate  : out std_logic;
--           Sl_wrDAck       : out std_logic;
--           Sl_wrComp       : out std_logic;
--           Sl_wrBTerm      : out std_logic;
--           Sl_rdDBus       : out std_logic_vector(0 to C_PLB_DBUS_WIDTH-1);
--           Sl_rdWdAddr     : out std_logic_vector(0 to 3);
--           Sl_rdDAck       : out std_logic;
--           Sl_rdComp       : out std_logic;
--           Sl_rdBTerm      : out std_logic;
--           Sl_MBusy        : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
--           Sl_MErr         : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
--
--           -- Master Attachment Signals
--           MA2SA_Select    : in std_logic;
--           MA2SA_XferAck   : in std_logic;
--           MA2SA_Rd        : in std_logic;
--           MA2SA_Num       : in std_logic_vector(0 to C_MA2SA_NUM_WIDTH-1);
--           SA2MA_RdRdy     : out std_logic;
--           SA2MA_WrAck     : out std_logic;
--           SA2MA_Retry     : out std_logic;
--           SA2MA_ErrAck    : out std_logic;
--
--
--           -- Controls to the IP/IPIF modules
--           Bus2IP_AValid   : Out std_logic;                   -- ***PLB
--           Bus2IP_masterID : Out std_logic_vector(0 to C_PLB_MID_WIDTH-1);  -- ***PLB future
--           --Bus2IP_Msize    : Out std_logic_vector(0 to 1);  -- ***PLB future
--           Bus2IP_Ssize    : Out std_logic_vector(0 to 1);  -- ***PLB future
--           Bus2IP_size     : Out std_logic_vector(0 to 3);  -- ***PLB future
--           Bus2IP_type     : Out std_logic_vector(0 to 2);  -- ***PLB future
--           --Bus2IP_lockErr  : out std_logic;                 -- ***PLB future
--
--           Bus2IP_Addr     : out std_logic_vector(0 to C_PLB_ABUS_WIDTH-1);
--           Bus2IP_Burst    : out std_logic;
--           Bus2IP_RNW      : out std_logic;
--           Bus2IP_BE       : out std_logic_vector(0 to C_IPIF_DBUS_WIDTH/8-1);
--           Bus2IP_WrReq    : out std_logic;
--           Bus2IP_RdReq    : out std_logic;
--           Bus2IP_CS       : Out std_logic_vector(0 to CS_BUS_WIDTH-1);
--           Bus2IP_DWidth   : Out std_logic_vector(0 to 2);
--           Bus2IP_CE       : out std_logic_vector(0 to CE_BUS_WIDTH-1);
--           Bus2IP_RdCE     : out std_logic_vector(0 to CE_BUS_WIDTH-1);
--           Bus2IP_WrCE     : out std_logic_vector(0 to CE_BUS_WIDTH-1);
--
--           -- Write Data bus output to the IP/IPIF modules
--           Bus2IP_Data     : out std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
--
--           --Inputs from the Read Data Bus Mux
--           MUX2SA_Data     : in std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
--
--           -- Inputs from the Status Reply Mux
--           MUX2SA_AddrSel  : In std_logic;     -- ***PLB
--           MUX2SA_WrAck    : in std_logic;
--           MUX2SA_RdAck    : in std_logic;
--           MUX2SA_ErrAck   : in std_logic;
--           MUX2SA_ToutSup  : in std_logic;
--           MUX2SA_Retry    : in std_logic;
--
--           -- Data Acknowledge Timeout Error to Interrupt Module
--           SA2INT_DAck_Timeout : Out std_logic
--           );
--   end component plb_slave_attachment_wrbuf;
  
-- Obsoleted  component plb_slave_attachment_dtime is
-- Obsoleted      generic (
-- Obsoleted          C_REG_CS_CE             : Boolean;
-- Obsoleted  		C_STEER_ADDR_SIZE       : integer;
-- Obsoleted          C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE;
-- Obsoleted          C_ARD_DWIDTH_ARRAY      : INTEGER_ARRAY_TYPE;
-- Obsoleted          C_ARD_NUM_CE_ARRAY      : INTEGER_ARRAY_TYPE;
-- Obsoleted          C_ARD_DTIME_READ_ARRAY  : INTEGER_ARRAY_TYPE;
-- Obsoleted          C_ARD_DTIME_WRITE_ARRAY : INTEGER_ARRAY_TYPE;
-- Obsoleted          C_PLB_NUM_MASTERS       : integer; --*** PLB
-- Obsoleted          C_PLB_MID_WIDTH         : integer; --*** PLB
-- Obsoleted          C_PLB_ABUS_WIDTH        : integer; --*** PLB
-- Obsoleted          C_PLB_DBUS_WIDTH        : integer; --*** PLB
-- Obsoleted          C_IPIF_ABUS_WIDTH       : integer;
-- Obsoleted          C_IPIF_DBUS_WIDTH       : integer;
-- Obsoleted          C_SL_ATT_ADDR_SEL_WIDTH : integer;
-- Obsoleted          C_SUPPORT_BURST         : boolean;
-- Obsoleted          C_FAST_DATA_XFER        : Boolean;
-- Obsoleted          C_BURST_PAGE_SIZE       : Integer;
-- Obsoleted          C_MA2SA_NUM_WIDTH       : integer;
-- Obsoleted          C_SLN_BUFFER_DEPTH      : integer;
-- Obsoleted          C_DPHASE_TIMEOUT        : Integer   --*** PLB
-- Obsoleted          );
-- Obsoleted      port(
-- Obsoleted          --System signals
-- Obsoleted          Bus_Reset       : in std_logic;
-- Obsoleted          Bus_Clk         : in std_logic;
-- Obsoleted  
-- Obsoleted          -- PLB Bus signals
-- Obsoleted          PLB_ABus        : in  std_logic_vector(0 to C_PLB_ABUS_WIDTH-1);
-- Obsoleted          PLB_PAValid     : in  std_logic;
-- Obsoleted          PLB_SAValid     : in  std_logic;
-- Obsoleted          PLB_rdPrim      : in  std_logic;
-- Obsoleted          PLB_wrPrim      : in  std_logic;
-- Obsoleted          PLB_masterID    : in  std_logic_vector(0 to C_PLB_MID_WIDTH-1);
-- Obsoleted          PLB_abort       : in  std_logic;
-- Obsoleted          PLB_busLock     : in  std_logic;
-- Obsoleted          PLB_RNW         : in  std_logic;
-- Obsoleted          PLB_BE          : in  std_logic_vector(0 to (C_PLB_DBUS_WIDTH/8)-1);
-- Obsoleted          PLB_Msize       : in  std_logic_vector(0 to 1);
-- Obsoleted          PLB_size        : in  std_logic_vector(0 to 3);
-- Obsoleted          PLB_type        : in  std_logic_vector(0 to 2);
-- Obsoleted          PLB_compress    : in  std_logic;
-- Obsoleted          PLB_guarded     : in  std_logic;
-- Obsoleted          PLB_ordered     : in  std_logic;
-- Obsoleted          PLB_lockErr     : in  std_logic;
-- Obsoleted          PLB_wrDBus      : in  std_logic_vector(0 to C_PLB_DBUS_WIDTH-1);
-- Obsoleted          PLB_wrBurst     : in  std_logic;
-- Obsoleted          PLB_rdBurst     : in  std_logic;
-- Obsoleted          PLB_pendReq     : in  std_logic;
-- Obsoleted          PLB_pendPri     : in  std_logic_vector(0 to 1);
-- Obsoleted          PLB_reqPri      : in  std_logic_vector(0 to 1);
-- Obsoleted          Sl_addrAck      : out std_logic;
-- Obsoleted          Sl_SSize        : out std_logic_vector(0 to 1);
-- Obsoleted          Sl_wait         : out std_logic;
-- Obsoleted          Sl_rearbitrate  : out std_logic;
-- Obsoleted          Sl_wrDAck       : out std_logic;
-- Obsoleted          Sl_wrComp       : out std_logic;
-- Obsoleted          Sl_wrBTerm      : out std_logic;
-- Obsoleted          Sl_rdDBus       : out std_logic_vector(0 to C_PLB_DBUS_WIDTH-1);
-- Obsoleted          Sl_rdWdAddr     : out std_logic_vector(0 to 3);
-- Obsoleted          Sl_rdDAck       : out std_logic;
-- Obsoleted          Sl_rdComp       : out std_logic;
-- Obsoleted          Sl_rdBTerm      : out std_logic;
-- Obsoleted          Sl_MBusy        : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
-- Obsoleted          Sl_MErr         : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
-- Obsoleted  
-- Obsoleted          -- Master Attachment Signals
-- Obsoleted          MA2SA_Select    : in std_logic;
-- Obsoleted          MA2SA_XferAck   : in std_logic;
-- Obsoleted          MA2SA_Rd        : in std_logic;
-- Obsoleted          MA2SA_Num       : in std_logic_vector(0 to C_MA2SA_NUM_WIDTH-1);
-- Obsoleted          SA2MA_RdRdy     : out std_logic;
-- Obsoleted          SA2MA_WrAck     : out std_logic;
-- Obsoleted          SA2MA_Retry     : out std_logic;
-- Obsoleted          SA2MA_ErrAck    : out std_logic;
-- Obsoleted  
-- Obsoleted          -- Controls to the Byte Steering Module
-- Obsoleted          SA2Steer_Addr   : Out std_logic_vector(0 to C_STEER_ADDR_SIZE-1);
-- Obsoleted          SA2Steer_BE     : Out std_logic_vector(0 to C_IPIF_DBUS_WIDTH/8-1);
-- Obsoleted          
-- Obsoleted          -- Controls to the IP/IPIF modules
-- Obsoleted          --Bus2IP_AValid   : Out std_logic;                   -- ***PLB
-- Obsoleted          Bus2IP_masterID : Out std_logic_vector(0 to C_PLB_MID_WIDTH-1);  -- ***PLB future
-- Obsoleted          --Bus2IP_Msize    : Out std_logic_vector(0 to 1);  -- ***PLB future
-- Obsoleted          Bus2IP_Ssize    : Out std_logic_vector(0 to 1);  -- ***PLB future
-- Obsoleted          Bus2IP_size     : Out std_logic_vector(0 to 3);  -- ***PLB future
-- Obsoleted          Bus2IP_type     : Out std_logic_vector(0 to 2);  -- ***PLB future
-- Obsoleted          --Bus2IP_lockErr  : out std_logic;                 -- ***PLB future
-- Obsoleted  
-- Obsoleted          Bus2IP_Addr     : out std_logic_vector(0 to C_PLB_ABUS_WIDTH-1);
-- Obsoleted          Bus2IP_Burst    : out std_logic;
-- Obsoleted          Bus2IP_RNW      : out std_logic;
-- Obsoleted          Bus2IP_BE       : out std_logic_vector(0 to C_IPIF_DBUS_WIDTH/8-1);
-- Obsoleted          Bus2IP_WrReq    : out std_logic;
-- Obsoleted          Bus2IP_RdReq    : out std_logic;
-- Obsoleted          Bus2IP_CS       : Out std_logic_vector(0 to CS_BUS_WIDTH-1);
-- Obsoleted          Bus2IP_DWidth   : Out std_logic_vector(0 to 2);
-- Obsoleted          Bus2IP_CE       : out std_logic_vector(0 to CE_BUS_WIDTH-1);
-- Obsoleted          Bus2IP_RdCE     : out std_logic_vector(0 to CE_BUS_WIDTH-1);
-- Obsoleted          Bus2IP_WrCE     : out std_logic_vector(0 to CE_BUS_WIDTH-1);
-- Obsoleted  
-- Obsoleted          -- Write Data bus output to the IP/IPIF modules
-- Obsoleted          Bus2IP_Data     : out std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
-- Obsoleted  
-- Obsoleted          --Inputs from the Read Data Bus Mux
-- Obsoleted          MUX2SA_Data     : in std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
-- Obsoleted  
-- Obsoleted          -- Inputs from the Status Reply Mux
-- Obsoleted          --MUX2SA_AddrSel  : In std_logic;     -- ***PLB
-- Obsoleted          MUX2SA_WrAck    : in std_logic;
-- Obsoleted          MUX2SA_RdAck    : in std_logic;
-- Obsoleted          MUX2SA_ErrAck   : in std_logic;
-- Obsoleted          MUX2SA_ToutSup  : in std_logic;
-- Obsoleted          MUX2SA_Retry    : in std_logic;
-- Obsoleted          
-- Obsoleted          -- IP Busy input
-- Obsoleted          IP2Bus_Busy     : In std_logic;
-- Obsoleted  
-- Obsoleted          -- Data Acknowledge Timeout Error to Interrupt Module
-- Obsoleted          SA2INT_DAck_Timeout : Out std_logic
-- Obsoleted          );
-- Obsoleted  end component plb_slave_attachment_dtime;

 
  
   component plb_slave_attachment_indet is
       generic (
           C_STEER_ADDR_SIZE : Integer := 10;
                   
           C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE :=
              (
               X"0000_0000_1000_0000", -- IPIF Interrupt base address
               X"0000_0000_1000_01FF", -- IPIF Interrupt high address
               X"0000_0000_1000_0200", -- IPIF Reset base address
               X"0000_0000_1000_02FF", -- IPIF Reset high address
               X"0000_0000_1000_2000", -- IPIF WrFIFO Registers base address
               X"0000_0000_1000_20FF", -- IPIF WrFIFO Registers high address
               X"0000_0000_1000_2100", -- IPIF WrFIFO Data base address 
               X"0000_0000_1000_21ff", -- IPIF WrFIFO Data high address 
               X"0000_0000_1000_2200", -- IPIF RdFIFO Registers base address
               X"0000_0000_1000_22FF", -- IPIF RdFIFO Registers high address
               X"0000_0000_1000_2300", -- IPIF RdFIFO Data base address     
               X"0000_0000_1000_23FF", -- IPIF RdFIFO Data high address     
               X"0000_0000_7000_0000", -- IP Registers base address 
               X"0000_0000_7000_00FF", -- IP Registers high address 
               X"0000_0000_8000_0000", -- IP user0 base address 
               X"0000_0000_8FFF_FFFF", -- IP user0 high address 
               X"0000_0000_9000_0000", -- IP user1 base address
               X"0000_0000_9FFF_FFFF"  -- IP user1 high address
              );
                   
           C_ARD_DWIDTH_ARRAY     : INTEGER_ARRAY_TYPE :=
              (
               32,    -- IPIF Interrupt data width
               32,    -- IPIF Reset data width
               32,    -- IPIF WrFIFO Registers data width
               64,    -- IPIF WrFIFO Data data width
               32,    -- IPIF RdFIFO Registers data width
               64,    -- IPIF RdFIFO Data width
               32,    -- IP Registers data width
               64,    -- User0 data width
               8      -- User1 data width
              );
                   
           C_ARD_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE :=
              (
               16,    -- IPIF Interrupt CE Number
               1,     -- IPIF Reset CE Number
               2,     -- IPIF WrFIFO Registers CE Number
               1,     -- IPIF WrFIFO Data data CE Number
               2,     -- IPIF RdFIFO Registers CE Number
               1,     -- IPIF RdFIFO Data CE Number
               8,     -- IP Registers CE Number
               1,     -- User0 CE Number
               1      -- User1 CE Number
              );
      
           
           C_PLB_NUM_MASTERS       : integer := 8;  
           C_PLB_MID_WIDTH         : Integer := 3;  
           C_PLB_ABUS_WIDTH        : integer := 32;        
           C_PLB_DBUS_WIDTH        : integer := 64;           
           C_IPIF_ABUS_WIDTH       : integer := 32;           
           C_IPIF_DBUS_WIDTH       : integer := 64;
           C_SL_ATT_ADDR_SEL_WIDTH : integer := 2;           
           C_SUPPORT_BURST         : boolean := false;
           C_FAST_DATA_XFER        : Boolean := false;
           C_BURST_PAGE_SIZE       : Integer := 1024;
           C_MA2SA_NUM_WIDTH       : integer := 4;       
           C_SLN_BUFFER_DEPTH      : integer := 8;
           C_DPHASE_TIMEOUT        : Integer := 64   
           );
       port(        
           --System signals
           Bus_Reset        : in std_logic;
           Bus_Clk          : in std_logic;
           
           -- PLB Bus signals
           PLB_ABus         : in  std_logic_vector(0 to C_PLB_ABUS_WIDTH-1);
           PLB_PAValid      : in  std_logic;
           PLB_SAValid      : in  std_logic;
           PLB_rdPrim       : in  std_logic;
           PLB_wrPrim       : in  std_logic;
           PLB_masterID     : in  std_logic_vector(0 to C_PLB_MID_WIDTH -1);
           PLB_abort        : in  std_logic;
           PLB_busLock      : in  std_logic;
           PLB_RNW          : in  std_logic;
           PLB_BE           : in  std_logic_vector(0 to (C_PLB_DBUS_WIDTH/8)-1);
           PLB_Msize        : in  std_logic_vector(0 to 1);
           PLB_size         : in  std_logic_vector(0 to 3);
           PLB_type         : in  std_logic_vector(0 to 2);
           PLB_compress     : in  std_logic;
           PLB_guarded      : in  std_logic;
           PLB_ordered      : in  std_logic;
           PLB_lockErr      : in  std_logic;
           PLB_wrDBus       : in  std_logic_vector(0 to C_PLB_DBUS_WIDTH-1);
           PLB_wrBurst      : in  std_logic;
           PLB_rdBurst      : in  std_logic;
           PLB_pendReq      : in  std_logic;
           PLB_pendPri      : in  std_logic_vector(0 to 1);
           PLB_reqPri       : in  std_logic_vector(0 to 1);
           Sl_addrAck       : out std_logic;
           Sl_SSize         : out std_logic_vector(0 to 1);
           Sl_wait          : out std_logic;
           Sl_rearbitrate   : out std_logic;
           Sl_wrDAck        : out std_logic;
           Sl_wrComp        : out std_logic;
           Sl_wrBTerm       : out std_logic;
           Sl_rdDBus        : out std_logic_vector(0 to C_PLB_DBUS_WIDTH-1);
           Sl_rdWdAddr      : out std_logic_vector(0 to 3);
           Sl_rdDAck        : out std_logic;
           Sl_rdComp        : out std_logic;
           Sl_rdBTerm       : out std_logic;
           Sl_MBusy         : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
           Sl_MErr          : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);
           
           -- Master Attachment Signals
           MA2SA_Select     : in std_logic := '0';
           MA2SA_XferAck    : in std_logic := '0';
           MA2SA_Rd         : in std_logic := '0';
           MA2SA_Num        : in std_logic_vector(0 to C_MA2SA_NUM_WIDTH-1)
                                 := (others => '0');
           SA2MA_RdRdy      : out std_logic;
           SA2MA_WrAck      : out std_logic;
           SA2MA_Retry      : out std_logic;
           SA2MA_ErrAck     : out std_logic;
           
           -- Controls to the Byte Steering Module
           SA2Steer_Addr    : Out std_logic_vector(0 to C_STEER_ADDR_SIZE-1);
           SA2Steer_BE      : Out std_logic_vector(0 to C_IPIF_DBUS_WIDTH/8-1);
           
           -- Controls to the IP/IPIF modules
           Bus2IP_masterID  : Out std_logic_vector(0 to C_PLB_MID_WIDTH-1);  -- ***PLB future
           --Bus2IP_Msize     : Out std_logic_vector(0 to 1);  -- ***PLB future
           Bus2IP_Ssize     : Out std_logic_vector(0 to 1);  -- ***PLB future
           Bus2IP_size      : Out std_logic_vector(0 to 3);  -- ***PLB future
           Bus2IP_type      : Out std_logic_vector(0 to 2);  -- ***PLB future
           --Bus2IP_lockErr  : out std_logic;                 -- ***PLB future
           
           Bus2IP_Addr      : out std_logic_vector (0 to C_PLB_ABUS_WIDTH-1);
           Bus2IP_Burst     : out std_logic;
           Bus2IP_IBurst    : Out std_logic;
           Bus2IP_RNW       : out std_logic;
           Bus2IP_BE        : out std_logic_vector (0 to C_IPIF_DBUS_WIDTH/8-1);
           Bus2IP_WrReq     : out std_logic;
           Bus2IP_RdReq     : out std_logic;
           Bus2IP_RNW_Early : Out std_logic; -- new PCI
           Bus2IP_PselHit   : Out std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1); -- new PCI
           Bus2IP_CS        : Out std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
           Bus2IP_Des_sig   : Out std_logic;--JTK Dual DDR Hack--
           Bus2IP_DWidth    : Out std_logic_vector(0 to 2);                              
           Bus2IP_CE        : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);  
           Bus2IP_RdCE      : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);  
           Bus2IP_WrCE      : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);   
           
           -- Write Data bus output to the IP/IPIF modules
           Bus2IP_Data      : out std_logic_vector (0 to C_IPIF_DBUS_WIDTH-1);
           
           --Inputs from the Read Data Bus Mux
           MUX2SA_Data      : in std_logic_vector (0 to C_IPIF_DBUS_WIDTH-1);
           
           -- Inputs from the Status Reply Mux
           --MUX2SA_AddrSel  : In std_logic;
           MUX2SA_AddrAck   : In std_logic; -- new
           MUX2SA_Busy      : In std_logic; -- new
           MUX2SA_BTerm     : In std_logic; -- new
           MUX2SA_WrAck     : in std_logic;
           MUX2SA_RdAck     : in std_logic;
           MUX2SA_ErrAck    : in std_logic;
           MUX2SA_ToutSup   : in std_logic;
           MUX2SA_Retry     : in std_logic;
           
           -- IP Busy input
           --IP2Bus_Busy     : In std_logic;
           
           -- Data Acknowledge Timeout Error to Interrupt Module
           SA2INT_DAck_Timeout : Out std_logic
           );
   end component plb_slave_attachment_indet;





  Component ipif_steer
   generic (
     C_DWIDTH    : integer;   -- 8, 16, 32, 64, 128, 256, or 512
 	 C_SMALLEST  : integer;   -- 8, 16, 32, 64, 128, 256, or 512
     C_AWIDTH    : integer
     );   
   port (
     Wr_Data_In  : in  std_logic_vector(0 to C_DWIDTH-1);    
     Rd_Data_In  : in  std_logic_vector(0 to C_DWIDTH-1);    
     Addr        : in  std_logic_vector(0 to C_AWIDTH-1);    
     BE_In       : in  std_logic_vector(0 to (C_DWIDTH/8)-1);
     Decode_size : in  std_logic_vector(0 to 2);             
     Wr_Data_Out : out std_logic_vector(0 to C_DWIDTH-1);    
     Rd_Data_Out : out std_logic_vector(0 to C_DWIDTH-1);    
     BE_Out      : out std_logic_vector(0 to (C_DWIDTH/8)-1) 
     );
  end component; -- ipif_steer



  component or_gate is
    generic (
      C_OR_WIDTH   : natural;
      C_BUS_WIDTH  : natural;
      C_USE_LUT_OR : boolean
      );
    port (
      A : in  std_logic_vector(0 to C_OR_WIDTH*C_BUS_WIDTH-1);
      Y : out std_logic_vector(0 to C_BUS_WIDTH-1)
      );
  end component or_gate;




-------------------------------------------------------------------------------
-- Begin architecture logic 
-------------------------------------------------------------------------------
begin

 --////////// Future Work ////////////////////////////////
 
 -- Perform consistency checks here 

  -- synthesis translate_off

     -- tbd consistancy checks
  
  -- synthesis translate_on
 
      

-------------------------------------------------------------------------------
-- Automatic Status Reply connect (replaces the SRMUX component)

      
-- Build the status reply to the Slave attachment
-------------------------------------------------------------------------------
 ip_status_reply(ADDRACK_BIT) <= IP2Bus_AddrAck;
 ip_status_reply(BUSY_BIT)    <= IP2Bus_Busy;
 ip_status_reply(BTERM_BIT)   <= IP2Bus_BTerm;
 
 ip_status_reply(WRACK_BIT)   <= IP2Bus_WrAck;
 ip_status_reply(RDACK_BIT)   <= IP2Bus_RdAck;
 ip_status_reply(RETRY_BIT)   <= IP2Bus_Retry;
 ip_status_reply(ERROR_BIT)   <= IP2Bus_Error;
 ip_status_reply(TOUTSUP_BIT) <= IP2Bus_ToutSup;

 -- Assign the IP status reply to the last array index
 status_reply_array(NUM_IPIF_RD_DBUSES) <= ip_status_reply;



  BUILD_SR_BUS : process (status_reply_array)
    Begin
       for i in 0 to NUM_IPIF_RD_DBUSES loop
    
          status_reply_bus(NUM_STATUS_REPLY_ELEMENTS*i to 
                           NUM_STATUS_REPLY_ELEMENTS*i+
                          (NUM_STATUS_REPLY_ELEMENTS-1)) 
                          <= status_reply_array(i);
         
       End loop; 
    
    End process; -- BUILD_SR_BUS



   I_OR_STATUS :  or_gate 
     generic map(
       C_OR_WIDTH   => NUM_IPIF_RD_DBUSES+1,
       C_BUS_WIDTH  => NUM_STATUS_REPLY_ELEMENTS,
       C_USE_LUT_OR => TRUE
       )
     port map(
       A => status_reply_bus,
       Y => status_reply_or
       );



-------------------------------------------------------------------------------
      
-------------------------------------------------------------------------------
-- Automatic Read Data bus connect (replaces the plb_ip2bus_dmux component)



  
-- Build the read dbus to the byte steer module
-------------------------------------------------------------------------------
 -- assign the IP read debus to the last array index
 read_dbus_array(NUM_IPIF_RD_DBUSES) <= IP2Bus_Data;


  BUILD_RD_DATA_BUS : process (read_dbus_array)
    Begin
       for i in 0 to NUM_IPIF_RD_DBUSES loop
    
          rd_data_wide_bus(C_IPIF_DWIDTH*i to 
                           C_IPIF_DWIDTH*i+
                          (C_IPIF_DWIDTH-1)) 
                          <= read_dbus_array(i);
         
       End loop; 
    
    End process; -- BUILD_RD_DATA_BUS



   I_OR_DATA :  or_gate 
     generic map(
       C_OR_WIDTH   => NUM_IPIF_RD_DBUSES+1,
       C_BUS_WIDTH  => C_IPIF_DWIDTH,
       C_USE_LUT_OR => TRUE
       )
     port map(
       A => rd_data_wide_bus,
       Y => read_data_or
       );



                                    
-------------------------------------------------------------------------------




      
 ------------------------------------------------------------------------------                       
 -- No master attachment in this version of PLB IPIF so always omit it.

  REMOVE_MASTER : if (DEV_NEEDS_MASTER = False or
                      DEV_NEEDS_MASTER = True) generate
    
        M_request               <=  '0';  -- : out std_logic;
                                
        M_priority              <=  (others => '0');  -- : out std_logic_vector(0 to 1);
                                
        M_buslock               <=  '0';  -- : out std_logic;
                                
        M_RNW                   <=  '0';  -- : out std_logic;
                                
        M_BE                    <=  (others => '0');  -- : out std_logic_vector(0 to ((C_PLB_DWIDTH/8)-1));
                                
        M_msize                 <=  (others => '0');  -- : out std_logic_vector(0 to 1);
                                
        M_size                  <=  (others => '0');  -- : out std_logic_vector(0 to 3);
                                
        M_type                  <=  (others => '0');  -- : out std_logic_vector(0 to 2);
                                
        M_compress              <=  '0';  -- : out std_logic;
                                
        M_guarded               <=  '0';  -- : out std_logic;
                                
        M_ordered               <=  '0';  -- : out std_logic;
                                
        M_lockErr               <=  '0';  -- : out std_logic;
                                
        M_abort                 <=  '0';  -- : out std_logic;
                                
        --M_UABus                 <=  (others => '0');  -- : out std_logic_vector(0 to C_PLB_AWIDTH-1);
                                
        M_ABus                  <=  (others => '0');  -- : out std_logic_vector(0 to C_PLB_AWIDTH-1);
                                
        M_wrDBus                <=  (others => '0');  -- : out std_logic_vector(0 to (C_PLB_DWIDTH-1));
                                
        M_wrBurst               <=  '0';  -- : out std_logic;
                                
        M_rdBurst               <=  '0';  -- : out std_logic);
        
        
        Bus_MnGrant             <=  '0';
        MA2SA_Select            <=  '0';
        MA2SA_XferAck           <=  '0';
        MA2SA_Rd                <=  '0';
        MA2SA_Num               <=  (others => '0');
        Mstr_Sel_ma             <=  '0';
        Bus2IP_MstWrAck_i       <=  '0';
        Bus2IP_MstRdAck_i       <=  '0';
        Bus2IP_MstRetry_i       <=  '0';
        Bus2IP_MstError_i       <=  '0';
        Bus2IP_MstTimeOut_i     <=  '0';
        Bus2IP_MstLastAck_i     <=  '0';
        
       
  end generate REMOVE_MASTER;  
                          
 ------------------------------------------------------------------------------                       
 
  
  
  
  
  -- Obsoleted  I_SLAVE_ATTACHMENT:  plb_slave_attachment_dtime
  -- Obsoleted      generic map(
  -- Obsoleted          C_REG_CS_CE                =>  true,
  -- Obsoleted    	  C_STEER_ADDR_SIZE          =>  STEER_ADDR_SIZE,
  -- Obsoleted          C_ARD_ADDR_RANGE_ARRAY     =>  C_ARD_ADDR_RANGE_ARRAY,
  -- Obsoleted          C_ARD_DWIDTH_ARRAY         =>  C_ARD_DWIDTH_ARRAY,
  -- Obsoleted          C_ARD_NUM_CE_ARRAY         =>  C_ARD_NUM_CE_ARRAY,
  -- Obsoleted          C_ARD_DTIME_READ_ARRAY     =>  C_ARD_DTIME_READ_ARRAY,      
  -- Obsoleted          C_ARD_DTIME_WRITE_ARRAY    =>  C_ARD_DTIME_WRITE_ARRAY,
  -- Obsoleted          C_PLB_NUM_MASTERS          =>  C_PLB_NUM_MASTERS,
  -- Obsoleted          C_PLB_MID_WIDTH            =>  C_PLB_MID_WIDTH,
  -- Obsoleted          C_PLB_ABUS_WIDTH           =>  C_PLB_AWIDTH, 
  -- Obsoleted          C_PLB_DBUS_WIDTH           =>  C_PLB_DWIDTH,    
  -- Obsoleted          C_IPIF_ABUS_WIDTH          =>  C_PLB_AWIDTH,
  -- Obsoleted          C_IPIF_DBUS_WIDTH          =>  C_IPIF_DWIDTH,
  -- Obsoleted          C_SL_ATT_ADDR_SEL_WIDTH    =>  2,
  -- Obsoleted          C_SUPPORT_BURST            =>  C_DEV_BURST_ENABLE,
  -- Obsoleted          C_FAST_DATA_XFER           =>  C_DEV_FAST_DATA_XFER,
  -- Obsoleted          C_BURST_PAGE_SIZE          =>  C_DEV_BURST_PAGE_SIZE,
  -- Obsoleted          C_MA2SA_NUM_WIDTH          =>  4,
  -- Obsoleted          C_SLN_BUFFER_DEPTH         =>  SLN_BUFFER_DEPTH,
  -- Obsoleted          C_DPHASE_TIMEOUT           =>  C_DEV_DPHASE_TIMEOUT
  -- Obsoleted          )
  -- Obsoleted      port map(        
  -- Obsoleted          --System signals
  -- Obsoleted          Bus_Reset              =>  Bus_Reset_i , 
  -- Obsoleted          Bus_Clk                =>  Bus2IP_Clk_i, 
  -- Obsoleted          
  -- Obsoleted          -- PLB Bus signals
  -- Obsoleted          PLB_ABus               =>  PLB_ABus     ,   
  -- Obsoleted          PLB_PAValid            =>  PLB_PAValid  ,   
  -- Obsoleted          PLB_SAValid            =>  PLB_SAValid  ,   
  -- Obsoleted          PLB_rdPrim             =>  PLB_rdPrim   ,   
  -- Obsoleted          PLB_wrPrim             =>  PLB_wrPrim   ,   
  -- Obsoleted          PLB_masterID           =>  PLB_masterID ,   
  -- Obsoleted          PLB_abort              =>  PLB_abort    ,   
  -- Obsoleted          PLB_busLock            =>  PLB_busLock  ,   
  -- Obsoleted          PLB_RNW                =>  PLB_RNW      ,   
  -- Obsoleted          PLB_BE                 =>  PLB_BE       ,   
  -- Obsoleted          PLB_Msize              =>  PLB_MSize    ,   
  -- Obsoleted          PLB_size               =>  PLB_size     ,   
  -- Obsoleted          PLB_type               =>  PLB_type     ,   
  -- Obsoleted          PLB_compress           =>  PLB_compress ,   
  -- Obsoleted          PLB_guarded            =>  PLB_guarded  ,   
  -- Obsoleted          PLB_ordered            =>  PLB_ordered  ,   
  -- Obsoleted          PLB_lockErr            =>  PLB_lockErr  ,   
  -- Obsoleted          PLB_wrDBus             =>  PLB_wrDBus   ,   
  -- Obsoleted          PLB_wrBurst            =>  PLB_wrBurst  ,   
  -- Obsoleted          PLB_rdBurst            =>  PLB_rdBurst  ,   
  -- Obsoleted          PLB_pendReq            =>  PLB_pendReq  ,   
  -- Obsoleted          PLB_pendPri            =>  PLB_pendPri  ,   
  -- Obsoleted          PLB_reqPri             =>  PLB_reqPri   ,   
  -- Obsoleted          Sl_addrAck             =>  Sl_addrAck_i ,
  -- Obsoleted          Sl_SSize               =>  open         ,
  -- Obsoleted          -- Sl_SSize               =>  Sl_SSize_i      ,
  -- Obsoleted          Sl_wait                =>  Sl_wait_i       ,
  -- Obsoleted          Sl_rearbitrate         =>  Sl_rearbitrate_i,
  -- Obsoleted          Sl_wrDAck              =>  Sl_wrDAck_i     ,
  -- Obsoleted          Sl_wrComp              =>  Sl_wrComp_i     ,
  -- Obsoleted          Sl_wrBTerm             =>  Sl_wrBTerm_i    ,
  -- Obsoleted          Sl_rdDBus              =>  Sl_rdDBus_i     ,
  -- Obsoleted          Sl_rdWdAddr            =>  Sl_rdWdAddr_i   ,
  -- Obsoleted          Sl_rdDAck              =>  Sl_rdDAck_i     ,
  -- Obsoleted          Sl_rdComp              =>  Sl_rdComp_i     ,
  -- Obsoleted          Sl_rdBTerm             =>  Sl_rdBTerm_i    ,
  -- Obsoleted          Sl_MBusy               =>  Sl_MBusy_i      ,
  -- Obsoleted          Sl_MErr                =>  Sl_MErr_i       ,
  -- Obsoleted          
  -- Obsoleted          -- Master Attachment Signals
  -- Obsoleted          MA2SA_Select          =>  MA2SA_select    , 
  -- Obsoleted          MA2SA_XferAck         =>  MA2SA_XferAck   , 
  -- Obsoleted          MA2SA_Rd              =>  MA2SA_Rd        , 
  -- Obsoleted          MA2SA_Num             =>  MA2SA_num(0 to 3),
  -- Obsoleted                                                      
  -- Obsoleted          SA2MA_RdRdy           =>  SA2MA_RdRdy  ,    
  -- Obsoleted          SA2MA_WrAck           =>  SA2MA_WrAck  ,    
  -- Obsoleted          SA2MA_Retry           =>  SA2MA_Retry  ,    
  -- Obsoleted          SA2MA_ErrAck          =>  SA2MA_ErrAck ,    
  -- Obsoleted          
  -- Obsoleted          -- Controls to the Byte Steering Module
  -- Obsoleted          SA2Steer_Addr         =>  SA2Steer_Addr_i,
  -- Obsoleted          SA2Steer_BE           =>  SA2Steer_BE_i,  
  -- Obsoleted        
  -- Obsoleted          -- Controls to the IP/IPIF modules
  -- Obsoleted          --Bus2IP_AValid        =>  Bus2IP_AValid_i,
  -- Obsoleted          
  -- Obsoleted          Bus2IP_masterID     =>  Bus2IP_masterID_i ,-- ***PLB future
  -- Obsoleted          --Bus2IP_Msize        =>  Bus2IP_Msize_i    ,-- ***PLB future
  -- Obsoleted          Bus2IP_Ssize        =>  Bus2IP_SSize_i     ,-- ***PLB future
  -- Obsoleted          Bus2IP_size         =>  Bus2IP_size_i     ,-- ***PLB future
  -- Obsoleted          Bus2IP_type         =>  Bus2IP_type_i     ,-- ***PLB future
  -- Obsoleted          --Bus2IP_lockErr      =>  Bus2IP_lockErr_i  ,-- ***PLB future
  -- Obsoleted                                
  -- Obsoleted          Bus2IP_Addr         =>  Bus2IP_Addr_i,    
  -- Obsoleted          Bus2IP_Burst        =>  Bus2IP_Burst_i,    
  -- Obsoleted          Bus2IP_RNW          =>  Bus2IP_RNW_i,      
  -- Obsoleted          Bus2IP_BE           =>  open,      
  -- Obsoleted          Bus2IP_WrReq        =>  Bus2IP_WrReq_i,    
  -- Obsoleted          Bus2IP_RdReq        =>  Bus2IP_RdReq_i,    
  -- Obsoleted          Bus2IP_CS           =>  Bus2IP_CS_i  ,
  -- Obsoleted          Bus2IP_DWidth       =>  Bus2IP_DWidth_i,
  -- Obsoleted          Bus2IP_CE           =>  Bus2IP_CE_i  ,
  -- Obsoleted          Bus2IP_RdCE         =>  Bus2IP_RdCE_i,
  -- Obsoleted          Bus2IP_WrCE         =>  Bus2IP_WrCE_i,
  -- Obsoleted          
  -- Obsoleted          -- Write Data bus output to the IP/IPIF modules
  -- Obsoleted          Bus2IP_Data         =>  SA2Steer_Data_i,
  -- Obsoleted          
  -- Obsoleted          --Read Data Inputs from the Byte Steering Block
  -- Obsoleted          MUX2SA_Data         =>  Steer2SA_Data_i,
  -- Obsoleted          
  -- Obsoleted          -- Inputs from the Status Reply Mux
  -- Obsoleted          --MUX2SA_AddrSel      =>  IP2Bus_AddrSel_i  ,
  -- Obsoleted          MUX2SA_WrAck        =>  status_reply_or(WRACK_BIT)  ,
  -- Obsoleted          MUX2SA_RdAck        =>  status_reply_or(RDACK_BIT)  ,
  -- Obsoleted          MUX2SA_ErrAck       =>  status_reply_or(ERROR_BIT)  ,
  -- Obsoleted          MUX2SA_ToutSup      =>  status_reply_or(TOUTSUP_BIT),
  -- Obsoleted          MUX2SA_Retry        =>  status_reply_or(RETRY_BIT),  
  -- Obsoleted         
  -- Obsoleted          -- IP Busy input
  -- Obsoleted          IP2Bus_Busy         =>  IP2Bus_Busy,
  -- Obsoleted          
  -- Obsoleted          -- Data Acknowledge Timeout Error to Interrupt Module
  -- Obsoleted          SA2INT_DAck_Timeout =>  SA2INT_DAck_Timeout_i
  -- Obsoleted          );

  
  I_SLAVE_ATTACHMENT:  plb_slave_attachment_indet
      generic map(
		  C_STEER_ADDR_SIZE          =>  STEER_ADDR_SIZE,
          C_ARD_ADDR_RANGE_ARRAY     =>  C_ARD_ADDR_RANGE_ARRAY,
          C_ARD_DWIDTH_ARRAY         =>  C_ARD_DWIDTH_ARRAY,
          C_ARD_NUM_CE_ARRAY         =>  C_ARD_NUM_CE_ARRAY,
          C_PLB_NUM_MASTERS          =>  C_PLB_NUM_MASTERS,
          C_PLB_MID_WIDTH            =>  C_PLB_MID_WIDTH,
          C_PLB_ABUS_WIDTH           =>  C_PLB_AWIDTH, 
          C_PLB_DBUS_WIDTH           =>  C_PLB_DWIDTH,    
          C_IPIF_ABUS_WIDTH          =>  C_PLB_AWIDTH,
          C_IPIF_DBUS_WIDTH          =>  C_IPIF_DWIDTH,
          C_SL_ATT_ADDR_SEL_WIDTH    =>  2,
          C_SUPPORT_BURST            =>  C_DEV_BURST_ENABLE,
          C_FAST_DATA_XFER           =>  C_DEV_FAST_DATA_XFER,
          C_BURST_PAGE_SIZE          =>  C_DEV_BURST_PAGE_SIZE,
          C_MA2SA_NUM_WIDTH          =>  4,
          C_SLN_BUFFER_DEPTH         =>  SLN_BUFFER_DEPTH,
          C_DPHASE_TIMEOUT           =>  C_DEV_DPHASE_TIMEOUT
          )
      port map(        
          --System signals
          Bus_Reset              =>  Bus_Reset_i , 
          Bus_Clk                =>  Bus2IP_Clk_i, 
          
          -- PLB Bus signals
          PLB_ABus               =>  PLB_ABus     ,   
          PLB_PAValid            =>  PLB_PAValid  ,   
          PLB_SAValid            =>  PLB_SAValid  ,   
          PLB_rdPrim             =>  PLB_rdPrim   ,   
          PLB_wrPrim             =>  PLB_wrPrim   ,   
          PLB_masterID           =>  PLB_masterID ,   
          PLB_abort              =>  PLB_abort    ,   
          PLB_busLock            =>  PLB_busLock  ,   
          PLB_RNW                =>  PLB_RNW      ,   
          PLB_BE                 =>  PLB_BE       ,   
          PLB_Msize              =>  PLB_MSize    ,   
          PLB_size               =>  PLB_size     ,   
          PLB_type               =>  PLB_type     ,   
          PLB_compress           =>  PLB_compress ,   
          PLB_guarded            =>  PLB_guarded  ,   
          PLB_ordered            =>  PLB_ordered  ,   
          PLB_lockErr            =>  PLB_lockErr  ,   
          PLB_wrDBus             =>  PLB_wrDBus   ,   
          PLB_wrBurst            =>  PLB_wrBurst  ,   
          PLB_rdBurst            =>  PLB_rdBurst  ,   
          PLB_pendReq            =>  PLB_pendReq  ,   
          PLB_pendPri            =>  PLB_pendPri  ,   
          PLB_reqPri             =>  PLB_reqPri   ,   
          Sl_addrAck             =>  Sl_addrAck_i ,
          Sl_SSize               =>  open         ,
          -- Sl_SSize               =>  Sl_SSize_i      ,
          Sl_wait                =>  Sl_wait_i       ,
          Sl_rearbitrate         =>  Sl_rearbitrate_i,
          Sl_wrDAck              =>  Sl_wrDAck_i     ,
          Sl_wrComp              =>  Sl_wrComp_i     ,
          Sl_wrBTerm             =>  Sl_wrBTerm_i    ,
          Sl_rdDBus              =>  Sl_rdDBus_i     ,
          Sl_rdWdAddr            =>  Sl_rdWdAddr_i   ,
          Sl_rdDAck              =>  Sl_rdDAck_i     ,
          Sl_rdComp              =>  Sl_rdComp_i     ,
          Sl_rdBTerm             =>  Sl_rdBTerm_i    ,
          Sl_MBusy               =>  Sl_MBusy_i      ,
          Sl_MErr                =>  Sl_MErr_i       ,
          
          -- Master Attachment Signals
          MA2SA_Select          =>  MA2SA_select    , 
          MA2SA_XferAck         =>  MA2SA_XferAck   , 
          MA2SA_Rd              =>  MA2SA_Rd        , 
          MA2SA_Num             =>  MA2SA_num(0 to 3),
                                                      
          SA2MA_RdRdy           =>  SA2MA_RdRdy  ,    
          SA2MA_WrAck           =>  SA2MA_WrAck  ,    
          SA2MA_Retry           =>  SA2MA_Retry  ,    
          SA2MA_ErrAck          =>  SA2MA_ErrAck ,    
          
          -- Controls to the Byte Steering Module
          SA2Steer_Addr         =>  SA2Steer_Addr_i,
          SA2Steer_BE           =>  SA2Steer_BE_i,  
        
          -- Controls to the IP/IPIF modules
          --Bus2IP_AValid        =>  Bus2IP_AValid_i,
          
          Bus2IP_masterID     =>  Bus2IP_masterID_i ,-- ***PLB future
          --Bus2IP_Msize        =>  Bus2IP_Msize_i    ,-- ***PLB future
          Bus2IP_Ssize        =>  Bus2IP_SSize_i     ,-- ***PLB future
          Bus2IP_size         =>  Bus2IP_size_i     ,-- ***PLB future
          Bus2IP_type         =>  Bus2IP_type_i     ,-- ***PLB future
          --Bus2IP_lockErr      =>  Bus2IP_lockErr_i  ,-- ***PLB future
                                
          Bus2IP_Addr         =>  Bus2IP_Addr_i,    
          Bus2IP_Burst        =>  Bus2IP_Burst_i,
          Bus2IP_IBurst       =>  Bus2IP_IBurst_i,
          Bus2IP_RNW          =>  Bus2IP_RNW_i,      
          Bus2IP_BE           =>  open,      
          Bus2IP_WrReq        =>  Bus2IP_WrReq_i,    
          Bus2IP_RdReq        =>  Bus2IP_RdReq_i, 
          Bus2IP_RNW_Early    =>  Bus2IP_RNW_Early_i,
          Bus2IP_PselHit      =>  Bus2IP_PselHit_i  ,
          Bus2IP_CS           =>  Bus2IP_CS_i  ,
		  Bus2IP_Des_sig      =>  Bus2IP_Des_sig_i ,  --JTK Dual DDR Hack--
          Bus2IP_DWidth       =>  Bus2IP_DWidth_i,
          Bus2IP_CE           =>  Bus2IP_CE_i  ,
          Bus2IP_RdCE         =>  Bus2IP_RdCE_i,
          Bus2IP_WrCE         =>  Bus2IP_WrCE_i,
          
          -- Write Data bus output to the IP/IPIF modules
          Bus2IP_Data         =>  SA2Steer_Data_i,
          
          --Read Data Inputs from the Byte Steering Block
          MUX2SA_Data         =>  Steer2SA_Data_i,
          
          -- Inputs from the Status Reply Mux
          --MUX2SA_AddrSel      =>  IP2Bus_AddrSel_i  ,
          
          MUX2SA_AddrAck      =>  status_reply_or(ADDRACK_BIT),    
          MUX2SA_Busy         =>  status_reply_or(BUSY_BIT)   ,     
          MUX2SA_BTerm        =>  status_reply_or(BTERM_BIT)  ,                                                                    
          MUX2SA_WrAck        =>  status_reply_or(WRACK_BIT)  ,
          MUX2SA_RdAck        =>  status_reply_or(RDACK_BIT)  ,
          MUX2SA_ErrAck       =>  status_reply_or(ERROR_BIT)  ,
          MUX2SA_ToutSup      =>  status_reply_or(TOUTSUP_BIT),
          MUX2SA_Retry        =>  status_reply_or(RETRY_BIT)  ,  
         
          -- IP Busy input
          --IP2Bus_Busy         =>  IP2Bus_Busy ,
          
          -- Data Acknowledge Timeout Error to Interrupt Module
          SA2INT_DAck_Timeout =>  SA2INT_DAck_Timeout_i
          );
    
    
    
    
    -------------------------------------------------------------
    -- Combinational Process
    --
    -- Label: CONNECT_STEER_ADDR
    --
    -- Process Description:
    -- Connects the low order address bits of the Byte Steering
    -- address bus to the Slave Attachment's byte steering address
    -- out.
    --
    -------------------------------------------------------------
    CONNECT_STEER_ADDR : process (SA2Steer_Addr_i)
       begin
          SA2Steer_Addr_full_i <= (others => '0'); -- default to zeroes
          
          SA2Steer_Addr_full_i(C_IPIF_AWIDTH - STEER_ADDR_SIZE to
                               C_IPIF_AWIDTH -1) 
                            <= SA2Steer_Addr_i;
    
       end process CONNECT_STEER_ADDR; 
    
    
    
    I_BYTE_STEERING: ipif_steer
     generic map(
       C_DWIDTH      =>  C_IPIF_DWIDTH,  
       C_SMALLEST    =>  MIN_DBUS_WIDTH,                  
       C_AWIDTH      =>  C_IPIF_AWIDTH   
       )   
     port map(                            
       Wr_Data_In    =>  SA2Steer_Data_i,  
       Rd_Data_In    =>  read_data_or, 
       --Addr          =>  Bus2IP_Addr_i, 
       Addr          =>  SA2Steer_Addr_full_i,   
       BE_In         =>  SA2Steer_BE_i,    
       Decode_size   =>  Bus2IP_DWidth_i,    
       Wr_Data_Out   =>  Bus2IP_Data_i,    
       Rd_Data_Out   =>  Steer2SA_Data_i,  
       BE_Out        =>  Bus2IP_BE_i       
       );
     
  

 
  
-------------------------------------------------------------------------------  
  INCLUDE_RESET : if (RESET_PRESENT = true) generate
 
     Constant NUM_RESET_CLKS        : integer := 4;
  
     -- Detirmine the CE indexes to use for the Reset Register CE
     Constant RESET_NAME_INDEX      : integer := get_id_index(C_ARD_ID_ARRAY,IPIF_RST);
     Constant RESET_REG_CE_INDEX    : integer := calc_start_ce_index(C_ARD_NUM_CE_ARRAY,
                                                                     RESET_NAME_INDEX);
     constant IP_RESET_DATA_WIDTH   : integer := C_ARD_DWIDTH_ARRAY(RESET_NAME_INDEX);
     Constant RESET_DBUS_INDEX      : integer := get_ipif_id_dbus_index(C_ARD_ID_ARRAY,
                                                                        IPIF_RST);       

     
     Signal   sig_reset_dbus_out     : std_logic_vector(0 to IP_RESET_DATA_WIDTH-1);
     Signal   sig_reset_rd_dbus      : std_logic_vector(0 to C_IPIF_DWIDTH-1);
     Signal   reset_status_reply_out : std_logic_vector(0 to 
                                                        NUM_STATUS_REPLY_ELEMENTS-1);
     
     
     
      component plb_ipif_reset
         generic (
               C_IPIF_MIR_ENABLE    : BOOLEAN;
               C_IPIF_TYPE          : INTEGER;
               C_IPIF_BLK_ID        : INTEGER;
               C_IPIF_REVISION      : INTEGER;
               C_IPIF_MINOR_VERSION : INTEGER;
               C_IPIF_MAJOR_VERSION : INTEGER;
               C_DBUS_WIDTH         : INTEGER;
               C_RESET_WIDTH        : INTEGER    
               );
         port (
               Reset               : in  std_logic;
               Bus2IP_Clk_i        : in  std_logic;
               Bus2IP_WrReq        : In  std_logic;  
               Bus2IP_RdReq        : In  std_logic;  
               IP_Reset_WrCE       : in  std_logic;
               IP_Reset_RdCE       : in  std_logic;
               Bus_DBus            : in  std_logic_vector(0 to C_DBUS_WIDTH-1);
               Bus_BE              : In  std_logic_vector(0 to (C_DBUS_WIDTH/8)-1);
               Reset2IP_Reset      : out std_logic;
               Reset2Bus_DBus      : out std_logic_vector(0 to C_DBUS_WIDTH-1);
               Reset2Bus_WrAck     : out std_logic;
               Reset2Bus_RdAck     : out std_logic;
               Reset2Bus_Error     : out std_logic;
               Reset2Bus_Retry     : out std_logic;
               Reset2Bus_ToutSup   : out std_logic
               );
     end component;
  
  begin
    
        I_RESET_CONTROL: plb_ipif_reset
          generic map (
             C_IPIF_MIR_ENABLE    =>  C_DEV_MIR_ENABLE,
             C_IPIF_TYPE          =>  IPIF_TYPE,
             C_IPIF_BLK_ID        =>  C_DEV_BLK_ID,
             C_IPIF_REVISION      =>  IPIF_REVISION,
             C_IPIF_MINOR_VERSION =>  IPIF_MINOR_VERSION,
             C_IPIF_MAJOR_VERSION =>  IPIF_MAJOR_VERSION,
             C_DBUS_WIDTH         =>  IP_RESET_DATA_WIDTH,
             C_RESET_WIDTH        =>  NUM_RESET_CLKS
             )
          port map (
             Reset             => Bus_Reset_i,
             Bus2IP_Clk_i      => Bus2IP_Clk_i,
             Bus2IP_WrReq      => Bus2IP_WrReq_i,
             Bus2IP_RdReq      => Bus2IP_RdReq_i,
             IP_Reset_WrCE     => BUS2IP_WrCE_i(RESET_REG_CE_INDEX),
             IP_Reset_RdCE     => BUS2IP_RdCE_i(RESET_REG_CE_INDEX),
             Bus_DBus          => Bus2IP_Data_i(0 to IP_RESET_DATA_WIDTH - 1),
             Bus_BE            => Bus2IP_BE_i(0 to (IP_RESET_DATA_WIDTH/8) -1),
             Reset2IP_Reset    => Bus2IP_Reset_i,
             Reset2Bus_DBus    => sig_reset_dbus_out,
             Reset2Bus_WrAck   => reset_status_reply_out(WRACK_BIT),
             Reset2Bus_RdAck   => reset_status_reply_out(RDACK_BIT),
             Reset2Bus_Error   => reset_status_reply_out(ERROR_BIT),
             Reset2Bus_Retry   => reset_status_reply_out(RETRY_BIT),
             Reset2Bus_ToutSup => reset_status_reply_out(TOUTSUP_BIT)
             );

         
          
         reset_status_reply_out(BTERM_BIT)    <= '0';
         reset_status_reply_out(BUSY_BIT)     <= '0';
         
         reset_status_reply_out(ADDRACK_BIT)  <= 
                                  reset_status_reply_out(WRACK_BIT) or 
                                  reset_status_reply_out(RDACK_BIT);
         
         
         -- Connect the status reply bus to the appropriate reply bus index
         status_reply_array(RESET_DBUS_INDEX) <= reset_status_reply_out;
         
         
             
             
         ------------------------------------------------------------
         -- If Generate
         --
         -- Label: MIR_ENABLED
         --
         -- If Generate Description:
         --     If the MIR feature is enabled, then the read data bus 
         -- from the Reset Module must be hooked to the IPIF.
         --
         ------------------------------------------------------------
         MIR_ENABLED : if (C_DEV_MIR_ENABLE = true) generate
         
            -- Local Constants
            -- Local variables
            -- local signals
            -- local components
         
            begin
         
              ---------------------------------------------------------------
              -- Process 
              --
              -- This process populates the data bus from the reset module
              -- (needed for MIR readback) to one that is the same width  
              -- as the IPIF DBUS. This is needed since the reset bus width 
              -- may not be as wide as the ipif dbus width.
              ---------------------------------------------------------------
              CONNECT_RST_DBUS_OUT : process (sig_reset_dbus_out)
                 Begin
                  
                  -- default entire bus to zeros
                    sig_reset_rd_dbus <= (others =>'0');  
                  
                  -- now assign reset dbus outputs   
                    sig_reset_rd_dbus(0 to IP_RESET_DATA_WIDTH-1) <= 
                                                    sig_reset_dbus_out; 
                                                          
                 End process; -- CONNECT_RST_DBUS_OUT

       
               -- Now connect into the read DBus array
               read_dbus_array(RESET_DBUS_INDEX) <= sig_reset_rd_dbus;
         
            end generate MIR_ENABLED;
         
         
            ------------------------------------------------------------
            -- If Generate
            --
            -- Label: MIR_DISABLED
            --
            -- If Generate Description:
            --  This IFGEN disconnects the read data bus of the Reset
            -- Module from the IPIF.
            --
            --
            ------------------------------------------------------------
            MIR_DISABLED : if (C_DEV_MIR_ENABLE = false) generate
            
               -- Local Constants
               -- Local variables
               -- local signals
               -- local components
            
               begin
                 
                 -- Set to zeroes  
                 read_dbus_array(RESET_DBUS_INDEX) <= (others => '0');
               
               end generate MIR_DISABLED;
         
          
          
  end generate INCLUDE_RESET; 
   
                                
    
 REMOVE_RESET : if (RESET_PRESENT = false) generate
 
       Bus2IP_Reset_i  <=  Bus_Reset_i;
 
 
 end generate REMOVE_RESET; 
 
-------------------------------------------------------------------------------  
  
 INCLUDE_INTERRUPT : if (INTERRUPT_PRESENT = true) generate
  
     
     
     -- Detirmine the CE indexes to use for the Interrupt Register CE
     Constant IRPT_NAME_INDEX        : integer := get_id_index(C_ARD_ID_ARRAY,IPIF_INTR);
     Constant IRPT_REG_CE_INDEX      : integer := calc_start_ce_index (C_ARD_NUM_CE_ARRAY,
                                                                       IRPT_NAME_INDEX);
     constant INTERRUPT_REG_NUM      : integer := C_ARD_NUM_CE_ARRAY(IRPT_NAME_INDEX);
     constant INTERRUPT_DATA_WIDTH   : integer := C_ARD_DWIDTH_ARRAY(IRPT_NAME_INDEX);
     Constant INTERRUPT_DBUS_INDEX   : integer := get_ipif_id_dbus_index(C_ARD_ID_ARRAY,
                                                                         IPIF_INTR);       
     
     -- Synplicity workaround for xst workaround of needing to constrain port widths
     -- on component declarations                                                                                  
     Constant NUM_IP_INTR : integer := C_IP_INTR_MODE_ARRAY'length;
     

     Signal   sig_interrupt_dbus_out    : std_logic_vector(0 to INTERRUPT_DATA_WIDTH-1);
     Signal   sig_interrupt_rd_dbus     : std_logic_vector(0 to C_IPIF_DWIDTH-1);
     Signal   interrupt_status_reply_out: std_logic_vector(0 to  
                                                           NUM_STATUS_REPLY_ELEMENTS-1);
     
     
     
     component interrupt_control is
      Generic(
         C_INTERRUPT_REG_NUM    : INTEGER;
         C_NUM_IPIF_IRPT_SRC    : INTEGER;
         C_IP_INTR_MODE_ARRAY   : INTEGER_ARRAY_TYPE;
         C_INCLUDE_DEV_PENCODER : BOOLEAN; 
         C_INCLUDE_DEV_ISC      : Boolean; 
         C_IRPT_DBUS_WIDTH      : INTEGER
         ); 
      port(
     
         -- Inputs From the IPIF Bus 
         Bus2IP_Clk_i        : In  std_logic;  -- Master timing clock from the IPIF
         Bus2IP_Data_sa      : In  std_logic_vector(0 to INTERRUPT_DATA_WIDTH-1);
         Bus2IP_RdReq_sa     : In  std_logic;
         Bus2IP_Reset_i      : In  std_logic;  -- Master Reset from the IPIF reset block
         Bus2IP_WrReq_sa     : In  std_logic;
         Interrupt_RdCE      : In  std_logic_vector(0 to INTERRUPT_REG_NUM-1);
         Interrupt_WrCE      : In  std_logic_vector(0 to INTERRUPT_REG_NUM-1);
         IPIF_Reg_Interrupts : In  std_logic_vector(0 to 1);                    
         
         -- Interrupt inputs from the IPIF sources that will get registered in this design
         IPIF_Lvl_Interrupts : In  std_logic_vector(0 to C_NUM_IPIF_IRPT_SRC-1);
                             -- Level Interrupt inputs from the IPIF sources
       
         -- Inputs from the IP Interface  
         IP2Bus_IntrEvent    : In  std_logic_vector(0 to NUM_IP_INTR-1); 
                             -- Interrupt inputs from the IP 
        -- Final Device Interrupt Output
        Intr2Bus_DevIntr     : Out std_logic;
                             -- Device interrupt output to the Master Interrupt Controller
       
        -- Status Reply Outputs to the Bus 
        Intr2Bus_DBus        : Out std_logic_vector(0 to INTERRUPT_DATA_WIDTH-1);
        Intr2Bus_WrAck       : Out std_logic;
        Intr2Bus_RdAck       : Out std_logic;
        Intr2Bus_Error       : Out std_logic;
        Intr2Bus_Retry       : Out std_logic;
        Intr2Bus_ToutSup     : Out std_logic
        );

     end component;
        
     
  
  begin

I_INTERRUPT_BLOCK : interrupt_control
   Generic map (
      C_INTERRUPT_REG_NUM    =>  INTERRUPT_REG_NUM,
      C_NUM_IPIF_IRPT_SRC    =>  NUM_IPIF_IRPT_SRC,
      C_IP_INTR_MODE_ARRAY   =>  C_IP_INTR_MODE_ARRAY,
      C_INCLUDE_DEV_PENCODER =>  C_INCLUDE_DEV_PENCODER and
                                 C_INCLUDE_DEV_ISC,
      C_INCLUDE_DEV_ISC      =>  C_INCLUDE_DEV_ISC,
      C_IRPT_DBUS_WIDTH      =>  INTERRUPT_DATA_WIDTH
      ) 
   port map (
  
       -- Inputs From the IPIF Bus 
       Bus2IP_Clk_i        =>  Bus2IP_Clk_i,
       Bus2IP_Data_sa      =>  Bus2IP_Data_i(0 to INTERRUPT_DATA_WIDTH - 1),
       Bus2IP_RdReq_sa     =>  Bus2IP_RdReq_i,
       Bus2IP_Reset_i      =>  Bus2IP_Reset_i,
       Bus2IP_WrReq_sa     =>  Bus2IP_WrReq_i,
       Interrupt_RdCE      =>  BUS2IP_RdCE_i(IRPT_REG_CE_INDEX to                   
                                             IRPT_REG_CE_INDEX+INTERRUPT_REG_NUM-1),
       Interrupt_WrCE      =>  BUS2IP_WrCE_i(IRPT_REG_CE_INDEX to                   
                                             IRPT_REG_CE_INDEX+INTERRUPT_REG_NUM-1),
       IPIF_Reg_Interrupts =>  IPIF_Reg_Interrupts,
       
       IPIF_Lvl_Interrupts =>  IPIF_Lvl_Interrupts,
     
       IP2Bus_IntrEvent    =>  IP2Bus_IntrEvent,
      
       Intr2Bus_DevIntr     =>  Intr2Bus_DevIntr,
       
       Intr2Bus_DBus        =>  sig_interrupt_dbus_out,
       Intr2Bus_WrAck       =>  interrupt_status_reply_out(WRACK_BIT), 
       Intr2Bus_RdAck       =>  interrupt_status_reply_out(RDACK_BIT), 
       Intr2Bus_Error       =>  interrupt_status_reply_out(ERROR_BIT), 
       Intr2Bus_Retry       =>  interrupt_status_reply_out(RETRY_BIT), 
       Intr2Bus_ToutSup     =>  interrupt_status_reply_out(TOUTSUP_BIT)
       );

         
         interrupt_status_reply_out(BTERM_BIT)    <= '0';
         interrupt_status_reply_out(BUSY_BIT)     <= '0';
         
         interrupt_status_reply_out(ADDRACK_BIT)  <= 
                                  interrupt_status_reply_out(WRACK_BIT) or 
                                  interrupt_status_reply_out(RDACK_BIT);
         
 
         -- Connect the status reply bus to the appropriate reply bus index
         status_reply_array(INTERRUPT_DBUS_INDEX) <= interrupt_status_reply_out;
         
        ---------------------------------------------------------------
        -- Process 
        --
        -- This process connects the data bus from the interrupt module
        -- to the ip2bus_dmux module. This is needed since the interrupt
        -- bus width may not be as wide as the ipif dbus width.
        ---------------------------------------------------------------
        CONNECT_INTR_DBUS_OUT : process (sig_interrupt_dbus_out)
           Begin
            
            -- default entire bus to zeros
              sig_interrupt_rd_dbus <= (others =>'0');  
            
            -- now assign reset dbus outputs   
              sig_interrupt_rd_dbus(0 to INTERRUPT_DATA_WIDTH-1) <= 
                                              sig_interrupt_dbus_out; 
                                                    
           End process; -- CONNECT_INTR_DBUS_OUT
 
          -- Now connect into the read DBus array
          read_dbus_array(INTERRUPT_DBUS_INDEX) <= sig_interrupt_rd_dbus;
          

 end generate INCLUDE_INTERRUPT;  
 
  
  
 REMOVE_INTERRUPT : if (INTERRUPT_PRESENT = false) generate
  
      Intr2Bus_DevIntr  <=  IP2Bus_IntrEvent(0);
             
 end generate REMOVE_INTERRUPT; 
-------------------------------------------------------------------------------                                                                               
                                                                               
 
 
------------------------------------------------------------------------------- 
  INCLUDE_SESR_SEAR : if (SESR_SEAR_PRESENT = true) generate
 
  
     -- Detirmine the CE indexes to use for the SESR/SEAR Register CE
     Constant SESR_NAME_INDEX        : integer := 
                              get_id_index(C_ARD_ID_ARRAY,
                                           IPIF_SESR_SEAR);
                              
     Constant SESR_REG_CE_INDEX      : integer := 
                              calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 
                                                  SESR_NAME_INDEX);
                                                   
     constant SESR_REG_NUM           : integer := 
                              C_ARD_NUM_CE_ARRAY(SESR_NAME_INDEX);
                              
     constant SESR_DATA_WIDTH        : integer := 
                              C_ARD_DWIDTH_ARRAY(SESR_NAME_INDEX);

     Constant SESR_DBUS_INDEX       : integer := 
                              get_ipif_id_dbus_index(C_ARD_ID_ARRAY,
                                                     IPIF_SESR_SEAR);       


     -- Note: This must match the SESR_REG_NUM constant value above
     Constant NUM_SESR_SEAR_CE_NEEDED : integer := 
                             1 +                   -- At least one needed
                             (C_PLB_AWIDTH/33) +   -- plus 1 for Extended PLB Address case
                             ((64-SESR_DATA_WIDTH)/32); -- plus 1 for Narrow PLB DBus Case
  
     Signal  sig_sesr_sear_dbus_out     : std_logic_vector(0 to SESR_DATA_WIDTH-1);
     Signal  sig_sesr_sear_rd_dbus      : std_logic_vector(0 to C_PLB_DWIDTH-1);
     Signal  sesr_sear_status_reply_out : std_logic_vector(0 to  
                                                           NUM_STATUS_REPLY_ELEMENTS-1);
  
     component plb_sesr_sear
        generic (
            C_PLB_MID_WIDTH     : Integer := 4; 
            C_PLB_AWIDTH        : integer := 32;
            C_PLB_DWIDTH        : Integer := 32;
            C_SESR_SEAR_DWIDTH  : Integer := 32;
            C_NUM_CE            : Integer := 2
            );
        port(        
            --System Input signals
            Bus_Reset           : in  std_logic;
            Bus_Clk             : in  std_logic;
            
            -- General Input signals
            Bus2IP_RdReq        : In  std_logic;
            Bus2IP_WrReq        : In  std_logic;
            SESR_RdCE           : In  std_logic_vector(0 to C_NUM_CE-1);
            SESR_WrCE           : In  std_logic_vector(0 to C_NUM_CE-1);
            Bus2IP_DBus         : In  std_logic_vector(0 to C_PLB_DWIDTH-1);
            Bus2IP_Addr         : in  std_logic_vector(0 to C_PLB_AWIDTH-1);
            Bus2IP_RNW          : in  std_logic;
            Bus2IP_BE           : in  std_logic_vector(0 to C_PLB_DWIDTH/8-1);
            SA2SESR_MID         : in  std_logic_vector(0 to C_PLB_MID_WIDTH-1);
            SA2SESR_size        : in  std_logic_vector(0 to 3);
            SA2SESR_type        : in  std_logic_vector(0 to 2);
            SA2SESR_Sl_SSize    : in  std_logic_vector(0 to 1);
            
            -- Capture trigger signals
            MUX2SA_ErrAck       : in  std_logic;
            SA2INT_DAck_Timeout : in  std_logic;
            
            -- Outputs
            SESR2Bus_RdAck      : out std_logic; 
            SESR2Bus_WrACK      : out std_logic; 
            SESR2Bus_Error      : out std_logic; 
            SESR2Bus_ToutSup    : out std_logic; 
            SESR2Bus_Retry      : out std_logic; 
            SESR2Bus_Data       : out std_logic_vector(0 to C_SESR_SEAR_DWIDTH-1)
            );
     end component plb_sesr_sear;

 
  
  begin
    
     I_SESR_SEAR : plb_sesr_sear
       generic map(
           C_PLB_MID_WIDTH     =>  C_PLB_MID_WIDTH,
           C_PLB_AWIDTH        =>  C_IPIF_AWIDTH,
           C_PLB_DWIDTH        =>  C_PLB_DWIDTH,
           C_SESR_SEAR_DWIDTH  =>  SESR_DATA_WIDTH,
           C_NUM_CE            =>  NUM_SESR_SEAR_CE_NEEDED
           )
       port map(        
           --System Input signals
           Bus_Reset           =>  Bus_Reset_i ,
           Bus_Clk             =>  Bus2IP_Clk_i,
           
           -- General Input signals      
           Bus2IP_RdReq        =>  Bus2IP_RdReq_i,
           Bus2IP_WrReq        =>  Bus2IP_WrReq_i,
           SESR_RdCE           =>  BUS2IP_RdCE_i(SESR_REG_CE_INDEX to                   
                                                 SESR_REG_CE_INDEX+SESR_REG_NUM
                                                 -1),
           SESR_WrCE           =>  BUS2IP_WrCE_i(SESR_REG_CE_INDEX to                   
                                                 SESR_REG_CE_INDEX+SESR_REG_NUM
                                                 -1),
           Bus2IP_DBus         =>  Bus2IP_Data_i,
           Bus2IP_Addr         =>  Bus2IP_Addr_i,
           Bus2IP_RNW          =>  Bus2IP_RNW_i,
           Bus2IP_BE           =>  SA2Steer_BE_i,
           SA2SESR_MID         =>  Bus2IP_masterID_i,
           SA2SESR_size        =>  Bus2IP_size_i,
           SA2SESR_type        =>  Bus2IP_type_i,
           SA2SESR_Sl_SSize    =>  Bus2IP_SSize_i,
           
           -- Capture trigger signals
           MUX2SA_ErrAck       =>  status_reply_or(ERROR_BIT),
           SA2INT_DAck_Timeout =>  SA2INT_DAck_Timeout_i,
           
           -- Outputs
           SESR2Bus_RdAck      =>  sesr_sear_status_reply_out(RDACK_BIT), 
           SESR2Bus_WrACK      =>  sesr_sear_status_reply_out(WRACK_BIT), 
           SESR2Bus_Error      =>  sesr_sear_status_reply_out(ERROR_BIT), 
           SESR2Bus_ToutSup    =>  sesr_sear_status_reply_out(TOUTSUP_BIT), 
           SESR2Bus_Retry      =>  sesr_sear_status_reply_out(RETRY_BIT),
           SESR2Bus_Data       =>  sig_sesr_sear_dbus_out
           );
                                                                               
         
         sesr_sear_status_reply_out(BTERM_BIT)    <= '0';
         sesr_sear_status_reply_out(BUSY_BIT)     <= '0';
         
         sesr_sear_status_reply_out(ADDRACK_BIT)  <= 
                                  sesr_sear_status_reply_out(WRACK_BIT) or 
                                  sesr_sear_status_reply_out(RDACK_BIT);
         
         -- Connect the status reply bus to the appropriate reply bus index
         status_reply_array(SESR_DBUS_INDEX) <= sesr_sear_status_reply_out;
         
         ----------------------------------------------------------------
         -- Process 
         --
         -- This process connects the data bus from the SESR/SEAR module
         -- to the ip2bus_dmux module. This is needed since the SESR/SEAR
         -- bus width may not be as wide as the ipif dbus width.
         ----------------------------------------------------------------
         CONNECT_SESR_DBUS_OUT : process (sig_sesr_sear_dbus_out)
            Begin
             
             -- default entire bus to zeros
               sig_sesr_sear_rd_dbus <= (others =>'0');  
             
             -- now assign SESR/SEAR dbus outputs   
               sig_sesr_sear_rd_dbus(0 to SESR_DATA_WIDTH-1) <= 
                                               sig_sesr_sear_dbus_out; 
                                                     
            End process; -- CONNECT_SESR_DBUS_OUT

          -- Now connect into the read DBus array
          read_dbus_array(SESR_DBUS_INDEX) <= sig_sesr_sear_rd_dbus;
          
 
 end generate INCLUDE_SESR_SEAR; 
 
 
 
 
 --REMOVE_SESR_SEAR : if (SESR_SEAR_PRESENT = false) generate
           
       -- No tie-offs required
           
 --end generate REMOVE_SESR_SEAR; 
 
 
------------------------------------------------------------------------------- 
 
 
 
 
 
 
 
 ------------------------------------------------------------------------------ 
  
  INCLUDE_RDFIFO : if (RDFIFO_PRESENT = true) generate
  

     -- Detirmine the CE indexes to use for the RDFIFO Register CE
     Constant RDFIFO_REG_NAME_INDEX  : integer := get_id_index(C_ARD_ID_ARRAY,
                                                               IPIF_RDFIFO_REG);
     Constant RDFIFO_REG_CE_INDEX    : integer := calc_start_ce_index (C_ARD_NUM_CE_ARRAY,
                                                                       RDFIFO_REG_NAME_INDEX);
     
     -- Detirmine the CE index to use for the RDFIFO Data CE
     Constant RDFIFO_DATA_NAME_INDEX : integer := get_id_index(C_ARD_ID_ARRAY,
                                                               IPIF_RDFIFO_DATA);
     Constant RDFIFO_DATA_CE_INDEX   : integer := calc_start_ce_index (C_ARD_NUM_CE_ARRAY,
                                                                       RDFIFO_DATA_NAME_INDEX);
     constant RDFIFO_DATA_WIDTH      : integer := C_ARD_DWIDTH_ARRAY(RDFIFO_DATA_NAME_INDEX);
     constant RDFIFO_DEPTH_LOG2X     : integer := log2(C_RDFIFO_DEPTH);
     
     Constant RDFIFO_DBUS_INDEX      : integer := get_ipif_id_dbus_index(C_ARD_ID_ARRAY,
                                                                      IPIF_RDFIFO_DATA);       
     
     Signal   sig_rdfifo_dbus_out     : std_logic_vector(0 to C_IPIF_DWIDTH-1);
     Signal   rdfifo_status_reply_out : std_logic_vector(0 to  
                                                         NUM_STATUS_REPLY_ELEMENTS-1);
     
   component rdpfifo_top
       Generic (
         C_MIR_ENABLE          : Boolean;
         C_BLOCK_ID            : integer; 
         C_FIFO_DEPTH_LOG2X    : Integer;     
         C_FIFO_WIDTH          : Integer;     
         C_INCLUDE_PACKET_MODE : Boolean;
         C_INCLUDE_VACANCY     : Boolean;   
         C_SUPPORT_BURST       : Boolean;
         C_IPIF_DBUS_WIDTH     : Integer;
         C_VIRTEX_II           : boolean
           );
       port(
       -- Inputs From the IPIF Bus 
         Bus_rst               : In  std_logic;  -- Master Reset from the IPIF
         Bus_Clk               : In  std_logic;  -- Master timing clock from the IPIF
         Bus_RdReq             : In  std_logic;
         Bus_WrReq             : In  std_logic;
         Bus_Burst             : In  std_logic;
         Bus_BE                : In  std_logic_vector(0 to C_IPIF_DBUS_WIDTH/8-1); 
         Bus2FIFO_RdCE1        : In  std_logic;
         Bus2FIFO_RdCE2        : In  std_logic;
         Bus2FIFO_RdCE3        : In  std_logic;
         Bus2FIFO_WrCE1        : In  std_logic;
         Bus2FIFO_WrCE2        : In  std_logic;
         Bus2FIFO_WrCE3        : In  std_logic;
         Bus_DBus              : In  std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
         
       -- Inputs from the IP
         IP2RFIFO_WrReq        : In std_logic;
         IP2RFIFO_WrMark       : In std_logic;
         IP2RFIFO_WrRestore    : In std_logic;
         IP2RFIFO_WrRelease    : In std_logic;
         IP2RFIFO_Data         : In std_logic_vector(0 to C_FIFO_WIDTH-1);

       -- Outputs to the IP  
         RFIFO2IP_WrAck        : Out std_logic;
         RFIFO2IP_AlmostFull   : Out std_logic;
         RFIFO2IP_Full         : Out std_logic;
         RFIFO2IP_Vacancy      : Out std_logic_vector(0 to C_FIFO_DEPTH_LOG2X);
         
       -- Outputs to the IPIF DMA/SG function
         RFIFO2DMA_AlmostEmpty : Out std_logic;
         RFIFO2DMA_Empty       : Out std_logic;
         RFIFO2DMA_Occupancy   : Out std_logic_vector(0 to C_FIFO_DEPTH_LOG2X);
       
       -- Interrupt Output to IPIF Interrupt Register  
         FIFO2IRPT_DeadLock    : Out std_logic;

       -- Outputs to the IPIF Bus 
         FIFO2Bus_DBus         : Out std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
         FIFO2Bus_WrAck        : Out std_logic;
         FIFO2Bus_RdAck        : Out std_logic;
         FIFO2Bus_Error        : Out std_logic;
         FIFO2Bus_Retry        : Out std_logic;
         FIFO2Bus_ToutSup      : Out std_logic
       );
     end component ;
     

     
  
  begin
    

    I_RDFIFO: rdpfifo_top
      Generic map(
        C_MIR_ENABLE          => C_DEV_MIR_ENABLE,
        C_BLOCK_ID            => C_DEV_BLK_ID,
        C_FIFO_DEPTH_LOG2X    => RDFIFO_DEPTH_LOG2X,
        C_FIFO_WIDTH          => RDFIFO_DATA_WIDTH,
        C_INCLUDE_PACKET_MODE => C_RDFIFO_INCLUDE_PACKET_MODE,
        C_INCLUDE_VACANCY     => C_RDFIFO_INCLUDE_VACANCY,
        C_SUPPORT_BURST       => C_DEV_BURST_ENABLE,
        C_IPIF_DBUS_WIDTH     => C_IPIF_DWIDTH,
        C_VIRTEX_II           => TARGET_VIRTEX_II
              )
      port map(
      -- Inputs From the IPIF Bus 
        Bus_rst               =>  Bus2IP_Reset_i,
        Bus_Clk               =>  Bus2IP_Clk_i,
        Bus_RdReq             =>  Bus2IP_RdReq_i,
        Bus_WrReq             =>  Bus2IP_WrReq_i,
        Bus_Burst             =>  Bus2IP_Burst_i,
        Bus_BE                =>  Bus2IP_BE_i,
        Bus2FIFO_RdCE1        =>  BUS2IP_RdCE_i(RDFIFO_REG_CE_INDEX),
        Bus2FIFO_RdCE2        =>  BUS2IP_RdCE_i(RDFIFO_REG_CE_INDEX+1),
        Bus2FIFO_RdCE3        =>  BUS2IP_RdCE_i(RDFIFO_DATA_CE_INDEX),
        Bus2FIFO_WrCE1        =>  BUS2IP_WrCE_i(RDFIFO_REG_CE_INDEX),
        Bus2FIFO_WrCE2        =>  BUS2IP_WrCE_i(RDFIFO_REG_CE_INDEX+1),
        Bus2FIFO_WrCE3        =>  BUS2IP_WrCE_i(RDFIFO_DATA_CE_INDEX),
        Bus_DBus              =>  Bus2IP_Data_i,
      -- Inputs from the IP
        IP2RFIFO_WrReq        =>  IP2RFIFO_WrReq,
        IP2RFIFO_WrMark       =>  IP2RFIFO_WrMark,
        IP2RFIFO_WrRestore    =>  IP2RFIFO_WrRestore,
        IP2RFIFO_WrRelease    =>  IP2RFIFO_WrRelease,
        IP2RFIFO_Data         =>  IP2RFIFO_Data,
      -- Outputs to the IP  
        RFIFO2IP_WrAck        =>  RFIFO2IP_WrAck,
        RFIFO2IP_AlmostFull   =>  RFIFO2IP_AlmostFull,
        RFIFO2IP_Full         =>  RFIFO2IP_Full,
        RFIFO2IP_Vacancy      =>  RFIFO2IP_Vacancy,
      -- Outputs to the IPIF DMA/SG function
        RFIFO2DMA_AlmostEmpty =>  RFIFO2DMA_AlmostEmpty,
        RFIFO2DMA_Empty       =>  RFIFO2DMA_Empty,
        RFIFO2DMA_Occupancy   =>  RFIFO2DMA_Occupancy,
      -- Interrupt Output to IPIF Interrupt Register  
        FIFO2IRPT_DeadLock    =>  RdFIFO2Intr_DeadLock,
      -- Outputs to the IPIF Bus 
        FIFO2Bus_DBus         =>  sig_rdfifo_dbus_out,
        FIFO2Bus_WrAck        =>  rdfifo_status_reply_out(WRACK_BIT), 
        FIFO2Bus_RdAck        =>  rdfifo_status_reply_out(RDACK_BIT), 
        FIFO2Bus_Error        =>  rdfifo_status_reply_out(ERROR_BIT), 
        FIFO2Bus_Retry        =>  rdfifo_status_reply_out(RETRY_BIT), 
        FIFO2Bus_ToutSup      =>  rdfifo_status_reply_out(TOUTSUP_BIT)
      );

  
  
         rdfifo_status_reply_out(BTERM_BIT)    <= '0';
         rdfifo_status_reply_out(BUSY_BIT)     <= '0';
         
         rdfifo_status_reply_out(ADDRACK_BIT)  <= 
                                  rdfifo_status_reply_out(WRACK_BIT) or 
                                  rdfifo_status_reply_out(RDACK_BIT);
         
       -- Connect the status reply bus to the appropriate reply bus index
       status_reply_array(RDFIFO_DBUS_INDEX) <= rdfifo_status_reply_out;
         
       -- Now connect into the read DBus array
       read_dbus_array(RDFIFO_DBUS_INDEX) <= sig_rdfifo_dbus_out;
          
  
  end generate INCLUDE_RDFIFO; 

  
  
  
  REMOVE_RDFIFO : if (RDFIFO_PRESENT = false) generate
  
          RdFIFO2Intr_DeadLock  <=  '0';
          RFIFO2DMA_AlmostEmpty <=  '0';
          RFIFO2DMA_Empty       <=  '0';
          RFIFO2DMA_Occupancy   <=  (others => '0');
          RFIFO2IP_AlmostFull   <=  '0';
          RFIFO2IP_Full         <=  '0';
          RFIFO2IP_Vacancy      <=  (others => '0');
          RFIFO2IP_WrAck        <=  '0';  
  
  end generate REMOVE_RDFIFO; 
  
                                                                
-------------------------------------------------------------------------------

 INCLUDE_WRFIFO : if (WRFIFO_PRESENT = true) generate
  
 
     -- Detirmine the CE indexes to use for the WRFIFO Register CE
     Constant WRFIFO_REG_NAME_INDEX  : integer := get_id_index(C_ARD_ID_ARRAY,IPIF_WRFIFO_REG);
     Constant WRFIFO_REG_CE_INDEX    : integer := calc_start_ce_index (C_ARD_NUM_CE_ARRAY, 
                                                                       WRFIFO_REG_NAME_INDEX);
     
     -- Detirmine the CE index to use for the WRFIFO Data CE
     Constant WRFIFO_DATA_NAME_INDEX : integer := get_id_index(C_ARD_ID_ARRAY,IPIF_WRFIFO_DATA);
     Constant WRFIFO_DATA_CE_INDEX   : integer := calc_start_ce_index (C_ARD_NUM_CE_ARRAY,
                                                                       WRFIFO_DATA_NAME_INDEX);
     constant WRFIFO_DATA_WIDTH      : integer := C_ARD_DWIDTH_ARRAY(WRFIFO_DATA_NAME_INDEX);
     constant WRFIFO_DEPTH_LOG2X     : integer := log2(C_WRFIFO_DEPTH);
     
     Constant WRFIFO_DBUS_INDEX      : integer := get_ipif_id_dbus_index(C_ARD_ID_ARRAY,
                                                                         IPIF_WRFIFO_DATA);       
     
     Signal   sig_wrfifo_dbus_out     : std_logic_vector(0 to C_IPIF_DWIDTH-1);
     Signal   wrfifo_status_reply_out : std_logic_vector(0 to  
                                                         NUM_STATUS_REPLY_ELEMENTS-1);
     
     component wrpfifo_top
       Generic (
           C_MIR_ENABLE          : Boolean;
           C_BLOCK_ID            : integer; 
           C_FIFO_DEPTH_LOG2X    : Integer;     
           C_FIFO_WIDTH          : Integer;     
           C_INCLUDE_PACKET_MODE : Boolean;
           C_INCLUDE_VACANCY     : Boolean;   
           C_SUPPORT_BURST       : Boolean;
           C_IPIF_DBUS_WIDTH     : Integer;
           C_VIRTEX_II           : boolean
               ); 
       port(
         -- Inputs From the IPIF Bus 
           Bus_rst               : In  std_logic;  
           Bus_clk               : In  std_logic;  
           Bus_RdReq             : In  std_logic;
           Bus_WrReq             : In  std_logic;
           Bus_Burst             : In  std_logic;
           Bus_BE                : In  std_logic_vector(0 to (C_IPIF_DBUS_WIDTH/8)-1);
           Bus2FIFO_RdCE1        : In  std_logic;
           Bus2FIFO_RdCE2        : In  std_logic;
           Bus2FIFO_RdCE3        : In  std_logic;
           Bus2FIFO_WrCE1        : In  std_logic;
           Bus2FIFO_WrCE2        : In  std_logic;
           Bus2FIFO_WrCE3        : In  std_logic;
           Bus_DBus              : In  std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
         -- Inputs from the IP
           IP2WFIFO_RdReq        : In std_logic;
           IP2WFIFO_RdMark       : In std_logic;
           IP2WFIFO_RdRestore    : In std_logic;
           IP2WFIFO_RdRelease    : In std_logic;
         -- Outputs to the IP  
           WFIFO2IP_Data         : Out std_logic_vector(0 to C_FIFO_WIDTH-1);
           WFIFO2IP_RdAck        : Out std_logic;
           WFIFO2IP_AlmostEmpty  : Out std_logic;
           WFIFO2IP_Empty        : Out std_logic;
           WFIFO2IP_Occupancy    : Out std_logic_vector(0 to C_FIFO_DEPTH_LOG2X);
         -- Outputs to the IPIF DMA/SG function
           WFIFO2DMA_AlmostFull  : Out std_logic;
           WFIFO2DMA_Full        : Out std_logic;
           WFIFO2DMA_Vacancy     : Out std_logic_vector(0 to C_FIFO_DEPTH_LOG2X);
         -- Interrupt Output to IPIF Interrupt Register  
           FIFO2IRPT_DeadLock    : Out std_logic;
         -- Outputs to the IPIF Bus 
           FIFO2Bus_DBus         : Out std_logic_vector(0 to C_IPIF_DBUS_WIDTH-1);
           FIFO2Bus_WrAck        : Out std_logic;
           FIFO2Bus_RdAck        : Out std_logic;
           FIFO2Bus_Error        : Out std_logic;
           FIFO2Bus_Retry        : Out std_logic;
           FIFO2Bus_ToutSup      : Out std_logic
         );
       end component wrpfifo_top;
     
 
     
  
  begin
    
    
    I_WRPFIFO_TOP: wrpfifo_top
      Generic map(
          C_MIR_ENABLE          =>  C_DEV_MIR_ENABLE,                      
          C_BLOCK_ID            =>  C_DEV_BLK_ID,                              
          C_FIFO_DEPTH_LOG2X    =>  WRFIFO_DEPTH_LOG2X,                   
          C_FIFO_WIDTH          =>  WRFIFO_DATA_WIDTH,                       
          C_INCLUDE_PACKET_MODE =>  C_WRFIFO_INCLUDE_PACKET_MODE,               
          C_INCLUDE_VACANCY     =>  C_WRFIFO_INCLUDE_VACANCY,            
          C_SUPPORT_BURST       =>  C_DEV_BURST_ENABLE,                   
          C_IPIF_DBUS_WIDTH     =>  C_IPIF_DWIDTH,                             
          C_VIRTEX_II           =>  TARGET_VIRTEX_II                         
              )
      port map(
        -- Inputs From the IPIF Bus 
          Bus_rst               =>  Bus2IP_Reset_i,   
          Bus_clk               =>  Bus2IP_Clk_i  ,   
          Bus_RdReq             =>  Bus2IP_RdReq_i, 
          Bus_WrReq             =>  Bus2IP_WrReq_i, 
          Bus_Burst             =>  Bus2IP_Burst_i,
          Bus_BE                =>  Bus2IP_BE_i,   
          Bus2FIFO_RdCE1        =>  BUS2IP_RdCE_i(WRFIFO_REG_CE_INDEX),     
          Bus2FIFO_RdCE2        =>  BUS2IP_RdCE_i(WRFIFO_REG_CE_INDEX+1),   
          Bus2FIFO_RdCE3        =>  BUS2IP_RdCE_i(WRFIFO_DATA_CE_INDEX),    
          Bus2FIFO_WrCE1        =>  BUS2IP_WrCE_i(WRFIFO_REG_CE_INDEX),     
          Bus2FIFO_WrCE2        =>  BUS2IP_WrCE_i(WRFIFO_REG_CE_INDEX+1),   
          Bus2FIFO_WrCE3        =>  BUS2IP_WrCE_i(WRFIFO_DATA_CE_INDEX),    
          Bus_DBus              =>  Bus2IP_Data_i,                          
        -- Inputs from the IP
          IP2WFIFO_RdReq        =>  IP2WFIFO_RdReq,     
          IP2WFIFO_RdMark       =>  IP2WFIFO_RdMark,    
          IP2WFIFO_RdRestore    =>  IP2WFIFO_RdRestore, 
          IP2WFIFO_RdRelease    =>  IP2WFIFO_RdRelease, 
        -- Outputs to the IP  
          WFIFO2IP_Data         =>  WFIFO2IP_Data,          
          WFIFO2IP_RdAck        =>  WFIFO2IP_RdAck,         
          WFIFO2IP_AlmostEmpty  =>  WFIFO2IP_AlmostEmpty,   
          WFIFO2IP_Empty        =>  WFIFO2IP_Empty,         
          WFIFO2IP_Occupancy    =>  WFIFO2IP_Occupancy,     
        -- Outputs to the IPIF DMA/SG function
          WFIFO2DMA_AlmostFull  =>  WFIFO2DMA_AlmostFull,   
          WFIFO2DMA_Full        =>  WFIFO2DMA_Full,         
          WFIFO2DMA_Vacancy     =>  WFIFO2DMA_Vacancy,      
        -- Interrupt Output to IPIF Interrupt Register  
          FIFO2IRPT_DeadLock    =>  WrFIFO2Intr_DeadLock, 
        -- Outputs to the IPIF Bus 
          FIFO2Bus_DBus         =>  sig_wrfifo_dbus_out, 
          FIFO2Bus_WrAck        =>  wrfifo_status_reply_out(WRACK_BIT), 
          FIFO2Bus_RdAck        =>  wrfifo_status_reply_out(RDACK_BIT), 
          FIFO2Bus_Error        =>  wrfifo_status_reply_out(ERROR_BIT), 
          FIFO2Bus_Retry        =>  wrfifo_status_reply_out(RETRY_BIT), 
          FIFO2Bus_ToutSup      =>  wrfifo_status_reply_out(TOUTSUP_BIT)
        );

  
  
         wrfifo_status_reply_out(BTERM_BIT)    <= '0';
         wrfifo_status_reply_out(BUSY_BIT)     <= '0';
         
         wrfifo_status_reply_out(ADDRACK_BIT)  <= 
                                  wrfifo_status_reply_out(WRACK_BIT) or 
                                  wrfifo_status_reply_out(RDACK_BIT);
         
       -- Connect the status reply bus to the appropriate reply bus index
       status_reply_array(WRFIFO_DBUS_INDEX) <= wrfifo_status_reply_out;
         
       -- Now connect into the read DBus array
       read_dbus_array(WRFIFO_DBUS_INDEX) <= sig_wrfifo_dbus_out;
          
  
  
 end generate INCLUDE_WRFIFO; 

 
 

 REMOVE_WRFIFO : if (WRFIFO_PRESENT = false) generate

                WFIFO2DMA_Full        <=  '0';
                WFIFO2DMA_Vacancy     <=  (others => '0');
                WFIFO2IP_AlmostEmpty  <=  '0';
                WFIFO2IP_Data         <=  (others => '0');
                WFIFO2IP_Empty        <=  '0';
                WFIFO2IP_Occupancy    <=  (others => '0');
                WFIFO2IP_RdAck        <=  '0';
                WrFIFO2Intr_DeadLock  <=  '0';
                                  
                                  
 end generate REMOVE_WRFIFO; 
 
  
 ------------------------------------------------------------------------------
  
 ------------------------------------------------------------------------------
 -- Include DMA in the IPIF
 ------------------------------------------------------------------------------
 INCLUDE_DMA : if (DMA_PRESENT = True) generate
     
     
      -- component dma_sg_blk
      --     generic (
      --              C_DMA_BLK_ID : INTEGER := 255;
      --              C_DMA_CHAN_NUM : INTEGER := 2;
      --              C_DMA_CH1_TYPE : INTEGER := 2;
      --              C_DMA_CH2_TYPE : INTEGER := 3;
      --              C_DMA_ALLOW_BURST : BOOLEAN := True;
      --              C_DMA_BAR : std_logic_vector := X"70002300";
      --              C_DMA_MAX_LENGTH_SIZE : INTEGER := 11;
      --              C_DMA_INTR_COALESCE : BOOLEAN := True;
      --              C_IP_REG_BAR : std_logic_vector := X"70001100";
      --              C_RXL_FIFO_BAR : std_logic_vector := X"70000000";
      --              C_TXL_FIFO_BAR : std_logic_vector := X"70000000";
      --              C_TXS_FIFO_BAR : std_logic_vector := X"70000000";
      --              C_RXS_FIFO_BAR : std_logic_vector := X"70000000";
      --              C_SG_PACKET_WAIT_UNIT_NS : INTEGER := 1000000;
      --              C_OPB_ABUS_WIDTH : INTEGER := 32;
      --              C_OPB_DBUS_WIDTH : INTEGER := 32;
      --              C_OPB_CLK_PERIOD_PS : INTEGER := 16000;
      --              C_B : INTEGER := 4;
      --              C_M : INTEGER := 26
      --              );
      --     port (
      --           Bus2IP_Addr_i : in std_logic_vector(0 to C_M - 1 );
      --           Bus2IP_BE_sa : in std_logic_vector(0 to C_B - 1 );
      --           Bus2IP_Burst_sa : in std_logic;
      --           Bus2IP_Clk_i : in std_logic;
      --           Bus2IP_Data_sa : in std_logic_vector(0 to C_OPB_DBUS_WIDTH - 1 );
      --           Bus2IP_DMA_Ack : out std_logic;
      --           Bus2IP_Freeze_i : in std_logic;
      --           Bus2IP_MstError_i : in std_logic;
      --           Bus2IP_MstLastAck_i : in std_logic;
      --           Bus2IP_MstRdAck_i : in std_logic;
      --           Bus2IP_MstRetry_i : in std_logic;
      --           Bus2IP_MstTimeOut_i : in std_logic;
      --           Bus2IP_MstWrAck_i : in std_logic;
      --           Bus2IP_RdReq_sa : in std_logic;
      --           Bus2IP_Reset_i : in std_logic;
      --           Bus2IP_WrReq_sa : in std_logic;
      --           DMA2Bus_Addr : out std_logic_vector(0 to C_OPB_ABUS_WIDTH - 1 );
      --           DMA2Bus_Data : out std_logic_vector(0 to C_OPB_DBUS_WIDTH - 1 );
      --           DMA2Intr_Intr : out std_logic_vector(0 to 1 );
      --           DMA2IP_Addr : out std_logic_vector(0 to C_M - 1 );
      --           DMA_MstBE : out std_logic_vector(0 to C_B - 1 );
      --           DMA_MstBurst : out std_logic;
      --           DMA_MstBusLock : out std_logic;
      --           DMA_MstRdReq : out std_logic;
      --           DMA_MstWrReq : out std_logic;
      --           DMA_RdCE : in std_logic;
      --           DMA_SG_Error : out std_logic;
      --           DMA_SG_RdAck : out std_logic;
      --           DMA_SG_Retry : out std_logic;
      --           DMA_SG_ToutSup : out std_logic;
      --           DMA_SG_WrAck : out std_logic;
      --           DMA_WrCE : in std_logic;
      --           IP2Bus_DMA_Req : in std_logic;
      --           IP2DMA_RxLength_Empty : in std_logic;
      --           IP2DMA_RxStatus_Empty : in std_logic;
      --           IP2DMA_TxLength_Full : in std_logic;
      --           IP2DMA_TxStatus_Empty : in std_logic;
      --           Mstr_sel_ma : in std_logic;
      --           RFIFO2DMA_AlmostEmpty : in std_logic;
      --           RFIFO2DMA_Empty : in std_logic;
      --           RFIFO2DMA_Occupancy : in std_logic_vector(0 to 9 );
      --           WFIFO2DMA_AlmostFull : in std_logic;
      --           WFIFO2DMA_Full : in std_logic;
      --           WFIFO2DMA_Vacancy : in std_logic_vector(0 to 9 )
      --           );
      -- end component;
 
     
     
     
     -- Detirmine the CE index to use for the DMA Data CE
     Constant DMA_NAME_INDEX : integer := get_id_index(C_ARD_ID_ARRAY,
                                                       IPIF_DMA_SG);
     Constant DMA_CE_INDEX   : integer := calc_start_ce_index (C_ARD_NUM_CE_ARRAY,
                                                               DMA_NAME_INDEX);
     constant DMA_DATA_WIDTH : integer := C_ARD_DWIDTH_ARRAY(DMA_NAME_INDEX);

     Constant DMA_DBUS_INDEX : integer := get_ipif_id_dbus_index(C_ARD_ID_ARRAY,
                                                                 IPIF_DMA_SG);       
     
     Signal   sig_dma_dbus_out     : std_logic_vector(0 to DMA_DATA_WIDTH-1);
     Signal   dma_status_reply_out : std_logic_vector(0 to  
                                                      NUM_STATUS_REPLY_ELEMENTS-1);
     
     
     
   begin
      -- I_DMA_SG_BLK: dma_sg_blk
      --   generic map (C_DEV_BLK_ID,
      --                C_DMA_CHAN_NUM,
      --                C_DMA_CH1_TYPE,
      --                C_DMA_CH2_TYPE,
      --                DMA_USE_BURST,
      --                DMA_REG_BASEADDR,
      --                C_DMA_LENGTH_WIDTH,
      --                C_DMA_INTR_COALESCE,
      --                IP_REG_BASEADDR,
      --                IP_RXL_FIFO_BASEADDR,
      --                IP_TXL_FIFO_BASEADDR,
      --                IP_TXS_FIFO_BASEADDR,
      --                IP_RXS_FIFO_BASEADDR,
      --                C_DMA_PACKET_WAIT_UNIT_NS,
      --                C_OPB_ABUS_WIDTH,
      --                C_OPB_DBUS_WIDTH,
      --                C_OPB_CLK_PERIOD_PS,
      --                C_OPB_BE_NUM,
      --                C_IPIF_ABUS_WIDTH-2)
      --   port map (
      --             Bus2IP_Addr_i => Bus2IP_Addr_i(0 to C_IPIF_ABUS_WIDTH - 3),
      --             Bus2IP_BE_sa => Bus2IP_BE_i(0 to C_OPB_BE_NUM - 1),
      --             Bus2IP_Burst_sa => Bus2IP_Burst_sa,
      --             Bus2IP_Clk_i => Bus2IP_Clk_i,
      --             Bus2IP_Data_sa => Bus2IP_Data_sa(0 to C_OPB_DBUS_WIDTH - 1),
      --             Bus2IP_DMA_Ack => Bus2IP_DMA_Ack,
      --             Bus2IP_Freeze_i => Bus2IP_Freeze_i,
      --             Bus2IP_MstError_i => Bus2IP_MstError_i,
      --             Bus2IP_MstLastAck_i => Bus2IP_MstLastAck_i,
      --             Bus2IP_MstRdAck_i => Bus2IP_MstRdAck_i,
      --             Bus2IP_MstRetry_i => Bus2IP_MstRetry_i,
      --             Bus2IP_MstTimeOut_i => Bus2IP_MstTimeOut_i,
      --             Bus2IP_MstWrAck_i => Bus2IP_MstWrAck_i,
      --             Bus2IP_RdReq_sa => Bus2IP_RdReq_sa,
      --             Bus2IP_Reset_i => Bus2IP_Reset_i,
      --             Bus2IP_WrReq_sa => Bus2IP_WrReq_sa,
      --             DMA2Bus_Addr => DMA2Bus_Addr(0 to C_OPB_ABUS_WIDTH - 1),
      --             DMA2Bus_Data => DMA2Bus_Data(0 to C_OPB_DBUS_WIDTH - 1),
      --             DMA2Intr_Intr => DMA2Intr_Intr(0 to 1),
      --             DMA2IP_Addr => DMA2IP_Addr(0 to C_IPIF_ABUS_WIDTH - 3),
      --               -- See assignment to DMA2IP_Addr(30:31), below.
      --             DMA_MstBE => DMA_MstBE(0 to C_OPB_BE_NUM - 1),
      --             DMA_MstBurst => DMA_MstBurst,
      --             DMA_MstBusLock => DMA_MstBusLock,
      --             DMA_MstRdReq => DMA_MstRdReq,
      --             DMA_MstWrReq => DMA_MstWrReq,
      --             DMA_RdCE => DMA_RdCE,
      --             DMA_SG_Error => DMA_SG_Error,
      --             DMA_SG_RdAck => DMA_SG_RdAck,
      --             DMA_SG_Retry => DMA_SG_Retry,
      --             DMA_SG_ToutSup => DMA_SG_ToutSup,
      --             DMA_SG_WrAck => DMA_SG_WrAck,
      --             DMA_WrCE => DMA_WrCE,
      --             IP2Bus_DMA_Req => IP2Bus_DMA_Req,
      --             IP2DMA_RxLength_Empty => IP2DMA_RxLength_Empty,
      --             IP2DMA_RxStatus_Empty => IP2DMA_RxStatus_Empty,
      --             IP2DMA_TxLength_Full => IP2DMA_TxLength_Full,
      --             IP2DMA_TxStatus_Empty => IP2DMA_TxStatus_Empty,
      --             Mstr_sel_ma => Mstr_sel_ma,
      --             RFIFO2DMA_AlmostEmpty => RFIFO2DMA_AlmostEmpty,
      --             RFIFO2DMA_Empty => RFIFO2DMA_Empty,
      --             RFIFO2DMA_Occupancy => RFIFO2DMA_Occupancy(0 to 9),
      --             WFIFO2DMA_AlmostFull => WFIFO2DMA_AlmostFull,
      --             WFIFO2DMA_Full => WFIFO2DMA_Full,
      --             WFIFO2DMA_Vacancy => WFIFO2DMA_Vacancy(0 to 9));
      -- 
      --             DMA2IP_Addr(C_IPIF_ABUS_WIDTH - 2 to C_IPIF_ABUS_WIDTH -1) <= (others => '0');
 
      
      --    ---------------------------------------------------------------
      --    -- Process 
      --    --
      --    -- This process connects the data bus from the dma module
      --    -- to the ip2bus_dmux module. This is needed since the dma
      --    -- bus width may not be as wide as the ipif dbus width.
      --    ---------------------------------------------------------------
      --    CONNECT_DMA_DBUS_OUT : process (sig_dma_dbus_out)
      --       Begin
      --        
      --        -- default entire bus to zeros
      --          DMA2Bus_Data <= (others =>'0');  
      --        
      --        -- now assign reset dbus outputs   
      --          DMA2Bus_Data(0 to DMA_DATA_WIDTH-1) <= 
      --                                          sig_dma_dbus_out; 
      --                                                
      --       End process; -- CONNECT_DMA_DBUS_OUT
      
      
      
      
      
      
      
      end generate INCLUDE_DMA; 
                 
            
            
    ------------------------------------------------------------------------------
    -- Don't include DMA in the IPIF . Drive all outputs to zero.
    ------------------------------------------------------------------------------
   
    REMOVE_DMA : if (DMA_PRESENT = False) generate
   
           Bus2IP_DMA_Ack      <=  '0';    
           DMA2Bus_Addr        <=  (others => '0');    
           DMA2Intr_Intr       <=  (others => '0');    
           DMA2IP_Addr         <=  (others => '0');    
           DMA_MstBE           <=  (others => '0');    
           DMA_MstBurst        <=  '0';    
           DMA_MstBusLock      <=  '0';    
           DMA_MstRdReq        <=  '0';    
           DMA_MstWrReq        <=  '0';    
    
      end generate REMOVE_DMA; 
   
  
  
-------------------------------------------------------------------------------  
-- Misc logic assignments  
  
  Sl_addrAck         <=  Sl_addrAck_i    ;
  Sl_SSize           <=  Sl_SSize_i      ;
  Sl_wait            <=  Sl_wait_i       ;
  Sl_rearbitrate     <=  Sl_rearbitrate_i;
  Sl_wrDAck          <=  Sl_wrDAck_i     ;
  Sl_wrComp          <=  Sl_wrComp_i     ;
  Sl_wrBTerm         <=  Sl_wrBTerm_i    ;
  Sl_rdDBus          <=  Sl_rdDBus_i     ;
  Sl_rdWdAddr        <=  Sl_rdWdAddr_i   ;
  Sl_rdDAck          <=  Sl_rdDAck_i     ;
  Sl_rdComp          <=  Sl_rdComp_i     ;
  Sl_rdBTerm         <=  Sl_rdBTerm_i    ;
  Sl_MBusy           <=  Sl_MBusy_i      ;
  Sl_MErr            <=  Sl_MErr_i       ;
  
  
  -- Now based on PLB Bus DWidth
  Sl_SSize_i         <= CONV_STD_LOGIC_VECTOR(SSIZE_RESPONSE, 2);
  
  
  
  --Bus2IP_AValid    <= Bus2IP_AValid_i;
  IP2Bus_AddrSel_i   <= '0';
  Bus2IP_RNW         <= Bus2IP_RNW_i;
  Bus2IP_Addr        <= Bus2IP_Addr_i; -- full PLB Address
  Bus2IP_Data        <= Bus2IP_Data_i(0 to C_IPIF_DWIDTH-1);
  Bus2IP_BE          <= Bus2IP_BE_i;
  Bus2IP_WrReq       <= Bus2IP_WrReq_i;
  Bus2IP_RdReq       <= Bus2IP_RdReq_i;
  Bus2IP_Burst       <= Bus2IP_Burst_i;
  Bus2IP_IBurst      <= Bus2IP_IBurst_i;
  Bus2IP_RNW_Early   <= Bus2IP_RNW_Early_i;
  Bus2IP_PselHit     <= Bus2IP_PselHit_i;  
  Bus2IP_CS          <= Bus2IP_CS_i;
  Bus2IP_Des_sig     <= Bus2IP_Des_sig_i;--JTK Dual DDR Hack--     
  Bus2IP_CE          <= Bus2IP_CE_i;   
  Bus2IP_RdCE        <= Bus2IP_RdCE_i; 
  Bus2IP_WrCE        <= Bus2IP_WrCE_i; 
  Bus2IP_MstWrAck    <= Bus2IP_MstWrAck_i and not(Mstr_sel_ma);
  Bus2IP_MstRdAck    <= Bus2IP_MstRdAck_i and not(Mstr_sel_ma);
  Bus2IP_MstRetry    <= Bus2IP_MstRetry_i;
  Bus2IP_MstError    <= Bus2IP_MstError_i;
  Bus2IP_MstTimeOut  <= Bus2IP_MstTimeOut_i;
  Bus2IP_MstLastAck  <= Bus2IP_MstLastAck_i;
  Bus2IP_Clk_i       <= PLB_Clk;
  Bus2IP_Clk         <= PLB_Clk;
  Bus_Reset_i        <= Reset;
  Bus2IP_Freeze_i    <= Freeze;
  Bus2IP_Freeze      <= Freeze;
  IP2INTC_Irpt       <= Intr2Bus_DevIntr;
  IPIF_Lvl_Interrupts(0) <= DMA2Intr_Intr(0);
  IPIF_Lvl_Interrupts(1) <= DMA2Intr_Intr(1);
  IPIF_Lvl_Interrupts(2) <= RdFIFO2Intr_DeadLock;
  IPIF_Lvl_Interrupts(3) <= WrFIFO2Intr_DeadLock;
  IPIF_Reg_Interrupts(0) <= status_reply_or(ERROR_BIT);
  IPIF_Reg_Interrupts(1) <= SA2INT_DAck_Timeout_i; -- *** PLB new
  Bus2IP_Reset           <= Bus2IP_Reset_i;
  --const_zero             <= LOGIC_LOW;
  


-- End of PLB_IPIF logic ------------------------------------------------------


                                                                               
                                                                               
                                                                               
                                                                               
-- Hardware Debug Support
-------------------------------------------------------------------------------
-- The chipscope controller, below, can be uncommented when hardware debug
-- of the IPIF is needed.
-- If used, the trigger signals are assigned to ila_trig and the data signals
-- are assigned to ila_data. Trigger signals that need to be seen need to
-- be in both places.
-------------------------------------------------------------------------------
--
--       -- for hardware implimentation, allow ChipScope insertion
--         MAKE_CHIPSCOPE :  if INCLUDE_CHIPSCOPE generate
--       
--       
--          ------ ChipScope declaration stuff ---------------------------------------
--            
--            --  ILA core signal declarations
--            signal control_bus           : std_logic_vector(41 downto 0);
--            signal ila_data              : std_logic_vector(63 downto 0);
--            signal ila_trig              : std_logic_vector(7 downto 0);
--            -- signal data                  : std_logic_vector(31 downto 0);
--          
--            
--            
--            -------------------------------------------------------------------
--            --
--            --  ICON core component declaration
--            --
--            -------------------------------------------------------------------
--            component ipif_icon
--              port
--              (
--                CONTROL0    :   out std_logic_vector(41 downto 0)
--              );
--            end component;
--            
--            -------------------------------------------------------------------
--            --  
--            --  ICON core compiler-specific attributes
--            --
--            -------------------------------------------------------------------
--            attribute syn_black_box : boolean;
--            attribute syn_black_box of ipif_icon : component is TRUE;
--            attribute syn_noprune : boolean;
--            attribute syn_noprune of ipif_icon : component is TRUE;
--          
--            
--            
--            -------------------------------------------------------------------
--            --
--            --  ILA core component declaration
--            --
--            -------------------------------------------------------------------
--            component ila_64
--              port
--              (
--                CONTROL     : in    std_logic_vector(41 downto 0);
--                CLK         : in    std_logic;
--                DATA        : in    std_logic_vector(63 downto 0);
--                TRIG        : in    std_logic_vector(7 downto 0)
--              );
--            end component;
--          
--                           
--                           
--            -------------------------------------------------------------------
--            --
--            --  ILA core compiler-specific attributes
--            --
--            -------------------------------------------------------------------
--            attribute syn_black_box of ila_64 : component is TRUE;
--            attribute syn_noprune of ila_64 : component is TRUE;
--            
--                                                           
--           -- End of ChipScope declaration stuff ----------------------------------
--       
--       
--       begin
--         
--       
--          -------------------------------------------------------------------
--          --
--          --  ICON core instance
--          --
--          -------------------------------------------------------------------
--          i_ipif_icon : ipif_icon
--            port map
--            (
--              CONTROL0   => control_bus
--            );
--          
--          
--          
--          -------------------------------------------------------------------
--          --
--          --  ILA core instance
--          --
--          -------------------------------------------------------------------
--          i_ipif_ila : ila_64
--            port map
--            (
--              CONTROL => control_bus,
--              CLK     => OPBClk,
--              DATA    => ila_data,
--              TRIG    => ila_trig   
--            );
--       
--          ila_trig(0)            <=   OPB_errAck; 
--          ila_trig(1)            <=   OPB_xferAck ; 
--          ila_trig(2)            <= t_Mn_request;
--          ila_trig(3)            <=   Bus2IP_RdReq_i;
--          ila_trig(4)            <=   Interrupt_WrCE(2); 
--          ila_trig(5)            <=   Interrupt_WrCE(8); 
--          ila_trig(6)            <=   Bus2IP_MstError_i;
--          ila_trig(7)            <=   RdFIFO_RdCE;  
--                                                           
--                                 
--          ila_data(0)            <=   OPB_errAck; 
--          ila_data(1)            <=   OPB_xferAck ; 
--          ila_data(2)            <= t_Mn_request;
--          ila_data(3)            <=   Bus2IP_RdReq_i;
--          ila_data(4)            <=   MA2SA_select; 
--          ila_data(5)            <=   MA2SA_XferAck; 
--          ila_data(6)            <=   MA2SA_Rd;
--          ila_data(7)            <=   RdFIFO_RdCE;  
--          ila_data(8)            <=   Bus2IP_RangeSel_i;
--          ila_data(9)            <=   Mstr_sel_ma;
--          ila_data(10)           <=   Addr_Cntr_ClkEN_sa;
--          ila_data(11)           <= t_ma2sa_rd_flag;
--          ila_data(12)           <=   MUX2SA_RdAck_i;
--          ila_data(13)           <=   IP2Bus_Error;
--          ila_data(14)           <=   RFIFO_Error;
--          ila_data(15)           <= t_mstr_busy;
--          ila_data(16)           <= t_opb_busy;
--          ila_data(32 downto 17) <=   Bus2IP_Addr_i(C_IPIF_ABUS_WIDTH-16 to C_IPIF_ABUS_WIDTH-1);  
--          ila_data(48 downto 33) <=   OPB_ABus(16 to C_PLB_AWIDTH-1);  
--          ila_data(52 downto 49) <=   OPB_ABus(0 to 3);  
--          ila_data(53)           <=   Bus2IP_Burst_i;              
--          ila_data(54)           <=   OPB_select;              
--          ila_data(55)           <=   OPB_RNW;              
--          ila_data(56)           <=   OPB_seqAddr;              
--          ila_data(60 downto 57) <=   OPB_DBus( 0 to  3);  
--          ila_data(63 downto 61) <=   OPB_DBus(29 to 31);  
--       
--            
--         end generate MAKE_CHIPSCOPE;   
--       
end implementation; -- (architecture)
