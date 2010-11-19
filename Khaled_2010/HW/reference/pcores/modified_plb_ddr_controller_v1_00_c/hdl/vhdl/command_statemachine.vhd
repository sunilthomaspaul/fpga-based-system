-------------------------------------------------------------------------------
-- $Id: command_statemachine.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- command_statemachine.vhd - entity/architecture pair
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
-- Filename:        command_statemachine.vhd
-- Version:         v1.00c
-- Description:     This state machine controls the application of commands
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
--  ALS             06/04/02
-- ^^^^^^
--  Simplified state machine by removing READ_DATA and WRITE_DATA states. Since
--  READ_CMD and WRITE_CMD states issue the commands, there is no need for the
--  READ_DATA and WRITE_DATA states.
-- ~~~~~~
--  ALS             06/06/02
-- ^^^^^^
--  In states that assert RETRY, must wait for Bus2IP_CS to negate before going
--  back to IDLE so that the bus has had time to react to the retry.
-- ~~~~~~
--  ALS             06/11/02
-- ^^^^^^
--  Generate DQ_OE_CMB during WRITE_CMD state. This will be used in the IOB register
--  to assert DQT. DQ_OE_CMB will be registered by falling edge register and then
--  used to reset the DQS IOB register and used in the IOB register to assert DQST.
--  DQS and DQST are clocked by CLK90, so the falling edge pipe register helps
--  the path delay. 
-- ~~~~~~
--  ALS             06/20/02
-- ^^^^^^
--  Fixed WAIT_TRAS state - Write op and read op may be already negated. Created
--  signals write_state and read state instead.
-- ~~~~~~
--  ALS             07/16/02
-- ^^^^^^
--  Major cleanup - with this version of IPIF, can't have a pend_wrreq or pend_rdreq
--  during a read or write command, so take all of this extra code out. Also, need
--  to make changes to support IPIF bursts (PLB)
-- ~~~~~~
--  ALS             05/01/03
-- ^^^^^^
--  Problem with BUS2IP_CS still being asserted after data cycle finished. This 
--  caused state machine to go to ACT_CMD state to activate the row. However, 
--  this state didn't re-examine BUS2IP_CS until Trcd expired, so the case existed
--  where BUS2IP_CS could negate and re-assert for the next transaction while
--  in the ACT_CMD state causing the correct row to not be activated and data
--  to be accessed from the previous row. 
--  Modified ACT_CMD state to examine BUS2IP_CS every clock.
-- ~~~~~~
--  ALS             06/25/03
-- ^^^^^^
--  Cleaned up code - added generation of addrAck
--  ALS             06/27/03
-- ^^^^^^
--  Made DQS_OE, DQS_RST, and DQS_SETRST vectors so that there is an individual 
--  enable for each DQS line. This reduces the fan-out on this signal and makes 
--  the CLK - CLK90 timing easier to meet. Instantiated primitives so that 
--  the synthesis tools would not optimize the redundant registers away.
-- ~~~~~~
--  ALS             07/01/03
-- ^^^^^^
--  Command state machine now uses RdReq instead of Burst to correctly end the 
--  read cycle. Precharge is now issued before all of the data is read as allowed
--  in the data sheet. Read_data_done is tested to be asserted before leaving PRECHARGE
-- ~~~~~~
-- ALS              07/15/03
-- ^^^^^^
--  Will assert TOUTSUP in all states except IDLE and PRECHARGE. The PRECHARGE
--  state waits for Read_data_done, therefore, will want the timeout counter
--  to be activated during this state to report an error if the state machine
--  stays in the PRECHARGE state. Also, modified code to generate "read_pause"
--  which signals the data state machine that the read transaction has been
--  interrupted to service a refresh or because a row or bank has rolled over.
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

