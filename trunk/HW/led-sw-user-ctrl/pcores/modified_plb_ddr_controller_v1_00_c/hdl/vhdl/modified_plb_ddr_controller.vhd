-------------------------------------------------------------------------------
-- $Id: modified_plb_ddr_controller.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- plb_ddr.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
--  ***************************************************************************
--  **  Copyright(C) 2003 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        plb_ddr.vhd
-- Version:         v1.00c
-- Description:     Top level file for PLB DDR controller
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--                  -- plb_ddr.vhd                  
--                      -- ddr_controller.vhd
--                          -- read_data_path.vhd
--                          -- data_statemachine.vhd
--                          -- command_statemachine.vhd
--                          -- init_statemachine.vhd
--                          -- counters.vhd
--                          -- io_registers.vhd
--                          -- clock_gen.vhd
--                          -- ipic_if.vhd
--                      -- plb_ipif.vhd
--
-------------------------------------------------------------------------------
-- Author:          ALS
-- History:
--   ALS           05/20/02    First Version
-- ^^^^^^
--      First version of PLB DDR controller
-- ~~~~~~
-- 
--  ALS             06/05/02
-- ^^^^^^
--      Removed C_IPIF_DWIDTH and C_IPIF_AWIDTH from top level. These are 
--      C_PLB_DWIDTH and C_PLB_AWIDTH. Added C_FAMILY generic.
-- ~~~~~~
--  ALS             06/06/02
-- ^^^^^^
--      Changed C_CLK_FREQ to C_PLB_CLK_PERIOD_PS to be consistent with other cores.
-- ~~~~~~
--  ALS             06/15/02
-- ^^^^^^
--      Added Clk, Clk90, and Clk_DDR_RdData outputs
-- ~~~~~~
--  ALS             07/02/02
-- ^^^^^^
--      Upgraded to plb_ipif_v1_00_b and ddr_v1_00_b.
-- ~~~~~~
--  ALS             07/12/02
-- ^^^^^^
--      Added C_REG_DIMM and C_INCLUDE_DDR_DCM generics. Changed C_INCLUDE_CLK90_GEN
--      to C_INCLUDE_CLK90_DCM for clarity. Also added C_INCLUDE_BURSTS to 
--      control bursting capability.
-- ~~~~~~
--  ALS             07/19/02            -- VERSION B (to avoid confusion)
-- ^^^^^^
--      Removed C_REG_DIMM from top level since can't hardware test at this point.
--      Set to 0 in DDR instantiation.
--      Changed C_INCLUDE_BURSTS to C_INCLUDE_BURST_CACHELN_SUPPORT.
-- ~~~~~~
--  ALS             09/10/92
-- ^^^^^^
--      Put in XST workarounds to correctly handle ARD_DTIME_READ_ARRAY to IPIF.
--      Also put back in the C_REG_DIMM generic.
-- ~~~~~~
--  ALS             10/03/02
-- ^^^^^^
--      Removed all generics associated with the DCMs. Added generic to indicate
--      if the DDR DQS lines were pulled up or down. Renamed DDR_Clk_in to 
--      DDR_Clk90_in. Removed the following ports:
--          Clk            
--          Clk90          
--          Clk_DDR_RdData 
--          Clk90_locked   
--          Clkddr_locked  
--          DCM_Rst        
-- ~~~~~~
--  ALS             06/25/03
-- ^^^^^^
--      Version C:
--      Use latest PLB IPIF to remove latency and support indeterminate bursts
--      Add INIT_DONE as output pin
--      Provide C_SIM_INIT_TIME parameter to allow simulation to run faster
--      Remove XST workarounds
--      Assert TOUTSUP during transfers
-- ~~~~~~
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.proc_common_pkg.all;
use modified_plb_ddr_controller_v1_00_c.family.all;
use modified_plb_ddr_controller_v1_00_c.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.ipif_pkg.all;
use modified_plb_ddr_controller_v1_00_c.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_DQS_PULLUPS          -- DDR DQS lines have pullups if 1, pulldowns if 0
--      C_INCLUDE_BURST_CACHELN_SUPPORT -- include bursting and cacheline support
--      C_REG_DIMM             -- include pipeline stage to support Reg DIMM
--      C_DDR_TMRD             -- Load Mode Register command cycle time
--      C_DDR_TWR              -- write recovery time
--      C_DDR_TWTR             -- write-to-read recovery time
--      C_DDR_TRAS             -- delay after ACTIVE command before
--                             -- PRECHARGE command
--      C_DDR_TRC              -- delay after ACTIVE command before
--                             -- another ACTIVE or AUTOREFRESH command
--      C_DDR_TRFC             -- delay after AUTOREFRESH before another command
--      C_DDR_TRCD             -- delay after ACTIVE before READ/WRITE
--      C_DDR_TRRD             -- delay after ACTIVE row a before ACTIVE 
--                             -- row b
--      C_DDR_TRP              -- delay after PRECHARGE command
--      C_DDR_TREFC            -- refresh to refresh command interval
--      C_DDR_TREFI            -- average periodic refresh command interval
--      C_DDR_CAS_LAT          -- CAS latency
--      C_DDR_DWIDTH           -- DDR data width 
--      C_DDR_AWIDTH           -- DDR row address width
--      C_DDR_COL_AWIDTH       -- DDR column address width
--      C_DDR_BANK_AWIDTH      -- DDR bank address width
--
--      C_PLB_CLK_PERIOD_PS    -- clock frequency
--      C_FAMILY               -- target device family
--      C_BASEADDR             -- DDR memory base address
--      C_HIGHADDR             -- DDR memory high address
--      C_PLB_NUM_MASTERS      -- Number of PLB masters
--      C_PLB_MID_WIDTH        -- Number of bits to encode number of masters
--      C_PLB_AWIDTH           -- PLB address width
--      C_PLB_DWIDTH           -- PLB data width
--
--      C_SIM_INIT_TIME_PS     -- DDR initialization time to be used in simulation
--
-- Definition of Ports:
--  -- PLB interface
--      PLB_ABus               -- PLB address bus
--      PLB_PAValid            -- PLB primary address valid indicator
--      PLB_SAValid            -- PLB secondary address valid indicator
--      PLB_rdPrim             -- PLB secondary to primary read request indicator
--      PLB_wrPrim             -- PLB secondary to primary write request indicator
--      PLB_masterID           -- PLB current master indicator
--      PLB_abort              -- PLB abort bus request indicator
--      PLB_busLock            -- PLB bus lock
--      PLB_RNW                -- PLB read not write
--      PLB_BE                 -- PLB byte enables
--      PLB_MSize              -- PLB master data bus size
--      PLB_size               -- PLB transfer size
--      PLB_type               -- PLB transfer type
--      PLB_compress           -- PLB compressed data transfer indicator
--      PLB_guarded            -- PLB guarded transfer indicator
--      PLB_ordered            -- PLB synchronize transfer indicator
--      PLB_lockErr            -- PLB lock error indicator
--      PLB_wrDBus             -- PLB write data bus
--      PLB_wrBurst            -- PLB burst write transfer indicator
--      PLB_rdBurst            -- PLB burst read transfer indicator
--      PLB_pendReq            -- PLB pending request
--      PLB_pendPri            -- PLB pending request priority
--      PLB_reqPri             -- PLB request priority
--      Sl_addrAck             -- Slave address acknowledge
--      Sl_SSize               -- Slave data bus sizer
--      Sl_wait                -- Slave wait indicator
--      Sl_rearbitrate         -- Slave rearbitrate bus indicator
--      Sl_wrDAck              -- Slave write data acknowledge
--      Sl_wrComp              -- Slave write transfer complete indicator
--      Sl_wrBTerm             -- Slave terminate write burst transfer
--      Sl_rdDBus              -- Slave read bus
--      Sl_rdWdAddr            -- Slave read word address
--      Sl_rdDAck              -- Slave read data acknowledge
--      Sl_rdComp              -- Slave read transfer complete indicator
--      Sl_rdBTerm             -- Slave terminate read burst transfer
--      Sl_MBusy               -- Slave busy indicator
--      Sl_MErr                -- Slave error indicator
--
--  -- DDR interface
--      DDR_Clk                -- DDR clock
--      DDR_Clkn               -- DDR clock negated
--      DDR_CKE                -- DDR clock enable
--      DDR_CSn                -- DDR chip select
--      DDR_RASn               -- DDR row address strobe
--      DDR_CASn               -- DDR column address strobe
--      DDR_WEn                -- DDR write enable
--      DDR_DM                 -- DDR data mask
--      DDR_BankAddr           -- DDR bank address
--      DDR_Addr               -- DDR address
--      DDR_DQ_o               -- DDR DQ output
--      DDR_DQ_i               -- DDR DQ input
--      DDR_DQ_t               -- DDR DQ output enable
--      DDR_DQS_i              -- DDR DQS input
--      DDR_DQS_o              -- DDR DQS output
--      DDR_DQS_t              -- DDR DQS output enable
--
--    -- Timer or interrrupt signals
--      DDR_Init_done          -- DDR power-up/reset initialization is
--                             -- complete
--
--  -- Clocks and reset
--      PLB_Clk                -- PLB clock 
--      Clk90_in               -- PLB clock shifted 90
--      DDR_Clk90_in           -- DDR clock feedback shifted 90
--      PLB_Rst                -- PLB Reset                                                          
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity modified_plb_ddr_controller is
    generic (
        -- ddr generics
        C_DQS_PULLUPS                   : integer  := 0;
        C_INCLUDE_BURST_CACHELN_SUPPORT : integer  := 0;
        C_REG_DIMM                      : integer  := 0;
        C_DDR_TMRD                      : integer  := 15000;
        C_DDR_TWR                       : integer  := 15000;
        C_DDR_TWTR                      : integer  := 1;
        C_DDR_TRAS                      : integer  := 40000;
        C_DDR_TRC                       : integer  := 65000;
        C_DDR_TRFC                      : integer  := 75000;
        C_DDR_TRCD                      : integer  := 20000;
        C_DDR_TRRD                      : integer  := 15000;
        C_DDR_TREFC                     : integer  := 70000000;
        C_DDR_TREFI                     : integer  := 7800000;
        C_DDR_TRP                       : integer  := 20000;
        C_DDR_CAS_LAT                   : integer  := 2;
        C_DDR_DWIDTH                    : integer  := 32;
        C_DDR_AWIDTH                    : integer  := 13;
        C_DDR_COL_AWIDTH                : integer  := 9;
        C_DDR_BANK_AWIDTH               : integer  := 2;

        C_PLB_CLK_PERIOD_PS             : integer  := 10000  ;
        C_FAMILY                        : string   := "virtex2";

        -- ipif generics
        C_BASEADDR                      : std_logic_vector := x"FFFFFFFF";
        C_HIGHADDR                      : std_logic_vector := x"00000000";
        C_PLB_NUM_MASTERS               : integer := 2;
        C_PLB_MID_WIDTH                 : integer := 1;
        C_PLB_AWIDTH                    : integer := 32;
        C_PLB_DWIDTH                    : integer := 64;
        
        -- simulation only generic (set to 200us)
        C_SIM_INIT_TIME_PS              : integer  := 200000000
     );  
  port (
        -- PLB Slave signals
        PLB_ABus            : in  std_logic_vector(0 to C_PLB_AWIDTH-1);                            
        PLB_PAValid         : in  std_logic;                            
        PLB_SAValid         : in  std_logic;                            
        PLB_rdPrim          : in  std_logic;                            
        PLB_wrPrim          : in  std_logic;                            
        PLB_masterID        : in  std_logic_vector(0 to C_PLB_MID_WIDTH-1);                            
        PLB_abort           : in  std_logic;                            
        PLB_busLock         : in  std_logic;                            
        PLB_RNW             : in  std_logic;                            
        PLB_BE              : in  std_logic_vector(0 to (C_PLB_DWIDTH/8)-1);                            
        PLB_MSize           : in  std_logic_vector(0 to 1);                            
        PLB_size            : in  std_logic_vector(0 to 3);                            
        PLB_type            : in  std_logic_vector(0 to 2);                            
        PLB_compress        : in  std_logic;                            
        PLB_guarded         : in  std_logic;                            
        PLB_ordered         : in  std_logic;                            
        PLB_lockErr         : in  std_logic;                            
        PLB_wrDBus          : in  std_logic_vector(0 to C_PLB_DWIDTH-1);                            
        PLB_wrBurst         : in  std_logic;                            
        PLB_rdBurst         : in  std_logic;                            
        PLB_pendReq         : in  std_logic;
        PLB_pendPri         : in  std_logic_vector(0 to 1);        
        PLB_reqPri          : in  std_logic_vector(0 to 1);                            
        Sl_addrAck          : out std_logic;                            
        Sl_SSize            : out std_logic_vector(0 to 1);                            
        Sl_wait             : out std_logic;                            
        Sl_rearbitrate      : out std_logic;                            
        Sl_wrDAck           : out std_logic;                            
        Sl_wrComp           : out std_logic;                            
        Sl_wrBTerm          : out std_logic;                            
        Sl_rdDBus           : out std_logic_vector(0 to C_PLB_DWIDTH-1);                            
        Sl_rdWdAddr         : out std_logic_vector(0 to 3);                            
        Sl_rdDAck           : out std_logic;                            
        Sl_rdComp           : out std_logic;                            
        Sl_rdBTerm          : out std_logic;                            
        Sl_MBusy            : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);                            
        Sl_MErr             : out std_logic_vector(0 to C_PLB_NUM_MASTERS-1);

        -- DDR interface signals
        DDR_Clk             : out std_logic;
        DDR_Clkn            : out std_logic;
        DDR_CKE             : out std_logic;
        DDR_CSn             : out std_logic;
        DDR_RASn            : out std_logic;
        DDR_CASn            : out std_logic;
        DDR_WEn             : out std_logic;
        DDR_DM              : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_BankAddr        : out std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        DDR_Addr            : out std_logic_vector(0 to C_DDR_AWIDTH-1);
        DDR_DQ_o            : out std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQ_i            : in  std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQ_t            : out std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQS_i           : in  std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_DQS_o           : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_DQS_t           : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);

        -- Timer/Interrupt signals
        DDR_Init_done       : out std_logic;

        -- Clocks and reset
        PLB_Clk             : in  std_logic;
        Clk90_in            : in  std_logic;
        DDR_Clk90_in        : in  std_logic;
        PLB_Rst             : in  std_logic
 );

    -- fan-out attributes for Synplicity
    attribute SYN_MAXFAN                  : integer;
    attribute SYN_MAXFAN   of PLB_Clk     : signal is 10000;
    attribute SYN_MAXFAN   of PLB_Rst     : signal is 10000;

    --fan-out attributes for XST
    attribute MAX_FANOUT                  : string;
    attribute MAX_FANOUT   of PLB_Clk     : signal is "10000";
    attribute MAX_FANOUT   of PLB_Rst     : signal is "10000";

    -- PSFUtil MPD attributes
    attribute IP_GROUP                                : string;
    attribute IP_GROUP of modified_plb_ddr_controller : entity is "LOGICORE";

    attribute ALERT                                   : string;
    attribute ALERT    of modified_plb_ddr_controller : entity is 
    "An example UCF for this core is available and must be modified for use in the system. Please refer to the EDK Getting Started guide for the location of this file.";
    
    attribute RESERVED			  : string;
    attribute RESERVED of C_SIM_INIT_TIME_PS : constant is "TRUE";
    
    attribute MIN_SIZE                    : string;
    attribute MIN_SIZE of C_BASEADDR      : constant is "0x08";

    attribute SIGIS                       : string;
    attribute SIGIS of PLB_Clk            : signal is "Clk";
    attribute SIGIS of PLB_Rst            : signal is "Rst";

