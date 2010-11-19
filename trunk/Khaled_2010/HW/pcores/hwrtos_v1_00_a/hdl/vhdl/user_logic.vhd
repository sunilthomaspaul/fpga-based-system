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
	 Int_Out								  : out std_logic;			--HWRTOS: Interrupt output
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

	--HWRTOS: TCB	  
  type task_rec is record											
	prio:			std_logic_vector(0 to 7);				--HWRTOS: Task priority
	free:			std_logic;								--HWRTOS: TCB free/used indication
	id:	    		std_logic_vector(0 to 15);				--HWRTOS: Task ID
	event_no:		std_logic_vector(0 to 7);				--HWRTOS: ECB that the task is pending on			
	msg:			std_logic_vector(0 to 31);				--HWRTOS: Pointer to the message recieved from mbox		
	delay:			std_logic_vector(0 to 15);				--HWRTOS: Task period
	dec_delay:		std_logic_vector(0 to 15);				--HWRTOS: Current value of decremented task period
	stat:			std_logic_vector(0 to 7);				--HWRTOS: Task status
	stat_pend:		std_logic_vector(0 to 7);				--HWRTOS: Task pend status
	x:				std_logic_vector(0 to 7);				--HWRTOS: Pre-calculated value used in list manipulation
	y:				std_logic_vector(0 to 7);				--HWRTOS: Pre-calculated value used in list manipulation
	bitx:			std_logic_vector(0 to 7);				--HWRTOS: Pre-calculated value used in list manipulation
	bity:			std_logic_vector(0 to 7);				--HWRTOS: Pre-calculated value used in list manipulation	
	ctx_sw_cntr:	std_logic_vector(0 to 31);				--HWRTOS: Task context switch counter						
	task_name:  	std_logic_vector(0 to 7);				--HWRTOS: Task name	
  end record task_rec;
  type task_arr is array(0 to 15) of task_rec;				--HWRTOS: Maximum 16 tasks allowed including idle task
  signal ostcb                         : task_arr := ((X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),	
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"),
													  (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F"));

	--HWRTOS: Temporary TCB 
  type task_create_tcb_rec is record										
	prio:				std_logic_vector(0 to 7);
	free:				std_logic;
	id:					std_logic_vector(0 to 15);
	event_no:			std_logic_vector(0 to 7);		
	msg:				std_logic_vector(0 to 31);		
	delay:				std_logic_vector(0 to 15);	
	dec_delay:		    std_logic_vector(0 to 15);
	stat:				std_logic_vector(0 to 7);
	stat_pend:			std_logic_vector(0 to 7);
	x:					std_logic_vector(0 to 7);
	y:					std_logic_vector(0 to 7);
	bitx:				std_logic_vector(0 to 7);
	bity:				std_logic_vector(0 to 7);	
	ctx_sw_cntr:		std_logic_vector(0 to 31);									
	task_name:    		std_logic_vector(0 to 7);			
  end record task_create_tcb_rec; 
  signal task_create_tcb        : task_create_tcb_rec := (X"00", '0', X"0000", X"00", X"00000000", X"0000", X"0000", X"00", X"00", X"00", X"00", X"00", X"00", X"00000000", X"3F");
													    
													
	--HWRTOS: Temporary TCB 
  type tick_tcb_rec is record
	dec_delay:		std_logic_vector(0 to 15);		
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);	
  end record tick_tcb_rec;
  type tick_tcb_arr is array(0 to 15) of tick_tcb_rec;
  signal tick_tcb                       : tick_tcb_arr := ((X"0000", X"00", X"00"),
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

 
	
    --HWRTOS: Temporary TCB 																		
  type time_delay_tcb_rec is record	
	ctx_sw_cntr_hprio:	std_logic_vector(0 to 31);	
  end record time_delay_tcb_rec;  
  signal time_delay_tcb                : time_delay_tcb_rec; 															
				
															 															 														
	--HWRTOS: Temporary TCB 														
  type sema4_pend_tcb_rec is record
    dec_delay:		std_logic_vector(0 to 15);
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);
	event_no:		std_logic_vector(0 to 7);	
  end record sema4_pend_tcb_rec;  
  signal sema4_pend_tcb                : sema4_pend_tcb_rec := (X"0000", X"00", X"00", X"00"); 															


	--HWRTOS: Temporary TCB 
  type sema4_pend_stat_tcb_rec is record    
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);
	event_no:		std_logic_vector(0 to 7);	
  end record sema4_pend_stat_tcb_rec;  
  signal sema4_pend_stat_tcb           : sema4_pend_stat_tcb_rec := (X"00", X"00", X"00"); 	
				
				
    --HWRTOS: Temporary TCB 																
  type sema4_post_tcb_rec is record
    dec_delay:		std_logic_vector(0 to 15);
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);	
	msg:			std_logic_vector(0 to 31);	
  end record sema4_post_tcb_rec;  
  signal sema4_post_tcb                : sema4_post_tcb_rec := (X"0000", X"00", X"00", X"00000000");  


  --HWRTOS: Temporary TCB 
