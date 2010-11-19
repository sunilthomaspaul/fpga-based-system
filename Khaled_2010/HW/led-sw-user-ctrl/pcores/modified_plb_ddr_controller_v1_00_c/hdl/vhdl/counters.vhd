-------------------------------------------------------------------------------
-- $Id: counters.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- counters.vhd - entity/architecture pair
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
-- Filename:        counters.vhd
-- Version:         v1.00c
-- Description:     This file contains all of the counters for the DDR design.
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
--   ALS           05/10/02    First Version
--
--  ALS             06/03/02
-- ^^^^^^
--  Fixed if statements in the process that generates the counter end signals.
-- ~~~~~~
--  ALS             06/20/02
-- ^^^^^^
--  Fixed gp counter so that the end signal stays asserted until the next load.
-- ~~~~~~
--  ALS             07/26/02
-- ^^^^^^
--  Twr count is not used if cnt = 0, so use generate around that counter
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

-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_GPCNT_WIDTH           -- width of general purpose counter
--      C_RCCNT_WIDTH           -- width of Trc counter
--      C_RRDCNT_WIDTH          -- width of Trrd counter
--      C_RASCNT_WIDTH          -- width of Tras counter
--      C_REFICNT_WIDTH         -- width of Trefi counter
--      C_WRCNT_WIDTH           -- width of Twr counter
--      C_BRSTCNT_WIDTH         -- width of burst counter
--      C_CASLATCNT_WIDTH       -- width of cas latency counter
--      C_RCCNT                 -- Trc count value in clock cycles 
--      C_RRDCNT                -- Trrd count value in clock cycles
--      C_RASCNT                -- Tras count value in clock cycles
--      C_REFICNT               -- Trefi count value in clock cycles
--      C_200US_CNT             -- 200us count value in clock cycles
--      C_200CK_CNT             -- 200 clocks count value
--      C_WRCNT                 -- Twr count value in clock cycles
--      C_BRSTCNT               -- Burst count value in clock cycles
--      C_CMDCNT                -- Command count value in clock cycles
--      C_CASLATCNT             -- CAS latency count value in clock cycles
--      C_DDR_BRST_SIZE         -- DDR burst size
--      C_CASLAT                -- DDR CAS latency
--
-- Definition of Ports:
--  -- inputs
--      GPcnt_load              -- load general purpose counter 
--      GPcnt_en                -- general purpose counter count enable
--      GPcnt_data              -- general purpose counter load value
--      Trrd_load               -- load Trrd counter
--      Trc_load                -- load Trc counter
--      Tras_load               -- load Tras counter
--      Trefi_load              -- load Trefi counter
--      Tpwrup_load             -- load power-up counter
--      Tbrst_load              -- load burst counter
--      Tbrst_cnt_en            -- burst counter count enable
--      Init_done               -- initialization is done
--      Tcmd_load               -- load command counter
--      Tcmd_cnt_en             -- command counter count enable
--      Tcaslat_load            -- load CAS latency counter
--      Tcaslat_cnt_en          -- CAS latency count enable
--      Twr_load                -- load Twr counter
--      Twr_rst                 -- reset Twr counter
--      Twr_cnten               -- Twr count enable
-- -- outputs
--      GPcnt_end               -- general purpose count complete     
--      Trrd_end                -- Trrd count complete
--      Trc_end                 -- Trc count complete
--      Tras_end                -- Tras count complete
--      Trefi_pwrup_end         -- Trefi-powerup count complete
--      Twr_end                 -- Twr count complete
--      DDR_brst_end            -- Burst count complete
--      Tcmd_end                -- Command count complete
--      Tcaslat_end             -- CAS latency count complete
--
--    -- Clocks and reset
--      Clk                 
--      Rst               
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity counters is
  generic ( C_GPCNT_WIDTH       : integer;
            C_RCCNT_WIDTH       : integer;
            C_RRDCNT_WIDTH      : integer;
            C_RASCNT_WIDTH      : integer;
            C_REFICNT_WIDTH     : integer;
            C_WRCNT_WIDTH       : integer;
            C_BRSTCNT_WIDTH     : integer;
            C_CASLATCNT_WIDTH   : integer;
            C_RCCNT             : std_logic_vector;
            C_RRDCNT            : std_logic_vector;
            C_RASCNT            : std_logic_vector;
            C_REFICNT           : std_logic_vector;
            C_200US_CNT         : std_logic_vector;
            C_200CK_CNT         : std_logic_vector;
            C_WRCNT             : std_logic_vector;
            C_BRSTCNT           : std_logic_vector;
            C_CMDCNT            : std_logic_vector;
            C_CASLATCNT         : std_logic_vector;
            C_DDR_BRST_SIZE     : integer;
            C_CASLAT            : integer
            );
  port (
        GPcnt_load              : in  std_logic;
        GPcnt_en                : in  std_logic;
        GPcnt_data              : in  std_logic_vector(0 to C_GPCNT_WIDTH-1);
        Trrd_load               : in  std_logic;
        Trc_load                : in  std_logic;
        Tras_load               : in  std_logic;
        Trefi_load              : in  std_logic;
        Tpwrup_load             : in  std_logic;
        Tbrst_load              : in  std_logic;
        Tbrst_cnt_en            : in  std_logic;
        Init_done               : in  std_logic;
        Tcmd_load               : in  std_logic;
        Tcmd_cnt_en             : in  std_logic;
        Tcaslat_load            : in  std_logic;
        Tcaslat_cnt_en          : in  std_logic;
        Twr_load                : in  std_logic;
        Twr_rst                 : in  std_logic;
        Twr_cnten               : in  std_logic;
        GPcnt_end               : out std_logic;
        Trrd_end                : out std_logic;
        Trc_end                 : out std_logic;
        Tras_end                : out std_logic;
        Trefi_pwrup_end         : out std_logic;       
        Twr_end                 : out std_logic;
        DDR_brst_end            : out std_logic;
        Tcmd_end                : out std_logic;
        Tcaslat_end             : out std_logic;
    
        -- Clocks and reset
        Clk                     : in  std_logic;
        Rst                     : in  std_logic
    );
