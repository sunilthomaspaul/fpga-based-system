-------------------------------------------------------------------------------
-- $Id: init_statemachine.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- init_statemachine.vhd - entity/architecture pair
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
-- Filename:        init_statemachine.vhd
-- Version:         v1.00c
-- Description:     This state machine controls the power-up sequence of commands
--                  to the DDR.
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
--   ALS           05/07/02    First Version
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.proc_common_pkg.all;
use modified_plb_ddr_controller_v1_00_c.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_DDR_AWIDTH        -- width of DDR address bus
--      C_DDR_BANK_AWIDTH   -- width of DDR bank address bus
--      C_DDR_BRST_SIZE     -- length of DDR burst
--      C_DDR_CAS_LAT       -- DDR CAS latency
--
-- Definition of Ports:
--  -- inputs
--      Cmd_done            -- indicates Command SM is in IDLE state
--      Trefi_pwrup_end     -- indicates 200uS, 200clocks has passed
--
--  -- outputs
--      Precharge           -- instructs Command SM to do a PRECHARGE command
--      Load_mr             -- instructs Command SM to do a LOAD_MR command
--      Tpwrup_load         -- loads the refresh_pwrup counter
--      Refresh             -- instructs Command SM to do a Refresh command
--      Register_data       -- data for the mode reg or extended mode reg
--      Register_sel        -- selects the mode reg or extended mode reg
--      Init_done           -- indicates initialization is complete
--                          -- NOTE: This signal could be a top-level output
--                             used as an interrupt to indicate init is done
--      DDR_CKE             -- DDR clock enable
--
--    -- Clocks and reset
--      Clk                 
--      Rst               
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity init_statemachine is
  generic ( C_DDR_AWIDTH        : integer;
            C_DDR_BANK_AWIDTH   : integer;
            C_DDR_BRST_SIZE     : integer;
            C_DDR_CAS_LAT       : integer);
  port (
    -- inputs
    Cmd_done            : in  std_logic;
    Trefi_pwrup_end     : in  std_logic;

    -- outputs
    Precharge           : out std_logic;
    Load_mr             : out std_logic;
    Tpwrup_load         : out std_logic;
    Refresh             : out std_logic;
    Register_data       : out std_logic_vector(0 to C_DDR_AWIDTH-1);
    Register_sel        : out std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
    Init_done           : out std_logic;
    DDR_CKE             : out std_logic;
    
    -- Clocks and reset
    Clk                 : in  std_logic;
    Rst                 : in  std_logic
    );
end entity init_statemachine;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of init_statemachine is
-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
-- Mode register definition
constant NUM_BRSTLEN_BITS   : integer := 3;
constant NUM_BRSTTYPE_BITS  : integer := 1;
constant NUM_CASLAT_BITS    : integer := 3;
constant NUM_OPMODE_BITS    : integer := C_DDR_AWIDTH - NUM_BRSTLEN_BITS
                                         - NUM_BRSTTYPE_BITS
                                         - NUM_CASLAT_BITS;
constant EMR_SEL        : std_logic_vector(0 to C_DDR_BANK_AWIDTH-1) := 
                                conv_std_logic_vector(1, C_DDR_BANK_AWIDTH);
constant MR_SEL         : std_logic_vector(0 to C_DDR_BANK_AWIDTH-1) := 
                                (others => '0');

constant QFC_N          : std_logic := '0';     -- QFC function disabled
constant EN_DLL         : std_logic := '1';     -- enable DLL
constant DRIVE_STR      : std_logic := '0';     -- normal drive strength   
constant BRST_TYPE      : std_logic := '0';     -- sequential burst type

constant BRST_LEN       : std_logic_vector(0 to NUM_BRSTLEN_BITS-1) :=
                          conv_std_logic_vector(log2(C_DDR_BRST_SIZE), NUM_BRSTLEN_BITS);
constant CAS_LAT        : std_logic_vector(0 to NUM_CASLAT_BITS-1) :=
                          conv_std_logic_vector(C_DDR_CAS_LAT, NUM_CASLAT_BITS);
constant NORM_OPMODE    : std_logic_vector(0 to NUM_OPMODE_BITS-1) := 
                                (others => '0');
constant RSTDLL_OPMODE  : std_logic_vector(0 to NUM_OPMODE_BITS-1) := 
                          conv_std_logic_vector(2, NUM_OPMODE_BITS);
constant EMR_OPMODE     : std_logic_vector(0 to (C_DDR_AWIDTH-3)-1) :=  
                                (others => '0');

constant RST_DLL_REGDATA    : std_logic_vector(0 to C_DDR_AWIDTH-1) :=
                    RSTDLL_OPMODE & CAS_LAT & BRST_TYPE & BRST_LEN;
-- hack to use Reduced Drive Strength (JTK) -- constant EN_DLL_REGDATA     : std_logic_vector(0 to C_DDR_AWIDTH-1) :=
-- hack to use Reduced Drive Strength (JTK) --                     (others => '0');
constant EN_DLL_REGDATA     : std_logic_vector(0 to C_DDR_AWIDTH-1) :=B"0000000000010";

constant NORM_OP_REGDATA    : std_logic_vector(0 to C_DDR_AWIDTH-1) :=
                    NORM_OPMODE & CAS_LAT & BRST_TYPE & BRST_LEN;

-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
type INIT_STATE_TYPE is (RESET, PRECHARGE1, ENABLE_DLL, RESET_DLL, PRECHARGE2, 
                         REFRESH1, REFRESH2, SET_OP_DONE);
