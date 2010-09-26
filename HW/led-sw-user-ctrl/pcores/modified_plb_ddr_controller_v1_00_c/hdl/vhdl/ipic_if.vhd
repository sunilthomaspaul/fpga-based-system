-------------------------------------------------------------------------------
-- $Id: ipic_if.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- ipic_if.vhd - entity/architecture pair
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
-- Filename:        ipic_if.vhd
-- Version:         v1.00c
-- Description:     This file interfaces to the IPIC and sets signals for the
--                  command state machine. 
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
--   ALS           05/14/02    First Version
--
--   ALS           06/4/02
-- ^^^^^^
--  Fixed address bus assignments based on DDR data widths
-- ~~~~~~
--  ALS            06/06/02
-- ^^^^^^
--  Added reset of pendrdreq and pendwrreq when CS negates. Qualified read_op
--  and write_op with RNW.
-- ~~~~~~
--  ALS            06/11/02
-- ^^^^^^
--  Added assertion of RETRY while CS=1 and INIT_DONE=0.
-- ~~~~~~
--  ALS           06/26/03
-- ^^^^^^
--  Added IP2Bus_Busy which gets asserted during initialization. No longer
--  assert ErrAck during initialization. Added IP2Bus_AddrAck. Assert ToutSup
--  for all transactions.
-- ~~~~~~
--  ALS           07/08/03
-- ^^^^^^
--  Removed all unused signals and ports.
-- ~~~~~~
--  ALS       07/15/03
-- ^^^^^^
--  Changed ToutSup from being asserted anytime Bus2IP_CS asserts to being asserted
--  in most states except in PRECHARGE when waiting for read_data_done. This is
--  to insure that if read_data_done doesn't assert for some reason, the bus will
--  not be hung and an error will be generated.
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
--      C_DDR_AWIDTH        -- DDR address width 
--      C_DDR_DWIDTH        -- DDR data width
--      C_DDR_COL_AWIDTH    -- DDR column address width
--      C_DDR_BANK_AWIDTH   -- DDR bank address width
--      C_IPIF_DWIDTH       -- IPIF data width
--      C_IPIF_AWIDTH       -- IPIF address width
--      C_INCLUDE_BURSTS    -- support bus burst transactions
--
-- Definition of Ports:
--      Bus2IP_CS           -- indicates DDR SDRAM controller has been selected
--      Bus2IP_RNW          -- read/write
--      Bus2IP_Addr         -- address
--      Bus2IP_Burst        -- burst
--      Bus2IP_Data         -- processor bus data
--      Bus2IP_BE           -- byte enables
--      Bus2IP_RdReq        -- read req
--      Bus2IP_WrReq        -- write req
--      IP2Bus_ErrAck       -- error acknowledge
--      IP2Bus_Retry        -- retry
--      IP2Bus_Busy         -- IP is busy, re-arbitrate transactions
--      IP2Bus_AddrAck      -- IP address acknowledge
--      IP2Bus_WrAck        -- write acknowledge
--      IP2Bus_RdAck        -- read acknowledge
--      IP2Bus_ToutSup      -- suppress timeout counter
--      IP2Bus_data         -- read data from DDR
--      WrAck               -- write acknowledge
--      RdAck               -- read acknowledge
--      ToutSup         -- timeout suppress
--      Read_data           -- data read from DDR
--      Retry               -- retry transaction
--      Init_done           -- initialization is complete
--      IPIC_wrdata         -- data to be written to DDR
--      IPIC_be             -- byte enables from bus
--      Burst               -- bus burst transaction
--      Reset_pendrdreq     -- reset pending read request
--      Reset_pendwrreq     -- reset pending write request
--      Row_addr            -- row address
--      Col_addr            -- column address
--      Bank_addr           -- bank address
--      Pend_rdreq          -- pending read request
--      Pend_wrreq          -- pending write request
--      Same_row            -- pending transaction is for the same row
--      Same_bank           -- pending transaction is for the same bank
--
--    -- Clocks and reset
--      Clk                 
--      Rst               
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity ipic_if is
  generic ( C_DDR_AWIDTH        : integer;
            C_DDR_DWIDTH        : integer;
            C_DDR_COL_AWIDTH    : integer;
            C_DDR_BANK_AWIDTH   : integer;
            C_IPIF_AWIDTH       : integer;
            C_IPIF_DWIDTH       : integer;
            C_INCLUDE_BURSTS    : integer);
  port (
        Bus2IP_CS               : in  std_logic;
        Bus2IP_RNW              : in  std_logic;
        Bus2IP_Addr             : in  std_logic_vector(0 to C_IPIF_AWIDTH-1);
        Bus2IP_Burst            : in  std_logic;
        Bus2IP_Data             : in  std_logic_vector(0 to C_IPIF_DWIDTH-1);
        Bus2IP_BE               : in  std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
        Bus2IP_RdReq            : in  std_logic;
        Bus2IP_WrReq            : in  std_logic;
        IP2Bus_ErrAck           : out std_logic;
        IP2Bus_Retry            : out std_logic;
        IP2Bus_Busy             : out std_logic;
        IP2Bus_AddrAck          : out std_logic;
        IP2Bus_WrAck            : out std_logic;
        IP2Bus_RdAck            : out std_logic;
        IP2Bus_ToutSup          : out std_logic;
        IP2Bus_data             : out std_logic_vector(0 to C_IPIF_DWIDTH-1);
        Wr_AddrAck              : in  std_logic;
        Rd_AddrAck              : in  std_logic;
        WrAck                   : in  std_logic;
        RdAck                   : in  std_logic;
        ToutSup             : in  std_logic;
        Read_data               : in  std_logic_vector(0 to C_IPIF_DWIDTH-1);
        Retry                   : in  std_logic;
        Init_done               : in  std_logic;
        IPIC_wrdata             : out std_logic_vector(0 to C_IPIF_DWIDTH-1);
        IPIC_be                 : out std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
        Burst                   : out std_logic;
        Reset_pendrdreq         : in  std_logic;
        Reset_pendwrreq         : in  std_logic; 
        Row_addr                : out std_logic_vector(0 to C_DDR_AWIDTH-1);
        Col_addr                : out std_logic_vector(0 to C_DDR_AWIDTH-1);
        Bank_addr               : out std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        Pend_rdreq              : out std_logic;
        Pend_wrreq              : out std_logic;
        Same_row                : out std_logic;
        Same_bank               : out std_logic;
        Clk                     : in  std_logic;
        Rst                     : in  std_logic
      );
