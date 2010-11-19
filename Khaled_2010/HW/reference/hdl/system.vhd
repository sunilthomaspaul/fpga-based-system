-------------------------------------------------------------------------------
-- system.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system is
  port (
    fpga_rst_n : in std_logic;
    fpga_opb_clk : in std_logic;
    fpga_plb_clk : in std_logic;
    fpga_test_led : inout std_logic_vector(0 to 7);
    fpga_test_switch_0 : in std_logic;
    fpga_test_switch_1 : in std_logic;
    fpga_test_switch_2 : in std_logic;
    fpga_test_switch_3 : in std_logic;
    fpga_test_switch_4 : in std_logic;
    fpga_test_switch_5 : in std_logic;
    fpga_test_switch_6 : in std_logic;
    fpga_test_switch_7 : in std_logic;
    lbus_addr : inout std_logic_vector(0 to 24);
    lbus_data : inout std_logic_vector(0 to 15);
    lbus_oe_n : inout std_logic;
    lbus_we_n : inout std_logic;
    flash_cs_n : out std_logic;
    fpga_config_flash_cs_n : inout std_logic;
    cpld_br_n : in std_logic;
    cpld_bg_n : out std_logic;
    cpld_cs_n : out std_logic;
    sysace_irq : in std_logic;
    sysace_cs_n : out std_logic;
    uart1_sin : in std_logic;
    uart1_sout : out std_logic;
    ddr1_clk_fb : in std_logic;
    ddr1_clk : out std_logic;
    ddr1_clk_n : out std_logic;
    ddr1_addr : out std_logic_vector(1 to 13);
    ddr1_ba : out std_logic_vector(0 to 1);
    ddr1_ras_n : out std_logic;
    ddr1_cas_n : out std_logic;
    ddr1_we_n : out std_logic;
    ddr1_cs_n : out std_logic;
    ddr1_cke : out std_logic;
    ddr1_dm : out std_logic_vector(3 downto 0);
    ddr1_dqs : inout std_logic_vector(3 downto 0);
    ddr1_dq : inout std_logic_vector(31 downto 0);
    psb_bg_n : in std_logic;
    psb_dbg_n : in std_logic;
    ps2_int0_n : in std_logic;
    ps2_int1_n : in std_logic;
    ps2_int2_n : in std_logic;
    ps2_int3_n : in std_logic;
    ps2_int4_n : in std_logic;
    ps2_int5_n : in std_logic;
    psb_br_n : out std_logic;
    psb_a : inout std_logic_vector(0 to 31);
    psb_abb_n : inout std_logic;
    psb_artry_n : inout std_logic;
    psb_aack_n : inout std_logic;
    psb_tbst_n : inout std_logic;
    psb_dbb_n : inout std_logic;
    psb_ts_n : inout std_logic;
    psb_ta_n : inout std_logic;
    psb_tea_n : inout std_logic;
    psb_tsiz : inout std_logic_vector(0 to 3);
    psb_tt : inout std_logic_vector(0 to 4);
    psb_data : inout std_logic_vector(0 to 63);
    pmc_inta_n : in std_logic;
    pmc_intb_n : in std_logic;
    pmc_intc_n : in std_logic;
    pmc_intd_n : in std_logic;
    fpga_therm : in std_logic;
    ExternalPort_0 : out std_logic
  );
end system;