library unisim;
use unisim.vcomponents.all;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.proc_common_pkg.all;
use modified_plb_ddr_controller_v1_00_c.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_DDR_AWIDTH        -- DDR address width     
--      C_DDR_COL_AWIDTH    -- DDR column address width 
--      C_DDR_BANK_AWIDTH   -- DDR bank address width
--      C_MRDCNT            -- Tmrd clock cycles         
--      C_RFCCNT            -- Trfc clock cycles
--      C_RCDCNT            -- Trcd clock cycles        
--      C_RPCNT             -- Trp clock cycles         
--      C_GP_CNTR_WIDTH     -- Width of general purpose counter 
--      C_OPB_BUS           -- Processor bus is OPB
--      C_PLB_BUS           -- Processor bus is PLB
--
-- Definition of Ports:
--  -- IPIC interface
--      -- inputs
--      Bus2IP_CS           -- indicates DDR SDRAM controller has been selected
--      Burst               -- processor burst transaction
--      Row_addr            -- row address
--      Col_addr            -- column address
--      Bank_addr           -- bank address
--      Bus2IP_RdReq        -- read request
--      Bus2IP_WrReq        -- write request
--      Pend_rdreq          -- pending read request
--      Pend_wrreq          -- pending write request
--      Same_row            -- access is within the same row
--      Same_bank           -- access is within the same bank
--      --outputs
--      Read_dqs_ce         -- clock enable to read dqs 
--      Retry               -- retry signal
--      Rd_AddrAck          -- read cycle address acknowledge
--      Wr_AddrAck          -- write cycle address acknowledge
--      Reset_pendrdreq     -- reset pending read request
--      Reset_pendwrreq     -- reset pending write request
--      ToutSup             -- suppress timeout counter
--
--  -- Init SM interface
--      --inputs
--      Refresh             -- issue refresh command
--      Precharge           -- issue precharge command
--      Load_mr             -- issue load_mr command
--      Register_data       -- data for the Mode or Extended Mode registers
--      Register_sel        -- selects either the Mode or Extended Mode register
--      Init_done           -- indicates initialization sequence is complete
--      -- outputs
--      CMD_idle            -- output indicating command sm is in IDLE state
--
--  -- Data SM interface
--      -- inputs
--      Read_data_done      -- done with read data reception
--      Rst_pend_wr         -- reset pending write
--      Rst_pend_rd         -- reset pending read
--      -- outputs
--      Read_data_done_rst  -- reset Read_data_done
--      Pend_write          -- start transmitting write data
--      Pend_read           -- start receiving read data
--      Read_pause          -- read transfer is interrupted
--
--  -- Counters interface
--      -- inputs 
--      Trefi_end           -- time to issue a refresh command
--      Trc_end             -- end of active row to active row delay
--      Trrd_end            -- end of active row to active row delay
--      Tras_end            -- end of active to precharge delay
--      Twr_end             -- end of write to precharge delay
--      GPcnt_end           -- general purpose timer ended
--      Tcmd_end            -- brst len/2 counter ended
--
--      -- outputs
--      Twr_rst             -- reset Twr counter
--      Tcmd_load           -- load Tcmd counter
--      Tcmd_cnt_en         -- enable Tcmd counter
--      Trefi_load          -- re-load refresh interval timer
--      Trc_load            -- load active row to active row timer
--      Trrd_load           -- load active row to active row timer
--      Tras_load           -- load active to precharge timer
--      GPcnt_load          -- load the general purpose timer
--      GPcnt_en            -- enable the general purpose timer
--      GPcnt_data          -- count to load into the general purpose timer
--
--  -- IOB Register Interface
--      DDR_RASn            -- Row address strobe
--      DDR_CASn            -- Column address strobe
--      DDR_WEn             -- Write enable
--      DDR_Addr            -- address
--      DDR_BankAddr        -- bank address
--      DQ_oe_cmb           -- combinational DQ output enable   
--      DQS_oe              -- registered DQS output enable
--      DQS_rst             -- reset DQS
--      DQS_setrst          -- DQS set/reset
--
--    -- Clocks and reset
--      Clk                 
--      Rst               
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity command_statemachine is
  generic ( C_DDR_AWIDTH        : integer;
            C_DDR_DWIDTH        : integer;
            C_DDR_COL_AWIDTH    : integer;
            C_DDR_BANK_AWIDTH   : integer;
            C_REG_DIMM          : integer;
            C_MRDCNT            : std_logic_vector;
            C_RFCCNT            : std_logic_vector;
            C_RCDCNT            : std_logic_vector;
            C_RPCNT             : std_logic_vector;
            C_GP_CNTR_WIDTH     : integer;
            C_OPB_BUS           : integer  := 0;
            C_PLB_BUS           : integer  := 1
            );
  port (
    -- IPIC 
        Bus2IP_CS               : in  std_logic;
        Burst                   : in  std_logic;
        Row_addr                : in  std_logic_vector(0 to C_DDR_AWIDTH-1);
        Col_addr                : in  std_logic_vector(0 to C_DDR_AWIDTH-1);
        Bank_addr               : in  std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        Bus2IP_RdReq            : in  std_logic;
        Bus2IP_WrReq            : in  std_logic;
        Pend_rdreq              : in  std_logic;
        Pend_wrreq              : in  std_logic;
        Same_row                : in  std_logic;
        Same_bank               : in  std_logic;
        Read_dqs_ce             : out std_logic;
        Retry                   : out std_logic;
        Rd_AddrAck              : out std_logic;
        Wr_AddrAck              : out std_logic;
        Reset_pendrdreq         : out std_logic;
        Reset_pendwrreq         : out std_logic;
        ToutSup                 : out std_logic;
        
    -- Init SM interface
        Refresh                 : in  std_logic;
        Precharge               : in  std_logic;
        Load_mr                 : in  std_logic;
        Register_data           : in  std_logic_vector(0 to C_DDR_AWIDTH-1);
        Register_sel            : in  std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        Init_done               : in  std_logic;
        Cmd_done                : out std_logic;        
    
    -- Data SM interface
        Read_data_done          : in  std_logic;
        Read_data_done_rst      : out std_logic;
        Pend_write              : out std_logic;
        Rst_pend_wr             : in  std_logic;
        Pend_read               : out std_logic;
        Rst_pend_rd             : in  std_logic;
        Read_pause              : out std_logic;
    
    -- Counters interface
        Trefi_end               : in  std_logic;       
        Trc_end                 : in  std_logic;
        Trrd_end                : in  std_logic;
        Tras_end                : in  std_logic;
        Twr_end                 : in  std_logic;
        GPcnt_end               : in  std_logic;
        Tcmd_end                : in  std_logic;
        Twr_rst                 : out std_logic;
        Tcmd_load               : out std_logic;
        Tcmd_cnt_en             : out std_logic;
        Trefi_load              : out std_logic;
        Trc_load                : out std_logic;
        Trrd_load               : out std_logic;
        Tras_load               : out std_logic;
        GPcnt_load              : out std_logic;
        GPcnt_en                : out std_logic;
        GPcnt_data              : out std_logic_vector(0 to C_GP_CNTR_WIDTH-1);
    
    -- IOB Register interface
        DDR_RASn                : out std_logic;
        DDR_CASn                : out std_logic;
        DDR_WEn                 : out std_logic;
        DDR_Addr                : out std_logic_vector(0 to C_DDR_AWIDTH-1);
        DDR_BankAddr            : out std_logic_vector(0 to C_DDR_BANK_AWIDTH-1);
        DQ_oe_cmb               : out std_logic;
        DQS_oe                  : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DQS_rst                 : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
        DQS_setrst              : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
    
      -- Clocks and reset
        Clk                     : in  std_logic;
        Rst                     : in  std_logic
      );
