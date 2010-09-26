-------------------------------------------------------------------------------
-- plb_ddr_controller_i_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library modified_plb_ddr_controller_v1_00_c;
use modified_plb_ddr_controller_v1_00_c.All;

entity plb_ddr_controller_i_wrapper is
  port (
    PLB_ABus : in std_logic_vector(0 to 31);
    PLB_PAValid : in std_logic;
    PLB_SAValid : in std_logic;
    PLB_rdPrim : in std_logic;
    PLB_wrPrim : in std_logic;
    PLB_masterID : in std_logic_vector(0 to 1);
    PLB_abort : in std_logic;
    PLB_busLock : in std_logic;
    PLB_RNW : in std_logic;
    PLB_BE : in std_logic_vector(0 to 7);
    PLB_MSize : in std_logic_vector(0 to 1);
    PLB_size : in std_logic_vector(0 to 3);
    PLB_type : in std_logic_vector(0 to 2);
    PLB_compress : in std_logic;
    PLB_guarded : in std_logic;
    PLB_ordered : in std_logic;
    PLB_lockErr : in std_logic;
    PLB_wrDBus : in std_logic_vector(0 to 63);
    PLB_wrBurst : in std_logic;
    PLB_rdBurst : in std_logic;
    PLB_pendReq : in std_logic;
    PLB_pendPri : in std_logic_vector(0 to 1);
    PLB_reqPri : in std_logic_vector(0 to 1);
    Sl_addrAck : out std_logic;
    Sl_SSize : out std_logic_vector(0 to 1);
    Sl_wait : out std_logic;
    Sl_rearbitrate : out std_logic;
    Sl_wrDAck : out std_logic;
    Sl_wrComp : out std_logic;
    Sl_wrBTerm : out std_logic;
    Sl_rdDBus : out std_logic_vector(0 to 63);
    Sl_rdWdAddr : out std_logic_vector(0 to 3);
    Sl_rdDAck : out std_logic;
    Sl_rdComp : out std_logic;
    Sl_rdBTerm : out std_logic;
    Sl_MBusy : out std_logic_vector(0 to 3);
    Sl_MErr : out std_logic_vector(0 to 3);
    DDR_Clk : out std_logic;
    DDR_Clkn : out std_logic;
    DDR_CKE : out std_logic;
    DDR_CSn : out std_logic;
    DDR_RASn : out std_logic;
    DDR_CASn : out std_logic;
    DDR_WEn : out std_logic;
    DDR_DM : out std_logic_vector(0 to 3);
    DDR_BankAddr : out std_logic_vector(0 to 1);
    DDR_Addr : out std_logic_vector(0 to 12);
    DDR_Init_done : out std_logic;
    PLB_Clk : in std_logic;
    Clk90_in : in std_logic;
    DDR_Clk90_in : in std_logic;
    PLB_Rst : in std_logic;
    DDR_DQ_I : in std_logic_vector(0 to 31);
    DDR_DQ_O : out std_logic_vector(0 to 31);
    DDR_DQ_T : out std_logic_vector(0 to 31);
    DDR_DQS_I : in std_logic_vector(0 to 3);
    DDR_DQS_O : out std_logic_vector(0 to 3);
    DDR_DQS_T : out std_logic_vector(0 to 3)
  );
end plb_ddr_controller_i_wrapper;