end entity modified_plb_ddr_controller;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of modified_plb_ddr_controller is

-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
-- set the bus to be used - 
constant OPB_BUS        : integer := 0;
constant PLB_BUS        : integer := 1;

-- set the DDR burst size
constant DDR_BRST_SIZE  : integer := C_PLB_DWIDTH/C_DDR_DWIDTH;

-- dummy value for PLB IPIF workaround
constant DUMMY          : integer := 200;

-- addresses are now expected to be 64-bits wide - create constants to 
-- zero the most significant address bits
constant ZERO_ADDR_PAD  : std_logic_vector(0 to 64-C_PLB_AWIDTH-1) := (others => '0');

-- constants for PLB IPIF
constant ARD_ID_ARRAY           : INTEGER_ARRAY_TYPE := 
         (
            0 => USER_00
          );
constant ARD_ADDR_RANGE_ARRAY   : SLV64_ARRAY_TYPE :=
         ( 
            ZERO_ADDR_PAD&C_BASEADDR,   -- PLB DDR base address
            ZERO_ADDR_PAD&C_HIGHADDR    -- PLB DDR high address
          );
constant ARD_DWIDTH_ARRAY       : INTEGER_ARRAY_TYPE :=
         ( 
            0 => C_PLB_DWIDTH
          );