type mbox_pend_tcb_rec is record
    dec_delay:		std_logic_vector(0 to 15);
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);
	event_no:		std_logic_vector(0 to 7);	
  end record mbox_pend_tcb_rec;
  signal mbox_pend_tcb                : mbox_pend_tcb_rec := (X"0000", X"00", X"00", X"00"); 															


	--HWRTOS: Temporary TCB 
  type mbox_pend_stat_tcb_rec is record    
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);
	event_no:		std_logic_vector(0 to 7);	
	msg:			std_logic_vector(0 to 31);
  end record mbox_pend_stat_tcb_rec;  
  signal mbox_pend_stat_tcb           : mbox_pend_stat_tcb_rec := (X"00", X"00", X"00", X"00000000"); 	


	--HWRTOS: Temporary TCB 
  type mbox_post_tcb_rec is record
    dec_delay:		std_logic_vector(0 to 15);
	stat:			std_logic_vector(0 to 7);
	stat_pend:		std_logic_vector(0 to 7);	
	msg:			std_logic_vector(0 to 31);	
  end record mbox_post_tcb_rec; 
  signal mbox_post_tcb                : mbox_post_tcb_rec := (X"0000", X"00", X"00", X"00000000");


	--HWRTOS: Unmap table 
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
   
	
	--HWRTOS: Ready list
  signal osrdy_grp 						: std_logic_vector(0 to 7) := X"00";
  type rdy_tbl is array(0 to 7) of std_logic_vector(0 to 7);
  signal osrdy_tbl						: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");


	--HWRTOS: Temporary ready list
  signal tick_rdy_grp 					: std_logic_vector(0 to 7) := X"00";
  signal tick_rdy_tbl					: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");


	--HWRTOS: Temporary ready list
  signal task_create_rdy_grp 			: std_logic_vector(0 to 7) := X"00";
  signal task_create_rdy_tbl			: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");


	--HWRTOS: Temporary ready list
  signal time_delay_rdy_grp 			: std_logic_vector(0 to 7) := X"00";
  signal time_delay_rdy_tbl				: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");


	--HWRTOS: Temporary ready list
  signal sema4_pend_rdy_grp 			: std_logic_vector(0 to 7) := X"00";
  signal sema4_pend_rdy_tbl				: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");


	--HWRTOS: Temporary ready list
  signal sema4_post_rdy_grp 			: std_logic_vector(0 to 7) := X"00";
  signal sema4_post_rdy_tbl				: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");


	--HWRTOS: Temporary ready list
  signal mbox_pend_rdy_grp 				: std_logic_vector(0 to 7) := X"00";
  signal mbox_pend_rdy_tbl				: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");


	--HWRTOS: Temporary ready list
  signal mbox_post_rdy_grp 				: std_logic_vector(0 to 7) := X"00";
  signal mbox_post_rdy_tbl				: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");

	
	--HWRTOS: ECB
  type event_rec is record
	osevent_type			: std_logic_vector(0 to 7);			--HWRTOS: ECB type
	osevent_free			: std_logic;						--HWRTOS: ECB free/used indication
	osevent_ptr				: std_logic_vector(0 to 31);		--HWRTOS: Pointer to message in case of mailbox
	osevent_cnt				: std_logic_vector(0 to 15);		--HWRTOS: Key count in case of semaphore
    osevent_grp 			: std_logic_vector(0 to 7);			--HWRTOS: Part of waiting list
    osevent_tbl             : rdy_tbl;							--HWRTOS: Part of waiting list
	osevent_name			: std_logic_vector(0 to 7);			--HWRTOS: ECB name
  end record event_rec; 
  type event_arr is array(1 to 16) of event_rec;				--HWRTOS: Maximum 16 ECBs for both semaphore and mailbox
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
														
  
	--HWRTOS: Temporary ECB
  type sema4_create_event_rec is record
	osevent_type							: std_logic_vector(0 to 7);		-- X"00" = unused, X"01" = Mbox, X"02" = Q, X"03" = Sem, X"04" = Mutex, X"05" = Flag
	osevent_free							: std_logic;	
	osevent_cnt								: std_logic_vector(0 to 15);    
	osevent_ptr								: std_logic_vector(0 to 31);
  end record sema4_create_event_rec; 
  signal sema4_create_ecb                   : sema4_create_event_rec := (X"00", '0', X"0000", X"00000000");
					
															
    --HWRTOS: Temporary ECB																	
  type sema4_pend_event_rec is record
	osevent_cnt								: std_logic_vector(0 to 15);    
	osevent_grp 						    : std_logic_vector(0 to 7);
    osevent_tbl                             : rdy_tbl;
  end record sema4_pend_event_rec;   
  signal sema4_pend_ecb                     : sema4_pend_event_rec := (X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"));														


	--HWRTOS: Temporary ECB
  type sema4_pend_stat_event_rec is record	
	osevent_grp 						    : std_logic_vector(0 to 7);
    osevent_tbl                             : rdy_tbl;
  end record sema4_pend_stat_event_rec;   
  signal sema4_pend_stat_ecb                : sema4_pend_stat_event_rec := (X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"));														


    --HWRTOS: Temporary ECB															
  type sema4_post_event_rec is record
	osevent_cnt								: std_logic_vector(0 to 15);    
	osevent_grp 						    : std_logic_vector(0 to 7);
    osevent_tbl                             : rdy_tbl;
  end record sema4_post_event_rec;   
  signal sema4_post_ecb                     : sema4_post_event_rec := (X"0000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"));


    --HWRTOS: Temporary ECB
  type mbox_create_event_rec is record
	osevent_type							: std_logic_vector(0 to 7);		-- X"00" = unused, X"01" = Mbox, X"02" = Q, X"03" = Sem, X"04" = Mutex, X"05" = Flag
	osevent_free							: std_logic;	
	osevent_cnt								: std_logic_vector(0 to 15);    
	osevent_ptr								: std_logic_vector(0 to 31);
  end record mbox_create_event_rec;   
  signal mbox_create_ecb                   : mbox_create_event_rec := (X"00", '0', X"0000", X"00000000");


    --HWRTOS: Temporary ECB
  type mbox_pend_event_rec is record
	osevent_ptr								: std_logic_vector(0 to 31);    
	osevent_grp 						    : std_logic_vector(0 to 7);
    osevent_tbl                             : rdy_tbl;
  end record mbox_pend_event_rec;   
  signal mbox_pend_ecb                     : mbox_pend_event_rec := (X"00000000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"));														


    --HWRTOS: Temporary ECB
  type mbox_pend_stat_event_rec is record	
	osevent_grp 						    : std_logic_vector(0 to 7);
    osevent_tbl                             : rdy_tbl;
  end record mbox_pend_stat_event_rec;   
  signal mbox_pend_stat_ecb                : mbox_pend_stat_event_rec := (X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"));


    --HWRTOS: Temporary ECB
  type mbox_post_event_rec is record
	osevent_ptr								: std_logic_vector(0 to 31);    
	osevent_grp 						    : std_logic_vector(0 to 7);
    osevent_tbl                             : rdy_tbl;
  end record mbox_post_event_rec;  
  signal mbox_post_ecb                     : mbox_post_event_rec := (X"00000000", X"00", (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"));


	--HWRTOS: State machine
  type state_machine is (idle, internal, external);
  signal state     			            : state_machine := idle;


	--HWRTOS: cmd(7)  = bit 7 is for internal tick timer
	--HWRTOS: cmd(0)  = bit 0 is for external select output
  signal cmd							: std_logic_vector(0 to 7) := X"00"; 
  
	--HWRTOS: Internal signals
  signal tick_timer_en					: std_logic 				:= '0';
  signal tick_timer_rst					: std_logic 				:= '0';
  signal tick_timer_cnt					: std_logic_vector(0 to 7 ) := X"01";

  signal int_resp_timer_en				: std_logic 				:= '0';  
  signal int_resp_timer_cnt				: std_logic_vector(0 to 15) := X"0000"; 

  signal ext_cmd_timer_en				: std_logic 				:= '0';  
  signal ext_cmd_timer_rst				: std_logic 				:= '0';
  signal ext_cmd_timer_cnt				: std_logic_vector(0 to 7 ) := X"03"; 
  signal cmd_en							: std_logic 				:= '0';
  signal cmd_dis						: std_logic 				:= '0';

  signal sw_ctrl_timer_en				: std_logic 				:= '0';
  signal sw_ctrl_timer_en_d				: std_logic 				:= '0';
  signal sw_ctrl_timer_en_1shot			: std_logic 				:= '0';
  signal sw_ctrl_timer_rst				: std_logic 				:= '0';
  signal sw_ctrl_timer_update			: std_logic 				:= '0';
  signal sw_ctrl_timer_update_d			: std_logic 				:= '0';
  signal sw_ctrl_timer_cnt				: std_logic_vector(0 to 31) := X"00000000";

  signal cont_timer_en					: std_logic 				:= '0';
  signal cont_timer_dis					: std_logic 				:= '0';
  signal cont_timer_start				: std_logic 				:= '0';
  signal cont_timer_start_d				: std_logic 				:= '0';
  signal cont_timer_start_1shot			: std_logic 				:= '0';  
  signal cont_timer_rd					: std_logic 				:= '0';
  signal cont_timer_rd_d				: std_logic 				:= '0';  
  signal cont_timer_cnt					: std_logic_vector(0 to 31) := X"00000000";

  signal rd_reg4						: std_logic 				:= '0';
  signal rd_reg4_d1						: std_logic 				:= '0';
  signal rd_reg4_d2						: std_logic 				:= '0';
  signal rd_reg4_rst					: std_logic 				:= '0';
  signal wr_rst							: std_logic 				:= '0';

  signal ostime							: std_logic_vector(0 to 31) := X"00000000";  
  signal ostsk_cntr		    			: std_logic_vector(0 to 7)  := X"00";
  signal osrunning						: std_logic 				:= '0';
  signal osctx_sw_cntr        			: std_logic_vector(0 to 7)  := X"00";          
  signal osprio_current					: std_logic_vector(0 to 7)	:= X"00";
  signal osprio_high_rdy				: std_logic_vector(0 to 7)	:= X"00";
  signal ostsk_idle_prio    			: std_logic_vector(0 to 7)  := X"00";	

  signal timer_value					: std_logic_vector(0 to 31) := X"00000000";													
  signal cnt							: std_logic_vector(0 to 31) := X"00000000";													
  signal os_time_tick					: std_logic := '0';													
  signal os_time_en						: std_logic := '0';														
  signal os_time_dis					: std_logic := '0';	
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
  
  signal task_create_en					: std_logic := '0';														
  signal task_create_rst				: std_logic := '0';
  signal task_create_update				: std_logic := '0';
  signal task_create_update_d			: std_logic := '0';
  signal task_create_out				: std_logic_vector(0 to 63) := X"0000000000000000";	  
  signal task_create_tsk_cntr  			: std_logic_vector(0 to 7)  := X"00";
  signal task_create_ctx_sw_cntr    	: std_logic_vector(0 to 7)  := X"00";
  signal task_create_prio_current		: std_logic_vector(0 to 7)	:= X"00";
  signal task_create_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";
  signal task_create_tcb_ctx_sw_cntr_hprio	: std_logic_vector(0 to 31)	:= X"00000000";  

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

  signal time_delay_en					: std_logic := '0';
  signal time_delay_rst					: std_logic := '0';
  signal time_delay_update				: std_logic := '0';
  signal time_delay_update_d			: std_logic := '0';
  signal time_delay_ctx_sw_cntr  	  	: std_logic_vector(0 to 7)  := X"00";
  signal time_delay_prio_current		: std_logic_vector(0 to 7)	:= X"00";
  signal time_delay_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";
  signal time_delay_out					: std_logic_vector(0 to 63) := X"0000000000000000";

  signal sema4_create_en				: std_logic := '0';
  signal sema4_create_rst				: std_logic := '0';
  signal sema4_create_update			: std_logic := '0';
  signal sema4_create_update_d			: std_logic := '0';
  signal sema4_create_out				: std_logic_vector(0 to 63) := X"0000000000000000";

  signal sema4_pend_en					: std_logic := '0';
  signal sema4_pend_rst					: std_logic := '0';
  signal sema4_pend_update				: std_logic := '0';
  signal sema4_pend_update_d			: std_logic := '0';
  signal sema4_pend_out		 			: std_logic_vector(0 to 63) := X"0000000000000000";	 
  signal sema4_pend_ctx_sw_cntr     	: std_logic_vector(0 to 7)  := X"00";
  signal sema4_pend_prio_current		: std_logic_vector(0 to 7)	:= X"00";
  signal sema4_pend_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";
  signal sema4_pend_tcb_ctx_sw_cntr_hprio	: std_logic_vector(0 to 31)	:= X"00000000";

  signal sema4_pend_stat_en				: std_logic := '0';
  signal sema4_pend_stat_rst			: std_logic := '0';
  signal sema4_pend_stat_update			: std_logic := '0';
  signal sema4_pend_stat_update_d		: std_logic := '0';
  signal sema4_pend_stat_out		 	: std_logic_vector(0 to 63) := X"0000000000000000";

  signal sema4_post_en					: std_logic := '0';
  signal sema4_post_rst					: std_logic := '0';
  signal sema4_post_update				: std_logic := '0';
  signal sema4_post_update_d			: std_logic := '0';
  signal sema4_post_out				 	: std_logic_vector(0 to 63) := X"0000000000000000";
  signal sema4_post_ctx_sw_cntr     	: std_logic_vector(0 to 7)  := X"00";
  signal sema4_post_prio_current		: std_logic_vector(0 to 7)	:= X"00";
  signal sema4_post_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";
  signal sema4_post_tcb_ctx_sw_cntr_hprio	: std_logic_vector(0 to 31)	:= X"00000000";

  signal mbox_create_en					: std_logic := '0';
  signal mbox_create_rst				: std_logic := '0';
  signal mbox_create_update				: std_logic := '0';
  signal mbox_create_update_d			: std_logic := '0';
  signal mbox_create_out				: std_logic_vector(0 to 63) := X"0000000000000000";

  signal mbox_pend_en					: std_logic := '0';
  signal mbox_pend_rst					: std_logic := '0';
  signal mbox_pend_update				: std_logic := '0';
  signal mbox_pend_update_d				: std_logic := '0';
  signal mbox_pend_out		 			: std_logic_vector(0 to 63) := X"0000000000000000";	 
  signal mbox_pend_ctx_sw_cntr     		: std_logic_vector(0 to 7)  := X"00";
  signal mbox_pend_prio_current			: std_logic_vector(0 to 7)	:= X"00";
  signal mbox_pend_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";
  signal mbox_pend_tcb_ctx_sw_cntr_hprio	: std_logic_vector(0 to 31)	:= X"00000000";

  signal mbox_pend_stat_en				: std_logic := '0';
  signal mbox_pend_stat_rst				: std_logic := '0';
  signal mbox_pend_stat_update			: std_logic := '0';
  signal mbox_pend_stat_update_d		: std_logic := '0';
  signal mbox_pend_stat_out		 		: std_logic_vector(0 to 63) := X"0000000000000000";

  signal mbox_post_en					: std_logic := '0';
  signal mbox_post_rst					: std_logic := '0';
  signal mbox_post_update				: std_logic := '0';
  signal mbox_post_update_d				: std_logic := '0';
  signal mbox_post_out				 	: std_logic_vector(0 to 63) := X"0000000000000000";
  signal mbox_post_ctx_sw_cntr     		: std_logic_vector(0 to 7)  := X"00";
  signal mbox_post_prio_current			: std_logic_vector(0 to 7)	:= X"00";
  signal mbox_post_prio_high_rdy		: std_logic_vector(0 to 7)	:= X"00";
  signal mbox_post_tcb_ctx_sw_cntr_hprio	: std_logic_vector(0 to 31)	:= X"00000000";
	 		
  signal update_clk						: std_logic := '0'; 
  signal update_case					: std_logic_vector(0 to 15) := X"0000";
  signal select_clk						: std_logic := '0';  
  signal select_case					: std_logic_vector(0 to 15) := X"0000";
  
  signal sw_bit							: std_logic := '0'; 



	

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
  

	--HWRTOS: Add a task to a list (ready list or waiting list) 
  procedure add_to_list (variable atl_prio: 	 in integer;
						 variable atl_rdy_grp_v: inout std_logic_vector;
						 variable atl_rdy_tbl_v: inout rdy_tbl) is
							
	variable temp_y_int	   	: integer range 0 to 255 := 0;
    variable test_prio	   	: integer range 0 to 15 := 0;	
  begin				
		test_prio					:= atl_prio;
		temp_y_int 					:= CONV_INTEGER(ostcb(test_prio).y);
		atl_rdy_grp_v 	   	   	 	:= atl_rdy_grp_v or ostcb(test_prio).bity;
		atl_rdy_tbl_v(temp_y_int)  	:= atl_rdy_tbl_v(temp_y_int) or ostcb(test_prio).bitx;		
  end procedure add_to_list;


	--HWRTOS: Remove a task from a list (ready list or waiting list)
  procedure remove_from_list (variable rfl_prio: 	  in integer;
							  variable rfl_rdy_grp_v: inout std_logic_vector;
							  variable rfl_rdy_tbl_v: inout rdy_tbl) is
							
	variable temp_y_int	   	: integer range 0 to 255 := 0;			
  begin				
		temp_y_int 					:= CONV_INTEGER(ostcb(rfl_prio).y);
		rfl_rdy_tbl_v(temp_y_int)  	:= rfl_rdy_tbl_v(temp_y_int) and (not ostcb(rfl_prio).bitx);
		if (rfl_rdy_tbl_v(temp_y_int) = X"00") then
				rfl_rdy_grp_v		:= rfl_rdy_grp_v and (not ostcb(rfl_prio).bity);
		end if;		
  end procedure remove_from_list;


    --HWRTOS: Find the highest priority task in a list (ready list or waiting list)				
  procedure find_hi_prio (variable fhp_rdy_grp_v: in std_logic_vector;
						  variable fhp_rdy_tbl_v: in rdy_tbl;
						  variable fhp_prio_high: out std_logic_vector) is
							
	variable temp_y_std	   	: std_logic_vector(0 to 7) := X"00";  
    variable temp_Hprio1   	: std_logic_vector(0 to 7) := X"00";
    variable temp_Hprio2    : std_logic_vector(0 to 7) := X"00";			
  begin				
		temp_y_std  	:= b"00000" & osunmaptbl(CONV_INTEGER(fhp_rdy_grp_v));			
		temp_Hprio1 	:= STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
		temp_Hprio2 	:= b"00000" & osunmaptbl(CONV_INTEGER(fhp_rdy_tbl_v(CONV_INTEGER(temp_y_std))));
		fhp_prio_high   := temp_Hprio1 + temp_Hprio2;	
  end procedure find_hi_prio;
		
			
	--HWRTOS: scheduler returns the highest priority task and the context switch information		
  procedure sched (variable sched_rdy_grp_v: 		in std_logic_vector;
				   variable sched_rdy_tbl_v: 		in rdy_tbl;
				   variable sched_prio_high: 		inout std_logic_vector;
				   variable sched_ctx_sw:  			out std_logic_vector;
				   variable sched_task_ctx_sw_cntr:	out std_logic_vector;
				   variable sched_osctx_sw_cntr:	out std_logic_vector;
				   variable sched_prio_current: 	out std_logic_vector) is
							
	
	variable hindex   		: integer range 0 to 15 := 0;			
  begin				
		find_hi_prio (sched_rdy_grp_v, sched_rdy_tbl_v, sched_prio_high);			
		hindex 	    := CONV_INTEGER(sched_prio_high);			
		if (sched_prio_high /= osprio_current) then
			sched_ctx_sw      		:= X"01";
			sched_task_ctx_sw_cntr 	:= ostcb(hindex).ctx_sw_cntr + 1;
			sched_osctx_sw_cntr 	:= osctx_sw_cntr + 1;
			sched_prio_current      := sched_prio_high;			
		else 
			sched_ctx_sw      		:= X"02";
			sched_task_ctx_sw_cntr 	:= ostcb(hindex).ctx_sw_cntr;
			sched_osctx_sw_cntr 	:= osctx_sw_cntr;
			sched_prio_current      := osprio_current;
		end if;
  end procedure sched;    





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
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk, wr_rst ) is
  begin

	--HWRTOS: Automatic command reset after execution
	if wr_rst = '1' then
		slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
        slv_reg2 <= (others => '0');
        slv_reg3 <= (others => '0');
    elsif Bus2IP_Clk'event and Bus2IP_Clk = '1' then
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
  SLAVE_REG_READ_PROC : process( rd_reg4_rst, slv_reg_read_select, slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7 ) is
  begin

	if rd_reg4_rst = '1' then
		 rd_reg4			<= '0';
    else case slv_reg_read_select is
			when "10000000" => slv_ip2bus_data <= slv_reg0;
			when "01000000" => slv_ip2bus_data <= slv_reg1;
			when "00100000" => slv_ip2bus_data <= slv_reg2;
			when "00010000" => slv_ip2bus_data <= slv_reg3;
			when "00001000" => slv_ip2bus_data <= slv_reg4;
									 if ( Bus2IP_BE = B"00001111" ) then	--HWRTOS: Automatic command reset after reading the result
										rd_reg4		   <= '1';
									 end if;	
			when "00000100" => slv_ip2bus_data <= slv_reg5;
			when "00000010" => slv_ip2bus_data <= slv_reg6;
			when "00000001" => slv_ip2bus_data <= slv_reg7;
			when others => slv_ip2bus_data <= (others => '0');
		end case;
	end if;

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
  Int_Out		   <= tick_int or sw_bit;

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


	--HWRTOS: External command decoding
hwrtos_decode: process( Bus2IP_Clk ) is    
	
  begin

	if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
	  if Bus2IP_Reset = '1' then
		cmd(0 to 6)					<= B"0000000";				--HWRTOS: Powerup reset		
		hw_init_en					<= '0';	
		os_time_en					<= '0';
		os_time_dis					<= '0';	
		cont_timer_en				<= '0';											
		cont_timer_dis				<= '0';											
	  else 	
	    case slv_reg0(56 to 63) is
		  when X"00" => 										--HWRTOS: Reset request
			cmd(0 to 6)				<= B"0000000";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"01" =>											--HWRTOS: HW/OS initialization request
			cmd(0 to 6)				<= B"0000000";																
			hw_init_en				<= '1';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';	
						
		  when X"02" =>											--HWRTOS: Tick timer enable request
		 	cmd(0 to 6)				<= B"0000000";																
			hw_init_en				<= '0';	
			os_time_en				<= '1';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';	
							
		  when X"03" =>											--HWRTOS: Tick timer disable request
		 	cmd(0 to 6)				<= B"0000000";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '1';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';							 

		  when X"04" =>											--HWRTOS: Context switch information request
		    cmd(0 to 6)				<= B"1000000";																
			hw_init_en				<= '0';	
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';						 						 		  			
		  			
		  when X"05" =>											--HWRTOS: Create Task request
		   	cmd(0 to 6)				<= B"1000001";																
			hw_init_en				<= '0';	
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"06" =>											--HWRTOS: Task done request
		   	cmd(0 to 6)				<= B"1000010";																
			hw_init_en				<= '0';	
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"07" =>											--HWRTOS: Create semaphore request
		   	cmd(0 to 6)				<= B"1000011";																
			hw_init_en				<= '0'; 
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';	 				  				
			
		  when X"08" =>											--HWRTOS: Pend on semaphore request
			cmd(0 to 6)				<= B"1000100";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';	
			
		  when X"09" =>											--HWRTOS: Semaphore pend status request
			cmd(0 to 6)				<= B"1000101";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"0A" =>											--HWRTOS: Post semaphore request
			cmd(0 to 6)				<= B"1000110";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"0B" =>											--HWRTOS: Create mailbox request
			cmd(0 to 6)				<= B"1000111";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
				
		  when X"0C" =>											--HWRTOS: Pend on mailbox request
			cmd(0 to 6)				<= B"1001000";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';		
					   			 
		  when X"0D" =>											--HWRTOS: Mailbox pend status request
			cmd(0 to 6)				<= B"1001001";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"0E" =>											--HWRTOS: Post a message to mailbox request
			cmd(0 to 6)				<= B"1001010";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"0F" =>											--HWRTOS: OS start request
			cmd(0 to 6)				<= B"1001011";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';	
			
		  when X"10" =>											--HWRTOS: Test request
			cmd(0 to 6)				<= B"1001100";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';			
					
		  when X"11" =>											--HWRTOS: Start stop-watch timer request
			cmd(0 to 6)				<= B"1001101";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';				
					
		  when X"12" =>											--HWRTOS: Stop stop-watch timer request
			cmd(0 to 6)				<= B"1001110";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"13" =>											--HWRTOS: Start continous timer request
			cmd(0 to 6)				<= B"0000000";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '1';											
		    cont_timer_dis			<= '0';
			
		  when X"14" =>											--HWRTOS: Read continous timer request
			cmd(0 to 6)				<= B"1001111";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';
			
		  when X"15" =>											--HWRTOS: Stop continous timer request
			cmd(0 to 6)				<= B"0000000";																
			hw_init_en				<= '0';
			os_time_en				<= '0';
			os_time_dis				<= '0';
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '1';
					
		  when others => 										--HWRTOS: Reset
			cmd(0 to 6)				<= B"0000000";																
			hw_init_en				<= '0';	
			os_time_en				<= '0';
			os_time_dis				<= '0';	
			cont_timer_en			<= '0';											
		    cont_timer_dis			<= '0';	    
		  
        end case;		  		 		 		  
      end if;
    end if;
  end process hwrtos_decode;


hwrtos_state_machine : process( Bus2IP_Clk ) is

  begin
    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        state			       		<= idle;				--HWRTOS: Powerup state is Idle	
		rst_en						<= '1';
		tick_en						<= '0';
		tick_sel					<= '0';				
		task_create_en				<= '0';				
		time_delay_en				<= '0';
		sema4_create_en				<= '0';
		sema4_pend_en				<= '0';
		sema4_pend_stat_en			<= '0';
		sema4_post_en				<= '0';
		mbox_create_en				<= '0';
		mbox_pend_en				<= '0';
		mbox_pend_stat_en			<= '0';
		mbox_post_en				<= '0';
		os_start_en					<= '0';
		test_en						<= '0';
		sw_ctrl_timer_en			<= '0';		
		cont_timer_rd				<= '0';
      else       
        case state is
          when idle =>										--HWRTOS: Idle state
            if ( cmd = X"00" ) then             
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';			 
			  task_create_en		<= '0';			  				  
			  time_delay_en			<= '0';
			  sema4_create_en		<= '0';
			  sema4_pend_en			<= '0';
			  sema4_pend_stat_en	<= '0';
			  sema4_post_en			<= '0';
			  mbox_create_en		<= '0';
			  mbox_pend_en			<= '0';
			  mbox_pend_stat_en		<= '0';
			  mbox_post_en			<= '0';
			  os_start_en			<= '0';
			  test_en				<= '0';
			  cont_timer_rd			<= '0';			  
              
            elsif ( (cmd = X"01") or (cmd = X"83") or (cmd = X"85") or (cmd = X"87") or (cmd = X"89") or (cmd = X"8B") or (cmd = X"8D") or (cmd = X"8F") or (cmd = X"91") or (cmd = X"93") or (cmd = X"95") or (cmd = X"97") or (cmd = X"99") or (cmd = X"9B") or (cmd = X"9D") or (cmd = X"9F")) then             
              state					<= internal;			--HWRTOS: Transitions to Internal state
			  rst_en				<= '0';
			  tick_en				<= '1';
			  if (cmd = X"9B") then
			    sw_ctrl_timer_en	<= '1';
			  end if;
              
            elsif ( (cmd = X"80") or (cmd = X"82") or (cmd = X"84") or (cmd = X"86") or (cmd = X"88") or (cmd = X"8A") or (cmd = X"8C") or (cmd = X"8E") or (cmd = X"90") or (cmd = X"92") or (cmd = X"94") or (cmd = X"96") or (cmd = X"98") or (cmd = X"9A") or (cmd = X"9C") or (cmd = X"9E")) then              
              state					<= external;			--HWRTOS: Transitions to External state
			  if (cmd = X"80") then
				rst_en				<= '0';
				tick_sel			<= '1';			  
			  elsif (cmd = X"82") then
				rst_en				<= '0';
				task_create_en		<= '1';			  			  
			  elsif (cmd = X"84") then
				rst_en				<= '0';
				time_delay_en		<= '1';
			  elsif (cmd = X"86") then
				rst_en				<= '0';
				sema4_create_en		<= '1';			  
			  elsif (cmd = X"88") then
				rst_en				<= '0';
				sema4_pend_en		<= '1';
			  elsif (cmd = X"8A") then
				rst_en				<= '0';
				sema4_pend_stat_en	<= '1';
			  elsif (cmd = X"8C") then
				rst_en				<= '0';
				sema4_post_en		<= '1';
			  elsif (cmd = X"8E") then
				rst_en				<= '0';
				mbox_create_en		<= '1';
			  elsif (cmd = X"90") then
				rst_en				<= '0';
				mbox_pend_en		<= '1';
			  elsif (cmd = X"92") then
				rst_en				<= '0';
				mbox_pend_stat_en	<= '1';
			  elsif (cmd = X"94") then
				rst_en				<= '0';
				mbox_post_en		<= '1';
			  elsif (cmd = X"96") then
				rst_en				<= '0';
				os_start_en			<= '1';
			  elsif (cmd = X"98") then
				rst_en				<= '0';
				test_en				<= '1';
			  elsif (cmd = X"9A") then
				rst_en				<= '0';
				sw_ctrl_timer_en	<= '1';
			  elsif (cmd = X"9C") then
				rst_en				<= '0';
				sw_ctrl_timer_en	<= '0';			  
			  elsif (cmd = X"9E") then
				rst_en				<= '0';
				cont_timer_rd		<= '1';
			  end if;
			
            else
              state					<= idle;
              rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';			  
			  task_create_en		<= '0';			  			  
			  time_delay_en			<= '0';
			  sema4_create_en		<= '0';
			  sema4_pend_en		    <= '0';
			  sema4_pend_stat_en    <= '0';
			  sema4_post_en    		<= '0';
			  mbox_create_en		<= '0';
			  mbox_pend_en			<= '0';
			  mbox_pend_stat_en		<= '0';
			  mbox_post_en    		<= '0';
			  os_start_en			<= '0';
			  test_en				<= '0';
			  cont_timer_rd			<= '0';
            end if;

          when internal =>									--HWRTOS: Internal state
            if ( (cmd = X"01") or (cmd = X"83") or (cmd = X"85") or (cmd = X"87") or (cmd = X"89") or (cmd = X"8B") or (cmd = X"8D") or (cmd = X"8F") or (cmd = X"91") or (cmd = X"93") or (cmd = X"95") or (cmd = X"97") or (cmd = X"99") or (cmd = X"9B") or (cmd = X"9D") or (cmd = X"9F")) then             
              state					<= internal;
			  rst_en				<= '0';
			  tick_en				<= '1';
			  tick_sel				<= '0';			  
			  task_create_en		<= '0';			 			  
			  time_delay_en			<= '0';
			  sema4_create_en		<= '0';
			  sema4_pend_en			<= '0';
			  sema4_pend_stat_en	<= '0';
			  sema4_post_en			<= '0';
			  mbox_create_en		<= '0';
			  mbox_pend_en			<= '0';
			  mbox_pend_stat_en		<= '0';
			  mbox_post_en			<= '0';
			  os_start_en			<= '0';
			  test_en				<= '0';
			  cont_timer_rd			<= '0';
			  if (cmd = X"9B") then
			    sw_ctrl_timer_en	<= '1';
			  end if;
              
            elsif ( (cmd = X"80") or (cmd = X"82") or (cmd = X"84") or (cmd = X"86") or (cmd = X"88") or (cmd = X"8A") or (cmd = X"8C") or (cmd = X"8E") or (cmd = X"90") or (cmd = X"92") or (cmd = X"94") or (cmd = X"96") or (cmd = X"98") or (cmd = X"9A") or (cmd = X"9C") or (cmd = X"9E")) then             
              state					<= external;			--HWRTOS: Transitions to External state
			  if (cmd = X"80") then
				tick_en				<= '0';
				tick_sel			<= '1';			  
			  elsif (cmd = X"82") then
				tick_en				<= '0';
				task_create_en		<= '1';			  			  
			  elsif (cmd = X"84") then
				tick_en				<= '0';
				time_delay_en		<= '1';
			  elsif (cmd = X"86") then
				tick_en				<= '0';
				sema4_create_en		<= '1';			  
			  elsif (cmd = X"88") then
				tick_en				<= '0';
				sema4_pend_en		<= '1';
			  elsif (cmd = X"8A") then
				tick_en				<= '0';
				sema4_pend_stat_en	<= '1';
			  elsif (cmd = X"8C") then
				tick_en				<= '0';
				sema4_post_en		<= '1';
			  elsif (cmd = X"8E") then
				tick_en				<= '0';
				mbox_create_en		<= '1';
			  elsif (cmd = X"90") then
				tick_en				<= '0';
				mbox_pend_en		<= '1';
			  elsif (cmd = X"92") then
				tick_en				<= '0';
				mbox_pend_stat_en	<= '1';
			  elsif (cmd = X"94") then
				tick_en				<= '0';
				mbox_post_en		<= '1';
			  elsif (cmd = X"96") then
				tick_en				<= '0';
				os_start_en			<= '1';
			  elsif (cmd = X"98") then
				tick_en				<= '0';
				test_en				<= '1';
			  elsif (cmd = X"9A") then
				rst_en				<= '0';
				sw_ctrl_timer_en	<= '1';
			  elsif (cmd = X"9C") then
				rst_en				<= '0';
				sw_ctrl_timer_en	<= '0';			  
			  elsif (cmd = X"9E") then
				rst_en				<= '0';
				cont_timer_rd		<= '1';
			  end if;
              
            elsif ( cmd = X"00" ) then              
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
              
            else
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';			 
			  task_create_en		<= '0';			 			  
			  time_delay_en			<= '0'; 
			  sema4_create_en		<= '0';             
			  sema4_pend_en			<= '0';
			  sema4_pend_stat_en	<= '0';
			  sema4_post_en			<= '0';
			  mbox_create_en		<= '0';
			  mbox_pend_en			<= '0';
			  mbox_pend_stat_en		<= '0';
			  mbox_post_en			<= '0';
			  os_start_en			<= '0';
			  test_en				<= '0';
			  cont_timer_rd			<= '0';
            end if;

          when external =>									--HWRTOS: External state
            if ( (cmd = X"80") or (cmd = X"82") or (cmd = X"83") or (cmd = X"84") or (cmd = X"85") or (cmd = X"86") or (cmd = X"87") or (cmd = X"88") or (cmd = X"89") or (cmd = X"8A") or (cmd = X"8B") or (cmd = X"8C") or (cmd = X"8D") or (cmd = X"8E") or (cmd = X"8F") or (cmd = X"90") or (cmd = X"91") or (cmd = X"92") or (cmd = X"93") or (cmd = X"94") or (cmd = X"95") or (cmd = X"96") or (cmd = X"97") or (cmd = X"98") or (cmd = X"99") or (cmd = X"9A") or (cmd = X"9B") or (cmd = X"9C") or (cmd = X"9D") or (cmd = X"9E") or (cmd = X"9F")) then             
              state					<= external;
			  if (cmd = X"80") then
				rst_en				<= '0';
				tick_en				<= '0';
				tick_sel			<= '1';			 
			  elsif ((cmd = X"82") or (cmd = X"83")) then
				rst_en				<= '0';
				tick_en				<= '0';
				task_create_en		<= '1';			  			  
			  elsif ((cmd = X"84") or (cmd = X"85")) then
				rst_en				<= '0';
				tick_en				<= '0';
				time_delay_en		<= '1';
			  elsif ((cmd = X"86") or (cmd = X"87")) then
				rst_en				<= '0';
				tick_en				<= '0';
				sema4_create_en		<= '1';			  
			  elsif ((cmd = X"88") or (cmd = X"89")) then
				rst_en				<= '0';
				tick_en				<= '0';
				sema4_pend_en		<= '1';
			  elsif ((cmd = X"8A") or (cmd = X"8B")) then
				rst_en				<= '0';
				tick_en				<= '0';
				sema4_pend_stat_en	<= '1';
			  elsif ((cmd = X"8C") or (cmd = X"8D")) then
				rst_en				<= '0';
				tick_en				<= '0';
				sema4_post_en		<= '1';
			  elsif ((cmd = X"8E") or (cmd = X"8F")) then
				rst_en				<= '0';
				tick_en				<= '0';
				mbox_create_en		<= '1';
			  elsif ((cmd = X"90") or (cmd = X"91")) then
				rst_en				<= '0';
				tick_en				<= '0';
				mbox_pend_en		<= '1';
			  elsif ((cmd = X"92") or (cmd = X"93")) then
				rst_en				<= '0';
				tick_en				<= '0';
				mbox_pend_stat_en	<= '1';
			  elsif ((cmd = X"94") or (cmd = X"95")) then
				rst_en				<= '0';
				tick_en				<= '0';
				mbox_post_en		<= '1';
			  elsif ((cmd = X"96") or (cmd = X"97")) then
				rst_en				<= '0';
				tick_en				<= '0';
				os_start_en			<= '1';
			  elsif ((cmd = X"98") or (cmd = X"99")) then
				rst_en				<= '0';
				tick_en				<= '0';
				test_en				<= '1';
			  elsif ((cmd = X"9A") or (cmd = X"9B")) then
				rst_en				<= '0';
				tick_en				<= '0';
				sw_ctrl_timer_en	<= '1';
			  elsif ((cmd = X"9C") or (cmd = X"9D")) then
				rst_en				<= '0';
				tick_en				<= '0';
				sw_ctrl_timer_en	<= '0';			  
			  elsif ((cmd = X"9E") or (cmd = X"9F")) then
				rst_en				<= '0';
				tick_en				<= '0';
				cont_timer_rd		<= '1';
			  end if;
              
            elsif ( cmd = X"01" ) then             			--HWRTOS: Transitions to Internal state
              state					<= internal;
			  rst_en				<= '0';
			  tick_en				<= '1';
			  tick_sel				<= '0';			  
			  task_create_en		<= '0';			  				 
			  time_delay_en			<= '0';
			  sema4_create_en		<= '0';
			  sema4_pend_en			<= '0';
			  sema4_pend_stat_en	<= '0';
			  sema4_post_en			<= '0';
			  mbox_create_en		<= '0';
			  mbox_pend_en  		<= '0';
			  mbox_pend_stat_en		<= '0';
			  mbox_post_en			<= '0';
			  os_start_en			<= '0';
			  test_en				<= '0';
			  cont_timer_rd			<= '0';
              
            elsif ( cmd = X"00" ) then              
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';			  
			  task_create_en		<= '0';			  					 
			  time_delay_en			<= '0';
			  sema4_create_en		<= '0';
			  sema4_pend_en			<= '0';
			  sema4_pend_stat_en	<= '0';
			  sema4_post_en			<= '0';
			  mbox_create_en		<= '0';
			  mbox_pend_en  		<= '0';
			  mbox_pend_stat_en		<= '0';
			  mbox_post_en			<= '0';
			  os_start_en			<= '0';
			  test_en				<= '0';
			  cont_timer_rd			<= '0';
              
            else
              state					<= idle;
			  rst_en				<= '1';
			  tick_en				<= '0';
			  tick_sel				<= '0';			  
			  task_create_en		<= '0';			 			  
			  time_delay_en			<= '0';
			  sema4_create_en		<= '0';
			  sema4_pend_en			<= '0';
			  sema4_pend_stat_en	<= '0';
			  sema4_post_en			<= '0';
			  mbox_create_en		<= '0';
			  mbox_pend_en  		<= '0';
			  mbox_pend_stat_en		<= '0';
			  mbox_post_en			<= '0'; 
			  os_start_en			<= '0';
			  test_en				<= '0'; 
			  cont_timer_rd			<= '0';			  
            end if;
          
          when others =>
            state    				<= idle;  
			rst_en					<= '1';
			tick_en					<= '0';
			tick_sel				<= '0';			
			task_create_en			<= '0';							
			time_delay_en			<= '0';
			sema4_create_en		    <= '0';
			sema4_pend_en			<= '0';
			sema4_pend_stat_en		<= '0';
			sema4_post_en			<= '0';
			mbox_create_en		    <= '0';
			mbox_pend_en  			<= '0';
			mbox_pend_stat_en		<= '0';
			mbox_post_en			<= '0';
			os_start_en				<= '0';
			test_en					<= '0';
			cont_timer_rd			<= '0';

        end case;
      end if;
    end if;
  end process hwrtos_state_machine;


	--HWRTOS: Reset function
hwrtos_reset: process( rst_en ) is  						  
  
  begin	
	if rst_en'event and rst_en = '1' then
		rst_out      				<= (others => '0');
	end if;									 		  			     	  	 
  end process hwrtos_reset;


	--HWRTOS: HW/OS initiliazation function
hwrtos_hwos_init: process( hw_init_en ) is  
  
  begin	
	if hw_init_en'event and hw_init_en = '1' then
		ostsk_idle_prio   		 	<= slv_reg0(48 to 55);		
		--timer_value	 			<= plb_clk / os_tick_per_sec;   (80000000 / 100 = 800000 (20 bits counter = X"C3500"))		
		timer_value					<= slv_reg0(0 to 31);
		sw_bit						<= slv_reg0(47);
	end if;									 		  			     	  	 
  end process hwrtos_hwos_init;


	--HWRTOS: Timer to measure the time taken to loop for all tasks and decrement the delay
	--HWRTOS: and if needed send an interrupt to ask the software for a context switch
hwrtos_tick_timer_enable: process( tick_en, tick_update_d ) is    

  begin	
	if tick_update_d = '1' then		
		tick_timer_en				<= '0';
	elsif tick_en'event and tick_en = '1' then
		tick_timer_en		   		<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_tick_timer_enable;
	
  tick_timer_rst 		<= (not(tick_int) and tick_upd_rst) or tick_sel_rst;

hwrtos_tick_timer: process( Bus2IP_Clk, tick_timer_rst, tick_timer_en ) is    			

  begin	
	if tick_timer_rst = '1' then		
		tick_timer_cnt				<= X"01";
	elsif tick_timer_en = '1' then
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
		  tick_timer_cnt			<= tick_timer_cnt + 1;		  
	    end if;
	end if;									 		  			     	  	 
  end process hwrtos_tick_timer;


	--HWRTOS: Timer to measure the time from sending the interrupt to the sw to receive the response command from the sw
hwrtos_int_resp_timer_enable: process( tick_int, tick_sel ) is    

  begin	
	if tick_sel = '1' then		
		int_resp_timer_en			<= '0';
	elsif tick_int'event and tick_int = '1' then
		int_resp_timer_en		 	<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_int_resp_timer_enable;
	
  
hwrtos_int_resp_timer: process( Bus2IP_Clk, tick_sel_rst, int_resp_timer_en ) is    			
																				
  begin	
	if tick_sel_rst = '1' then		
		int_resp_timer_cnt			<= X"0000";
	elsif int_resp_timer_en = '1' then
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
		  int_resp_timer_cnt		<= int_resp_timer_cnt + 1;		  
	    end if;
	end if;									 		  			     	  	 
  end process hwrtos_int_resp_timer;


	--HWRTOS: Timer to measure the time of sw initiated requests
  cmd_en		 	<= task_create_en or time_delay_en or sema4_create_en or sema4_pend_en or sema4_pend_stat_en or sema4_post_en or mbox_create_en or mbox_pend_en or mbox_pend_stat_en or mbox_post_en or os_start_en;
  cmd_dis			<= task_create_update_d or time_delay_update_d or sema4_create_update_d or sema4_pend_update_d or sema4_pend_stat_update_d or sema4_post_update_d or mbox_create_update_d or mbox_pend_update_d or mbox_pend_stat_update_d  or mbox_post_update_d or os_start_update_d;
  ext_cmd_timer_rst	<= task_create_rst or time_delay_rst or sema4_create_rst or sema4_pend_rst or sema4_pend_stat_rst or sema4_post_rst or mbox_create_rst or mbox_pend_rst or mbox_pend_stat_rst or mbox_post_rst or os_start_rst;

hwrtos_ext_cmd_timer_enable: process( cmd_en, cmd_dis ) is    

  begin	
	if cmd_dis = '1' then		
		ext_cmd_timer_en			<= '0';
	elsif cmd_en'event and cmd_en = '1' then
		ext_cmd_timer_en		   	<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_ext_cmd_timer_enable;
	
  
hwrtos_ext_cmd_timer: process( Bus2IP_Clk, ext_cmd_timer_rst, ext_cmd_timer_en ) is    			
																				
  begin	
	if ext_cmd_timer_rst = '1' then		
		ext_cmd_timer_cnt			<= X"03";
	elsif ext_cmd_timer_en = '1' then
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
		  ext_cmd_timer_cnt			<= ext_cmd_timer_cnt + 1;		  
	    end if;
	end if;									 		  			     	  	 
  end process hwrtos_ext_cmd_timer;


	--HWRTOS: Stop-watch timer
hwrtos_sw_ctrl_timer_update: process( sw_ctrl_timer_en, sw_ctrl_timer_rst) is    					
																				
  begin	
	if sw_ctrl_timer_rst = '1' then		
		sw_ctrl_timer_update		<= '0';
	elsif sw_ctrl_timer_en'event and sw_ctrl_timer_en = '0' then		
		sw_ctrl_timer_update		<= '1';		  	    
	end if;									 		  			     	  	 
  end process hwrtos_sw_ctrl_timer_update;


hwrtos_sw_ctrl_timer: process( Bus2IP_Clk, sw_ctrl_timer_rst, sw_ctrl_timer_en ) is    			
																				
  begin	
	if sw_ctrl_timer_rst = '1' then		
		sw_ctrl_timer_cnt			<= X"00000000";
	elsif sw_ctrl_timer_en = '1' then
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
		  sw_ctrl_timer_cnt			<= sw_ctrl_timer_cnt + 1;		  
	    end if;
	end if;									 		  			     	  	 
  end process hwrtos_sw_ctrl_timer;


	--HWRTOS: Continuous timer
hwrtos_cont_time_enable: process( cont_timer_en, cont_timer_dis ) is    

  begin	
	if cont_timer_dis = '1' then		
		cont_timer_start			<= '0';
	elsif cont_timer_en'event and cont_timer_en = '1' then
		cont_timer_start   			<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_cont_time_enable;
  
  
hwrtos_cont_timer: process( Bus2IP_Clk, cont_timer_start_1shot, cont_timer_start ) is    			
																				
  begin	
	if cont_timer_start_1shot = '1' then		
		cont_timer_cnt				<= X"00000000";
	elsif cont_timer_start = '1' then
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
		  cont_timer_cnt			<= cont_timer_cnt + 1;		  
	    end if;
	end if;									 		  			     	  	 
  end process hwrtos_cont_timer;  


	--HWRTOS: Tick timer
hwrtos_os_time_enable: process( os_time_en, os_time_dis ) is    

  begin	
	if os_time_dis = '1' then		
		time_tick_rst				<= '0';
	elsif os_time_en'event and os_time_en = '1' then
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
		cmd(7)						<= '0';
	elsif os_time_tick'event and os_time_tick = '1' then
		cmd(7)						<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_tick_en;


	--HWRTOS: Periodic tick fucntion 
hwrtos_tick_act: process( tick_en, tick_upd_rst, tick_sel_rst ) is      
  variable priority			: integer range 0 to 15 := 0;  
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";   
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";  
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  variable dec_delay_v		: std_logic_vector(0 to 15) := X"0000";		
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
			for i in 0 to 15 loop											--HWRTOS: Loop for the 16 TCBs
				priority				:= i;
				dec_delay_v				:= ostcb(i).dec_delay;
				stat_v					:= ostcb(i).stat;
				stat_pend_v				:= ostcb(i).stat_pend;				
				if (dec_delay_v /= X"0000") then
					dec_delay_v				:= dec_delay_v - 1;				--HWRTOS: Decrements task period				
					if (dec_delay_v = X"0000") then
						if ((stat_v and X"37") /= X"00") then				--Pending timeout
							stat_v		:= stat_v and X"C8";
							stat_pend_v	:= X"01";
						else
							stat_pend_v	:= X"00";				
						end if;																
						add_to_list (priority, rdy_grp_v, rdy_tbl_v);
							dec_delay_v	:= ostcb(i).delay;
					end if;	
				end if;
				tick_tcb(i).dec_delay	<= dec_delay_v;
				tick_tcb(i).stat		<= stat_v;
				tick_tcb(i).stat_pend	<= stat_pend_v;	
			end loop;	
			tick_rdy_grp				<= rdy_grp_v;
			tick_rdy_tbl				<= rdy_tbl_v;					
			find_hi_prio (rdy_grp_v, rdy_tbl_v, prio_high);			
			if (prio_high /= osprio_current) then			    	
				tick_out				<= X"0000000000" & prio_high & osprio_current & X"01";									 		  			     	  	 
				tick_int				<= '1';  							--HWRTOS: Sends an interrupt			
			end if;															
			tick_update					<= '1';                                                   		
		end if;		
	end if;	
  end process hwrtos_tick_act;


	--HWRTOS: Create task function
hwrtos_task_create: process( task_create_en, task_create_rst ) is  					  
  variable index   			: integer range 0 to 15 := 0;  
  variable free_v			: std_logic := '0'; 
  variable temp_y_un	    : unsigned(0 to 7) := X"00";  
  variable temp_y_int	   	: integer range 0 to 255 := 0;  
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00";
  variable os_ctx_sw_cntr   : std_logic_vector(0 to 7) := X"00";
  variable prio_current     : std_logic_vector(0 to 7) := X"00";
  variable tsk_ctx_sw_cntr  : std_logic_vector(0 to 31)	:= X"00000000";
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
		free_v		:= ostcb(index).free;
		if (free_v = '0') then											--HWRTOS: Create task if no task with the same priority already reserved
			free_v 						:= '1';			
			task_create_tcb.prio	   	<= slv_reg0(48 to 55);
			task_create_tcb.stat	   	<= X"00";
			task_create_tcb.stat_pend  	<= X"00";
			task_create_tcb.delay	   	<= slv_reg0(16 to 31);
			task_create_tcb.dec_delay	<= slv_reg0(16 to 31);								
			task_create_tcb.id		   	<= slv_reg0(32 to 47);						
			temp_y_un  	:= shr(UNSIGNED(slv_reg0(48 to 55)),CONV_UNSIGNED(3,2));		
			y_v					        := STD_LOGIC_VECTOR(temp_y_un); 		     
			x_v							:= slv_reg0(48 to 55) and X"07";	             
			bity_v					    := STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),temp_y_un));			    
			bitx_v					    := STD_LOGIC_VECTOR(shl(CONV_UNSIGNED(1,8),UNSIGNED(x_v)));						
			task_create_tcb.event_no  	<= X"00";						
			task_create_tcb.msg			<= X"00000000";
			task_create_tcb.ctx_sw_cntr	<= X"00000000";												
			task_create_tcb.task_name	<= slv_reg0(8 to 15);
			temp_y_int 	:= CONV_INTEGER(y_v);
			rdy_grp_v					:= osrdy_grp;
			rdy_tbl_v					:= osrdy_tbl;
			rdy_grp_v 		   	   		:= rdy_grp_v or bity_v;
			rdy_tbl_v(temp_y_int)   	:= rdy_tbl_v(temp_y_int) or bitx_v;
			task_create_tsk_cntr		<= ostsk_cntr + 1;				
			if (osrunning = '1') then 									--HWRTOS: Call scheduler if OS is running
				sched (rdy_grp_v, rdy_tbl_v, prio_high, cntx_sw, tsk_ctx_sw_cntr, os_ctx_sw_cntr, prio_current);
				task_create_prio_high_rdy			<= prio_high;			
				task_create_tcb_ctx_sw_cntr_hprio	<= tsk_ctx_sw_cntr;
				task_create_ctx_sw_cntr				<= os_ctx_sw_cntr;
				task_create_prio_current    		<= prio_current;					
			else
				cntx_sw     := X"00";
				task_create_prio_high_rdy	<= osprio_high_rdy;			
				task_create_prio_current	<= osprio_current;			
				task_create_ctx_sw_cntr		<= osctx_sw_cntr;
			end if; 
			task_create_tcb.y	 	<= y_v; 		     
			task_create_tcb.x		<= x_v;	             
			task_create_tcb.bity 	<= bity_v;			    
			task_create_tcb.bitx  	<= bitx_v;	
			task_create_rdy_grp		<= rdy_grp_v;
			task_create_rdy_tbl		<= rdy_tbl_v;
		end if;		
		task_create_tcb.free		<= free_v;	
		task_create_out  	 		<= X"000000" & prio_high & osprio_current & cntx_sw & B"0000000" & ostcb(index).free & X"01";					
		task_create_update			<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_task_create;


	--HWRTOS: OS-Start fucntion
