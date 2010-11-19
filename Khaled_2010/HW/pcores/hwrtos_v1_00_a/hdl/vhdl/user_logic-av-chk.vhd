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
-- Date:              Tue Jun 02 12:44:13 2009 (by Create and Import Peripheral Wizard)
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
--   Bus2IP_Burst                 -- Bus to IP burst-mode qualifier
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
--   IP2Bus_MstNum                -- IP to Bus burst size indicator
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
    C_DWIDTH                       : integer              := 64;
    C_NUM_CE                       : integer              := 10;
    C_IP_INTR_NUM                  : integer              := 1
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
	 Int_Out								  : out std_logic;
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    IP2Bus_IntrEvent               : out std_logic_vector(0 to C_IP_INTR_NUM-1);
    Bus2IP_Data                    : in  std_logic_vector(0 to C_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_DWIDTH/8-1);
    Bus2IP_Burst                   : in  std_logic;
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
    IP2Bus_MstNum                  : out std_logic_vector(0 to 4);
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

  type task_rec is record
	stk_ptr:		std_logic_vector(0 to 31);
	stk_btm:		std_logic_vector(0 to 31);
	stk_size:		std_logic_vector(0 to 31);
	opt:			std_logic_vector(0 to 15);		--maybe not needed
	prio:			std_logic_vector(0 to 7);
	free:			std_logic;
	id:	    		std_logic_vector(0 to 15);
	event_ptr:		std_logic_vector(0 to 7);
	event_mptr: 	std_logic_vector(0 to 7);		--maybe not needed
	msg:			std_logic_vector(0 to 31);
	flag_node:		std_logic_vector(0 to 7);
	flags_rdy:		std_logic_vector(0 to 7);
	delay:			std_logic_vector(0 to 15);		--maybe need to change to integer
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);
	x:				std_logic_vector(0 to 7);
	y:				std_logic_vector(0 to 7);
	bitx:			std_logic_vector(0 to 7);
	bity:			std_logic_vector(0 to 7);
	delay_req:		std_logic;
	ctx_sw_cntr:	std_logic_vector(0 to 31);		--maybe not needed
	cycles_tot:  	std_logic_vector(0 to 31);		--maybe not needed
	cycles_start:	std_logic_vector(0 to 31);		--maybe not needed
	stk_base:		std_logic_vector(0 to 31);		--maybe not needed
	stk_used:		std_logic_vector(0 to 31);		--maybe not needed
	task_name:  	std_logic_vector(0 to 7);		--maybe not needed	
  end record task_rec;
  type task_arr is array(0 to 15) of task_rec;
  signal ostcb                         : task_arr := ((X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),	
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"));

  type task_create_rec is record
	stk_ptr:			std_logic_vector(0 to 31);
	stk_btm:			std_logic_vector(0 to 31);
	stk_size:			std_logic_vector(0 to 31);
	opt:				std_logic_vector(0 to 15);		--maybe not needed
	prio:				std_logic_vector(0 to 7);
	free:				std_logic;
	id:					std_logic_vector(0 to 15);
	event_ptr:			std_logic_vector(0 to 7);
	event_mptr:   		std_logic_vector(0 to 7);		--maybe not needed
	msg:				std_logic_vector(0 to 31);
	flag_node:			std_logic_vector(0 to 7);
	flags_rdy:			std_logic_vector(0 to 7);
	delay:				std_logic_vector(0 to 15);		--maybe need to change to integer
	stat:				std_logic_vector(0 to 7);
	stat_pend:			std_logic_vector(0 to 7);
	x:					std_logic_vector(0 to 7);
	y:					std_logic_vector(0 to 7);
	bitx:				std_logic_vector(0 to 7);
	bity:				std_logic_vector(0 to 7);
	delay_req:			std_logic;
	ctx_sw_cntr:		std_logic_vector(0 to 31);		--maybe not needed
	cycles_tot:   		std_logic_vector(0 to 31);		--maybe not needed
	cycles_start:		std_logic_vector(0 to 31);		--maybe not needed
	stk_base:			std_logic_vector(0 to 31);		--maybe not needed
	stk_used:			std_logic_vector(0 to 31);		--maybe not needed
	task_name:    		std_logic_vector(0 to 7);		--maybe not needed	
  end record task_create_rec;
  type task_create_arr is array(0 to 15) of task_create_rec;
  signal task_create_tcb        : task_create_arr := ((X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),	
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"),
													  (X"00000000", X"00000000", X"00000000", X"0000", X"00", '0', X"0000", X"00", X"00", X"00000000", X"00", X"00", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", '0', X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"3F"));
													
  
  type tick_rec is record
	delay:			std_logic_vector(0 to 15);		--maybe need to change to integer
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);	
  end record tick_rec;
  type tick_arr is array(0 to 15) of tick_rec;
  signal tick_tcb                       : tick_arr := ((X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"),
													   (X"0000", X"00", X"00"));	

  type task_av_chk_rec is record
	free:			std_logic;	
  end record task_av_chk_rec;
  type task_av_chk_arr is array(0 to 15) of task_av_chk_rec;
  signal task_av_chk_tcb                : task_av_chk_arr; 

--  type task_av_chk_arr is array(0 to 15) of std_logic;
--  signal task_av_chk_free             : task_av_chk_arr; 
															
															
  type time_delay_rec is record
	delay:			std_logic_vector(0 to 15);
	ctx_sw_cntr:	std_logic_vector(0 to 31);	
  end record time_delay_rec;
  type time_delay_arr is array(0 to 15) of time_delay_rec;
  signal time_delay_tcb                : time_delay_arr; 															
															 															 														
															
  
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
	
  signal osrdy_grp 						: std_logic_vector(0 to 7) := X"00";
  type rdy_tbl is array(0 to 7) of std_logic_vector(0 to 7);
  signal osrdy_tbl						: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");

  signal tick_rdy_grp 					: std_logic_vector(0 to 7) := X"00";
  signal tick_rdy_tbl					: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");

  signal task_create_rdy_grp 			: std_logic_vector(0 to 7) := X"00";
  signal task_create_rdy_tbl			: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");

  signal time_delay_rdy_grp 			: std_logic_vector(0 to 7) := X"00";
  signal time_delay_rdy_tbl				: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
	
  type event_tbl is array(0 to 7) of std_logic_vector(0 to 7);
  type event_rec is record
	osevent_type							: std_logic_vector(0 to 7);
	osevent_free							: std_logic;
	osevent_ptr								: std_logic_vector(0 to 31);		--maybe we need only 8 bits
	osevet_cnt								: std_logic_vector(0 to 15);
    osevent_grp 						    : std_logic_vector(0 to 7);
    osevent_tbl                             : event_tbl;
	osevent_name							: std_logic_vector(0 to 7);
  end record event_rec; 
  type event_arr is array(0 to 15) of event_rec;
  signal ecb                            : event_arr := ((X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"),
														(X"00", '0', X"00000000", X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"), X"3F"));

  type state_machine is (idle, internal, external);
  signal state     			            : state_machine := idle;

  signal cmd							: std_logic_vector(0 to 15) := X"0000"; 
  --cmd(15) = internal cmd (time tick)  
  --cmd(14) = external cmd (check task availability)
  --cmd(13) = external cmd (create task)
  --cmd(12) = external cmd (delete task)
  --cmd(11) = external cmd (change task priority)
  --cmd(10) = external cmd (os start)
  --cmd(9)  = external cmd (test)
  --cmd(8)  = external cmd (time delay)
  --others
  --cmd(0)  = external cmd (select output)

  signal ostime							: std_logic_vector(0 to 31) := X"00000000";  
  signal ostsk_cntr		    			: std_logic_vector(0 to 7)  := X"00";
  signal osrunning						: std_logic 				:= '0';
  signal osctx_sw_cntr        			: std_logic_vector(0 to 7)  := X"00";
  signal osidle_cntr	    			: std_logic_vector(0 to 31) := X"00000000";
  signal osidle_cntr_run	   			: std_logic_vector(0 to 7)  := X"00";
  signal osidle_cntr_max    			: std_logic_vector(0 to 7)  := X"00";    
  signal osstat_rdy						: std_logic 				:='0';
  signal osprio_current					: std_logic_vector(0 to 7)	:= X"00";
  signal osprio_high_rdy				: std_logic_vector(0 to 7)	:= X"00";
  signal ostsk_idle_prio    			: std_logic_vector(0 to 7)  := X"00";	

  signal timer_value					: std_logic_vector(0 to 31) := X"00000000";													
  signal cnt							: std_logic_vector(0 to 31) := X"00000000";													
  signal os_time_tick					: std_logic := '0';													
  signal hw_time_en						: std_logic := '0';														
  signal hw_time_dis					: std_logic := '0';	
  signal time_tick_rst					: std_logic := '0';																											
  signal tick_en						: std_logic := '0';   
  signal tick_out						: std_logic_vector(0 to 63) := X"0000000000000000";
  signal tick_int						: std_logic := '0';  										
  signal tick_update					: std_logic := '0';
  signal tick_update_d					: std_logic := '0';
  signal tick_upd_rst					: std_logic := '0';
  signal tick_sel						: std_logic := '0';
  signal tick_sel_d						: std_logic := '0'; 
  signal tick_sel_update				: std_logic := '0';
  signal tick_sel_update_d				: std_logic := '0';
  signal tick_sel_rst					: std_logic := '0';
														
  signal rst_en							: std_logic := '0';														
  signal rst_out						: std_logic_vector(0 to 63) := X"0000000000000000";	

  signal hw_init_en						: std_logic := '0';														

  signal task_av_chk_en					: std_logic := '0';
  signal task_av_chk_rst				: std_logic := '0';	
  signal task_av_chk_update				: std_logic := '0'; 
  signal task_av_chk_update_d			: std_logic := '0';
  signal task_av_chk_out				: std_logic_vector(0 to 63) := X"0000000000000000";														   
  
  signal task_create_en					: std_logic := '0';														
  signal task_create_rst				: std_logic := '0';
  signal task_create_update				: std_logic := '0';
  signal task_create_update_d			: std_logic := '0';
  signal task_create_out				: std_logic_vector(0 to 63) := X"0000000000000000";	  
  signal task_create_tsk_cntr  			: std_logic_vector(0 to 7)  := X"00";
  signal task_create_ctx_sw_cntr    	: std_logic_vector(0 to 7)  := X"00";
  signal task_create_prio_current		: std_logic_vector(0 to 7)	:= X"00";
  signal task_create_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";

  signal task_delete_en					: std_logic := '0';
  --signal cmd_task_delete_out			: std_logic_vector(0 to 63) := X"0000000000000000";

  signal task_chg_prio_en				: std_logic := '0';
  --signal cmd_task_chg_prio_out			: std_logic_vector(0 to 63) := X"0000000000000000";

  signal os_start_en					: std_logic := '0';
  signal os_start_rst					: std_logic := '0';
  signal os_start_update				: std_logic := '0';
  signal os_start_update_d				: std_logic := '0';
  signal os_start_out					: std_logic_vector(0 to 63) := X"0000000000000000";
  signal os_start_running				: std_logic 				:= '0';
  signal os_start_prio_current			: std_logic_vector(0 to 7)	:= X"00";
  signal os_start_prio_high_rdy			: std_logic_vector(0 to 7)	:= X"00"; 	

  signal test_en						: std_logic := '0';
  signal test_rst						: std_logic := '0';
  signal test_sel						: std_logic := '0';
  signal test_sel_d						: std_logic := '0';
  signal test_out0						: std_logic_vector(0 to 63) := X"0000000000000000";
  signal test_out1						: std_logic_vector(0 to 63) := X"0000000000000000";
  signal test_out2						: std_logic_vector(0 to 63) := X"0000000000000000";
  signal test_out3						: std_logic_vector(0 to 63) := X"0000000000000000";


  signal time_delay_en					: std_logic := '0';
  signal time_delay_rst					: std_logic := '0';
  signal time_delay_update				: std_logic := '0';
  signal time_delay_update_d			: std_logic := '0';
  signal time_delay_ctx_sw_cntr  	  	: std_logic_vector(0 to 7)  := X"00";
  signal time_delay_prio_current		: std_logic_vector(0 to 7)	:= X"00";
  signal time_delay_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";
  signal time_delay_out					: std_logic_vector(0 to 63) := X"0000000000000000";
	 
  signal update_clk						: std_logic := '0'; 
  signal update_case					: std_logic_vector(0 to 7) := X"00";
  signal select_clk						: std_logic := '0';  
  signal select_case					: std_logic_vector(0 to 7) := X"00";
  
  signal sw_bit						: std_logic := '0'; 



	

  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg2                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg3                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg4                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg5                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg6                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg7                       : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_reg_write_select           : std_logic_vector(0 to 7);
  signal slv_reg_read_select            : std_logic_vector(0 to 7);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

  ------------------------------------------
  -- Signals for user logic master model example
  ------------------------------------------
  -- signals for write/read data
  signal mst_ip2bus_data                : std_logic_vector(0 to C_DWIDTH-1);
  signal mst_reg_read_request           : std_logic;
  signal mst_reg_write_select           : std_logic_vector(0 to 1);
  signal mst_reg_read_select            : std_logic_vector(0 to 1);
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
  type MASTER_CNTL_SM_TYPE is (IDLE, SINGLE, BURST_16, LAST_BURST, CHK_BURST_DONE);
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
  signal mst_sm_ip2bus_mstnum           : std_logic_vector(0 to 4);
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
  slv_reg_write_select <= Bus2IP_WrCE(0 to 7);
  slv_reg_read_select  <= Bus2IP_RdCE(0 to 7);
  slv_write_ack        <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2) or Bus2IP_WrCE(3) or Bus2IP_WrCE(4) or Bus2IP_WrCE(5) or Bus2IP_WrCE(6) or Bus2IP_WrCE(7);
  slv_read_ack         <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2) or Bus2IP_RdCE(3) or Bus2IP_RdCE(4) or Bus2IP_RdCE(5) or Bus2IP_RdCE(6) or Bus2IP_RdCE(7);

  -- implement slave model register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
        slv_reg2 <= (others => '0');
        slv_reg3 <= (others => '0');
        --slv_reg4 <= (others => '0');
        --slv_reg5 <= (others => '0');
        --slv_reg6 <= (others => '0');
        --slv_reg7 <= (others => '0');
      else
        case slv_reg_write_select is
          when "10000000" =>
            for byte_index in 0 to (C_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "01000000" =>
            for byte_index in 0 to (C_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00100000" =>
            for byte_index in 0 to (C_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg2(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "00010000" =>
            for byte_index in 0 to (C_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg3(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          --when "00001000" =>
          --  for byte_index in 0 to (C_DWIDTH/8)-1 loop
          --    if ( Bus2IP_BE(byte_index) = '1' ) then
          --      slv_reg4(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
          --    end if;
          --  end loop;
          --when "00000100" =>
          --  for byte_index in 0 to (C_DWIDTH/8)-1 loop
          --    if ( Bus2IP_BE(byte_index) = '1' ) then
          --      slv_reg5(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
          --    end if;
          --  end loop;
          --when "00000010" =>
          --  for byte_index in 0 to (C_DWIDTH/8)-1 loop
          --   if ( Bus2IP_BE(byte_index) = '1' ) then
          --      slv_reg6(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
          --    end if;
          --  end loop;
          --when "00000001" =>
          --  for byte_index in 0 to (C_DWIDTH/8)-1 loop
          --    if ( Bus2IP_BE(byte_index) = '1' ) then
          --     slv_reg7(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
          --    end if;
          --  end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model register read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_select, slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7 ) is
  begin

    case slv_reg_read_select is
      when "10000000" => slv_ip2bus_data <= slv_reg0;
      when "01000000" => slv_ip2bus_data <= slv_reg1;
      when "00100000" => slv_ip2bus_data <= slv_reg2;
      when "00010000" => slv_ip2bus_data <= slv_reg3;
      when "00001000" => slv_ip2bus_data <= slv_reg4;
      when "00000100" => slv_ip2bus_data <= slv_reg5;
      when "00000010" => slv_ip2bus_data <= slv_reg6;
      when "00000001" => slv_ip2bus_data <= slv_reg7;
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
  mst_reg_read_request <= Bus2IP_RdCE(8) or Bus2IP_RdCE(9);
  mst_reg_write_select <= Bus2IP_WrCE(8 to 9);
  mst_reg_read_select  <= Bus2IP_RdCE(8 to 9);
  mst_write_ack        <= Bus2IP_WrCE(8) or Bus2IP_WrCE(9);
  mst_read_ack         <= Bus2IP_RdCE(8) or Bus2IP_RdCE(9);

  -- user logic master request output assignments
  IP2Bus_Addr          <= mst_sm_ip2bus_addr;
  IP2Bus_MstBE         <= mst_sm_ip2bus_be;
  IP2Bus_MstBurst      <= mst_sm_burst;
  IP2Bus_MstBusLock    <= mst_sm_bus_lock;
  IP2Bus_MstNum        <= mst_sm_ip2bus_mstnum;
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
  mst_ip2bus_be        <= mst_reg(14);

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
      when "10" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg(byte_index);
        end loop;
      when "01" =>
        for byte_index in 0 to C_DWIDTH/8-1 loop
          if ( byte_index = C_DWIDTH/8-1 ) then
            -- go port is not readable
            mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= (others => '0');
          else
            mst_ip2bus_data(byte_index*8 to byte_index*8+7) <= mst_reg((C_DWIDTH/8)*1+byte_index);
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
        mst_sm_ip2bus_mstnum <= "00000";
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
        mst_sm_ip2bus_mstnum <= "00000";
        mst_sm_set_done      <= '0';
        mst_sm_busy          <= '1';

        -- state transition
        case mst_cntl_state is

          when IDLE =>
            if ( mst_go = '1' and mst_xfer_length <= 8 ) then
              -- single beat transfer
              mst_cntl_state       <= SINGLE;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            elsif ( mst_go = '1' and mst_xfer_length < 128 ) then
              -- burst transfer less than 128 bytes
              mst_cntl_state       <= LAST_BURST;
              mst_sm_clr_go        <= '1';
              mst_xfer_count       <= CONV_INTEGER(mst_xfer_length);
              mst_bus_addr_count   <= CONV_INTEGER(mst_ip2bus_addr);
              mst_ip_addr_count    <= CONV_INTEGER(mst_ip2ip_addr);
            elsif ( mst_go = '1' ) then
              -- burst transfer greater than 128 bytes
              mst_cntl_state       <= BURST_16;
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
              mst_sm_ip2bus_mstnum <= "00001";
            end if;

          when BURST_16 =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= CHK_BURST_DONE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_xfer_count       <= mst_xfer_count-128;
              mst_bus_addr_count   <= mst_bus_addr_count+128;
              mst_ip_addr_count    <= mst_ip_addr_count+128;
            else
              mst_cntl_state       <= BURST_16;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_burst         <= mst_cntl_burst;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= (others => '1');
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
              mst_sm_ip2bus_mstnum <= "10000"; -- 16 double words
            end if;

          when LAST_BURST =>
            if ( Bus2IP_MstLastAck = '1' ) then
              mst_cntl_state       <= CHK_BURST_DONE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_xfer_count       <= mst_xfer_count-((mst_xfer_count/8)*8);
              mst_bus_addr_count   <= mst_bus_addr_count+(mst_xfer_count/8)*8;
              mst_ip_addr_count    <= mst_ip_addr_count+(mst_xfer_count/8)*8;
            else
              mst_cntl_state       <= LAST_BURST;
              mst_sm_rd_req        <= mst_cntl_rd_req;
              mst_sm_wr_req        <= mst_cntl_wr_req;
              mst_sm_burst         <= mst_cntl_burst;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
              mst_sm_ip2bus_addr   <= CONV_STD_LOGIC_VECTOR(mst_bus_addr_count, C_AWIDTH);
              mst_sm_ip2bus_be     <= (others => '1');
              mst_sm_ip2ip_addr    <= CONV_STD_LOGIC_VECTOR(mst_ip_addr_count, C_AWIDTH);
              mst_sm_ip2bus_mstnum <= CONV_STD_LOGIC_VECTOR((mst_xfer_count/8), 5);
            end if;

          when CHK_BURST_DONE =>
            if ( mst_xfer_count = 0 ) then
              -- transfer done
              mst_cntl_state       <= IDLE;
              mst_sm_set_done      <= '1';
              mst_sm_busy          <= '0';
            elsif ( mst_xfer_count <= 8 ) then
              -- need single beat transfer
              mst_cntl_state       <= SINGLE;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            elsif ( mst_xfer_count < 128 ) then
              -- need burst transfer less than 128 bytes
              mst_cntl_state       <= LAST_BURST;
              mst_sm_bus_lock      <= mst_cntl_bus_lock;
            else
              -- need burst transfer greater than 128 bytes
              mst_cntl_state       <= BURST_16;
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
  --IP2Bus_IntrEvent(0)	<= tick_int or sw_bit;
  Int_Out					<= tick_int or sw_bit;

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

--  userlogic_control: process( Bus2IP_Clk ) is
     --variable index   			: integer range 0 to 255;
	 --variable priority	        : integer range 0 to 255;
	 --variable temp_y_int	   	: integer range 0 to 255;
	 --variable temp_y_un	    	: unsigned(0 to 7);
	 --variable temp_y_std	   	: std_logic_vector(0 to 7);
	 --variable temp_x_std	   	: std_logic_vector(0 to 7);
	 --variable temp_Hprio1     	: std_logic_vector(0 to 7);
	 --variable temp_Hprio2     	: std_logic_vector(0 to 7);
	 --variable prio_high	     	: std_logic_vector(0 to 7);
	 
	 --variable temp1 	      	: std_logic_vector(0 to 7);
	 --variable temp2 	      	: std_logic_vector(0 to 7);
	 --variable temp3 	      	: std_logic_vector(0 to 7);
	 --variable temp4 	      	: std_logic_vector(0 to 7);
	 --variable temp5 	      	: std_logic_vector(0 to 7);
	
  --begin

	--if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
	  --if Bus2IP_Reset = '1' then
		--slv_reg1 <= (others => '0');
	  --else 
						
	    --case slv_reg3(24 to 31) is								--Calculate y, bity, x, bitx for a task
		  --when X"01" =>
		    --index      := CONV_INTEGER(slv_reg3(16 to 23));
		    --temp_y_un  := shr(UNSIGNED(slv_reg3(8 to 15)),CONV_UNSIGNED(3,2));
		    --temp_x_std := slv_reg3(8 to 15) and X"07";
		    --task(index).prio       <= slv_reg3(8 to 15); 
		    --task(index).y	       <= STD_LOGIC_VECTOR(temp_y_un); 		     
            --task(index).x	       <= temp_x_std;	             
		    --task(index).bity       <= STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),temp_y_un));			    
		    --task(index).bitx       <= STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),UNSIGNED(temp_x_std)));
		
		    --temp1                  := slv_reg3(8 to 15);	
		    --temp2       	       := STD_LOGIC_VECTOR(temp_y_un);
		    --temp3       	       := temp_x_std;
		    --temp4                  := STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),temp_y_un));	
		    --temp5                  := STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),UNSIGNED(temp_x_std)));
		    --slv_reg1               <= temp3 & temp2 & temp1 & X"01";
		    --slv_reg2               <= X"00" & STD_LOGIC_VECTOR(CONV_UNSIGNED(index,8)) & temp5 & temp4;								 
		  			
		  --when X"02" =>											--Put a task in the ready list
		    --index 	   := CONV_INTEGER(slv_reg3(16 to 23));
		    --temp_y_int := CONV_INTEGER(task(index).y);
		    --osrdygrp 		   	   <= osrdygrp or task(index).bity;
		    --osrdytbl(temp_y_int)   <= osrdytbl(temp_y_int) or task(index).bitx;
		
		    --temp1                  := osrdygrp or task(index).bity;
		    --temp2       	       := osrdytbl(temp_y_int) or task(index).bitx;
		    --temp3       	       := task(index).bitx;		    
		    --slv_reg1               <= temp3 & temp2 & temp1 & X"01";
            --slv_reg2               <= slv_reg3(16 to 23) & osrdytbl(temp_y_int) & task(index).bity & osrdygrp;		    
				  				
		  --when X"03" =>											--Find the highest priority task in the ready list
		    --temp_y_std  := b"00000" & osunmaptbl(CONV_INTEGER(osrdygrp));
			--temp_Hprio1 := STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
			--temp_Hprio2 := b"00000" & osunmaptbl(CONV_INTEGER(osrdytbl(CONV_INTEGER(temp_y_std))));
		    --prio_high   := temp_Hprio1 + temp_Hprio2;
		    --slv_reg1               <= osrdygrp & temp_y_std & prio_high & X"01";
			--slv_reg2               <= X"00" & osrdytbl(CONV_INTEGER(temp_y_std)) & temp_Hprio2 & temp_Hprio1;			
		  			
		  --when X"04" =>											--remove a task from the ready list
		    --index 	   := CONV_INTEGER(slv_reg3(16 to 23));
		    --temp_y_int := CONV_INTEGER(task(index).y);
		    --temp_y_std := osrdytbl(temp_y_int) and (not task(index).bitx);
		    --osrdytbl(temp_y_int) <= temp_y_std;
		    --if (temp_y_std = "00000000") then
			  --osrdygrp 		         <= osrdygrp and (not task(index).bity);
		    --end if;  
		
		    --temp1                  := osrdygrp and (not task(index).bity);		    
		    --temp2       	       := task(index).y;		    
		    --slv_reg1               <= temp_y_std & temp2 & temp1 & X"01";
		
		  --when X"05" =>											--Put a task in the wait list
		    --index      := CONV_INTEGER(slv_reg3(16 to 23));
		    --priority   := CONV_INTEGER(slv_reg3(8 to 15));
		    --temp_y_int := CONV_INTEGER(task(priority).y);
		    --ecb(index).oseventtbl(temp_y_int) <= ecb(index).oseventtbl(temp_y_int) or task(priority).bitx;
		    --ecb(index).oseventgrp		      <= ecb(index).oseventgrp or task(priority).bity;
		
		    --temp1                  := ecb(index).oseventtbl(temp_y_int) or task(priority).bitx;
		    --temp2       	       := ecb(index).oseventgrp or task(priority).bity;
		    --temp3       	       := task(priority).y;		    
		    --slv_reg1               <= temp3 & temp2 & temp1 & X"01";	
		
		  --when X"06" =>											--Find the highest priority task in the wait list
			--index 	    := CONV_INTEGER(slv_reg3(16 to 23));
		    --temp_y_std  := b"00000" & osunmaptbl(CONV_INTEGER(ecb(index).oseventgrp));
		    --temp_Hprio1 := STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
		    --temp_Hprio2 := b"00000" & osunmaptbl(CONV_INTEGER(ecb(index).oseventtbl(CONV_INTEGER(temp_y_std))));
		    --prio_high   := temp_Hprio1 + temp_Hprio2;
		    --slv_reg1               <= X"00" & temp_y_std & prio_high & X"01";
		
		  --when X"07" =>											--remove a task from the wait list
		    --index 	   := CONV_INTEGER(slv_reg3(16 to 23));
		    --priority   := CONV_INTEGER(slv_reg3(8 to 15));
		    --temp_y_int := CONV_INTEGER(task(priority).y);
			--temp_y_std := ecb(index).oseventtbl(temp_y_int)and (not task(priority).bitx);
		    --ecb(index).oseventtbl(temp_y_int) <= temp_y_std;
		    --if (temp_y_std = "00000000") then
		      --ecb(index).oseventgrp           <= ecb(index).oseventgrp and (not task(priority).bity);
		    --end if;
		
		    --temp1                  := ecb(index).oseventgrp and (not task(priority).bity);		    
		    --temp2       	       := task(priority).y;		    
		    --slv_reg1               <= temp_y_std & temp2 & temp1 & X"01";
				   		
		  --when X"08" =>											--Initialize
		    --osrdygrp					<= X"00";
			--osrdytbl(0)				<= X"00";
			--osrdytbl(1)				<= X"00";
			--osrdytbl(2)				<= X"00";
			--osrdytbl(3)				<= X"00";
			--osrdytbl(4)				<= X"00";
			--osrdytbl(5)				<= X"00";
			--osrdytbl(6)				<= X"00";
			--osrdytbl(7)				<= X"00";
			
			--slv_reg1               <= X"00000001";		
		    --slv_reg2               <= slv_reg3;
							
		  --when X"09" =>											--Test
		    --slv_reg1               <= X"00000001";		
		    --slv_reg2               <= slv_reg3;
		  
		  --when others => 
		    --slv_reg1               <= (others => '0');
		  
        --end case;		  		 		 
		  
      --end if;
    --end if;

  --end process userlogic_control;


hwrtos_decode: process( Bus2IP_Clk ) is    
	
  begin

	if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
	  if Bus2IP_Reset = '1' then
		cmd(0 to 14)				<= B"000000000000000";	
		hw_init_en					<= '0';	
		hw_time_en					<= '0';
		hw_time_dis					<= '0';												
	  else 	
	    case slv_reg0(56 to 63) is
		  when X"00" => 										--Command reset
			cmd(0 to 14)			<= B"000000000000000";																
			hw_init_en				<= '0';
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	
			
		  when X"01" =>											--HW/OS initialize
			cmd(0 to 14)			<= B"000000000000000";																
			hw_init_en				<= '1';
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	
						
		  when X"02" =>											--Select internal output
		 	cmd(0 to 14)			<= B"100000000000000";																
			hw_init_en				<= '0';	
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	
							
		  when X"03" =>											--Check task availability & reserve it if available
		 	cmd(0 to 14)			<= B"100000000000001";																
			hw_init_en				<= '0';
			hw_time_en				<= '0';
			hw_time_dis				<= '0';							 

		  when X"04" =>											--Task create
		    cmd(0 to 14)			<= B"100000000000010";																
			hw_init_en				<= '0';	
			hw_time_en				<= '0';
			hw_time_dis				<= '0';						 						 		  			
		  			
		  when X"05" =>											--Task delete
		   	cmd(0 to 14)			<= B"100000000000100";																
			hw_init_en				<= '0';	
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	
			
		  when X"06" =>											--Change task priority
		   	cmd(0 to 14)			<= B"100000000001000";																
			hw_init_en				<= '0';	
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	
			
		  when X"07" =>											--OS start
		   	cmd(0 to 14)			<= B"100000000010000";																
			hw_init_en				<= '0'; 
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	 				  				
			
		  when X"08" =>											--Test
			cmd(0 to 14)			<= B"100000000100000";																
			hw_init_en				<= '0';
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	
			
		  when X"09" =>											--Time delay
			cmd(0 to 14)			<= B"100000001000000";																
			hw_init_en				<= '0';
			hw_time_en				<= '0';
			hw_time_dis				<= '0';	
			
		  when X"0A" =>											--Time tick enabled
			cmd(0 to 14)			<= B"100000000000000";																
			hw_init_en				<= '0';
			hw_time_en				<= '1';
			hw_time_dis				<= '0';
			
		  when X"0B" =>											--Time tick disabled
			cmd(0 to 14)			<= B"100000000000000";																
			hw_init_en				<= '0';
			hw_time_en				<= '0';
			hw_time_dis				<= '1';
		   			 
		  when others => 										--Command reset
			cmd(0 to 14)			<= B"000000000000000";																
			hw_init_en				<= '0';	
			hw_time_en				<= '0';
			hw_time_dis				<= '0';		    
		  
        end case;		  		 		 		  
      end if;
    end if;
  end process hwrtos_decode;


hwrtos_state_machine : process( Bus2IP_Clk ) is

  begin
    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        state			       		<= idle; 
		rst_en						<= '1';
		tick_en						<= '0';
		tick_sel					<= '0';
		task_av_chk_en				<= '0';
		task_create_en				<= '0';
		task_delete_en				<= '0';				
		task_chg_prio_en			<= '0';		
		os_start_en					<= '0';
		test_en						<= '0';
		time_delay_en				<= '0';
      else       
        case state is
          when idle =>
            if ( cmd = X"0000" ) then             
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';
			  task_av_chk_en		<= '0';
			  task_create_en		<= '0';
			  task_delete_en		<= '0';				
			  task_chg_prio_en		<= '0';		
			  os_start_en			<= '0';
			  test_en				<= '0';
			  time_delay_en			<= '0';
              
            elsif ( (cmd = X"0001") or (cmd = X"8003") or (cmd = X"8005") or (cmd = X"8009") or (cmd = X"8011") or (cmd = X"8021") or (cmd = X"8041") or (cmd = X"8081") ) then             
              state					<= internal;
			  rst_en				<= '0';
			  tick_en				<= '1';
              
            elsif ( (cmd = X"8000") or (cmd = X"8002") or (cmd = X"8004") or (cmd = X"8008") or (cmd = X"8010") or (cmd = X"8020") or (cmd = X"8040") or (cmd = X"8080") ) then              
              state					<= external;
			  if (cmd = X"8000") then
				rst_en				<= '0';
				tick_sel			<= '1';
			  elsif (cmd = X"8002") then
				rst_en				<= '0';
				task_av_chk_en		<= '1';
			  elsif (cmd = X"8004") then
				rst_en				<= '0';
				task_create_en		<= '1';
			  elsif (cmd = X"8008") then
				rst_en				<= '0';
				task_delete_en		<= '1';
			  elsif (cmd = X"8010") then
				rst_en				<= '0';
				task_chg_prio_en	<= '1';
			  elsif (cmd = X"8020") then
				rst_en				<= '0';
				os_start_en			<= '1';
			  elsif (cmd = X"8040") then
				rst_en				<= '0';
				test_en				<= '1';
			  elsif (cmd = X"8080") then
				rst_en				<= '0';
				time_delay_en		<= '1';
			  end if;
			
            else
              state					<= idle;
              rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';
			  task_av_chk_en		<= '0';
			  task_create_en		<= '0';
			  task_delete_en		<= '0';				
			  task_chg_prio_en		<= '0';		
			  os_start_en			<= '0';
			  test_en				<= '0';
			  time_delay_en			<= '0';
            end if;

          when internal =>
            if ( (cmd = X"0001") or (cmd = X"8003") or (cmd = X"8005") or (cmd = X"8009") or (cmd = X"8011") or (cmd = X"8021") or (cmd = X"8041") or (cmd = X"8081") ) then             
              state					<= internal;
			  rst_en				<= '0';
			  tick_en				<= '1';
			  tick_sel				<= '0';
			  task_av_chk_en		<= '0';
			  task_create_en		<= '0';
			  task_delete_en		<= '0';				
			  task_chg_prio_en		<= '0';		
			  os_start_en			<= '0';
			  test_en				<= '0';
			  time_delay_en			<= '0';
              
            elsif ( (cmd = X"8000") or (cmd = X"8002") or (cmd = X"8004") or (cmd = X"8008") or (cmd = X"8010") or (cmd = X"8020") or (cmd = X"8040") or (cmd = X"8080") ) then             
              state					<= external;
			  if (cmd = X"8000") then
				tick_en				<= '0';
				tick_sel			<= '1';
			  elsif (cmd = X"8002") then
				tick_en				<= '0';
				task_av_chk_en		<= '1';
			  elsif (cmd = X"8004") then
				tick_en				<= '0';
				task_create_en		<= '1';
			  elsif (cmd = X"8008") then
				tick_en				<= '0';
				task_delete_en		<= '1';
			  elsif (cmd = X"8010") then
				tick_en				<= '0';
				task_chg_prio_en	<= '1';
			  elsif (cmd = X"8020") then
				tick_en				<= '0';
				os_start_en			<= '1';
			  elsif (cmd = X"8040") then
				tick_en				<= '0';
				test_en				<= '1';
			  elsif (cmd = X"8080") then
				tick_en				<= '0';
				time_delay_en		<= '1';
			  end if;
              
            elsif ( cmd = X"0000" ) then              
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
              
            else
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';
			  task_av_chk_en		<= '0';
			  task_create_en		<= '0';
			  task_delete_en		<= '0';				
			  task_chg_prio_en		<= '0';		
			  os_start_en			<= '0';
			  test_en				<= '0';
			  time_delay_en			<= '0';              
            end if;

          when external =>
            if ( (cmd = X"8000") or (cmd = X"8002") or (cmd = X"8004") or (cmd = X"8008") or (cmd = X"8010") or (cmd = X"8020") or (cmd = X"8040") or (cmd = X"8080") or (cmd = X"8003") or (cmd = X"8005") or (cmd = X"8009") or (cmd = X"8011") or (cmd = X"8021") or (cmd = X"8041") or (cmd = X"8081") ) then             
              state					<= external;
			  if (cmd = X"8000") then
				rst_en				<= '0';
				tick_en				<= '0';
				tick_sel			<= '1';
			  elsif ((cmd = X"8002") or (cmd = X"8003")) then
				rst_en				<= '0';
				tick_en				<= '0';
				task_av_chk_en		<= '1';
			  elsif ((cmd = X"8004") or (cmd = X"8005")) then
				rst_en				<= '0';
				tick_en				<= '0';
				task_create_en		<= '1';
			  elsif ((cmd = X"8008") or (cmd = X"8009")) then
				rst_en				<= '0';
				tick_en				<= '0';
				task_delete_en		<= '1';
			  elsif ((cmd = X"8010") or (cmd = X"8011")) then
				rst_en				<= '0';
				tick_en				<= '0';
				task_chg_prio_en	<= '1';
			  elsif ((cmd = X"8020") or (cmd = X"8021")) then
				rst_en				<= '0';
				tick_en				<= '0';
				os_start_en			<= '1';
			  elsif ((cmd = X"8040") or (cmd = X"8041")) then
				rst_en				<= '0';
				tick_en				<= '0';
				test_en				<= '1';
			  elsif ((cmd = X"8080") or (cmd = X"8081")) then
				rst_en				<= '0';
				tick_en				<= '0';
				time_delay_en		<= '1';
			  end if;
              
            elsif ( cmd = X"0001" ) then             
              state					<= internal;
			  rst_en				<= '0';
			  tick_en				<= '1';
			  tick_sel				<= '0';
			  task_av_chk_en		<= '0';
			  task_create_en		<= '0';
			  task_delete_en		<= '0';				
			  task_chg_prio_en		<= '0';		
			  os_start_en			<= '0';
			  test_en				<= '0';
			  time_delay_en			<= '0';
              
            elsif ( cmd = X"0000" ) then              
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';
			  task_av_chk_en		<= '0';
			  task_create_en		<= '0';
			  task_delete_en		<= '0';				
			  task_chg_prio_en		<= '0';		
			  os_start_en			<= '0';
			  test_en				<= '0';
			  time_delay_en			<= '0';
              
            else
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';
			  task_av_chk_en		<= '0';
			  task_create_en		<= '0';
			  task_delete_en		<= '0';				
			  task_chg_prio_en		<= '0';		
			  os_start_en			<= '0';
			  test_en				<= '0';
			  time_delay_en			<= '0';
              
            end if;
          
          when others =>
            state    				<= idle;  
			rst_en					<= '1';
			tick_en					<= '0';
			tick_sel				<= '0';
			task_av_chk_en			<= '0';
			task_create_en			<= '0';
			task_delete_en			<= '0';				
			task_chg_prio_en		<= '0';		
			os_start_en				<= '0';
			test_en					<= '0';
			time_delay_en			<= '0';

        end case;
      end if;
    end if;
  end process hwrtos_state_machine;


hwrtos_reset: process( rst_en ) is  						--maybe not needed  
  
  begin	
	if rst_en'event and rst_en = '1' then
		rst_out      				<= (others => '0');
	end if;									 		  			     	  	 
  end process hwrtos_reset;


hwrtos_hwos_init: process( hw_init_en ) is  
  
  begin	
	if hw_init_en'event and hw_init_en = '1' then
		ostsk_idle_prio   		 	<= slv_reg0(48 to 55);		
		--timer_value	 			 <= plb_clk / os_tick_per_sec;   (80000000 / 100 = 800000 (20 bits counter))
		--for the mean time set timer_value fixed = 800000
		--timer_value					<= X"C3500";
		timer_value					   <= slv_reg0(16 to 47);
		sw_bit							<= slv_reg0(15);
	end if;									 		  			     	  	 
  end process hwrtos_hwos_init;


--hwrtos_task_idle: process( Bus2IP_Clk ) is      			--could use os_time_tick (ask prof.)
															-- I think better to keep it in sw (ask prof.)
--  begin	
--	if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
--		if (osprio_high_rdy = ostsk_idle_prio) then
--			osidle_cntr   			<= osidle_cntr + 1;
--		end if;
--	end if;									 		  			     	  	 
--  end process hwrtos_task_idle;


hwrtos_os_time_enable: process( hw_time_en, hw_time_dis ) is    

  begin	
	if hw_time_dis = '1' then		
		time_tick_rst				<= '0';
	elsif hw_time_en'event and hw_time_en = '1' then
		time_tick_rst   			<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_os_time_enable;


hwrtos_os_time_tick: process( Bus2IP_Clk, time_tick_rst ) is    

  begin	
	if time_tick_rst = '0' then		
		os_time_tick				<= '0';
	elsif Bus2IP_Clk'event and Bus2IP_Clk = '1' then
		cnt							<= cnt + 1;
		if (cnt = (timer_value - 1)) then
			os_time_tick   			<= '1';
			cnt						<= X"00000000";
		else os_time_tick   		<= '0';
		end if;
	end if;									 		  			     	  	 
  end process hwrtos_os_time_tick;


hwrtos_tick_en: process( os_time_tick, tick_upd_rst ) is    

  begin	
	if tick_upd_rst = '1' then		
		cmd(15)						<= '0';
	elsif os_time_tick'event and os_time_tick = '1' then
		cmd(15)						<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_tick_en;


hwrtos_tick_act: process( tick_en, tick_upd_rst, tick_sel_rst ) is      
  variable temp_y_int  		: integer range 0 to 255 := 0;       
  variable temp_y_std	   	: std_logic_vector(0 to 7) := X"00"; 
  variable temp_Hprio1     	: std_logic_vector(0 to 7) := X"00";
  variable temp_Hprio2     	: std_logic_vector(0 to 7) := X"00";
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";   
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";  
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  variable delay_v			: std_logic_vector(0 to 15) := X"0000";		
  variable stat_v			: std_logic_vector(0 to 7) := X"00";
  variable stat_pend_v		: std_logic_vector(0 to 7) := X"00";

  begin	
	if tick_upd_rst = '1' then		
		tick_update						<= '0';		
    elsif tick_sel_rst = '1' then
        tick_int						<= '0';
		tick_out						<= (others => '0');																
	elsif tick_en'event and tick_en = '1' then		
		ostime							<= ostime +1;				
		if (osrunning = '1') then				
			rdy_grp_v					:= osrdy_grp;
			rdy_tbl_v					:= osrdy_tbl;
			for i in 0 to 15 loop
				delay_v					:= ostcb(i).delay;
				stat_v					:= ostcb(i).stat;
				stat_pend_v				:= ostcb(i).stat_pend;				
				if (delay_v /= X"0000") then
					delay_v				:= delay_v - 1;					
					if (delay_v = X"0000") then
						if ((stat_v and X"37") /= X"00") then				--pending timeout
							stat_v		:= stat_v and X"C8";
							stat_pend_v	:= X"01";
						else
							stat_pend_v	:= X"00";				
						end if;
						--if ((stat_v and X"08") = X"00") then				--task suspend check					
							temp_y_int  				:= CONV_INTEGER(ostcb(i).y);
							rdy_grp_v 				  	:= rdy_grp_v or ostcb(i).bity;
							rdy_tbl_v(temp_y_int)	:= rdy_tbl_v(temp_y_int) or ostcb(i).bitx;												
						--end if;					
					end if;	
				end if;
				tick_tcb(i).delay		<= delay_v;
				tick_tcb(i).stat		<= stat_v;
				tick_tcb(i).stat_pend	<= stat_pend_v;	
			end loop;	
			tick_rdy_grp				<= rdy_grp_v;
			tick_rdy_tbl				<= rdy_tbl_v;		
			temp_y_std  := b"00000" & osunmaptbl(CONV_INTEGER(rdy_grp_v));
			temp_Hprio1 := STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
			temp_Hprio2 := b"00000" & osunmaptbl(CONV_INTEGER(rdy_tbl_v(CONV_INTEGER(temp_y_std))));
			prio_high   := temp_Hprio1 + temp_Hprio2;			
			if (prio_high /= osprio_current) then			    	
				tick_out				<= X"0000000000" & prio_high & osprio_current & X"01";									 		  			     	  	 
				tick_int				<= '1';  			
			end if;															
			tick_update					<= '1';                                                   		
		end if;		
	end if;	
  end process hwrtos_tick_act;


hwrtos_task_availability: process( task_av_chk_en, task_av_chk_rst ) is    
  variable index   			: integer range 0 to 15 := 0; 
  variable free_v			: std_logic := '0'; 

  begin	
	if task_av_chk_rst = '1' then
		task_av_chk_out					<= (others => '0');
		task_av_chk_update				<= '0';
	elsif task_av_chk_en'event and task_av_chk_en = '1' then		
		index 	        := CONV_INTEGER(slv_reg0(48 to 55));
		free_v			:= ostcb(index).free;
		if (free_v = '0') then
			free_v 		:= '1';
		end if;		
		task_av_chk_tcb(index).free		<= free_v;
		task_av_chk_out     			<= X"0000000000000" & B"000" & ostcb(index).free & X"01";									 		  			     	  	 
		task_av_chk_update				<= '1';
	end if;	
  end process hwrtos_task_availability;



hwrtos_task_create: process( task_create_en, task_create_rst ) is  					  
  variable index   			: integer range 0 to 15 := 0;
  variable hindex   		: integer range 0 to 15 := 0;
  variable temp_y_un	    : unsigned(0 to 7) := X"00";  
  variable temp_y_int	   	: integer range 0 to 255 := 0;
  variable temp_y_std	   	: std_logic_vector(0 to 7) := X"00";  
  variable temp_Hprio1     	: std_logic_vector(0 to 7) := X"00";
  variable temp_Hprio2     	: std_logic_vector(0 to 7) := X"00";
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00";
  variable x_v			   	: std_logic_vector(0 to 7) := X"00";
  variable y_v			   	: std_logic_vector(0 to 7) := X"00";
  variable bitx_v 		   	: std_logic_vector(0 to 7) := X"00";
  variable bity_v		   	: std_logic_vector(0 to 7) := X"00";
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";  
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  
  begin	
	if task_create_rst = '1' then
		task_create_out					<= (others => '0');
		task_create_update				<= '0';
	elsif task_create_en'event and task_create_en = '1' then			
		index 	    := CONV_INTEGER(slv_reg0(48 to 55));
		task_create_tcb(index).stk_ptr 		<= slv_reg0(0 to 31);
		task_create_tcb(index).prio	   		<= slv_reg0(48 to 55);
		task_create_tcb(index).stat	   		<= X"00";
		task_create_tcb(index).stat_pend  	<= X"00";
		task_create_tcb(index).delay	   	<= X"0000";
		task_create_tcb(index).stk_size   	<= slv_reg1(0 to 31);
		task_create_tcb(index).stk_btm    	<= slv_reg1(32 to 63);
		task_create_tcb(index).opt 	    	<= slv_reg2(48 to 63);
		task_create_tcb(index).id		   	<= slv_reg0(32 to 47);
		task_create_tcb(index).delay_req  	<= '0';
		temp_y_un  	:= shr(UNSIGNED(slv_reg0(48 to 55)),CONV_UNSIGNED(3,2));		
		y_v					          		:= STD_LOGIC_VECTOR(temp_y_un); 		     
        x_v							 		:= slv_reg0(48 to 55) and X"07";	             
	    bity_v					       	 	:= STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),temp_y_un));			    
	    bitx_v					        	:= STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),UNSIGNED(x_v)));						
		task_create_tcb(index).event_ptr  	<= X"00";
		task_create_tcb(index).event_mptr	<= X"00";
		task_create_tcb(index).flag_node  	<= X"00";
		task_create_tcb(index).msg			<= X"00000000";
		task_create_tcb(index).ctx_sw_cntr	<= X"00000000";
		task_create_tcb(index).cycles_start <= X"00000000";
		task_create_tcb(index).cycles_tot  	<= X"00000000";
		task_create_tcb(index).stk_base	    <= X"00000000";
		task_create_tcb(index).stk_used	  	<= X"00000000";
		task_create_tcb(index).task_name	<= slv_reg2(40 to 47);
		temp_y_int 	:= CONV_INTEGER(y_v);
		rdy_grp_v							:= osrdy_grp;
		rdy_tbl_v							:= osrdy_tbl;
		rdy_grp_v 		   	   				:= rdy_grp_v or bity_v;
		rdy_tbl_v(temp_y_int)   			:= rdy_tbl_v(temp_y_int) or bitx_v;
		task_create_tsk_cntr				<= ostsk_cntr + 1;
		task_create_prio_current			<= osprio_current;
		task_create_prio_high_rdy			<= osprio_high_rdy;
		task_create_ctx_sw_cntr				<= osctx_sw_cntr;		
		if (osrunning = '1') then 
			temp_y_std  := b"00000" & osunmaptbl(CONV_INTEGER(rdy_grp_v));
			temp_Hprio1 := STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
			temp_Hprio2 := b"00000" & osunmaptbl(CONV_INTEGER(rdy_tbl_v(CONV_INTEGER(temp_y_std))));
			prio_high   := temp_Hprio1 + temp_Hprio2;
			task_create_prio_high_rdy		<= prio_high;			
			hindex 	    := CONV_INTEGER(prio_high);
			task_create_tcb(hindex).ctx_sw_cntr	<= ostcb(hindex).ctx_sw_cntr;	--should be before osrunning check but we need hidex and before osrunning the cntr = 0 
			if (prio_high /= osprio_current) then
			    cntx_sw      := X"01";
				task_create_tcb(hindex).ctx_sw_cntr	<= ostcb(hindex).ctx_sw_cntr + 1;
				task_create_ctx_sw_cntr		<= osctx_sw_cntr + 1;
				task_create_prio_current    <= prio_high;			
			else 
                cntx_sw      := X"00";
			end if;
		else
		    cntx_sw     := X"00";
		end if; 
		task_create_tcb(index).y	 	<= y_v; 		     
        task_create_tcb(index).x		<= x_v;	             
	    task_create_tcb(index).bity 	<= bity_v;			    
	    task_create_tcb(index).bitx  	<= bitx_v;	
	    task_create_rdy_grp				<= rdy_grp_v;
		task_create_rdy_tbl				<= rdy_tbl_v;
		task_create_out  	 		    <= X"00000000" & prio_high & osprio_current & cntx_sw & X"01";					
		task_create_update				<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_task_create;