constant ARD_NUM_CE_ARRAY       : INTEGER_ARRAY_TYPE := 
         (
            0 => 1
          );

-- don't include MIR
constant DEV_MIR_ENABLE         : boolean   := false;
constant DEV_BLK_ID             : integer   := 1;

-- set IPIF timeout counter to 64
constant DEV_DPHASE_TIMEOUT     : integer   := 64;

-- set IPIF burst page size 
constant DEV_BURST_ENABLE       : boolean := true;
constant DEV_FAST_DATA_XFER     : boolean := C_INCLUDE_BURST_CACHELN_SUPPORT /= 0; 
constant ADDR_OFFSET            : integer := log2(C_DDR_DWIDTH/8);
constant DEV_BURST_PAGE_SIZE    : integer := 
                    2**(C_DDR_AWIDTH+C_DDR_BANK_AWIDTH+C_DDR_COL_AWIDTH+ADDR_OFFSET); 
constant DEV_MAX_BURST_SIZE     : integer := DEV_BURST_PAGE_SIZE;

-- no interrupts
constant INCLUDE_DEV_ISC        : boolean           := false;
constant INCLUDE_DEV_PENCODER   : boolean           := false;
constant IP_INTR_MODE_ARRAY     : INTEGER_ARRAY_TYPE := 
         (
            0 => 0
          );
          