end entity counters;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of counters is
-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
-- reset values
constant GPCNT_RST      : std_logic_vector(0 to C_GPCNT_WIDTH-1)  := (others => '0');
constant RCCNT_RST      : std_logic_vector(0 to C_RCCNT_WIDTH-1)  := (others => '0');
constant RRDCNT_RST     : std_logic_vector(0 to C_RRDCNT_WIDTH-1) := (others => '0');
constant RASCNT_RST     : std_logic_vector(0 to C_RASCNT_WIDTH-1) := (others => '0');
constant REFICNT_RST    : std_logic_vector(0 to C_REFICNT_WIDTH-1):= (others => '0');
constant WRCNT_RST      : std_logic_vector(0 to C_WRCNT_WIDTH-1)  := (others => '0');
constant BRSTCNT_RST    : std_logic_vector(0 to C_BRSTCNT_WIDTH-1):= (others => '0');
constant CMDCNT_RST     : std_logic_vector(0 to C_BRSTCNT_WIDTH-1):= (others => '0');
constant CASLATCNT_RST  : std_logic_vector(0 to C_CASLATCNT_WIDTH-1):= (others => '0');

-- zero values
constant ZERO_GPCNT     : std_logic_vector(0 to C_GPCNT_WIDTH-1)  := (others => '0');

-- terminal values
constant GPCNTR_END     : std_logic_vector(0 to C_GPCNT_WIDTH-1)  := 
                        conv_std_logic_vector(1,C_GPCNT_WIDTH);
-- since state machine will always go from PRECHARGE to IDLE before going to ACTIVE,
-- make the end signal for Trc a clock early
constant RCCNT_END      : std_logic_vector(0 to C_RCCNT_WIDTH-1) := 
                        conv_std_logic_vector(2,C_RCCNT_WIDTH);
constant RRDCNT_END     : std_logic_vector(0 to C_RRDCNT_WIDTH-1) := 
                        conv_std_logic_vector(1,C_RRDCNT_WIDTH);