end entity ipic_if;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of ipic_if is

-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
-- calculate the unused address bits based on ddr data width
-- this is then used to calculate the address bit slices for the bank, row, and
-- column addresses
constant ADDR_OFFSET        : integer := log2(C_DDR_DWIDTH/8);
constant COLADDR_STARTBIT   : integer := C_IPIF_AWIDTH - (C_DDR_COL_AWIDTH+ADDR_OFFSET);
constant COLADDR_ENDBIT     : integer := COLADDR_STARTBIT + C_DDR_COL_AWIDTH-2; -- A0 not used
constant ROWADDR_STARTBIT   : integer := COLADDR_STARTBIT - C_DDR_AWIDTH;
constant ROWADDR_ENDBIT     : integer := ROWADDR_STARTBIT + C_DDR_AWIDTH-1;
constant BANKADDR_STARTBIT  : integer := ROWADDR_STARTBIT - C_DDR_BANK_AWIDTH;
constant BANKADDR_ENDBIT    : integer := BANKADDR_STARTBIT + C_DDR_BANK_AWIDTH-1;

constant ZERO_COL_PAD       : std_logic_vector(0 to C_DDR_AWIDTH-C_DDR_COL_AWIDTH-1)
                                := (others => '0');
-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
-- internal versions of output signals
signal row_addr_i           : std_logic_vector(0 to C_DDR_AWIDTH-1);
signal bank_addr_i          : std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
signal same_row_i           : std_logic;
signal same_bank_i          : std_logic;
signal ip2bus_retry_i       : std_logic;
signal pend_wrreq_i         : std_logic;
signal pend_rdreq_i         : std_logic;

-- Same_row and Same_bank signals
signal last_row_lsb         : std_logic;
signal last_bank_lsb        : std_logic;

-- Xfer qualifiers  rising edge detect signals
signal cs_d1, cs_re         : std_logic;
signal wrreq_d1, wrreq_re   : std_logic;
signal rdreq_d1, rdreq_re   : std_logic;

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------

 
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  -- architecture imp
-- assign output signals
Row_addr <= row_addr_i;
Bank_addr <= bank_addr_i;
Same_row <= same_row_i;
Same_bank <= same_bank_i;
IP2Bus_Retry <= ip2bus_retry_i;
Pend_rdreq <= pend_rdreq_i;
Pend_wrreq <= pend_wrreq_i;
Burst <= Bus2IP_Burst;
            