constant IP_NUM_INTR    :  integer := IP_INTR_MODE_ARRAY'length;
constant ZERO_INTREVENT : std_logic_vector(0 to IP_NUM_INTR-1) := (others => '0');

-- no FIFOs, just use default generics

-- no master, slave only
constant IP_MASTER_PRESENT      : boolean           := false;

-- zero constants for unused IPIF inputs
constant ZERO_ADDR      : std_logic_vector(0 to C_PLB_AWIDTH-1)   := (others => '0');
constant ZERO_DATA      : std_logic_vector(0 to C_PLB_DWIDTH-1)   := (others => '0');
constant ZERO_BE        : std_logic_vector(0 to C_PLB_DWIDTH/8-1) := (others => '0');

-- zero read fifo data input
constant RDFIFO_DWIDTH  : integer := C_PLB_DWIDTH;
constant ZERO_RFIFO_DATA: std_logic_vector(0 to RDFIFO_DWIDTH-1) := (others => '0');                                                      
-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
-- IPIC Signals
signal bus2ip_cs            : std_logic_vector(0 to ARD_ADDR_RANGE_ARRAY'LENGTH/2 -1);
signal bus2ip_addr          : std_logic_vector(0 to C_PLB_AWIDTH-1);
signal bus2ip_rnw           : std_logic;
signal bus2ip_data          : std_logic_vector(0 to C_PLB_DWIDTH-1);
signal bus2ip_be            : std_logic_vector(0 to C_PLB_DWIDTH/8-1);
signal bus2ip_burst         : std_logic;
signal bus2ip_iburst        : std_logic;
signal bus2ip_rdreq         : std_logic;
signal bus2ip_wrreq         : std_logic;

signal ip2bus_retry         : std_logic;
signal ip2bus_busy          : std_logic;
signal ip2bus_toutsup       : std_logic;
signal ip2bus_errack        : std_logic;
signal ip2bus_data          : std_logic_vector(0 to C_PLB_DWIDTH-1);
signal ip2bus_rdack         : std_logic;
signal ip2bus_wrack         : std_logic;
signal ip2bus_addrack       : std_logic;

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
component ddr_controller 
    generic (
        C_FAMILY                : string   := "virtex2";
        C_REG_DIMM              : integer  := 0;
        C_DDR_TMRD              : integer  := 15000;
        C_DDR_TWR               : integer  := 15000;
        C_DDR_TWTR              : integer  := 1;
        C_DDR_TRAS              : integer  := 40000;
        C_DDR_TRC               : integer  := 65000;
        C_DDR_TRFC              : integer  := 75000;
        C_DDR_TRCD              : integer  := 20000;
        C_DDR_TRRD              : integer  := 15000;
        C_DDR_TREFC             : integer  := 70000000;
        C_DDR_TREFI             : integer  := 7800000;
        C_DDR_TRP               : integer  := 20000;
        C_DDR_CAS_LAT           : integer  := 2;
        C_DDR_DWIDTH            : integer  := 32;
        C_DDR_AWIDTH            : integer  := 13;
        C_DDR_COL_AWIDTH        : integer  := 9;
        C_DDR_BANK_AWIDTH       : integer  := 2;
        C_DDR_BRST_SIZE         : integer  := 8;
        C_IPIF_DWIDTH           : integer  := 64;
        C_IPIF_AWIDTH           : integer  := 32;
        C_INCLUDE_BURSTS        : integer  := 1;
        C_CLK_PERIOD            : integer  := 10000;
        C_OPB_BUS               : integer  := 0;
        C_PLB_BUS               : integer  := 1;
--        C_DTIME_READ_LATENCY    : integer;
        C_PULLUPS               : integer  := 1;
        -- simulation only generic (set to 200us)
        C_SIM_INIT_TIME_PS              : integer  := 200000000
     );  
  port (
        -- IPIC inputs
        Bus2IP_Addr         : in  std_logic_vector(0 to C_IPIF_AWIDTH-1);
        Bus2IP_BE           : in  std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
        Bus2IP_Data         : in  std_logic_vector(0 to C_IPIF_DWIDTH-1);
        Bus2IP_RNW          : in  std_logic;
        Bus2IP_RdReq        : in  std_logic;
        Bus2IP_WrReq        : in  std_logic;
        Bus2IP_Burst        : in  std_logic;
        Bus2IP_IBurst       : in  std_logic;
        Bus2IP_CS           : in  std_logic;

        -- IPIC outputs
        IP2Bus_Data         : out std_logic_vector(0 to C_IPIF_DWIDTH-1);
        IP2Bus_AddrAck      : out std_logic;
        IP2Bus_Busy         : out std_logic;
        IP2Bus_RdAck        : out std_logic;
        IP2Bus_WrAck        : out std_logic;
        IP2Bus_ErrAck       : out std_logic;
        IP2Bus_Retry        : out std_logic;
        IP2Bus_ToutSup      : out std_logic;

        -- DDR interface signals
        DDR_Clk             : out std_logic;
        DDR_Clkn            : out std_logic;
        DDR_CKE             : out std_logic;
        DDR_CSn             : out std_logic;
        DDR_RASn            : out std_logic;
        DDR_CASn            : out std_logic;
        DDR_WEn             : out std_logic;
        DDR_DM              : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_BankAddr        : out std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        DDR_Addr            : out std_logic_vector(0 to C_DDR_AWIDTH-1);
        DDR_DQ_o            : out std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQ_i            : in  std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQ_t            : out std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQS_i           : in  std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_DQS_o           : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_DQS_t           : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        
        -- Timer/Interrupt signals
        DDR_Init_done       : out std_logic;

        -- Clocks and reset
        Sys_Clk             : in  std_logic;
        Clk90_in            : in  std_logic;
        DDR_Clk90_in        : in  std_logic;
        Rst                 : in  std_logic
    );
end component ddr_controller;

component plb_ipif 
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
        PLB_ABus                : in  std_logic_vector(0 to C_PLB_AWIDTH-1);                                           
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
        Sl_rdDBus               : out std_logic_vector(0 to C_PLB_DWIDTH-1);                                                                                       
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
        IP2Bus_PostedWrInh      : in  std_logic;        
        IP2Bus_Busy             : in  std_logic;  -- new  PCI v1.00.e        
        IP2Bus_AddrAck          : in  std_logic;  -- new  PCI v1.00.e        
        IP2Bus_BTerm            : in  std_logic;  -- new  PCI v1.00.e        
        Bus2IP_Addr             : out std_logic_vector(0 to C_IPIF_AWIDTH - 1 );                                
        Bus2IP_Data             : out std_logic_vector(0 to C_IPIF_DWIDTH - 1 );                                
        Bus2IP_RNW              : out std_logic;         
        Bus2IP_BE               : out std_logic_vector(0 to (C_IPIF_DWIDTH/8) - 1 );        
        Bus2IP_Burst            : out std_logic;        
        Bus2IP_IBurst           : out std_logic; -- new  PCI v1.00.e        
        Bus2IP_WrReq            : out std_logic;        
        Bus2IP_RdReq            : out std_logic;        
        Bus2IP_RNW_Early        : out std_logic; -- new  PCI v1.00.e        
        Bus2IP_PselHit          : out std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1); -- new  PCI v1.00.e        
        Bus2IP_CS               : out std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
		Bus2IP_Des_sig          : out std_logic;--JTK Dual DDR Hack--
        Bus2IP_CE               : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);          
        Bus2IP_RdCE             : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);          
        Bus2IP_WrCE             : out std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);         
        
        -- IP to DMA Support Signals (Length and Status FIFO I/O)
        IP2DMA_RxLength_Empty   : in  std_logic;        
        IP2DMA_RxStatus_Empty   : in  std_logic;        
        IP2DMA_TxLength_Full    : in  std_logic;        
        IP2DMA_TxStatus_Empty   : in  std_logic;        
                        
        -- IP Master Signals
        IP2Bus_Addr             : in  std_logic_vector(0 to C_IPIF_AWIDTH - 1 );        
        IP2Bus_MstBE            : in  std_logic_vector(0 to (C_IPIF_DWIDTH/8) - 1 );        
        IP2IP_Addr              : in  std_logic_vector(0 to C_IPIF_AWIDTH - 1 );        
        IP2Bus_MstWrReq         : in  std_logic;        
        IP2Bus_MstRdReq         : in  std_logic;        
        IP2Bus_MstBurst         : in  std_logic;        
        IP2Bus_MstBusLock       : in  std_logic;        
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
 end component plb_ipif;

