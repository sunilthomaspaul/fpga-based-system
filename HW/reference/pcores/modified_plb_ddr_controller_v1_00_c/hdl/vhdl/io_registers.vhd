-------------------------------------------------------------------------------
-- $Id: io_registers.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- io_registers.vhd - entity/architecture pair
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
-- Filename:        io_registers.vhd
-- Version:         v1.00c
-- Description:     This file contains all of the io_registers for the DDR design.
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
--   ALS           05/13/02    First Version
--
--   ALS           06/04/02
-- ^^^^^^
--  Added XON generic and set to false for zero-delay simulations
-- ~~~~~~
--  ALS             06/07/02
-- ^^^^^^
--  Added input register for DQS which is asynchronously held in reset by 
--  read_data_en.
-- ~~~~~~
--  ALS             06/11/02
-- ^^^^^^
--  Changed reset of DQS input register because there is only one reset in IOB. 
--  Instead, synchronized read_data_en and used it as clock enable. Used
--  Clk90 for DQST so it can go into IOB with DQS.
-- ~~~~~~
--  ALS             09/25/02
-- ^^^^^^
--  To allow for either pullups or pulldowns on DQS, will now register DQS on 
--  both falling and rising edge of DDR clock and verify that it is 0 and then 1
--  before writing data to the FIFO. Will output the DDR_READ_DATA_ENABLE signal
--  to the read data path module to qualify the FIFO write enable signal.
-- ~~~~~~
--  ALS            06/25/03
-- ^^^^^^
--  Removed XON generic from unisim component instantiations.
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
--      C_DDR_AWIDTH        -- width of DDR address bus
--      C_DDR_BANK_AWIDTH   -- width of DDR bank address bus
--      C_DDR_DWIDTH        -- length of DDR burst
--      C_IPIF_DWIDTH       -- DDR CAS latency
--      C_PULLUPS           -- indicates pull resistor type on DQS
--
-- Definition of Ports:
--  -- inputs
--      Write_data          -- data to be written to DDR
--      Write_data_en       -- write data enable 
--      Write_dqs_en        -- write dqs enable
--      Read_dqs_ce         -- read dqs clock enable
--      Write_data_mask     -- data mask to DDR
--      Read_data_en        -- read data clock enable
--      DQ_oe_cmb           -- combinational DQ output enable
--      DQS_oe              -- DQS output enable
--      DQS_rst             -- DQS reset
--      DQS_setrst          -- DQS set/reset
--      RASn                -- RASn for DDR
--      CASn                -- CASn for DDR
--      WEn                 -- WEn for DDR
--      BankAddr            -- bank address for DDR
--      Addr                -- address for DDR
--      DDR_DQ_i            -- input data from DDR
--      DDR_DQS_i           -- input DQS from DDR
--
--  -- outputs
--      DDR_DQ_o            -- DQ output to DDR
--      DDR_DQ_t            -- DQ output enable 
--      DDR_DM              -- DDR data mask
--      DDR_Read_DQS        -- DQS value read from DDR
--      DDR_DQS_o           -- DQS output to DDR
--      DDR_DQS_t           -- DQS output enable
--      DDR_RASn            -- RASn output to DDR
--      DDR_CASn            -- CASn output to DDR
--      DDR_WEn             -- WEn output to DDR
--      DDR_BankAddr        -- bank address output to DDR
--      DDR_Addr            -- address output to DDR
--
--    -- Clocks and reset
--      Clk                 -- bus clock
--      Clk90               -- bus clock shifted 90
--      Clk_ddr_rddata      -- DDR feedback clock shifted 90
--      Rst               
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity io_registers is
  generic ( C_DDR_AWIDTH        : integer;
            C_DDR_BANK_AWIDTH   : integer;
            C_DDR_DWIDTH        : integer;
            C_IPIF_DWIDTH       : integer;
            C_PULLUPS           : integer
            );
  port (
        Write_data              : in  std_logic_vector(0 to C_IPIF_DWIDTH-1);
        Write_data_en           : in  std_logic;
        Write_dqs_en            : in  std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        Read_dqs_ce             : in  std_logic;
        Write_data_mask         : in  std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
        Read_data_en            : in  std_logic;
        DQ_oe_cmb               : in  std_logic;
        DQS_oe                  : in  std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DQS_rst                 : in  std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DQS_setrst              : in  std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        RASn                    : in  std_logic;
        CASn                    : in  std_logic;
        WEn                     : in  std_logic;
        BankAddr                : in  std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        Addr                    : in  std_logic_vector(0 to C_DDR_AWIDTH-1);
        DDR_ReadData            : out std_logic_vector(0 to C_IPIF_DWIDTH-1);
        DDR_read_data_en        : out std_logic;
        DDR_DQ_i                : in  std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQ_o                : out std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DQ_t                : out std_logic_vector(0 to C_DDR_DWIDTH-1);
        DDR_DM                  : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_Read_DQS            : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_DQS_i               : in std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_DQS_o               : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_DQS_t               : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_RASn                : out std_logic;       
        DDR_CASn                : out std_logic;
        DDR_WEn                 : out std_logic;
        DDR_BankAddr            : out std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        DDR_Addr                : out std_logic_vector(0 to C_DDR_AWIDTH-1);
        Clk                     : in  std_logic;
        Clk90                   : in  std_logic;
        Clk_ddr_rddata          : in  std_logic;
        Rst                     : in  std_logic
    );
