-------------------------------------------------------------------------------
-- $Id: data_statemachine.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- data_statemachine.vhd - entity/architecture pair
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
-- Filename:        data_statemachine.vhd
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
--   ALS           06/07/02
-- ^^^^^^
--  Made changes to support Asynch FIFO read data interface:
--      -- generate READ_DATA_EN sooner 
--      -- remove RDACK generation
-- ~~~~~~
--  ALS             07/12/02
-- ^^^^^^
--      Added C_REG_DIMM generic. When C_REG_DIMM=1, add a 1-clock pipeline
--      delay to write_data, write_data_mask, write_data_en, write_dqs_en.
-- ~~~~~~
-- ALS              07/17/02
-- ^^^^^^
--      Drastically changed state machine to simplify it. No longer need to monitor
--      burst signal - will use pend_wr and pend_rd instead.
-- ~~~~~~
--  ALS             06/27/03
-- ^^^^^^
--  Made WRITE_DQS_EN a vector so that there is an individual enable for each
--  DQS line. This reduces the fan-out on this signal and makes the CLK - CLK90
--  timing easier to meet.
-- ~~~~~~
--  ALS             07/01/03
-- ^^^^^^
--  Use Bus2IP_Burst to control data phase instead of pend_read as command state
--  machine will leave read state earlier. Also, will register and hold data_done
--  as it signals when the command state machine can service the next command.
-- ~~~~~~
--  ALS             07/15/03
-- ^^^^^^
--  Since DQS pullups will look like DQS is asserted, have to determine
--  when to reset the read acknowledge. This requires knowing when the read
--  transaction has been interrupted to service a refresh or because the row
--  or bank has changed. Implemented a counter to count clocks in which the 
--  read command has been issued so that the read acknowledge can be reset
--  when the proper number of read acknowledges have been received. This is
--  only needed when a read transaction has been interrupted.
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
--      C_DDR_DWIDTH        -- width of DDR address bus
--      C_IPIF_DWIDTH       -- width of processor bus
--      C_REG_DIMM          -- add clock delay on write data, etc. for reg dimms
--
-- Definition of Ports:
--  -- inputs
--      IPIC_wrdata         -- data to be written
--      IPIC_be             -- bus byte enables
--      Pend_write          -- enable writing of data
--      Pend_read           -- enable reading of data
--      DDR_brst_end        -- end of ddr burst
--      Bus2IP_RNW          -- bus read not write
--      Tcaslat_end         -- CAS latency end
--      Twr_end             -- Twr end
--      Rdack               -- read data acknowledge
--      Read_data_done_rst  -- reset read data done register
--      Read_pause          -- pause in read transfer due to row/bank rollover or refresh
--
--  -- outputs
--      WrAck               -- write acknowledge
--      Read_data_en        -- enable read data io register
--      Write_data_en       -- enable write data io register
--      Write_dqs_en        -- enable write dqs io register
--      Write_data          -- data to be written
--      Write_data_mask     -- data mask to be written
--      Read_data_done      -- data statemachine is complete
--      Tbrst_cnt_en        -- enable burst counter
--      Tbrst_load          -- load burst counter
--      Tcaslat_cnt_en      -- enable CAS latency counter
--      Tcaslat_load        -- load CAS latency counter
--      Twr_load            -- load Twr counter
--      Twr_cnten           -- enable Twr counter
--      Rst_pend_rd         -- reset pending read
--      Rst_pend_wr         -- reset pending write
--
--    -- Clocks and reset
--      Clk                 
--      Rst               
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity data_statemachine is
  generic ( C_DDR_DWIDTH        : integer;
            C_IPIF_DWIDTH       : integer;
            C_REG_DIMM          : integer);
  port (
    -- inputs
    IPIC_wrdata         : in  std_logic_vector(0 to C_IPIF_DWIDTH-1);
    IPIC_be             : in  std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
    Bus2IP_Burst        : in  std_logic;
    Pend_write          : in  std_logic;
    Pend_read           : in  std_logic;
    DDR_brst_end        : in  std_logic;
    Bus2IP_RNW          : in  std_logic;
    Tcaslat_end         : in  std_logic;
    Twr_end             : in  std_logic;
    Rdack               : in  std_logic;
    Read_data_done_rst  : in  std_logic;
    Read_pause          : in  std_logic;

    -- outputs
    WrAck               : out std_logic;
    Read_data_en        : out std_logic;
    Write_data_en       : out std_logic;
    Write_dqs_en        : out std_logic_vector(0 to C_DDR_DWIDTH/8-1);
    Write_data          : out std_logic_vector(0 to C_IPIF_DWIDTH-1);
    Write_data_mask     : out std_logic_vector(0 to C_IPIF_DWIDTH/8-1);
    Read_data_done      : out std_logic;
    Tbrst_cnt_en        : out std_logic;
    Tbrst_load          : out std_logic;
    Tcaslat_cnt_en      : out std_logic;
    Tcaslat_load        : out std_logic;
    Twr_load            : out std_logic;
    Twr_cnten           : out std_logic;
    Rst_pend_rd         : out std_logic;
    Rst_pend_wr         : out std_logic;
    RdAck_rst           : out std_logic;

    -- Clocks and reset
    Clk                 : in  std_logic;
    Rst                 : in  std_logic
    );