end entity command_statemachine;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of command_statemachine is

-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
-- setup constants for the DDR command (RCW = Ras, Cas, Wen)
-- RAS = bit 0
-- CAS = bit 1
-- WEN = bit 2
constant NOP_RCW        : std_logic_vector(0 to 2) := "111";
constant ACTIVE_RCW     : std_logic_vector(0 to 2) := "011";
constant READ_RCW       : std_logic_vector(0 to 2) := "101";
constant WRITE_RCW      : std_logic_vector(0 to 2) := "100";
constant PRECHARGE_RCW  : std_logic_vector(0 to 2) := "010";
constant REFRESH_RCW    : std_logic_vector(0 to 2) := "001";
constant LOAD_MR_RCW    : std_logic_vector(0 to 2) := "000";

-- Precharge command has data value
constant PRECHARGE_DATA : std_logic_vector(0 to C_DDR_AWIDTH-1) := (others => '1');


-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
type COMMAND_STATE_TYPE is (IDLE, LOAD_MR_CMD, REFRESH_CMD, ACT_CMD, READ_CMD,
                         WRITE_CMD, WAIT_TWR, WAIT_TRAS,  
                         PRECHARGE_CMD, WAIT_TRRD);
signal cmdsm_ns         : COMMAND_STATE_TYPE;
signal cmdsm_cs         : COMMAND_STATE_TYPE;

-- combinational versions of registered outputs


-- other needed signals
signal pend_req             : std_logic;
signal pend_read_cmb        : std_logic;
signal pend_read_reg        : std_logic;
signal pend_write_cmb       : std_logic;
signal pend_write_reg       : std_logic;
signal RCW_cmd              : std_logic_vector(0 to 2);
signal cmd_done_cmb         : std_logic;
signal reset_pendwrreq_cmb  : std_logic;
signal reset_pendrdreq_cmb  : std_logic;
signal read_data_done_rst_cmb    : std_logic;
signal read_pause_cmb       : std_logic;
signal read_pause_i         : std_logic;

signal dq_oe_cmb_i          : std_logic;
signal dqs_oe_cmb           : std_logic;
signal dqs_oe_reg           : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal dqs_rst_cmb          : std_logic;
signal dqs_rst_reg          : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal dqs_setrst_cmb       : std_logic;
signal dqs_setrst_reg       : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal rst_write_state      : std_logic;
signal rst_read_state       : std_logic;
signal read_state_cmb       : std_logic;
signal write_state_cmb      : std_logic;
signal read_state           : std_logic;
signal write_state          : std_logic;

signal bus2ip_cs_d1         : std_logic;
signal bus2ip_cs_re         : std_logic;
signal bus2ip_cs_re_reg     : std_logic;
signal bus2ip_cs_re_reg_rst : std_logic;

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  -- architecture imp

-- determine pendreq signal
pend_req <= Pend_rdreq or Pend_wrreq;

-- assign outputs
DDR_RASn <= RCW_cmd(0) after 1 ns;
DDR_CASn <= RCW_cmd(1) after 1 ns;
DDR_WEn  <= RCW_cmd(2) after 1 ns;
Pend_read <= pend_read_cmb;
Pend_write <= pend_write_reg;
Read_pause <= read_pause_i;

-- use falling edge to clock dqs_oe, dqs_rst, and dqs_setrst
-- 1 bit for each DQS
DQS_OE_SETRST_GEN: for i in 0 to C_DDR_DWIDTH/8-1 generate
 begin
    DQS_OE_REG_I: FDS_1
      port map (
        Q => DQS_oe_reg(i),     --[out]
        C => Clk,           --[in]
        D => dqs_oe_cmb,    --[in]
        S => Rst            --[in]
      );
    DQS_RST_I: FDR_1
      port map (
        Q => DQS_rst_reg(i),    --[out]
        C => Clk,           --[in]
        D => dqs_rst_cmb,   --[in]
        R => Rst            --[in]
      );
    DQS_SETRST_I: FDS_1
      port map (
        Q => DQS_setrst_reg(i), --[out]
        C => Clk,           --[in]
        D => dqs_setrst_cmb, --[in]
        S => Rst            --[in]
      );
end generate DQS_OE_SETRST_GEN;

