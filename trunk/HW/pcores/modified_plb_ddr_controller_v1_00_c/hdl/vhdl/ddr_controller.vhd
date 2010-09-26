-------------------------------------------------------------------------------
-- $Id: ddr_controller.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- ddr_controller.vhd - entity/architecture pair
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
-- Filename:        ddr_controller.vhd
-- Version:         v1.00c
-- Description:     DDR controller with IPIC interface
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--                  ddr_controller.vhd
--                      -- read_data_path.vhd
--                      -- data_statemachine.vhd
--                      -- command_statemachine.vhd
--                      -- init_statemachine.vhd
--                      -- counters.vhd
--                      -- io_registers.vhd
--                      -- clock_gen.vhd
--                      -- ipic_if.vhd
--
-------------------------------------------------------------------------------
-- Author:          ALS
-- History:
--   ALS           05/02/02    First Version
-- ^^^^^^
--      First version of DDR controller
-- ~~~~~~
--   ALS            06/05/02
-- ^^^^^^
--      Replaced C_CLK_FREQ with C_CLK_PERIOD
-- ~~~~~~
--  ALS             06/07/02
-- ^^^^^^
--      Made modifications for FIFO implementation of read data path. Added
--      C_FAMILY generic.
-- ~~~~~~
--  ALS             07/12/02
-- ^^^^^^
--      Added C_REG_DIMM generic. When C_REG_DIMM=1, add a 1-clock pipeline
--      delay to write_data, write_data_mask, write_data_en, write_dqs_en.
--      Also, add 1 to the CAS_LATENCY to account for the register delay in
--      the DIMM. Changed generic C_INCLUDE_CLK90_GEN to C_INCLUDE_CLK90_DCM
--      and added generic C_INCLUDE_DDRCLK_DCM so that the inclusion of the
--      DDR clock DCM and the output registers to generate the DDR clock output
-- ~~~~~~
--  ALS             06/25/03
-- ^^^^^^
--      Version C:
--      Use latest IPIFs to remove latency and support indeterminate bursts
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
use modified_plb_ddr_controller_v1_00_c.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_FAMILY                    -- target FPGA family
--      C_REG_DIMM                  -- support registered ddr dimm
--      C_DDR_TMRD                  -- Load Mode Register command cycle time
--      C_DDR_TWR                   -- write recovery time
--      C_DDR_TRAS                  -- delay after ACTIVE command before
--                                  -- PRECHARGE command
--      C_DDR_TRC                   -- delay after ACTIVE command before
--                                  -- another ACTIVE or AUTOREFRESH command
--      C_DDR_TRFC                  -- delay after AUTOREFRESH before another command
--      C_DDR_TRCD                  -- delay after ACTIVE before READ/WRITE
--      C_DDR_TRRD                  -- delay after ACTIVE row a before ACTIVE 
--                                  -- row b
--      C_DDR_TRP                   -- delay after PRECHARGE command
--      C_DDR_TREFC                 -- refresh to refresh command interval
--      C_DDR_TREFI                 -- average periodic refresh command interval
--      C_DDR_CAS_LAT               -- Device CAS latency
--      C_DDR_DWIDTH                -- DDR data width of each device
--      C_DDR_AWIDTH                -- DDR row address width
--      C_DDR_COL_AWIDTH            -- DDR column address width
--      C_DDR_BANK_AWIDTH           -- DDR bank address width
--      C_DDR_BRST_SIZE             -- DDR burst size
--      C_IPIF_DWIDTH               -- IPIC data width
--      C_IPIF_AWIDTH               -- IPIC address width
--      C_INCLUDE_BURSTS            -- include support for bus burst transactions
--      C_CLK_PERIOD                -- processor bus clock period
--      C_OPB_BUS                   -- processor bus is OPB
--      C_PLB_BUS                   -- processor bus is PLB
--      C_PULLUPS                   -- pullups on dqs lines
--      C_SIM_INIT_TIME_PS          -- DDR initialization time to be used in simulation
--
-- Definition of Ports:
--  -- IPIC
--    Bus2IP_Addr               -- Processor bus address         
--    Bus2IP_BE                 -- Processor bus byte enables
--    Bus2IP_Data               -- Processor data
--    Bus2IP_RNW                -- Processor read not write
--    Bus2IP_RdReq              -- Processor read request
--    Bus2IP_WrReq              -- Processor write request
--    Bus2IP_Burst              -- Processor burst
--    Bus2IP_IBurst             -- Processor indeterminate burst
--    Bus2IP_CS                 -- DDR memory is being accessed
--
--    -- IPIC outputs
--    IP2Bus_Data               -- Data to processor bus
--    IP2Bus_AddrAck            -- Address phase acknowledge (inc address count)
--    IP2Bus_Busy               -- IP busy (issue re-arbitrate during address phase)
--    IP2Bus_RdAck              -- Read acknowledge
--    IP2Bus_WrAck              -- Write acknowledge
--    IP2Bus_Retry              -- Retry indicator
--    IP2Bus_ToutSup            -- Suppress watch dog timer
--    
--    -- DDR interface signals
--    DDR_Clk                   -- DDR clock
--    DDR_Clkn                  -- DDR clock negated
--    DDR_CKE                   -- DDR clock enable
--    DDR_CSn                   -- DDR chip select
--    DDR_RASn                  -- DDR row address strobe
--    DDR_CASn                  -- DDR column address strobe
--    DDR_WEn                   -- DDR write enable
--    DDR_DM                    -- DDR data mask
--    DDR_BankAddr              -- DDR bank address
--    DDR_Addr                  -- DDR address
--    DDR_DQ_o                  -- DDR DQ output
--    DDR_DQ_i                  -- DDR DQ input
--    DDR_DQ_t                  -- DDR DQ output enable
--    DDR_DQS_i                 -- DDR DQS input
--    DDR_DQS_o                 -- DDR DQS output
--    DDR_DQS_t                 -- DDR DQS output enable
--    
--    -- Clocks and reset
--    Sys_Clk                   -- Processor clock input                
--    Clk90_in                  -- Processor clock shifted 90 input
--    DDR_Clk90_in              -- DDR clock feedback shifted 90 input
--    Rst                       -- System reset
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity ddr_controller is
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
        C_PULLUPS               : integer  := 1;
        -- simulation only generic (set to 200us)
        C_SIM_INIT_TIME_PS      : integer  := 200000000
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
end entity ddr_controller;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of ddr_controller is
-----------------------------------------------------------------------------
-- Function declarations
-----------------------------------------------------------------------------
type INTEGER_ARRAY is array (natural range <>) of integer;
-- function max returns the max value of an array
function max(indata : INTEGER_ARRAY ) return integer is
  variable max_val : integer;