end entity data_statemachine;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of data_statemachine is
-----------------------------------------------------------------------------
-- Constant declarations
-----------------------------------------------------------------------------
constant DATA_MASK_ONES   : std_logic_vector(0 to C_DDR_DWIDTH/8-1) 
                            := (others => '1');
constant READ_CNTR_WIDTH  : integer := 4;                            
constant READ_CNTR_ZEROS  : std_logic_vector(0 to READ_CNTR_WIDTH-1) 
                            := (others => '0');
constant READ_CNTR_ONE  : std_logic_vector(0 to READ_CNTR_WIDTH-1) 
                            := conv_std_logic_vector(1, READ_CNTR_WIDTH);
-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
type DATA_STATE_TYPE is (IDLE, WAIT_CASLAT, WR_DATA, WAIT_TWR, 
                         RD_DATA, WAIT_RDACK, DONE);
signal datasm_ns        : DATA_STATE_TYPE;
signal datasm_cs        : DATA_STATE_TYPE;

signal write_data_en_cmb: std_logic;
signal read_data_en_cmb : std_logic;
signal wrdata_ack       : std_logic;
signal read_data_done_cmb    : std_logic;
signal read_data_done_reg    : std_logic;
signal data_mask        : std_logic;
signal ipic_wrdata_d1   : std_logic_vector(0 to C_DDR_DWIDTH-1);
signal ipic_be_d1       : std_logic_vector(0 to C_DDR_DWIDTH/8-1);

signal write_data_en_i  : std_logic;
signal write_dqs_en_i   : std_logic_vector(0 to C_DDR_DWIDTH/8-1);
signal write_data_i     : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal write_data_mask_i: std_logic_vector(0 to C_IPIF_DWIDTH/8-1);

signal rdack_rst_i      : std_logic;

signal read_cntr_ce     : std_logic;
signal read_cntr_rst    : std_logic;
signal read_cnt         : std_logic_vector(0 to READ_CNTR_WIDTH-1);
-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin  -- architecture imp
-- assign output signals

WrAck <= wrdata_ack;

-- reset RdAck when the read transaction has been interrupted and the last
-- read ack has been received and during all states of the read side of the
-- data state machine except RD_DATA
RdAck_rst <= '1' 
                when ((read_cnt = READ_CNTR_ONE and RdAck = '1' and Read_pause='1')
                       or rdack_rst_i = '1')
                else '0';

Read_data_done <= read_data_done_reg;

-- generate the read data en 
RD_DATAEN_PROCESS: process(Clk)
begin
    if Clk'event and Clk = '1' then
        if Rst = RESET_ACTIVE then
            Read_data_en <= '0';
        else 
            Read_data_en <= read_data_en_cmb;
        end if;
    end if;
end process RD_DATAEN_PROCESS;


WR_DATAEN_PROCESS: process (Clk)
begin
    -- register write_data_en on falling edge of clock 
    if Clk'event and Clk = '0' then
        if Rst = RESET_ACTIVE then
            write_data_en_i <= '0';
        else 
            write_data_en_i <= write_data_en_cmb;
        end if;
    end if;
end process;    

WRITE_DQS_EN_GEN: for i in 0 to C_DDR_DWIDTH/8 -1 generate
    WR_DQS_REG: FDR
      port map (
        Q => write_dqs_en_i(i), --[out]
        C => Clk,               --[in]
        D => write_data_en_cmb, --[in]
        R => Rst                --[in]
      );
end generate WRITE_DQS_EN_GEN;    

-- generate write data and write data mask
-- need to register the lower half of the bus
BUS2IPDATA_REG: process (Clk)
begin
    if Clk'event and Clk='1' then
        if Rst = RESET_ACTIVE then
            ipic_wrdata_d1 <= (others => '0');
            ipic_be_d1 <= (others => '0');
        else
            ipic_wrdata_d1 <= IPIC_wrdata(C_DDR_DWIDTH to C_DDR_DWIDTH*2-1);
            if data_mask = '0' then
                ipic_be_d1 <= IPIC_be(C_DDR_DWIDTH/8 to C_DDR_DWIDTH*2/8-1);
            else
                ipic_be_d1 <= (others => '0');
            end if;
        end if;
    end if;
end process BUS2IPDATA_REG;