end entity io_registers;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of io_registers is
-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
signal clk_n                : std_logic;
signal clk90_n              : std_logic;
signal clk_ddr_rddata_n     : std_logic;
signal ddr_read_data_en_i   : std_logic;
signal ddr_read_dqs_ce      : std_logic;
-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Attribute declarations
----------------------------------------------------------------------------- 
attribute IOB                   : string;

attribute IOB of DDR_RASN_REG : label is "true";
attribute IOB of DDR_CASN_REG : label is "true";
attribute IOB of DDR_WEN_REG  : label is "true";

-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  
-- create the inverse clocks and control signals
clk_n               <= not(Clk);
clk90_n             <= not(Clk90);
clk_ddr_rddata_n    <= not(Clk_ddr_rddata);

-- assign output signals
DDR_read_data_en <= ddr_read_data_en_i;
-------------------------------------------------------------------------------
-- Instantiate the IOB Output registers
-------------------------------------------------------------------------------
DDR_DQ_REG_GEN: for i in 0 to C_DDR_DWIDTH-1 generate
  
  attribute IOB   : string;
  attribute IOB of DDR_DQ_REG_I     : label is "true";
  attribute IOB of DDR_DQT_REG_I    : label is "true";
    
begin
    
    -- use DDR register to generate DQ_o
    DDR_DQ_REG_I: FDDRRSE
      port map (
        Q   => DDR_DQ_o(i),                 --[out]
        C0  => Clk,                         --[in]
        C1  => clk_n,                       --[in]
        CE  => Write_data_en,               --[in]
        D0  => Write_data(i),               --[in]
        D1  => Write_data(C_DDR_DWIDTH+i),  --[in]
        R   => Rst,                         --[in]
        S   => '0'                          --[in]
      );
    -- use regular register with io attribute for tri-state control  
    DDR_DQT_REG_I: FDS
      port map (
        Q   => DDR_DQ_t(i), --[out]
        C   => Clk,         --[in]
        D   => DQ_oe_cmb,   --[in]
        S   => Rst          --[in]
      );      
end generate DDR_DQ_REG_GEN;

DDR_DMDQS_REG_GEN: for i in 0 to C_DDR_DWIDTH/8-1 generate

  attribute IOB   : string;
  attribute IOB of DDR_DM_REG_I     : label is "true";
  attribute IOB of DDR_DQST_REG_I   : label is "true";
    
begin
    -- use DDR register to generate DM and DQS
    DDR_DM_REG_I: FDDRRSE
      port map (
        Q   => DDR_DM(i),                   --[out]
        C0  => Clk,                         --[in]
        C1  => clk_n,                       --[in]
        CE  => Write_data_en,               --[in]
        D0  => Write_data_mask(i),          --[in]
        D1  => Write_data_mask(C_DDR_DWIDTH/8+i),--[in]
        R   => '0',                         --[in]
        S   => Rst                          --[in]
      );
      
    -- DQS is generated from CLK90 so it is centered in the data
    -- if pullups are on the board, set DQS based on DQS_setrst
    -- and reset based on DQS_rst
    -- if pulldowns are on the board, reset DQS based on DQS_rst
    -- don't need to set DQS
    PULLUPDQS_GEN: if C_PULLUPS = 1 generate
    
      attribute IOB   : string;
      attribute IOB of DDR_DQS_REG_I     : label is "true";

    begin
        DDR_DQS_REG_I: FDDRRSE
         port map (
            Q   => DDR_DQS_o(i),                --[out]
            C0  => Clk90,                       --[in]
            C1  => clk90_n,                     --[in]
            CE  => Write_dqs_en(i),             --[in]
            D0  => '1',                         --[in]
            D1  => '0',                         --[in]
            R   => DQS_rst(i),                  --[in]
            S   => DQS_setrst(i)                --[in]
          );
    end generate PULLUPDQS_GEN;
    PULLDOWNDQS_GEN: if C_PULLUPS=0 generate

      attribute IOB   : string;
      attribute IOB of DDR_DQS_REG_I     : label is "true";

    begin
        DDR_DQS_REG_I: FDDRRSE
         port map (
            Q   => DDR_DQS_o(i),                --[out]
            C0  => Clk90,                       --[in]
            C1  => clk90_n,                     --[in]
            CE  => Write_dqs_en(i),             --[in]
            D0  => '1',                         --[in]
            D1  => '0',                         --[in]
            R   => DQS_rst(i),                  --[in]
            S   => '0'                          --[in]
          );
     end generate PULLDOWNDQS_GEN; 

    -- use regular register with io attribute for tri-state control  
    DDR_DQST_REG_I: FDS
      port map (
        Q   => DDR_DQS_t(i), --[out]
        C   => Clk90,         --[in]
        D   => DQS_oe(i),     --[in]
        S   => '0'         --[in]
      );      