hwrtos_osstart: process( os_start_en, os_start_rst ) is  					  
  variable temp_y_std	   	: std_logic_vector(0 to 7) := X"00"; 
  variable temp_Hprio1     	: std_logic_vector(0 to 7) := X"00";
  variable temp_Hprio2     	: std_logic_vector(0 to 7) := X"00";
  variable prio_high	    : std_logic_vector(0 to 7) := X"00"; 

  begin	
	if os_start_rst = '1' then
		os_start_out					<= (others => '0');
		os_start_update					<= '0';
	elsif os_start_en'event and os_start_en = '1' then			
		os_start_prio_high_rdy	  		<= osprio_high_rdy;
		os_start_prio_current       	<= osprio_current;
		os_start_running				<= osrunning;
		if osrunning = '0' then
    		temp_y_std  := b"00000" & osunmaptbl(CONV_INTEGER(osrdy_grp));
			-- shift lift could be done like this [ temp_y_std(3 to 7) & B"000" ]
			temp_Hprio1 := STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
			temp_Hprio2 := b"00000" & osunmaptbl(CONV_INTEGER(osrdy_tbl(CONV_INTEGER(temp_y_std))));
			prio_high   := temp_Hprio1 + temp_Hprio2;
			os_start_prio_high_rdy	  	<= prio_high;
			os_start_prio_current       <= prio_high;
			os_start_running			<= '1';
		end if;		
		os_start_out	   			    <= X"0000000000" & prio_high & B"0000000" & osrunning & X"01";
		os_start_update					<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_osstart;