begin
  max_val := 0;
  for i in 0 to indata'length-1 loop
    if indata(i) > max_val then
        max_val := indata(i);
    end if;
 end loop;
  
 return max_val; 
end max;

--
-- Function get_init_clocks returns the number of clocks for the initialization
-- time. If simulation, the initialization time is set by C_SIM_INIT_TIME_PS.
-- Otherwise, it is 200us.
--
function get_init_clocks return integer is
    variable init_clocks : integer;
begin

    -- the following assignment is used in synthesis
    init_clocks := ((200000000-1)/C_CLK_PERIOD)+1;
    
    -- the following assignment is used in simulation
    -- synthesis translate off
    init_clocks := ((C_SIM_INIT_TIME_PS-1)/C_CLK_PERIOD)+1;
    -- synthesis translate on
    
    return init_clocks;
end get_init_clocks;

-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
-- create integer values of the delay parameters divided by clock frequency
-- to round values to next integer
constant DDR_TMRD_CLKS   : integer range 1 to 31 := ((C_DDR_TMRD-1)/C_CLK_PERIOD)+1;
constant DDR_TWR_CLKS    : integer range 1 to 31 := ((C_DDR_TWR-1)/C_CLK_PERIOD)+1;
constant DDR_TRAS_CLKS   : integer range 1 to 31 := ((C_DDR_TRAS-1)/C_CLK_PERIOD)+1;
constant DDR_TRC_CLKS    : integer range 1 to 31 := ((C_DDR_TRC-1)/C_CLK_PERIOD)+1;
constant DDR_TRFC_CLKS   : integer range 1 to 31 := ((C_DDR_TRFC-1)/C_CLK_PERIOD)+1;
constant DDR_TRCD_CLKS   : integer range 1 to 31 := ((C_DDR_TRCD-1)/C_CLK_PERIOD)+1;
constant DDR_TRRD_CLKS   : integer range 1 to 31 := ((C_DDR_TRRD-1)/C_CLK_PERIOD)+1;
constant DDR_TREFC_CLKS  : integer := ((C_DDR_TREFC-1)/C_CLK_PERIOD)+1;
constant DDR_TREFI_CLKS  : integer := ((C_DDR_TREFI-1)/C_CLK_PERIOD)+1;
constant DDR_TRP_CLKS    : integer range 1 to 31 := ((C_DDR_TRP-1)/C_CLK_PERIOD)+1;

