-------------------------------------------------------------------------------
-- $Id: read_data_path.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- read_data_path.vhd - entity/architecture pair
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
-- Filename:        read_data_path.vhd
-- Version:         v1.00c
-- Description:     This file contains the logic to synchronize the read data
--                  for the DDR design.
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
--   ALS           05/15/02    First Version
--
--   ALS            06/07/02
-- ^^^^^^
--  Changed read data path to use an asynchronous FIFO to capture data and 
--  re-align to internal FPGA clock
-- ~~~~~~
-- 
--  ALS             06/11/02
-- ^^^^^^
--  Since FDDRSE is only in Virtex2 and Virtex2P, don't need generate statements
--  for different FIFO types.
-- ~~~~~~
--  ALS             07/16/02
-- ^^^^^^
--  When C_INCLUDE_BURSTS=1, the IP2Bus_RdAck signal must precede the data by
--  one clock so the FIFO_EMPTY signal is negated and used to generate RdAck
--  without the register delay.
-- ~~~~~~
--  ALS             09/25/02
-- ^^^^^^
--  To allow for either pullups or pulldowns on DQS, will now register DQS on 
--  both falling and rising edge of DDR clock and verify that it is 0 and then 1
--  before writing data to the FIFO
-- ~~~~~~
--  ALS             07/08/03
-- ^^^^^^
--  Removed instantiation of Coregen FIFO - instead modified code so that 
--  XST would call Coregen to instantiate the FIFO.
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

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.coregen_comp_defs.all;

library unisim;
use unisim.all;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_IPIF_DWIDTH       -- width of the IPIF data bus
--      C_DDR_DWIDTH        -- ddr data width
--      C_INCLUDE_BURSTS    -- support bursts
--      C_RDLAT_WIDTH       -- determinate timer read latency counter width
--      C_RDLATCNT          -- determinate timer read latency count
--      C_FAMILY            -- target FPGA family type
--
-- Definition of Ports:
--  -- inputs
--      DDR_ReadData        -- data input from DDR
--      DDR_ReadDQS         -- data strobe input from DDR
--      DDR_read_data_en    -- gates the DDR input FIFO write enable
--      Read_data_en        -- read data enable - used to reset FIFO
--
--  -- outputs
--      Read_data           -- read data synchronized to FPGA clock
--      RdAck               -- read data acknowledge
--
--    -- Clocks and reset
--      Clk                 -- bus clock
--      Clk_ddr_rddata      -- DDR feedback clock shifted 90
--      Rst               
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity read_data_path is
  generic ( C_IPIF_DWIDTH       : integer;
            C_DDR_DWIDTH        : integer;
            C_INCLUDE_BURSTS    : integer;
            C_FAMILY            : string := "virtex2"
           );
  port (
        DDR_ReadData            : in  std_logic_vector(0 to C_IPIF_DWIDTH-1);
        DDR_ReadDQS             : in  std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DDR_read_data_en        : in  std_logic;
        Read_data_en            : in  std_logic;
        RdAck_rst               : in  std_logic;
        Read_data               : out std_logic_vector(0 to C_IPIF_DWIDTH-1);
        RdAck                   : out std_logic;

        -- Clocks and reset
        Clk                     : in  std_logic;
        Clk_ddr_rddata          : in  std_logic;
        Rst                     : in  std_logic
    );
end entity read_data_path;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of read_data_path is
-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------

constant ZERO_EMPTY     : std_logic_vector(0 to C_IPIF_DWIDTH/16-1) := (others => '0');

-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
-- fifo control signals
signal fifo_rden            : std_logic;
signal fifo_wren            : std_logic_vector(0 to C_IPIF_DWIDTH/16-1);
signal fifo_wren_gate       : std_logic_vector(0 to C_IPIF_DWIDTH/16-1);
signal fifo_empty           : std_logic_vector(0 to C_IPIF_DWIDTH/16-1);
signal fifo_rst             : std_logic;

-- internal signals
signal read_data_i          : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal rdack_i              : std_logic;
-----------------------------------------------------------------------------
-- Component declarations
-------------------------------------------------------------------------------