-- Determine whether REG_DIMM - if so, register delay all associated output enable signals
-- by one clock to account for the registering of control/address signals in the DIMM
-- if not REG_DIMM, output signals
OE_PIPE_GEN: if C_REG_DIMM = 1 generate
    OE_REG: process(Clk)
    begin
        if Clk'event and Clk='1' then
            if Rst=RESET_ACTIVE then
                DQ_OE_cmb <= '1';
            else
                DQ_OE_cmb <= dq_oe_cmb_i;
            end if;
         end if;
    end process OE_REG;
    -- use falling edge to clock dqs_oe, dqs_rst, and dqs_setrst
    -- 1 bit for each DQS
    DQS_OE_SETRST_REG_GEN: for i in 0 to C_DDR_DWIDTH/8-1 generate
     begin
        DQS_OE_REG_I: FDS_1
          port map (
            Q => DQS_oe(i),     --[out]
            C => Clk,           --[in]
            D => dqs_oe_reg(i), --[in]
            S => Rst            --[in]
          );
        DQS_RST_I: FDR_1
          port map (
            Q => DQS_rst(i),    --[out]
            C => Clk,           --[in]
            D => dqs_rst_reg(i),--[in]
            R => Rst            --[in]
          );
        DQS_SETRST_I: FDS_1
          port map (
            Q => DQS_setrst(i), --[out]
            C => Clk,           --[in]
            D => dqs_setrst_reg(i), --[in]
            S => Rst            --[in]
          );
    end generate DQS_OE_SETRST_REG_GEN;
end generate OE_PIPE_GEN;

OE_NOPIPE_GEN: if C_REG_DIMM=0 generate
    DQ_oe_cmb <= dq_oe_cmb_i;
    DQS_oe <= dqs_oe_reg;
    DQS_rst <= dqs_rst_reg;
    DQS_setrst <= dqs_setrst_reg;
end generate OE_NOPIPE_GEN;

--------------------------------------------------------------------------------
-- Command State Machine
-- CMDSM_CMB:     combinational process for determining next state
-- CMDSM_REG:     state machine registers
--------------------------------------------------------------------------------
    -- Combinational process
CMDSM_CMB: process (Bus2IP_CS, Row_addr, 
                    Col_addr, Bank_addr, Refresh, Precharge, Load_mr, 
                    Register_data, Register_sel, Read_data_done, Trefi_end, Trrd_end,  
                    Tras_end, Twr_end, GPcnt_end, Burst, Pend_rdreq,  
                    Pend_wrreq, Same_row, Same_bank, Tcmd_end, Trc_end, 
                    pend_read_reg, pend_write_reg, cmdsm_cs, write_state, 
                    read_state, Init_done,
                    Bus2IP_RdReq, read_pause_i)

begin
-- Set default values
-- Note: the DDR interface signals will be registered in IOB registers for better timing
RCW_cmd <= (others => '1');
DDR_Addr <= (others => '0');
DDR_BankAddr <= (others => '0');
cmd_done_cmb <= '0';       
pend_write_cmb <=  '0';
pend_read_cmb <= '0';
Tcmd_load <= '0';
Tcmd_cnt_en <= '0';
Trefi_load <= '0';
Trc_load <= '0';
Trrd_load <= '0';
Tras_load <= '0';
GPcnt_en <= '0';
GPcnt_load <= '0';
GPcnt_data <= (others => '1');
cmdsm_ns <= cmdsm_cs;
Retry <= '0';
reset_pendrdreq_cmb <= '0';
reset_pendwrreq_cmb <= '0';
dq_oe_cmb_i <= '1';
dqs_oe_cmb  <= '1';
dqs_setrst_cmb <= '0';
dqs_rst_cmb <= '0';
rst_read_state <= '0';
rst_write_state <= '0';
write_state_cmb <= write_state;
read_state_cmb <= read_state;
Rd_AddrAck <= '0';
Wr_AddrAck <= '0';
Twr_rst <= '0';
read_data_done_rst_cmb <= '0';
ToutSup <= '0';
read_pause_cmb <= read_pause_i;

case cmdsm_cs is
-------------------------- IDLE --------------------------
    when IDLE =>
        -- reset state
        Twr_rst <= '1';
        rst_read_state <= '1';
        rst_write_state <= '1';
        -- while in IDLE, drive the DQS lines to the pullup/pulldown value
        dqs_oe_cmb <= '1';
        dqs_setrst_cmb <= '1';
        -- setup the command so that once its registered,
        -- it'll line up with the state
        if Refresh='1' or 
            (init_done = '1' and Trefi_end='1') then
            cmdsm_ns <= REFRESH_CMD;
            RCW_cmd <= REFRESH_RCW;
            -- reload the refresh interval timer
            Trefi_load <= '1';
            -- load the general purpose counter to time refresh
            -- command to another command delay
            GPcnt_load <= '1';
            GPcnt_data <= C_RFCCNT;
            -- assert Retry
            Retry <= '1'; 
        elsif Bus2IP_CS = '1' and Init_done = '1' then
            -- prepare for ACTIVE command
            cmdsm_ns <= ACT_CMD;
            RCW_cmd <= ACTIVE_RCW;
            DDR_Addr <= Row_addr;
            DDR_BankAddr <= Bank_addr;
            -- load the general purpose counter to time Trcd
            GPcnt_load <= '1';
            GPcnt_data <= C_RCDCNT;
            -- load the RAS counter to time Tras
            Tras_load <= '1';
            -- load the RRD counter to time Trrd
            Trrd_load <= '1';
            -- load the RC counter to time Trc
            Trc_load <= '1';
        elsif Load_mr = '1' then
            cmdsm_ns <= LOAD_MR_CMD;
            RCW_cmd <= LOAD_MR_RCW;
            DDR_Addr <= Register_data;
            DDR_BankAddr <= Register_sel;
            GPcnt_load <= '1';
            GPcnt_data <= C_MRDCNT;
        elsif Precharge = '1' then
            cmdsm_ns <= PRECHARGE_CMD;
            RCW_cmd <= PRECHARGE_RCW;
            DDR_Addr <= PRECHARGE_DATA;
            GPcnt_load <= '1';
            GPcnt_data <= C_RPCNT;
        end if;        
