//-----------------------------------------------------------------------------
// opbslave_ext_bridge_i_wrapper.v
//-----------------------------------------------------------------------------

module opbslave_ext_bridge_i_wrapper
  (
    clk,
    reset,
    opb_abus,
    opb_be,
    opb_rnw,
    opb_select,
    opb_seqAddr,
    opb_dbusm,
    sl_dbus,
    sl_errack,
    sl_retry,
    sl_toutsup,
    sl_xferack,
    fpga_test_switch,
    fpga_test_led,
    fpga_therm,
    EXT_cpld_br_n,
    EXT_cpld_bg_n,
    EXT_cpld_cs_n,
    EXT_flash_cs_n,
    EXT_sysace_cs_n,
    RSTCPU1,
    RSTCPU2,
    ppc1_sw_reset,
    ppc2_sw_reset,
    opb_ext_bridge_debug_bus,
    EXT_data_I,
    EXT_data_O,
    EXT_data_T,
    EXT_addr_I,
    EXT_addr_O,
    EXT_addr_T,
    EXT_we_n_I,
    EXT_we_n_O,
    EXT_we_n_T,
    EXT_con_flash_cs_n_I,
    EXT_con_flash_cs_n_O,
    EXT_con_flash_cs_n_T,
    EXT_oe_n_I,
    EXT_oe_n_O,
    EXT_oe_n_T
  );
  input clk;
  input reset;
  input [0:31] opb_abus;
  input [0:3] opb_be;
  input opb_rnw;
  input opb_select;
  input opb_seqAddr;
  input [0:31] opb_dbusm;
  output [0:31] sl_dbus;
  output sl_errack;
  output sl_retry;
  output sl_toutsup;
  output sl_xferack;
  input [0:7] fpga_test_switch;
  output [0:7] fpga_test_led;
  input fpga_therm;
  input EXT_cpld_br_n;
  output EXT_cpld_bg_n;
  output EXT_cpld_cs_n;
  output EXT_flash_cs_n;
  output EXT_sysace_cs_n;
  input RSTCPU1;
  input RSTCPU2;
  output ppc1_sw_reset;
  output ppc2_sw_reset;
  output [60:0] opb_ext_bridge_debug_bus;
  input [0:15] EXT_data_I;
  output [0:15] EXT_data_O;
  output EXT_data_T;
  input [0:24] EXT_addr_I;
  output [0:24] EXT_addr_O;
  output EXT_addr_T;
  input EXT_we_n_I;
  output EXT_we_n_O;
  output EXT_we_n_T;
  input EXT_con_flash_cs_n_I;
  output EXT_con_flash_cs_n_O;
  output EXT_con_flash_cs_n_T;
  input EXT_oe_n_I;
  output EXT_oe_n_O;
  output EXT_oe_n_T;

  defparam opbslave_ext_bridge_i.C_OPB_DWIDTH = 32;
  defparam opbslave_ext_bridge_i.C_OPB_AWIDTH = 32;
  defparam opbslave_ext_bridge_i.flash_wait_cycles = 8;
  defparam opbslave_ext_bridge_i.base_cfg_enable = 1;
  defparam opbslave_ext_bridge_i.FPGA_revision = 'h21050010;
  defparam opbslave_ext_bridge_i.ppc1_reset_value = 0;
  defparam opbslave_ext_bridge_i.ppc2_reset_value = 1;
  defparam opbslave_ext_bridge_i.size_of_config_flash = 4;
  defparam opbslave_ext_bridge_i.size_of_protected_area = 2;
  defparam opbslave_ext_bridge_i.ext_dwidth = 16;
  defparam opbslave_ext_bridge_i.ext_awidth = 25;
  defparam opbslave_ext_bridge_i.test_swtch_width = 8;
  defparam opbslave_ext_bridge_i.test_led_width = 8;
  opbslave_ext_bridge
    opbslave_ext_bridge_i (
      .clk ( clk ),
      .reset ( reset ),
      .opb_abus ( opb_abus ),
      .opb_be ( opb_be ),
      .opb_rnw ( opb_rnw ),
      .opb_select ( opb_select ),
      .opb_seqAddr ( opb_seqAddr ),
      .opb_dbusm ( opb_dbusm ),
      .sl_dbus ( sl_dbus ),
      .sl_errack ( sl_errack ),
      .sl_retry ( sl_retry ),
      .sl_toutsup ( sl_toutsup ),
      .sl_xferack ( sl_xferack ),
      .fpga_test_switch ( fpga_test_switch ),
      .fpga_test_led ( fpga_test_led ),
      .fpga_therm ( fpga_therm ),
      .EXT_cpld_br_n ( EXT_cpld_br_n ),
      .EXT_cpld_bg_n ( EXT_cpld_bg_n ),
      .EXT_cpld_cs_n ( EXT_cpld_cs_n ),
      .EXT_flash_cs_n ( EXT_flash_cs_n ),
      .EXT_sysace_cs_n ( EXT_sysace_cs_n ),
      .RSTCPU1 ( RSTCPU1 ),
      .RSTCPU2 ( RSTCPU2 ),
      .ppc1_sw_reset ( ppc1_sw_reset ),
      .ppc2_sw_reset ( ppc2_sw_reset ),
      .opb_ext_bridge_debug_bus ( opb_ext_bridge_debug_bus ),
      .EXT_data_I ( EXT_data_I ),
      .EXT_data_O ( EXT_data_O ),
      .EXT_data_T ( EXT_data_T ),
      .EXT_addr_I ( EXT_addr_I ),
      .EXT_addr_O ( EXT_addr_O ),
      .EXT_addr_T ( EXT_addr_T ),
      .EXT_we_n_I ( EXT_we_n_I ),
      .EXT_we_n_O ( EXT_we_n_O ),
      .EXT_we_n_T ( EXT_we_n_T ),
      .EXT_con_flash_cs_n_I ( EXT_con_flash_cs_n_I ),
      .EXT_con_flash_cs_n_O ( EXT_con_flash_cs_n_O ),
      .EXT_con_flash_cs_n_T ( EXT_con_flash_cs_n_T ),
      .EXT_oe_n_I ( EXT_oe_n_I ),
      .EXT_oe_n_O ( EXT_oe_n_O ),
      .EXT_oe_n_T ( EXT_oe_n_T )
    );

endmodule

// synthesis attribute x_core_info of opbslave_ext_bridge is opbslave_ext_bridge_v3_10_a;