-- set the number of clocks for the 200uS counter to the generic C_SIM_INIT_TIME_PS
-- for simulation by calling function get_init_clocks
constant CNT_200US_CLKS  : integer := get_init_clocks;

--                                    
-- set width of counters
--
constant RCCNT_WIDTH    : integer := max2(1,log2(DDR_TRC_CLKS));
constant RRDCNT_WIDTH   : integer := max2(1,log2(DDR_TRRD_CLKS));
constant RASCNT_WIDTH   : integer := max2(1,log2(DDR_TRAS_CLKS));

-- width of the REFI and initialization counter is the max of the number of clocks for
-- REFI and initialization (sim_init_time or 200us and 200 clks)
constant INITCNTR_WIDTH : integer := max2(log2(CNT_200US_CLKS+1),log2(200));
constant REFICNT_WIDTH  : integer := max2(log2(DDR_TREFI_CLKS),INITCNTR_WIDTH);

constant BRSTCNT_WIDTH  : integer := max2(1,log2(C_DDR_BRST_SIZE/2)); 
constant WRCNT_WIDTH    : integer := max2(1,log2(DDR_TWR_CLKS));

-- add one to CAS latency if C_REG_DIMM
constant CASLATCNT_WIDTH: integer := max2(1,log2(C_DDR_CAS_LAT+C_REG_DIMM));

-- general purpose counter is used to count Tmrd, Trfc, Trp and Trcd
-- set this counter width from the max of these values
constant CNTR_WIDTH     : INTEGER_ARRAY := ( max2(1,log2(DDR_TMRD_CLKS)), 
                                             max2(1,log2(DDR_TRFC_CLKS)),
                                             max2(1,log2(DDR_TRP_CLKS)),
                                             max2(1,log2(DDR_TRCD_CLKS)));
                                             
constant GPCNT_WIDTH    : integer := max(CNTR_WIDTH);

--
-- create std_logic_vectors for counter load values
--
constant RCCNT          : std_logic_vector(0 to RCCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TRC_CLKS-1, RCCNT_WIDTH);
constant RRDCNT         : std_logic_vector(0 to RRDCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TRRD_CLKS-1, RRDCNT_WIDTH);
constant RASCNT         : std_logic_vector(0 to RASCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TRAS_CLKS-1, RASCNT_WIDTH);
-- Set REFICNT to DDR_TREFI_CLKS - X where X is enough margin 
-- to do a refresh properly knowing that the state machine may be in another command
constant REF_MARGIN     : integer   := 64;
constant REFICNT        : std_logic_vector(0 to REFICNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TREFI_CLKS-REF_MARGIN-1, REFICNT_WIDTH);
constant WRCNT          : std_logic_vector(0 to WRCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TWR_CLKS-1, WRCNT_WIDTH);
constant BRSTCNT        : std_logic_vector(0 to BRSTCNT_WIDTH-1) :=
                        conv_std_logic_vector(C_DDR_BRST_SIZE/2-1, BRSTCNT_WIDTH);
-- determine brstcnt/2 to mark when new command can be applied 
constant CMDCNT        : std_logic_vector(0 to BRSTCNT_WIDTH-1) :=
                        conv_std_logic_vector(C_DDR_BRST_SIZE/2-1, BRSTCNT_WIDTH);

-- add one to CAS latency if C_REG_DIMM
constant CASLATCNT      : std_logic_vector(0 to CASLATCNT_WIDTH-1) :=
                        conv_std_logic_vector(C_DDR_CAS_LAT+C_REG_DIMM-1, CASLATCNT_WIDTH);
constant CNT_200US      : std_logic_vector(0 to REFICNT_WIDTH-1) :=
                        conv_std_logic_vector(CNT_200US_CLKS-1, REFICNT_WIDTH);
constant CNT_200CLK     : std_logic_vector(0 to REFICNT_WIDTH-1) :=
                        conv_std_logic_vector(200-1, REFICNT_WIDTH);

constant MRDCNT         : std_logic_vector(0 to GPCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TMRD_CLKS-1, GPCNT_WIDTH);
constant RFCCNT         : std_logic_vector(0 to GPCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TRFC_CLKS-1, GPCNT_WIDTH);
constant RPCNT          : std_logic_vector(0 to GPCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TRP_CLKS-1, GPCNT_WIDTH);
constant RCDCNT         : std_logic_vector(0 to GPCNT_WIDTH-1) :=
                        conv_std_logic_vector(DDR_TRCD_CLKS-1, GPCNT_WIDTH);