hwrtos_osstart: process( os_start_en, os_start_rst ) is  					    
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";   
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";  
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");

  begin	
	if os_start_rst = '1' then
		os_start_out					<= (others => '0');
		os_start_update					<= '0';
	elsif os_start_en'event and os_start_en = '1' then			
		os_start_prio_high_rdy	  		<= osprio_high_rdy;
		os_start_prio_current       	<= osprio_current;
		os_start_running				<= osrunning;
		if osrunning = '0' then
			rdy_grp_v					:= osrdy_grp;
			rdy_tbl_v					:= osrdy_tbl;    		
			find_hi_prio (rdy_grp_v, rdy_tbl_v, prio_high);
			os_start_prio_high_rdy	  	<= prio_high;
			os_start_prio_current       <= prio_high;
			os_start_running			<= '1';
		end if;		
		os_start_out	   			    <= X"0000000000" & prio_high & B"0000000" & osrunning & X"01";
		os_start_update					<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_osstart;


	--HWRTOS: Task done function
hwrtos_time_delay: process( time_delay_en, time_delay_rst ) is  					  
  variable index   			: integer range 0 to 15 := 0;  
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00"; 
  variable os_ctx_sw_cntr   : std_logic_vector(0 to 7) := X"00";
  variable prio_current     : std_logic_vector(0 to 7) := X"00";
  variable tsk_ctx_sw_cntr  : std_logic_vector(0 to 31)	:= X"00000000";
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
		remove_from_list (index, rdy_grp_v, rdy_tbl_v);								
		sched (rdy_grp_v, rdy_tbl_v, prio_high, cntx_sw, tsk_ctx_sw_cntr, os_ctx_sw_cntr, prio_current);
		time_delay_prio_high_rdy			<= prio_high;			
		time_delay_tcb.ctx_sw_cntr_hprio	<= tsk_ctx_sw_cntr;
		time_delay_ctx_sw_cntr				<= os_ctx_sw_cntr;
		time_delay_prio_current    			<= prio_current;					
		time_delay_rdy_grp					<= rdy_grp_v;
		time_delay_rdy_tbl					<= rdy_tbl_v;																													    					    
		time_delay_out  		 			<= X"00000000" & prio_high & osprio_current & cntx_sw & X"01";					
		time_delay_update					<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_time_delay;


	--HWRTOS: Test function