-------------------------- REFRESH_CMD --------------------------
    when REFRESH_CMD =>
        -- start timing refresh command cycle. 
        GPcnt_en <= '1';
        
        -- assert Retry
        Retry <= '1'; 
        
        -- assert ToutSup
        ToutSup <= '1';
        
        if C_OPB_BUS = 1 then
            -- When timer expires and Bus2IP_CS=0, 
            -- return to IDLE state 
            -- must wait for Bus2IP_CS to negate so that the bus
            -- has reacted to the retry
            if GPcnt_end = '1' and Bus2IP_CS = '0' then
                cmd_done_cmb <= '1';
                cmdsm_ns <= IDLE;
            end if;
        end if;
        if C_PLB_BUS = 1 then
            -- when timer expires, return to IDLE state if CS is negated
            -- Data phase can't abort on PLB, so if CS is still valid
            -- go to ACT state
            if GPcnt_end = '1'then
                cmd_done_cmb <= '1';
                
                if Bus2IP_CS = '1' then
                    cmdsm_ns <= ACT_CMD;
                    RCW_cmd <= ACTIVE_RCW;
                    DDR_Addr <= Row_addr;
                    DDR_BankAddr <= Bank_addr;
                    -- load the general purpose counter to time Trcd
                    GPcnt_load <= '1';
                    GPcnt_data <= C_RCDCNT;
                    -- load the RAS counter to time Tras
                    Tras_load <= '1';
                    -- load the RRD counter to time Trrd
                    Trrd_load <= '1';
                    -- load the RC counter to time Trc
                    Trc_load <= '1';
                else
                    cmdsm_ns <= IDLE;
                end if;
            end if;
        end if;

-------------------------- LOAD_MR_CMD --------------------------
    when LOAD_MR_CMD =>
        -- assert the count enable to start timing LOAD_MR command
        -- cycle.
        GPcnt_en <= '1';
        Retry <= '1';
        -- assert ToutSup
        ToutSup <= '1';
        
        if C_OPB_BUS = 1 then
            -- When timer expires and Bus2IP_CS=0, 
            -- return to IDLE state 
            -- must wait for Bus2IP_CS to negate so that the bus
            -- has reacted to the retry
            if GPcnt_end = '1' and Bus2IP_CS = '0' then
                cmd_done_cmb <= '1';
                cmdsm_ns <= IDLE;
            end if;
        end if;
        if C_PLB_BUS = 1 then
            -- when timer expires, return to IDLE state
            -- Data phase can't abort on PLB, so CS is still valid
            if GPcnt_end = '1'then
                cmd_done_cmb <= '1';
                cmdsm_ns <= IDLE;
            end if;
        end if;
           