--constant RDLATCNT       : std_logic_vector(0 to RDLAT_WIDTH-1) :=
--                        conv_std_logic_vector(C_DTIME_READ_LATENCY-1, RDLAT_WIDTH);

-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
signal gpcnt_load           : std_logic;
signal gpcnt_en             : std_logic;
signal gpcnt_data           : std_logic_vector(0 to GPCNT_WIDTH-1);
signal trc_load             : std_logic;
signal trrd_load            : std_logic;
signal tras_load            : std_logic;
signal trefi_load           : std_logic;
signal tpwrup_load          : std_logic;
signal tbrst_load           : std_logic;
signal tbrst_cnt_en         : std_logic;
signal tcmd_load            : std_logic;
signal tcmd_cnt_en          : std_logic;
signal tcaslat_load         : std_logic;
signal tcaslat_cnt_en       : std_logic;
signal tcaslat_end          : std_logic;
signal gpcnt_end            : std_logic;
signal trc_end              : std_logic;
signal trrd_end             : std_logic;
signal tras_end             : std_logic;
signal trefi_pwrup_end      : std_logic;       
signal twr_load             : std_logic;
signal twr_rst              : std_logic;
signal twr_cnten            : std_logic;
signal twr_end              : std_logic;
signal ddr_brst_end         : std_logic;  
signal tcmd_end             : std_logic;

signal refresh              : std_logic;
signal precharge            : std_logic;
signal load_mr              : std_logic;
signal register_data        : std_logic_vector(0 to C_DDR_AWIDTH-1);
signal register_sel         : std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
signal cmd_done             : std_logic;  
signal init_done            : std_logic;

signal read_data_done       : std_logic;
signal read_data_done_rst   : std_logic;
signal ipic_be              : std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
signal ipic_wrdata          : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal write_data           : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal write_data_mask      : std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
signal write_data_en        : std_logic;
signal write_dqs_en         : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal dq_oe_cmb            : std_logic;
signal dqs_oe               : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal dqs_rst              : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal dqs_setrst           : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal read_data_en         : std_logic;
signal ddr_readdata         : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal ddr_read_data_en     : std_logic;
signal ddr_read_dqs         : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal read_data            : std_logic_vector(0 to C_IPIF_DWIDTH-1);

signal rdack                : std_logic;
signal rdack_rst            : std_logic;
signal read_pause           : std_logic;
signal wrack                : std_logic;
signal retry                : std_logic;
signal rd_addrack           : std_logic;
signal wr_addrack           : std_logic;
signal read_dqs_ce          : std_logic;
signal burst                : std_logic;

signal row_addr             : std_logic_vector(0 to C_DDR_AWIDTH-1);
signal col_addr             : std_logic_vector(0 to C_DDR_AWIDTH-1);
signal bank_addr            : std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
signal pend_rdreq           : std_logic;
signal pend_wrreq           : std_logic;
signal same_row             : std_logic;
signal same_bank            : std_logic;
signal reset_pendrdreq      : std_logic;
signal reset_pendwrreq      : std_logic;
signal toutsup              : std_logic;

signal pend_read            : std_logic;
signal pend_write           : std_logic;
signal rst_pend_rd          : std_logic;
signal rst_pend_wr          : std_logic;

signal rasn                 : std_logic;
signal casn                 : std_logic;
signal wen                  : std_logic;
signal addr                 : std_logic_vector(0 to C_DDR_AWIDTH-1);
signal bankaddr             : std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);

signal clk_i                : std_logic;
signal clk90_i              : std_logic;
signal clk_ddr_rddata_i     : std_logic;

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  -- architecture imp

-- assign constant signals
DDR_CSn <= '0';

-- assign output signals
DDR_Init_done <= init_done;