hwrtos_test: process( test_en, test_rst ) is    
  variable index   			: integer range 0 to 15 := 0; 
  variable index_ecb		: integer range 0 to 16 := 0;
  
  begin	
	if test_rst = '1' then
		test_out0					<= (others => '0');
		test_out1					<= (others => '0');
		test_out2					<= (others => '0');		
		test_sel					<= '0';
	elsif test_en'event and test_en = '1' then	
		if (slv_reg0(40 to 47) = X"FF") then
			index					:= CONV_INTEGER(osprio_current);
		else
			index					:= CONV_INTEGER(slv_reg0(40 to 47));
		end if;
		index_ecb					:= CONV_INTEGER(slv_reg0(32 to 39));
		case slv_reg0(48 to 55) is
          when X"00" =>						--HWRTOS: Copy tcb content
			test_out0				<= ostcb(index).msg & ostcb(index).ctx_sw_cntr;
			test_out1				<= ostcb(index).stat_pend & ostcb(index).stat & ostcb(index).id & ostcb(index).dec_delay & ostcb(index).delay;
			test_out2				<= B"0000000" & ostcb(index).free & ostcb(index).event_no & ostcb(index).bity & ostcb(index).bitx & ostcb(index).y & ostcb(index).x & ostcb(index).task_name & ostcb(index).prio;			
		  when X"01" =>						--HWRTOS: Copy system parameter + ready list
			test_out0				<= ostsk_cntr & ostsk_idle_prio & osprio_high_rdy & osprio_current & ostime;			
			test_out1				<= osrdy_tbl(7) & osrdy_tbl(6) & osrdy_tbl(5) & osrdy_tbl(4) & osrdy_tbl(3) & osrdy_tbl(2) & osrdy_tbl(1) & osrdy_tbl(0);
			test_out2				<= X"0000000000" & B"00000" & sw_bit & tick_int & osrunning & osctx_sw_cntr & osrdy_grp;			
		  when X"02" =>						--HWRTOS: Copy ecb content
			test_out0				<= ecb(index_ecb).osevent_name & ecb(index_ecb).osevent_type & ecb(index_ecb).osevent_cnt & ecb(index_ecb).osevent_ptr;
			test_out1				<= ecb(index_ecb).osevent_tbl(7) & ecb(index_ecb).osevent_tbl(6) & ecb(index_ecb).osevent_tbl(5) & ecb(index_ecb).osevent_tbl(4) & ecb(index_ecb).osevent_tbl(3) & ecb(index_ecb).osevent_tbl(2) & ecb(index_ecb).osevent_tbl(1) & ecb(index_ecb).osevent_tbl(0);
			test_out2				<= X"000000000000" & B"0000000" & ecb(index_ecb).osevent_free & ecb(index_ecb).osevent_grp;			
		  when others =>
			test_out0				<= (others => '0');
			test_out1				<= (others => '0');
			test_out2				<= (others => '0');			
		end case;		
		test_sel					<= '1';			
	end if;	
  end process hwrtos_test;


	--HWRTOS: Create semaphore function
