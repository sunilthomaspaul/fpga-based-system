-------------------------------------------------------------------------------
-- $Id: clock_gen.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- clock_gen.vhd - entity/architecture pair
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
-- Filename:        clock_gen.vhd
-- Version:         v1.00c
-- Description:     This file contains the logic to generate the DDR output
--                  clocks, DDR_Clk and DDR_Clkn.
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
-- ALS           05/15/02    First Version
--
-- ALS         06/03/02
-- ^^^^^^
-- Registers that generate the DDR clock are no longer reset because the clock
-- feeds back to the DCM and violates the max clock value if a reset occurs
-- after power-up. Also, added BEGIN statement to generates.
-- ~~~~~~
-- ALS         06/12/02
-- Will use the clk90 output of the ddr dcm to capture ddr read data.
--
-- ALS         06/15/02
-- ^^^^^^
-- Test version - generation of DDR clock outputs has been moved out of 
-- DDRCLK_GEN generate so that the DDR DCM can be put at the system level
-- for experimentation.
-- ~~~~~~~
-- ALS          07/12/02
-- ^^^^^^
-- Renamed C_INCLUDE_CLK90_GEN to C_INCLUDE_CLK90_DCM for clarity. Added
-- C_INCLUDE_DDRCLK_DCM to separate the inclusion of the DDR DCM logic and the
-- output DDR registers that generate the DDR clock outputs.
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

library unisim;
use unisim.vcomponents.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--  -- inputs
--      Sys_clk                 -- system clock
--      Clk90_in                -- clock 90 input for use if C_INCLUDE_CLK90_DCM=0
--      DDR_Clk_in              -- ddr clock input
--
--  -- outputs
--      Clk                     -- either SysClk or DCM output
--      Clk90                   -- SysClk with 90 degree phase shift
--      Clk_ddr_rddata          -- DDR clock used to register incoming read data
--      DDR_Clk                 -- DDR clock output
--      DDR_Clkn                -- DDR inverted clock output
--
--    -- reset
--      Rst                     -- system reset 
--      DCM_Rst                 -- reset for DCM
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity clock_gen is
  port (
        Sys_clk             : in  std_logic;
        Clk90_in            : in  std_logic;
        DDR_Clk90_in        : in  std_logic;
        Clk                 : out std_logic;
        Clk90               : out std_logic;
        Clk_ddr_rddata      : out std_logic;
        DDR_Clk             : out std_logic;
        DDR_Clkn            : out std_logic;
        Rst                 : in  std_logic
    );
end entity clock_gen;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of clock_gen is
-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
signal clk90_n              : std_logic;

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Attribute declarations
----------------------------------------------------------------------------- 
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  
-- assign output signals
Clk90 <= Clk90_in;
Clk <= Sys_clk;
Clk_ddr_rddata <= DDR_Clk90_in;

-- create falling edge clocks
clk90_n <= not(Clk90_in);

-------------------------------------------------------------------------------
-- DDR Clock Outputs 
-------------------------------------------------------------------------------
-- use DDR I/O registers with CLk90 to generate DDR Clk and CLkn outputs
-- DDR Clk and Clkn are generated from CLK90 so it is centered in the data
DDR_CLK_REG_I: FDDRRSE
  port map (
    Q   => DDR_Clk,                     --[out]
    C0  => Clk90_in,                     --[in]
    C1  => clk90_n,                     --[in]
    CE  => '1',                         --[in]
    D0  => '1',                         --[in]
    D1  => '0',                         --[in]
    R   => '0',                         --[in]
    S   => '0'                          --[in]
  );

DDR_CLKN_REG_I: FDDRRSE
  port map (
    Q   => DDR_Clkn,                    --[out]
    C0  => Clk90_in,                     --[in]
    C1  => clk90_n,                     --[in]
    CE  => '1',                         --[in]
    D0  => '0',                         --[in]
    D1  => '1',                         --[in]
    R   => '0',                         --[in]
    S   => '0'                          --[in]
  );

end imp;