-- determine bank, row, and column addresses
bank_addr_i <= Bus2IP_Addr(BANKADDR_STARTBIT to BANKADDR_ENDBIT);
row_addr_i  <= Bus2IP_Addr(ROWADDR_STARTBIT to ROWADDR_ENDBIT);
Col_addr    <= ZERO_COL_PAD & Bus2IP_Addr(COLADDR_STARTBIT to COLADDR_ENDBIT) &'0';

-- when an ACK is received, register the bank address LSB and row address LSB
-- then compare to current bank address LSB and row address LSB to see if in
-- same row and same bank

LAST_BNKRW_PROCESS: process(Clk)
begin
    if Clk'event and Clk = '1' then
        if Rst = RESET_ACTIVE then
            last_row_lsb <= '0';
            last_bank_lsb <= '0';
        else
            last_row_lsb <= row_addr_i(C_DDR_AWIDTH-1);
            last_bank_lsb <= bank_addr_i(C_DDR_BANK_AWIDTH-1);
        end if;
    end if;
end process LAST_BNKRW_PROCESS;

same_row_i <= '1' when last_row_lsb = row_addr_i(C_DDR_AWIDTH-1)
            else '0';
same_bank_i <= '1' when last_bank_lsb = bank_addr_i(C_DDR_BANK_AWIDTH-1)
            else '0';

XFERSIGS_RE_PROCESS: process(Clk)
begin
    if Clk'event and Clk='1' then
        if Rst=RESET_ACTIVE then
            cs_d1       <= '0';
            wrreq_d1    <= '0';
            rdreq_d1    <= '0';
        else
            cs_d1       <= Bus2IP_CS;
            wrreq_d1    <= Bus2IP_WrReq;
            rdreq_d1    <= Bus2IP_RdReq;
        end if;
    end if;
end process XFERSIGS_RE_PROCESS; 

cs_re <= Bus2IP_CS and not(cs_d1);
wrreq_re <= Bus2IP_WrReq and not(wrreq_d1);
rdreq_re <= Bus2IP_RdReq and not(rdreq_d1);

-- generate RdAck, WrAck, ErrAck and Retry signals
IP2Bus_AddrAck <= Rd_addrAck or Wr_addrAck;
IP2Bus_RdAck <= RdAck;
IP2Bus_data <= Read_data;
IP2Bus_WrAck <= (WrAck and Bus2IP_CS);
-- ErrAck is set to ground
IP2Bus_ErrAck <= '0'; 

IPIC_wrdata <= Bus2IP_data;
IPIC_be <= Bus2IP_BE;    

-- 
TOUTSUP_PROCESS: process(Clk)
begin
    if Clk'event and Clk = '1' then
        if Rst = RESET_ACTIVE  then
            IP2Bus_ToutSup <= '0';
        else
            IP2Bus_ToutSup <= ToutSup;
        end if;
    end if;
end process TOUTSUP_PROCESS;

--
RETRY_PROCESS: process(Clk)
begin
    if Clk'event and Clk = '1' then
        if Rst = RESET_ACTIVE  then
            ip2bus_retry_i <= '0';
        else
            ip2bus_retry_i <= Retry or not(Init_done);
        end if;
    end if;
end process RETRY_PROCESS;

BUSY_PROCESS: process(Clk)
begin
    if Clk'event and Clk = '1' then
        if Rst = RESET_ACTIVE then
            IP2Bus_Busy <= '0';
        else
            IP2Bus_Busy <= Retry or not(Init_done);
        end if;
    end if;
end process BUSY_PROCESS;



-- determine pending read and write requests
PEND_REQ_PROCESS: process(Clk)
begin
    if Clk'event and Clk='1' then
        if Rst = RESET_ACTIVE then
           pend_rdreq_i <= '0';
           pend_wrreq_i <= '0';
        else
           if Reset_pendrdreq = RESET_ACTIVE or Bus2IP_CS = '0' then
               pend_rdreq_i <= '0';
           elsif rdreq_re = '1'  then
               pend_rdreq_i <= '1';
           end if;
           if Reset_pendwrreq = RESET_ACTIVE or Bus2IP_CS = '0' then
               pend_wrreq_i <= '0';
           elsif wrreq_re = '1' then
               pend_wrreq_i <= '1';
           end if;
        end if;
    end if;
end process PEND_REQ_PROCESS;



end imp;