-----------------------------------------------------------------------------
-- Attribute declarations
----------------------------------------------------------------------------- 

-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  -- architecture imp

-----------------------------------------------------------------------------
-- Assign output signals
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Instantiate the DDR Controller
-----------------------------------------------------------------------------
DDR_CTRL_I: ddr_controller 
    generic map (
        C_FAMILY                =>  C_FAMILY            ,
        C_REG_DIMM              =>  C_REG_DIMM          ,
        C_DDR_TMRD              =>  C_DDR_TMRD          ,
        C_DDR_TWR               =>  C_DDR_TWR           ,
        C_DDR_TWTR              =>  C_DDR_TWTR          ,
        C_DDR_TRAS              =>  C_DDR_TRAS          ,
        C_DDR_TRC               =>  C_DDR_TRC           ,
        C_DDR_TRFC              =>  C_DDR_TRFC          ,
        C_DDR_TRCD              =>  C_DDR_TRCD          ,
        C_DDR_TRRD              =>  C_DDR_TRRD          ,
        C_DDR_TREFC             =>  C_DDR_TREFC         ,
        C_DDR_TREFI             =>  C_DDR_TREFI         ,
        C_DDR_TRP               =>  C_DDR_TRP           ,
        C_DDR_CAS_LAT           =>  C_DDR_CAS_LAT       ,
        C_DDR_DWIDTH            =>  C_DDR_DWIDTH        ,
        C_DDR_AWIDTH            =>  C_DDR_AWIDTH        ,
        C_DDR_COL_AWIDTH        =>  C_DDR_COL_AWIDTH    ,
        C_DDR_BANK_AWIDTH       =>  C_DDR_BANK_AWIDTH   ,
        C_DDR_BRST_SIZE         =>  DDR_BRST_SIZE       ,
        C_IPIF_DWIDTH           =>  C_PLB_DWIDTH        ,
        C_IPIF_AWIDTH           =>  C_PLB_AWIDTH        ,
        C_INCLUDE_BURSTS        =>  C_INCLUDE_BURST_CACHELN_SUPPORT,
        C_CLK_PERIOD            =>  C_PLB_CLK_PERIOD_PS ,
        C_OPB_BUS               =>  OPB_BUS             ,
        C_PLB_BUS               =>  PLB_BUS             ,
--        C_DTIME_READ_LATENCY    =>  DTIME_READ_LATENCY  ,
        C_PULLUPS               =>  C_DQS_PULLUPS       ,
        C_SIM_INIT_TIME_PS      =>  C_SIM_INIT_TIME_PS        
     )  
  port map (
        Bus2IP_Addr         =>  bus2ip_addr   ,                                            
        Bus2IP_BE           =>  bus2ip_be     ,                                            
        Bus2IP_Data         =>  bus2ip_data   ,                                            
        Bus2IP_RNW          =>  bus2ip_rnw    ,                                            
        Bus2IP_RdReq        =>  bus2ip_rdreq  ,                                            
        Bus2IP_WrReq        =>  bus2ip_wrreq  ,                                            
        Bus2IP_Burst        =>  bus2ip_burst  ,  
        Bus2IP_IBurst       =>  bus2ip_iburst ,  
        Bus2IP_CS           =>  bus2ip_cs(0)  ,                                            
        IP2Bus_Data         =>  ip2bus_data   , 
        IP2Bus_AddrAck      =>  ip2bus_addrack,
        IP2Bus_Busy         =>  ip2bus_busy   ,
        IP2Bus_RdAck        =>  ip2bus_rdack  ,                                            
        IP2Bus_WrAck        =>  ip2bus_wrack  ,                                            
        IP2Bus_ErrAck       =>  ip2bus_errack ,                                            
        IP2Bus_Retry        =>  ip2bus_retry  ,                                            
        IP2Bus_ToutSup      =>  ip2bus_toutsup,                                            
        DDR_Clk             =>  DDR_Clk        ,                                            
        DDR_Clkn            =>  DDR_Clkn       ,                                            
        DDR_CKE             =>  DDR_CKE        ,                                            
        DDR_CSn             =>  DDR_CSn        ,                                            
        DDR_RASn            =>  DDR_RASn       ,                                            
        DDR_CASn            =>  DDR_CASn       ,                                            
        DDR_WEn             =>  DDR_WEn        ,                                            
        DDR_DM              =>  DDR_DM         ,                                            
        DDR_BankAddr        =>  DDR_BankAddr   ,                                            
        DDR_Addr            =>  DDR_Addr       ,                                            
        DDR_DQ_o            =>  DDR_DQ_o       ,                                            
        DDR_DQ_i            =>  DDR_DQ_i       ,                                            
        DDR_DQ_t            =>  DDR_DQ_t       ,                                            
        DDR_DQS_i           =>  DDR_DQS_i      ,                                            
        DDR_DQS_o           =>  DDR_DQS_o      ,                                            
        DDR_DQS_t           =>  DDR_DQS_t      ,  
        
        DDR_Init_done       =>  DDR_Init_done  ,
        Sys_Clk             =>  PLB_Clk        ,                                            
        Clk90_in            =>  Clk90_in       ,
        DDR_Clk90_in        =>  DDR_Clk90_in   ,                                            
        Rst                 =>  PLB_Rst                                                        
    );