-- Instantiate the components
  COMMAND_STATEMACHINE_I : entity modified_plb_ddr_controller_v1_00_c.command_statemachine(imp)
    generic map
    (
      C_DDR_AWIDTH      => C_DDR_AWIDTH,        -- integer
      C_DDR_DWIDTH      => C_DDR_DWIDTH,        -- integer
      C_DDR_COL_AWIDTH  => C_DDR_COL_AWIDTH,    -- integer
      C_DDR_BANK_AWIDTH => C_DDR_BANK_AWIDTH,   -- integer
      C_REG_DIMM        => C_REG_DIMM,          -- integer
      C_MRDCNT          => MRDCNT,         
      C_RFCCNT          => RFCCNT,         
      C_RCDCNT          => RCDCNT,         
      C_RPCNT           => RPCNT,          
      C_GP_CNTR_WIDTH   => GPCNT_WIDTH,         -- integer
      C_OPB_BUS         => C_OPB_BUS,           -- integer
      C_PLB_BUS         => C_PLB_BUS            -- integer
    )
    port map
    (
      Bus2IP_CS       => Bus2IP_CS,         -- in
      Burst           => burst,             -- in
      Row_addr        => row_addr,          -- in  (0:C_DDR_AWIDTH-1)
      Col_addr        => col_addr,          -- in  (0:C_DDR_AWIDTH-1)
      Bank_addr       => bank_addr,         -- in  (0:C_DDR_BANK_AWIDTH-1)
      Bus2IP_RdReq    => Bus2IP_RdReq,      -- in
      Bus2IP_WrReq    => Bus2IP_WrReq,      -- in 
      Pend_rdreq      => pend_rdreq,        -- in
      Pend_wrreq      => pend_wrreq,        -- in
      Same_row        => same_row,          -- in
      Same_bank       => same_bank,         -- in
      Read_dqs_ce     => read_dqs_ce,       -- out
      Retry           => retry,             -- out
      Rd_AddrAck      => rd_addrack,        -- out
      Wr_AddrAck      => wr_addrack,        -- out
      Reset_pendrdreq => reset_pendrdreq,   -- out
      Reset_pendwrreq => reset_pendwrreq,   -- out
      ToutSup         => toutsup,           -- out
      Refresh         => refresh,           -- in
      Precharge       => precharge,         -- in
      Load_mr         => load_mr,           -- in
      Register_data   => register_data,     -- in  (0:C_DDR_AWIDTH-1)
      Register_sel    => register_sel,      -- in  (0:C_DDR_BANK_AWIDTH-1)
      Init_done       => init_done,         -- in
      Cmd_done        => cmd_done,          -- out
      Read_data_done  =>  read_data_done,   -- in 
      Read_data_done_rst  =>  read_data_done_rst, -- out    
      Pend_write      => pend_write,        -- out
      Rst_pend_wr     => rst_pend_wr,       -- in
      Pend_read       => pend_read,         -- out
      Rst_pend_rd     => rst_pend_rd,       -- in
      Read_pause      => read_pause,        -- out
      Trefi_end       => trefi_pwrup_end,   -- in
      Trc_end         => trc_end,           -- in
      Trrd_end        => trrd_end,          -- in
      Tras_end        => tras_end,          -- in
      Twr_end         => twr_end,           -- in
      GPcnt_end       => gpcnt_end,         -- in
      Tcmd_end        => tcmd_end,          -- in
      Twr_rst         => twr_rst,           -- out
      Tcmd_load       => tcmd_load,         -- out
      Tcmd_cnt_en     => tcmd_cnt_en,       -- out
      Trefi_load      => trefi_load,        -- out
      Trc_load        => trc_load,          -- out
      Trrd_load       => trrd_load,         -- out
      Tras_load       => tras_load,         -- out
      GPcnt_load      => gpcnt_load,        -- out
      GPcnt_en        => gpcnt_en,          -- out
      GPcnt_data      => gpcnt_data,        -- out (0:C_GP_CNTR_WIDTH-1)
      DDR_RASn        => rasn,              -- out
      DDR_CASn        => casn,              -- out
      DDR_WEn         => wen,               -- out
      DDR_Addr        => addr,              -- out (0:C_DDR_AWIDTH-1)
      DDR_BankAddr    => bankaddr,          -- out (0:C_DDR_BANK_AWIDTH-1)
      DQ_oe_cmb       => dq_oe_cmb,         -- out
      DQS_oe          => dqs_oe,            -- out
      DQS_rst         => dqs_rst,           -- out
      DQS_setrst      => dqs_setrst,        -- out
      Clk             => clk_i,             -- in
      Rst             => rst                -- in
    );