constant RASCNT_END     : std_logic_vector(0 to C_RASCNT_WIDTH-1) := 
                        conv_std_logic_vector(1,C_RASCNT_WIDTH);
constant REFICNT_END    : std_logic_vector(0 to C_REFICNT_WIDTH-1):= 
                        conv_std_logic_vector(1,C_REFICNT_WIDTH);
constant WRCNT_END      : std_logic_vector(0 to C_WRCNT_WIDTH-1)  := 
                        conv_std_logic_vector(1,C_WRCNT_WIDTH);
constant BRSTCNT_END    : std_logic_vector(0 to C_BRSTCNT_WIDTH-1):= 
                        conv_std_logic_vector(1,C_BRSTCNT_WIDTH);
constant CMDCNT_END     : std_logic_vector(0 to C_BRSTCNT_WIDTH-1):= 
                        conv_std_logic_vector(1,C_BRSTCNT_WIDTH);

-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
signal gp_cnt           : std_logic_vector(0 to C_GPCNT_WIDTH-1);
signal rc_cnt           : std_logic_vector(0 to C_RCCNT_WIDTH-1);
signal rrd_cnt          : std_logic_vector(0 to C_RRDCNT_WIDTH-1);
signal ras_cnt          : std_logic_vector(0 to C_RASCNT_WIDTH-1);
signal refi_pwrup_load  : std_logic;
signal refi_pwrup_data  : std_logic_vector(0 to C_REFICNT_WIDTH-1);
signal refi_pwrup_cnt   : std_logic_vector(0 to C_REFICNT_WIDTH-1);
signal refi_pwrup_cnten : std_logic;
signal wr_cnt           : std_logic_vector(0 to C_WRCNT_WIDTH-1);
signal brst_cnt         : std_logic_vector(0 to C_BRSTCNT_WIDTH-1);
signal cmd_cnt          : std_logic_vector(0 to C_BRSTCNT_WIDTH-1);
signal caslat_cnt       : std_logic_vector(0 to C_CASLATCNT_WIDTH-1);
signal tcaslat_minus1_i : std_logic;

signal twr_cnt_en       : std_logic;
signal twr_rst_i        : std_logic;

signal trc_cnt_en       : std_logic;
signal trrd_cnt_en      : std_logic;
signal tras_cnt_en      : std_logic;

signal ddr_brst_end_i   : std_logic;

signal gpcnt_load_delay : std_logic;
signal gpcnt_en_delay   : std_logic;
-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
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
-- assign output to internal signal
DDR_brst_end <= ddr_brst_end_i;
gpcnt_load_delay <= GPcnt_load after 1 ns;
gpcnt_en_delay <= GPcnt_en and not(GPcnt_load) after 1 ns;
-------------------------------------------------------------------------------
-- Instantiate the counters
-- All counters are down counters
-------------------------------------------------------------------------------
-- General Purpose Counter
GPCNT_I: ld_arith_reg
    generic map (C_ADD_SUB_NOT  => false,
                 C_REG_WIDTH    => C_GPCNT_WIDTH,
                 C_RESET_VALUE  => GPCNT_RST,
                 C_LD_WIDTH     => C_GPCNT_WIDTH,
                 C_LD_OFFSET    => 0,
                 C_AD_WIDTH     => 1,
                 C_AD_OFFSET    => 0
                )
    port map (   CK             => Clk,
                 RST            => Rst,
                 Q              => gp_cnt,   
                 LD             => GPcnt_data, 
                 AD             => "1",  
                 LOAD           => gpcnt_load_delay,
                 OP             => gpcnt_en_delay
             );

-- RC delay counter
trc_cnt_en <= not(Trc_load);

RCCNT_I: ld_arith_reg
    generic map (C_ADD_SUB_NOT  => false,
                 C_REG_WIDTH    => C_RCCNT_WIDTH,
                 C_RESET_VALUE  => RCCNT_RST,
                 C_LD_WIDTH     => C_RCCNT_WIDTH,
                 C_LD_OFFSET    => 0,
                 C_AD_WIDTH     => 1,
                 C_AD_OFFSET    => 0
                )
    port map (   CK             => Clk,
                 RST            => Rst,
                 Q              => rc_cnt,   
                 LD             => C_RCCNT, 
                 AD             => "1",  
                 LOAD           => Trc_load,
                 OP             => trc_cnt_en
             );