hwrtos_time_delay: process( time_delay_en, time_delay_rst ) is  					  
  variable index   			: integer range 0 to 15 := 0;
  variable hindex   		: integer range 0 to 15 := 0; 
  variable temp_y_int	   	: integer range 0 to 255 := 0;  
  variable temp_y_std	   	: std_logic_vector(0 to 7) := X"00";
  variable temp_Hprio1     	: std_logic_vector(0 to 7) := X"00";
  variable temp_Hprio2     	: std_logic_vector(0 to 7) := X"00";
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00"; 
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";  
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  
  begin	
	if time_delay_rst = '1' then
		time_delay_out					<= (others => '0');
		time_delay_update				<= '0';
	elsif time_delay_en'event and time_delay_en = '1' then	
		rdy_grp_v						:= osrdy_grp;
		rdy_tbl_v						:= osrdy_tbl;						
		index 	  	 					:= CONV_INTEGER(osprio_current);
		temp_y_int 						:= CONV_INTEGER(ostcb(index).y);
		rdy_tbl_v(temp_y_int)			:= rdy_tbl_v(temp_y_int) and (not ostcb(index).bitx);		
		if (rdy_tbl_v(temp_y_int) = X"00") then
			rdy_grp_v 		   			:= rdy_grp_v and (not ostcb(index).bity);
		end if; 
		time_delay_tcb(index).delay		<= slv_reg0(40 to 55);
		temp_y_std 						:= b"00000" & osunmaptbl(CONV_INTEGER(rdy_grp_v));
		temp_Hprio1 					:= STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
		temp_Hprio2 					:= b"00000" & osunmaptbl(CONV_INTEGER(rdy_tbl_v(CONV_INTEGER(temp_y_std))));
		prio_high  						:= temp_Hprio1 + temp_Hprio2;
		hindex 	    					:= CONV_INTEGER(prio_high);
		time_delay_prio_high_rdy		<= prio_high;						
		time_delay_tcb(hindex).ctx_sw_cntr	<= ostcb(hindex).ctx_sw_cntr;	
		time_delay_prio_current			<= osprio_current;		
		time_delay_ctx_sw_cntr			<= osctx_sw_cntr;
		if (prio_high /= osprio_current) then
			cntx_sw      				:= X"01";
			time_delay_tcb(hindex).ctx_sw_cntr	<= ostcb(hindex).ctx_sw_cntr + 1;
			time_delay_ctx_sw_cntr		<= osctx_sw_cntr + 1;
			time_delay_prio_current	    <= prio_high;			
		else 
            cntx_sw     				:= X"00";
		end if;					
		time_delay_rdy_grp				<= rdy_grp_v;
		time_delay_rdy_tbl				<= rdy_tbl_v;																													    					    
		time_delay_out  		 		<= X"00000000" & prio_high & osprio_current & cntx_sw & X"01";					
		time_delay_update				<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_time_delay;