INITSM_I: entity modified_plb_ddr_controller_v1_00_c.init_statemachine(imp) 
  generic map ( C_DDR_AWIDTH        =>  C_DDR_AWIDTH     ,    
                C_DDR_BANK_AWIDTH   =>  C_DDR_BANK_AWIDTH,    
                C_DDR_BRST_SIZE     =>  C_DDR_BRST_SIZE  ,    
                C_DDR_CAS_LAT       =>  C_DDR_CAS_LAT)
  port map(
    Cmd_done            =>   cmd_done       ,                                           
    Trefi_pwrup_end     =>   trefi_pwrup_end,                                           
    Precharge           =>   precharge      ,                                           
    Load_mr             =>   load_mr        ,                                           
    Tpwrup_load         =>   tpwrup_load    ,                                           
    Refresh             =>   refresh        ,                                           
    Register_data       =>   register_data  ,                                           
    Register_sel        =>   register_sel   , 
    Init_done           =>   init_done      ,
    DDR_CKE             =>   DDR_CKE        ,
    Clk                 =>   clk_i          ,                                           
    Rst                 =>   Rst                                                        
    );

CNTRS_I: entity modified_plb_ddr_controller_v1_00_c.counters(imp) 
  generic map ( C_GPCNT_WIDTH    =>  GPCNT_WIDTH  ,
                C_RCCNT_WIDTH    =>  RCCNT_WIDTH ,
                C_RRDCNT_WIDTH   =>  RRDCNT_WIDTH ,
                C_RASCNT_WIDTH   =>  RASCNT_WIDTH ,
                C_REFICNT_WIDTH  =>  REFICNT_WIDTH,
                C_WRCNT_WIDTH    =>  WRCNT_WIDTH  ,
                C_BRSTCNT_WIDTH  =>  BRSTCNT_WIDTH,
                C_CASLATCNT_WIDTH=>  CASLATCNT_WIDTH,
                C_RCCNT          =>  RCCNT       ,
                C_RRDCNT         =>  RRDCNT       ,
                C_RASCNT         =>  RASCNT       ,
                C_REFICNT        =>  REFICNT      ,
                C_200US_CNT      =>  CNT_200US    ,
                C_200CK_CNT      =>  CNT_200CLK   ,
                C_WRCNT          =>  WRCNT        ,
                C_BRSTCNT        =>  BRSTCNT      ,
                C_CMDCNT         =>  CMDCNT       ,
                C_CASLATCNT      =>  CASLATCNT    ,
                C_DDR_BRST_SIZE  =>  C_DDR_BRST_SIZE ,
                C_CASLAT         =>  C_DDR_CAS_LAT+C_REG_DIMM                
            )
  port map (
        GPcnt_load              => gpcnt_load        ,                                           
        GPcnt_en                => gpcnt_en          ,                                           
        GPcnt_data              => gpcnt_data        ,                                           
        Trc_load                => trc_load         ,                                           
        Trrd_load               => trrd_load         ,                                           
        Tras_load               => tras_load         ,                                           
        Trefi_load              => trefi_load        ,                                           
        Tpwrup_load             => tpwrup_load       ,                                           
        Tbrst_load              => tbrst_load        ,                                           
        Tbrst_cnt_en            => tbrst_cnt_en      , 
        Init_done               => init_done         ,
        Tcmd_load               => tcmd_load         ,
        Tcmd_cnt_en             => tcmd_cnt_en       ,
        Tcaslat_load            => tcaslat_load      ,
        Tcaslat_cnt_en          => tcaslat_cnt_en    ,
        Twr_load                => twr_load          ,
        Twr_rst                 => twr_rst           ,
        Twr_cnten               => twr_cnten         ,
        GPcnt_end               => gpcnt_end         ,                                           
        Trc_end                 => trc_end           ,                                           
        Trrd_end                => trrd_end          ,                                           
        Tras_end                => tras_end          ,                                           
        Trefi_pwrup_end         => trefi_pwrup_end   ,                                           
        Twr_end                 => twr_end           ,                                           
        DDR_brst_end            => ddr_brst_end      ,
        Tcmd_end                => tcmd_end          ,
        Tcaslat_end             => tcaslat_end       ,
        Clk                     => clk_i             ,                                           
        Rst                     => Rst                                                           
    );