architecture STRUCTURE of system is

  component clock_reset_block_wrapper is
    port (
      fpga_plb_clk : in std_logic;
      fpga_opb_clk : in std_logic;
      ddr_clk_fb : in std_logic;
      async_fpga_rst_n : in std_logic;
      CLKPLB : out std_logic;
      CLKOPB : out std_logic;
      CLKCPU : out std_logic;
      DDR_CLKPLB_90 : out std_logic;
      DDR_CLKFB_90 : out std_logic;
      RSTPLB : out std_logic;
      RSTOPB : out std_logic;
      RSTCPU : out std_logic
    );
  end component;

  component ppc405_i_wrapper is
    port (
      C405CPMCORESLEEPREQ : out std_logic;
      C405CPMMSRCE : out std_logic;
      C405CPMMSREE : out std_logic;
      C405CPMTIMERIRQ : out std_logic;
      C405CPMTIMERRESETREQ : out std_logic;
      C405XXXMACHINECHECK : out std_logic;
      CPMC405CLOCK : in std_logic;
      CPMC405CORECLKINACTIVE : in std_logic;
      CPMC405CPUCLKEN : in std_logic;
      CPMC405JTAGCLKEN : in std_logic;
      CPMC405TIMERCLKEN : in std_logic;
      CPMC405TIMERTICK : in std_logic;
      MCBCPUCLKEN : in std_logic;
      MCBTIMEREN : in std_logic;
      MCPPCRST : in std_logic;
      PLBCLK : in std_logic;
      DCRCLK : in std_logic;
      C405RSTCHIPRESETREQ : out std_logic;
      C405RSTCORERESETREQ : out std_logic;
      C405RSTSYSRESETREQ : out std_logic;
      RSTC405RESETCHIP : in std_logic;
      RSTC405RESETCORE : in std_logic;
      RSTC405RESETSYS : in std_logic;
      C405PLBICUABUS : out std_logic_vector(0 to 31);
      C405PLBICUBE : out std_logic_vector(0 to 7);
      C405PLBICURNW : out std_logic;
      C405PLBICUABORT : out std_logic;
      C405PLBICUBUSLOCK : out std_logic;
      C405PLBICUU0ATTR : out std_logic;
      C405PLBICUGUARDED : out std_logic;
      C405PLBICULOCKERR : out std_logic;
      C405PLBICUMSIZE : out std_logic_vector(0 to 1);
      C405PLBICUORDERED : out std_logic;
      C405PLBICUPRIORITY : out std_logic_vector(0 to 1);
      C405PLBICURDBURST : out std_logic;
      C405PLBICUREQUEST : out std_logic;
      C405PLBICUSIZE : out std_logic_vector(0 to 3);
      C405PLBICUTYPE : out std_logic_vector(0 to 2);
      C405PLBICUWRBURST : out std_logic;
      C405PLBICUWRDBUS : out std_logic_vector(0 to 63);
      C405PLBICUCACHEABLE : out std_logic;
      PLBC405ICUADDRACK : in std_logic;
      PLBC405ICUBUSY : in std_logic;
      PLBC405ICUERR : in std_logic;
      PLBC405ICURDBTERM : in std_logic;
      PLBC405ICURDDACK : in std_logic;
      PLBC405ICURDDBUS : in std_logic_vector(0 to 63);
      PLBC405ICURDWDADDR : in std_logic_vector(0 to 3);
      PLBC405ICUREARBITRATE : in std_logic;
      PLBC405ICUWRBTERM : in std_logic;
      PLBC405ICUWRDACK : in std_logic;
      PLBC405ICUSSIZE : in std_logic_vector(0 to 1);
      PLBC405ICUSERR : in std_logic;
      PLBC405ICUSBUSYS : in std_logic;
      C405PLBDCUABUS : out std_logic_vector(0 to 31);
      C405PLBDCUBE : out std_logic_vector(0 to 7);
      C405PLBDCURNW : out std_logic;
      C405PLBDCUABORT : out std_logic;
      C405PLBDCUBUSLOCK : out std_logic;
      C405PLBDCUU0ATTR : out std_logic;
      C405PLBDCUGUARDED : out std_logic;
      C405PLBDCULOCKERR : out std_logic;
      C405PLBDCUMSIZE : out std_logic_vector(0 to 1);
      C405PLBDCUORDERED : out std_logic;
      C405PLBDCUPRIORITY : out std_logic_vector(0 to 1);
      C405PLBDCURDBURST : out std_logic;
      C405PLBDCUREQUEST : out std_logic;
      C405PLBDCUSIZE : out std_logic_vector(0 to 3);
      C405PLBDCUTYPE : out std_logic_vector(0 to 2);
      C405PLBDCUWRBURST : out std_logic;
      C405PLBDCUWRDBUS : out std_logic_vector(0 to 63);
      C405PLBDCUCACHEABLE : out std_logic;
      C405PLBDCUWRITETHRU : out std_logic;
      PLBC405DCUADDRACK : in std_logic;
      PLBC405DCUBUSY : in std_logic;
      PLBC405DCUERR : in std_logic;
      PLBC405DCURDBTERM : in std_logic;
      PLBC405DCURDDACK : in std_logic;
      PLBC405DCURDDBUS : in std_logic_vector(0 to 63);
      PLBC405DCURDWDADDR : in std_logic_vector(0 to 3);
      PLBC405DCUREARBITRATE : in std_logic;
      PLBC405DCUWRBTERM : in std_logic;
      PLBC405DCUWRDACK : in std_logic;
      PLBC405DCUSSIZE : in std_logic_vector(0 to 1);
      PLBC405DCUSERR : in std_logic;
      PLBC405DCUSBUSYS : in std_logic;
      BRAMDSOCMCLK : in std_logic;
      BRAMDSOCMRDDBUS : in std_logic_vector(0 to 31);
      DSARCVALUE : in std_logic_vector(0 to 7);
      DSCNTLVALUE : in std_logic_vector(0 to 7);
      DSOCMBRAMABUS : out std_logic_vector(8 to 29);
      DSOCMBRAMBYTEWRITE : out std_logic_vector(0 to 3);
      DSOCMBRAMEN : out std_logic;
      DSOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
      DSOCMBUSY : out std_logic;
      BRAMISOCMCLK : in std_logic;
      BRAMISOCMRDDBUS : in std_logic_vector(0 to 63);
      ISARCVALUE : in std_logic_vector(0 to 7);
      ISCNTLVALUE : in std_logic_vector(0 to 7);
      ISOCMBRAMEN : out std_logic;
      ISOCMBRAMEVENWRITEEN : out std_logic;
      ISOCMBRAMODDWRITEEN : out std_logic;
      ISOCMBRAMRDABUS : out std_logic_vector(8 to 28);
      ISOCMBRAMWRABUS : out std_logic_vector(8 to 28);
      ISOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
      C405DCRABUS : out std_logic_vector(0 to 9);
      C405DCRDBUSOUT : out std_logic_vector(0 to 31);
      C405DCRREAD : out std_logic;
      C405DCRWRITE : out std_logic;
      DCRC405ACK : in std_logic;
      DCRC405DBUSIN : in std_logic_vector(0 to 31);
      EICC405CRITINPUTIRQ : in std_logic;
      EICC405EXTINPUTIRQ : in std_logic;
      C405JTGCAPTUREDR : out std_logic;
      C405JTGEXTEST : out std_logic;
      C405JTGPGMOUT : out std_logic;
      C405JTGSHIFTDR : out std_logic;
      C405JTGTDO : out std_logic;
      C405JTGTDOEN : out std_logic;
      C405JTGUPDATEDR : out std_logic;
      MCBJTAGEN : in std_logic;
      JTGC405BNDSCANTDO : in std_logic;
      JTGC405TCK : in std_logic;
      JTGC405TDI : in std_logic;
      JTGC405TMS : in std_logic;
      JTGC405TRSTNEG : in std_logic;
      C405DBGMSRWE : out std_logic;
      C405DBGSTOPACK : out std_logic;
      C405DBGWBCOMPLETE : out std_logic;
      C405DBGWBFULL : out std_logic;
      C405DBGWBIAR : out std_logic_vector(0 to 29);
      DBGC405DEBUGHALT : in std_logic;
      DBGC405EXTBUSHOLDACK : in std_logic;
      DBGC405UNCONDDEBUGEVENT : in std_logic;
      C405TRCCYCLE : out std_logic;
      C405TRCEVENEXECUTIONSTATUS : out std_logic_vector(0 to 1);
      C405TRCODDEXECUTIONSTATUS : out std_logic_vector(0 to 1);
      C405TRCTRACESTATUS : out std_logic_vector(0 to 3);
      C405TRCTRIGGEREVENTOUT : out std_logic;
      C405TRCTRIGGEREVENTTYPE : out std_logic_vector(0 to 10);
      TRCC405TRACEDISABLE : in std_logic;
      TRCC405TRIGGEREVENTIN : in std_logic
    );
  end component;

  component plb_bus_wrapper is
    port (
      PLB_Clk : in std_logic;
      SYS_Rst : in std_logic;
      PLB_Rst : out std_logic;
      PLB_dcrAck : out std_logic;
      PLB_dcrDBus : out std_logic_vector(0 to 31);
      DCR_ABus : in std_logic_vector(0 to 9);
      DCR_DBus : in std_logic_vector(0 to 31);
      DCR_Read : in std_logic;
      DCR_Write : in std_logic;
      M_ABus : in std_logic_vector(0 to 127);
      M_BE : in std_logic_vector(0 to 31);
      M_RNW : in std_logic_vector(0 to 3);
      M_abort : in std_logic_vector(0 to 3);
      M_busLock : in std_logic_vector(0 to 3);
      M_compress : in std_logic_vector(0 to 3);
      M_guarded : in std_logic_vector(0 to 3);
      M_lockErr : in std_logic_vector(0 to 3);
      M_MSize : in std_logic_vector(0 to 7);
      M_ordered : in std_logic_vector(0 to 3);
      M_priority : in std_logic_vector(0 to 7);
      M_rdBurst : in std_logic_vector(0 to 3);
      M_request : in std_logic_vector(0 to 3);
      M_size : in std_logic_vector(0 to 15);
      M_type : in std_logic_vector(0 to 11);
      M_wrBurst : in std_logic_vector(0 to 3);
      M_wrDBus : in std_logic_vector(0 to 255);
      Sl_addrAck : in std_logic_vector(0 to 5);
      Sl_MErr : in std_logic_vector(0 to 23);
      Sl_MBusy : in std_logic_vector(0 to 23);
      Sl_rdBTerm : in std_logic_vector(0 to 5);
      Sl_rdComp : in std_logic_vector(0 to 5);
      Sl_rdDAck : in std_logic_vector(0 to 5);
      Sl_rdDBus : in std_logic_vector(0 to 383);
      Sl_rdWdAddr : in std_logic_vector(0 to 23);
      Sl_rearbitrate : in std_logic_vector(0 to 5);
      Sl_SSize : in std_logic_vector(0 to 11);
      Sl_wait : in std_logic_vector(0 to 5);
      Sl_wrBTerm : in std_logic_vector(0 to 5);
      Sl_wrComp : in std_logic_vector(0 to 5);
      Sl_wrDAck : in std_logic_vector(0 to 5);
      PLB_ABus : out std_logic_vector(0 to 31);
      PLB_BE : out std_logic_vector(0 to 7);
      PLB_MAddrAck : out std_logic_vector(0 to 3);
      PLB_MBusy : out std_logic_vector(0 to 3);
      PLB_MErr : out std_logic_vector(0 to 3);
      PLB_MRdBTerm : out std_logic_vector(0 to 3);
      PLB_MRdDAck : out std_logic_vector(0 to 3);
      PLB_MRdDBus : out std_logic_vector(0 to 255);
      PLB_MRdWdAddr : out std_logic_vector(0 to 15);
      PLB_MRearbitrate : out std_logic_vector(0 to 3);
      PLB_MWrBTerm : out std_logic_vector(0 to 3);
      PLB_MWrDAck : out std_logic_vector(0 to 3);
      PLB_MSSize : out std_logic_vector(0 to 7);
      PLB_PAValid : out std_logic;
      PLB_RNW : out std_logic;
      PLB_SAValid : out std_logic;
      PLB_abort : out std_logic;
      PLB_busLock : out std_logic;
      PLB_compress : out std_logic;
      PLB_guarded : out std_logic;
      PLB_lockErr : out std_logic;
      PLB_masterID : out std_logic_vector(0 to 1);
      PLB_MSize : out std_logic_vector(0 to 1);
      PLB_ordered : out std_logic;
      PLB_pendPri : out std_logic_vector(0 to 1);
      PLB_pendReq : out std_logic;
      PLB_rdBurst : out std_logic;
      PLB_rdPrim : out std_logic;
      PLB_reqPri : out std_logic_vector(0 to 1);
      PLB_size : out std_logic_vector(0 to 3);
      PLB_type : out std_logic_vector(0 to 2);
      PLB_wrBurst : out std_logic;
      PLB_wrDBus : out std_logic_vector(0 to 63);
      PLB_wrPrim : out std_logic;
      PLB_SaddrAck : out std_logic;
      PLB_SMErr : out std_logic_vector(0 to 3);
      PLB_SMBusy : out std_logic_vector(0 to 3);
      PLB_SrdBTerm : out std_logic;
      PLB_SrdComp : out std_logic;
      PLB_SrdDAck : out std_logic;
      PLB_SrdDBus : out std_logic_vector(0 to 63);
      PLB_SrdWdAddr : out std_logic_vector(0 to 3);
      PLB_Srearbitrate : out std_logic;
      PLB_Sssize : out std_logic_vector(0 to 1);
      PLB_Swait : out std_logic;
      PLB_SwrBTerm : out std_logic;
      PLB_SwrComp : out std_logic;
      PLB_SwrDAck : out std_logic;
      PLB2OPB_rearb : in std_logic_vector(0 to 5);
      ArbAddrVldReg : out std_logic;
      Bus_Error_Det : out std_logic
    );
  end component;

  component plb_ddr_controller_i_wrapper is
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
  end component;

  component plb_bram_if_cntlr_i_wrapper is
    port (
      plb_clk : in std_logic;
      plb_rst : in std_logic;
      plb_abort : in std_logic;
      plb_abus : in std_logic_vector(0 to 31);
      plb_be : in std_logic_vector(0 to 7);
      plb_buslock : in std_logic;
      plb_compress : in std_logic;
      plb_guarded : in std_logic;
      plb_lockerr : in std_logic;
      plb_masterid : in std_logic_vector(0 to 1);
      plb_msize : in std_logic_vector(0 to 1);
      plb_ordered : in std_logic;
      plb_pavalid : in std_logic;
      plb_rnw : in std_logic;
      plb_size : in std_logic_vector(0 to 3);
      plb_type : in std_logic_vector(0 to 2);
      sl_addrack : out std_logic;
      sl_mbusy : out std_logic_vector(0 to 3);
      sl_merr : out std_logic_vector(0 to 3);
      sl_rearbitrate : out std_logic;
      sl_ssize : out std_logic_vector(0 to 1);
      sl_wait : out std_logic;
      plb_rdprim : in std_logic;
      plb_savalid : in std_logic;
      plb_wrprim : in std_logic;
      plb_wrburst : in std_logic;
      plb_wrdbus : in std_logic_vector(0 to 63);
      sl_wrbterm : out std_logic;
      sl_wrcomp : out std_logic;
      sl_wrdack : out std_logic;
      plb_rdburst : in std_logic;
      sl_rdbterm : out std_logic;
      sl_rdcomp : out std_logic;
      sl_rddack : out std_logic;
      sl_rddbus : out std_logic_vector(0 to 63);
      sl_rdwdaddr : out std_logic_vector(0 to 3);
      plb_pendreq : in std_logic;
      plb_pendpri : in std_logic_vector(0 to 1);
      plb_reqpri : in std_logic_vector(0 to 1);
      bram_rst : out std_logic;
      bram_clk : out std_logic;
      bram_en : out std_logic;
      bram_wen : out std_logic_vector(0 to 7);
      bram_addr : out std_logic_vector(0 to 31);
      bram_din : in std_logic_vector(0 to 63);
      bram_dout : out std_logic_vector(0 to 63)
    );
  end component;

  component bram_wrapper is
    port (
      BRAM_Rst_A : in std_logic;
      BRAM_Clk_A : in std_logic;
      BRAM_EN_A : in std_logic;
      BRAM_WEN_A : in std_logic_vector(0 to 7);
      BRAM_Addr_A : in std_logic_vector(0 to 31);
      BRAM_Din_A : out std_logic_vector(0 to 63);
      BRAM_Dout_A : in std_logic_vector(0 to 63);
      BRAM_Rst_B : in std_logic;
      BRAM_Clk_B : in std_logic;
      BRAM_EN_B : in std_logic;
      BRAM_WEN_B : in std_logic_vector(0 to 7);
      BRAM_Addr_B : in std_logic_vector(0 to 31);
      BRAM_Din_B : out std_logic_vector(0 to 63);
      BRAM_Dout_B : in std_logic_vector(0 to 63)
    );
  end component;

  component plb2opb_bridge_i_wrapper is
    port (
      PLB_Clk : in std_logic;
      OPB_Clk : in std_logic;
      PLB_Rst : in std_logic;
      OPB_Rst : in std_logic;
      Bus_Error_Det : out std_logic;
      BGI_Trans_Abort : out std_logic;
      BGO_dcrAck : out std_logic;
      BGO_dcrDBus : out std_logic_vector(0 to 31);
      DCR_ABus : in std_logic_vector(0 to 9);
      DCR_DBus : in std_logic_vector(0 to 31);
      DCR_Read : in std_logic;
      DCR_Write : in std_logic;
      BGO_addrAck : out std_logic;
      BGO_MErr : out std_logic_vector(0 to 3);
      BGO_MBusy : out std_logic_vector(0 to 3);
      BGO_rdBTerm : out std_logic;
      BGO_rdComp : out std_logic;
      BGO_rdDAck : out std_logic;
      BGO_rdDBus : out std_logic_vector(0 to 63);
      BGO_rdWdAddr : out std_logic_vector(0 to 3);
      BGO_rearbitrate : out std_logic;
      BGO_SSize : out std_logic_vector(0 to 1);
      BGO_wait : out std_logic;
      BGO_wrBTerm : out std_logic;
      BGO_wrComp : out std_logic;
      BGO_wrDAck : out std_logic;
      PLB_abort : in std_logic;
      PLB_ABus : in std_logic_vector(0 to 31);
      PLB_BE : in std_logic_vector(0 to 7);
      PLB_busLock : in std_logic;
      PLB_compress : in std_logic;
      PLB_guarded : in std_logic;
      PLB_lockErr : in std_logic;
      PLB_masterID : in std_logic_vector(0 to 1);
      PLB_MSize : in std_logic_vector(0 to 1);
      PLB_ordered : in std_logic;
      PLB_PAValid : in std_logic;
      PLB_rdBurst : in std_logic;
      PLB_rdPrim : in std_logic;
      PLB_RNW : in std_logic;
      PLB_SAValid : in std_logic;
      PLB_size : in std_logic_vector(0 to 3);
      PLB_type : in std_logic_vector(0 to 2);
      PLB_wrBurst : in std_logic;
      PLB_wrDBus : in std_logic_vector(0 to 63);
      PLB_wrPrim : in std_logic;
      PLB2OPB_rearb : out std_logic;
      BGO_ABus : out std_logic_vector(0 to 31);
      BGO_BE : out std_logic_vector(0 to 3);
      BGO_busLock : out std_logic;
      BGO_DBus : out std_logic_vector(0 to 31);
      BGO_request : out std_logic;
      BGO_RNW : out std_logic;
      BGO_select : out std_logic;
      BGO_seqAddr : out std_logic;
      OPB_DBus : in std_logic_vector(0 to 31);
      OPB_errAck : in std_logic;
      OPB_MnGrant : in std_logic;
      OPB_retry : in std_logic;
      OPB_timeout : in std_logic;
      OPB_xferAck : in std_logic
    );
  end component;

  component opb_bus_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : out std_logic;
      SYS_Rst : in std_logic;
      Debug_SYS_Rst : in std_logic;
      WDT_Rst : in std_logic;
      M_ABus : in std_logic_vector(0 to 31);
      M_BE : in std_logic_vector(0 to 3);
      M_beXfer : in std_logic_vector(0 to 0);
      M_busLock : in std_logic_vector(0 to 0);
      M_DBus : in std_logic_vector(0 to 31);
      M_DBusEn : in std_logic_vector(0 to 0);
      M_DBusEn32_63 : in std_logic_vector(0 to 0);
      M_dwXfer : in std_logic_vector(0 to 0);
      M_fwXfer : in std_logic_vector(0 to 0);
      M_hwXfer : in std_logic_vector(0 to 0);
      M_request : in std_logic_vector(0 to 0);
      M_RNW : in std_logic_vector(0 to 0);
      M_select : in std_logic_vector(0 to 0);
      M_seqAddr : in std_logic_vector(0 to 0);
      Sl_beAck : in std_logic_vector(0 to 4);
      Sl_DBus : in std_logic_vector(0 to 159);
      Sl_DBusEn : in std_logic_vector(0 to 4);
      Sl_DBusEn32_63 : in std_logic_vector(0 to 4);
      Sl_errAck : in std_logic_vector(0 to 4);
      Sl_dwAck : in std_logic_vector(0 to 4);
      Sl_fwAck : in std_logic_vector(0 to 4);
      Sl_hwAck : in std_logic_vector(0 to 4);
      Sl_retry : in std_logic_vector(0 to 4);
      Sl_toutSup : in std_logic_vector(0 to 4);
      Sl_xferAck : in std_logic_vector(0 to 4);
      OPB_MRequest : out std_logic_vector(0 to 0);
      OPB_ABus : out std_logic_vector(0 to 31);
      OPB_BE : out std_logic_vector(0 to 3);
      OPB_beXfer : out std_logic;
      OPB_beAck : out std_logic;
      OPB_busLock : out std_logic;
      OPB_rdDBus : out std_logic_vector(0 to 31);
      OPB_wrDBus : out std_logic_vector(0 to 31);
      OPB_DBus : out std_logic_vector(0 to 31);
      OPB_errAck : out std_logic;
      OPB_dwAck : out std_logic;
      OPB_dwXfer : out std_logic;
      OPB_fwAck : out std_logic;
      OPB_fwXfer : out std_logic;
      OPB_hwAck : out std_logic;
      OPB_hwXfer : out std_logic;
      OPB_MGrant : out std_logic_vector(0 to 0);
      OPB_pendReq : out std_logic_vector(0 to 0);
      OPB_retry : out std_logic;
      OPB_RNW : out std_logic;
      OPB_select : out std_logic;
      OPB_seqAddr : out std_logic;
      OPB_timeout : out std_logic;
      OPB_toutSup : out std_logic;
      OPB_xferAck : out std_logic
    );
  end component;

  component ap1000_interrupt_interface_i_wrapper is
    port (
      EXT_sysace_irq : in std_logic;
      PMC_inta_n : in std_logic;
      PMC_intb_n : in std_logic;
      PMC_intc_n : in std_logic;
      PMC_intd_n : in std_logic;
      PS2_int0_n : in std_logic;
      PS2_int1_n : in std_logic;
      PS2_int2_n : in std_logic;
      PS2_int3_n : in std_logic;
      PS2_int4_n : in std_logic;
      PS2_int5_n : in std_logic;
      EXT_sysace_irq_internal : out std_logic;
      PMC_inta_n_internal : out std_logic;
      PMC_intb_n_internal : out std_logic;
      PMC_intc_n_internal : out std_logic;
      PMC_intd_n_internal : out std_logic;
      PS2_int0_n_internal : out std_logic;
      PS2_int1_n_internal : out std_logic;
      PS2_int2_n_internal : out std_logic;
      PS2_int3_n_internal : out std_logic;
      PS2_int4_n_internal : out std_logic;
      PS2_int5_n_internal : out std_logic;
      dummy1_interrupt : out std_logic;
      dummy2_interrupt : out std_logic;
      dummy3_interrupt : out std_logic;
      dummy4_interrupt : out std_logic;
      dummy5_interrupt : out std_logic;
      dummy6_interrupt : out std_logic;
      dummy7_interrupt : out std_logic;
      dummy8_interrupt : out std_logic;
      dummy9_interrupt : out std_logic;
      dummy10_interrupt : out std_logic;
      dummy11_interrupt : out std_logic;
      dummy12_interrupt : out std_logic
    );
  end component;

  component opb_intc_i_wrapper is
    port (
      OPB_Clk : in std_logic;
      Intr : in std_logic_vector(20 downto 0);
      OPB_Rst : in std_logic;
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      OPB_DBus : in std_logic_vector(0 to 31);
      IntC_DBus : out std_logic_vector(0 to 31);
      IntC_errAck : out std_logic;
      IntC_retry : out std_logic;
      IntC_toutSup : out std_logic;
      IntC_xferAck : out std_logic;
      Irq : out std_logic
    );
  end component;

  component rs232_1_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      Interrupt : out std_logic;
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      OPB_DBus : in std_logic_vector(0 to 31);
      UART_DBus : out std_logic_vector(0 to 31);
      UART_errAck : out std_logic;
      UART_retry : out std_logic;
      UART_toutSup : out std_logic;
      UART_xferAck : out std_logic;
      RX : in std_logic;
      TX : out std_logic
    );
  end component;

  component opbslave_ext_bridge_i_wrapper is
    port (
      clk : in std_logic;
      reset : in std_logic;
      opb_abus : in std_logic_vector(0 to 31);
      opb_be : in std_logic_vector(0 to 3);
      opb_rnw : in std_logic;
      opb_select : in std_logic;
      opb_seqAddr : in std_logic;
      opb_dbusm : in std_logic_vector(0 to 31);
      sl_dbus : out std_logic_vector(0 to 31);
      sl_errack : out std_logic;
      sl_retry : out std_logic;
      sl_toutsup : out std_logic;
      sl_xferack : out std_logic;
      fpga_test_switch : in std_logic_vector(0 to 7);
      fpga_test_led : out std_logic_vector(0 to 7);
      fpga_therm : in std_logic;
      EXT_cpld_br_n : in std_logic;
      EXT_cpld_bg_n : out std_logic;
      EXT_cpld_cs_n : out std_logic;
      EXT_flash_cs_n : out std_logic;
      EXT_sysace_cs_n : out std_logic;
      RSTCPU1 : in std_logic;
      RSTCPU2 : in std_logic;
      ppc1_sw_reset : out std_logic;
      ppc2_sw_reset : out std_logic;
      opb_ext_bridge_debug_bus : out std_logic_vector(60 downto 0);
      EXT_data_I : in std_logic_vector(0 to 15);
      EXT_data_O : out std_logic_vector(0 to 15);
      EXT_data_T : out std_logic;
      EXT_addr_I : in std_logic_vector(0 to 24);
      EXT_addr_O : out std_logic_vector(0 to 24);
      EXT_addr_T : out std_logic;
      EXT_we_n_I : in std_logic;
      EXT_we_n_O : out std_logic;
      EXT_we_n_T : out std_logic;
      EXT_con_flash_cs_n_I : in std_logic;
      EXT_con_flash_cs_n_O : out std_logic;
      EXT_con_flash_cs_n_T : out std_logic;
      EXT_oe_n_I : in std_logic;
      EXT_oe_n_O : out std_logic;
      EXT_oe_n_T : out std_logic
    );
  end component;

  component plb_psb_bridge_i_wrapper is
    port (
      debug_bus : out std_logic_vector(254 downto 0);
      clk : in std_logic;
      reset : in std_logic;
      PLBma_RdWdAddr : in std_logic_vector(0 to 3);
      PLBma_RdDBus : in std_logic_vector(0 to 63);
      PLBma_AddrAck : in std_logic;
      PLBma_RdDAck : in std_logic;
      PLBma_WrDAck : in std_logic;
      PLBma_rearbitrate : in std_logic;
      PLBma_Busy : in std_logic;
      PLBma_Err : in std_logic;
      PLBma_RdBTerm : in std_logic;
      PLBma_WrBTerm : in std_logic;
      PLBma_sSize : in std_logic_vector(0 to 1);
      PLBma_pendReq : in std_logic;
      PLBma_pendPri : in std_logic_vector(0 to 1);
      PLBma_reqPri : in std_logic_vector(0 to 1);
      BGIma_request : out std_logic;
      BGIma_ABus : out std_logic_vector(0 to 31);
      BGIma_RNW : out std_logic;
      BGIma_BE : out std_logic_vector(0 to 7);
      BGIma_size : out std_logic_vector(0 to 3);
      BGIma_type : out std_logic_vector(0 to 2);
      BGIma_priority : out std_logic_vector(0 to 1);
      BGIma_rdBurst : out std_logic;
      BGIma_wrBurst : out std_logic;
      BGIma_busLock : out std_logic;
      BGIma_abort : out std_logic;
      BGIma_lockErr : out std_logic;
      BGIma_mSize : out std_logic_vector(0 to 1);
      BGIma_ordered : out std_logic;
      BGIma_compress : out std_logic;
      BGIma_guarded : out std_logic;
      BGIma_wrDBus : out std_logic_vector(0 to 63);
      PLBsl_ABus : in std_logic_vector(0 to 31);
      PLBsl_PAValid : in std_logic;
      PLBsl_SAValid : in std_logic;
      PLBsl_rdPrim : in std_logic;
      PLBsl_wrPrim : in std_logic;
      PLBsl_masterID : in std_logic_vector(0 to 1);
      PLBsl_abort : in std_logic;
      PLBsl_busLock : in std_logic;
      PLBsl_RNW : in std_logic;
      PLBsl_BE : in std_logic_vector(0 to 7);
      PLBsl_MSize : in std_logic_vector(0 to 1);
      PLBsl_size : in std_logic_vector(0 to 3);
      PLBsl_type : in std_logic_vector(0 to 2);
      PLBsl_compress : in std_logic;
      PLBsl_guarded : in std_logic;
      PLBsl_ordered : in std_logic;
      PLBsl_lockErr : in std_logic;
      PLBsl_wrDBus : in std_logic_vector(0 to 63);
      PLBsl_wrBurst : in std_logic;
      PLBsl_rdBurst : in std_logic;
      BGOsl_addrAck : out std_logic;
      BGOsl_SSize : out std_logic_vector(0 to 1);
      BGOsl_wait : out std_logic;
      BGOsl_rearbitrate : out std_logic;
      BGOsl_wrDAck : out std_logic;
      BGOsl_wrComp : out std_logic;
      BGOsl_wrBTerm : out std_logic;
      BGOsl_rdDBus : out std_logic_vector(0 to 63);
      BGOsl_rdWdAddr : out std_logic_vector(0 to 3);
      BGOsl_rdDAck : out std_logic;
      BGOsl_rdComp : out std_logic;
      BGOsl_rdBTerm : out std_logic;
      BGOsl_MBusy : out std_logic_vector(0 to 3);
      BGOsl_MErr : out std_logic_vector(0 to 3);
      PSB_bg_n : in std_logic;
      PSB_br_n : out std_logic;
      PSB_dbg_n : in std_logic;
      ppc0_uart_to_reg_bus : in std_logic_vector(29 downto 0);
      ppc0_reg_to_uart_bus : out std_logic_vector(75 downto 0);
      host0_uart_to_reg_bus : in std_logic_vector(29 downto 0);
      host0_reg_to_uart_bus : out std_logic_vector(75 downto 0);
      ppc1_uart_to_reg_bus : in std_logic_vector(29 downto 0);
      ppc1_reg_to_uart_bus : out std_logic_vector(75 downto 0);
      host1_uart_to_reg_bus : in std_logic_vector(29 downto 0);
      host1_reg_to_uart_bus : out std_logic_vector(75 downto 0);
      PSB_a_I : in std_logic_vector(0 to 31);
      PSB_a_O : out std_logic_vector(0 to 31);
      PSB_a_T : out std_logic_vector(0 to 31);
      PSB_abb_n_I : in std_logic;
      PSB_abb_n_O : out std_logic;
      PSB_abb_n_T : out std_logic;
      PSB_dbb_n_I : in std_logic;
      PSB_dbb_n_O : out std_logic;
      PSB_dbb_n_T : out std_logic;
      PSB_tbst_n_I : in std_logic;
      PSB_tbst_n_O : out std_logic;
      PSB_tbst_n_T : out std_logic;
      PSB_tsiz_I : in std_logic_vector(0 to 3);
      PSB_tsiz_O : out std_logic_vector(0 to 3);
      PSB_tsiz_T : out std_logic_vector(0 to 3);
      PSB_ts_n_I : in std_logic;
      PSB_ts_n_O : out std_logic;
      PSB_ts_n_T : out std_logic;
      PSB_tt_I : in std_logic_vector(0 to 4);
      PSB_tt_O : out std_logic_vector(0 to 4);
      PSB_tt_T : out std_logic_vector(0 to 4);
      PSB_aack_n_I : in std_logic;
      PSB_aack_n_O : out std_logic;
      PSB_aack_n_T : out std_logic;
      PSB_artry_n_I : in std_logic;
      PSB_artry_n_O : out std_logic;
      PSB_artry_n_T : out std_logic;
      PSB_d_I : in std_logic_vector(0 to 63);
      PSB_d_O : out std_logic_vector(0 to 63);
      PSB_d_T : out std_logic_vector(0 to 63);
      PSB_ta_n_I : in std_logic;
      PSB_ta_n_O : out std_logic;
      PSB_ta_n_T : out std_logic;
      PSB_tea_n_I : in std_logic;
      PSB_tea_n_O : out std_logic;
      PSB_tea_n_T : out std_logic
    );
  end component;

  component dcr_bus_wrapper is
    port (
      M_dcrABus : in std_logic_vector(0 to 9);
      M_dcrDBus : in std_logic_vector(0 to 31);
      M_dcrRead : in std_logic;
      M_dcrWrite : in std_logic;
      DCR_M_DBus : out std_logic_vector(0 to 31);
      DCR_Ack : out std_logic;
      DCR_ABus : out std_logic_vector(0 to 19);
      DCR_Sl_DBus : out std_logic_vector(0 to 63);
      DCR_Read : out std_logic_vector(0 to 1);
      DCR_Write : out std_logic_vector(0 to 1);
      Sl_dcrDBus : in std_logic_vector(0 to 63);
      Sl_dcrAck : in std_logic_vector(0 to 1)
    );
  end component;

  component ppc405_ppcjtag_chain_wrapper is
    port (
      C405CPMCORESLEEPREQ : out std_logic;
      C405CPMMSRCE : out std_logic;
      C405CPMMSREE : out std_logic;
      C405CPMTIMERIRQ : out std_logic;
      C405CPMTIMERRESETREQ : out std_logic;
      C405XXXMACHINECHECK : out std_logic;
      CPMC405CLOCK : in std_logic;
      CPMC405CORECLKINACTIVE : in std_logic;
      CPMC405CPUCLKEN : in std_logic;
      CPMC405JTAGCLKEN : in std_logic;
      CPMC405TIMERCLKEN : in std_logic;
      CPMC405TIMERTICK : in std_logic;
      MCBCPUCLKEN : in std_logic;
      MCBTIMEREN : in std_logic;
      MCPPCRST : in std_logic;
      PLBCLK : in std_logic;
      DCRCLK : in std_logic;
      C405RSTCHIPRESETREQ : out std_logic;
      C405RSTCORERESETREQ : out std_logic;
      C405RSTSYSRESETREQ : out std_logic;
      RSTC405RESETCHIP : in std_logic;
      RSTC405RESETCORE : in std_logic;
      RSTC405RESETSYS : in std_logic;
      C405PLBICUABUS : out std_logic_vector(0 to 31);
      C405PLBICUBE : out std_logic_vector(0 to 7);
      C405PLBICURNW : out std_logic;
      C405PLBICUABORT : out std_logic;
      C405PLBICUBUSLOCK : out std_logic;
      C405PLBICUU0ATTR : out std_logic;
      C405PLBICUGUARDED : out std_logic;
      C405PLBICULOCKERR : out std_logic;
      C405PLBICUMSIZE : out std_logic_vector(0 to 1);
      C405PLBICUORDERED : out std_logic;
      C405PLBICUPRIORITY : out std_logic_vector(0 to 1);
      C405PLBICURDBURST : out std_logic;
      C405PLBICUREQUEST : out std_logic;
      C405PLBICUSIZE : out std_logic_vector(0 to 3);
      C405PLBICUTYPE : out std_logic_vector(0 to 2);
      C405PLBICUWRBURST : out std_logic;
      C405PLBICUWRDBUS : out std_logic_vector(0 to 63);
      C405PLBICUCACHEABLE : out std_logic;
      PLBC405ICUADDRACK : in std_logic;
      PLBC405ICUBUSY : in std_logic;
      PLBC405ICUERR : in std_logic;
      PLBC405ICURDBTERM : in std_logic;
      PLBC405ICURDDACK : in std_logic;
      PLBC405ICURDDBUS : in std_logic_vector(0 to 63);
      PLBC405ICURDWDADDR : in std_logic_vector(0 to 3);
      PLBC405ICUREARBITRATE : in std_logic;
      PLBC405ICUWRBTERM : in std_logic;
      PLBC405ICUWRDACK : in std_logic;
      PLBC405ICUSSIZE : in std_logic_vector(0 to 1);
      PLBC405ICUSERR : in std_logic;
      PLBC405ICUSBUSYS : in std_logic;
      C405PLBDCUABUS : out std_logic_vector(0 to 31);
      C405PLBDCUBE : out std_logic_vector(0 to 7);
      C405PLBDCURNW : out std_logic;
      C405PLBDCUABORT : out std_logic;
      C405PLBDCUBUSLOCK : out std_logic;
      C405PLBDCUU0ATTR : out std_logic;
      C405PLBDCUGUARDED : out std_logic;
      C405PLBDCULOCKERR : out std_logic;
      C405PLBDCUMSIZE : out std_logic_vector(0 to 1);
      C405PLBDCUORDERED : out std_logic;
      C405PLBDCUPRIORITY : out std_logic_vector(0 to 1);
      C405PLBDCURDBURST : out std_logic;
      C405PLBDCUREQUEST : out std_logic;
      C405PLBDCUSIZE : out std_logic_vector(0 to 3);
      C405PLBDCUTYPE : out std_logic_vector(0 to 2);
      C405PLBDCUWRBURST : out std_logic;
      C405PLBDCUWRDBUS : out std_logic_vector(0 to 63);
      C405PLBDCUCACHEABLE : out std_logic;
      C405PLBDCUWRITETHRU : out std_logic;
      PLBC405DCUADDRACK : in std_logic;
      PLBC405DCUBUSY : in std_logic;
      PLBC405DCUERR : in std_logic;
      PLBC405DCURDBTERM : in std_logic;
      PLBC405DCURDDACK : in std_logic;
      PLBC405DCURDDBUS : in std_logic_vector(0 to 63);
      PLBC405DCURDWDADDR : in std_logic_vector(0 to 3);
      PLBC405DCUREARBITRATE : in std_logic;
      PLBC405DCUWRBTERM : in std_logic;
      PLBC405DCUWRDACK : in std_logic;
      PLBC405DCUSSIZE : in std_logic_vector(0 to 1);
      PLBC405DCUSERR : in std_logic;
      PLBC405DCUSBUSYS : in std_logic;
      BRAMDSOCMCLK : in std_logic;
      BRAMDSOCMRDDBUS : in std_logic_vector(0 to 31);
      DSARCVALUE : in std_logic_vector(0 to 7);
      DSCNTLVALUE : in std_logic_vector(0 to 7);
      DSOCMBRAMABUS : out std_logic_vector(8 to 29);
      DSOCMBRAMBYTEWRITE : out std_logic_vector(0 to 3);
      DSOCMBRAMEN : out std_logic;
      DSOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
      DSOCMBUSY : out std_logic;
      BRAMISOCMCLK : in std_logic;
      BRAMISOCMRDDBUS : in std_logic_vector(0 to 63);
      ISARCVALUE : in std_logic_vector(0 to 7);
      ISCNTLVALUE : in std_logic_vector(0 to 7);
      ISOCMBRAMEN : out std_logic;
      ISOCMBRAMEVENWRITEEN : out std_logic;
      ISOCMBRAMODDWRITEEN : out std_logic;
      ISOCMBRAMRDABUS : out std_logic_vector(8 to 28);
      ISOCMBRAMWRABUS : out std_logic_vector(8 to 28);
      ISOCMBRAMWRDBUS : out std_logic_vector(0 to 31);
      C405DCRABUS : out std_logic_vector(0 to 9);
      C405DCRDBUSOUT : out std_logic_vector(0 to 31);
      C405DCRREAD : out std_logic;
      C405DCRWRITE : out std_logic;
      DCRC405ACK : in std_logic;
      DCRC405DBUSIN : in std_logic_vector(0 to 31);
      EICC405CRITINPUTIRQ : in std_logic;
      EICC405EXTINPUTIRQ : in std_logic;
      C405JTGCAPTUREDR : out std_logic;
      C405JTGEXTEST : out std_logic;
      C405JTGPGMOUT : out std_logic;
      C405JTGSHIFTDR : out std_logic;
      C405JTGTDO : out std_logic;
      C405JTGTDOEN : out std_logic;
      C405JTGUPDATEDR : out std_logic;
      MCBJTAGEN : in std_logic;
      JTGC405BNDSCANTDO : in std_logic;
      JTGC405TCK : in std_logic;
      JTGC405TDI : in std_logic;
      JTGC405TMS : in std_logic;
      JTGC405TRSTNEG : in std_logic;
      C405DBGMSRWE : out std_logic;
      C405DBGSTOPACK : out std_logic;
      C405DBGWBCOMPLETE : out std_logic;
      C405DBGWBFULL : out std_logic;
      C405DBGWBIAR : out std_logic_vector(0 to 29);
      DBGC405DEBUGHALT : in std_logic;
      DBGC405EXTBUSHOLDACK : in std_logic;
      DBGC405UNCONDDEBUGEVENT : in std_logic;
      C405TRCCYCLE : out std_logic;
      C405TRCEVENEXECUTIONSTATUS : out std_logic_vector(0 to 1);
      C405TRCODDEXECUTIONSTATUS : out std_logic_vector(0 to 1);
      C405TRCTRACESTATUS : out std_logic_vector(0 to 3);
      C405TRCTRIGGEREVENTOUT : out std_logic;
      C405TRCTRIGGEREVENTTYPE : out std_logic_vector(0 to 10);
      TRCC405TRACEDISABLE : in std_logic;
      TRCC405TRIGGEREVENTIN : in std_logic
    );
  end component;

  component jtagppc_0_wrapper is
    port (
      TRSTNEG : in std_logic;
      HALTNEG0 : in std_logic;
      DBGC405DEBUGHALT0 : out std_logic;
      HALTNEG1 : in std_logic;
      DBGC405DEBUGHALT1 : out std_logic;
      C405JTGTDO0 : in std_logic;
      C405JTGTDOEN0 : in std_logic;
      JTGC405TCK0 : out std_logic;
      JTGC405TDI0 : out std_logic;
      JTGC405TMS0 : out std_logic;
      JTGC405TRSTNEG0 : out std_logic;
      C405JTGTDO1 : in std_logic;
      C405JTGTDOEN1 : in std_logic;
      JTGC405TCK1 : out std_logic;
      JTGC405TDI1 : out std_logic;
      JTGC405TMS1 : out std_logic;
      JTGC405TRSTNEG1 : out std_logic
    );
  end component;

  component plb_emc_0_wrapper is
    port (
      PLB_Clk : in std_logic;
      PLB_Rst : in std_logic;
      PLB_abort : in std_logic;
      PLB_ABus : in std_logic_vector(0 to 31);
      PLB_BE : in std_logic_vector(0 to 7);
      PLB_busLock : in std_logic;
      PLB_compress : in std_logic;
      PLB_guarded : in std_logic;
      PLB_lockErr : in std_logic;
      PLB_masterID : in std_logic_vector(0 to 1);
      PLB_MSize : in std_logic_vector(0 to 1);
      PLB_ordered : in std_logic;
      PLB_PAValid : in std_logic;
      PLB_RNW : in std_logic;
      PLB_size : in std_logic_vector(0 to 3);
      PLB_type : in std_logic_vector(0 to 2);
      Sl_addrAck : out std_logic;
      Sl_MBusy : out std_logic_vector(0 to 3);
      Sl_MErr : out std_logic_vector(0 to 3);
      Sl_rearbitrate : out std_logic;
      Sl_SSize : out std_logic_vector(0 to 1);
      Sl_wait : out std_logic;
      PLB_rdPrim : in std_logic;
      PLB_SAValid : in std_logic;
      PLB_wrPrim : in std_logic;
      PLB_wrBurst : in std_logic;
      PLB_wrDBus : in std_logic_vector(0 to 63);
      Sl_wrBTerm : out std_logic;
      Sl_wrComp : out std_logic;
      Sl_wrDAck : out std_logic;
      PLB_rdBurst : in std_logic;
      Sl_rdBTerm : out std_logic;
      Sl_rdComp : out std_logic;
      Sl_rdDAck : out std_logic;
      Sl_rdDBus : out std_logic_vector(0 to 63);
      Sl_rdWdAddr : out std_logic_vector(0 to 3);
      PLB_pendReq : in std_logic;
      PLB_pendPri : in std_logic_vector(0 to 1);
      PLB_reqPri : in std_logic_vector(0 to 1);
      Mem_A : out std_logic_vector(0 to 31);
      Mem_CEN : out std_logic_vector(0 to 0);
      Mem_OEN : out std_logic_vector(0 to 0);
      Mem_WEN : out std_logic;
      Mem_QWEN : out std_logic_vector(0 to 3);
      Mem_BEN : out std_logic_vector(0 to 3);
      Mem_RPN : out std_logic;
      Mem_CE : out std_logic_vector(0 to 0);
      Mem_ADV_LDN : out std_logic;
      Mem_LBON : out std_logic;
      Mem_CKEN : out std_logic;
      Mem_RNW : out std_logic;
      Mem_DQ_I : in std_logic_vector(0 to 31);
      Mem_DQ_O : out std_logic_vector(0 to 31);
      Mem_DQ_T : out std_logic_vector(0 to 31)
    );
  end component;

  component opb_gpio_0_wrapper is
    port (
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_Clk : in std_logic;
      OPB_DBus : in std_logic_vector(0 to 31);
      OPB_RNW : in std_logic;
      OPB_Rst : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      Sln_DBus : out std_logic_vector(0 to 31);
      Sln_errAck : out std_logic;
      Sln_retry : out std_logic;
      Sln_toutSup : out std_logic;
      Sln_xferAck : out std_logic;
      IP2INTC_Irpt : out std_logic;
      GPIO_in : in std_logic_vector(0 to 7);
      GPIO_d_out : out std_logic_vector(0 to 7);
      GPIO_t_out : out std_logic_vector(0 to 7);
      GPIO2_in : in std_logic_vector(0 to 7);
      GPIO2_d_out : out std_logic_vector(0 to 7);
      GPIO2_t_out : out std_logic_vector(0 to 7);
      GPIO_IO_I : in std_logic_vector(0 to 7);
      GPIO_IO_O : out std_logic_vector(0 to 7);
      GPIO_IO_T : out std_logic_vector(0 to 7);
      GPIO2_IO_I : in std_logic_vector(0 to 7);
      GPIO2_IO_O : out std_logic_vector(0 to 7);
      GPIO2_IO_T : out std_logic_vector(0 to 7)
    );
  end component;

  component opb_timer_0_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_DBus : in std_logic_vector(0 to 31);
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      TC_DBus : out std_logic_vector(0 to 31);
      TC_errAck : out std_logic;
      TC_retry : out std_logic;
      TC_toutSup : out std_logic;
      TC_xferAck : out std_logic;
      CaptureTrig0 : in std_logic;
      CaptureTrig1 : in std_logic;
      GenerateOut0 : out std_logic;
      GenerateOut1 : out std_logic;
      PWM0 : out std_logic;
      Interrupt : out std_logic;
      Freeze : in std_logic
    );
  end component;

  component hwrtos_0_wrapper is
    port (
      PLB_Clk : in std_logic;
      PLB_Rst : in std_logic;
      Sl_addrAck : out std_logic;
      Sl_MBusy : out std_logic_vector(0 to 3);
      Sl_MErr : out std_logic_vector(0 to 3);
      Sl_rdBTerm : out std_logic;
      Sl_rdComp : out std_logic;
      Sl_rdDAck : out std_logic;
      Sl_rdDBus : out std_logic_vector(0 to 63);
      Sl_rdWdAddr : out std_logic_vector(0 to 3);
      Sl_rearbitrate : out std_logic;
      Sl_SSize : out std_logic_vector(0 to 1);
      Sl_wait : out std_logic;
      Sl_wrBTerm : out std_logic;
      Sl_wrComp : out std_logic;
      Sl_wrDAck : out std_logic;
      PLB_abort : in std_logic;
      PLB_ABus : in std_logic_vector(0 to 31);
      PLB_BE : in std_logic_vector(0 to 7);
      PLB_busLock : in std_logic;
      PLB_compress : in std_logic;
      PLB_guarded : in std_logic;
      PLB_lockErr : in std_logic;
      PLB_masterID : in std_logic_vector(0 to 1);
      PLB_MSize : in std_logic_vector(0 to 1);
      PLB_ordered : in std_logic;
      PLB_PAValid : in std_logic;
      PLB_pendPri : in std_logic_vector(0 to 1);
      PLB_pendReq : in std_logic;
      PLB_rdBurst : in std_logic;
      PLB_rdPrim : in std_logic;
      PLB_reqPri : in std_logic_vector(0 to 1);
      PLB_RNW : in std_logic;
      PLB_SAValid : in std_logic;
      PLB_size : in std_logic_vector(0 to 3);
      PLB_type : in std_logic_vector(0 to 2);
      PLB_wrBurst : in std_logic;
      PLB_wrDBus : in std_logic_vector(0 to 63);
      PLB_wrPrim : in std_logic;
      M_abort : out std_logic;
      M_ABus : out std_logic_vector(0 to 31);
      M_BE : out std_logic_vector(0 to 7);
      M_busLock : out std_logic;
      M_compress : out std_logic;
      M_guarded : out std_logic;
      M_lockErr : out std_logic;
      M_MSize : out std_logic_vector(0 to 1);
      M_ordered : out std_logic;
      M_priority : out std_logic_vector(0 to 1);
      M_rdBurst : out std_logic;
      M_request : out std_logic;
      M_RNW : out std_logic;
      M_size : out std_logic_vector(0 to 3);
      M_type : out std_logic_vector(0 to 2);
      M_wrBurst : out std_logic;
      M_wrDBus : out std_logic_vector(0 to 63);
      PLB_MBusy : in std_logic;
      PLB_MErr : in std_logic;
      PLB_MWrBTerm : in std_logic;
      PLB_MWrDAck : in std_logic;
      PLB_MAddrAck : in std_logic;
      PLB_MRdBTerm : in std_logic;
      PLB_MRdDAck : in std_logic;
      PLB_MRdDBus : in std_logic_vector(0 to 63);
      PLB_MRdWdAddr : in std_logic_vector(0 to 3);
      PLB_MRearbitrate : in std_logic;
      PLB_MSSize : in std_logic_vector(0 to 1);
      IP2INTC_Irpt : out std_logic
    );
  end component;

  component IOBUF is
    port (
      I : in std_logic;
      IO : inout std_logic;
      O : out std_logic;
      T : in std_logic
    );
  end component;

  -- Internal signals

  signal CLKCPU : std_logic;
  signal CLKOPB : std_logic;
  signal CLKPLB : std_logic;
  signal DDR1_CLKFB_90 : std_logic;
  signal DDR_CLKPLB_90 : std_logic;
  signal Irq : std_logic;
  signal PSB_d_I : std_logic_vector(0 to 63);
  signal PSB_d_O : std_logic_vector(0 to 63);
  signal PSB_d_T : std_logic_vector(0 to 63);
  signal RSTCPU : std_logic;
  signal RSTOPB : std_logic;
  signal RSTPLB : std_logic;
  signal con_flash_cs_n_I : std_logic;
  signal con_flash_cs_n_O : std_logic;
  signal con_flash_cs_n_T : std_logic;
  signal dcr_bus_DCR_ABus : std_logic_vector(0 to 19);
  signal dcr_bus_DCR_Ack : std_logic;
  signal dcr_bus_DCR_M_DBus : std_logic_vector(0 to 31);
  signal dcr_bus_DCR_Read : std_logic_vector(0 to 1);
  signal dcr_bus_DCR_Sl_DBus : std_logic_vector(0 to 63);
  signal dcr_bus_DCR_Write : std_logic_vector(0 to 1);
  signal dcr_bus_M_dcrABus : std_logic_vector(0 to 9);
  signal dcr_bus_M_dcrDBus : std_logic_vector(0 to 31);
  signal dcr_bus_M_dcrRead : std_logic;
  signal dcr_bus_M_dcrWrite : std_logic;
  signal dcr_bus_Sl_dcrAck : std_logic_vector(0 to 1);
  signal dcr_bus_Sl_dcrDBus : std_logic_vector(0 to 63);
  signal ddr1_dq_I : std_logic_vector(31 downto 0);
  signal ddr1_dq_O : std_logic_vector(31 downto 0);
  signal ddr1_dq_T : std_logic_vector(31 downto 0);
  signal ddr1_dqs_I : std_logic_vector(3 downto 0);
  signal ddr1_dqs_O : std_logic_vector(3 downto 0);
  signal ddr1_dqs_T : std_logic_vector(3 downto 0);
  signal fpga_test_led_I : std_logic_vector(0 to 7);
  signal fpga_test_led_O : std_logic_vector(0 to 7);
  signal fpga_test_led_T : std_logic_vector(0 to 7);
  signal int0 : std_logic;
  signal int1 : std_logic;
  signal int2 : std_logic;
  signal int3 : std_logic;
  signal int4 : std_logic;
  signal int5 : std_logic;
  signal int6 : std_logic;
  signal int8 : std_logic;
  signal int9 : std_logic;
  signal int10 : std_logic;
  signal int11 : std_logic;
  signal int12 : std_logic;
  signal int13 : std_logic;
  signal int14 : std_logic;
  signal int15 : std_logic;
  signal int16 : std_logic;
  signal int17 : std_logic;
  signal int18 : std_logic;
  signal int19 : std_logic;
  signal int20 : std_logic;
  signal int21 : std_logic;
  signal jtagppc0_C405JTGTDO : std_logic;
  signal jtagppc0_C405JTGTDOEN : std_logic;
  signal jtagppc0_JTGC405TCK : std_logic;
  signal jtagppc0_JTGC405TDI : std_logic;
  signal jtagppc0_JTGC405TMS : std_logic;
  signal jtagppc0_JTGC405TRSTNEG : std_logic;
  signal jtagppc1_C405JTGTDO : std_logic;
  signal jtagppc1_C405JTGTDOEN : std_logic;
  signal jtagppc1_JTGC405TCK : std_logic;
  signal jtagppc1_JTGC405TDI : std_logic;
  signal jtagppc1_JTGC405TMS : std_logic;
  signal jtagppc1_JTGC405TRSTNEG : std_logic;
  signal lbus_addr_I : std_logic_vector(0 to 24);
  signal lbus_addr_O : std_logic_vector(0 to 24);
  signal lbus_addr_T : std_logic;
  signal lbus_data_I : std_logic_vector(0 to 15);
  signal lbus_data_O : std_logic_vector(0 to 15);
  signal lbus_data_T : std_logic;
  signal lbus_oe_n_I : std_logic;
  signal lbus_oe_n_O : std_logic;
  signal lbus_oe_n_T : std_logic;
  signal lbus_we_n_I : std_logic;
  signal lbus_we_n_O : std_logic;
  signal lbus_we_n_T : std_logic;
  signal net_gnd0 : std_logic;
  signal net_gnd1 : std_logic_vector(0 to 0);
  signal net_gnd2 : std_logic_vector(0 to 1);
  signal net_gnd4 : std_logic_vector(0 to 3);
  signal net_gnd5 : std_logic_vector(0 to 4);
  signal net_gnd8 : std_logic_vector(0 to 7);
  signal net_gnd30 : std_logic_vector(29 downto 0);
  signal net_gnd32 : std_logic_vector(0 to 31);
  signal net_gnd64 : std_logic_vector(0 to 63);
  signal net_vcc0 : std_logic;
  signal net_vcc1 : std_logic_vector(0 to 0);
  signal net_vcc5 : std_logic_vector(0 to 4);
  signal opb_bus_M_ABus : std_logic_vector(0 to 31);
  signal opb_bus_M_BE : std_logic_vector(0 to 3);
  signal opb_bus_M_DBus : std_logic_vector(0 to 31);
  signal opb_bus_M_RNW : std_logic_vector(0 to 0);
  signal opb_bus_M_busLock : std_logic_vector(0 to 0);
  signal opb_bus_M_request : std_logic_vector(0 to 0);
  signal opb_bus_M_select : std_logic_vector(0 to 0);
  signal opb_bus_M_seqAddr : std_logic_vector(0 to 0);
  signal opb_bus_OPB_ABus : std_logic_vector(0 to 31);
  signal opb_bus_OPB_BE : std_logic_vector(0 to 3);
  signal opb_bus_OPB_DBus : std_logic_vector(0 to 31);
  signal opb_bus_OPB_MGrant : std_logic_vector(0 to 0);
  signal opb_bus_OPB_RNW : std_logic;
  signal opb_bus_OPB_Rst : std_logic;
  signal opb_bus_OPB_errAck : std_logic;
  signal opb_bus_OPB_retry : std_logic;
  signal opb_bus_OPB_select : std_logic;
  signal opb_bus_OPB_seqAddr : std_logic;
  signal opb_bus_OPB_timeout : std_logic;
  signal opb_bus_OPB_xferAck : std_logic;
  signal opb_bus_Sl_DBus : std_logic_vector(0 to 159);
  signal opb_bus_Sl_errAck : std_logic_vector(0 to 4);
  signal opb_bus_Sl_retry : std_logic_vector(0 to 4);
  signal opb_bus_Sl_toutSup : std_logic_vector(0 to 4);
  signal opb_bus_Sl_xferAck : std_logic_vector(0 to 4);
  signal pgassign1 : std_logic_vector(20 downto 0);
  signal pgassign2 : std_logic_vector(0 to 7);
  signal plb_bus_M_ABus : std_logic_vector(0 to 127);
  signal plb_bus_M_BE : std_logic_vector(0 to 31);
  signal plb_bus_M_MSize : std_logic_vector(0 to 7);
  signal plb_bus_M_RNW : std_logic_vector(0 to 3);
  signal plb_bus_M_abort : std_logic_vector(0 to 3);
  signal plb_bus_M_busLock : std_logic_vector(0 to 3);
  signal plb_bus_M_compress : std_logic_vector(0 to 3);
  signal plb_bus_M_guarded : std_logic_vector(0 to 3);
  signal plb_bus_M_lockErr : std_logic_vector(0 to 3);
  signal plb_bus_M_ordered : std_logic_vector(0 to 3);
  signal plb_bus_M_priority : std_logic_vector(0 to 7);
  signal plb_bus_M_rdBurst : std_logic_vector(0 to 3);
  signal plb_bus_M_request : std_logic_vector(0 to 3);
  signal plb_bus_M_size : std_logic_vector(0 to 15);
  signal plb_bus_M_type : std_logic_vector(0 to 11);
  signal plb_bus_M_wrBurst : std_logic_vector(0 to 3);
  signal plb_bus_M_wrDBus : std_logic_vector(0 to 255);
  signal plb_bus_PLB2OPB_rearb : std_logic_vector(0 to 5);
  signal plb_bus_PLB_ABus : std_logic_vector(0 to 31);
  signal plb_bus_PLB_BE : std_logic_vector(0 to 7);
  signal plb_bus_PLB_MAddrAck : std_logic_vector(0 to 3);
  signal plb_bus_PLB_MBusy : std_logic_vector(0 to 3);
  signal plb_bus_PLB_MErr : std_logic_vector(0 to 3);
  signal plb_bus_PLB_MRdBTerm : std_logic_vector(0 to 3);
  signal plb_bus_PLB_MRdDAck : std_logic_vector(0 to 3);
  signal plb_bus_PLB_MRdDBus : std_logic_vector(0 to 255);
  signal plb_bus_PLB_MRdWdAddr : std_logic_vector(0 to 15);
  signal plb_bus_PLB_MRearbitrate : std_logic_vector(0 to 3);
  signal plb_bus_PLB_MSSize : std_logic_vector(0 to 7);
  signal plb_bus_PLB_MSize : std_logic_vector(0 to 1);
  signal plb_bus_PLB_MWrBTerm : std_logic_vector(0 to 3);
  signal plb_bus_PLB_MWrDAck : std_logic_vector(0 to 3);
  signal plb_bus_PLB_PAValid : std_logic;
  signal plb_bus_PLB_RNW : std_logic;
  signal plb_bus_PLB_Rst : std_logic;
  signal plb_bus_PLB_SAValid : std_logic;
  signal plb_bus_PLB_SMBusy : std_logic_vector(0 to 3);
  signal plb_bus_PLB_SMErr : std_logic_vector(0 to 3);
  signal plb_bus_PLB_abort : std_logic;
  signal plb_bus_PLB_busLock : std_logic;
  signal plb_bus_PLB_compress : std_logic;
  signal plb_bus_PLB_guarded : std_logic;
  signal plb_bus_PLB_lockErr : std_logic;
  signal plb_bus_PLB_masterID : std_logic_vector(0 to 1);
  signal plb_bus_PLB_ordered : std_logic;
  signal plb_bus_PLB_pendPri : std_logic_vector(0 to 1);
  signal plb_bus_PLB_pendReq : std_logic;
  signal plb_bus_PLB_rdBurst : std_logic;
  signal plb_bus_PLB_rdPrim : std_logic;
  signal plb_bus_PLB_reqPri : std_logic_vector(0 to 1);
  signal plb_bus_PLB_size : std_logic_vector(0 to 3);
  signal plb_bus_PLB_type : std_logic_vector(0 to 2);
  signal plb_bus_PLB_wrBurst : std_logic;
  signal plb_bus_PLB_wrDBus : std_logic_vector(0 to 63);
  signal plb_bus_PLB_wrPrim : std_logic;
  signal plb_bus_Sl_MBusy : std_logic_vector(0 to 23);
  signal plb_bus_Sl_MErr : std_logic_vector(0 to 23);
  signal plb_bus_Sl_SSize : std_logic_vector(0 to 11);
  signal plb_bus_Sl_addrAck : std_logic_vector(0 to 5);
  signal plb_bus_Sl_rdBTerm : std_logic_vector(0 to 5);
  signal plb_bus_Sl_rdComp : std_logic_vector(0 to 5);
  signal plb_bus_Sl_rdDAck : std_logic_vector(0 to 5);
  signal plb_bus_Sl_rdDBus : std_logic_vector(0 to 383);
  signal plb_bus_Sl_rdWdAddr : std_logic_vector(0 to 23);
  signal plb_bus_Sl_rearbitrate : std_logic_vector(0 to 5);
  signal plb_bus_Sl_wait : std_logic_vector(0 to 5);
  signal plb_bus_Sl_wrBTerm : std_logic_vector(0 to 5);
  signal plb_bus_Sl_wrComp : std_logic_vector(0 to 5);
  signal plb_bus_Sl_wrDAck : std_logic_vector(0 to 5);
  signal porta_BRAM_Addr : std_logic_vector(0 to 31);
  signal porta_BRAM_Clk : std_logic;
  signal porta_BRAM_Din : std_logic_vector(0 to 63);
  signal porta_BRAM_Dout : std_logic_vector(0 to 63);
  signal porta_BRAM_EN : std_logic;
  signal porta_BRAM_Rst : std_logic;
  signal porta_BRAM_WEN : std_logic_vector(0 to 7);
  signal psb_a_I : std_logic_vector(0 to 31);
  signal psb_a_O : std_logic_vector(0 to 31);
  signal psb_a_T : std_logic_vector(0 to 31);
  signal psb_aack_n_I : std_logic;
  signal psb_aack_n_O : std_logic;
  signal psb_aack_n_T : std_logic;
  signal psb_abb_n_I : std_logic;
  signal psb_abb_n_O : std_logic;
  signal psb_abb_n_T : std_logic;
  signal psb_artry_n_I : std_logic;
  signal psb_artry_n_O : std_logic;
  signal psb_artry_n_T : std_logic;
  signal psb_dbb_n_I : std_logic;
  signal psb_dbb_n_O : std_logic;
  signal psb_dbb_n_T : std_logic;
  signal psb_ta_n_I : std_logic;
  signal psb_ta_n_O : std_logic;
  signal psb_ta_n_T : std_logic;
  signal psb_tbst_n_I : std_logic;
  signal psb_tbst_n_O : std_logic;
  signal psb_tbst_n_T : std_logic;
  signal psb_tea_n_I : std_logic;
  signal psb_tea_n_O : std_logic;
  signal psb_tea_n_T : std_logic;
  signal psb_ts_n_I : std_logic;
  signal psb_ts_n_O : std_logic;
  signal psb_ts_n_T : std_logic;
  signal psb_tsiz_I : std_logic_vector(0 to 3);
  signal psb_tsiz_O : std_logic_vector(0 to 3);
  signal psb_tsiz_T : std_logic_vector(0 to 3);
  signal psb_tt_I : std_logic_vector(0 to 4);
  signal psb_tt_O : std_logic_vector(0 to 4);
  signal psb_tt_T : std_logic_vector(0 to 4);

  attribute box_type : STRING;
  attribute box_type of clock_reset_block_wrapper : component is "black_box";
  attribute box_type of ppc405_i_wrapper : component is "black_box";
  attribute box_type of plb_bus_wrapper : component is "black_box";
  attribute box_type of plb_ddr_controller_i_wrapper : component is "black_box";
  attribute box_type of plb_bram_if_cntlr_i_wrapper : component is "black_box";
  attribute box_type of bram_wrapper : component is "black_box";
  attribute box_type of plb2opb_bridge_i_wrapper : component is "black_box";
  attribute box_type of opb_bus_wrapper : component is "black_box";
  attribute box_type of ap1000_interrupt_interface_i_wrapper : component is "black_box";
  attribute box_type of opb_intc_i_wrapper : component is "black_box";
  attribute box_type of rs232_1_wrapper : component is "black_box";
  attribute box_type of opbslave_ext_bridge_i_wrapper : component is "black_box";
  attribute box_type of plb_psb_bridge_i_wrapper : component is "black_box";
  attribute box_type of dcr_bus_wrapper : component is "black_box";
  attribute box_type of ppc405_ppcjtag_chain_wrapper : component is "black_box";
  attribute box_type of jtagppc_0_wrapper : component is "black_box";
  attribute box_type of plb_emc_0_wrapper : component is "black_box";
  attribute box_type of opb_gpio_0_wrapper : component is "black_box";
  attribute box_type of opb_timer_0_wrapper : component is "black_box";
  attribute box_type of hwrtos_0_wrapper : component is "black_box";

