

library ieee;
use ieee.std_logic_1164.all;
library IEEE;
use IEEE.std_logic_1164.all;

entity jtagppc_bdi2000_cntlr is
  port (
        RISCWATCH_HALT   : in std_logic;
        RISCWATCH_TCK    : in std_logic;
        RISCWATCH_TMS    : in std_logic;
        RISCWATCH_TDI    : in std_logic;
        RISCWATCH_TRSTn  : in std_logic;
        RISCWATCH_TDO    : out std_logic;

        DBGC405DEBUGHALT : out std_logic;
        JTGC405TCK       : out std_logic;
        JTGC405TMS       : out std_logic;
        JTGC405TDI       : out std_logic;
        JTGC405TRSTNEG   : out std_logic;
        C405JTGTDO       : in std_logic);
end entity jtagppc_bdi2000_cntlr;

architecture IMP of jtagppc_bdi2000_cntlr is

begin

DBGC405DEBUGHALT <= not RISCWATCH_HALT;
JTGC405TCK		 <= RISCWATCH_TCK;
JTGC405TMS		 <= RISCWATCH_TMS;
JTGC405TDI		 <= RISCWATCH_TDI;
JTGC405TRSTNEG	 <= RISCWATCH_TRSTn;

RISCWATCH_TDO    <= C405JTGTDO;
    
end architecture IMP;