DATASM_I: entity modified_plb_ddr_controller_v1_00_c.data_statemachine(imp) 
  generic map ( C_DDR_DWIDTH    => C_DDR_DWIDTH,
                C_IPIF_DWIDTH   => C_IPIF_DWIDTH,
                C_REG_DIMM      => C_REG_DIMM)
  port map (
        -- inputs
        IPIC_wrdata         =>  ipic_wrdata   , 
        IPIC_be             =>  ipic_be       ,
        Bus2IP_Burst        =>  Bus2IP_Burst  ,
        Pend_write          =>  pend_write    ,                                            
        Pend_read           =>  pend_read     ,                                            
        DDR_brst_end        =>  ddr_brst_end  ,                                            
        Bus2IP_RNW          =>  Bus2IP_RNW    , 
        Tcaslat_end         =>  tcaslat_end   ,
        Twr_end             =>  twr_end       ,                                           
        Read_data_done_rst  =>  read_data_done_rst ,
        Read_pause          =>  read_pause    ,       
        RdAck               =>  rdack         ,            
        WrAck               =>  WrAck         ,                                            
        Read_data_en        =>  read_data_en  ,
        Write_data_en       =>  write_data_en ,
        Write_dqs_en        =>  write_dqs_en  ,
        Write_data          =>  write_data    ,
        Write_data_mask     =>  write_data_mask,
        Read_data_done      =>  read_data_done, 
        Tbrst_cnt_en        =>  tbrst_cnt_en  ,
        Tbrst_load          =>  tbrst_load    ,
        Tcaslat_load        =>  tcaslat_load  ,
        Tcaslat_cnt_en      =>  tcaslat_cnt_en,
        Twr_load            =>  twr_load       ,
        Twr_cnten           =>  twr_cnten      ,
        Rst_pend_rd         =>  rst_pend_rd   ,
        Rst_pend_wr         =>  rst_pend_wr   ,
        RdAck_rst           =>  rdack_rst     ,
        Clk                 =>  clk_i         ,                                            
        Rst                 =>  Rst                                                        
    );

IO_REG_I: entity modified_plb_ddr_controller_v1_00_c.io_registers(imp) 
  generic map ( C_DDR_AWIDTH        => C_DDR_AWIDTH,
                C_DDR_BANK_AWIDTH   => C_DDR_BANK_AWIDTH,  
                C_DDR_DWIDTH        => C_DDR_DWIDTH,       
                C_IPIF_DWIDTH       => C_IPIF_DWIDTH,
                C_PULLUPS           => C_PULLUPS
              )
  port map(
        Write_data          => write_data     , 
        Write_data_en       => write_data_en  , 
        Write_dqs_en        => write_dqs_en   ,
        Read_dqs_ce         => read_dqs_ce    ,
        Write_data_mask     => write_data_mask, 
        Read_data_en        => read_data_en   ,
        DQ_oe_cmb           => dq_oe_cmb      ,                 
        DQS_oe              => dqs_oe         , 
        DQS_rst             => dqs_rst        ,
        DQS_setrst          => dqs_setrst     ,
        RASn                => rasn           , 
        CASn                => casn           , 
        WEn                 => wen            , 
        BankAddr            => bankaddr       , 
        Addr                => addr           ,
        DDR_ReadData        => ddr_readdata   ,
        DDR_read_data_en    => ddr_read_data_en,
        DDR_DQ_i            => DDR_DQ_i       ,
        DDR_DQ_o            => DDR_DQ_o       , 
        DDR_DQ_t            => DDR_DQ_t       , 
        DDR_DM              => DDR_DM         , 
        DDR_Read_DQS        => ddr_read_dqs   ,
        DDR_DQS_I           => DDR_DQS_i      ,
        DDR_DQS_o           => DDR_DQS_o      ,
        DDR_DQS_t           => DDR_DQS_t      ,
        DDR_RASn            => DDR_RASn       , 
        DDR_CASn            => DDR_CASn       , 
        DDR_WEn             => DDR_WEn        , 
        DDR_BankAddr        => DDR_BankAddr   , 
        DDR_Addr            => DDR_Addr       , 
        Clk                 => clk_i          , 
        Clk90               => clk90_i        , 
        Clk_ddr_rddata      => clk_ddr_rddata_i ,
        Rst                 => rst              
    );

  IPIC_IF_I : entity modified_plb_ddr_controller_v1_00_c.ipic_if(imp)
    generic map
    (
      C_DDR_AWIDTH      => C_DDR_AWIDTH,        -- integer
      C_DDR_DWIDTH      => C_DDR_DWIDTH,        -- integer
      C_DDR_COL_AWIDTH  => C_DDR_COL_AWIDTH,    -- integer
      C_DDR_BANK_AWIDTH => C_DDR_BANK_AWIDTH,   -- integer
      C_IPIF_AWIDTH     => C_IPIF_AWIDTH,       -- integer
      C_IPIF_DWIDTH     => C_IPIF_DWIDTH,       -- integer
      C_INCLUDE_BURSTS  => C_INCLUDE_BURSTS     -- integer
    )
    port map
    (
      Bus2IP_CS       => Bus2IP_CS   ,      -- in
      Bus2IP_RNW      => Bus2IP_RNW  ,      -- in
      Bus2IP_Addr     => Bus2IP_Addr ,      -- in  (0:C_IPIF_AWIDTH-1)
      Bus2IP_Burst    => Bus2IP_Burst,      -- in
      Bus2IP_Data     => Bus2IP_Data ,      -- in  (0:C_IPIF_DWIDTH-1)
      Bus2IP_BE       => Bus2IP_BE   ,      -- in  (0:C_IPIF_DWIDTH/8-1)
      Bus2IP_RdReq    => Bus2IP_RdReq,      -- in
      Bus2IP_WrReq    => Bus2IP_WrReq,      -- in
      IP2Bus_ErrAck   => IP2Bus_ErrAck,     -- out
      IP2Bus_Retry    => IP2Bus_Retry,      -- out
      IP2Bus_Busy     => IP2Bus_Busy,       -- out
      IP2Bus_AddrAck  => IP2Bus_AddrAck,    -- out
      IP2Bus_WrAck    => IP2Bus_WrAck,      -- out
      IP2Bus_RdAck    => IP2Bus_RdAck,      -- out
      IP2Bus_ToutSup  => IP2Bus_ToutSup,    -- out
      IP2Bus_data     => IP2Bus_data,       -- out (0:C_IPIF_DWIDTH-1)
      Wr_AddrAck      => wr_addrack,        -- in
      Rd_AddrAck      => rd_addrack,        -- in
      WrAck           => wrack,             -- in
      RdAck           => rdack,             -- in
      ToutSup         => toutsup,           -- in
      Read_data       => read_data,         -- in  (0:C_IPIF_DWIDTH-1)
      Retry           => retry,             -- in
      Init_done       => init_done,         -- in
      IPIC_wrdata     => ipic_wrdata,       -- out (0:C_IPIF_DWIDTH-1)
      IPIC_be         => ipic_be,           -- out (0:C_IPIF_DWIDTH/8-1)
      Burst           => burst,             -- out
      Reset_pendrdreq => reset_pendrdreq,   -- in
      Reset_pendwrreq => reset_pendwrreq,   -- in
      Row_addr        => row_addr,          -- out (0:C_DDR_AWIDTH-1)
      Col_addr        => col_addr,          -- out (0:C_DDR_AWIDTH-1)
      Bank_addr       => bank_addr,         -- out (0:C_DDR_BANK_AWIDTH-1)
      Pend_rdreq      => pend_rdreq,        -- out
      Pend_wrreq      => pend_wrreq,        -- out
      Same_row        => same_row,          -- out
      Same_bank       => same_bank,         -- out
      Clk             => clk_i,             -- in
      Rst             => rst                -- in
    );