-- RRD delay counter
trrd_cnt_en <= not(Trrd_load);
RRDCNT_I: ld_arith_reg
    generic map (C_ADD_SUB_NOT  => false,
                 C_REG_WIDTH    => C_RRDCNT_WIDTH,
                 C_RESET_VALUE  => RRDCNT_RST,
                 C_LD_WIDTH     => C_RRDCNT_WIDTH,
                 C_LD_OFFSET    => 0,
                 C_AD_WIDTH     => 1,
                 C_AD_OFFSET    => 0
                )
    port map (   CK             => Clk,
                 RST            => Rst,
                 Q              => rrd_cnt,   
                 LD             => C_RRDCNT, 
                 AD             => "1",  
                 LOAD           => Trrd_load,
                 OP             => trrd_cnt_en
             );

-- RAS delay counter
tras_cnt_en <= not(Tras_load);
RASCNT_I: ld_arith_reg
    generic map (C_ADD_SUB_NOT  => false,
                 C_REG_WIDTH    => C_RASCNT_WIDTH,
                 C_RESET_VALUE  => RASCNT_RST,
                 C_LD_WIDTH     => C_RASCNT_WIDTH,
                 C_LD_OFFSET    => 0,
                 C_AD_WIDTH     => 1,
                 C_AD_OFFSET    => 0
                )
    port map (   CK             => Clk,
                 RST            => Rst,
                 Q              => ras_cnt,   
                 LD             => C_RASCNT, 
                 AD             => "1",  
                 LOAD           => Tras_load,
                 OP             => tras_cnt_en
             );

-- Refresh and powerup delay counter
refi_pwrup_load <= Tpwrup_load or Trefi_load;
refi_pwrup_cnten <= not(refi_pwrup_load);
refi_pwrup_data <= C_200CK_CNT when Tpwrup_load = '1' 
                    else C_REFICNT;

REFI_PWRUP_CNT_I: ld_arith_reg
    generic map (C_ADD_SUB_NOT  => false,
                 C_REG_WIDTH    => C_REFICNT_WIDTH,
                 C_RESET_VALUE  => C_200US_CNT,
                 C_LD_WIDTH     => C_REFICNT_WIDTH,
                 C_LD_OFFSET    => 0,
                 C_AD_WIDTH     => 1,
                 C_AD_OFFSET    => 0
                )
    port map (   CK             => Clk,
                 RST            => Rst,
                 Q              => refi_pwrup_cnt,   
                 LD             => refi_pwrup_data, 
                 AD             => "1",  
                 LOAD           => refi_pwrup_load,
                 OP             => refi_pwrup_cnten
             );

-- WR delay counter
-- counter is only needed if C_WRCNT > 0
WRCNT_GEN: if C_WRCNT > 0 generate
    twr_cnt_en <= not(twr_load) and Twr_cnten after 1 ns;
    twr_rst_i <= Twr_rst after 1 ns;
    WRCNT_I: ld_arith_reg
        generic map (C_ADD_SUB_NOT  => false,
                     C_REG_WIDTH    => C_WRCNT_WIDTH,
                     C_RESET_VALUE  => WRCNT_RST,
                     C_LD_WIDTH     => C_WRCNT_WIDTH,
                     C_LD_OFFSET    => 0,
                     C_AD_WIDTH     => 1,
                     C_AD_OFFSET    => 0
                    )
        port map (   CK             => Clk,
                     RST            => twr_rst_i,
                     Q              => wr_cnt,   
                     LD             => C_WRCNT, 
                     AD             => "1",  
                     LOAD           => Twr_load,
                     OP             => twr_cnt_en
                 );

    WRCNT_END_PROCESS: process(Clk)
    begin
        if Clk'event and Clk = '1' then
            if Rst = RESET_ACTIVE then
                Twr_end <= '0';
            elsif Twr_rst = '1' then
                Twr_end <= '0';
            elsif wr_cnt = WRCNT_END then
                Twr_end <= '1';
            end if;
        end if;
    end process WRCNT_END_PROCESS;
