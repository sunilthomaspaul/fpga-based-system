//-----------------------------------------------------------------------------
// plb_psb_bridge_i_wrapper.v
//-----------------------------------------------------------------------------

module plb_psb_bridge_i_wrapper
  (
    debug_bus,
    clk,
    reset,
    PLBma_RdWdAddr,
    PLBma_RdDBus,
    PLBma_AddrAck,
    PLBma_RdDAck,
    PLBma_WrDAck,
    PLBma_rearbitrate,
    PLBma_Busy,
    PLBma_Err,
    PLBma_RdBTerm,
    PLBma_WrBTerm,
    PLBma_sSize,
    PLBma_pendReq,
    PLBma_pendPri,
    PLBma_reqPri,
    BGIma_request,
    BGIma_ABus,
    BGIma_RNW,
    BGIma_BE,
    BGIma_size,
    BGIma_type,
    BGIma_priority,
    BGIma_rdBurst,
    BGIma_wrBurst,
    BGIma_busLock,
    BGIma_abort,
    BGIma_lockErr,
    BGIma_mSize,
    BGIma_ordered,
    BGIma_compress,
    BGIma_guarded,
    BGIma_wrDBus,
    PLBsl_ABus,
    PLBsl_PAValid,
    PLBsl_SAValid,
    PLBsl_rdPrim,
    PLBsl_wrPrim,
    PLBsl_masterID,
    PLBsl_abort,
    PLBsl_busLock,
    PLBsl_RNW,
    PLBsl_BE,
    PLBsl_MSize,
    PLBsl_size,
    PLBsl_type,
    PLBsl_compress,
    PLBsl_guarded,
    PLBsl_ordered,
    PLBsl_lockErr,
    PLBsl_wrDBus,
    PLBsl_wrBurst,
    PLBsl_rdBurst,
    BGOsl_addrAck,
    BGOsl_SSize,
    BGOsl_wait,
    BGOsl_rearbitrate,
    BGOsl_wrDAck,
    BGOsl_wrComp,
    BGOsl_wrBTerm,
    BGOsl_rdDBus,
    BGOsl_rdWdAddr,
    BGOsl_rdDAck,
    BGOsl_rdComp,
    BGOsl_rdBTerm,
    BGOsl_MBusy,
    BGOsl_MErr,
    PSB_bg_n,
    PSB_br_n,
    PSB_dbg_n,
    ppc0_uart_to_reg_bus,
    ppc0_reg_to_uart_bus,
    host0_uart_to_reg_bus,
    host0_reg_to_uart_bus,
    ppc1_uart_to_reg_bus,
    ppc1_reg_to_uart_bus,
    host1_uart_to_reg_bus,
    host1_reg_to_uart_bus,
    PSB_a_I,
    PSB_a_O,
    PSB_a_T,
    PSB_abb_n_I,
    PSB_abb_n_O,
    PSB_abb_n_T,
    PSB_dbb_n_I,
    PSB_dbb_n_O,
    PSB_dbb_n_T,
    PSB_tbst_n_I,
    PSB_tbst_n_O,
    PSB_tbst_n_T,
    PSB_tsiz_I,
    PSB_tsiz_O,
    PSB_tsiz_T,
    PSB_ts_n_I,
    PSB_ts_n_O,
    PSB_ts_n_T,
    PSB_tt_I,
    PSB_tt_O,
    PSB_tt_T,
    PSB_aack_n_I,
    PSB_aack_n_O,
    PSB_aack_n_T,
    PSB_artry_n_I,
    PSB_artry_n_O,
    PSB_artry_n_T,
    PSB_d_I,
    PSB_d_O,
    PSB_d_T,
    PSB_ta_n_I,
    PSB_ta_n_O,
    PSB_ta_n_T,
    PSB_tea_n_I,
    PSB_tea_n_O,
    PSB_tea_n_T
  );
  output [254:0] debug_bus;
  input clk;
  input reset;
  input [0:3] PLBma_RdWdAddr;
  input [0:63] PLBma_RdDBus;
  input PLBma_AddrAck;
  input PLBma_RdDAck;
  input PLBma_WrDAck;
  input PLBma_rearbitrate;
  input PLBma_Busy;
  input PLBma_Err;
  input PLBma_RdBTerm;
  input PLBma_WrBTerm;
  input [0:1] PLBma_sSize;
  input PLBma_pendReq;
  input [0:1] PLBma_pendPri;
  input [0:1] PLBma_reqPri;
  output BGIma_request;
  output [0:31] BGIma_ABus;
  output BGIma_RNW;
  output [0:7] BGIma_BE;
  output [0:3] BGIma_size;
  output [0:2] BGIma_type;
  output [0:1] BGIma_priority;
  output BGIma_rdBurst;
  output BGIma_wrBurst;
  output BGIma_busLock;
  output BGIma_abort;
  output BGIma_lockErr;
  output [0:1] BGIma_mSize;
  output BGIma_ordered;
  output BGIma_compress;
  output BGIma_guarded;
  output [0:63] BGIma_wrDBus;
  input [0:31] PLBsl_ABus;
  input PLBsl_PAValid;
  input PLBsl_SAValid;
  input PLBsl_rdPrim;
  input PLBsl_wrPrim;
  input [0:1] PLBsl_masterID;
  input PLBsl_abort;
  input PLBsl_busLock;
  input PLBsl_RNW;
  input [0:7] PLBsl_BE;
  input [0:1] PLBsl_MSize;
  input [0:3] PLBsl_size;
  input [0:2] PLBsl_type;
  input PLBsl_compress;
  input PLBsl_guarded;
  input PLBsl_ordered;
  input PLBsl_lockErr;
  input [0:63] PLBsl_wrDBus;
  input PLBsl_wrBurst;
  input PLBsl_rdBurst;
  output BGOsl_addrAck;
  output [0:1] BGOsl_SSize;
  output BGOsl_wait;
  output BGOsl_rearbitrate;
  output BGOsl_wrDAck;
  output BGOsl_wrComp;
  output BGOsl_wrBTerm;
  output [0:63] BGOsl_rdDBus;
  output [0:3] BGOsl_rdWdAddr;
  output BGOsl_rdDAck;
  output BGOsl_rdComp;
  output BGOsl_rdBTerm;
  output [0:3] BGOsl_MBusy;
  output [0:3] BGOsl_MErr;
  input PSB_bg_n;
  output PSB_br_n;
  input PSB_dbg_n;
  input [29:0] ppc0_uart_to_reg_bus;
  output [75:0] ppc0_reg_to_uart_bus;
  input [29:0] host0_uart_to_reg_bus;
  output [75:0] host0_reg_to_uart_bus;
  input [29:0] ppc1_uart_to_reg_bus;
  output [75:0] ppc1_reg_to_uart_bus;
  input [29:0] host1_uart_to_reg_bus;
  output [75:0] host1_reg_to_uart_bus;
  input [0:31] PSB_a_I;
  output [0:31] PSB_a_O;
  output [0:31] PSB_a_T;
  input PSB_abb_n_I;
  output PSB_abb_n_O;
  output PSB_abb_n_T;
  input PSB_dbb_n_I;
  output PSB_dbb_n_O;
  output PSB_dbb_n_T;
  input PSB_tbst_n_I;
  output PSB_tbst_n_O;
  output PSB_tbst_n_T;
  input [0:3] PSB_tsiz_I;
  output [0:3] PSB_tsiz_O;
  output [0:3] PSB_tsiz_T;
  input PSB_ts_n_I;
  output PSB_ts_n_O;
  output PSB_ts_n_T;
  input [0:4] PSB_tt_I;
  output [0:4] PSB_tt_O;
  output [0:4] PSB_tt_T;
  input PSB_aack_n_I;
  output PSB_aack_n_O;
  output PSB_aack_n_T;
  input PSB_artry_n_I;
  output PSB_artry_n_O;
  output PSB_artry_n_T;
  input [0:63] PSB_d_I;
  output [0:63] PSB_d_O;
  output [0:63] PSB_d_T;
  input PSB_ta_n_I;
  output PSB_ta_n_O;
  output PSB_ta_n_T;
  input PSB_tea_n_I;
  output PSB_tea_n_O;
  output PSB_tea_n_T;

  defparam plb_psb_bridge_i.PLB_MASTER_BASEADDR1 = 'h00000000;
  defparam plb_psb_bridge_i.PLB_MASTER_LSB_DECODE1 = 2;
  defparam plb_psb_bridge_i.PLB_MASTER_BASEADDR2 = 'h20000000;
  defparam plb_psb_bridge_i.PLB_MASTER_LSB_DECODE2 = 3;
  defparam plb_psb_bridge_i.C_PLB_PRIORITY = 'h0;
  defparam plb_psb_bridge_i.C_BASEADDR = 'h30000000;
  defparam plb_psb_bridge_i.C_HIGHADDR = 'h3FFFFFFF;
  defparam plb_psb_bridge_i.PLB_SLAVE_LSB_DECODE = 3;
  defparam plb_psb_bridge_i.C_PLB_NUM_MASTERS = 4;
  defparam plb_psb_bridge_i.C_PLB_MID_WIDTH = 2;
  defparam plb_psb_bridge_i.PLB_PSB_FPGA_REG_BASEADDR = 'h30002000;
  defparam plb_psb_bridge_i.PLB_PSB_FPGA_REG_LSB_DECODE = 18;
  defparam plb_psb_bridge_i.C_PLB_AWIDTH = 32;
  defparam plb_psb_bridge_i.C_PLB_DWIDTH = 64;
  defparam plb_psb_bridge_i.C_FAMILY = "virtex2p";
  plb_psb_bridge
    plb_psb_bridge_i (
      .debug_bus ( debug_bus ),
      .clk ( clk ),
      .reset ( reset ),
      .PLBma_RdWdAddr ( PLBma_RdWdAddr ),
      .PLBma_RdDBus ( PLBma_RdDBus ),
      .PLBma_AddrAck ( PLBma_AddrAck ),
      .PLBma_RdDAck ( PLBma_RdDAck ),
      .PLBma_WrDAck ( PLBma_WrDAck ),
      .PLBma_rearbitrate ( PLBma_rearbitrate ),
      .PLBma_Busy ( PLBma_Busy ),
      .PLBma_Err ( PLBma_Err ),
      .PLBma_RdBTerm ( PLBma_RdBTerm ),
      .PLBma_WrBTerm ( PLBma_WrBTerm ),
      .PLBma_sSize ( PLBma_sSize ),
      .PLBma_pendReq ( PLBma_pendReq ),
      .PLBma_pendPri ( PLBma_pendPri ),
      .PLBma_reqPri ( PLBma_reqPri ),
      .BGIma_request ( BGIma_request ),
      .BGIma_ABus ( BGIma_ABus ),
      .BGIma_RNW ( BGIma_RNW ),
      .BGIma_BE ( BGIma_BE ),
      .BGIma_size ( BGIma_size ),
      .BGIma_type ( BGIma_type ),
      .BGIma_priority ( BGIma_priority ),
      .BGIma_rdBurst ( BGIma_rdBurst ),
      .BGIma_wrBurst ( BGIma_wrBurst ),
      .BGIma_busLock ( BGIma_busLock ),
      .BGIma_abort ( BGIma_abort ),
      .BGIma_lockErr ( BGIma_lockErr ),
      .BGIma_mSize ( BGIma_mSize ),
      .BGIma_ordered ( BGIma_ordered ),
      .BGIma_compress ( BGIma_compress ),
      .BGIma_guarded ( BGIma_guarded ),
      .BGIma_wrDBus ( BGIma_wrDBus ),
      .PLBsl_ABus ( PLBsl_ABus ),
      .PLBsl_PAValid ( PLBsl_PAValid ),
      .PLBsl_SAValid ( PLBsl_SAValid ),
      .PLBsl_rdPrim ( PLBsl_rdPrim ),
      .PLBsl_wrPrim ( PLBsl_wrPrim ),
      .PLBsl_masterID ( PLBsl_masterID ),
      .PLBsl_abort ( PLBsl_abort ),
      .PLBsl_busLock ( PLBsl_busLock ),
      .PLBsl_RNW ( PLBsl_RNW ),
      .PLBsl_BE ( PLBsl_BE ),
      .PLBsl_MSize ( PLBsl_MSize ),
      .PLBsl_size ( PLBsl_size ),
      .PLBsl_type ( PLBsl_type ),
      .PLBsl_compress ( PLBsl_compress ),
      .PLBsl_guarded ( PLBsl_guarded ),
      .PLBsl_ordered ( PLBsl_ordered ),
      .PLBsl_lockErr ( PLBsl_lockErr ),
      .PLBsl_wrDBus ( PLBsl_wrDBus ),
      .PLBsl_wrBurst ( PLBsl_wrBurst ),
      .PLBsl_rdBurst ( PLBsl_rdBurst ),
      .BGOsl_addrAck ( BGOsl_addrAck ),
      .BGOsl_SSize ( BGOsl_SSize ),
      .BGOsl_wait ( BGOsl_wait ),
      .BGOsl_rearbitrate ( BGOsl_rearbitrate ),
      .BGOsl_wrDAck ( BGOsl_wrDAck ),
      .BGOsl_wrComp ( BGOsl_wrComp ),
      .BGOsl_wrBTerm ( BGOsl_wrBTerm ),
      .BGOsl_rdDBus ( BGOsl_rdDBus ),
      .BGOsl_rdWdAddr ( BGOsl_rdWdAddr ),
      .BGOsl_rdDAck ( BGOsl_rdDAck ),
      .BGOsl_rdComp ( BGOsl_rdComp ),
      .BGOsl_rdBTerm ( BGOsl_rdBTerm ),
      .BGOsl_MBusy ( BGOsl_MBusy ),
      .BGOsl_MErr ( BGOsl_MErr ),
      .PSB_bg_n ( PSB_bg_n ),
      .PSB_br_n ( PSB_br_n ),
      .PSB_dbg_n ( PSB_dbg_n ),
      .ppc0_uart_to_reg_bus ( ppc0_uart_to_reg_bus ),
      .ppc0_reg_to_uart_bus ( ppc0_reg_to_uart_bus ),
      .host0_uart_to_reg_bus ( host0_uart_to_reg_bus ),
      .host0_reg_to_uart_bus ( host0_reg_to_uart_bus ),
      .ppc1_uart_to_reg_bus ( ppc1_uart_to_reg_bus ),
      .ppc1_reg_to_uart_bus ( ppc1_reg_to_uart_bus ),
      .host1_uart_to_reg_bus ( host1_uart_to_reg_bus ),
      .host1_reg_to_uart_bus ( host1_reg_to_uart_bus ),
      .PSB_a_I ( PSB_a_I ),
      .PSB_a_O ( PSB_a_O ),
      .PSB_a_T ( PSB_a_T ),
      .PSB_abb_n_I ( PSB_abb_n_I ),
      .PSB_abb_n_O ( PSB_abb_n_O ),
      .PSB_abb_n_T ( PSB_abb_n_T ),
      .PSB_dbb_n_I ( PSB_dbb_n_I ),
      .PSB_dbb_n_O ( PSB_dbb_n_O ),
      .PSB_dbb_n_T ( PSB_dbb_n_T ),
      .PSB_tbst_n_I ( PSB_tbst_n_I ),
      .PSB_tbst_n_O ( PSB_tbst_n_O ),
      .PSB_tbst_n_T ( PSB_tbst_n_T ),
      .PSB_tsiz_I ( PSB_tsiz_I ),
      .PSB_tsiz_O ( PSB_tsiz_O ),
      .PSB_tsiz_T ( PSB_tsiz_T ),
      .PSB_ts_n_I ( PSB_ts_n_I ),
      .PSB_ts_n_O ( PSB_ts_n_O ),
      .PSB_ts_n_T ( PSB_ts_n_T ),
      .PSB_tt_I ( PSB_tt_I ),
      .PSB_tt_O ( PSB_tt_O ),
      .PSB_tt_T ( PSB_tt_T ),
      .PSB_aack_n_I ( PSB_aack_n_I ),
      .PSB_aack_n_O ( PSB_aack_n_O ),
      .PSB_aack_n_T ( PSB_aack_n_T ),
      .PSB_artry_n_I ( PSB_artry_n_I ),
      .PSB_artry_n_O ( PSB_artry_n_O ),
      .PSB_artry_n_T ( PSB_artry_n_T ),
      .PSB_d_I ( PSB_d_I ),
      .PSB_d_O ( PSB_d_O ),
      .PSB_d_T ( PSB_d_T ),
      .PSB_ta_n_I ( PSB_ta_n_I ),
      .PSB_ta_n_O ( PSB_ta_n_O ),
      .PSB_ta_n_T ( PSB_ta_n_T ),
      .PSB_tea_n_I ( PSB_tea_n_I ),
      .PSB_tea_n_O ( PSB_tea_n_O ),
      .PSB_tea_n_T ( PSB_tea_n_T )
    );

endmodule

// synthesis attribute x_core_info of plb_psb_bridge is plb_psb_bridge_v1_00_a;