-------------------------- ACT_CMD --------------------------
    when ACT_CMD =>
        -- assert general purpose counter enable to start timing Trcd
        GPcnt_en <= '1';
        
        -- assert reset to DQS registers to insure 1 clock of DQS=0
        -- DQS output enable will only output this if write cycle
        dqs_rst_cmb <= '1';

        -- assert ToutSup
        ToutSup <= '1';
        
        -- release read data done reset
        --read_data_done_rst_cmb <= '0';
        
        if Trefi_end='1' then
            -- refresh, assert Retry
            Retry <= '1'; 
            -- must go to to precharge to close row                
            if Tras_end = '1' then
                 cmdsm_ns <= PRECHARGE_CMD;
                 RCW_cmd <= PRECHARGE_RCW;
                 DDR_Addr <= PRECHARGE_DATA;
                 GPcnt_load <= '1';
                 GPcnt_data <= C_RPCNT;
            else
                 cmdsm_ns <= WAIT_TRAS;
            end if;
        elsif Bus2IP_CS = '0' then
            -- CS has negated (master abort)
            -- must go to to precharge to close row                
            if Tras_end = '1' then
                 cmdsm_ns <= PRECHARGE_CMD;
                 RCW_cmd <= PRECHARGE_RCW;
                 DDR_Addr <= PRECHARGE_DATA;
                 GPcnt_load <= '1';
                 GPcnt_data <= C_RPCNT;
            else
                 cmdsm_ns <= WAIT_TRAS;
            end if;
        elsif GPcnt_end = '1' then
            -- Trcd is complete
            -- load the command counter
            Tcmd_load <= '1';
            if read_state = '1' then
                -- need to continue an interrupted read transaction
                -- wait for data to be completed
                if read_data_done = '1' then
                    -- prepare for READ_CMD state
                    RCW_cmd <= READ_RCW;
                    DDR_Addr <= Col_addr;
                    DDR_BankAddr <= bank_addr;
                    cmdsm_ns <= READ_CMD;
                    pend_read_cmb <= '1';
                    reset_pendrdreq_cmb <= '1';
                    Rd_addrAck <= '1';
                    -- release read data done reset
                    read_data_done_rst_cmb <= '1';
                end if;
            elsif Pend_rdreq ='1' or  Bus2IP_RdReq = '1' then
                -- prepare for READ_CMD state
                RCW_cmd <= READ_RCW;
                DDR_Addr <= Col_addr;
                DDR_BankAddr <= bank_addr;
                cmdsm_ns <= READ_CMD;
                pend_read_cmb <= '1';
                reset_pendrdreq_cmb <= '1';
                Rd_addrAck <= '1';
             elsif Pend_wrreq = '1' or Bus2IP_WrReq = '1'then
               -- check for new write request or if need to finish write burst
                -- prepare for WRITE_CMD state
                RCW_cmd <= WRITE_RCW;
                DDR_Addr <= Col_addr;
                DDR_BankAddr <= bank_addr;
                cmdsm_ns <= WRITE_CMD;
                pend_write_cmb <= '1';
                reset_pendwrreq_cmb <= '1';
                Wr_addrAck <= '1';    -- start IPIC address counters
                dq_oe_cmb_i <= '0';   -- assert output enable
                dqs_oe_cmb  <= '0';
            end if;
        end if;
-------------------------- READ_CMD --------------------------
    when READ_CMD =>
        -- when command timer ends, see if this is a burst
        -- so that a new command can be issued
        read_state_cmb <= '1';
        -- assert ToutSup
        ToutSup <= '1';

        if Tcmd_end = '1' then
            if Trefi_end = '1' then
                -- go handle refresh
                -- have to PRECHARGE
                -- assert read_pause
                read_pause_cmb <= '1';
                if Tras_end = '1' then
                     cmdsm_ns <= PRECHARGE_CMD;
                     RCW_cmd <= PRECHARGE_RCW;
                     DDR_Addr <= PRECHARGE_DATA;
                     GPcnt_load <= '1';
                     GPcnt_data <= C_RPCNT;
                else
                     cmdsm_ns <= WAIT_TRAS;
                end if;
            else
                if Bus2IP_RdReq = '1' then
                    if Same_row = '1' then
                        -- access is to the same row, can repeat read command
                        RCW_cmd <= READ_RCW;
                        DDR_Addr <= Col_addr;
                        DDR_BankAddr <= bank_addr;
                        cmdsm_ns <= READ_CMD;
                        Tcmd_load <= '1';
                        Tcmd_cnt_en <= '0';
                        pend_read_cmb <= '1';
                        Rd_addrAck <= '1';
                    else
                        -- access is to a different row
                        -- if same bank, have to precharge
                        -- assert read_pause
                        read_pause_cmb <= '1';
                        if Same_bank = '1' then
                            if Tras_end = '1' then
                                 cmdsm_ns <= PRECHARGE_CMD;
                                 RCW_cmd <= PRECHARGE_RCW;
                                 DDR_Addr <= PRECHARGE_DATA;
                                 GPcnt_load <= '1';
                                 GPcnt_data <= C_RPCNT;
                            else
                                 cmdsm_ns <= WAIT_TRAS;
                            end if;
                        else
                            -- different bank - can go to ACTIVE
                            -- if Trrd has expired, prepare for ACTIVE cmd, else
                            -- wait for Trrd to expire
                            if Trrd_end = '1'  then
                                RCW_cmd <= ACTIVE_RCW;
                                DDR_Addr <= Row_addr;
                                DDR_BankAddr <= Bank_addr;
                                -- load the general purpose counter to time Trcd
                                GPcnt_load <= '1';
                                GPcnt_data <= C_RCDCNT;
                                -- load the RAS counter to time Tras
                                Tras_load <= '1';
                                -- load the RC counter to time Trc
                                Trc_load <= '1';
                                -- reset read_data_done
                                read_data_done_rst_cmb <= '1';                                    
                                cmdsm_ns <= ACT_CMD;
                            else
                                cmdsm_ns <= WAIT_TRRD;
                            end if;
                        end if;  
                    end if; -- if same bank, different row
                else
                    -- not a burst
                    -- if Tras has expired, go to PRECHARGE, 
                    -- otherwise wait for Tras to expire
                    if Tras_end = '1' then
                         cmdsm_ns <= PRECHARGE_CMD;
                         RCW_cmd <= PRECHARGE_RCW;
                         DDR_Addr <= PRECHARGE_DATA;
                         GPcnt_load <= '1';
                         GPcnt_data <= C_RPCNT;
                    else
                         cmdsm_ns <= WAIT_TRAS;
                    end if;
                end if; -- if bus2ip_rdreq
            end if; -- if refresh
        else
            Tcmd_load <= '0';
            Tcmd_cnt_en <= '1';              
        end if;    