RDDATA_PATH_I: entity modified_plb_ddr_controller_v1_00_c.read_data_path(imp) 
  generic map ( C_IPIF_DWIDTH   => C_IPIF_DWIDTH,
                C_DDR_DWIDTH    => C_DDR_DWIDTH,
                C_INCLUDE_BURSTS=> C_INCLUDE_BURSTS,
                --C_RDLAT_WIDTH   => RDLAT_WIDTH,
                --C_RDLATCNT      => RDLATCNT,
                C_FAMILY        => C_FAMILY
               )
  port map (
            DDR_ReadData        => ddr_readdata,
            DDR_ReadDQS         => ddr_read_dqs,
            DDR_read_data_en    => ddr_read_data_en,
            Read_data_en        => read_data_en,
            RdAck_rst           => rdack_rst,
            Read_data           => read_data,
            RdAck               => rdack,
            Clk                 => clk_i,
            Clk_ddr_rddata      => clk_ddr_rddata_i,
            Rst                 => Rst
            );

CLKGEN_I: entity modified_plb_ddr_controller_v1_00_c.clock_gen(imp) 
  port map (
        Sys_clk             =>  Sys_clk,             
        Clk90_in            =>  Clk90_in,             
        DDR_Clk90_in        =>  DDR_Clk90_in,             
        Clk                 =>  clk_i,             
        Clk90               =>  clk90_i,                      
        Clk_ddr_rddata      =>  clk_ddr_rddata_i,             
        DDR_Clk             =>  DDR_Clk,                     
        DDR_Clkn            =>  DDR_Clkn,                  
        Rst                 =>  Rst                         
    );

end imp;