hwrtos_sema4create: process( sema4_create_en, sema4_create_rst ) is 
  variable ecb_found   		: std_logic := '0';	
  variable ecb_num   		: integer range 0 to 16 := 0; 				   

  begin	
	if sema4_create_rst = '1' then
		sema4_create_out				<= (others => '0');
		sema4_create_update				<= '0';
	elsif sema4_create_en'event and sema4_create_en = '1' then	
		ecb_found	:= '0';
		ecb_num		:= 0;
		for i in 1 to 16 loop
			if ((ecb(i).osevent_free = '0') and (ecb_found = '0')) then
				ecb_found	:= '1';
				ecb_num		:= i;
			end if;
		end loop;
		if (ecb_found = '1') then						--HWRTOS: Check if all ECBs are reserved or not
			sema4_create_ecb.osevent_type <= X"03";	
			sema4_create_ecb.osevent_free <= '1';
			sema4_create_ecb.osevent_cnt  <= slv_reg0(40 to 55);							
			sema4_create_ecb.osevent_ptr  <= X"00000000";
		end if;							
		sema4_create_out 				  <= X"000000000000" & CONV_STD_LOGIC_VECTOR(ecb_num, 8) & X"01";				
		sema4_create_update				  <= '1';
	end if;									 		  			     	  	 
  end process hwrtos_sema4create;


	--HWRTOS: Pend on semaphore function
hwrtos_sema4pend: process( sema4_pend_en, sema4_pend_rst ) is 
  variable error     		: std_logic_vector(0 to 7) := X"00";	  	
  variable index_ecb 		: integer range 0 to 16 := 0; 
  variable index_tcb		: integer range 0 to 15 := 0;  
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00";
  variable os_ctx_sw_cntr   : std_logic_vector(0 to 7) := X"00";
  variable prio_current     : std_logic_vector(0 to 7) := X"00";
  variable tsk_ctx_sw_cntr  : std_logic_vector(0 to 31)	:= X"00000000";
  variable event_rdy_grp_v	: std_logic_vector(0 to 7) := X"00";     
  variable event_rdy_tbl_v	: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";     
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");				   

  begin	
	if sema4_pend_rst = '1' then
		sema4_pend_out				<= (others => '0');
		sema4_pend_update			<= '0';
	elsif sema4_pend_en'event and sema4_pend_en = '1' then			
		index_ecb			:= CONV_INTEGER(slv_reg0(48 to 55));
		index_tcb			:= CONV_INTEGER(osprio_current);
		event_rdy_grp_v		:= ecb(index_ecb).osevent_grp;
		event_rdy_tbl_v		:= ecb(index_ecb).osevent_tbl;
		rdy_grp_v			:= osrdy_grp;
		rdy_tbl_v			:= osrdy_tbl;
		error 				:= X"00";
		cntx_sw      		:= X"00";
		
		if (ecb(index_ecb).osevent_type /= X"03" ) then
			error 			:= X"01";							--HWRTOS: Type error
		elsif (ecb(index_ecb).osevent_cnt > 0 ) then
			sema4_pend_ecb.osevent_cnt  <= ecb(index_ecb).osevent_cnt - 1;	
			error 			:= X"00";							--HWRTOS: Key is available
		else													--HWRTOS: Else wait for a key
			sema4_pend_tcb.stat			<= ostcb(index_tcb).stat or X"01";  
			sema4_pend_tcb.stat_pend	<= X"00";  
			sema4_pend_tcb.dec_delay	<= slv_reg0(32 to 47);			  			
			sema4_pend_tcb.event_no		<= slv_reg0(48 to 55);			
			add_to_list (index_tcb, event_rdy_grp_v, event_rdy_tbl_v);						
			remove_from_list (index_tcb, rdy_grp_v, rdy_tbl_v);			
			sched (rdy_grp_v, rdy_tbl_v, prio_high, cntx_sw, tsk_ctx_sw_cntr, os_ctx_sw_cntr, prio_current);
			sema4_pend_prio_high_rdy			<= prio_high;			
			sema4_pend_tcb_ctx_sw_cntr_hprio	<= tsk_ctx_sw_cntr;
			sema4_pend_ctx_sw_cntr				<= os_ctx_sw_cntr;
			sema4_pend_prio_current    			<= prio_current;			
			sema4_pend_ecb.osevent_tbl			<= event_rdy_tbl_v;
			sema4_pend_ecb.osevent_grp			<= event_rdy_grp_v;
			sema4_pend_rdy_tbl					<= rdy_tbl_v;
			sema4_pend_rdy_grp					<= rdy_grp_v;										
		end if;								
		sema4_pend_out 				<= X"000000" & prio_high & osprio_current & cntx_sw & error & X"01";				
		sema4_pend_update			<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_sema4pend;


	--HWRTOS: Pend on semaphore status function
hwrtos_sema4pend_stat: process( sema4_pend_stat_en, sema4_pend_stat_rst ) is 
  variable error     		: std_logic_vector(0 to 7) := X"00";	  	
  variable index_ecb 		: integer range 0 to 16 := 0; 
  variable index_tcb		: integer range 0 to 15 := 0;
  variable event_rdy_grp_v	: std_logic_vector(0 to 7) := X"00";     
  variable event_rdy_tbl_v	: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");  			   

  begin	
	if sema4_pend_stat_rst = '1' then
		sema4_pend_stat_out			<= (others => '0');
		sema4_pend_stat_update		<= '0';
	elsif sema4_pend_stat_en'event and sema4_pend_stat_en = '1' then			
		index_ecb			:= CONV_INTEGER(slv_reg0(48 to 55));
		index_tcb			:= CONV_INTEGER(osprio_current);
		event_rdy_grp_v		:= ecb(index_ecb).osevent_grp;
		event_rdy_tbl_v		:= ecb(index_ecb).osevent_tbl;
		case ostcb(index_tcb).stat_pend is
          when X"00" =>
			error	:= X"00";					--HWRTOS: No error
		  when X"02" =>
			error	:= X"0E";					--HWRTOS: Pending aborted
		  when X"01" =>
			error	:= X"0A";					--HWRTOS: Pending timed out
			remove_from_list (index_tcb, event_rdy_grp_v, event_rdy_tbl_v);
		  when others =>
			error	:= X"00";
		end case;
		sema4_pend_stat_ecb.osevent_tbl	<= event_rdy_tbl_v;
		sema4_pend_stat_ecb.osevent_grp	<= event_rdy_grp_v;
		sema4_pend_stat_tcb.stat		<= X"00";  
		sema4_pend_stat_tcb.stat_pend	<= X"00";  		
		sema4_pend_stat_tcb.event_no	<= X"00";
																						
		sema4_pend_stat_out 			<= X"000000000000" & error & X"01";				
		sema4_pend_stat_update			<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_sema4pend_stat;


	--HWRTOS: Post semaphore function