-------------------------- WRITE_CMD --------------------------
    when WRITE_CMD =>
        -- assert ToutSup
        ToutSup <= '1';


        -- keep the counters enabled
        write_state_cmb <= '1';
        GPcnt_en <= '1';
        dq_oe_cmb_i <= '0';   -- assert output enable
        dqs_oe_cmb  <= '0';

        -- prepare for WRITE_DATA state
        -- when command timer ends, see if this is a burst
        -- so that a new command can be issued
        -- If there is a need for a refresh command, (Trefi_end=1)
        -- don't service the burst
        if Tcmd_end = '1' then
            if Trefi_end = '1' then
                -- refresh command
                -- must first wait for Twr to expire and then issue
                -- PRECHARGE
                if Twr_end = '1' then
                         -- data transmission is done
                         -- if Tras has expired, go to PRECHARGE, 
                         -- otherwise wait for Tras to expire
                         dq_oe_cmb_i <= '1';   -- negate output enable
                         dqs_oe_cmb <= '1';
                         if Tras_end = '1' then
                             cmdsm_ns <= PRECHARGE_CMD;
                             RCW_cmd <= PRECHARGE_RCW;
                             DDR_Addr <= PRECHARGE_DATA;
                             GPcnt_load <= '1';
                             GPcnt_data <= C_RPCNT;
                         else
                             cmdsm_ns <= WAIT_TRAS;
                         end if;
                 else
                    cmdsm_ns <= WAIT_TWR;
                 end if;  -- if twr_end
            elsif Bus2IP_WrReq = '1' then
                -- write burst
                if Same_row = '1' then
                        -- access is to the same row, issue write command
                        RCW_cmd <= WRITE_RCW;
                        DDR_Addr <= Col_addr;
                        DDR_BankAddr <= Bank_addr;
                        cmdsm_ns <= WRITE_CMD;
                        Tcmd_load <= '1';
                        Tcmd_cnt_en <= '0';
                        Wr_AddrAck <= '1';
                        pend_write_cmb <= '1';
                else
                        pend_write_cmb <= '0';
                        -- access is to a different row
                        -- if same bank, have to PRECHARGE
                        if Same_bank = '1' then
                            if Twr_end = '1' then
                                -- data transmission is done
                                -- if Tras has expired, go to PRECHARGE, 
                                -- otherwise wait for Tras to expire
                                dq_oe_cmb_i <= '1';   -- negate output enable
                                dqs_oe_cmb <= '1';
                                if Tras_end = '1' then
                                    cmdsm_ns <= PRECHARGE_CMD;
                                    RCW_cmd <= PRECHARGE_RCW;
                                    DDR_Addr <= PRECHARGE_DATA;
                                    GPcnt_load <= '1';
                                    GPcnt_data <= C_RPCNT;
                                else
                                    cmdsm_ns <= WAIT_TRAS;
                                end if;
                            else
                                cmdsm_ns <= WAIT_TWR;
                            end if; -- if twr_end
                        else
                            -- different bank, can go to ACTIVE
                            -- if Trrd has expired, prepare for ACTIVE cmd, else
                            -- wait for Trrd to expire
                            if Twr_end = '1' then
                                -- data transmission is done
                                -- if Tras has expired, go to PRECHARGE, 
                                -- otherwise wait for Tras to expire
                                dq_oe_cmb_i <= '1';   -- negate output enable
                                dqs_oe_cmb <= '1';
                                if Trrd_end = '1' then
                                    RCW_cmd <= ACTIVE_RCW;
                                    DDR_Addr <= Row_addr;
                                    DDR_BankAddr <= Bank_addr;
                                    -- load the general purpose counter to time Trcd
                                    GPcnt_load <= '1';
                                    GPcnt_data <= C_RCDCNT;
                                    -- load the RAS counter to time Tras
                                    Tras_load <= '1';
                                    cmdsm_ns <= ACT_CMD;
                                else
                                    cmdsm_ns <= WAIT_TRRD;
                                end if; -- if trrd_end
                            else
                                cmdsm_ns <= WAIT_TWR;
                            end if; -- if twr_end
                        end if; -- if same_bank
                end if; -- if same_row
            else
                pend_write_cmb <= '0';
                if Twr_end = '1' then
                    -- data transmission is done
                    -- if Tras has expired, go to PRECHARGE, 
                    -- otherwise wait for Tras and Twr to expire
                    dq_oe_cmb_i <= '1';   -- negate output enable
                    dqs_oe_cmb <= '1';
                    if Tras_end = '1' then
                        cmdsm_ns <= PRECHARGE_CMD;
                        RCW_cmd <= PRECHARGE_RCW;
                        DDR_Addr <= PRECHARGE_DATA;
                        GPcnt_load <= '1';
                        GPcnt_data <= C_RPCNT;
                    else
                        cmdsm_ns <= WAIT_TRAS;
                    end if;
                 else
                    cmdsm_ns <= WAIT_TWR;
                 end if;  -- if twr_end
            end if; -- if bus2ip_wrreq
        else
            pend_write_cmb <= '0';
            Tcmd_load <= '0';
            Tcmd_cnt_en <= '1';    
        end if;    