hwrtos_test: process( test_en, test_rst ) is    
  variable index   			: integer range 0 to 15 := 0; 
  
  begin	
	if test_rst = '1' then
		test_out0					<= (others => '0');
		test_out1					<= (others => '0');
		test_out2					<= (others => '0');
		test_out3					<= (others => '0');
		test_sel					<= '0';
	elsif test_en'event and test_en = '1' then	
		if (slv_reg0(40 to 47) = X"FF") then
			index					:= CONV_INTEGER(osprio_current);
		else
			index					:= CONV_INTEGER(slv_reg0(40 to 47));
		end if;
		case slv_reg0(48 to 55) is
          when X"00" =>						--copy tcb part1
			test_out0				<= ostcb(index).stk_btm & ostcb(index).stk_ptr;
			test_out1				<= ostcb(index).msg & ostcb(index).stk_size;
			test_out2				<= ostcb(index).cycles_tot & ostcb(index).ctx_sw_cntr;
			test_out3				<= ostcb(index).stk_base & ostcb(index).cycles_start;				
		  when X"01" =>						--copy tcb part2
			test_out0				<= ostcb(index).id & ostcb(index).opt & ostcb(index).stk_used;
			test_out1				<= ostcb(index).stat & ostcb(index).flags_rdy & ostcb(index).flag_node & ostcb(index).event_mptr & ostcb(index).event_ptr & ostcb(index).prio & ostcb(index).delay;
			test_out2				<= X"000" & B"00" & ostcb(index).delay_req & ostcb(index).free & ostcb(index).task_name & ostcb(index).bity & ostcb(index).bitx & ostcb(index).y & ostcb(index).x & ostcb(index).stat_pend;
			test_out3				<= (others => '0');	
		  when X"02" =>						--copy system parameter
			test_out0				<= osidle_cntr & ostime;
			test_out1				<= B"0000" & sw_bit & tick_int & osstat_rdy & osrunning & ostsk_idle_prio & osprio_high_rdy & osprio_current & osidle_cntr_max & osidle_cntr_run & osctx_sw_cntr & ostsk_cntr;
			test_out2				<= (others => '0');	
			test_out3				<= (others => '0');														
		  when others =>
			test_out0				<= (others => '0');
			test_out1				<= (others => '0');
			test_out2				<= (others => '0');
			test_out3				<= (others => '0');		
		end case;		
		test_sel					<= '1';			
	end if;	
  end process hwrtos_test;