hwrtos_sema4post: process( sema4_post_en, sema4_post_rst ) is 
  variable error     		: std_logic_vector(0 to 7) := X"00";	  	
  variable index_ecb 		: integer range 0 to 16 := 0;
  variable index_tcb		: integer range 0 to 15 := 0;  
  variable prio_high_wait   : std_logic_vector(0 to 7) := X"00";
  variable prio_high		: std_logic_vector(0 to 7) := X"00";          
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00";
  variable stat   			: std_logic_vector(0 to 7) := X"00";
  variable novf   			: std_logic_vector(0 to 7) := X"00";
  variable os_ctx_sw_cntr   : std_logic_vector(0 to 7) := X"00";
  variable prio_current     : std_logic_vector(0 to 7) := X"00";
  variable tsk_ctx_sw_cntr  : std_logic_vector(0 to 31)	:= X"00000000";
  variable event_rdy_grp_v	: std_logic_vector(0 to 7) := X"00";     
  variable event_rdy_tbl_v	: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";     
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");	
         			   
  begin	
	if sema4_post_rst = '1' then
		sema4_post_out				<= (others => '0');
		sema4_post_update			<= '0';
	elsif sema4_post_en'event and sema4_post_en = '1' then	
		index_ecb			:= CONV_INTEGER(slv_reg0(48 to 55));		
		event_rdy_grp_v		:= ecb(index_ecb).osevent_grp;
		event_rdy_tbl_v		:= ecb(index_ecb).osevent_tbl;
		rdy_grp_v			:= osrdy_grp;
		rdy_tbl_v			:= osrdy_tbl;
		cntx_sw     		:= X"00";
		novf				:= X"00";		
		if (ecb(index_ecb).osevent_type /= X"03" ) then
			error 			:= X"01";							--HWRTOS: Type error
		elsif (event_rdy_grp_v /= X"00" ) then					--HWRTOS: There is waiting task(s) for the semaphore				
			find_hi_prio (event_rdy_grp_v, event_rdy_tbl_v, prio_high_wait);
			index_tcb		:= CONV_INTEGER(prio_high_wait);
			sema4_post_tcb.dec_delay	<= ostcb(index_tcb).delay;
			sema4_post_tcb.msg			<= X"00000000";
			stat						:= ostcb(index_tcb).stat and (not X"01");
			sema4_post_tcb.stat			<= stat;
			sema4_post_tcb.stat_pend	<= X"00";
			if ((stat and X"08") = X"00") then				
				add_to_list (index_tcb, rdy_grp_v, rdy_tbl_v);
			end if;			
			remove_from_list (index_tcb, event_rdy_grp_v, event_rdy_tbl_v);									
			sched (rdy_grp_v, rdy_tbl_v, prio_high, cntx_sw, tsk_ctx_sw_cntr, os_ctx_sw_cntr, prio_current);
			sema4_post_prio_high_rdy			<= prio_high;			
			sema4_post_tcb_ctx_sw_cntr_hprio	<= tsk_ctx_sw_cntr;
			sema4_post_ctx_sw_cntr				<= os_ctx_sw_cntr;
			sema4_post_prio_current    			<= prio_current;	
			error 			:= X"00";		
		elsif (ecb(index_ecb).osevent_cnt < X"FFFF" ) then
			sema4_post_ecb.osevent_cnt  		<= ecb(index_ecb).osevent_cnt + 1;		
			novf			:= X"01";
			error 			:= X"00";							--HWRTOS: Key is available
		else
			error 			:= X"32";							--HWRTOS: Overflow error
		end if;																										
		sema4_post_ecb.osevent_tbl	<= event_rdy_tbl_v;
		sema4_post_ecb.osevent_grp	<= event_rdy_grp_v;
		sema4_post_rdy_tbl			<= rdy_tbl_v;
		sema4_post_rdy_grp			<= rdy_grp_v;																				
		sema4_post_out 				<= X"00" & novf & prio_high_wait & prio_high & osprio_current & cntx_sw & error & X"01";				
		sema4_post_update			<= '1';
	end if;								 		  			     	  	 
  end process hwrtos_sema4post;


	--HWRTOS: Create mailbox function
hwrtos_mboxcreate: process( mbox_create_en, mbox_create_rst ) is 
  variable ecb_found   		: std_logic := '0';	
  variable ecb_num   		: integer range 0 to 16 := 0; 				   

  begin	
	if mbox_create_rst = '1' then
		mbox_create_out					<= (others => '0');
		mbox_create_update				<= '0';
	elsif mbox_create_en'event and mbox_create_en = '1' then	
		ecb_found	:= '0';
		ecb_num		:= 0;
		for i in 1 to 16 loop
			if ((ecb(i).osevent_free = '0') and (ecb_found = '0')) then
				ecb_found	:= '1';
				ecb_num		:= i;
			end if;
		end loop;
		if (ecb_found = '1') then								--HWRTOS: Check if all ECBs are reserved or not
			mbox_create_ecb.osevent_type <= X"01";	
			mbox_create_ecb.osevent_free <= '1';
			mbox_create_ecb.osevent_cnt  <= X"0000";							
			mbox_create_ecb.osevent_ptr  <= slv_reg0(0 to 31);
		end if;							
		mbox_create_out 				<= X"000000000000" & CONV_STD_LOGIC_VECTOR(ecb_num, 8) & X"01";				
		mbox_create_update				<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_mboxcreate;


	--HWRTOS: Pend on message mailbox function
hwrtos_mboxpend: process( mbox_pend_en, mbox_pend_rst ) is 
  variable error     		: std_logic_vector(0 to 7) := X"00";	  	
  variable index_ecb 		: integer range 0 to 16 := 0; 
  variable index_tcb		: integer range 0 to 15 := 0;  
  variable msg_ptr     		: std_logic_vector(0 to 31) := X"00000000";  
  variable prio_high	    : std_logic_vector(0 to 7) := X"00";
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00";
  variable os_ctx_sw_cntr   : std_logic_vector(0 to 7) := X"00";
  variable prio_current     : std_logic_vector(0 to 7) := X"00";
  variable tsk_ctx_sw_cntr  : std_logic_vector(0 to 31)	:= X"00000000";
  variable event_rdy_grp_v	: std_logic_vector(0 to 7) := X"00";     
  variable event_rdy_tbl_v	: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";     
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");				   

  begin	
	if mbox_pend_rst = '1' then
		mbox_pend_out				<= (others => '0');
		mbox_pend_update			<= '0';
	elsif mbox_pend_en'event and mbox_pend_en = '1' then			
		index_ecb			:= CONV_INTEGER(slv_reg0(48 to 55));
		index_tcb			:= CONV_INTEGER(osprio_current);
		event_rdy_grp_v		:= ecb(index_ecb).osevent_grp;
		event_rdy_tbl_v		:= ecb(index_ecb).osevent_tbl;
		rdy_grp_v			:= osrdy_grp;
		rdy_tbl_v			:= osrdy_tbl;
		msg_ptr				:= X"00000000";
		error 				:= X"00";
		cntx_sw      		:= X"00";
		
		if (ecb(index_ecb).osevent_type /= X"01" ) then
			msg_ptr			:= X"00000000";
			error 			:= X"01";							--HWRTOS: Type error
		elsif (ecb(index_ecb).osevent_ptr /= X"00000000" ) then
			msg_ptr			:= ecb(index_ecb).osevent_ptr;
			mbox_pend_ecb.osevent_ptr   <= X"00000000";		
			error 			:= X"00";							--HWRTOS: Message is available				
		else													--HWRTOS: Else wait for a message
			mbox_pend_tcb.stat			<= ostcb(index_tcb).stat or X"02";  
			mbox_pend_tcb.stat_pend		<= X"00";  
			mbox_pend_tcb.dec_delay		<= slv_reg0(32 to 47);
			  			
			mbox_pend_tcb.event_no		<= slv_reg0(48 to 55);
						
			add_to_list (index_tcb, event_rdy_grp_v, event_rdy_tbl_v);
						
			remove_from_list (index_tcb, rdy_grp_v, rdy_tbl_v);
						
			sched (rdy_grp_v, rdy_tbl_v, prio_high, cntx_sw, tsk_ctx_sw_cntr, os_ctx_sw_cntr, prio_current);
			mbox_pend_prio_high_rdy				<= prio_high;			
			mbox_pend_tcb_ctx_sw_cntr_hprio		<= tsk_ctx_sw_cntr;
			mbox_pend_ctx_sw_cntr				<= os_ctx_sw_cntr;
			mbox_pend_prio_current    			<= prio_current;			
			mbox_pend_ecb.osevent_tbl			<= event_rdy_tbl_v;
			mbox_pend_ecb.osevent_grp			<= event_rdy_grp_v;
			mbox_pend_rdy_tbl					<= rdy_tbl_v;
			mbox_pend_rdy_grp					<= rdy_grp_v;										
		end if;	
		if (cntx_sw = X"01") then							
			mbox_pend_out 				<= X"000000" & prio_high & osprio_current & cntx_sw & error & X"01";				
		else
			mbox_pend_out 				<= msg_ptr & osprio_current & cntx_sw & error & X"01";				
		end if;
		mbox_pend_update				<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_mboxpend;


	--HWRTOS: Pend on message mailbox status function
hwrtos_mboxpend_stat: process( mbox_pend_stat_en, mbox_pend_stat_rst ) is 
  variable error     		: std_logic_vector(0 to 7) := X"00";	  	
  variable pmsg     		: std_logic_vector(0 to 31) := X"00000000";	  	
  variable index_ecb 		: integer range 0 to 16 := 0; 
  variable index_tcb		: integer range 0 to 15 := 0;
  variable event_rdy_grp_v	: std_logic_vector(0 to 7) := X"00";     
  variable event_rdy_tbl_v	: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  
  begin	
	if mbox_pend_stat_rst = '1' then
		mbox_pend_stat_out			<= (others => '0');
		mbox_pend_stat_update		<= '0';
	elsif mbox_pend_stat_en'event and mbox_pend_stat_en = '1' then			
		index_ecb			:= CONV_INTEGER(slv_reg0(48 to 55));
		index_tcb			:= CONV_INTEGER(osprio_current);
		event_rdy_grp_v		:= ecb(index_ecb).osevent_grp;
		event_rdy_tbl_v		:= ecb(index_ecb).osevent_tbl;
		case ostcb(index_tcb).stat_pend is
          when X"00" =>
			pmsg	:= ostcb(index_tcb).msg;
			error	:= X"00";						--HWRTOS: No error
		  when X"02" =>
			pmsg	:= X"00000000";
			error	:= X"0E";						--HWRTOS: Pending aborted
		  when X"01" =>
			pmsg	:= X"00000000";
			error	:= X"0A";			 			--HWRTOS: Pending timed out
			remove_from_list (index_tcb, event_rdy_grp_v, event_rdy_tbl_v);
		  when others =>	
			pmsg	:= X"00000000";
			error	:= X"00";
		end case;
		mbox_pend_stat_ecb.osevent_tbl	<= event_rdy_tbl_v;
		mbox_pend_stat_ecb.osevent_grp	<= event_rdy_grp_v;
		mbox_pend_stat_tcb.stat			<= X"00";  
		mbox_pend_stat_tcb.stat_pend	<= X"00";  		
		mbox_pend_stat_tcb.event_no		<= X"00";
		mbox_pend_stat_tcb.msg			<= X"00000000";
																						
		mbox_pend_stat_out 				<= pmsg & X"0000" & error & X"01";				
		mbox_pend_stat_update			<= '1';
	end if;									 		  			     	  	 
  end process hwrtos_mboxpend_stat;


	--HWRTOS: Post a message to a mailbox function