---------------------------- WAIT_TWR --------------------------
    when WAIT_TWR =>
        -- assert ToutSup
        ToutSup <= '1';

        -- wait in this state for the write recovery and TRAS
             dq_oe_cmb_i <= '1';   
             dqs_oe_cmb <= '1';
             if Tras_end = '1' and Twr_end = '1' then
                 cmdsm_ns <= PRECHARGE_CMD;
                 RCW_cmd <= PRECHARGE_RCW;
                 DDR_Addr <= PRECHARGE_DATA;
                 GPcnt_load <= '1';
                 GPcnt_data <= C_RPCNT;
             end if;
-------------------------- PRECHARGE_CMD --------------------------
    when PRECHARGE_CMD =>
        -- keep the general purpose counter enable to count Trp
        -- keep the Trc counter enabled
        Twr_rst <= '1';
        GPcnt_en <= '1';


        if Trefi_end = '1' or read_state = '0' or Bus2IP_RdReq = '1' then
            -- either refresh or initialization or write xfer
            -- or an interrupted read burst
            -- assert ToutSup
            -- ToutSup is not asserted if waiting for read_data_done
            ToutSup <= '1';
        end if;


        -- go to IDLE state once Trp and Trc have expired
        -- Note: if came to this state to do a REFRESH, Trefi_end will
        -- still be asserted, so will get to REFRESH state through IDLE
        if GPcnt_end = '1' and Trc_end = '1' then
            if read_state = '0' then
                -- either refresh or initialization or write xfer
                -- go to IDLE
                cmd_done_cmb <= '1';
                cmdsm_ns <= IDLE;                
            else 
                -- end of read transaction or interrupted read, must wait for Read_data_done
                if Read_data_done = '1' then
                    cmd_done_cmb <= '1';
                    read_data_done_rst_cmb <= '1';
                    cmdsm_ns <= IDLE;
                end if;
            end if;
        end if;
        if Trefi_end='1' then
            -- refresh
            -- assert Retry
            Retry <= '1'; 
        end if;
-------------------------- WAIT_TRAS --------------------------
    when WAIT_TRAS =>
        -- assert ToutSup
        ToutSup <= '1';

        -- go to PRECHARGE_CMD state once Tras has expired
        -- if write transaction, also insure that Twr has expired
        if Trefi_end='1' then
            -- refresh
            -- assert Retry
            Retry <= '1'; 
        end if;
       if Tras_end = '1' then
            cmdsm_ns <= PRECHARGE_CMD;
            RCW_cmd <= PRECHARGE_RCW;
            DDR_Addr <= PRECHARGE_DATA;
            GPcnt_load <= '1';
            GPcnt_data <= C_RPCNT;
        end if;
-------------------------- WAIT_TRRD --------------------------
    when WAIT_TRRD =>
        -- assert ToutSup
        ToutSup <= '1';
        
            -- go to ACT_CMD state once Trrd has expired
        if Trrd_end = '1' then
            RCW_cmd <= ACTIVE_RCW;
            DDR_Addr <= Row_addr;
            DDR_BankAddr <= Bank_addr;
            -- load the general purpose counter to time Trcd
            GPcnt_load <= '1';
            GPcnt_data <= C_RCDCNT;
            -- load the RAS counter to time Tras
            Tras_load <= '1';
            -- load the RC counter to time Trc
            Trc_load <= '1';
            cmdsm_ns <= ACT_CMD;
        end if;
        
---------------------------- DEFAULT --------------------------
    when others => 
        cmd_done_cmb <= '1';
        cmdsm_ns <= IDLE;
end case;
end process CMDSM_CMB;

-- Note: most outputs from this state machine will be registered in the I/O module
-- and are not registered here
CMDSM_REG: process (Clk)
begin

    if (Clk'event and Clk = '1') then
        if (Rst = RESET_ACTIVE) then
            cmdsm_cs <= IDLE;
            Cmd_done <= '0'; 
            pend_read_reg <= '0';
            pend_write_reg <= '0';
            read_state <= '0';
            write_state <= '0';
            Read_dqs_ce <= '1';
            Read_data_done_rst <= '1';
            read_pause_i <= '0';
        else
            cmdsm_cs <= cmdsm_ns;
            -- if doing a write, disable the input DQS registers
            if cmdsm_ns = WRITE_CMD then
                Read_dqs_ce <= '0';
            else
                Read_dqs_ce <= '1';
            end if;
            if rst_read_state = '1' then
                read_state <= '0';
            else
                read_state <= read_state_cmb;
            end if;
            if rst_write_state = '1' then
                write_state <= '0';
            else
                write_state <= write_state_cmb;
            end if;
            Cmd_done <= cmd_done_cmb; 
            if Rst_pend_rd = RESET_ACTIVE then
                pend_read_reg <= '0';
            elsif pend_read_cmb = '1' then
                pend_read_reg <= '1';
            end if;
            pend_write_reg <= pend_write_cmb;
            Read_data_done_rst  <= read_data_done_rst_cmb;
            
            if Read_data_done = '1' then
                read_pause_i <= '0';
            else
                read_pause_i <= read_pause_cmb;
            end if;
        end if;
    end if;
end process CMDSM_REG;    

Reset_pendwrreq <= reset_pendwrreq_cmb;
Reset_pendrdreq <= reset_pendrdreq_cmb;

end imp;

