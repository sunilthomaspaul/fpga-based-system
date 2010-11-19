------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Wed Apr 22 14:12:54 2009 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;


library proc_common_v1_00_b;
use proc_common_v1_00_b.proc_common_pkg.all;
-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_AWIDTH                     -- User logic address bus width
--   C_DWIDTH                     -- User logic data bus width
--   C_NUM_CE                     -- User logic chip enable bus width
--   C_IP_INTR_NUM                -- User logic number of interrupt event
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   IP2Bus_IntrEvent             -- IP to Bus interrupt event
--   Bus2IP_Data                  -- Bus to IP data bus for user logic
--   Bus2IP_BE                    -- Bus to IP byte enables for user logic
--   Bus2IP_RdCE                  -- Bus to IP read chip enable for user logic
--   Bus2IP_WrCE                  -- Bus to IP write chip enable for user logic
--   Bus2IP_RdReq                 -- Bus to IP read request
--   Bus2IP_WrReq                 -- Bus to IP write request
--   IP2Bus_Data                  -- IP to Bus data bus for user logic
--   IP2Bus_Retry                 -- IP to Bus retry response
--   IP2Bus_Error                 -- IP to Bus error response
--   IP2Bus_ToutSup               -- IP to Bus timeout suppress
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   Bus2IP_MstError              -- Bus to IP master error
--   Bus2IP_MstLastAck            -- Bus to IP master last acknowledge
--   Bus2IP_MstRdAck              -- Bus to IP master read acknowledge
--   Bus2IP_MstWrAck              -- Bus to IP master write acknowledge
--   Bus2IP_MstRetry              -- Bus to IP master retry
--   Bus2IP_MstTimeOut            -- Bus to IP mster timeout
--   IP2Bus_Addr                  -- IP to Bus address for the master transaction
--   IP2Bus_MstBE                 -- IP to Bus byte-enables qualifiers
--   IP2Bus_MstBurst              -- IP to Bus burst qualifier
--   IP2Bus_MstBusLock            -- IP to Bus bus-lock qualifier
--   IP2Bus_MstRdReq              -- IP to Bus master read request
--   IP2Bus_MstWrReq              -- IP to Bus master write request
--   IP2IP_Addr                   -- IP to IP local device address for the master transaction
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_AWIDTH                       : integer              := 32;
    C_DWIDTH                       : integer              := 32;
    C_NUM_CE                       : integer              := 8;
    C_IP_INTR_NUM                  : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    IP2Bus_IntrEvent               : out std_logic_vector(0 to C_IP_INTR_NUM-1);
    Bus2IP_Data                    : in  std_logic_vector(0 to C_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
    Bus2IP_RdReq                   : in  std_logic;
    Bus2IP_WrReq                   : in  std_logic;
    IP2Bus_Data                    : out std_logic_vector(0 to C_DWIDTH-1);
    IP2Bus_Retry                   : out std_logic;
    IP2Bus_Error                   : out std_logic;
    IP2Bus_ToutSup                 : out std_logic;
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    Bus2IP_MstError                : in  std_logic;
    Bus2IP_MstLastAck              : in  std_logic;
    Bus2IP_MstRdAck                : in  std_logic;
    Bus2IP_MstWrAck                : in  std_logic;
    Bus2IP_MstRetry                : in  std_logic;
    Bus2IP_MstTimeOut              : in  std_logic;
    IP2Bus_Addr                    : out std_logic_vector(0 to C_AWIDTH-1);
    IP2Bus_MstBE                   : out std_logic_vector(0 to C_DWIDTH/8-1);
    IP2Bus_MstBurst                : out std_logic;
    IP2Bus_MstBusLock              : out std_logic;
    IP2Bus_MstRdReq                : out std_logic;
    IP2Bus_MstWrReq                : out std_logic;
    IP2IP_Addr                     : out std_logic_vector(0 to C_AWIDTH-1)
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic

  type xy_info is record
	prio:	std_logic_vector(0 to 7);
	x:		std_logic_vector(0 to 7);
	bitx:	std_logic_vector(0 to 7);
	y:		std_logic_vector(0 to 7);
	bity:	std_logic_vector(0 to 7);
	delay:	std_logic_vector(0 to 31);
  end record xy_info;
  type task_rec is array(0 to 15) of xy_info;
  signal task                           : task_rec;
  
  type osunmap is array(0 to 255) of std_logic_vector(0 to 2);
  constant osunmaptbl: osunmap := 
	("000", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "110", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "111", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "110", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000"); 
  signal osrdygrp 						: std_logic_vector(0 to 7) := X"00";
  type rdytbl is array(0 to 7) of std_logic_vector(0 to 7);
  signal osrdytbl						: rdytbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");

  --signal ospriohighrdy					: std_logic_vector(0 to 7);
	
  type eventtbl	is array(0 to 7) of std_logic_vector(0 to 7);
  type wait_list is record
    oseventgrp 						    : std_logic_vector(0 to 7);
    oseventtbl                          : eventtbl;
  end record wait_list;
  type event_rec is array(1 to 16) of wait_list;
  signal ecb                            : event_rec := ((X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")),
														(X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00")));
														
  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg2                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg3                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg_write_select           : std_logic_vector(0 to 3);
  signal slv_reg_read_select            : std_logic_vector(0 to 3);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

  ------------------------------------------
  -- Signals for user logic master model example
  ------------------------------------------
  -- signals for write/read data
  signal mst_ip2bus_data                : std_logic_vector(0 to C_DWIDTH-1);
  signal mst_reg_read_request           : std_logic;
  signal mst_reg_write_select           : std_logic_vector(0 to 3);
  signal mst_reg_read_select            : std_logic_vector(0 to 3);
  signal mst_write_ack                  : std_logic;
  signal mst_read_ack                   : std_logic;
  -- signals for master control/status registers
  type BYTE_REG_TYPE is array(0 to 15) of std_logic_vector(0 to 7);
  signal mst_reg                        : BYTE_REG_TYPE;
  signal mst_byte_we                    : std_logic_vector(0 to 15);
  signal mst_cntl_rd_req                : std_logic;
  signal mst_cntl_wr_req                : std_logic;
  signal mst_cntl_bus_lock              : std_logic;
  signal mst_cntl_burst                 : std_logic;
  signal mst_ip2bus_addr                : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_ip2ip_addr                 : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_ip2bus_be                  : std_logic_vector(0 to C_DWIDTH/8-1);
  signal mst_go                         : std_logic;
  -- signals for master control state machine
  type MASTER_CNTL_SM_TYPE is (IDLE, SINGLE, BURST_8, LAST_BURST, CHK_BURST_DONE);
  signal mst_cntl_state                 : MASTER_CNTL_SM_TYPE;
  signal mst_sm_set_done                : std_logic;
  signal mst_sm_busy                    : std_logic;
  signal mst_sm_clr_go                  : std_logic;
  signal mst_sm_rd_req                  : std_logic;
  signal mst_sm_wr_req                  : std_logic;
  signal mst_sm_burst                   : std_logic;
  signal mst_sm_bus_lock                : std_logic;
  signal mst_sm_ip2bus_addr             : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_sm_ip2ip_addr              : std_logic_vector(0 to C_AWIDTH-1);
  signal mst_sm_ip2bus_be               : std_logic_vector(0 to C_DWIDTH/8-1);
  signal mst_xfer_length                : integer;
  signal mst_xfer_count                 : integer;
  signal mst_ip_addr_count              : integer;
  signal mst_bus_addr_count             : integer;

  ------------------------------------------
  -- Signals for user logic interrupt example
  ------------------------------------------
  signal interrupt                      : std_logic_vector(0 to C_IP_INTR_NUM-1);

begin

  --USER logic implementation added here

  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic, you
  -- are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE or   Memory Mapped
  --       Bus2IP_RdCE   Register
  --            "1000"   C_BASEADDR + 0x0
  --            "0100"   C_BASEADDR + 0x4
  --            "0010"   C_BASEADDR + 0x8
  --            "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_select <= Bus2IP_WrCE(0 to 3);
  slv_reg_read_select  <= Bus2IP_RdCE(0 to 3);
  slv_write_ack        <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3);
  slv_read_ack         <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3);

  -- implement slave model register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
        --slv_reg1 <= (others => '0');
        --slv_reg2 <= (others => '0');
        slv_reg3 <= (others => '0');
      else
        case slv_reg_write_select is
          when "1000" =>
            for byte_index in 0 to (C_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          --when "0100" =>
          --  for byte_index in 0 to (C_DWIDTH/8)-1 loop
          --    if ( Bus2IP_BE(byte_index) = '1' ) then
          --      slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
          --    end if;
          --  end loop;
          --when "0010" =>
          --  for byte_index in 0 to (C_DWIDTH/8)-1 loop
          --    if ( Bus2IP_BE(byte_index) = '1' ) then
          --      slv_reg2(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
          --    end if;
          --  end loop;
          when "0001" =>
            for byte_index in 0 to (C_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg3(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model register read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_select, slv_reg0, slv_reg1, slv_reg2, slv_reg3 ) is
  begin

    case slv_reg_read_select is
      when "1000" => slv_ip2bus_data <= slv_reg0;
      when "0100" => slv_ip2bus_data <= slv_reg1;
      when "0010" => slv_ip2bus_data <= slv_reg2;
      when "0001" => slv_ip2bus_data <= slv_reg3;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to demonstrate user logic master model functionality
  -- 
  -- Note:
  -- The example code presented here is to show you one way of stimulating
  -- the IPIF IP master interface under user control. It is provided for
  -- demonstration purposes only and allows the user to exercise the IPIF
  -- IP master interface during test and evaluation of the template.
  -- This user logic master model contains a 16-byte flattened register and
  -- the user is required to initialize the value to desire and then write to
  -- the model's 'Go' port to initiate the user logic master operation.
  -- 
  --    Control Register	(C_BASEADDR + OFFSET + 0x0):
  --       bit 0		- Rd		(Read Request Control)
  --       bit 1		- Wr		(Write Request Control)
  --       bit 2		- BL		(Bus Lock Control)
  --       bit 3		- Brst	(Burst Assertion Control)
  --       bit 4-7	- Spare	(Spare Control Bits)
  --    Status Register	(C_BASEADDR + OFFSET + 0x1):
  --       bit 0		- Done	(Transfer Done Status)
  --       bit 1		- Bsy		(User Logic Master is Busy)
  --       bit 2-7	- Spare	(Spare Status Bits)
  --    IP2IP Register		(C_BASEADDR + OFFSET + 0x4):
  --       bit 0-31	- IP2IP Address (This 32-bit value is used to populate the
  --                  IP2IP_Addr(0:31) address bus during a Read or Write user
  --                  logic master operation)
  --    IP2Bus Register	(C_BASEADDR + OFFSET + 0x8):
  --       bit 0-31	- IP2Bus Address (This 32-bit value is used to populate the
  --                  IP2Bus_Addr(0:31) address bus during a Read or Write user
  --                  logic master operation)
  --    Length Register	(C_BASEADDR + OFFSET + 0xC):
  --       bit 0-15	- Transfer Length (This 16-bit value is used to specify the
  --                  number of bytes (1 to 65,536) to transfer during user logic
  --                  master read or write operations)
  --    BE Register			(C_BASEADDR + OFFSET + 0xE):
  --       bit 0-7	- IP2Bus master BE (This 8-bit value is used to populate the
  --                  IP2Bus_MstBE byte enable bus during user logic master read or
  --                  write operations, only used in single data beat operation)
  --    Go Register			(C_BASEADDR + OFFSET + 0xF):
  --       bit 0-7	- Go Port (A write to this byte address initiates the user
  --                  logic master transfer, data key value of 0x0A must be used)
  -- 
  --    Note: OFFSET may be different depending on your address space configuration,
  --          by default it's either 0x0 or 0x100. Refer to IPIF address range array
  --          for actual value.
  -- 
  -- Here's an example procedure in your software application to initiate a 4-byte
  -- write operation (single data beat) of this master model:
  --   1. write 0x40 to the control register
  --   2. write the source data address (local) to the ip2ip register
  --   3. write the destination address (remote) to the ip2bus register
  --      - note: this address will be put on the target bus address line
  --   4. write 0x0004 to the length register
  --   5. write valid byte lane value to the be register
  --      - note: this value must be aligned with ip2bus address
  --   6. write 0x0a to the go register, this will start the write operation
  -- 
  ------------------------------------------
  mst_reg_read_request <= Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7);
  mst_reg_write_select <= Bus2IP_WrCE(4 to 7);
  mst_reg_read_select  <= Bus2IP_RdCE(4 to 7);
  mst_write_ack        <= Bus2IP_WrCE(4) or Bus2IP_WrCE(5) or Bus2IP_WrCE(6) or Bus2IP_WrCE(7);
  mst_read_ack         <= Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7);

  -- user logic master request output assignments
  IP2Bus_Addr          <= mst_sm_ip2bus_addr;
  IP2Bus_MstBE         <= mst_sm_ip2bus_be;
  IP2Bus_MstBurst      <= mst_sm_burst;
  IP2Bus_MstBusLock    <= mst_sm_bus_lock;
  IP2Bus_MstRdReq      <= mst_sm_rd_req;
  IP2Bus_MstWrReq      <= mst_sm_wr_req;
  IP2IP_Addr           <= mst_sm_ip2ip_addr;

  -- rip control bits from master model registers
  mst_cntl_rd_req      <= mst_reg(0)(0);
  mst_cntl_wr_req      <= mst_reg(0)(1);
  mst_cntl_bus_lock    <= mst_reg(0)(2);
  mst_cntl_burst       <= mst_reg(0)(3);
  mst_ip2ip_addr       <= mst_reg(4) & mst_reg(5) & mst_reg(6) & mst_reg(7);
  mst_ip2bus_addr      <= mst_reg(8) & mst_reg(9) & mst_reg(10) & mst_reg(11);
  mst_xfer_length      <= CONV_INTEGER(mst_reg(12) & mst_reg(13));
  mst_ip2bus_be        <= mst_reg(14)(0 to C_DWIDTH/8-1);

  -- implement byte write enable for each byte slice of the master model registers
  MASTER_REG_BYTE_WR_EN : process( Bus2IP_BE, Bus2IP_WrReq, mst_reg_write_select ) is
  begin

    for byte_index in 0 to 15 loop
      mst_byte_we(byte_index) <= Bus2IP_WrReq and
                                 mst_reg_write_select(byte_index/(C_DWIDTH/8)) and
                                 Bus2IP_BE(byte_index-(byte_index/(C_DWIDTH/8))*(C_DWIDTH/8));
    end loop;

  end process MASTER_REG_BYTE_WR_EN;

  -- implement master model registers
  MASTER_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        mst_reg(0 to 14)  <= (others => "00000000");
      else
        -- control register (byte 0)
        if ( mst_byte_we(0) = '1' ) then
          mst_reg(0)      <= Bus2IP_Data(0 to 7);
        end if;
        -- status register (byte 1)
        mst_reg(1)(1)     <= mst_sm_busy;
        if ( mst_byte_we(1) = '1' ) then
          -- allows a clear of the 'Done'
          mst_reg(1)(0)  <= Bus2IP_Data((1-(1/(C_DWIDTH/8))*(C_DWIDTH/8))*8);
        else
          -- 'Done' from master control state machine
          mst_reg(1)(0)  <= mst_sm_set_done or mst_reg(1)(0);
        end if;
        -- ip2ip address register (byte 4 to 7)
        -- ip2bus address register (byte 8 to 11)
        -- length register (byte 12 to 13)
        -- be register (byte 14)
        for byte_index in 4 to 14 loop
          if ( mst_byte_we(byte_index) = '1' ) then
            mst_reg(byte_index) <= Bus2IP_Data(
                                     (byte_index-(byte_index/(C_DWIDTH/8))*(C_DWIDTH/8))*8 to
                                     (byte_index-(byte_index/(C_DWIDTH/8))*(C_DWIDTH/8))*8+7);
          end if;
        end loop;
      end if;
    end if;

  end process MASTER_REG_WRITE_PROC;

  -- implement master model write only 'go' port
  MASTER_WRITE_GO_PORT : process( Bus2IP_Clk ) is
    constant GO_DATA_KEY  : std_logic_vector(0 to 7) := X"0A";
    constant GO_BYTE_LANE : integer := 15;
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' or mst_sm_clr_go = '1' ) then
        mst_go   <= '0';
      elsif ( mst_byte_we(GO_BYTE_LANE) = '1' and
              Bus2IP_Data((GO_BYTE_LANE-(GO_BYTE_LANE/(C_DWIDTH/8))*(C_DWIDTH/8))*8 to
                          (GO_BYTE_LANE-(GO_BYTE_LANE/(C_DWIDTH/8))*(C_DWIDTH/8))*8+7) = GO_DATA_KEY ) then
        mst_go   <= '1';
      else
        null;
      end if;
    end if;

  end process MASTER_WRITE_GO_PORT;

  -- implement master model register read mux
  MASTER_REG_READ_PROC : process( mst_reg_read_select, mst_reg ) is
  begin

    case mst_reg_read_select is
      when "1000" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg(byte_index);
        end loop;
      when "0100" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg((C_DWIDTH/8)+byte_index);
        end loop;
      when "0010" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg((C_DWIDTH/8)*2+byte_index);
        end loop;
      when "0001" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          if ( byte_index = C_DWIDTH/8-1 ) then
            -- go port is not readable
            mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= (others => '0');
          else
            mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg((C_DWIDTH/8)*3+byte_index);
          end if;
        end loop;
      when others =>
        mst_ip2bus_data <= (others => '0');
    end case;

  end process MASTER_REG_READ_PROC;

  --implement master model control state machine
  MASTER_CNTL_STATE_MACHINE : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then

        mst_cntl_state       <= IDLE;
        mst_sm_clr_go        <= '0';
        mst_sm_rd_req        <= '0';
        mst_sm_wr_req        <= '0';
        mst_sm_burst         <= '0';
        mst_sm_bus_lock      <= '0';
        mst_sm_ip2bus_addr   <= (others => '0');
        mst_sm_ip2bus_be     <= (others => '0');
        mst_sm_ip2ip_addr    <= (others => '0');
        mst_sm_set_done      <= '0';
        mst_sm_busy          <= '0';
        mst_xfer_count       <= 0;
        mst_bus_addr_count   <= 0;
        mst_ip_addr_count    <= 0;

      else

        -- default condition
        mst_sm_clr_go        <= '0';
        mst_sm_rd_req        <= '0';
        mst_sm_wr_req        <= '0';
        mst_sm_burst         <= '0';
        mst_sm_bus_lock      <= '0';
        mst_sm_ip2bus_addr   <= (others => '0');
        mst_sm_ip2bus_be     <= (others => '0');
        mst_sm_ip2ip_addr    <= (others => '0');
        mst_sm_set_done      <= '0';
        mst_sm_busy          <= '1';

        -- state transition
        case mst_cntl_state is

          when IDLE =>
            if ( mst_go = '1' and mst_xfer_length <= 4 ) then
              -- single beat transfer
              mst_cntl_state       <= SINGLE;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            elsif ( mst_go = '1' and mst_xfer_length < 32 ) then
              -- burst transfer less than 32 bytes
              mst_cntl_state       <= LAST_BURST;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            elsif ( mst_go = '1' ) then
              -- burst transfer greater than 32 bytes
              mst_cntl_state       <= BURST_8;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            else
              mst_cntl_state       <= IDLE;
              mst_sm_busy          <= '0';
            end if;

          when SINGLE =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= IDLE;
              mst_sm_set_done      <= '1';
              mst_sm_busy          <= '0';
            else
              mst_cntl_state       <= SINGLE;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= mst_ip2bus_be;
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
            end if;

          when BURST_8 =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= CHK_BURST_DONE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_xfer_count       <= mst_xfer_count-32;
              mst_bus_addr_count   <= mst_bus_addr_count+32;
              mst_ip_addr_count    <= mst_ip_addr_count+32;
            else
              mst_cntl_state       <= BURST_8;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_burst         <= mst_cntl_burst;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= (others => '1');
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
            end if;

          when LAST_BURST =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= CHK_BURST_DONE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_xfer_count       <= mst_xfer_count-((mst_xfer_count/4)*4);
              mst_bus_addr_count   <= mst_bus_addr_count+(mst_xfer_count/4)*4;
              mst_ip_addr_count    <= mst_ip_addr_count+(mst_xfer_count/4)*4;
            else
              mst_cntl_state       <= LAST_BURST;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_burst         <= mst_cntl_burst;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= (others => '1');
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
            end if;

          when CHK_BURST_DONE =>
            if ( mst_xfer_count = 0 ) then
              -- transfer done
              mst_cntl_state       <= IDLE;
              mst_sm_set_done      <= '1';
              mst_sm_busy          <= '0';
            elsif ( mst_xfer_count <= 4 ) then
              -- need single beat transfer
              mst_cntl_state       <= SINGLE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            elsif ( mst_xfer_count < 32 ) then
              -- need burst transfer less than 32 bytes
              mst_cntl_state       <= LAST_BURST;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            else
              -- need burst transfer greater than 32 bytes
              mst_cntl_state       <= BURST_8;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            end if;

          when others =>
            mst_cntl_state    <= IDLE;
            mst_sm_busy       <= '0';

        end case;

      end if;
    end if;

  end process MASTER_CNTL_STATE_MACHINE;

  ------------------------------------------
  -- Example code to generate user logic interrupts
  -- 
  -- Note:
  -- The example code presented here is to show you one way of generating
  -- interrupts from the user logic. This code snippet infers a counter
  -- and generate the interrupts whenever the counter rollover (the counter
  -- will rollover ~21 sec @50Mhz).
  ------------------------------------------
  INTR_PROC : process( Bus2IP_Clk ) is
    constant COUNT_SIZE   : integer := 30;
    constant ALL_ONES     : std_logic_vector(0 to COUNT_SIZE-1) := (others => '1');
    variable counter      : std_logic_vector(0 to COUNT_SIZE-1);
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        counter := (others => '0');
        interrupt <= (others => '0');
      else
        counter := counter + 1;
        if ( counter = ALL_ONES ) then
          interrupt <= (others => '1');
        else
          interrupt <= (others => '0');
        end if;
      end if;
    end if;

  end process INTR_PROC;

  IP2Bus_IntrEvent <= interrupt;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data        <= mst_ip2bus_data when mst_reg_read_request = '1' else
                        slv_ip2bus_data;

  IP2Bus_WrAck       <= slv_write_ack or mst_write_ack;
  IP2Bus_RdAck       <= slv_read_ack or mst_read_ack;
  IP2Bus_Error       <= '0';
  IP2Bus_Retry       <= '0';
  IP2Bus_ToutSup     <= '0';

  userlogic_control: process( Bus2IP_Clk, slv_reg0 ) is
    variable index   			: integer range 0 to 255;
	 variable priority	      : integer range 0 to 255;
	 variable temp_y_int	   	: integer range 0 to 255;
	 variable temp_y_un	    	: unsigned(0 to 7);
	 variable temp_y_std	   	: std_logic_vector(0 to 7);
	 variable temp_x_std	   	: std_logic_vector(0 to 7);
	 variable temp_Hprio1     	: std_logic_vector(0 to 7);
	 variable temp_Hprio2     	: std_logic_vector(0 to 7);
	 variable prio_high	     	: std_logic_vector(0 to 7);
	 
	 variable temp1 	      	: std_logic_vector(0 to 7);
	 variable temp2 	      	: std_logic_vector(0 to 7);
	 variable temp3 	      	: std_logic_vector(0 to 7);
	 variable temp4 	      	: std_logic_vector(0 to 7);
	 variable temp5 	      	: std_logic_vector(0 to 7);
	
  begin

	if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
	  if Bus2IP_Reset = '1' then
		slv_reg1 <= (others => '0');
	  else 
		---if ( slv_reg0(0 to 7) = X"01" ) then					
	    case slv_reg0(24 to 31) is								--Calculate y, bity, x, bitx for a task
		  when X"01" =>
		    index      := CONV_INTEGER(slv_reg0(16 to 23));
		    temp_y_un  := shr(UNSIGNED(slv_reg0(8 to 15)),CONV_UNSIGNED(3,2));
		    temp_x_std := slv_reg0(8 to 15) and X"07";
		    task(index).prio       <= slv_reg0(8 to 15); 
		    task(index).y	       <= STD_LOGIC_VECTOR(temp_y_un); 		     
            task(index).x	       <= temp_x_std;	             
		    task(index).bity       <= STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),temp_y_un));			    
		    task(index).bitx       <= STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),UNSIGNED(temp_x_std)));
		
		    temp1                  := slv_reg0(8 to 15);	
		    temp2       	       := STD_LOGIC_VECTOR(temp_y_un);
		    temp3       	       := temp_x_std;
		    temp4                  := STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),temp_y_un));	
		    temp5                  := STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),UNSIGNED(temp_x_std)));
		    slv_reg1               <= temp3 & temp2 & temp1 & X"01";
		    slv_reg2               <= X"00" & STD_LOGIC_VECTOR(CONV_UNSIGNED(index,8)) & temp5 & temp4;
			 
			 
		 
		  ---elsif ( slv_reg0(0 to 7) = X"02" ) then				
		  when X"02" =>											--Put a task in the ready list
		    index 	   := CONV_INTEGER(slv_reg0(16 to 23));
		    temp_y_int := CONV_INTEGER(task(index).y);
		    osrdygrp 		   	   <= osrdygrp or task(index).bity;
		    osrdytbl(temp_y_int)   <= osrdytbl(temp_y_int) or task(index).bitx;
		
		    temp1                  := osrdygrp or task(index).bity;
		    temp2       	       := osrdytbl(temp_y_int) or task(index).bitx;
		    temp3       	       := task(index).bitx;		    
		    slv_reg1               <= temp3 & temp2 & temp1 & X"01";
            slv_reg2               <= slv_reg0(16 to 23) & osrdytbl(temp_y_int) & task(index).bity & osrdygrp;		    
		
		  ---elsif ( slv_reg0(0 to 7) = X"03" ) then				
		  when X"03" =>											--Find the highest priority task in the ready list
		    temp_y_std  := b"00000" & osunmaptbl(CONV_INTEGER(osrdygrp));
			temp_Hprio1 := STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
			temp_Hprio2 := b"00000" & osunmaptbl(CONV_INTEGER(osrdytbl(CONV_INTEGER(temp_y_std))));
		    prio_high   := temp_Hprio1 + temp_Hprio2;
		    slv_reg1               <= osrdygrp & temp_y_std & prio_high & X"01";
			slv_reg2               <= X"00" & osrdytbl(CONV_INTEGER(temp_y_std)) & temp_Hprio2 & temp_Hprio1;
			
		  ---elsif ( slv_reg0(0 to 7) = X"04" ) then				
		  when X"04" =>											--remove a task from the ready list
		    index 	   := CONV_INTEGER(slv_reg0(16 to 23));
		    temp_y_int := CONV_INTEGER(task(index).y);
		    temp_y_std := osrdytbl(temp_y_int) and (not task(index).bitx);
		    osrdytbl(temp_y_int) <= temp_y_std;
		    if (temp_y_std = "00000000") then
			  osrdygrp 		         <= osrdygrp and (not task(index).bity);
		    end if;  
		
		    temp1                  := osrdygrp and (not task(index).bity);		    
		    temp2       	       := task(index).y;		    
		    slv_reg1               <= temp_y_std & temp2 & temp1 & X"01";
		
		  when X"05" =>											--Put a task in the wait list
		    index      := CONV_INTEGER(slv_reg0(16 to 23));
		    priority   := CONV_INTEGER(slv_reg0(8 to 15));
		    temp_y_int := CONV_INTEGER(task(priority).y);
		    ecb(index).oseventtbl(temp_y_int) <= ecb(index).oseventtbl(temp_y_int) or task(priority).bitx;
		    ecb(index).oseventgrp		      <= ecb(index).oseventgrp or task(priority).bity;
		
		    temp1                  := ecb(index).oseventtbl(temp_y_int) or task(priority).bitx;
		    temp2       	       := ecb(index).oseventgrp or task(priority).bity;
		    temp3       	       := task(priority).y;		    
		    slv_reg1               <= temp3 & temp2 & temp1 & X"01";	
		
		  when X"06" =>											--Find the highest priority task in the wait list
			index 	    := CONV_INTEGER(slv_reg0(16 to 23));
		    temp_y_std  := b"00000" & osunmaptbl(CONV_INTEGER(ecb(index).oseventgrp));
		    temp_Hprio1 := STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
		    temp_Hprio2 := b"00000" & osunmaptbl(CONV_INTEGER(ecb(index).oseventtbl(CONV_INTEGER(temp_y_std))));
		    prio_high   := temp_Hprio1 + temp_Hprio2;
		    slv_reg1               <= X"00" & temp_y_std & prio_high & X"01";
		
		  when X"07" =>											--remove a task from the wait list
		    index 	   := CONV_INTEGER(slv_reg0(16 to 23));
		    priority   := CONV_INTEGER(slv_reg0(8 to 15));
		    temp_y_int := CONV_INTEGER(task(priority).y);
			temp_y_std := ecb(index).oseventtbl(temp_y_int)and (not task(priority).bitx);
		    ecb(index).oseventtbl(temp_y_int) <= temp_y_std;
		    if (temp_y_std = "00000000") then
		      ecb(index).oseventgrp           <= ecb(index).oseventgrp and (not task(priority).bity);
		    end if;
		
		    temp1                  := ecb(index).oseventgrp and (not task(priority).bity);		    
		    temp2       	       := task(priority).y;		    
		    slv_reg1               <= temp_y_std & temp2 & temp1 & X"01";
				   		
		  when X"08" =>											--Initialize
		    osrdygrp					<= X"00";
			 osrdytbl(0)				<= X"00";
			 osrdytbl(1)				<= X"00";
			 osrdytbl(2)				<= X"00";
			 osrdytbl(3)				<= X"00";
			 osrdytbl(4)				<= X"00";
			 osrdytbl(5)				<= X"00";
			 osrdytbl(6)				<= X"00";
			 osrdytbl(7)				<= X"00";
			
			slv_reg1               <= X"00000001";		
		   slv_reg2               <= slv_reg0;
							
		  --when X"09" =>											--Test
		    --slv_reg1               <= X"00000001";		
		    --slv_reg2               <= slv_reg0;

		  --when X"02" =>											--Test
		    --slv_reg1               <= X"00000011";		
		    --slv_reg2               <= slv_reg0;				 
			 
		  --when "00000011" =>										--Test
		    --slv_reg1               <= "00000000000000000000000000000111";		
		    --slv_reg2               <= slv_reg0;				 
							
		  ---else slv_reg1 <= (others => '0');
		  when others => 
		    slv_reg1               <= (others => '0');
		  ---end if;
        end case;
		  
		  --case slv_reg0(0 to 31) is								--Calculate y, bity, x, bitx for a task
		  --when "00000000000000000000000000001001" =>
		    --slv_reg1               <= "00000000000000000000000000010100";		
		    --slv_reg2               <= slv_reg0;
		  --when others => null;
		  --end case;
		  
		  --if ( slv_reg0 = "00000000000000000000000000000100" ) then
		    --slv_reg1               <= "00000000000000000000000000001111";		
		    --slv_reg2               <= slv_reg0;	
		  --elsif ( slv_reg0(0 to 7) = "00000101" ) then
		    --slv_reg1               <= "00000000000000000000000000010000";		
		    --slv_reg2               <= slv_reg0;
		  --elsif ( slv_reg0(24 to 31) = "00000110" ) then
		    --slv_reg1               <= "00000000000000000000000000010001";		
		    --slv_reg2               <= slv_reg0;
		  --elsif ( slv_reg0 = X"00000007" ) then
		    --slv_reg1               <= X"00000012";		
		    --slv_reg2               <= slv_reg0;	 
		  --elsif ( slv_reg0 = X"00000008" ) then
		    --slv_reg1               <= X"00000013";		
		    --slv_reg2               <= slv_reg0;	 
		  --end if;
		  
      end if;
    end if;

  end process userlogic_control;

end IMP;