architecture STRUCTURE of plb_ddr_controller_i_wrapper is

  component modified_plb_ddr_controller is
    generic (
      C_DQS_PULLUPS : INTEGER;
      C_INCLUDE_BURST_CACHELN_SUPPORT : INTEGER;
      C_REG_DIMM : INTEGER;
      C_DDR_TMRD : INTEGER;
      C_DDR_TWR : INTEGER;
      C_DDR_TWTR : INTEGER;
      C_DDR_TRAS : INTEGER;
      C_DDR_TRC : INTEGER;
      C_DDR_TRFC : INTEGER;
      C_DDR_TRCD : INTEGER;
      C_DDR_TRRD : INTEGER;
      C_DDR_TREFC : INTEGER;
      C_DDR_TREFI : INTEGER;
      C_DDR_TRP : INTEGER;
      C_DDR_CAS_LAT : INTEGER;
      C_DDR_DWIDTH : INTEGER;
      C_DDR_AWIDTH : INTEGER;
      C_DDR_COL_AWIDTH : INTEGER;
      C_DDR_BANK_AWIDTH : INTEGER;
      C_PLB_CLK_PERIOD_PS : INTEGER;
      C_FAMILY : STRING;
      C_BASEADDR : std_logic_vector;
      C_HIGHADDR : std_logic_vector;
      C_PLB_NUM_MASTERS : INTEGER;
      C_PLB_MID_WIDTH : INTEGER;
      C_PLB_AWIDTH : INTEGER;
      C_PLB_DWIDTH : INTEGER;
      C_SIM_INIT_TIME_PS : integer
    );
    port (
      PLB_ABus : in std_logic_vector(0 to (C_PLB_AWIDTH-1));
      PLB_PAValid : in std_logic;
      PLB_SAValid : in std_logic;
      PLB_rdPrim : in std_logic;
      PLB_wrPrim : in std_logic;
      PLB_masterID : in std_logic_vector(0 to (C_PLB_MID_WIDTH-1));
      PLB_abort : in std_logic;
      PLB_busLock : in std_logic;
      PLB_RNW : in std_logic;
      PLB_BE : in std_logic_vector(0 to ((C_PLB_DWIDTH/8)-1));
      PLB_MSize : in std_logic_vector(0 to 1);
      PLB_size : in std_logic_vector(0 to 3);
      PLB_type : in std_logic_vector(0 to 2);
      PLB_compress : in std_logic;
      PLB_guarded : in std_logic;
      PLB_ordered : in std_logic;
      PLB_lockErr : in std_logic;
      PLB_wrDBus : in std_logic_vector(0 to (C_PLB_DWIDTH-1));
      PLB_wrBurst : in std_logic;
      PLB_rdBurst : in std_logic;
      PLB_pendReq : in std_logic;
      PLB_pendPri : in std_logic_vector(0 to 1);
      PLB_reqPri : in std_logic_vector(0 to 1);
      Sl_addrAck : out std_logic;
      Sl_SSize : out std_logic_vector(0 to 1);
      Sl_wait : out std_logic;
      Sl_rearbitrate : out std_logic;
      Sl_wrDAck : out std_logic;
      Sl_wrComp : out std_logic;
      Sl_wrBTerm : out std_logic;
      Sl_rdDBus : out std_logic_vector(0 to (C_PLB_DWIDTH-1));
      Sl_rdWdAddr : out std_logic_vector(0 to 3);
      Sl_rdDAck : out std_logic;
      Sl_rdComp : out std_logic;
      Sl_rdBTerm : out std_logic;
      Sl_MBusy : out std_logic_vector(0 to (C_PLB_NUM_MASTERS-1));
      Sl_MErr : out std_logic_vector(0 to (C_PLB_NUM_MASTERS-1));
      DDR_Clk : out std_logic;
      DDR_Clkn : out std_logic;
      DDR_CKE : out std_logic;
      DDR_CSn : out std_logic;
      DDR_RASn : out std_logic;
      DDR_CASn : out std_logic;
      DDR_WEn : out std_logic;
      DDR_DM : out std_logic_vector(0 to ((C_DDR_DWIDTH/8)-1));
      DDR_BankAddr : out std_logic_vector(0 to (C_DDR_BANK_AWIDTH-1));
      DDR_Addr : out std_logic_vector(0 to (C_DDR_AWIDTH-1));
      DDR_Init_done : out std_logic;
      PLB_Clk : in std_logic;
      Clk90_in : in std_logic;
      DDR_Clk90_in : in std_logic;
      PLB_Rst : in std_logic;
      DDR_DQ_I : in std_logic_vector(0 to (C_DDR_DWIDTH-1));
      DDR_DQ_O : out std_logic_vector(0 to (C_DDR_DWIDTH-1));
      DDR_DQ_T : out std_logic_vector(0 to (C_DDR_DWIDTH-1));
      DDR_DQS_I : in std_logic_vector(0 to ((C_DDR_DWIDTH/8)-1));
      DDR_DQS_O : out std_logic_vector(0 to ((C_DDR_DWIDTH/8)-1));
      DDR_DQS_T : out std_logic_vector(0 to ((C_DDR_DWIDTH/8)-1))
    );
  end component;

  attribute x_core_info : STRING;
  attribute x_core_info of modified_plb_ddr_controller : component is "modified_plb_ddr_controller_v1_00_c";