hwrtos_update: process( update_clk ) is  
  variable index   			: integer range 0 to 15 := 0;				  
  variable hindex  			: integer range 0 to 15 := 0;

  begin		
		if update_clk'event and update_clk = '1' then
			case update_case is		
			  when X"01" =>									--internal tick	
				for i in 0 to 15 loop
					ostcb(i).delay					<= tick_tcb(i).delay;
					ostcb(i).stat					<= tick_tcb(i).stat;
					ostcb(i).stat_pend				<= tick_tcb(i).stat_pend;					
				end loop;
					osrdy_grp						<= tick_rdy_grp;
					osrdy_tbl						<= tick_rdy_tbl;												
			
			  when X"02" =>									--update internal output				
				if ( (tick_out(48 to 55) = osprio_current) and (slv_reg0(48 to 55) = X"00") ) then 
					index							:= CONV_INTEGER(tick_out(40 to 47));
					ostcb(index).ctx_sw_cntr		<= ostcb(index).ctx_sw_cntr + 1;   
					osctx_sw_cntr					<= osctx_sw_cntr + 1;
					osprio_current	        	    <= tick_out(40 to 47);
				end if;
			
			  when X"04" =>									--check availability
				index 	        					:= CONV_INTEGER(slv_reg0(48 to 55));
				ostcb(index).free					<= task_av_chk_tcb(index).free;					
			
			  when X"08" =>									--task create 
				index 	    := CONV_INTEGER(slv_reg0(48 to 55));
				hindex 	    := CONV_INTEGER(task_create_out(32 to 39));
				ostcb(index).stk_ptr 				<= task_create_tcb(index).stk_ptr;
				ostcb(index).prio	   				<= task_create_tcb(index).prio;
				ostcb(index).stat	   				<= task_create_tcb(index).stat;
				ostcb(index).stat_pend  			<= task_create_tcb(index).stat_pend;
				ostcb(index).delay	   				<= task_create_tcb(index).delay;
				ostcb(index).stk_size   			<= task_create_tcb(index).stk_size;
				ostcb(index).stk_btm    			<= task_create_tcb(index).stk_btm;
				ostcb(index).opt 	    			<= task_create_tcb(index).opt;
				ostcb(index).id		   				<= task_create_tcb(index).id;
				ostcb(index).delay_req  			<= task_create_tcb(index).delay_req;
				ostcb(index).event_ptr  			<= task_create_tcb(index).event_ptr;
				ostcb(index).event_mptr				<= task_create_tcb(index).event_mptr;
				ostcb(index).flag_node  			<= task_create_tcb(index).flag_node;
				ostcb(index).msg					<= task_create_tcb(index).msg;
				ostcb(index).ctx_sw_cntr			<= task_create_tcb(index).ctx_sw_cntr;
				ostcb(index).cycles_start 			<= task_create_tcb(index).cycles_start;
				ostcb(index).cycles_tot  			<= task_create_tcb(index).cycles_tot;
				ostcb(index).stk_base	   			<= task_create_tcb(index).stk_base;
				ostcb(index).stk_used	  			<= task_create_tcb(index).stk_used;
				ostcb(index).task_name				<= task_create_tcb(index).task_name;
				ostcb(index).y						<= task_create_tcb(index).y;
				ostcb(index).x						<= task_create_tcb(index).x;
				ostcb(index).bity					<= task_create_tcb(index).bity;
				ostcb(index).bitx					<= task_create_tcb(index).bitx;
				ostcb(hindex).ctx_sw_cntr			<= task_create_tcb(hindex).ctx_sw_cntr;
				ostsk_cntr	 						<= task_create_tsk_cntr; 		     
				osprio_current						<= task_create_prio_current;	             
				osprio_high_rdy						<= task_create_prio_high_rdy;			    
				osctx_sw_cntr  						<= task_create_ctx_sw_cntr;	
				osrdy_grp							<= task_create_rdy_grp;
				osrdy_tbl							<= task_create_rdy_tbl;															  	
			
			  when X"10" =>									--os start
				osprio_high_rdy	  					<= os_start_prio_high_rdy;
		       	osprio_current						<= os_start_prio_current;
				osrunning							<= os_start_running;														 
			
			  when X"20" =>									--time delay
				index 	    := CONV_INTEGER(time_delay_out(40 to 47));
				hindex 	    := CONV_INTEGER(time_delay_out(32 to 39));
				osrdy_grp							<= time_delay_rdy_grp;
				osrdy_tbl							<= time_delay_rdy_tbl;	
				ostcb(index).delay					<= time_delay_tcb(index).delay;
				ostcb(hindex).ctx_sw_cntr			<= time_delay_tcb(hindex).ctx_sw_cntr;
				osprio_high_rdy	  					<= time_delay_prio_high_rdy;
		       	osprio_current						<= time_delay_prio_current;
				osctx_sw_cntr						<= time_delay_ctx_sw_cntr;
														
			  when others => 										
				--slv_reg5				<= cmd_rst_out;																			    	
			end case;	
		end if;															
  end process hwrtos_update;