component ld_arith_reg
    generic (
        C_ADD_SUB_NOT : boolean := false;
        C_REG_WIDTH   : natural := 8;
        C_RESET_VALUE : std_logic_vector;
        C_LD_WIDTH    : natural :=  8;
        C_LD_OFFSET   : natural :=  0;
        C_AD_WIDTH    : natural :=  8;
        C_AD_OFFSET   : natural :=  0
    );
    port (
        CK       : in  std_logic;
        RST      : in  std_logic; 
        Q        : out std_logic_vector(0 to C_REG_WIDTH-1);
        LD       : in  std_logic_vector(0 to C_LD_WIDTH-1); 
        AD       : in  std_logic_vector(0 to C_AD_WIDTH-1); 
        LOAD     : in  std_logic;  
        OP       : in  std_logic   
       );
end component ld_arith_reg;
 
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------
begin  

-------------------------------------------------------------------------------
-- FIFO control signals
-------------------------------------------------------------------------------
-- write the FIFOs when the DDR asserts the data strobe
FIFO_WREN_GEN: for i in 0 to C_IPIF_DWIDTH/16-1 generate
begin
    FIFO_WREN_GATE_PROCESS: process(Clk_ddr_rddata)
    begin
        if Clk_ddr_rddata'event and Clk_ddr_rddata = '1' then
            if DDR_read_data_en = '0' then
                fifo_wren_gate(i) <= '0';
            elsif DDR_ReadDQS(i)='0' then
                fifo_wren_gate(i) <= '1';
            end if;
        end if;
    end process FIFO_WREN_GATE_PROCESS;
    
    fifo_wren(i)  <= '1' when (DDR_ReadDQS(i)='1' and fifo_wren_gate(i)='1')
                        else '0';
end generate FIFO_WREN_GEN;

-- read the FIFOs when all FIFOs are not empty
fifo_rden <= '1' when fifo_empty = ZERO_EMPTY
            else '0';
-- reset the FIFOs when the read data phase is over
FIFO_RST_REG: process(Clk)
begin
    if Clk'event and Clk = '1' then
        if Rst = RESET_ACTIVE then
            fifo_rst <= RESET_ACTIVE;
        else
            fifo_rst <= not(Read_data_en);
        end if;
     end if;
end process FIFO_RST_REG;
-------------------------------------------------------------------------------
-- Generate RdAck 
-------------------------------------------------------------------------------
RDACK_PROCESS: process(Clk)
begin
    if Clk'event and Clk='1' then
       if Rst = RESET_ACTIVE or RdAck_rst = '1' then
            rdack_i <= '0';
        else 
            rdack_i <= fifo_rden;
        end if;
    end if;
end process RDACK_PROCESS;
RdAck <= rdack_i;

-------------------------------------------------------------------------------
-- Instantiate the FIFOs
-------------------------------------------------------------------------------
-- use one FIFO for each DQS. Since there are two bytes from the DDR each clock,
-- one DQS bit corresponds to 16-bit data. Therefore, instantiate 16-bit wide
-- FIFOs
FIFO_GEN: for i in 0 to C_IPIF_DWIDTH/16-1 generate
    V2_ASYNCH_FIFO_I: async_fifo_v4_0
        generic map(
                c_enable_rlocs => 0,
                c_data_width => 16,
                c_fifo_depth => 15,
                c_has_almost_full => 0,
                c_has_almost_empty => 0,
                c_has_wr_count => 0,
                c_has_rd_count => 0,
                c_wr_count_width => 2,
                c_rd_count_width => 2,
                c_has_rd_ack => 0,
                c_rd_ack_low => 0,
                c_has_rd_err => 0,
                c_rd_err_low => 0,
                c_has_wr_ack => 0,
                c_wr_ack_low => 0,
                c_has_wr_err => 0,
                c_wr_err_low => 0,
                c_use_blockmem => 0
                )
            port map (
                din     => DDR_ReadData(i*16 to i*16+15),
                wr_en   => fifo_wren(i),
                wr_clk  => Clk_ddr_rddata,
                rd_en   => fifo_rden,
                rd_clk  => Clk,
                ainit   => fifo_rst,
                dout    => read_data_i(i*16 to i*16+15),
                full    => open,
                empty   => fifo_empty(i)
                );
end generate FIFO_GEN;    


Read_data <= read_data_i;

end imp;