signal initsm_ns        : INIT_STATE_TYPE;
signal initsm_cs        : INIT_STATE_TYPE;

-- combinational versions of registered outputs
signal precharge_cmb            : std_logic;
signal load_mr_cmb              : std_logic;
signal tpwrup_load_cmb          : std_logic;
signal refresh_cmb              : std_logic;
signal register_data_cmb        : std_logic_vector(0 to C_DDR_AWIDTH-1);
signal register_sel_cmb         : std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
signal init_done_cmb            : std_logic;
signal ddr_cke_cmb              : std_logic;
-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------

 
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  -- architecture imp

--------------------------------------------------------------------------------
-- Initialization State Machine
-- INITSM_CMB:     combinational process for determining next state
-- INITSM_REG:     state machine registers
--------------------------------------------------------------------------------
    -- Combinational process
INITSM_CMB: process (Trefi_pwrup_end, Cmd_done, initsm_cs)
begin
-- Set default values
precharge_cmb <= '0';
load_mr_cmb <= '0';
tpwrup_load_cmb <= '0';
refresh_cmb <= '0';       
register_data_cmb <= (others => '0');
register_sel_cmb <= (others => '0'); 
init_done_cmb <= '0';
ddr_cke_cmb <= '1';
initsm_ns <= initsm_cs;

case initsm_cs is
-------------------------- RESET --------------------------
    when RESET =>
        -- reset state
        -- the register process will keep initsm_cs in IDLE
        -- when reset is released, the 200us counter will start
        -- when this counter finishes, move to the PRECHARGE1 state
        ddr_cke_cmb <= '0';
        if Trefi_pwrup_end = '1' then
            initsm_ns <= PRECHARGE1;
            precharge_cmb <= '1';
            ddr_cke_cmb <= '1';
        end if;
        
-------------------------- PRECHARGE1 --------------------------
    when PRECHARGE1 =>
        -- wait for IDLE
        -- once IDLE asserts, prepare for ENABLE_DLL state
        -- select the Extended Mode Register and set the data
        if Cmd_done = '1' then
            initsm_ns <= ENABLE_DLL;
            register_sel_cmb <= EMR_SEL;
            register_data_cmb <= EN_DLL_REGDATA;
            load_mr_cmb <= '1';
        end if;        

-------------------------- ENABLE_DLL --------------------------
    when ENABLE_DLL =>
        -- wait for IDLE
        -- once IDLE asserts, prepare for RESET_DLL state
        -- select the Mode Register and set the data
        -- enable the 200 clock timer
        if Cmd_done = '1' then
            initsm_ns <= RESET_DLL;
            register_sel_cmb <= MR_SEL;
            register_data_cmb <= RST_DLL_REGDATA;
            tpwrup_load_cmb <= '1';
            load_mr_cmb <= '1';
        end if;
           
-------------------------- RESET_DLL --------------------------
    when RESET_DLL =>
        -- wait in this state for 200 clocks
        if Trefi_pwrup_end = '1' then
            -- prepare for PRECHARGE2 state
            initsm_ns <= PRECHARGE2;
            precharge_cmb <= '1';
        end if;
            
-------------------------- PRECHARGE2 --------------------------
    when PRECHARGE2 =>
        -- wait in this state for IDLE
        -- once IDLE asserts, prepare for REFRESH1 state
        if Cmd_done = '1' then
            initsm_ns <= REFRESH1;
            refresh_cmb <= '1';
        end if;
        
-------------------------- REFRESH1 --------------------------
    when REFRESH1 =>
        -- wait in this state for refresh period to end
        -- once cycle ends, prepare for REFRESH2 state
        if Cmd_done = '1' then
            initsm_ns <= REFRESH2;
            refresh_cmb <= '1';
        end if;
        
-------------------------- REFRESH2 --------------------------
    when REFRESH2 =>
        -- wait in this state for IDLE
        -- once IDLE asserts, prepare for SET_OP state
        -- select the Mode Register and set the data
        if Cmd_done = '1' then
            initsm_ns <= SET_OP_DONE;
            register_sel_cmb <= MR_SEL;
            register_data_cmb <= NORM_OP_REGDATA;
            load_mr_cmb <= '1';
        end if;

-------------------------- SET_OP_DONE --------------------------
    when SET_OP_DONE =>
        -- once in this state, initialization is done
        -- state machine stays in this state until a reset
        -- sets the current state to IDLE and the process starts again.
        initsm_ns <= SET_OP_DONE;
        init_done_cmb <= '1';
-------------------------- DEFAULT --------------------------
    when others => 
        initsm_ns <= RESET;
end case;
end process INITSM_CMB;
    
INITSM_REG: process (Clk)
begin

    if (Clk'event and Clk = '1') then
        if (Rst = RESET_ACTIVE) then
            initsm_cs <= RESET;
            Precharge <= '0';
            Load_mr <= '0';
            Refresh <= '0';
            Tpwrup_load <= '0';
            Register_data <= (others => '0');
            Register_sel <= (others => '0');
            Init_done <= '0';
            DDR_CKE <= '0';
        else
            initsm_cs <= initsm_ns;
            Precharge <= precharge_cmb;
            Load_mr <= load_mr_cmb;
            Refresh <= refresh_cmb;
            Tpwrup_load <= tpwrup_load_cmb;
            Register_data <= register_data_cmb;
            Register_sel <= register_sel_cmb;
            Init_done <= init_done_cmb;
            DDR_CKE <= ddr_cke_cmb;
        end if;
    end if;
end process INITSM_REG;    


end imp;