hwrtos_select_output: process( select_clk, tick_sel_rst ) is  					  

  begin	
	if ( tick_sel_rst = '1' ) then
		tick_sel_update					<= '0';
	elsif select_clk'event and select_clk = '1' then	
		case select_case is		
		  when X"01" =>										--Select reset output							
				slv_reg4				<= (others => '0');			
			
		  when X"02" =>										--Select internal output
			if ( tick_out(48 to 55) = osprio_current ) then  								
				slv_reg4				<= tick_out;				
			else 
				slv_reg4				<= X"0000000000000001";
			end if;
			tick_sel_update				<= '1';
			
		  when X"04" =>										--Select check availability output
			slv_reg4					<= task_av_chk_out;					
			
		  when X"08" =>										--Select task create output
			slv_reg4					<= task_create_out;			
			
		  when X"10" =>										--Select os start output
			slv_reg4					<= os_start_out;					
			
		  when X"20" =>										--Select time delay output
			slv_reg4					<= time_delay_out;
			
		  when X"40" =>										--Select test output
			slv_reg4					<= test_out0;			
			slv_reg5					<= test_out1;			
			slv_reg6					<= test_out2;			
			slv_reg7					<= test_out3;			
					  			
		  when others => 										
			slv_reg4					<= rst_out;																			    	
        end case;		
	end if;									 		  			     	  	 
  end process hwrtos_select_output;