hwrtos_mboxpost: process( mbox_post_en, mbox_post_rst ) is 
  variable error     		: std_logic_vector(0 to 7) := X"00";	  	
  variable index_ecb 		: integer range 0 to 16 := 0;
  variable index_tcb		: integer range 0 to 15 := 0;  
  variable prio_high_wait   : std_logic_vector(0 to 7) := X"00";
  variable prio_high		: std_logic_vector(0 to 7) := X"00";   
  variable cntx_sw          : std_logic_vector(0 to 7) := X"00";
  variable stat   			: std_logic_vector(0 to 7) := X"00";
  variable nwait   			: std_logic_vector(0 to 7) := X"00";
  variable os_ctx_sw_cntr   : std_logic_vector(0 to 7) := X"00";
  variable prio_current     : std_logic_vector(0 to 7) := X"00";
  variable tsk_ctx_sw_cntr  : std_logic_vector(0 to 31)	:= X"00000000";
  variable event_rdy_grp_v	: std_logic_vector(0 to 7) := X"00";     
  variable event_rdy_tbl_v	: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");
  variable rdy_grp_v		: std_logic_vector(0 to 7) := X"00";     
  variable rdy_tbl_v		: rdy_tbl := (X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00");	
         			   
  begin	
	if mbox_post_rst = '1' then
		mbox_post_out				<= (others => '0');
		mbox_post_update			<= '0';
	elsif mbox_post_en'event and mbox_post_en = '1' then	
		index_ecb			:= CONV_INTEGER(slv_reg0(48 to 55));		
		event_rdy_grp_v		:= ecb(index_ecb).osevent_grp;
		event_rdy_tbl_v		:= ecb(index_ecb).osevent_tbl;
		rdy_grp_v			:= osrdy_grp;
		rdy_tbl_v			:= osrdy_tbl;
		cntx_sw      		:= X"00";
		nwait				:= X"00";
		if (ecb(index_ecb).osevent_type /= X"01" ) then
			error 			:= X"01";								--HWRTOS: Type error
		elsif (event_rdy_grp_v /= X"00" ) then						--HWRTOS: There is waiting task(s)
			find_hi_prio (event_rdy_grp_v, event_rdy_tbl_v, prio_high_wait);
			index_tcb		:= CONV_INTEGER(prio_high_wait);
			mbox_post_tcb.dec_delay		<= ostcb(index_tcb).delay;
			mbox_post_tcb.msg			<= slv_reg0(0 to 31);
			stat						:= ostcb(index_tcb).stat and (not X"02");
			mbox_post_tcb.stat			<= stat;
			mbox_post_tcb.stat_pend		<= X"00";
			if ((stat and X"08") = X"00") then				
				add_to_list (index_tcb, rdy_grp_v, rdy_tbl_v);
			end if;			
			remove_from_list (index_tcb, event_rdy_grp_v, event_rdy_tbl_v);				
			sched (rdy_grp_v, rdy_tbl_v, prio_high, cntx_sw, tsk_ctx_sw_cntr, os_ctx_sw_cntr, prio_current);
			mbox_post_prio_high_rdy				<= prio_high;			
			mbox_post_tcb_ctx_sw_cntr_hprio		<= tsk_ctx_sw_cntr;
			mbox_post_ctx_sw_cntr				<= os_ctx_sw_cntr;
			mbox_post_prio_current    			<= prio_current;			
			error 			:= X"00";		
		elsif (ecb(index_ecb).osevent_ptr /= X"00000000" ) then			
			error 			:= X"14";						--HWRTOS: There is a message already
		else
			mbox_post_ecb.osevent_ptr  	<= slv_reg0(0 to 31);		
			nwait			:= X"01";
			error 			:= X"00";						--HWRTOS: No error
		end if;																										
		mbox_post_ecb.osevent_tbl	<= event_rdy_tbl_v;
		mbox_post_ecb.osevent_grp	<= event_rdy_grp_v;
		mbox_post_rdy_tbl			<= rdy_tbl_v;
		mbox_post_rdy_grp			<= rdy_grp_v;																				
		mbox_post_out 				<= X"00" & nwait & prio_high_wait & prio_high & osprio_current & cntx_sw & error & X"01";				
		mbox_post_update			<= '1';
	end if;								 		  			     	  	 
  end process hwrtos_mboxpost;


	--HWRTOS: Update TCB(s)
hwrtos_update: process( update_clk ) is  
  variable index   			: integer range 0 to 15 := 0;				  
  variable hindex  			: integer range 0 to 15 := 0;
  variable index_ecb 		: integer range 0 to 16 := 0; 
  variable index_tcb		: integer range 0 to 15 := 0;
  variable index_tcb_wait	: integer range 0 to 15 := 0;


  begin		
		if update_clk'event and update_clk = '1' then
			case update_case is		
			  when X"0001" =>									--HWRTOS: Caused by internal tick timer	
				for i in 0 to 15 loop
					ostcb(i).dec_delay				<= tick_tcb(i).dec_delay;
					ostcb(i).stat					<= tick_tcb(i).stat;
					ostcb(i).stat_pend				<= tick_tcb(i).stat_pend;					
				end loop;
					osrdy_grp						<= tick_rdy_grp;
					osrdy_tbl						<= tick_rdy_tbl;												
			
			  when X"0002" =>									--HWRTOS: Caused by context switch info request				
				if ( (tick_out(48 to 55) = osprio_current) and (slv_reg0(48 to 55) = X"00") ) then 
					index							:= CONV_INTEGER(tick_out(40 to 47));
					ostcb(index).ctx_sw_cntr		<= ostcb(index).ctx_sw_cntr + 1;   
					osctx_sw_cntr					<= osctx_sw_cntr + 1;
					osprio_current	        	    <= tick_out(40 to 47);
				end if;
						 						
			  when X"0004" =>									--HWRTOS: Caused by create task request
				index 	    := CONV_INTEGER(slv_reg0(48 to 55));
				hindex 	    := CONV_INTEGER(task_create_out(24 to 31));
				if (ostcb(index).free = '0') then
					ostcb(index).free					<= task_create_tcb.free;					
					ostcb(index).prio	   				<= task_create_tcb.prio;
					ostcb(index).stat	   				<= task_create_tcb.stat;
					ostcb(index).stat_pend  			<= task_create_tcb.stat_pend;
					ostcb(index).delay	   				<= task_create_tcb.delay;
					ostcb(index).dec_delay	   			<= task_create_tcb.dec_delay;															
					ostcb(index).id		   				<= task_create_tcb.id;										
					ostcb(index).event_no  				<= task_create_tcb.event_no;										
					ostcb(index).msg					<= task_create_tcb.msg;
					ostcb(index).ctx_sw_cntr			<= task_create_tcb.ctx_sw_cntr;																				
					ostcb(index).task_name				<= task_create_tcb.task_name;
					ostcb(index).y						<= task_create_tcb.y;
					ostcb(index).x						<= task_create_tcb.x;
					ostcb(index).bity					<= task_create_tcb.bity;
					ostcb(index).bitx					<= task_create_tcb.bitx;					
					ostsk_cntr	 						<= task_create_tsk_cntr; 		     
					osprio_current						<= task_create_prio_current;	             
					osprio_high_rdy						<= task_create_prio_high_rdy;			    
					osctx_sw_cntr  						<= task_create_ctx_sw_cntr;	
					osrdy_grp							<= task_create_rdy_grp;
					osrdy_tbl							<= task_create_rdy_tbl;	
					if (task_create_out(40 to 47) /= X"00") then
						ostcb(hindex).ctx_sw_cntr		<= task_create_tcb_ctx_sw_cntr_hprio;														  	
					end if;	
				end if;		
				
			  when X"0008" =>									--HWRTOS: Caused by task done request
				index 	    := CONV_INTEGER(time_delay_out(40 to 47));
				hindex 	    := CONV_INTEGER(time_delay_out(32 to 39));
				osrdy_grp							<= time_delay_rdy_grp;
				osrdy_tbl							<= time_delay_rdy_tbl;	
				ostcb(hindex).ctx_sw_cntr			<= time_delay_tcb.ctx_sw_cntr_hprio;
				osprio_high_rdy	  					<= time_delay_prio_high_rdy;
		       	osprio_current						<= time_delay_prio_current;
				osctx_sw_cntr						<= time_delay_ctx_sw_cntr;					  
				
			  when X"0010" =>									--HWRTOS: Caused by create sema4 request
				index 	    := CONV_INTEGER(sema4_create_out(48 to 55));
				if (sema4_create_out(48 to 55) /= X"00") then
					ecb(index).osevent_type 		<= sema4_create_ecb.osevent_type;	
					ecb(index).osevent_free 		<= sema4_create_ecb.osevent_free;
					ecb(index).osevent_cnt 			<= sema4_create_ecb.osevent_cnt;
					ecb(index).osevent_ptr 			<= sema4_create_ecb.osevent_ptr;
				end if;
					
			  when X"0020" =>									--HWRTOS: Caused by pend on sema4 request
				index_ecb	:= CONV_INTEGER(slv_reg0(48 to 55));
				index_tcb	:= CONV_INTEGER(sema4_pend_out(32 to 39));				
				hindex 	    := CONV_INTEGER(sema4_pend_out(24 to 31));
				if ((sema4_pend_out(48 to 55) = X"00") and (sema4_pend_out(40 to 47) = X"00")) then
					ecb(index_ecb).osevent_cnt		<= sema4_pend_ecb.osevent_cnt;					
				elsif (sema4_pend_out(40 to 47) = X"01") then
					ostcb(index_tcb).stat			<= sema4_pend_tcb.stat;
					ostcb(index_tcb).stat_pend		<= sema4_pend_tcb.stat_pend;
					ostcb(index_tcb).dec_delay		<= sema4_pend_tcb.dec_delay;
					ostcb(index_tcb).event_no		<= sema4_pend_tcb.event_no;				
					ostcb(hindex).ctx_sw_cntr		<= sema4_pend_tcb_ctx_sw_cntr_hprio;					
					osprio_current					<= sema4_pend_prio_current;	             
					osprio_high_rdy					<= sema4_pend_prio_high_rdy;			    
					osctx_sw_cntr  					<= sema4_pend_ctx_sw_cntr;	
					ecb(index_ecb).osevent_grp		<= sema4_pend_ecb.osevent_grp;
					ecb(index_ecb).osevent_tbl		<= sema4_pend_ecb.osevent_tbl; 
					osrdy_grp						<= sema4_pend_rdy_grp;
					osrdy_tbl						<= sema4_pend_rdy_tbl;							
				elsif (sema4_pend_out(40 to 47) = X"02") then
					ostcb(index_tcb).stat			<= sema4_pend_tcb.stat;
					ostcb(index_tcb).stat_pend		<= sema4_pend_tcb.stat_pend;
					ostcb(index_tcb).dec_delay		<= sema4_pend_tcb.dec_delay;
					ostcb(index_tcb).event_no		<= sema4_pend_tcb.event_no;										             
					osprio_high_rdy					<= sema4_pend_prio_high_rdy;			    						
					ecb(index_ecb).osevent_grp		<= sema4_pend_ecb.osevent_grp;
					ecb(index_ecb).osevent_tbl		<= sema4_pend_ecb.osevent_tbl; 
					osrdy_grp						<= sema4_pend_rdy_grp;
					osrdy_tbl						<= sema4_pend_rdy_tbl;	
				end if;	
				
			  when X"0040" =>									--HWRTOS: Caused by pend on sema4 status request
				index_ecb	:= CONV_INTEGER(slv_reg0(48 to 55));
				index_tcb	:= CONV_INTEGER(osprio_current);								
				ostcb(index_tcb).stat			<= sema4_pend_stat_tcb.stat;
				ostcb(index_tcb).stat_pend		<= sema4_pend_stat_tcb.stat_pend;
				ostcb(index_tcb).event_no		<= sema4_pend_stat_tcb.event_no;																			
				ecb(index_ecb).osevent_grp		<= sema4_pend_stat_ecb.osevent_grp;
				ecb(index_ecb).osevent_tbl		<= sema4_pend_stat_ecb.osevent_tbl; 
				
			  when X"0080" =>									--HWRTOS: Caused by post sema4 request				
				index_ecb		:= CONV_INTEGER(slv_reg0(48 to 55));
				index_tcb_wait	:= CONV_INTEGER(sema4_post_out(16 to 23));				
				hindex 	   		:= CONV_INTEGER(sema4_post_out(24 to 31));
				if (sema4_post_out(8 to 15) = X"01") then					
					ecb(index_ecb).osevent_cnt		<= sema4_post_ecb.osevent_cnt;					
				elsif ((sema4_post_out(40 to 47) = X"01") and (sema4_post_out(48 to 55) = X"00")) then
					ostcb(index_tcb_wait).dec_delay	<= sema4_post_tcb.dec_delay;
					ostcb(index_tcb_wait).msg		<= sema4_post_tcb.msg;
					ostcb(index_tcb_wait).stat		<= sema4_post_tcb.stat;
					ostcb(index_tcb_wait).stat_pend	<= sema4_post_tcb.stat_pend;
					osprio_high_rdy					<= sema4_post_prio_high_rdy;
					ostcb(hindex).ctx_sw_cntr		<= sema4_post_tcb_ctx_sw_cntr_hprio;
					osctx_sw_cntr  					<= sema4_post_ctx_sw_cntr;
					osprio_current					<= sema4_post_prio_current;																	
				elsif ((sema4_post_out(40 to 47) = X"02") and (sema4_post_out(48 to 55) = X"00")) then
					ostcb(index_tcb_wait).dec_delay	<= sema4_post_tcb.dec_delay;
					ostcb(index_tcb_wait).msg		<= sema4_post_tcb.msg;
					ostcb(index_tcb_wait).stat		<= sema4_post_tcb.stat;
					ostcb(index_tcb_wait).stat_pend	<= sema4_post_tcb.stat_pend;
					osprio_high_rdy					<= sema4_post_prio_high_rdy;
				end if;	
				ecb(index_ecb).osevent_grp		<= sema4_post_ecb.osevent_grp;
				ecb(index_ecb).osevent_tbl		<= sema4_post_ecb.osevent_tbl; 
				osrdy_grp						<= sema4_post_rdy_grp;
				osrdy_tbl						<= sema4_post_rdy_tbl;
				
			  when X"0100" =>									--HWRTOS: Caused by create mbox request
				index 	    := CONV_INTEGER(mbox_create_out(48 to 55));
				if (mbox_create_out(48 to 55) /= X"00") then
					ecb(index).osevent_type 		<= mbox_create_ecb.osevent_type;	
					ecb(index).osevent_free 		<= mbox_create_ecb.osevent_free;
					ecb(index).osevent_cnt 			<= mbox_create_ecb.osevent_cnt;
					ecb(index).osevent_ptr 			<= mbox_create_ecb.osevent_ptr;
				end if;
				
			  when X"0200" =>									--HWRTOS: Caused by pend on mbox request
				index_ecb	:= CONV_INTEGER(slv_reg0(48 to 55));
				index_tcb	:= CONV_INTEGER(mbox_pend_out(32 to 39));				
				hindex 	    := CONV_INTEGER(mbox_pend_out(24 to 31));
				if ((mbox_pend_out(48 to 55) = X"00") and (mbox_pend_out(40 to 47) = X"00")) then
					ecb(index_ecb).osevent_ptr		<= mbox_pend_ecb.osevent_ptr;					
				elsif (mbox_pend_out(40 to 47) = X"01") then
					ostcb(index_tcb).stat			<= mbox_pend_tcb.stat;
					ostcb(index_tcb).stat_pend		<= mbox_pend_tcb.stat_pend;
					ostcb(index_tcb).dec_delay		<= mbox_pend_tcb.dec_delay;
					ostcb(index_tcb).event_no		<= mbox_pend_tcb.event_no;				
					ostcb(hindex).ctx_sw_cntr		<= mbox_pend_tcb_ctx_sw_cntr_hprio;					
					osprio_current					<= mbox_pend_prio_current;	             
					osprio_high_rdy					<= mbox_pend_prio_high_rdy;			    
					osctx_sw_cntr  					<= mbox_pend_ctx_sw_cntr;	
					ecb(index_ecb).osevent_grp		<= mbox_pend_ecb.osevent_grp;
					ecb(index_ecb).osevent_tbl		<= mbox_pend_ecb.osevent_tbl; 
					osrdy_grp						<= mbox_pend_rdy_grp;
					osrdy_tbl						<= mbox_pend_rdy_tbl;							
				elsif (mbox_pend_out(40 to 47) = X"02") then
					ostcb(index_tcb).stat			<= mbox_pend_tcb.stat;
					ostcb(index_tcb).stat_pend		<= mbox_pend_tcb.stat_pend;
					ostcb(index_tcb).dec_delay		<= mbox_pend_tcb.dec_delay;
					ostcb(index_tcb).event_no		<= mbox_pend_tcb.event_no;										             
					osprio_high_rdy					<= mbox_pend_prio_high_rdy;			    						
					ecb(index_ecb).osevent_grp		<= mbox_pend_ecb.osevent_grp;
					ecb(index_ecb).osevent_tbl		<= mbox_pend_ecb.osevent_tbl; 
					osrdy_grp						<= mbox_pend_rdy_grp;
					osrdy_tbl						<= mbox_pend_rdy_tbl;	
				end if;	
				
			  when X"0400" =>									--HWRTOS: Caused by pend on mbox status request
				index_ecb	:= CONV_INTEGER(slv_reg0(48 to 55));
				index_tcb	:= CONV_INTEGER(osprio_current);								
				ostcb(index_tcb).stat			<= mbox_pend_stat_tcb.stat;
				ostcb(index_tcb).stat_pend		<= mbox_pend_stat_tcb.stat_pend;
				ostcb(index_tcb).event_no		<= mbox_pend_stat_tcb.event_no;
				ostcb(index_tcb).msg			<= mbox_pend_stat_tcb.msg;																
				ecb(index_ecb).osevent_grp		<= mbox_pend_stat_ecb.osevent_grp;
				ecb(index_ecb).osevent_tbl		<= mbox_pend_stat_ecb.osevent_tbl;
				
			  when X"0800" =>									--HWRTOS: Caused by post mbox request
				index_ecb		:= CONV_INTEGER(slv_reg0(48 to 55));
				index_tcb_wait	:= CONV_INTEGER(mbox_post_out(16 to 23));				
				hindex 	   		:= CONV_INTEGER(mbox_post_out(24 to 31));
				if (mbox_post_out(8 to 15) = X"01") then					
					ecb(index_ecb).osevent_ptr		<= mbox_post_ecb.osevent_ptr;					
				elsif ((mbox_post_out(40 to 47) = X"01") and (mbox_post_out(48 to 55) = X"00")) then
					ostcb(index_tcb_wait).dec_delay	<= mbox_post_tcb.dec_delay;
					ostcb(index_tcb_wait).msg		<= mbox_post_tcb.msg;
					ostcb(index_tcb_wait).stat		<= mbox_post_tcb.stat;
					ostcb(index_tcb_wait).stat_pend	<= mbox_post_tcb.stat_pend;
					osprio_high_rdy					<= mbox_post_prio_high_rdy;
					ostcb(hindex).ctx_sw_cntr		<= mbox_post_tcb_ctx_sw_cntr_hprio;
					osctx_sw_cntr  					<= mbox_post_ctx_sw_cntr;
					osprio_current					<= mbox_post_prio_current;																	
				elsif ((mbox_post_out(40 to 47) = X"02") and (mbox_post_out(48 to 55) = X"00")) then
					ostcb(index_tcb_wait).dec_delay	<= mbox_post_tcb.dec_delay;
					ostcb(index_tcb_wait).msg		<= mbox_post_tcb.msg;
					ostcb(index_tcb_wait).stat		<= mbox_post_tcb.stat;
					ostcb(index_tcb_wait).stat_pend	<= mbox_post_tcb.stat_pend;
					osprio_high_rdy					<= mbox_post_prio_high_rdy;
				end if;	
				ecb(index_ecb).osevent_grp		<= mbox_post_ecb.osevent_grp;
				ecb(index_ecb).osevent_tbl		<= mbox_post_ecb.osevent_tbl; 
				osrdy_grp						<= mbox_post_rdy_grp;
				osrdy_tbl						<= mbox_post_rdy_tbl;
				
			  when X"1000" =>									--HWRTOS: Caused by os start request
				osprio_high_rdy	  					<= os_start_prio_high_rdy;
		       	osprio_current						<= os_start_prio_current;
				osrunning							<= os_start_running;														 						
																					
			  when others => 										
																						    	
			end case;	
		end if;															
  end process hwrtos_update;


	--HWRTOS: Multiplex the output
hwrtos_select_output: process( select_clk, tick_sel_rst ) is  					  

  begin	
	if ( tick_sel_rst = '1' ) then
		tick_sel_update					<= '0';
	elsif select_clk'event and select_clk = '1' then	
		case select_case is		
		  when X"0001" =>										--HWRTOS: Select reset output							
				slv_reg4				<= (others => '0');			
			
		  when X"0002" =>										--HWRTOS: Select context switch info output
			if ( tick_out(48 to 55) = osprio_current ) then  								
				slv_reg4				<= (X"00" & int_resp_timer_cnt & tick_timer_cnt & X"00000000") or tick_out;				
			else 
				slv_reg4				<= (X"00" & int_resp_timer_cnt & tick_timer_cnt & X"00000000") or X"0000000000000001";
			end if;			
			tick_sel_update				<= '1';					  				
			
		  when X"0004" =>										--HWRTOS: Select create task output
			slv_reg4					<= (X"0000" & ext_cmd_timer_cnt & X"0000000000") or task_create_out;						
					  
		  when X"0008" =>										--HWRTOS: Select task done output
			slv_reg4					<= (X"000000" & ext_cmd_timer_cnt & X"00000000") or time_delay_out;								  			
			
		  when X"0010" =>										--HWRTOS: Select create sema4 output
			slv_reg4					<= (X"000000" & ext_cmd_timer_cnt & X"00000000") or sema4_create_out;			
					
		  when X"0020" =>										--HWRTOS: Select pend on sema4 output
			slv_reg4					<= (X"0000" & ext_cmd_timer_cnt & X"0000000000") or sema4_pend_out;			
			
		  when X"0040" =>										--HWRTOS: Select pend on sema4 status output
			slv_reg4					<= (X"000000" & ext_cmd_timer_cnt & X"00000000") or sema4_pend_stat_out;				
			
          when X"0080" =>										--HWRTOS: Select post sema4 output
			slv_reg4					<= (ext_cmd_timer_cnt & X"00000000000000") or sema4_post_out;					  			
			
		  when X"0100" =>										--HWRTOS: Select create mbox output
			slv_reg4					<= (X"000000" & ext_cmd_timer_cnt & X"00000000") or mbox_create_out;			
			
		  when X"0200" =>										--HWRTOS: Select pend on mbox output
			slv_reg4					<= mbox_pend_out;
			slv_reg5					<= X"00000000000000" & ext_cmd_timer_cnt;
			
		  when X"0400" =>										--HWRTOS: Select pend on mbox status output
			slv_reg4					<= (X"0000000000" & ext_cmd_timer_cnt & X"0000") or mbox_pend_stat_out;			
			
		  when X"0800" =>										--HWRTOS: Select post mbox output
			slv_reg4					<= (ext_cmd_timer_cnt & X"00000000000000") or mbox_post_out;			
			
		  when X"1000" =>										--HWRTOS: Select os start output
			slv_reg4					<= (X"000000" & ext_cmd_timer_cnt & X"00000000") or os_start_out;			
			
		  when X"2000" =>										--HWRTOS: Select test output
			slv_reg4					<= test_out0;			
			slv_reg5					<= test_out1;			
			slv_reg6					<= test_out2;						
			
		  when X"4000" =>										--HWRTOS: Select stop-watch timer output
			slv_reg4					<= (X"00000000" & sw_ctrl_timer_cnt);									
			
		  when X"8000" =>										--HWRTOS: Select continuous timer output
			slv_reg4					<= (X"00000000" & cont_timer_cnt);	
					
		  when others => 										
			slv_reg4					<= rst_out;																			    	
        end case;		
	end if;									 		  			     	  	 
  end process hwrtos_select_output;


	--HWRTOS: Some signals delay processing
hwrtos_tick_update_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			tick_update_d			<= tick_update;																					    				
			tick_upd_rst			<= tick_update_d;																	    				
		end if;															
  end process hwrtos_tick_update_delay;


hwrtos_tick_select_upd_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			tick_sel_update_d		<= tick_sel_update;																					    				
			tick_sel_rst			<= tick_sel_update_d;																    				
		end if;															
  end process hwrtos_tick_select_upd_delay;


hwrtos_tick_select_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			tick_sel_d				<= tick_sel;																																			    							
		end if;															
  end process hwrtos_tick_select_delay;
 

hwrtos_task_create_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			task_create_update_d	<= task_create_update;																					    				
			task_create_rst			<= task_create_update_d;																    				
		end if;															
  end process hwrtos_task_create_delay;


hwrtos_time_dly_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			time_delay_update_d		<= time_delay_update;																					    				
			time_delay_rst			<= time_delay_update_d;																    				
		end if;															
  end process hwrtos_time_dly_delay;


hwrtos_sema4_create_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			sema4_create_update_d	<= sema4_create_update;																					    				
			sema4_create_rst		<= sema4_create_update_d;																    				
		end if;															
  end process hwrtos_sema4_create_delay;


hwrtos_sema4_pend_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			sema4_pend_update_d		<= sema4_pend_update;																					    				
			sema4_pend_rst			<= sema4_pend_update_d;																    				
		end if;															
  end process hwrtos_sema4_pend_delay;


hwrtos_sema4_pend_stat_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			sema4_pend_stat_update_d	<= sema4_pend_stat_update;																					    				
			sema4_pend_stat_rst			<= sema4_pend_stat_update_d;																    				
		end if;															
  end process hwrtos_sema4_pend_stat_delay;


hwrtos_sema4_post_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			sema4_post_update_d		<= sema4_post_update;																					    				
			sema4_post_rst			<= sema4_post_update_d;																    				
		end if;															
  end process hwrtos_sema4_post_delay;


hwrtos_mbox_create_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			mbox_create_update_d	<= mbox_create_update;																					    				
			mbox_create_rst			<= mbox_create_update_d;																    				
		end if;															
  end process hwrtos_mbox_create_delay;


hwrtos_mbox_pend_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			mbox_pend_update_d		<= mbox_pend_update;																					    				
			mbox_pend_rst			<= mbox_pend_update_d;																    				
		end if;															
  end process hwrtos_mbox_pend_delay;


hwrtos_mbox_pend_stat_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			mbox_pend_stat_update_d		<= mbox_pend_stat_update;																					    				
			mbox_pend_stat_rst			<= mbox_pend_stat_update_d;																    				
		end if;															
  end process hwrtos_mbox_pend_stat_delay;


hwrtos_mbox_post_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			mbox_post_update_d		<= mbox_post_update;																					    				
			mbox_post_rst			<= mbox_post_update_d;														    				
		end if;															
  end process hwrtos_mbox_post_delay;


hwrtos_os_start_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			os_start_update_d		<= os_start_update;																					    				
			os_start_rst			<= os_start_update_d;															    				
		end if;															
  end process hwrtos_os_start_delay;


hwrtos_test_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			test_sel_d				<= test_sel;																					    				
			test_rst				<= test_sel_d;																    				
		end if;																	
  end process hwrtos_test_delay;


hwrtos_sw_ctrl_timer_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then						
			sw_ctrl_timer_update_d	<= sw_ctrl_timer_update;																					    				
			sw_ctrl_timer_rst		<= sw_ctrl_timer_update_d;																    				
		end if;																	
  end process hwrtos_sw_ctrl_timer_delay;


hwrtos_rd_reg4_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then																													    			
			rd_reg4_d1				<= rd_reg4;	
			rd_reg4_d2				<= rd_reg4_d1;
			rd_reg4_rst				<= rd_reg4_d2;															    				
		end if;																	
  end process hwrtos_rd_reg4_delay;


hwrtos_sw_ctrl_timer_en_d1shot: process( Bus2IP_Clk ) is  					    

  begin			
	if Bus2IP_Clk'event and Bus2IP_Clk = '1' then	
		sw_ctrl_timer_en_d			<= sw_ctrl_timer_en;
		sw_ctrl_timer_en_1shot  	<= sw_ctrl_timer_en and (not sw_ctrl_timer_en_d);		
	end if;									 		  			     	  	 
  end process hwrtos_sw_ctrl_timer_en_d1shot;
  
  
hwrtos_cont_timer_rd_delay: process( Bus2IP_Clk ) is  					  

  begin		
		if Bus2IP_Clk'event and Bus2IP_Clk = '1' then																													    			
			cont_timer_rd_d			<= cont_timer_rd;																			    				
		end if;																	
  end process hwrtos_cont_timer_rd_delay;


hwrtos_cont_timer_en_d1shot: process( Bus2IP_Clk ) is  					    

  begin			
	if Bus2IP_Clk'event and Bus2IP_Clk = '1' then	
		cont_timer_start_d			<= cont_timer_start;
		cont_timer_start_1shot  	<= cont_timer_start xor cont_timer_start_d;		
	end if;									 		  			     	  	 
  end process hwrtos_cont_timer_en_d1shot;  
  
 
  wr_rst						 <= rd_reg4_d2 or sw_ctrl_timer_en_1shot;


  update_clk					 <= os_start_update_d or mbox_post_update_d or mbox_pend_stat_update_d or mbox_pend_update_d or mbox_create_update_d or sema4_post_update_d or sema4_pend_stat_update_d or sema4_pend_update_d or sema4_create_update_d or time_delay_update_d or task_create_update_d or tick_sel_update_d or tick_update_d;  
  update_case					 <= B"000" & os_start_update & mbox_post_update & mbox_pend_stat_update & mbox_pend_update & mbox_create_update & sema4_post_update & sema4_pend_stat_update & sema4_pend_update & sema4_create_update & time_delay_update & task_create_update & tick_sel_update & tick_update;  
  select_clk					 <= cont_timer_rd_d or sw_ctrl_timer_update_d or test_sel_d or os_start_update_d or mbox_post_update_d or mbox_pend_stat_update_d or mbox_pend_update_d or mbox_create_update_d or sema4_post_update_d or sema4_pend_stat_update_d or sema4_pend_update_d or sema4_create_update_d or time_delay_update_d or task_create_update_d or tick_sel_d or rst_en;  
  select_case					 <= cont_timer_rd & sw_ctrl_timer_update & test_sel & os_start_update & mbox_post_update & mbox_pend_stat_update & mbox_pend_update & mbox_create_update & sema4_post_update & sema4_pend_stat_update & sema4_pend_update & sema4_create_update & time_delay_update & task_create_update & tick_sel & rst_en;  
  

end IMP;