-- generate the data mask
write_data_mask_i <= not(IPIC_be(0 to C_DDR_DWIDTH/8-1)) & not(ipic_be_d1)
                    when data_mask = '0' 
                    else DATA_MASK_ONES & not(ipic_be_d1);

write_data_i <= IPIC_wrdata(0 to C_DDR_DWIDTH-1)& ipic_wrdata_d1;

-- Determine whether REG_DIMM - if so, register delay all associated write signals
-- by one clock to account for the registering of control/address signals in the DIMM
-- if not REG_DIMM, output write signals
WRITE_PIPE_GEN: if C_REG_DIMM = 1 generate
    WRITE_RE_REG: process(Clk)
    begin
        if Clk'event and Clk='1' then
            if Rst=RESET_ACTIVE then
                Write_data <= (others => '0');
                Write_data_mask <= (others => '1');
                Write_dqs_en <= (others => '0');
            else
                Write_data <= write_data_i;
                Write_data_mask <= write_data_mask_i;
                Write_dqs_en <= write_dqs_en_i;
            end if;
         end if;
    end process WRITE_RE_REG;
    
    WRITE_FE_REG: process(Clk)
    begin
        if Clk'event and Clk='0' then
            if Rst=RESET_ACTIVE then
                Write_data_en <= '0';
            else
                Write_data_en <= write_data_en_i  after 1 ns;
            end if;
        end if;
    end process WRITE_FE_REG;
end generate WRITE_PIPE_GEN;

NOWRITE_PIPE_GEN: if C_REG_DIMM = 0 generate
            Write_data <= write_data_i;
            Write_data_mask <= write_data_mask_i;
            Write_dqs_en <= write_dqs_en_i;
            Write_data_en <= write_data_en_i after 1 ns;
            --Write_dqs_en <= write_data_en_cmb;
            --Write_data_en <= write_data_en_cmb after 1 ns;
end generate NOWRITE_PIPE_GEN;    

            
--------------------------------------------------------------------------------
-- Data State Machine
-- DATASM_CMB:     combinational process for determining next state
-- DATASM_REG:     state machine registers
--------------------------------------------------------------------------------
    -- Combinational process
DATASM_CMB: process (Pend_write, Pend_read, DDR_brst_end, datasm_cs, Tcaslat_end,
                     Twr_end,
                     Bus2IP_Burst,
                     read_cnt,
                     Rdack,
                     Read_pause)
begin
-- Set default values
wrdata_ack <= '0';
write_data_en_cmb <= '0';
read_data_en_cmb <= '0';
read_data_done_cmb <= '0';
datasm_ns <= datasm_cs;
Tbrst_cnt_en <= '0';
Tbrst_load <= '0';
Tcaslat_load <= '0';
Tcaslat_cnt_en <= '0';
Twr_load <= '0';
Twr_cnten <= '0';
Rst_pend_wr <= not(RESET_ACTIVE);
Rst_pend_rd <= not(RESET_ACTIVE);
data_mask <= '1';
rdack_rst_i <= '0';

case datasm_cs is
-------------------------- IDLE --------------------------
    when IDLE =>
        -- idle state
        -- wait in this state for pending read or write       
        rdack_rst_i <= '1';
        
        if Pend_write = '1' then
            datasm_ns <= WR_DATA;
            wrdata_ack <= '1';
            Tbrst_load <= '1';
            write_data_en_cmb <= '1';
            data_mask <= '0';
            Rst_pend_wr <= RESET_ACTIVE;
        end if;
        if Pend_read = '1' then
            datasm_ns <= WAIT_CASLAT;
            Tcaslat_load <= '1';
            Rst_pend_rd <= RESET_ACTIVE;
        end if;
        
-------------------------- WAIT_CASLAT --------------------------
    when WAIT_CASLAT => 
        -- wait in this state for cas latency timer to expire
        Tcaslat_cnt_en <= '1';
        -- since this is a state only accessable from READ,
        -- assert read data enable a clock before caslatency expires
        read_data_en_cmb <= '1';
        rdack_rst_i <= '1';
        if Tcaslat_end = '1' then
            datasm_ns <= RD_DATA;
            Tbrst_load <= '1';
        end if;