hwrtos_tick_update_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			tick_update_d			<= tick_update;																					    				
			tick_upd_rst			<= tick_update_d;		--if one clk delay is enough we could modify this															    				
		end if;															
  end process hwrtos_tick_update_delay;



hwrtos_tick_select_upd_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			tick_sel_update_d		<= tick_sel_update;																					    				
			tick_sel_rst			<= tick_sel_update_d;	--if one clk delay is enough we could modify this															    				
		end if;															
  end process hwrtos_tick_select_upd_delay;



hwrtos_tick_select_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			tick_sel_d				<= tick_sel;			--if one clk delay is not enough we could modify this																																    							
		end if;															
  end process hwrtos_tick_select_delay;

 
hwrtos_task_av_chk_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			task_av_chk_update_d	<= task_av_chk_update;																					    				
			task_av_chk_rst			<= task_av_chk_update_d;	--if one clk delay is enough we could modify this															    				
		end if;															
  end process hwrtos_task_av_chk_delay;
 

hwrtos_task_create_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			task_create_update_d	<= task_create_update;																					    				
			task_create_rst			<= task_create_update_d;	--if one clk delay is enough we could modify this															    				
		end if;															
  end process hwrtos_task_create_delay;


hwrtos_os_start_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			os_start_update_d		<= os_start_update;																					    				
			os_start_rst			<= os_start_update_d;	--if one clk delay is enough we could modify this															    				
		end if;															
  end process hwrtos_os_start_delay;