begin

  -- Internal assignments

  plb_bus_PLB2OPB_rearb(0 to 0) <= B"0";
  plb_bus_PLB2OPB_rearb(1 to 1) <= B"0";
  plb_bus_PLB2OPB_rearb(3 to 3) <= B"0";
  plb_bus_PLB2OPB_rearb(4 to 4) <= B"0";
  plb_bus_PLB2OPB_rearb(5 to 5) <= B"0";
  pgassign1(20) <= int21;
  pgassign1(19) <= int20;
  pgassign1(18) <= int19;
  pgassign1(17) <= int18;
  pgassign1(16) <= int17;
  pgassign1(15) <= int16;
  pgassign1(14) <= int15;
  pgassign1(13) <= int14;
  pgassign1(12) <= int13;
  pgassign1(11) <= int12;
  pgassign1(10) <= int11;
  pgassign1(9) <= int10;
  pgassign1(8) <= int9;
  pgassign1(7) <= int8;
  pgassign1(6) <= int6;
  pgassign1(5) <= int5;
  pgassign1(4) <= int4;
  pgassign1(3) <= int3;
  pgassign1(2) <= int2;
  pgassign1(1) <= int1;
  pgassign1(0) <= int0;
  pgassign2(0) <= fpga_test_switch_7;
  pgassign2(1) <= fpga_test_switch_6;
  pgassign2(2) <= fpga_test_switch_5;
  pgassign2(3) <= fpga_test_switch_4;
  pgassign2(4) <= fpga_test_switch_3;
  pgassign2(5) <= fpga_test_switch_2;
  pgassign2(6) <= fpga_test_switch_1;
  pgassign2(7) <= fpga_test_switch_0;
  net_gnd0 <= '0';
  ExternalPort_0 <= net_gnd0;
  net_gnd1(0 to 0) <= B"0";
  net_gnd2(0 to 1) <= B"00";
  net_gnd30(29 downto 0) <= B"000000000000000000000000000000";
  net_gnd32(0 to 31) <= B"00000000000000000000000000000000";
  net_gnd4(0 to 3) <= B"0000";
  net_gnd5(0 to 4) <= B"00000";
  net_gnd64(0 to 63) <= B"0000000000000000000000000000000000000000000000000000000000000000";
  net_gnd8(0 to 7) <= B"00000000";
  net_vcc0 <= '1';
  net_vcc1(0 to 0) <= B"1";
  net_vcc5(0 to 4) <= B"11111";

  clock_reset_block : clock_reset_block_wrapper
    port map (
      fpga_plb_clk => fpga_plb_clk,
      fpga_opb_clk => fpga_opb_clk,
      ddr_clk_fb => ddr1_clk_fb,
      async_fpga_rst_n => fpga_rst_n,
      CLKPLB => CLKPLB,
      CLKOPB => CLKOPB,
      CLKCPU => CLKCPU,
      DDR_CLKPLB_90 => DDR_CLKPLB_90,
      DDR_CLKFB_90 => DDR1_CLKFB_90,
      RSTPLB => RSTPLB,
      RSTOPB => RSTOPB,
      RSTCPU => RSTCPU
    );

  ppc405_i : ppc405_i_wrapper
    port map (
      C405CPMCORESLEEPREQ => open,
      C405CPMMSRCE => open,
      C405CPMMSREE => open,
      C405CPMTIMERIRQ => open,
      C405CPMTIMERRESETREQ => open,
      C405XXXMACHINECHECK => open,
      CPMC405CLOCK => CLKCPU,
      CPMC405CORECLKINACTIVE => net_gnd0,
      CPMC405CPUCLKEN => net_vcc0,
      CPMC405JTAGCLKEN => net_vcc0,
      CPMC405TIMERCLKEN => net_vcc0,
      CPMC405TIMERTICK => net_vcc0,
      MCBCPUCLKEN => net_vcc0,
      MCBTIMEREN => net_vcc0,
      MCPPCRST => net_vcc0,
      PLBCLK => CLKPLB,
      DCRCLK => net_gnd0,
      C405RSTCHIPRESETREQ => open,
      C405RSTCORERESETREQ => open,
      C405RSTSYSRESETREQ => open,
      RSTC405RESETCHIP => RSTCPU,
      RSTC405RESETCORE => RSTCPU,
      RSTC405RESETSYS => RSTCPU,
      C405PLBICUABUS => plb_bus_M_ABus(32 to 63),
      C405PLBICUBE => plb_bus_M_BE(8 to 15),
      C405PLBICURNW => plb_bus_M_RNW(1),
      C405PLBICUABORT => plb_bus_M_abort(1),
      C405PLBICUBUSLOCK => plb_bus_M_busLock(1),
      C405PLBICUU0ATTR => plb_bus_M_compress(1),
      C405PLBICUGUARDED => plb_bus_M_guarded(1),
      C405PLBICULOCKERR => plb_bus_M_lockErr(1),
      C405PLBICUMSIZE => plb_bus_M_MSize(2 to 3),
      C405PLBICUORDERED => plb_bus_M_ordered(1),
      C405PLBICUPRIORITY => plb_bus_M_priority(2 to 3),
      C405PLBICURDBURST => plb_bus_M_rdBurst(1),
      C405PLBICUREQUEST => plb_bus_M_request(1),
      C405PLBICUSIZE => plb_bus_M_size(4 to 7),
      C405PLBICUTYPE => plb_bus_M_type(3 to 5),
      C405PLBICUWRBURST => plb_bus_M_wrBurst(1),
      C405PLBICUWRDBUS => plb_bus_M_wrDBus(64 to 127),
      C405PLBICUCACHEABLE => open,
      PLBC405ICUADDRACK => plb_bus_PLB_MAddrAck(1),
      PLBC405ICUBUSY => plb_bus_PLB_MBusy(1),
      PLBC405ICUERR => plb_bus_PLB_MErr(1),
      PLBC405ICURDBTERM => plb_bus_PLB_MRdBTerm(1),
      PLBC405ICURDDACK => plb_bus_PLB_MRdDAck(1),
      PLBC405ICURDDBUS => plb_bus_PLB_MRdDBus(64 to 127),
      PLBC405ICURDWDADDR => plb_bus_PLB_MRdWdAddr(4 to 7),
      PLBC405ICUREARBITRATE => plb_bus_PLB_MRearbitrate(1),
      PLBC405ICUWRBTERM => plb_bus_PLB_MWrBTerm(1),
      PLBC405ICUWRDACK => plb_bus_PLB_MWrDAck(1),
      PLBC405ICUSSIZE => plb_bus_PLB_MSSize(2 to 3),
      PLBC405ICUSERR => plb_bus_PLB_SMErr(1),
      PLBC405ICUSBUSYS => plb_bus_PLB_SMBusy(1),
      C405PLBDCUABUS => plb_bus_M_ABus(0 to 31),
      C405PLBDCUBE => plb_bus_M_BE(0 to 7),
      C405PLBDCURNW => plb_bus_M_RNW(0),
      C405PLBDCUABORT => plb_bus_M_abort(0),
      C405PLBDCUBUSLOCK => plb_bus_M_busLock(0),
      C405PLBDCUU0ATTR => plb_bus_M_compress(0),
      C405PLBDCUGUARDED => plb_bus_M_guarded(0),
      C405PLBDCULOCKERR => plb_bus_M_lockErr(0),
      C405PLBDCUMSIZE => plb_bus_M_MSize(0 to 1),
      C405PLBDCUORDERED => plb_bus_M_ordered(0),
      C405PLBDCUPRIORITY => plb_bus_M_priority(0 to 1),
      C405PLBDCURDBURST => plb_bus_M_rdBurst(0),
      C405PLBDCUREQUEST => plb_bus_M_request(0),
      C405PLBDCUSIZE => plb_bus_M_size(0 to 3),
      C405PLBDCUTYPE => plb_bus_M_type(0 to 2),
      C405PLBDCUWRBURST => plb_bus_M_wrBurst(0),
      C405PLBDCUWRDBUS => plb_bus_M_wrDBus(0 to 63),
      C405PLBDCUCACHEABLE => open,
      C405PLBDCUWRITETHRU => open,
      PLBC405DCUADDRACK => plb_bus_PLB_MAddrAck(0),
      PLBC405DCUBUSY => plb_bus_PLB_MBusy(0),
      PLBC405DCUERR => plb_bus_PLB_MErr(0),
      PLBC405DCURDBTERM => plb_bus_PLB_MRdBTerm(0),
      PLBC405DCURDDACK => plb_bus_PLB_MRdDAck(0),
      PLBC405DCURDDBUS => plb_bus_PLB_MRdDBus(0 to 63),
      PLBC405DCURDWDADDR => plb_bus_PLB_MRdWdAddr(0 to 3),
      PLBC405DCUREARBITRATE => plb_bus_PLB_MRearbitrate(0),
      PLBC405DCUWRBTERM => plb_bus_PLB_MWrBTerm(0),
      PLBC405DCUWRDACK => plb_bus_PLB_MWrDAck(0),
      PLBC405DCUSSIZE => plb_bus_PLB_MSSize(0 to 1),
      PLBC405DCUSERR => plb_bus_PLB_SMErr(0),
      PLBC405DCUSBUSYS => plb_bus_PLB_SMBusy(0),
      BRAMDSOCMCLK => net_gnd0,
      BRAMDSOCMRDDBUS => net_gnd32,
      DSARCVALUE => net_gnd8,
      DSCNTLVALUE => net_gnd8,
      DSOCMBRAMABUS => open,
      DSOCMBRAMBYTEWRITE => open,
      DSOCMBRAMEN => open,
      DSOCMBRAMWRDBUS => open,
      DSOCMBUSY => open,
      BRAMISOCMCLK => net_gnd0,
      BRAMISOCMRDDBUS => net_gnd64,
      ISARCVALUE => net_gnd8,
      ISCNTLVALUE => net_gnd8,
      ISOCMBRAMEN => open,
      ISOCMBRAMEVENWRITEEN => open,
      ISOCMBRAMODDWRITEEN => open,
      ISOCMBRAMRDABUS => open,
      ISOCMBRAMWRABUS => open,
      ISOCMBRAMWRDBUS => open,
      C405DCRABUS => dcr_bus_M_dcrABus,
      C405DCRDBUSOUT => dcr_bus_M_dcrDBus,
      C405DCRREAD => dcr_bus_M_dcrRead,
      C405DCRWRITE => dcr_bus_M_dcrWrite,
      DCRC405ACK => dcr_bus_DCR_Ack,
      DCRC405DBUSIN => dcr_bus_DCR_M_DBus,
      EICC405CRITINPUTIRQ => net_gnd0,
      EICC405EXTINPUTIRQ => Irq,
      C405JTGCAPTUREDR => open,
      C405JTGEXTEST => open,
      C405JTGPGMOUT => open,
      C405JTGSHIFTDR => open,
      C405JTGTDO => jtagppc0_C405JTGTDO,
      C405JTGTDOEN => jtagppc0_C405JTGTDOEN,
      C405JTGUPDATEDR => open,
      MCBJTAGEN => net_vcc0,
      JTGC405BNDSCANTDO => net_gnd0,
      JTGC405TCK => jtagppc0_JTGC405TCK,
      JTGC405TDI => jtagppc0_JTGC405TDI,
      JTGC405TMS => jtagppc0_JTGC405TMS,
      JTGC405TRSTNEG => jtagppc0_JTGC405TRSTNEG,
      C405DBGMSRWE => open,
      C405DBGSTOPACK => open,
      C405DBGWBCOMPLETE => open,
      C405DBGWBFULL => open,
      C405DBGWBIAR => open,
      DBGC405DEBUGHALT => net_gnd0,
      DBGC405EXTBUSHOLDACK => net_gnd0,
      DBGC405UNCONDDEBUGEVENT => net_gnd0,
      C405TRCCYCLE => open,
      C405TRCEVENEXECUTIONSTATUS => open,
      C405TRCODDEXECUTIONSTATUS => open,
      C405TRCTRACESTATUS => open,
      C405TRCTRIGGEREVENTOUT => open,
      C405TRCTRIGGEREVENTTYPE => open,
      TRCC405TRACEDISABLE => net_gnd0,
      TRCC405TRIGGEREVENTIN => net_gnd0
    );

  plb_bus : plb_bus_wrapper
    port map (
      PLB_Clk => CLKPLB,
      SYS_Rst => RSTPLB,
      PLB_Rst => plb_bus_PLB_Rst,
      PLB_dcrAck => dcr_bus_Sl_dcrAck(0),
      PLB_dcrDBus => dcr_bus_Sl_dcrDBus(0 to 31),
      DCR_ABus => dcr_bus_DCR_ABus(0 to 9),
      DCR_DBus => dcr_bus_DCR_Sl_DBus(0 to 31),
      DCR_Read => dcr_bus_DCR_Read(0),
      DCR_Write => dcr_bus_DCR_Write(0),
      M_ABus => plb_bus_M_ABus,
      M_BE => plb_bus_M_BE,
      M_RNW => plb_bus_M_RNW,
      M_abort => plb_bus_M_abort,
      M_busLock => plb_bus_M_busLock,
      M_compress => plb_bus_M_compress,
      M_guarded => plb_bus_M_guarded,
      M_lockErr => plb_bus_M_lockErr,
      M_MSize => plb_bus_M_MSize,
      M_ordered => plb_bus_M_ordered,
      M_priority => plb_bus_M_priority,
      M_rdBurst => plb_bus_M_rdBurst,
      M_request => plb_bus_M_request,
      M_size => plb_bus_M_size,
      M_type => plb_bus_M_type,
      M_wrBurst => plb_bus_M_wrBurst,
      M_wrDBus => plb_bus_M_wrDBus,
      Sl_addrAck => plb_bus_Sl_addrAck,
      Sl_MErr => plb_bus_Sl_MErr,
      Sl_MBusy => plb_bus_Sl_MBusy,
      Sl_rdBTerm => plb_bus_Sl_rdBTerm,
      Sl_rdComp => plb_bus_Sl_rdComp,
      Sl_rdDAck => plb_bus_Sl_rdDAck,
      Sl_rdDBus => plb_bus_Sl_rdDBus,
      Sl_rdWdAddr => plb_bus_Sl_rdWdAddr,
      Sl_rearbitrate => plb_bus_Sl_rearbitrate,
      Sl_SSize => plb_bus_Sl_SSize,
      Sl_wait => plb_bus_Sl_wait,
      Sl_wrBTerm => plb_bus_Sl_wrBTerm,
      Sl_wrComp => plb_bus_Sl_wrComp,
      Sl_wrDAck => plb_bus_Sl_wrDAck,
      PLB_ABus => plb_bus_PLB_ABus,
      PLB_BE => plb_bus_PLB_BE,
      PLB_MAddrAck => plb_bus_PLB_MAddrAck,
      PLB_MBusy => plb_bus_PLB_MBusy,
      PLB_MErr => plb_bus_PLB_MErr,
      PLB_MRdBTerm => plb_bus_PLB_MRdBTerm,
      PLB_MRdDAck => plb_bus_PLB_MRdDAck,
      PLB_MRdDBus => plb_bus_PLB_MRdDBus,
      PLB_MRdWdAddr => plb_bus_PLB_MRdWdAddr,
      PLB_MRearbitrate => plb_bus_PLB_MRearbitrate,
      PLB_MWrBTerm => plb_bus_PLB_MWrBTerm,
      PLB_MWrDAck => plb_bus_PLB_MWrDAck,
      PLB_MSSize => plb_bus_PLB_MSSize,
      PLB_PAValid => plb_bus_PLB_PAValid,
      PLB_RNW => plb_bus_PLB_RNW,
      PLB_SAValid => plb_bus_PLB_SAValid,
      PLB_abort => plb_bus_PLB_abort,
      PLB_busLock => plb_bus_PLB_busLock,
      PLB_compress => plb_bus_PLB_compress,
      PLB_guarded => plb_bus_PLB_guarded,
      PLB_lockErr => plb_bus_PLB_lockErr,
      PLB_masterID => plb_bus_PLB_masterID,
      PLB_MSize => plb_bus_PLB_MSize,
      PLB_ordered => plb_bus_PLB_ordered,
      PLB_pendPri => plb_bus_PLB_pendPri,
      PLB_pendReq => plb_bus_PLB_pendReq,
      PLB_rdBurst => plb_bus_PLB_rdBurst,
      PLB_rdPrim => plb_bus_PLB_rdPrim,
      PLB_reqPri => plb_bus_PLB_reqPri,
      PLB_size => plb_bus_PLB_size,
      PLB_type => plb_bus_PLB_type,
      PLB_wrBurst => plb_bus_PLB_wrBurst,
      PLB_wrDBus => plb_bus_PLB_wrDBus,
      PLB_wrPrim => plb_bus_PLB_wrPrim,
      PLB_SaddrAck => open,
      PLB_SMErr => plb_bus_PLB_SMErr,
      PLB_SMBusy => plb_bus_PLB_SMBusy,
      PLB_SrdBTerm => open,
      PLB_SrdComp => open,
      PLB_SrdDAck => open,
      PLB_SrdDBus => open,
      PLB_SrdWdAddr => open,
      PLB_Srearbitrate => open,
      PLB_Sssize => open,
      PLB_Swait => open,
      PLB_SwrBTerm => open,
      PLB_SwrComp => open,
      PLB_SwrDAck => open,
      PLB2OPB_rearb => plb_bus_PLB2OPB_rearb,
      ArbAddrVldReg => open,
      Bus_Error_Det => open
    );

  plb_ddr_controller_i : plb_ddr_controller_i_wrapper
    port map (
      PLB_ABus => plb_bus_PLB_ABus,
      PLB_PAValid => plb_bus_PLB_PAValid,
      PLB_SAValid => plb_bus_PLB_SAValid,
      PLB_rdPrim => plb_bus_PLB_rdPrim,
      PLB_wrPrim => plb_bus_PLB_wrPrim,
      PLB_masterID => plb_bus_PLB_masterID,
      PLB_abort => plb_bus_PLB_abort,
      PLB_busLock => plb_bus_PLB_busLock,
      PLB_RNW => plb_bus_PLB_RNW,
      PLB_BE => plb_bus_PLB_BE,
      PLB_MSize => plb_bus_PLB_MSize,
      PLB_size => plb_bus_PLB_size,
      PLB_type => plb_bus_PLB_type,
      PLB_compress => plb_bus_PLB_compress,
      PLB_guarded => plb_bus_PLB_guarded,
      PLB_ordered => plb_bus_PLB_ordered,
      PLB_lockErr => plb_bus_PLB_lockErr,
      PLB_wrDBus => plb_bus_PLB_wrDBus,
      PLB_wrBurst => plb_bus_PLB_wrBurst,
      PLB_rdBurst => plb_bus_PLB_rdBurst,
      PLB_pendReq => plb_bus_PLB_pendReq,
      PLB_pendPri => plb_bus_PLB_pendPri,
      PLB_reqPri => plb_bus_PLB_reqPri,
      Sl_addrAck => plb_bus_Sl_addrAck(0),
      Sl_SSize => plb_bus_Sl_SSize(0 to 1),
      Sl_wait => plb_bus_Sl_wait(0),
      Sl_rearbitrate => plb_bus_Sl_rearbitrate(0),
      Sl_wrDAck => plb_bus_Sl_wrDAck(0),
      Sl_wrComp => plb_bus_Sl_wrComp(0),
      Sl_wrBTerm => plb_bus_Sl_wrBTerm(0),
      Sl_rdDBus => plb_bus_Sl_rdDBus(0 to 63),
      Sl_rdWdAddr => plb_bus_Sl_rdWdAddr(0 to 3),
      Sl_rdDAck => plb_bus_Sl_rdDAck(0),
      Sl_rdComp => plb_bus_Sl_rdComp(0),
      Sl_rdBTerm => plb_bus_Sl_rdBTerm(0),
      Sl_MBusy => plb_bus_Sl_MBusy(0 to 3),
      Sl_MErr => plb_bus_Sl_MErr(0 to 3),
      DDR_Clk => ddr1_clk,
      DDR_Clkn => ddr1_clk_n,
      DDR_CKE => ddr1_cke,
      DDR_CSn => ddr1_cs_n,
      DDR_RASn => ddr1_ras_n,
      DDR_CASn => ddr1_cas_n,
      DDR_WEn => ddr1_we_n,
      DDR_DM => ddr1_dm(3 downto 0),
      DDR_BankAddr => ddr1_ba,
      DDR_Addr => ddr1_addr,
      DDR_Init_done => open,
      PLB_Clk => CLKPLB,
      Clk90_in => DDR_CLKPLB_90,
      DDR_Clk90_in => DDR1_CLKFB_90,
      PLB_Rst => plb_bus_PLB_Rst,
      DDR_DQ_I => ddr1_dq_I(31 downto 0),
      DDR_DQ_O => ddr1_dq_O(31 downto 0),
      DDR_DQ_T => ddr1_dq_T(31 downto 0),
      DDR_DQS_I => ddr1_dqs_I(3 downto 0),
      DDR_DQS_O => ddr1_dqs_O(3 downto 0),
      DDR_DQS_T => ddr1_dqs_T(3 downto 0)
    );

  plb_bram_if_cntlr_i : plb_bram_if_cntlr_i_wrapper
    port map (
      plb_clk => CLKPLB,
      plb_rst => plb_bus_PLB_Rst,
      plb_abort => plb_bus_PLB_abort,
      plb_abus => plb_bus_PLB_ABus,
      plb_be => plb_bus_PLB_BE,
      plb_buslock => plb_bus_PLB_busLock,
      plb_compress => plb_bus_PLB_compress,
      plb_guarded => plb_bus_PLB_guarded,
      plb_lockerr => plb_bus_PLB_lockErr,
      plb_masterid => plb_bus_PLB_masterID,
      plb_msize => plb_bus_PLB_MSize,
      plb_ordered => plb_bus_PLB_ordered,
      plb_pavalid => plb_bus_PLB_PAValid,
      plb_rnw => plb_bus_PLB_RNW,
      plb_size => plb_bus_PLB_size,
      plb_type => plb_bus_PLB_type,
      sl_addrack => plb_bus_Sl_addrAck(1),
      sl_mbusy => plb_bus_Sl_MBusy(4 to 7),
      sl_merr => plb_bus_Sl_MErr(4 to 7),
      sl_rearbitrate => plb_bus_Sl_rearbitrate(1),
      sl_ssize => plb_bus_Sl_SSize(2 to 3),
      sl_wait => plb_bus_Sl_wait(1),
      plb_rdprim => plb_bus_PLB_rdPrim,
      plb_savalid => plb_bus_PLB_SAValid,
      plb_wrprim => plb_bus_PLB_wrPrim,
      plb_wrburst => plb_bus_PLB_wrBurst,
      plb_wrdbus => plb_bus_PLB_wrDBus,
      sl_wrbterm => plb_bus_Sl_wrBTerm(1),
      sl_wrcomp => plb_bus_Sl_wrComp(1),
      sl_wrdack => plb_bus_Sl_wrDAck(1),
      plb_rdburst => plb_bus_PLB_rdBurst,
      sl_rdbterm => plb_bus_Sl_rdBTerm(1),
      sl_rdcomp => plb_bus_Sl_rdComp(1),
      sl_rddack => plb_bus_Sl_rdDAck(1),
      sl_rddbus => plb_bus_Sl_rdDBus(64 to 127),
      sl_rdwdaddr => plb_bus_Sl_rdWdAddr(4 to 7),
      plb_pendreq => plb_bus_PLB_pendReq,
      plb_pendpri => plb_bus_PLB_pendPri,
      plb_reqpri => plb_bus_PLB_reqPri,
      bram_rst => porta_BRAM_Rst,
      bram_clk => porta_BRAM_Clk,
      bram_en => porta_BRAM_EN,
      bram_wen => porta_BRAM_WEN,
      bram_addr => porta_BRAM_Addr,
      bram_din => porta_BRAM_Din,
      bram_dout => porta_BRAM_Dout
    );

  bram : bram_wrapper
    port map (
      BRAM_Rst_A => porta_BRAM_Rst,
      BRAM_Clk_A => porta_BRAM_Clk,
      BRAM_EN_A => porta_BRAM_EN,
      BRAM_WEN_A => porta_BRAM_WEN,
      BRAM_Addr_A => porta_BRAM_Addr,
      BRAM_Din_A => porta_BRAM_Din,
      BRAM_Dout_A => porta_BRAM_Dout,
      BRAM_Rst_B => net_gnd0,
      BRAM_Clk_B => net_gnd0,
      BRAM_EN_B => net_gnd0,
      BRAM_WEN_B => net_gnd8,
      BRAM_Addr_B => net_gnd32,
      BRAM_Din_B => open,
      BRAM_Dout_B => net_gnd64
    );

  plb2opb_bridge_i : plb2opb_bridge_i_wrapper
    port map (
      PLB_Clk => CLKPLB,
      OPB_Clk => CLKOPB,
      PLB_Rst => plb_bus_PLB_Rst,
      OPB_Rst => opb_bus_OPB_Rst,
      Bus_Error_Det => int6,
      BGI_Trans_Abort => open,
      BGO_dcrAck => dcr_bus_Sl_dcrAck(1),
      BGO_dcrDBus => dcr_bus_Sl_dcrDBus(32 to 63),
      DCR_ABus => dcr_bus_DCR_ABus(10 to 19),
      DCR_DBus => dcr_bus_DCR_Sl_DBus(32 to 63),
      DCR_Read => dcr_bus_DCR_Read(1),
      DCR_Write => dcr_bus_DCR_Write(1),
      BGO_addrAck => plb_bus_Sl_addrAck(2),
      BGO_MErr => plb_bus_Sl_MErr(8 to 11),
      BGO_MBusy => plb_bus_Sl_MBusy(8 to 11),
      BGO_rdBTerm => plb_bus_Sl_rdBTerm(2),
      BGO_rdComp => plb_bus_Sl_rdComp(2),
      BGO_rdDAck => plb_bus_Sl_rdDAck(2),
      BGO_rdDBus => plb_bus_Sl_rdDBus(128 to 191),
      BGO_rdWdAddr => plb_bus_Sl_rdWdAddr(8 to 11),
      BGO_rearbitrate => plb_bus_Sl_rearbitrate(2),
      BGO_SSize => plb_bus_Sl_SSize(4 to 5),
      BGO_wait => plb_bus_Sl_wait(2),
      BGO_wrBTerm => plb_bus_Sl_wrBTerm(2),
      BGO_wrComp => plb_bus_Sl_wrComp(2),
      BGO_wrDAck => plb_bus_Sl_wrDAck(2),
      PLB_abort => plb_bus_PLB_abort,
      PLB_ABus => plb_bus_PLB_ABus,
      PLB_BE => plb_bus_PLB_BE,
      PLB_busLock => plb_bus_PLB_busLock,
      PLB_compress => plb_bus_PLB_compress,
      PLB_guarded => plb_bus_PLB_guarded,
      PLB_lockErr => plb_bus_PLB_lockErr,
      PLB_masterID => plb_bus_PLB_masterID,
      PLB_MSize => plb_bus_PLB_MSize,
      PLB_ordered => plb_bus_PLB_ordered,
      PLB_PAValid => plb_bus_PLB_PAValid,
      PLB_rdBurst => plb_bus_PLB_rdBurst,
      PLB_rdPrim => plb_bus_PLB_rdPrim,
      PLB_RNW => plb_bus_PLB_RNW,
      PLB_SAValid => plb_bus_PLB_SAValid,
      PLB_size => plb_bus_PLB_size,
      PLB_type => plb_bus_PLB_type,
      PLB_wrBurst => plb_bus_PLB_wrBurst,
      PLB_wrDBus => plb_bus_PLB_wrDBus,
      PLB_wrPrim => plb_bus_PLB_wrPrim,
      PLB2OPB_rearb => plb_bus_PLB2OPB_rearb(2),
      BGO_ABus => opb_bus_M_ABus,
      BGO_BE => opb_bus_M_BE,
      BGO_busLock => opb_bus_M_busLock(0),
      BGO_DBus => opb_bus_M_DBus,
      BGO_request => opb_bus_M_request(0),
      BGO_RNW => opb_bus_M_RNW(0),
      BGO_select => opb_bus_M_select(0),
      BGO_seqAddr => opb_bus_M_seqAddr(0),
      OPB_DBus => opb_bus_OPB_DBus,
      OPB_errAck => opb_bus_OPB_errAck,
      OPB_MnGrant => opb_bus_OPB_MGrant(0),
      OPB_retry => opb_bus_OPB_retry,
      OPB_timeout => opb_bus_OPB_timeout,
      OPB_xferAck => opb_bus_OPB_xferAck
    );

  opb_bus : opb_bus_wrapper
    port map (
      OPB_Clk => CLKOPB,
      OPB_Rst => opb_bus_OPB_Rst,
      SYS_Rst => RSTOPB,
      Debug_SYS_Rst => net_gnd0,
      WDT_Rst => net_gnd0,
      M_ABus => opb_bus_M_ABus,
      M_BE => opb_bus_M_BE,
      M_beXfer => net_gnd1(0 to 0),
      M_busLock => opb_bus_M_busLock(0 to 0),
      M_DBus => opb_bus_M_DBus,
      M_DBusEn => net_gnd1(0 to 0),
      M_DBusEn32_63 => net_vcc1(0 to 0),
      M_dwXfer => net_gnd1(0 to 0),
      M_fwXfer => net_gnd1(0 to 0),
      M_hwXfer => net_gnd1(0 to 0),
      M_request => opb_bus_M_request(0 to 0),
      M_RNW => opb_bus_M_RNW(0 to 0),
      M_select => opb_bus_M_select(0 to 0),
      M_seqAddr => opb_bus_M_seqAddr(0 to 0),
      Sl_beAck => net_gnd5,
      Sl_DBus => opb_bus_Sl_DBus,
      Sl_DBusEn => net_vcc5,
      Sl_DBusEn32_63 => net_vcc5,
      Sl_errAck => opb_bus_Sl_errAck,
      Sl_dwAck => net_gnd5,
      Sl_fwAck => net_gnd5,
      Sl_hwAck => net_gnd5,
      Sl_retry => opb_bus_Sl_retry,
      Sl_toutSup => opb_bus_Sl_toutSup,
      Sl_xferAck => opb_bus_Sl_xferAck,
      OPB_MRequest => open,
      OPB_ABus => opb_bus_OPB_ABus,
      OPB_BE => opb_bus_OPB_BE,
      OPB_beXfer => open,
      OPB_beAck => open,
      OPB_busLock => open,
      OPB_rdDBus => open,
      OPB_wrDBus => open,
      OPB_DBus => opb_bus_OPB_DBus,
      OPB_errAck => opb_bus_OPB_errAck,
      OPB_dwAck => open,
      OPB_dwXfer => open,
      OPB_fwAck => open,
      OPB_fwXfer => open,
      OPB_hwAck => open,
      OPB_hwXfer => open,
      OPB_MGrant => opb_bus_OPB_MGrant(0 to 0),
      OPB_pendReq => open,
      OPB_retry => opb_bus_OPB_retry,
      OPB_RNW => opb_bus_OPB_RNW,
      OPB_select => opb_bus_OPB_select,
      OPB_seqAddr => opb_bus_OPB_seqAddr,
      OPB_timeout => opb_bus_OPB_timeout,
      OPB_toutSup => open,
      OPB_xferAck => opb_bus_OPB_xferAck
    );

  ap1000_interrupt_interface_i : ap1000_interrupt_interface_i_wrapper
    port map (
      EXT_sysace_irq => sysace_irq,
      PMC_inta_n => pmc_inta_n,
      PMC_intb_n => pmc_intb_n,
      PMC_intc_n => pmc_intc_n,
      PMC_intd_n => pmc_intd_n,
      PS2_int0_n => ps2_int0_n,
      PS2_int1_n => ps2_int1_n,
      PS2_int2_n => ps2_int2_n,
      PS2_int3_n => ps2_int3_n,
      PS2_int4_n => ps2_int4_n,
      PS2_int5_n => ps2_int5_n,
      EXT_sysace_irq_internal => int0,
      PMC_inta_n_internal => int3,
      PMC_intb_n_internal => int2,
      PMC_intc_n_internal => int1,
      PMC_intd_n_internal => int13,
      PS2_int0_n_internal => int16,
      PS2_int1_n_internal => int17,
      PS2_int2_n_internal => int18,
      PS2_int3_n_internal => int19,
      PS2_int4_n_internal => int20,
      PS2_int5_n_internal => int21,
      dummy1_interrupt => int4,
      dummy2_interrupt => int5,
      dummy3_interrupt => int8,
      dummy4_interrupt => int9,
      dummy5_interrupt => int10,
      dummy6_interrupt => int11,
      dummy7_interrupt => int12,
      dummy8_interrupt => int14,
      dummy9_interrupt => int15,
      dummy10_interrupt => open,
      dummy11_interrupt => open,
      dummy12_interrupt => open
    );

  opb_intc_i : opb_intc_i_wrapper
    port map (
      OPB_Clk => CLKOPB,
      Intr => pgassign1,
      OPB_Rst => opb_bus_OPB_Rst,
      OPB_ABus => opb_bus_OPB_ABus,
      OPB_BE => opb_bus_OPB_BE,
      OPB_RNW => opb_bus_OPB_RNW,
      OPB_select => opb_bus_OPB_select,
      OPB_seqAddr => opb_bus_OPB_seqAddr,
      OPB_DBus => opb_bus_OPB_DBus,
      IntC_DBus => opb_bus_Sl_DBus(0 to 31),
      IntC_errAck => opb_bus_Sl_errAck(0),
      IntC_retry => opb_bus_Sl_retry(0),
      IntC_toutSup => opb_bus_Sl_toutSup(0),
      IntC_xferAck => opb_bus_Sl_xferAck(0),
      Irq => Irq
    );

  rs232_1 : rs232_1_wrapper
    port map (
      OPB_Clk => CLKOPB,
      OPB_Rst => opb_bus_OPB_Rst,
      Interrupt => open,
      OPB_ABus => opb_bus_OPB_ABus,
      OPB_BE => opb_bus_OPB_BE,
      OPB_RNW => opb_bus_OPB_RNW,
      OPB_select => opb_bus_OPB_select,
      OPB_seqAddr => opb_bus_OPB_seqAddr,
      OPB_DBus => opb_bus_OPB_DBus,
      UART_DBus => opb_bus_Sl_DBus(32 to 63),
      UART_errAck => opb_bus_Sl_errAck(1),
      UART_retry => opb_bus_Sl_retry(1),
      UART_toutSup => opb_bus_Sl_toutSup(1),
      UART_xferAck => opb_bus_Sl_xferAck(1),
      RX => uart1_sin,
      TX => uart1_sout
    );

  opbslave_ext_bridge_i : opbslave_ext_bridge_i_wrapper
    port map (
      clk => CLKOPB,
      reset => opb_bus_OPB_Rst,
      opb_abus => opb_bus_OPB_ABus,
      opb_be => opb_bus_OPB_BE,
      opb_rnw => opb_bus_OPB_RNW,
      opb_select => opb_bus_OPB_select,
      opb_seqAddr => opb_bus_OPB_seqAddr,
      opb_dbusm => opb_bus_OPB_DBus,
      sl_dbus => opb_bus_Sl_DBus(64 to 95),
      sl_errack => opb_bus_Sl_errAck(2),
      sl_retry => opb_bus_Sl_retry(2),
      sl_toutsup => opb_bus_Sl_toutSup(2),
      sl_xferack => opb_bus_Sl_xferAck(2),
      fpga_test_switch => pgassign2,
      fpga_test_led => open,
      fpga_therm => fpga_therm,
      EXT_cpld_br_n => cpld_br_n,
      EXT_cpld_bg_n => cpld_bg_n,
      EXT_cpld_cs_n => cpld_cs_n,
      EXT_flash_cs_n => flash_cs_n,
      EXT_sysace_cs_n => sysace_cs_n,
      RSTCPU1 => net_gnd0,
      RSTCPU2 => net_gnd0,
      ppc1_sw_reset => open,
      ppc2_sw_reset => open,
      opb_ext_bridge_debug_bus => open,
      EXT_data_I => lbus_data_I,
      EXT_data_O => lbus_data_O,
      EXT_data_T => lbus_data_T,
      EXT_addr_I => lbus_addr_I,
      EXT_addr_O => lbus_addr_O,
      EXT_addr_T => lbus_addr_T,
      EXT_we_n_I => lbus_we_n_I,
      EXT_we_n_O => lbus_we_n_O,
      EXT_we_n_T => lbus_we_n_T,
      EXT_con_flash_cs_n_I => con_flash_cs_n_I,
      EXT_con_flash_cs_n_O => con_flash_cs_n_O,
      EXT_con_flash_cs_n_T => con_flash_cs_n_T,
      EXT_oe_n_I => lbus_oe_n_I,
      EXT_oe_n_O => lbus_oe_n_O,
      EXT_oe_n_T => lbus_oe_n_T
    );

  plb_psb_bridge_i : plb_psb_bridge_i_wrapper
    port map (
      debug_bus => open,
      clk => CLKPLB,
      reset => plb_bus_PLB_Rst,
      PLBma_RdWdAddr => plb_bus_PLB_MRdWdAddr(8 to 11),
      PLBma_RdDBus => plb_bus_PLB_MRdDBus(128 to 191),
      PLBma_AddrAck => plb_bus_PLB_MAddrAck(2),
      PLBma_RdDAck => plb_bus_PLB_MRdDAck(2),
      PLBma_WrDAck => plb_bus_PLB_MWrDAck(2),
      PLBma_rearbitrate => plb_bus_PLB_MRearbitrate(2),
      PLBma_Busy => plb_bus_PLB_MBusy(2),
      PLBma_Err => plb_bus_PLB_MErr(2),
      PLBma_RdBTerm => plb_bus_PLB_MRdBTerm(2),
      PLBma_WrBTerm => plb_bus_PLB_MWrBTerm(2),
      PLBma_sSize => plb_bus_PLB_MSSize(4 to 5),
      PLBma_pendReq => net_gnd0,
      PLBma_pendPri => net_gnd2,
      PLBma_reqPri => net_gnd2,
      BGIma_request => plb_bus_M_request(2),
      BGIma_ABus => plb_bus_M_ABus(64 to 95),
      BGIma_RNW => plb_bus_M_RNW(2),
      BGIma_BE => plb_bus_M_BE(16 to 23),
      BGIma_size => plb_bus_M_size(8 to 11),
      BGIma_type => plb_bus_M_type(6 to 8),
      BGIma_priority => plb_bus_M_priority(4 to 5),
      BGIma_rdBurst => plb_bus_M_rdBurst(2),
      BGIma_wrBurst => plb_bus_M_wrBurst(2),
      BGIma_busLock => plb_bus_M_busLock(2),
      BGIma_abort => plb_bus_M_abort(2),
      BGIma_lockErr => plb_bus_M_lockErr(2),
      BGIma_mSize => plb_bus_M_MSize(4 to 5),
      BGIma_ordered => plb_bus_M_ordered(2),
      BGIma_compress => plb_bus_M_compress(2),
      BGIma_guarded => plb_bus_M_guarded(2),
      BGIma_wrDBus => plb_bus_M_wrDBus(128 to 191),
      PLBsl_ABus => plb_bus_PLB_ABus,
      PLBsl_PAValid => plb_bus_PLB_PAValid,
      PLBsl_SAValid => plb_bus_PLB_SAValid,
      PLBsl_rdPrim => plb_bus_PLB_rdPrim,
      PLBsl_wrPrim => plb_bus_PLB_wrPrim,
      PLBsl_masterID => plb_bus_PLB_masterID,
      PLBsl_abort => plb_bus_PLB_abort,
      PLBsl_busLock => plb_bus_PLB_busLock,
      PLBsl_RNW => plb_bus_PLB_RNW,
      PLBsl_BE => plb_bus_PLB_BE,
      PLBsl_MSize => plb_bus_PLB_MSize,
      PLBsl_size => plb_bus_PLB_size,
      PLBsl_type => plb_bus_PLB_type,
      PLBsl_compress => plb_bus_PLB_compress,
      PLBsl_guarded => plb_bus_PLB_guarded,
      PLBsl_ordered => plb_bus_PLB_ordered,
      PLBsl_lockErr => plb_bus_PLB_lockErr,
      PLBsl_wrDBus => plb_bus_PLB_wrDBus,
      PLBsl_wrBurst => plb_bus_PLB_wrBurst,
      PLBsl_rdBurst => plb_bus_PLB_rdBurst,
      BGOsl_addrAck => plb_bus_Sl_addrAck(4),
      BGOsl_SSize => plb_bus_Sl_SSize(8 to 9),
      BGOsl_wait => plb_bus_Sl_wait(4),
      BGOsl_rearbitrate => plb_bus_Sl_rearbitrate(4),
      BGOsl_wrDAck => plb_bus_Sl_wrDAck(4),
      BGOsl_wrComp => plb_bus_Sl_wrComp(4),
      BGOsl_wrBTerm => plb_bus_Sl_wrBTerm(4),
      BGOsl_rdDBus => plb_bus_Sl_rdDBus(256 to 319),
      BGOsl_rdWdAddr => plb_bus_Sl_rdWdAddr(16 to 19),
      BGOsl_rdDAck => plb_bus_Sl_rdDAck(4),
      BGOsl_rdComp => plb_bus_Sl_rdComp(4),
      BGOsl_rdBTerm => plb_bus_Sl_rdBTerm(4),
      BGOsl_MBusy => plb_bus_Sl_MBusy(16 to 19),
      BGOsl_MErr => plb_bus_Sl_MErr(16 to 19),
      PSB_bg_n => psb_bg_n,
      PSB_br_n => psb_br_n,
      PSB_dbg_n => psb_dbg_n,
      ppc0_uart_to_reg_bus => net_gnd30,
      ppc0_reg_to_uart_bus => open,
      host0_uart_to_reg_bus => net_gnd30,
      host0_reg_to_uart_bus => open,
      ppc1_uart_to_reg_bus => net_gnd30,
      ppc1_reg_to_uart_bus => open,
      host1_uart_to_reg_bus => net_gnd30,
      host1_reg_to_uart_bus => open,
      PSB_a_I => psb_a_I,
      PSB_a_O => psb_a_O,
      PSB_a_T => psb_a_T,
      PSB_abb_n_I => psb_abb_n_I,
      PSB_abb_n_O => psb_abb_n_O,
      PSB_abb_n_T => psb_abb_n_T,
      PSB_dbb_n_I => psb_dbb_n_I,
      PSB_dbb_n_O => psb_dbb_n_O,
      PSB_dbb_n_T => psb_dbb_n_T,
      PSB_tbst_n_I => psb_tbst_n_I,
      PSB_tbst_n_O => psb_tbst_n_O,
      PSB_tbst_n_T => psb_tbst_n_T,
      PSB_tsiz_I => psb_tsiz_I,
      PSB_tsiz_O => psb_tsiz_O,
      PSB_tsiz_T => psb_tsiz_T,
      PSB_ts_n_I => psb_ts_n_I,
      PSB_ts_n_O => psb_ts_n_O,
      PSB_ts_n_T => psb_ts_n_T,
      PSB_tt_I => psb_tt_I,
      PSB_tt_O => psb_tt_O,
      PSB_tt_T => psb_tt_T,
      PSB_aack_n_I => psb_aack_n_I,
      PSB_aack_n_O => psb_aack_n_O,
      PSB_aack_n_T => psb_aack_n_T,
      PSB_artry_n_I => psb_artry_n_I,
      PSB_artry_n_O => psb_artry_n_O,
      PSB_artry_n_T => psb_artry_n_T,
      PSB_d_I => PSB_d_I,
      PSB_d_O => PSB_d_O,
      PSB_d_T => PSB_d_T,
      PSB_ta_n_I => psb_ta_n_I,
      PSB_ta_n_O => psb_ta_n_O,
      PSB_ta_n_T => psb_ta_n_T,
      PSB_tea_n_I => psb_tea_n_I,
      PSB_tea_n_O => psb_tea_n_O,
      PSB_tea_n_T => psb_tea_n_T
    );

  dcr_bus : dcr_bus_wrapper
    port map (
      M_dcrABus => dcr_bus_M_dcrABus,
      M_dcrDBus => dcr_bus_M_dcrDBus,
      M_dcrRead => dcr_bus_M_dcrRead,
      M_dcrWrite => dcr_bus_M_dcrWrite,
      DCR_M_DBus => dcr_bus_DCR_M_DBus,
      DCR_Ack => dcr_bus_DCR_Ack,
      DCR_ABus => dcr_bus_DCR_ABus,
      DCR_Sl_DBus => dcr_bus_DCR_Sl_DBus,
      DCR_Read => dcr_bus_DCR_Read,
      DCR_Write => dcr_bus_DCR_Write,
      Sl_dcrDBus => dcr_bus_Sl_dcrDBus,
      Sl_dcrAck => dcr_bus_Sl_dcrAck
    );

  ppc405_ppcjtag_chain : ppc405_ppcjtag_chain_wrapper
    port map (
      C405CPMCORESLEEPREQ => open,
      C405CPMMSRCE => open,
      C405CPMMSREE => open,
      C405CPMTIMERIRQ => open,
      C405CPMTIMERRESETREQ => open,
      C405XXXMACHINECHECK => open,
      CPMC405CLOCK => net_gnd0,
      CPMC405CORECLKINACTIVE => net_gnd0,
      CPMC405CPUCLKEN => net_vcc0,
      CPMC405JTAGCLKEN => net_vcc0,
      CPMC405TIMERCLKEN => net_vcc0,
      CPMC405TIMERTICK => net_vcc0,
      MCBCPUCLKEN => net_vcc0,
      MCBTIMEREN => net_vcc0,
      MCPPCRST => net_vcc0,
      PLBCLK => net_gnd0,
      DCRCLK => net_gnd0,
      C405RSTCHIPRESETREQ => open,
      C405RSTCORERESETREQ => open,
      C405RSTSYSRESETREQ => open,
      RSTC405RESETCHIP => net_gnd0,
      RSTC405RESETCORE => net_gnd0,
      RSTC405RESETSYS => net_gnd0,
      C405PLBICUABUS => open,
      C405PLBICUBE => open,
      C405PLBICURNW => open,
      C405PLBICUABORT => open,
      C405PLBICUBUSLOCK => open,
      C405PLBICUU0ATTR => open,
      C405PLBICUGUARDED => open,
      C405PLBICULOCKERR => open,
      C405PLBICUMSIZE => open,
      C405PLBICUORDERED => open,
      C405PLBICUPRIORITY => open,
      C405PLBICURDBURST => open,
      C405PLBICUREQUEST => open,
      C405PLBICUSIZE => open,
      C405PLBICUTYPE => open,
      C405PLBICUWRBURST => open,
      C405PLBICUWRDBUS => open,
      C405PLBICUCACHEABLE => open,
      PLBC405ICUADDRACK => net_gnd0,
      PLBC405ICUBUSY => net_gnd0,
      PLBC405ICUERR => net_gnd0,
      PLBC405ICURDBTERM => net_gnd0,
      PLBC405ICURDDACK => net_gnd0,
      PLBC405ICURDDBUS => net_gnd64,
      PLBC405ICURDWDADDR => net_gnd4,
      PLBC405ICUREARBITRATE => net_gnd0,
      PLBC405ICUWRBTERM => net_gnd0,
      PLBC405ICUWRDACK => net_gnd0,
      PLBC405ICUSSIZE => net_gnd2,
      PLBC405ICUSERR => net_gnd0,
      PLBC405ICUSBUSYS => net_gnd0,
      C405PLBDCUABUS => open,
      C405PLBDCUBE => open,
      C405PLBDCURNW => open,
      C405PLBDCUABORT => open,
      C405PLBDCUBUSLOCK => open,
      C405PLBDCUU0ATTR => open,
      C405PLBDCUGUARDED => open,
      C405PLBDCULOCKERR => open,
      C405PLBDCUMSIZE => open,
      C405PLBDCUORDERED => open,
      C405PLBDCUPRIORITY => open,
      C405PLBDCURDBURST => open,
      C405PLBDCUREQUEST => open,
      C405PLBDCUSIZE => open,
      C405PLBDCUTYPE => open,
      C405PLBDCUWRBURST => open,
      C405PLBDCUWRDBUS => open,
      C405PLBDCUCACHEABLE => open,
      C405PLBDCUWRITETHRU => open,
      PLBC405DCUADDRACK => net_gnd0,
      PLBC405DCUBUSY => net_gnd0,
      PLBC405DCUERR => net_gnd0,
      PLBC405DCURDBTERM => net_gnd0,
      PLBC405DCURDDACK => net_gnd0,
      PLBC405DCURDDBUS => net_gnd64,
      PLBC405DCURDWDADDR => net_gnd4,
      PLBC405DCUREARBITRATE => net_gnd0,
      PLBC405DCUWRBTERM => net_gnd0,
      PLBC405DCUWRDACK => net_gnd0,
      PLBC405DCUSSIZE => net_gnd2,
      PLBC405DCUSERR => net_gnd0,
      PLBC405DCUSBUSYS => net_gnd0,
      BRAMDSOCMCLK => net_gnd0,
      BRAMDSOCMRDDBUS => net_gnd32,
      DSARCVALUE => net_gnd8,
      DSCNTLVALUE => net_gnd8,
      DSOCMBRAMABUS => open,
      DSOCMBRAMBYTEWRITE => open,
      DSOCMBRAMEN => open,
      DSOCMBRAMWRDBUS => open,
      DSOCMBUSY => open,
      BRAMISOCMCLK => net_gnd0,
      BRAMISOCMRDDBUS => net_gnd64,
      ISARCVALUE => net_gnd8,
      ISCNTLVALUE => net_gnd8,
      ISOCMBRAMEN => open,
      ISOCMBRAMEVENWRITEEN => open,
      ISOCMBRAMODDWRITEEN => open,
      ISOCMBRAMRDABUS => open,
      ISOCMBRAMWRABUS => open,
      ISOCMBRAMWRDBUS => open,
      C405DCRABUS => open,
      C405DCRDBUSOUT => open,
      C405DCRREAD => open,
      C405DCRWRITE => open,
      DCRC405ACK => net_gnd0,
      DCRC405DBUSIN => net_gnd32,
      EICC405CRITINPUTIRQ => net_gnd0,
      EICC405EXTINPUTIRQ => net_gnd0,
      C405JTGCAPTUREDR => open,
      C405JTGEXTEST => open,
      C405JTGPGMOUT => open,
      C405JTGSHIFTDR => open,
      C405JTGTDO => jtagppc1_C405JTGTDO,
      C405JTGTDOEN => jtagppc1_C405JTGTDOEN,
      C405JTGUPDATEDR => open,
      MCBJTAGEN => net_vcc0,
      JTGC405BNDSCANTDO => net_gnd0,
      JTGC405TCK => jtagppc1_JTGC405TCK,
      JTGC405TDI => jtagppc1_JTGC405TDI,
      JTGC405TMS => jtagppc1_JTGC405TMS,
      JTGC405TRSTNEG => jtagppc1_JTGC405TRSTNEG,
      C405DBGMSRWE => open,
      C405DBGSTOPACK => open,
      C405DBGWBCOMPLETE => open,
      C405DBGWBFULL => open,
      C405DBGWBIAR => open,
      DBGC405DEBUGHALT => net_gnd0,
      DBGC405EXTBUSHOLDACK => net_gnd0,
      DBGC405UNCONDDEBUGEVENT => net_gnd0,
      C405TRCCYCLE => open,
      C405TRCEVENEXECUTIONSTATUS => open,
      C405TRCODDEXECUTIONSTATUS => open,
      C405TRCTRACESTATUS => open,
      C405TRCTRIGGEREVENTOUT => open,
      C405TRCTRIGGEREVENTTYPE => open,
      TRCC405TRACEDISABLE => net_gnd0,
      TRCC405TRIGGEREVENTIN => net_gnd0
    );

  jtagppc_0 : jtagppc_0_wrapper
    port map (
      TRSTNEG => net_vcc0,
      HALTNEG0 => net_vcc0,
      DBGC405DEBUGHALT0 => open,
      HALTNEG1 => net_vcc0,
      DBGC405DEBUGHALT1 => open,
      C405JTGTDO0 => jtagppc0_C405JTGTDO,
      C405JTGTDOEN0 => jtagppc0_C405JTGTDOEN,
      JTGC405TCK0 => jtagppc0_JTGC405TCK,
      JTGC405TDI0 => jtagppc0_JTGC405TDI,
      JTGC405TMS0 => jtagppc0_JTGC405TMS,
      JTGC405TRSTNEG0 => jtagppc0_JTGC405TRSTNEG,
      C405JTGTDO1 => jtagppc1_C405JTGTDO,
      C405JTGTDOEN1 => jtagppc1_C405JTGTDOEN,
      JTGC405TCK1 => jtagppc1_JTGC405TCK,
      JTGC405TDI1 => jtagppc1_JTGC405TDI,
      JTGC405TMS1 => jtagppc1_JTGC405TMS,
      JTGC405TRSTNEG1 => jtagppc1_JTGC405TRSTNEG
    );

  plb_emc_0 : plb_emc_0_wrapper
    port map (
      PLB_Clk => CLKPLB,
      PLB_Rst => plb_bus_PLB_Rst,
      PLB_abort => plb_bus_PLB_abort,
      PLB_ABus => plb_bus_PLB_ABus,
      PLB_BE => plb_bus_PLB_BE,
      PLB_busLock => plb_bus_PLB_busLock,
      PLB_compress => plb_bus_PLB_compress,
      PLB_guarded => plb_bus_PLB_guarded,
      PLB_lockErr => plb_bus_PLB_lockErr,
      PLB_masterID => plb_bus_PLB_masterID,
      PLB_MSize => plb_bus_PLB_MSize,
      PLB_ordered => plb_bus_PLB_ordered,
      PLB_PAValid => plb_bus_PLB_PAValid,
      PLB_RNW => plb_bus_PLB_RNW,
      PLB_size => plb_bus_PLB_size,
      PLB_type => plb_bus_PLB_type,
      Sl_addrAck => plb_bus_Sl_addrAck(5),
      Sl_MBusy => plb_bus_Sl_MBusy(20 to 23),
      Sl_MErr => plb_bus_Sl_MErr(20 to 23),
      Sl_rearbitrate => plb_bus_Sl_rearbitrate(5),
      Sl_SSize => plb_bus_Sl_SSize(10 to 11),
      Sl_wait => plb_bus_Sl_wait(5),
      PLB_rdPrim => plb_bus_PLB_rdPrim,
      PLB_SAValid => plb_bus_PLB_SAValid,
      PLB_wrPrim => plb_bus_PLB_wrPrim,
      PLB_wrBurst => plb_bus_PLB_wrBurst,
      PLB_wrDBus => plb_bus_PLB_wrDBus,
      Sl_wrBTerm => plb_bus_Sl_wrBTerm(5),
      Sl_wrComp => plb_bus_Sl_wrComp(5),
      Sl_wrDAck => plb_bus_Sl_wrDAck(5),
      PLB_rdBurst => plb_bus_PLB_rdBurst,
      Sl_rdBTerm => plb_bus_Sl_rdBTerm(5),
      Sl_rdComp => plb_bus_Sl_rdComp(5),
      Sl_rdDAck => plb_bus_Sl_rdDAck(5),
      Sl_rdDBus => plb_bus_Sl_rdDBus(320 to 383),
      Sl_rdWdAddr => plb_bus_Sl_rdWdAddr(20 to 23),
      PLB_pendReq => plb_bus_PLB_pendReq,
      PLB_pendPri => plb_bus_PLB_pendPri,
      PLB_reqPri => plb_bus_PLB_reqPri,
      Mem_A => open,
      Mem_CEN => open,
      Mem_OEN => open,
      Mem_WEN => open,
      Mem_QWEN => open,
      Mem_BEN => open,
      Mem_RPN => open,
      Mem_CE => open,
      Mem_ADV_LDN => open,
      Mem_LBON => open,
      Mem_CKEN => open,
      Mem_RNW => open,
      Mem_DQ_I => net_gnd32,
      Mem_DQ_O => open,
      Mem_DQ_T => open
    );

  opb_gpio_0 : opb_gpio_0_wrapper
    port map (
      OPB_ABus => opb_bus_OPB_ABus,
      OPB_BE => opb_bus_OPB_BE,
      OPB_Clk => CLKOPB,
      OPB_DBus => opb_bus_OPB_DBus,
      OPB_RNW => opb_bus_OPB_RNW,
      OPB_Rst => opb_bus_OPB_Rst,
      OPB_select => opb_bus_OPB_select,
      OPB_seqAddr => opb_bus_OPB_seqAddr,
      Sln_DBus => opb_bus_Sl_DBus(96 to 127),
      Sln_errAck => opb_bus_Sl_errAck(3),
      Sln_retry => opb_bus_Sl_retry(3),
      Sln_toutSup => opb_bus_Sl_toutSup(3),
      Sln_xferAck => opb_bus_Sl_xferAck(3),
      IP2INTC_Irpt => open,
      GPIO_in => net_gnd8,
      GPIO_d_out => open,
      GPIO_t_out => open,
      GPIO2_in => net_gnd8,
      GPIO2_d_out => open,
      GPIO2_t_out => open,
      GPIO_IO_I => fpga_test_led_I,
      GPIO_IO_O => fpga_test_led_O,
      GPIO_IO_T => fpga_test_led_T,
      GPIO2_IO_I => net_gnd8,
      GPIO2_IO_O => open,
      GPIO2_IO_T => open
    );

  opb_timer_0 : opb_timer_0_wrapper
    port map (
      OPB_Clk => CLKOPB,
      OPB_Rst => opb_bus_OPB_Rst,
      OPB_ABus => opb_bus_OPB_ABus,
      OPB_BE => opb_bus_OPB_BE,
      OPB_DBus => opb_bus_OPB_DBus,
      OPB_RNW => opb_bus_OPB_RNW,
      OPB_select => opb_bus_OPB_select,
      OPB_seqAddr => opb_bus_OPB_seqAddr,
      TC_DBus => opb_bus_Sl_DBus(128 to 159),
      TC_errAck => opb_bus_Sl_errAck(4),
      TC_retry => opb_bus_Sl_retry(4),
      TC_toutSup => opb_bus_Sl_toutSup(4),
      TC_xferAck => opb_bus_Sl_xferAck(4),
      CaptureTrig0 => net_gnd0,
      CaptureTrig1 => net_gnd0,
      GenerateOut0 => open,
      GenerateOut1 => open,
      PWM0 => open,
      Interrupt => open,
      Freeze => net_gnd0
    );

  hwrtos_0 : hwrtos_0_wrapper
    port map (
      PLB_Clk => CLKPLB,
      PLB_Rst => plb_bus_PLB_Rst,
      Sl_addrAck => plb_bus_Sl_addrAck(3),
      Sl_MBusy => plb_bus_Sl_MBusy(12 to 15),
      Sl_MErr => plb_bus_Sl_MErr(12 to 15),
      Sl_rdBTerm => plb_bus_Sl_rdBTerm(3),
      Sl_rdComp => plb_bus_Sl_rdComp(3),
      Sl_rdDAck => plb_bus_Sl_rdDAck(3),
      Sl_rdDBus => plb_bus_Sl_rdDBus(192 to 255),
      Sl_rdWdAddr => plb_bus_Sl_rdWdAddr(12 to 15),
      Sl_rearbitrate => plb_bus_Sl_rearbitrate(3),
      Sl_SSize => plb_bus_Sl_SSize(6 to 7),
      Sl_wait => plb_bus_Sl_wait(3),
      Sl_wrBTerm => plb_bus_Sl_wrBTerm(3),
      Sl_wrComp => plb_bus_Sl_wrComp(3),
      Sl_wrDAck => plb_bus_Sl_wrDAck(3),
      PLB_abort => plb_bus_PLB_abort,
      PLB_ABus => plb_bus_PLB_ABus,
      PLB_BE => plb_bus_PLB_BE,
      PLB_busLock => plb_bus_PLB_busLock,
      PLB_compress => plb_bus_PLB_compress,
      PLB_guarded => plb_bus_PLB_guarded,
      PLB_lockErr => plb_bus_PLB_lockErr,
      PLB_masterID => plb_bus_PLB_masterID,
      PLB_MSize => plb_bus_PLB_MSize,
      PLB_ordered => plb_bus_PLB_ordered,
      PLB_PAValid => plb_bus_PLB_PAValid,
      PLB_pendPri => plb_bus_PLB_pendPri,
      PLB_pendReq => plb_bus_PLB_pendReq,
      PLB_rdBurst => plb_bus_PLB_rdBurst,
      PLB_rdPrim => plb_bus_PLB_rdPrim,
      PLB_reqPri => plb_bus_PLB_reqPri,
      PLB_RNW => plb_bus_PLB_RNW,
      PLB_SAValid => plb_bus_PLB_SAValid,
      PLB_size => plb_bus_PLB_size,
      PLB_type => plb_bus_PLB_type,
      PLB_wrBurst => plb_bus_PLB_wrBurst,
      PLB_wrDBus => plb_bus_PLB_wrDBus,
      PLB_wrPrim => plb_bus_PLB_wrPrim,
      M_abort => plb_bus_M_abort(3),
      M_ABus => plb_bus_M_ABus(96 to 127),
      M_BE => plb_bus_M_BE(24 to 31),
      M_busLock => plb_bus_M_busLock(3),
      M_compress => plb_bus_M_compress(3),
      M_guarded => plb_bus_M_guarded(3),
      M_lockErr => plb_bus_M_lockErr(3),
      M_MSize => plb_bus_M_MSize(6 to 7),
      M_ordered => plb_bus_M_ordered(3),
      M_priority => plb_bus_M_priority(6 to 7),
      M_rdBurst => plb_bus_M_rdBurst(3),
      M_request => plb_bus_M_request(3),
      M_RNW => plb_bus_M_RNW(3),
      M_size => plb_bus_M_size(12 to 15),
      M_type => plb_bus_M_type(9 to 11),
      M_wrBurst => plb_bus_M_wrBurst(3),
      M_wrDBus => plb_bus_M_wrDBus(192 to 255),
      PLB_MBusy => plb_bus_PLB_MBusy(3),
      PLB_MErr => plb_bus_PLB_MErr(3),
      PLB_MWrBTerm => plb_bus_PLB_MWrBTerm(3),
      PLB_MWrDAck => plb_bus_PLB_MWrDAck(3),
      PLB_MAddrAck => plb_bus_PLB_MAddrAck(3),
      PLB_MRdBTerm => plb_bus_PLB_MRdBTerm(3),
      PLB_MRdDAck => plb_bus_PLB_MRdDAck(3),
      PLB_MRdDBus => plb_bus_PLB_MRdDBus(192 to 255),
      PLB_MRdWdAddr => plb_bus_PLB_MRdWdAddr(12 to 15),
      PLB_MRearbitrate => plb_bus_PLB_MRearbitrate(3),
      PLB_MSSize => plb_bus_PLB_MSSize(6 to 7),
      IP2INTC_Irpt => open
    );

  iobuf_0 : IOBUF
    port map (
      I => fpga_test_led_O(0),
      IO => fpga_test_led(0),
      O => fpga_test_led_I(0),
      T => fpga_test_led_T(0)
    );

  iobuf_1 : IOBUF
    port map (
      I => fpga_test_led_O(1),
      IO => fpga_test_led(1),
      O => fpga_test_led_I(1),
      T => fpga_test_led_T(1)
    );

  iobuf_2 : IOBUF
    port map (
      I => fpga_test_led_O(2),
      IO => fpga_test_led(2),
      O => fpga_test_led_I(2),
      T => fpga_test_led_T(2)
    );

  iobuf_3 : IOBUF
    port map (
      I => fpga_test_led_O(3),
      IO => fpga_test_led(3),
      O => fpga_test_led_I(3),
      T => fpga_test_led_T(3)
    );

  iobuf_4 : IOBUF
    port map (
      I => fpga_test_led_O(4),
      IO => fpga_test_led(4),
      O => fpga_test_led_I(4),
      T => fpga_test_led_T(4)
    );

  iobuf_5 : IOBUF
    port map (
      I => fpga_test_led_O(5),
      IO => fpga_test_led(5),
      O => fpga_test_led_I(5),
      T => fpga_test_led_T(5)
    );

  iobuf_6 : IOBUF
    port map (
      I => fpga_test_led_O(6),
      IO => fpga_test_led(6),
      O => fpga_test_led_I(6),
      T => fpga_test_led_T(6)
    );

  iobuf_7 : IOBUF
    port map (
      I => fpga_test_led_O(7),
      IO => fpga_test_led(7),
      O => fpga_test_led_I(7),
      T => fpga_test_led_T(7)
    );

  iobuf_8 : IOBUF
    port map (
      I => lbus_addr_O(0),
      IO => lbus_addr(0),
      O => lbus_addr_I(0),
      T => lbus_addr_T
    );

  iobuf_9 : IOBUF
    port map (
      I => lbus_addr_O(1),
      IO => lbus_addr(1),
      O => lbus_addr_I(1),
      T => lbus_addr_T
    );

  iobuf_10 : IOBUF
    port map (
      I => lbus_addr_O(2),
      IO => lbus_addr(2),
      O => lbus_addr_I(2),
      T => lbus_addr_T
    );

  iobuf_11 : IOBUF
    port map (
      I => lbus_addr_O(3),
      IO => lbus_addr(3),
      O => lbus_addr_I(3),
      T => lbus_addr_T
    );

  iobuf_12 : IOBUF
    port map (
      I => lbus_addr_O(4),
      IO => lbus_addr(4),
      O => lbus_addr_I(4),
      T => lbus_addr_T
    );

  iobuf_13 : IOBUF
    port map (
      I => lbus_addr_O(5),
      IO => lbus_addr(5),
      O => lbus_addr_I(5),
      T => lbus_addr_T
    );

  iobuf_14 : IOBUF
    port map (
      I => lbus_addr_O(6),
      IO => lbus_addr(6),
      O => lbus_addr_I(6),
      T => lbus_addr_T
    );

  iobuf_15 : IOBUF
    port map (
      I => lbus_addr_O(7),
      IO => lbus_addr(7),
      O => lbus_addr_I(7),
      T => lbus_addr_T
    );

  iobuf_16 : IOBUF
    port map (
      I => lbus_addr_O(8),
      IO => lbus_addr(8),
      O => lbus_addr_I(8),
      T => lbus_addr_T
    );

  iobuf_17 : IOBUF
    port map (
      I => lbus_addr_O(9),
      IO => lbus_addr(9),
      O => lbus_addr_I(9),
      T => lbus_addr_T
    );

  iobuf_18 : IOBUF
    port map (
      I => lbus_addr_O(10),
      IO => lbus_addr(10),
      O => lbus_addr_I(10),
      T => lbus_addr_T
    );

  iobuf_19 : IOBUF
    port map (
      I => lbus_addr_O(11),
      IO => lbus_addr(11),
      O => lbus_addr_I(11),
      T => lbus_addr_T
    );

  iobuf_20 : IOBUF
    port map (
      I => lbus_addr_O(12),
      IO => lbus_addr(12),
      O => lbus_addr_I(12),
      T => lbus_addr_T
    );

  iobuf_21 : IOBUF
    port map (
      I => lbus_addr_O(13),
      IO => lbus_addr(13),
      O => lbus_addr_I(13),
      T => lbus_addr_T
    );

  iobuf_22 : IOBUF
    port map (
      I => lbus_addr_O(14),
      IO => lbus_addr(14),
      O => lbus_addr_I(14),
      T => lbus_addr_T
    );

  iobuf_23 : IOBUF
    port map (
      I => lbus_addr_O(15),
      IO => lbus_addr(15),
      O => lbus_addr_I(15),
      T => lbus_addr_T
    );

  iobuf_24 : IOBUF
    port map (
      I => lbus_addr_O(16),
      IO => lbus_addr(16),
      O => lbus_addr_I(16),
      T => lbus_addr_T
    );

  iobuf_25 : IOBUF
    port map (
      I => lbus_addr_O(17),
      IO => lbus_addr(17),
      O => lbus_addr_I(17),
      T => lbus_addr_T
    );

  iobuf_26 : IOBUF
    port map (
      I => lbus_addr_O(18),
      IO => lbus_addr(18),
      O => lbus_addr_I(18),
      T => lbus_addr_T
    );

  iobuf_27 : IOBUF
    port map (
      I => lbus_addr_O(19),
      IO => lbus_addr(19),
      O => lbus_addr_I(19),
      T => lbus_addr_T
    );

  iobuf_28 : IOBUF
    port map (
      I => lbus_addr_O(20),
      IO => lbus_addr(20),
      O => lbus_addr_I(20),
      T => lbus_addr_T
    );

  iobuf_29 : IOBUF
    port map (
      I => lbus_addr_O(21),
      IO => lbus_addr(21),
      O => lbus_addr_I(21),
      T => lbus_addr_T
    );

  iobuf_30 : IOBUF
    port map (
      I => lbus_addr_O(22),
      IO => lbus_addr(22),
      O => lbus_addr_I(22),
      T => lbus_addr_T
    );

  iobuf_31 : IOBUF
    port map (
      I => lbus_addr_O(23),
      IO => lbus_addr(23),
      O => lbus_addr_I(23),
      T => lbus_addr_T
    );

  iobuf_32 : IOBUF
    port map (
      I => lbus_addr_O(24),
      IO => lbus_addr(24),
      O => lbus_addr_I(24),
      T => lbus_addr_T
    );

  iobuf_33 : IOBUF
    port map (
      I => lbus_data_O(0),
      IO => lbus_data(0),
      O => lbus_data_I(0),
      T => lbus_data_T
    );

  iobuf_34 : IOBUF
    port map (
      I => lbus_data_O(1),
      IO => lbus_data(1),
      O => lbus_data_I(1),
      T => lbus_data_T
    );

  iobuf_35 : IOBUF
    port map (
      I => lbus_data_O(2),
      IO => lbus_data(2),
      O => lbus_data_I(2),
      T => lbus_data_T
    );

  iobuf_36 : IOBUF
    port map (
      I => lbus_data_O(3),
      IO => lbus_data(3),
      O => lbus_data_I(3),
      T => lbus_data_T
    );

  iobuf_37 : IOBUF
    port map (
      I => lbus_data_O(4),
      IO => lbus_data(4),
      O => lbus_data_I(4),
      T => lbus_data_T
    );

  iobuf_38 : IOBUF
    port map (
      I => lbus_data_O(5),
      IO => lbus_data(5),
      O => lbus_data_I(5),
      T => lbus_data_T
    );

  iobuf_39 : IOBUF
    port map (
      I => lbus_data_O(6),
      IO => lbus_data(6),
      O => lbus_data_I(6),
      T => lbus_data_T
    );

  iobuf_40 : IOBUF
    port map (
      I => lbus_data_O(7),
      IO => lbus_data(7),
      O => lbus_data_I(7),
      T => lbus_data_T
    );

  iobuf_41 : IOBUF
    port map (
      I => lbus_data_O(8),
      IO => lbus_data(8),
      O => lbus_data_I(8),
      T => lbus_data_T
    );

  iobuf_42 : IOBUF
    port map (
      I => lbus_data_O(9),
      IO => lbus_data(9),
      O => lbus_data_I(9),
      T => lbus_data_T
    );

  iobuf_43 : IOBUF
    port map (
      I => lbus_data_O(10),
      IO => lbus_data(10),
      O => lbus_data_I(10),
      T => lbus_data_T
    );

  iobuf_44 : IOBUF
    port map (
      I => lbus_data_O(11),
      IO => lbus_data(11),
      O => lbus_data_I(11),
      T => lbus_data_T
    );

  iobuf_45 : IOBUF
    port map (
      I => lbus_data_O(12),
      IO => lbus_data(12),
      O => lbus_data_I(12),
      T => lbus_data_T
    );

  iobuf_46 : IOBUF
    port map (
      I => lbus_data_O(13),
      IO => lbus_data(13),
      O => lbus_data_I(13),
      T => lbus_data_T
    );

  iobuf_47 : IOBUF
    port map (
      I => lbus_data_O(14),
      IO => lbus_data(14),
      O => lbus_data_I(14),
      T => lbus_data_T
    );

  iobuf_48 : IOBUF
    port map (
      I => lbus_data_O(15),
      IO => lbus_data(15),
      O => lbus_data_I(15),
      T => lbus_data_T
    );

  iobuf_49 : IOBUF
    port map (
      I => lbus_oe_n_O,
      IO => lbus_oe_n,
      O => lbus_oe_n_I,
      T => lbus_oe_n_T
    );

  iobuf_50 : IOBUF
    port map (
      I => lbus_we_n_O,
      IO => lbus_we_n,
      O => lbus_we_n_I,
      T => lbus_we_n_T
    );

  iobuf_51 : IOBUF
    port map (
      I => con_flash_cs_n_O,
      IO => fpga_config_flash_cs_n,
      O => con_flash_cs_n_I,
      T => con_flash_cs_n_T
    );

  iobuf_52 : IOBUF
    port map (
      I => ddr1_dqs_O(3),
      IO => ddr1_dqs(3),
      O => ddr1_dqs_I(3),
      T => ddr1_dqs_T(3)
    );

  iobuf_53 : IOBUF
    port map (
      I => ddr1_dqs_O(2),
      IO => ddr1_dqs(2),
      O => ddr1_dqs_I(2),
      T => ddr1_dqs_T(2)
    );

  iobuf_54 : IOBUF
    port map (
      I => ddr1_dqs_O(1),
      IO => ddr1_dqs(1),
      O => ddr1_dqs_I(1),
      T => ddr1_dqs_T(1)
    );

  iobuf_55 : IOBUF
    port map (
      I => ddr1_dqs_O(0),
      IO => ddr1_dqs(0),
      O => ddr1_dqs_I(0),
      T => ddr1_dqs_T(0)
    );

  iobuf_56 : IOBUF
    port map (
      I => ddr1_dq_O(31),
      IO => ddr1_dq(31),
      O => ddr1_dq_I(31),
      T => ddr1_dq_T(31)
    );

  iobuf_57 : IOBUF
    port map (
      I => ddr1_dq_O(30),
      IO => ddr1_dq(30),
      O => ddr1_dq_I(30),
      T => ddr1_dq_T(30)
    );

  iobuf_58 : IOBUF
    port map (
      I => ddr1_dq_O(29),
      IO => ddr1_dq(29),
      O => ddr1_dq_I(29),
      T => ddr1_dq_T(29)
    );

  iobuf_59 : IOBUF
    port map (
      I => ddr1_dq_O(28),
      IO => ddr1_dq(28),
      O => ddr1_dq_I(28),
      T => ddr1_dq_T(28)
    );

  iobuf_60 : IOBUF
    port map (
      I => ddr1_dq_O(27),
      IO => ddr1_dq(27),
      O => ddr1_dq_I(27),
      T => ddr1_dq_T(27)
    );

  iobuf_61 : IOBUF
    port map (
      I => ddr1_dq_O(26),
      IO => ddr1_dq(26),
      O => ddr1_dq_I(26),
      T => ddr1_dq_T(26)
    );

  iobuf_62 : IOBUF
    port map (
      I => ddr1_dq_O(25),
      IO => ddr1_dq(25),
      O => ddr1_dq_I(25),
      T => ddr1_dq_T(25)
    );

  iobuf_63 : IOBUF
    port map (
      I => ddr1_dq_O(24),
      IO => ddr1_dq(24),
      O => ddr1_dq_I(24),
      T => ddr1_dq_T(24)
    );

  iobuf_64 : IOBUF
    port map (
      I => ddr1_dq_O(23),
      IO => ddr1_dq(23),
      O => ddr1_dq_I(23),
      T => ddr1_dq_T(23)
    );

  iobuf_65 : IOBUF
    port map (
      I => ddr1_dq_O(22),
      IO => ddr1_dq(22),
      O => ddr1_dq_I(22),
      T => ddr1_dq_T(22)
    );

  iobuf_66 : IOBUF
    port map (
      I => ddr1_dq_O(21),
      IO => ddr1_dq(21),
      O => ddr1_dq_I(21),
      T => ddr1_dq_T(21)
    );

  iobuf_67 : IOBUF
    port map (
      I => ddr1_dq_O(20),
      IO => ddr1_dq(20),
      O => ddr1_dq_I(20),
      T => ddr1_dq_T(20)
    );

  iobuf_68 : IOBUF
    port map (
      I => ddr1_dq_O(19),
      IO => ddr1_dq(19),
      O => ddr1_dq_I(19),
      T => ddr1_dq_T(19)
    );

  iobuf_69 : IOBUF
    port map (
      I => ddr1_dq_O(18),
      IO => ddr1_dq(18),
      O => ddr1_dq_I(18),
      T => ddr1_dq_T(18)
    );

  iobuf_70 : IOBUF
    port map (
      I => ddr1_dq_O(17),
      IO => ddr1_dq(17),
      O => ddr1_dq_I(17),
      T => ddr1_dq_T(17)
    );

  iobuf_71 : IOBUF
    port map (
      I => ddr1_dq_O(16),
      IO => ddr1_dq(16),
      O => ddr1_dq_I(16),
      T => ddr1_dq_T(16)
    );

  iobuf_72 : IOBUF
    port map (
      I => ddr1_dq_O(15),
      IO => ddr1_dq(15),
      O => ddr1_dq_I(15),
      T => ddr1_dq_T(15)
    );

  iobuf_73 : IOBUF
    port map (
      I => ddr1_dq_O(14),
      IO => ddr1_dq(14),
      O => ddr1_dq_I(14),
      T => ddr1_dq_T(14)
    );

  iobuf_74 : IOBUF
    port map (
      I => ddr1_dq_O(13),
      IO => ddr1_dq(13),
      O => ddr1_dq_I(13),
      T => ddr1_dq_T(13)
    );

  iobuf_75 : IOBUF
    port map (
      I => ddr1_dq_O(12),
      IO => ddr1_dq(12),
      O => ddr1_dq_I(12),
      T => ddr1_dq_T(12)
    );

  iobuf_76 : IOBUF
    port map (
      I => ddr1_dq_O(11),
      IO => ddr1_dq(11),
      O => ddr1_dq_I(11),
      T => ddr1_dq_T(11)
    );

  iobuf_77 : IOBUF
    port map (
      I => ddr1_dq_O(10),
      IO => ddr1_dq(10),
      O => ddr1_dq_I(10),
      T => ddr1_dq_T(10)
    );

  iobuf_78 : IOBUF
    port map (
      I => ddr1_dq_O(9),
      IO => ddr1_dq(9),
      O => ddr1_dq_I(9),
      T => ddr1_dq_T(9)
    );

  iobuf_79 : IOBUF
    port map (
      I => ddr1_dq_O(8),
      IO => ddr1_dq(8),
      O => ddr1_dq_I(8),
      T => ddr1_dq_T(8)
    );

  iobuf_80 : IOBUF
    port map (
      I => ddr1_dq_O(7),
      IO => ddr1_dq(7),
      O => ddr1_dq_I(7),
      T => ddr1_dq_T(7)
    );

  iobuf_81 : IOBUF
    port map (
      I => ddr1_dq_O(6),
      IO => ddr1_dq(6),
      O => ddr1_dq_I(6),
      T => ddr1_dq_T(6)
    );

  iobuf_82 : IOBUF
    port map (
      I => ddr1_dq_O(5),
      IO => ddr1_dq(5),
      O => ddr1_dq_I(5),
      T => ddr1_dq_T(5)
    );

  iobuf_83 : IOBUF
    port map (
      I => ddr1_dq_O(4),
      IO => ddr1_dq(4),
      O => ddr1_dq_I(4),
      T => ddr1_dq_T(4)
    );

  iobuf_84 : IOBUF
    port map (
      I => ddr1_dq_O(3),
      IO => ddr1_dq(3),
      O => ddr1_dq_I(3),
      T => ddr1_dq_T(3)
    );

  iobuf_85 : IOBUF
    port map (
      I => ddr1_dq_O(2),
      IO => ddr1_dq(2),
      O => ddr1_dq_I(2),
      T => ddr1_dq_T(2)
    );

  iobuf_86 : IOBUF
    port map (
      I => ddr1_dq_O(1),
      IO => ddr1_dq(1),
      O => ddr1_dq_I(1),
      T => ddr1_dq_T(1)
    );

  iobuf_87 : IOBUF
    port map (
      I => ddr1_dq_O(0),
      IO => ddr1_dq(0),
      O => ddr1_dq_I(0),
      T => ddr1_dq_T(0)
    );

  iobuf_88 : IOBUF
    port map (
      I => psb_a_O(0),
      IO => psb_a(0),
      O => psb_a_I(0),
      T => psb_a_T(0)
    );

  iobuf_89 : IOBUF
    port map (
      I => psb_a_O(1),
      IO => psb_a(1),
      O => psb_a_I(1),
      T => psb_a_T(1)
    );

  iobuf_90 : IOBUF
    port map (
      I => psb_a_O(2),
      IO => psb_a(2),
      O => psb_a_I(2),
      T => psb_a_T(2)
    );

  iobuf_91 : IOBUF
    port map (
      I => psb_a_O(3),
      IO => psb_a(3),
      O => psb_a_I(3),
      T => psb_a_T(3)
    );

  iobuf_92 : IOBUF
    port map (
      I => psb_a_O(4),
      IO => psb_a(4),
      O => psb_a_I(4),
      T => psb_a_T(4)
    );

  iobuf_93 : IOBUF
    port map (
      I => psb_a_O(5),
      IO => psb_a(5),
      O => psb_a_I(5),
      T => psb_a_T(5)
    );

  iobuf_94 : IOBUF
    port map (
      I => psb_a_O(6),
      IO => psb_a(6),
      O => psb_a_I(6),
      T => psb_a_T(6)
    );

  iobuf_95 : IOBUF
    port map (
      I => psb_a_O(7),
      IO => psb_a(7),
      O => psb_a_I(7),
      T => psb_a_T(7)
    );

  iobuf_96 : IOBUF
    port map (
      I => psb_a_O(8),
      IO => psb_a(8),
      O => psb_a_I(8),
      T => psb_a_T(8)
    );

  iobuf_97 : IOBUF
    port map (
      I => psb_a_O(9),
      IO => psb_a(9),
      O => psb_a_I(9),
      T => psb_a_T(9)
    );

  iobuf_98 : IOBUF
    port map (
      I => psb_a_O(10),
      IO => psb_a(10),
      O => psb_a_I(10),
      T => psb_a_T(10)
    );

  iobuf_99 : IOBUF
    port map (
      I => psb_a_O(11),
      IO => psb_a(11),
      O => psb_a_I(11),
      T => psb_a_T(11)
    );

  iobuf_100 : IOBUF
    port map (
      I => psb_a_O(12),
      IO => psb_a(12),
      O => psb_a_I(12),
      T => psb_a_T(12)
    );

  iobuf_101 : IOBUF
    port map (
      I => psb_a_O(13),
      IO => psb_a(13),
      O => psb_a_I(13),
      T => psb_a_T(13)
    );

  iobuf_102 : IOBUF
    port map (
      I => psb_a_O(14),
      IO => psb_a(14),
      O => psb_a_I(14),
      T => psb_a_T(14)
    );

  iobuf_103 : IOBUF
    port map (
      I => psb_a_O(15),
      IO => psb_a(15),
      O => psb_a_I(15),
      T => psb_a_T(15)
    );

  iobuf_104 : IOBUF
    port map (
      I => psb_a_O(16),
      IO => psb_a(16),
      O => psb_a_I(16),
      T => psb_a_T(16)
    );

  iobuf_105 : IOBUF
    port map (
      I => psb_a_O(17),
      IO => psb_a(17),
      O => psb_a_I(17),
      T => psb_a_T(17)
    );

  iobuf_106 : IOBUF
    port map (
      I => psb_a_O(18),
      IO => psb_a(18),
      O => psb_a_I(18),
      T => psb_a_T(18)
    );

  iobuf_107 : IOBUF
    port map (
      I => psb_a_O(19),
      IO => psb_a(19),
      O => psb_a_I(19),
      T => psb_a_T(19)
    );

  iobuf_108 : IOBUF
    port map (
      I => psb_a_O(20),
      IO => psb_a(20),
      O => psb_a_I(20),
      T => psb_a_T(20)
    );

  iobuf_109 : IOBUF
    port map (
      I => psb_a_O(21),
      IO => psb_a(21),
      O => psb_a_I(21),
      T => psb_a_T(21)
    );

  iobuf_110 : IOBUF
    port map (
      I => psb_a_O(22),
      IO => psb_a(22),
      O => psb_a_I(22),
      T => psb_a_T(22)
    );

  iobuf_111 : IOBUF
    port map (
      I => psb_a_O(23),
      IO => psb_a(23),
      O => psb_a_I(23),
      T => psb_a_T(23)
    );

  iobuf_112 : IOBUF
    port map (
      I => psb_a_O(24),
      IO => psb_a(24),
      O => psb_a_I(24),
      T => psb_a_T(24)
    );

  iobuf_113 : IOBUF
    port map (
      I => psb_a_O(25),
      IO => psb_a(25),
      O => psb_a_I(25),
      T => psb_a_T(25)
    );

  iobuf_114 : IOBUF
    port map (
      I => psb_a_O(26),
      IO => psb_a(26),
      O => psb_a_I(26),
      T => psb_a_T(26)
    );

  iobuf_115 : IOBUF
    port map (
      I => psb_a_O(27),
      IO => psb_a(27),
      O => psb_a_I(27),
      T => psb_a_T(27)
    );

  iobuf_116 : IOBUF
    port map (
      I => psb_a_O(28),
      IO => psb_a(28),
      O => psb_a_I(28),
      T => psb_a_T(28)
    );

  iobuf_117 : IOBUF
    port map (
      I => psb_a_O(29),
      IO => psb_a(29),
      O => psb_a_I(29),
      T => psb_a_T(29)
    );

  iobuf_118 : IOBUF
    port map (
      I => psb_a_O(30),
      IO => psb_a(30),
      O => psb_a_I(30),
      T => psb_a_T(30)
    );

  iobuf_119 : IOBUF
    port map (
      I => psb_a_O(31),
      IO => psb_a(31),
      O => psb_a_I(31),
      T => psb_a_T(31)
    );

  iobuf_120 : IOBUF
    port map (
      I => psb_abb_n_O,
      IO => psb_abb_n,
      O => psb_abb_n_I,
      T => psb_abb_n_T
    );

  iobuf_121 : IOBUF
    port map (
      I => psb_artry_n_O,
      IO => psb_artry_n,
      O => psb_artry_n_I,
      T => psb_artry_n_T
    );

  iobuf_122 : IOBUF
    port map (
      I => psb_aack_n_O,
      IO => psb_aack_n,
      O => psb_aack_n_I,
      T => psb_aack_n_T
    );

  iobuf_123 : IOBUF
    port map (
      I => psb_tbst_n_O,
      IO => psb_tbst_n,
      O => psb_tbst_n_I,
      T => psb_tbst_n_T
    );

  iobuf_124 : IOBUF
    port map (
      I => psb_dbb_n_O,
      IO => psb_dbb_n,
      O => psb_dbb_n_I,
      T => psb_dbb_n_T
    );

  iobuf_125 : IOBUF
    port map (
      I => psb_ts_n_O,
      IO => psb_ts_n,
      O => psb_ts_n_I,
      T => psb_ts_n_T
    );

  iobuf_126 : IOBUF
    port map (
      I => psb_ta_n_O,
      IO => psb_ta_n,
      O => psb_ta_n_I,
      T => psb_ta_n_T
    );

  iobuf_127 : IOBUF
    port map (
      I => psb_tea_n_O,
      IO => psb_tea_n,
      O => psb_tea_n_I,
      T => psb_tea_n_T
    );

  iobuf_128 : IOBUF
    port map (
      I => psb_tsiz_O(0),
      IO => psb_tsiz(0),
      O => psb_tsiz_I(0),
      T => psb_tsiz_T(0)
    );

  iobuf_129 : IOBUF
    port map (
      I => psb_tsiz_O(1),
      IO => psb_tsiz(1),
      O => psb_tsiz_I(1),
      T => psb_tsiz_T(1)
    );

  iobuf_130 : IOBUF
    port map (
      I => psb_tsiz_O(2),
      IO => psb_tsiz(2),
      O => psb_tsiz_I(2),
      T => psb_tsiz_T(2)
    );

  iobuf_131 : IOBUF
    port map (
      I => psb_tsiz_O(3),
      IO => psb_tsiz(3),
      O => psb_tsiz_I(3),
      T => psb_tsiz_T(3)
    );

  iobuf_132 : IOBUF
    port map (
      I => psb_tt_O(0),
      IO => psb_tt(0),
      O => psb_tt_I(0),
      T => psb_tt_T(0)
    );

  iobuf_133 : IOBUF
    port map (
      I => psb_tt_O(1),
      IO => psb_tt(1),
      O => psb_tt_I(1),
      T => psb_tt_T(1)
    );

  iobuf_134 : IOBUF
    port map (
      I => psb_tt_O(2),
      IO => psb_tt(2),
      O => psb_tt_I(2),
      T => psb_tt_T(2)
    );

  iobuf_135 : IOBUF
    port map (
      I => psb_tt_O(3),
      IO => psb_tt(3),
      O => psb_tt_I(3),
      T => psb_tt_T(3)
    );

  iobuf_136 : IOBUF
    port map (
      I => psb_tt_O(4),
      IO => psb_tt(4),
      O => psb_tt_I(4),
      T => psb_tt_T(4)
    );

  iobuf_137 : IOBUF
    port map (
      I => PSB_d_O(0),
      IO => psb_data(0),
      O => PSB_d_I(0),
      T => PSB_d_T(0)
    );

  iobuf_138 : IOBUF
    port map (
      I => PSB_d_O(1),
      IO => psb_data(1),
      O => PSB_d_I(1),
      T => PSB_d_T(1)
    );

  iobuf_139 : IOBUF
    port map (
      I => PSB_d_O(2),
      IO => psb_data(2),
      O => PSB_d_I(2),
      T => PSB_d_T(2)
    );

  iobuf_140 : IOBUF
    port map (
      I => PSB_d_O(3),
      IO => psb_data(3),
      O => PSB_d_I(3),
      T => PSB_d_T(3)
    );

  iobuf_141 : IOBUF
    port map (
      I => PSB_d_O(4),
      IO => psb_data(4),
      O => PSB_d_I(4),
      T => PSB_d_T(4)
    );

  iobuf_142 : IOBUF
    port map (
      I => PSB_d_O(5),
      IO => psb_data(5),
      O => PSB_d_I(5),
      T => PSB_d_T(5)
    );

  iobuf_143 : IOBUF
    port map (
      I => PSB_d_O(6),
      IO => psb_data(6),
      O => PSB_d_I(6),
      T => PSB_d_T(6)
    );

  iobuf_144 : IOBUF
    port map (
      I => PSB_d_O(7),
      IO => psb_data(7),
      O => PSB_d_I(7),
      T => PSB_d_T(7)
    );

  iobuf_145 : IOBUF
    port map (
      I => PSB_d_O(8),
      IO => psb_data(8),
      O => PSB_d_I(8),
      T => PSB_d_T(8)
    );

  iobuf_146 : IOBUF
    port map (
      I => PSB_d_O(9),
      IO => psb_data(9),
      O => PSB_d_I(9),
      T => PSB_d_T(9)
    );

  iobuf_147 : IOBUF
    port map (
      I => PSB_d_O(10),
      IO => psb_data(10),
      O => PSB_d_I(10),
      T => PSB_d_T(10)
    );

  iobuf_148 : IOBUF
    port map (
      I => PSB_d_O(11),
      IO => psb_data(11),
      O => PSB_d_I(11),
      T => PSB_d_T(11)
    );

  iobuf_149 : IOBUF
    port map (
      I => PSB_d_O(12),
      IO => psb_data(12),
      O => PSB_d_I(12),
      T => PSB_d_T(12)
    );

  iobuf_150 : IOBUF
    port map (
      I => PSB_d_O(13),
      IO => psb_data(13),
      O => PSB_d_I(13),
      T => PSB_d_T(13)
    );

  iobuf_151 : IOBUF
    port map (
      I => PSB_d_O(14),
      IO => psb_data(14),
      O => PSB_d_I(14),
      T => PSB_d_T(14)
    );

  iobuf_152 : IOBUF
    port map (
      I => PSB_d_O(15),
      IO => psb_data(15),
      O => PSB_d_I(15),
      T => PSB_d_T(15)
    );

  iobuf_153 : IOBUF
    port map (
      I => PSB_d_O(16),
      IO => psb_data(16),
      O => PSB_d_I(16),
      T => PSB_d_T(16)
    );

  iobuf_154 : IOBUF
    port map (
      I => PSB_d_O(17),
      IO => psb_data(17),
      O => PSB_d_I(17),
      T => PSB_d_T(17)
    );

  iobuf_155 : IOBUF
    port map (
      I => PSB_d_O(18),
      IO => psb_data(18),
      O => PSB_d_I(18),
      T => PSB_d_T(18)
    );

  iobuf_156 : IOBUF
    port map (
      I => PSB_d_O(19),
      IO => psb_data(19),
      O => PSB_d_I(19),
      T => PSB_d_T(19)
    );

  iobuf_157 : IOBUF
    port map (
      I => PSB_d_O(20),
      IO => psb_data(20),
      O => PSB_d_I(20),
      T => PSB_d_T(20)
    );

  iobuf_158 : IOBUF
    port map (
      I => PSB_d_O(21),
      IO => psb_data(21),
      O => PSB_d_I(21),
      T => PSB_d_T(21)
    );

  iobuf_159 : IOBUF
    port map (
      I => PSB_d_O(22),
      IO => psb_data(22),
      O => PSB_d_I(22),
      T => PSB_d_T(22)
    );

  iobuf_160 : IOBUF
    port map (
      I => PSB_d_O(23),
      IO => psb_data(23),
      O => PSB_d_I(23),
      T => PSB_d_T(23)
    );

  iobuf_161 : IOBUF
    port map (
      I => PSB_d_O(24),
      IO => psb_data(24),
      O => PSB_d_I(24),
      T => PSB_d_T(24)
    );

  iobuf_162 : IOBUF
    port map (
      I => PSB_d_O(25),
      IO => psb_data(25),
      O => PSB_d_I(25),
      T => PSB_d_T(25)
    );

  iobuf_163 : IOBUF
    port map (
      I => PSB_d_O(26),
      IO => psb_data(26),
      O => PSB_d_I(26),
      T => PSB_d_T(26)
    );

  iobuf_164 : IOBUF
    port map (
      I => PSB_d_O(27),
      IO => psb_data(27),
      O => PSB_d_I(27),
      T => PSB_d_T(27)
    );

  iobuf_165 : IOBUF
    port map (
      I => PSB_d_O(28),
      IO => psb_data(28),
      O => PSB_d_I(28),
      T => PSB_d_T(28)
    );

  iobuf_166 : IOBUF
    port map (
      I => PSB_d_O(29),
      IO => psb_data(29),
      O => PSB_d_I(29),
      T => PSB_d_T(29)
    );

  iobuf_167 : IOBUF
    port map (
      I => PSB_d_O(30),
      IO => psb_data(30),
      O => PSB_d_I(30),
      T => PSB_d_T(30)
    );

  iobuf_168 : IOBUF
    port map (
      I => PSB_d_O(31),
      IO => psb_data(31),
      O => PSB_d_I(31),
      T => PSB_d_T(31)
    );

  iobuf_169 : IOBUF
    port map (
      I => PSB_d_O(32),
      IO => psb_data(32),
      O => PSB_d_I(32),
      T => PSB_d_T(32)
    );

  iobuf_170 : IOBUF
    port map (
      I => PSB_d_O(33),
      IO => psb_data(33),
      O => PSB_d_I(33),
      T => PSB_d_T(33)
    );

  iobuf_171 : IOBUF
    port map (
      I => PSB_d_O(34),
      IO => psb_data(34),
      O => PSB_d_I(34),
      T => PSB_d_T(34)
    );

  iobuf_172 : IOBUF
    port map (
      I => PSB_d_O(35),
      IO => psb_data(35),
      O => PSB_d_I(35),
      T => PSB_d_T(35)
    );

  iobuf_173 : IOBUF
    port map (
      I => PSB_d_O(36),
      IO => psb_data(36),
      O => PSB_d_I(36),
      T => PSB_d_T(36)
    );

  iobuf_174 : IOBUF
    port map (
      I => PSB_d_O(37),
      IO => psb_data(37),
      O => PSB_d_I(37),
      T => PSB_d_T(37)
    );

  iobuf_175 : IOBUF
    port map (
      I => PSB_d_O(38),
      IO => psb_data(38),
      O => PSB_d_I(38),
      T => PSB_d_T(38)
    );

  iobuf_176 : IOBUF
    port map (
      I => PSB_d_O(39),
      IO => psb_data(39),
      O => PSB_d_I(39),
      T => PSB_d_T(39)
    );

  iobuf_177 : IOBUF
    port map (
      I => PSB_d_O(40),
      IO => psb_data(40),
      O => PSB_d_I(40),
      T => PSB_d_T(40)
    );

  iobuf_178 : IOBUF
    port map (
      I => PSB_d_O(41),
      IO => psb_data(41),
      O => PSB_d_I(41),
      T => PSB_d_T(41)
    );

  iobuf_179 : IOBUF
    port map (
      I => PSB_d_O(42),
      IO => psb_data(42),
      O => PSB_d_I(42),
      T => PSB_d_T(42)
    );

  iobuf_180 : IOBUF
    port map (
      I => PSB_d_O(43),
      IO => psb_data(43),
      O => PSB_d_I(43),
      T => PSB_d_T(43)
    );

  iobuf_181 : IOBUF
    port map (
      I => PSB_d_O(44),
      IO => psb_data(44),
      O => PSB_d_I(44),
      T => PSB_d_T(44)
    );

  iobuf_182 : IOBUF
    port map (
      I => PSB_d_O(45),
      IO => psb_data(45),
      O => PSB_d_I(45),
      T => PSB_d_T(45)
    );

  iobuf_183 : IOBUF
    port map (
      I => PSB_d_O(46),
      IO => psb_data(46),
      O => PSB_d_I(46),
      T => PSB_d_T(46)
    );

  iobuf_184 : IOBUF
    port map (
      I => PSB_d_O(47),
      IO => psb_data(47),
      O => PSB_d_I(47),
      T => PSB_d_T(47)
    );

  iobuf_185 : IOBUF
    port map (
      I => PSB_d_O(48),
      IO => psb_data(48),
      O => PSB_d_I(48),
      T => PSB_d_T(48)
    );

  iobuf_186 : IOBUF
    port map (
      I => PSB_d_O(49),
      IO => psb_data(49),
      O => PSB_d_I(49),
      T => PSB_d_T(49)
    );

  iobuf_187 : IOBUF
    port map (
      I => PSB_d_O(50),
      IO => psb_data(50),
      O => PSB_d_I(50),
      T => PSB_d_T(50)
    );

  iobuf_188 : IOBUF
    port map (
      I => PSB_d_O(51),
      IO => psb_data(51),
      O => PSB_d_I(51),
      T => PSB_d_T(51)
    );

  iobuf_189 : IOBUF
    port map (
      I => PSB_d_O(52),
      IO => psb_data(52),
      O => PSB_d_I(52),
      T => PSB_d_T(52)
    );

  iobuf_190 : IOBUF
    port map (
      I => PSB_d_O(53),
      IO => psb_data(53),
      O => PSB_d_I(53),
      T => PSB_d_T(53)
    );

  iobuf_191 : IOBUF
    port map (
      I => PSB_d_O(54),
      IO => psb_data(54),
      O => PSB_d_I(54),
      T => PSB_d_T(54)
    );

  iobuf_192 : IOBUF
    port map (
      I => PSB_d_O(55),
      IO => psb_data(55),
      O => PSB_d_I(55),
      T => PSB_d_T(55)
    );

  iobuf_193 : IOBUF
    port map (
      I => PSB_d_O(56),
      IO => psb_data(56),
      O => PSB_d_I(56),
      T => PSB_d_T(56)
    );

  iobuf_194 : IOBUF
    port map (
      I => PSB_d_O(57),
      IO => psb_data(57),
      O => PSB_d_I(57),
      T => PSB_d_T(57)
    );

  iobuf_195 : IOBUF
    port map (
      I => PSB_d_O(58),
      IO => psb_data(58),
      O => PSB_d_I(58),
      T => PSB_d_T(58)
    );

  iobuf_196 : IOBUF
    port map (
      I => PSB_d_O(59),
      IO => psb_data(59),
      O => PSB_d_I(59),
      T => PSB_d_T(59)
    );

  iobuf_197 : IOBUF
    port map (
      I => PSB_d_O(60),
      IO => psb_data(60),
      O => PSB_d_I(60),
      T => PSB_d_T(60)
    );

  iobuf_198 : IOBUF
    port map (
      I => PSB_d_O(61),
      IO => psb_data(61),
      O => PSB_d_I(61),
      T => PSB_d_T(61)
    );

  iobuf_199 : IOBUF
    port map (
      I => PSB_d_O(62),
      IO => psb_data(62),
      O => PSB_d_I(62),
      T => PSB_d_T(62)
    );

  iobuf_200 : IOBUF
    port map (
      I => PSB_d_O(63),
      IO => psb_data(63),
      O => PSB_d_I(63),
      T => PSB_d_T(63)
    );

end architecture STRUCTURE;