-- instantiate the PLB-IPIF
PLB_IPIF_I: plb_ipif 
  generic map (
        C_ARD_ID_ARRAY          => ARD_ID_ARRAY,
        C_ARD_ADDR_RANGE_ARRAY  => ARD_ADDR_RANGE_ARRAY,
        C_ARD_DWIDTH_ARRAY      => ARD_DWIDTH_ARRAY,                
        C_ARD_NUM_CE_ARRAY      => ARD_NUM_CE_ARRAY,
        C_DEV_BLK_ID            => DEV_BLK_ID,  
        C_DEV_MIR_ENABLE        => DEV_MIR_ENABLE,                      
        C_DEV_BURST_ENABLE      => DEV_BURST_ENABLE,
        C_DEV_FAST_DATA_XFER    => DEV_FAST_DATA_XFER,
        C_DEV_BURST_PAGE_SIZE   => DEV_BURST_PAGE_SIZE,
        C_DEV_MAX_BURST_SIZE    => DEV_MAX_BURST_SIZE,
        C_DEV_DPHASE_TIMEOUT    => DEV_DPHASE_TIMEOUT,
        C_INCLUDE_DEV_ISC       => INCLUDE_DEV_ISC,
        C_INCLUDE_DEV_PENCODER  => INCLUDE_DEV_PENCODER,
        C_IP_INTR_MODE_ARRAY    => IP_INTR_MODE_ARRAY,
        C_IP_MASTER_PRESENT     => IP_MASTER_PRESENT,
        C_PLB_MID_WIDTH         => C_PLB_MID_WIDTH,
        C_PLB_NUM_MASTERS       => C_PLB_NUM_MASTERS,
        C_PLB_AWIDTH            => C_PLB_AWIDTH,  
        C_PLB_DWIDTH            => C_PLB_DWIDTH,  
        C_PLB_CLK_PERIOD_PS     => C_PLB_CLK_PERIOD_PS,  
        C_IPIF_DWIDTH           => C_PLB_DWIDTH,
        C_IPIF_AWIDTH           => C_PLB_AWIDTH,
        C_FAMILY                => C_FAMILY
        )
  port map (  
    -- System signals ---------------------------------------------------------    
        PLB_clk                 => PLB_Clk,                                 
        Reset                   => PLB_Rst,                                
        Freeze                  => '0',                                
        IP2INTC_Irpt            => open,                
    -- Bus Slave signals ------------------------------------------------------       
        PLB_ABus                => PLB_ABus      ,                          
        PLB_PAValid             => PLB_PAValid   ,
        PLB_SAValid             => PLB_SAValid   ,
        PLB_rdPrim              => PLB_rdPrim    ,
        PLB_wrPrim              => PLB_wrPrim    ,
        PLB_masterID            => PLB_masterID  ,                             
        PLB_abort               => PLB_abort     ,
        PLB_busLock             => PLB_busLock   ,
        PLB_RNW                 => PLB_RNW       ,
        PLB_BE                  => PLB_BE        ,                             
        PLB_MSize               => PLB_MSize     ,             
        PLB_size                => PLB_size      ,             
        PLB_type                => PLB_type      ,             
        PLB_compress            => PLB_compress  ,
        PLB_guarded             => PLB_guarded   ,
        PLB_ordered             => PLB_ordered   ,
        PLB_lockErr             => PLB_lockErr   ,
        PLB_wrDBus              => PLB_wrDBus    ,                          
        PLB_wrBurst             => PLB_wrBurst   ,
        PLB_rdBurst             => PLB_rdBurst   ,
        PLB_pendReq             => PLB_pendReq   ,
        PLB_pendPri             => PLB_pendPri   ,
        PLB_reqPri              => PLB_reqPri    ,             
        Sl_addrAck              => Sl_addrAck    ,
        Sl_SSize                => Sl_SSize      ,             
        Sl_wait                 => Sl_wait       ,
        Sl_rearbitrate          => Sl_rearbitrate,
        Sl_wrDAck               => Sl_wrDAck     ,
        Sl_wrComp               => Sl_wrComp     ,
        Sl_wrBTerm              => Sl_wrBTerm    ,
        Sl_rdDBus               => Sl_rdDBus     ,                          
        Sl_rdWdAddr             => Sl_rdWdAddr   ,             
        Sl_rdDAck               => Sl_rdDAck     ,
        Sl_rdComp               => Sl_rdComp     ,
        Sl_rdBTerm              => Sl_rdBTerm    ,
        Sl_MBusy                => Sl_MBusy      ,                               
        Sl_MErr                 => Sl_MErr       ,               
    -- Bus Master Signals -----------------------------------------------------        
        PLB_MAddrAck            => '0',                                
        PLB_MSSize              => "00",                                
        PLB_MRearbitrate        => '0',                                         
        PLB_MBusy               => '0',                                         
        PLB_MErr                => '0',                                         
        PLB_MWrDAck             => '0',                                         
        PLB_MRdDBus             => ZERO_DATA,                                
        PLB_MRdWdAddr           => "0000",
        PLB_MRdDAck             => '0',                                         
        PLB_MRdBTerm            => '0',         
        PLB_MWrBTerm            => '0',         
        M_request               => open,                                
        M_priority              => open,                                
        M_buslock               => open,                                        
        M_RNW                   => open,                                        
        M_BE                    => open,                                                                       
        M_MSize                 => open,                                                       
        M_size                  => open,                                                       
        M_type                  => open,                                                       
        M_compress              => open,                                        
        M_guarded               => open,                                        
        M_ordered               => open,                                        
        M_lockErr               => open,                                        
        M_abort                 => open,                                                                      
        M_ABus                  => open,                                                                    
        M_wrDBus                => open,                                                                    
        M_wrBurst               => open,                                           
        M_rdBurst               => open,                         
    -- IP Interconnect (IPIC) port signals -----------------------------------------        
        --System Signals
        IP2Bus_Clk              => '0',        
        Bus2IP_Clk              => open,        
        Bus2IP_Reset            => open,        
        Bus2IP_Freeze           => open,       
        -- IP Slave signals
        IP2Bus_IntrEvent        => ZERO_INTREVENT,        
        IP2Bus_Data             => ip2bus_data,                                
        IP2Bus_WrAck            => ip2bus_wrack,                                
        IP2Bus_RdAck            => ip2bus_rdack,        
        IP2Bus_Retry            => ip2bus_retry,
        IP2Bus_Error            => ip2bus_errack,
        IP2Bus_ToutSup          => ip2bus_toutsup,        
        IP2Bus_PostedWrInh      => '0',
        IP2Bus_Busy             => ip2bus_busy,
        IP2Bus_AddrAck          => ip2bus_addrack,
        IP2Bus_BTerm            => '0',
        Bus2IP_Addr             => bus2ip_addr,                               
        Bus2IP_Data             => bus2ip_data,                                
        Bus2IP_RNW              => bus2ip_rnw,             
        Bus2IP_BE               => bus2ip_be,        
        Bus2IP_Burst            => bus2ip_burst, 
        Bus2IP_IBurst           => bus2ip_iburst,
        Bus2IP_WrReq            => bus2ip_wrreq,        
        Bus2IP_RdReq            => bus2ip_rdreq, 
        Bus2IP_RNW_Early        => open,
        Bus2IP_PselHit          => open,
        Bus2IP_CS               => bus2ip_cs,        
		Bus2IP_Des_sig          => open,-- JTK Dual DDR Hack--
        Bus2IP_CE               => open,                                                                 
        Bus2IP_RdCE             => open,                                                                 
        Bus2IP_WrCE             => open,                                                          
        -- IP to DMA Support Signals (Length and Status FIFO I/O)
        IP2DMA_RxLength_Empty   => '0',        
        IP2DMA_RxStatus_Empty   => '0',        
        IP2DMA_TxLength_Full    => '0',        
        IP2DMA_TxStatus_Empty   => '0',                                
        -- IP Master Signals
        IP2Bus_Addr             => ZERO_ADDR,        
        IP2Bus_MstBE            => ZERO_BE,        
        IP2IP_Addr              => ZERO_ADDR,        
        IP2Bus_MstWrReq         => '0',
        IP2Bus_MstRdReq         => '0',        
        IP2Bus_MstBurst         => '0',        
        IP2Bus_MstBusLock       => '0',        
        Bus2IP_MstWrAck         => open,        
        Bus2IP_MstRdAck         => open,        
        Bus2IP_MstRetry         => open,        
        Bus2IP_MstError         => open,        
        Bus2IP_MstTimeOut       => open,        
        Bus2IP_MstLastAck       => open,                
        -- RdPFIFO Signals
        IP2RFIFO_WrReq          => '0',        
        IP2RFIFO_Data           => ZERO_RFIFO_DATA,
        IP2RFIFO_WrMark         => '0',        
        IP2RFIFO_WrRelease      => '0',        
        IP2RFIFO_WrRestore      => '0',        
        RFIFO2IP_WrAck          => open,                
        RFIFO2IP_AlmostFull     => open,                
        RFIFO2IP_Full           => open,        
        RFIFO2IP_Vacancy        => open,
        -- WrPFIFO signals
        IP2WFIFO_RdReq          => '0',        
        IP2WFIFO_RdMark         => '0',
        IP2WFIFO_RdRelease      => '0',        
        IP2WFIFO_RdRestore      => '0',
        WFIFO2IP_Data           => open,                                
        WFIFO2IP_RdAck          => open,                
        WFIFO2IP_AlmostEmpty    => open,                
        WFIFO2IP_Empty          => open,                
        WFIFO2IP_Occupancy      => open,                
        -- IP DMA signals
        IP2Bus_DMA_Req          => '0',        
        Bus2IP_DMA_Ack          => open                
        ); 
end imp;