end generate WRCNT_GEN;

NOWRCNT_GEN: if C_WRCNT = 0 generate
    WRCNT_END_PROCESS: process(Clk)
    begin
        if Clk'event and Clk = '1' then
            if Rst = RESET_ACTIVE then
                Twr_end <= '0';
            elsif Twr_load = '1' then
                Twr_end <= '1';
            elsif Twr_rst = '1' then
                Twr_end <= '0';
            end if;
        end if;
    end process WRCNT_END_PROCESS;
end generate NOWRCNT_GEN;


CASLAT_GT_2_GEN: if C_CASLAT > 2 generate
    constant CASLAT_MINUS_ONE_END :std_logic_vector(0 to C_CASLATCNT_WIDTH-1):= 
                            conv_std_logic_vector(2,C_CASLATCNT_WIDTH);

    begin
    CASLATCNT_I: ld_arith_reg
        generic map (C_ADD_SUB_NOT  => false,
                     C_REG_WIDTH    => C_CASLATCNT_WIDTH,
                     C_RESET_VALUE  => CASLATCNT_RST,
                     C_LD_WIDTH     => C_CASLATCNT_WIDTH,
                     C_LD_OFFSET    => 0,
                     C_AD_WIDTH     => 1,
                     C_AD_OFFSET    => 0
                    )
        port map (   CK             => Clk,
                     RST            => Rst,
                     Q              => caslat_cnt,   
                     LD             => C_CASLATCNT, 
                     AD             => "1",  
                     LOAD           => tcaslat_load,
                     OP             => tcaslat_cnt_en
                 );

    CASLAT_MINUS1_PROCESS: process (Clk)
    begin
        if Clk'event and Clk='1' then
            if Rst = RESET_ACTIVE then
                tcaslat_minus1_i <= '0';
                Tcaslat_end    <= '0';
            else
                Tcaslat_end <= tcaslat_minus1_i;
                if caslat_cnt =  CASLAT_MINUS_ONE_END and Tcaslat_cnt_en = '1' then
                    tcaslat_minus1_i <= '1';
                else
                    tcaslat_minus1_i <= '0';
                end if;
            end if;
        end if;
    end process CASLAT_MINUS1_PROCESS;
end generate CASLAT_GT_2_GEN;

CASLAT_EQ_2_GEN: if C_CASLAT <= 2 generate
    CASLAT_MINUS1_PROCESS: process (Clk)
    begin
        if Clk'event and Clk='1' then
            if Rst = RESET_ACTIVE then
                tcaslat_minus1_i <= '0';
                Tcaslat_end    <= '0';
            else
                tcaslat_minus1_i <= Tcaslat_load;
                Tcaslat_end <= tcaslat_minus1_i;
            end if;
        end if;
    end process CASLAT_MINUS1_PROCESS;
end generate CASLAT_EQ_2_GEN;

-------------------------------------------------------------------------------
-- Generate the counter end signals
-- Generate signal when counter is at '1' so that the end signal can be
-- registered
-------------------------------------------------------------------------------
CNTR_END_PROCESS: process (Clk)
begin
    if Clk'event and Clk='1' then
        if Rst = RESET_ACTIVE then
            GPcnt_end           <= '0';
            Trc_end             <= '0';         
            Trrd_end            <= '0';         
            Tras_end            <= '0';                    
            Trefi_pwrup_end     <= '0';  
        else
          --  if GPcnt_data = ZERO_GPCNT or GPcnt_data=GPCNTR_END then
            if GPcnt_data = ZERO_GPCNT  then
                GPcnt_end <= gpcnt_load_delay;
            elsif gpcnt_load_delay='1' then 
                GPcnt_end <= '0';
            elsif  gp_cnt =  GPCNTR_END then
                GPcnt_end <= '1';
            end if;

            -- The Trc_end, Trrd_end, and Tras_end signals must
            -- stay asserted until the counters are reloaded.
            if Trc_load = '1' then
                Trc_end <= '0';
            elsif  rc_cnt =  RCCNT_END then
                Trc_end <= '1';
            end if;
            if Trrd_load = '1' then
                Trrd_end <= '0';
            elsif  rrd_cnt =  RRDCNT_END then
                Trrd_end <= '1';
            end if;
            if Tras_load = '1' then
                Tras_end <= '0';
            elsif  ras_cnt =  RASCNT_END then
                Tras_end <= '1';
            end if;
            -- the refresh timer interval end signal must
            -- stay asserted until the refresh can be serviced
            -- reset it once the load signal occurs again
            if refi_pwrup_load = '1' then
                Trefi_pwrup_end <= '0';
            elsif  refi_pwrup_cnt =  REFICNT_END then
                Trefi_pwrup_end <= '1';
            elsif Init_done = '0' then
                Trefi_pwrup_end <= '0';
            end if;
        end if;
    end if;