end generate DDR_DMDQS_REG_GEN;

-- Can use regular registers with attributes for the rest of the control signals
-- DDR address
DDR_ADDR_REG_GEN: for i in 0 to C_DDR_AWIDTH-1 generate

  attribute IOB   : string;
  attribute IOB of DDR_ADDR_REG_I     : label is "true";
    
begin
    DDR_ADDR_REG_I: FDR
      port map (
        Q   => DDR_Addr(i), --[out]
        C   => Clk,         --[in]
        D   => Addr(i),     --[in]
        R   => Rst          --[in]
      );
end generate DDR_ADDR_REG_GEN;

-- DDR Bank Address
DDR_BANKADDR_REG_GEN: for i in 0 to C_DDR_BANK_AWIDTH-1 generate

  attribute IOB   : string;
  attribute IOB of DDR_BANKADDR_REG_I     : label is "true";
    
begin
    DDR_BANKADDR_REG_I: FDR
      port map (
        Q   => DDR_BankAddr(i), --[out]
        C   => Clk,             --[in]
        D   => BankAddr(i),     --[in]
        R   => Rst              --[in]
      );
end generate DDR_BANKADDR_REG_GEN;

-- DDR RASn, CASn, and WEn
DDR_RASN_REG: FDS
  port map (
    Q   => DDR_RASn,--[out]
    C   => Clk,     --[in]
    D   => RASn,    --[in]
    S   => Rst      --[in]
  );
DDR_CASN_REG: FDS
  port map (
    Q   => DDR_CASn,--[out]
    C   => Clk,     --[in]
    D   => CASn,    --[in]
    S   => Rst      --[in]
  );
DDR_WEN_REG: FDS
  port map (
    Q   => DDR_WEn, --[out]
    C   => Clk,     --[in]
    D   => WEn,     --[in]
    S   => Rst      --[in]
  );

-------------------------------------------------------------------------------
-- IOB input DDR registers
-------------------------------------------------------------------------------
-- First synchronize the read data enable signal
RD_DATAEN_SYNC_REG: FDC
  port map (
    Q       => ddr_read_data_en_i,    --[out]
    C       => Clk_ddr_rddata,      --[in]
    CLR     => Rst,                 --[in]
    D       => Read_data_en         --[in]
  );
-- Synchronize the read dqs ce signal
RD_DQSCE_SYNC_REG: FDC
  port map (
    Q       => ddr_read_dqs_ce,    --[out]
    C       => Clk_ddr_rddata,      --[in]
    CLR     => Rst,                 --[in]
    D       => Read_dqs_ce         --[in]
  );

INPUT_DDR_REGS_GEN: for i in 0 to C_DDR_DWIDTH -1 generate

  attribute IOB   : string;
  attribute IOB of RDDATA_HIREG    : label is "true";
  attribute IOB of RDDATA_LOREG    : label is "true";
    
begin
    -- use async reset since reg is clocked from Clk_ddr_rddata
    RDDATA_HIREG: FDCE
      port map (
        Q   => DDR_ReadData(i), --[out]
        C   => Clk_ddr_rddata,  --[in]
        CE  => ddr_read_data_en_i,--[in]
        D   => DDR_DQ_i(i),     --[in]
        CLR => Rst              --[in]
      );

    RDDATA_LOREG: FDCE
      port map (
        Q   => DDR_ReadData(C_DDR_DWIDTH+i),  --[out]
        C   => clk_ddr_rddata_n,              --[in]
        CE  => ddr_read_data_en_i,              --[in]
        D   => DDR_DQ_i(i),                   --[in]
        CLR => Rst                            --[in]
      );
end generate INPUT_DDR_REGS_GEN;

INPUT_DQS_REG_GEN: for i in 0 to C_DDR_DWIDTH/8-1 generate

  attribute IOB   : string;
  attribute IOB of RDDQS_REG    : label is "true";
    
begin
    RDDQS_REG: FDCE
      port map (
        Q   => DDR_Read_DQS(i), --[out]
        C   => Clk_ddr_rddata,  --[in]
        D   => DDR_DQS_i(i),    --[in]
        CE  => ddr_read_dqs_ce,--[in]
        CLR => '0'              --[in]
     );
end generate INPUT_DQS_REG_GEN;      

end imp;