-------------------------- WR_DATA --------------------------
    when WR_DATA =>
        -- write data in this state
        -- stay in this state while pend_wr is asserted
        -- check to see if the DDR burst cycle is complete
        Tbrst_cnt_en <= '1';
        write_data_en_cmb <= '1';
        if Pend_write = '0' then
            -- single transaction or burst has finished
            if DDR_brst_end = '1' then
                -- DDR is done, wait for Twr
                -- kill the data enable for writes
                Twr_load <= '1';
                datasm_ns <= WAIT_TWR;
            else
                -- DDR is not done with burst, stay in this state and keep the data enable asserted
                data_mask <= '0';
                Rst_pend_wr <= RESET_ACTIVE;
            end if;
        else
            wrdata_ack <= '1';
            -- still transferring data
            if DDR_brst_end = '1' then
                --stay in this state, need to reset pending command and reload burst counter
                Tbrst_load <= '1';
                Tbrst_cnt_en <= '0';
                data_mask <= '0';
                Rst_pend_wr <= RESET_ACTIVE;
            else
                -- DDR is not done with burst, stay in this state and keep the data enable asserted
                data_mask <= '0';
                Rst_pend_wr <= RESET_ACTIVE;
            end if;
        end if;

-------------------------- RD_DATA --------------------------
    when RD_DATA =>
        -- read data in this state
        -- stay in this state while pend_rd is asserted
        -- check to see if the DDR burst cycle is complete
        Tbrst_cnt_en <= '1';
        read_data_en_cmb <= '1';

        if Bus2IP_Burst = '0' and Read_pause = '0' then 
            -- single transaction or burst has finished
            if Rdack = '1' then
            -- DDR is done with burst, go to DONE
                datasm_ns <= DONE;
                read_data_done_cmb <= '1';
                rdack_rst_i <= '1';
            else
                -- wait for read data ack
                datasm_ns <= WAIT_RDACK;
            end if;
        elsif read_cnt = READ_CNTR_ZEROS then
            -- read transaction has been interrupted and
            -- all read acks have been received
            datasm_ns <= DONE;
            read_data_done_cmb <= '1';
            rdack_rst_i <= '1';
        else
            -- still transferring data
            if DDR_brst_end = '1' then
                --stay in this state, need to reset pending command and reload burst counter
                Tbrst_load <= '1';
                Tbrst_cnt_en <= '0';
            end if;
        end if;
-------------------------- WAIT_TWR --------------------------
    when WAIT_TWR => 
        -- wait in this state for write recovery timer to expire
        Twr_cnten <= '1';
        if Twr_end = '1' then
           datasm_ns <= DONE;
           write_data_en_cmb <= '0'; 
        end if;
-------------------------- WAIT_RDACK --------------------------
    when WAIT_RDACK => 
        read_data_en_cmb <= '1';
        -- wait in this state for read data ack to assert
        if Rdack = '1' then
            -- DDR is done with burst, go to DONE
            datasm_ns <= DONE;
            read_data_done_cmb <= '1';
            rdack_rst_i <= '1';
        end if;
-------------------------- DONE --------------------------
    when DONE =>
        -- Read_data_done is asserted in this state
        -- if pend_op asserts, go to XFER_DATA, otherwise
        -- go back to IDLE
        rdack_rst_i <= '1';
        if Pend_write = '1' then
            datasm_ns <= WR_DATA;
            Tbrst_load <= '1';
            write_data_en_cmb <= '1';
            data_mask <= '0';
            Rst_pend_wr <= RESET_ACTIVE;
        elsif Pend_read = '1' then
            datasm_ns <= WAIT_CASLAT;
            Tcaslat_load <= '1';
            Rst_pend_rd <= RESET_ACTIVE;
        else
            datasm_ns <= IDLE;
        end if;
        
-------------------------- DEFAULT --------------------------
    when others => 
        datasm_ns <= IDLE;
end case;
end process DATASM_CMB;
    
DATASM_REG: process (Clk)
begin

    if (Clk'event and Clk = '1') then
        if (Rst = RESET_ACTIVE) then
            datasm_cs <= IDLE;
        else
            datasm_cs <= datasm_ns;
        end if;
    end if;
end process DATASM_REG;    

DATADONE_REG: process (Clk)
begin

    if (Clk'event and Clk = '1') then
        if (Rst = RESET_ACTIVE or Read_data_done_rst='1') then
            read_data_done_reg <= '0';
        elsif read_data_done_cmb = '1' then
            read_data_done_reg <= '1';
        end if;
    end if;
end process DATADONE_REG;    

-- Read counter
-- Counts up when there is a pending read command, counts
-- down everytime a read acknowledge is received
-- Reset whenever read data is finished
read_cntr_ce <= Pend_read xor RdAck;
read_cntr_rst <= read_data_done_cmb or Rst;
READCNTR_I:  entity modified_plb_ddr_controller_v1_00_c.Counter(imp)
    generic map (C_NUM_BITS => READ_CNTR_WIDTH)
    port map
        (
            Clk           => Clk,
            Rst           => read_cntr_rst,  
            Load_In       => READ_CNTR_ZEROS,
            Count_Enable  => read_cntr_ce,
            Count_Load    => '0',
            Count_Down    => RdAck,
            Count_Out     => read_cnt,
            Carry_Out     => open
        );
end imp;