end process CNTR_END_PROCESS;    
            
BRSTCNT_EQ2_GEN: if C_DDR_BRST_SIZE <= 2 generate
    brst_cnt <= (others => '0');
    cmd_cnt <= (others => '0');
    DDR_BRST2_END_PROCESS: process (Clk)
        begin
            if Clk'event and Clk = '1' then
                if Rst = RESET_ACTIVE then
                    ddr_brst_end_i <= '0';
                    Tcmd_end <= '0';
                else
                    ddr_brst_end_i <= Tbrst_load;
                    Tcmd_end <= Tcmd_load after 1 nS;
                end if;
            end if;
    end process  DDR_BRST2_END_PROCESS;
end generate BRSTCNT_EQ2_GEN;

BRSTCNT_GT_2_GEN: if C_DDR_BRST_SIZE > 2 generate
-- BrstLen div 2 delay counter
BRSTLEN2_I: ld_arith_reg
    generic map (C_ADD_SUB_NOT  => false,
                 C_REG_WIDTH    => C_BRSTCNT_WIDTH,
                 C_RESET_VALUE  => BRSTCNT_RST,
                 C_LD_WIDTH     => C_BRSTCNT_WIDTH,
                 C_LD_OFFSET    => 0,
                 C_AD_WIDTH     => 1,
                 C_AD_OFFSET    => 0
                )
    port map (   CK             => Clk,
                 RST            => Rst,
                 Q              => brst_cnt,   
                 LD             => C_BRSTCNT,
                 AD             => "1",  
                 LOAD           => Tbrst_load, 
                 OP             => Tbrst_cnt_en
             );
-- Command delay counter
CMDCNT_I: ld_arith_reg
    generic map (C_ADD_SUB_NOT  => false,
                 C_REG_WIDTH    => C_BRSTCNT_WIDTH,
                 C_RESET_VALUE  => CMDCNT_RST,
                 C_LD_WIDTH     => C_BRSTCNT_WIDTH,
                 C_LD_OFFSET    => 0,
                 C_AD_WIDTH     => 1,
                 C_AD_OFFSET    => 0
                )
    port map (   CK             => Clk,
                 RST            => Rst,
                 Q              => cmd_cnt,   
                 LD             => C_CMDCNT,
                 AD             => "1",  
                 LOAD           => Tcmd_load, 
                 OP             => Tcmd_cnt_en
             );


    DDR_BRST_END_PROCESS: process (Clk)
    begin
        if Clk'event and Clk='1' then
            if Rst = RESET_ACTIVE then
                ddr_brst_end_i  <= '0';
                Tcmd_end         <= '0';
            else
               if  cmd_cnt =  CMDCNT_END and Tcmd_cnt_en = '1' then
                    Tcmd_end <= '1' after 1 ns;
               else
                    Tcmd_end <= '0'after 1 ns;
                end if;
                if  brst_cnt =  BRSTCNT_END and Tbrst_cnt_en = '1' then
                    ddr_brst_end_i <= '1';
                else
                    ddr_brst_end_i <= '0';
                end if;
            end if;
        end if;
    end process DDR_BRST_END_PROCESS; 
end generate BRSTCNT_GT_2_GEN;    





end imp;