begin

  plb_ddr_controller_i : modified_plb_ddr_controller
    generic map (
      C_DQS_PULLUPS => 0,
      C_INCLUDE_BURST_CACHELN_SUPPORT => 1,
      C_REG_DIMM => 0,
      C_DDR_TMRD => 15000,
      C_DDR_TWR => 15000,
      C_DDR_TWTR => 1,
      C_DDR_TRAS => 40000,
      C_DDR_TRC => 65000,
      C_DDR_TRFC => 75000,
      C_DDR_TRCD => 20000,
      C_DDR_TRRD => 15000,
      C_DDR_TREFC => 70000000,
      C_DDR_TREFI => 7800000,
      C_DDR_TRP => 20000,
      C_DDR_CAS_LAT => 2,
      C_DDR_DWIDTH => 32,
      C_DDR_AWIDTH => 13,
      C_DDR_COL_AWIDTH => 9,
      C_DDR_BANK_AWIDTH => 2,
      C_PLB_CLK_PERIOD_PS => 12500,
      C_FAMILY => "virtex2p",
      C_BASEADDR => X"00000000",
      C_HIGHADDR => X"1FFFFFFF",
      C_PLB_NUM_MASTERS => 4,
      C_PLB_MID_WIDTH => 2,
      C_PLB_AWIDTH => 32,
      C_PLB_DWIDTH => 64,
      C_SIM_INIT_TIME_PS => 200000000
    )
    port map (
      PLB_ABus => PLB_ABus,
      PLB_PAValid => PLB_PAValid,
      PLB_SAValid => PLB_SAValid,
      PLB_rdPrim => PLB_rdPrim,
      PLB_wrPrim => PLB_wrPrim,
      PLB_masterID => PLB_masterID,
      PLB_abort => PLB_abort,
      PLB_busLock => PLB_busLock,
      PLB_RNW => PLB_RNW,
      PLB_BE => PLB_BE,
      PLB_MSize => PLB_MSize,
      PLB_size => PLB_size,
      PLB_type => PLB_type,
      PLB_compress => PLB_compress,
      PLB_guarded => PLB_guarded,
      PLB_ordered => PLB_ordered,
      PLB_lockErr => PLB_lockErr,
      PLB_wrDBus => PLB_wrDBus,
      PLB_wrBurst => PLB_wrBurst,
      PLB_rdBurst => PLB_rdBurst,
      PLB_pendReq => PLB_pendReq,
      PLB_pendPri => PLB_pendPri,
      PLB_reqPri => PLB_reqPri,
      Sl_addrAck => Sl_addrAck,
      Sl_SSize => Sl_SSize,
      Sl_wait => Sl_wait,
      Sl_rearbitrate => Sl_rearbitrate,
      Sl_wrDAck => Sl_wrDAck,
      Sl_wrComp => Sl_wrComp,
      Sl_wrBTerm => Sl_wrBTerm,
      Sl_rdDBus => Sl_rdDBus,
      Sl_rdWdAddr => Sl_rdWdAddr,
      Sl_rdDAck => Sl_rdDAck,
      Sl_rdComp => Sl_rdComp,
      Sl_rdBTerm => Sl_rdBTerm,
      Sl_MBusy => Sl_MBusy,
      Sl_MErr => Sl_MErr,
      DDR_Clk => DDR_Clk,
      DDR_Clkn => DDR_Clkn,
      DDR_CKE => DDR_CKE,
      DDR_CSn => DDR_CSn,
      DDR_RASn => DDR_RASn,
      DDR_CASn => DDR_CASn,
      DDR_WEn => DDR_WEn,
      DDR_DM => DDR_DM,
      DDR_BankAddr => DDR_BankAddr,
      DDR_Addr => DDR_Addr,
      DDR_Init_done => DDR_Init_done,
      PLB_Clk => PLB_Clk,
      Clk90_in => Clk90_in,
      DDR_Clk90_in => DDR_Clk90_in,
      PLB_Rst => PLB_Rst,
      DDR_DQ_I => DDR_DQ_I,
      DDR_DQ_O => DDR_DQ_O,
      DDR_DQ_T => DDR_DQ_T,
      DDR_DQS_I => DDR_DQS_I,
      DDR_DQS_O => DDR_DQS_O,
      DDR_DQS_T => DDR_DQS_T
    );

end architecture STRUCTURE;