hwrtos_time_dly_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			time_delay_update_d		<= time_delay_update;																					    				
			time_delay_rst			<= time_delay_update_d;	--if one clk delay is enough we could modify this															    				
		end if;															
  end process hwrtos_time_dly_delay;


hwrtos_test_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			test_sel_d				<= test_sel;																					    				
			test_rst				<= test_sel_d;	--if one clk delay is enough we could modify this															    				
		end if;																	
  end process hwrtos_test_delay;


--userlogic_task_create_d1shot: process( Bus2IP_Clk ) is  					    

  --begin			
	--if Bus2IP_Clk'event and Bus2IP_Clk = '1' then	
		--task_create_d			 <= task_create_b;
		--task_create_1shot  		 <= task_create_b and (not task_create_d);		
	--end if;									 		  			     	  	 
  --end process userlogic_task_create_d1shot;



  update_clk					 <= time_delay_update_d or os_start_update_d or task_create_update_d or task_av_chk_update_d or tick_sel_update_d or tick_update_d;  
  update_case					 <= B"00" & time_delay_update & os_start_update & task_create_update & task_av_chk_update & tick_sel_update & tick_update;  
  select_clk					 <= test_sel_d or time_delay_update_d or os_start_update_d or task_create_update_d or task_av_chk_update_d or tick_sel_d or rst_en;  
  select_case					 <= '0' & test_sel & time_delay_update & os_start_update & task_create_update & task_av_chk_update & tick_sel & rst_en;  
  

end IMP;
