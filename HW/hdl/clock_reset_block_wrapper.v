//-----------------------------------------------------------------------------
// clock_reset_block_wrapper.v
//-----------------------------------------------------------------------------

module clock_reset_block_wrapper
  (
    fpga_plb_clk,
    fpga_opb_clk,
    ddr_clk_fb,
    async_fpga_rst_n,
    CLKPLB,
    CLKOPB,
    CLKCPU,
    DDR_CLKPLB_90,
    DDR_CLKFB_90,
    RSTPLB,
    RSTOPB,
    RSTCPU
  );
  input fpga_plb_clk;
  input fpga_opb_clk;
  input ddr_clk_fb;
  input async_fpga_rst_n;
  output CLKPLB;
  output CLKOPB;
  output CLKCPU;
  output DDR_CLKPLB_90;
  output DDR_CLKFB_90;
  output RSTPLB;
  output RSTOPB;
  output RSTCPU;

  ap1000_bp_clock_reset_generation
    clock_reset_block (
      .fpga_plb_clk ( fpga_plb_clk ),
      .fpga_opb_clk ( fpga_opb_clk ),
      .ddr_clk_fb ( ddr_clk_fb ),
      .async_fpga_rst_n ( async_fpga_rst_n ),
      .CLKPLB ( CLKPLB ),
      .CLKOPB ( CLKOPB ),
      .CLKCPU ( CLKCPU ),
      .DDR_CLKPLB_90 ( DDR_CLKPLB_90 ),
      .DDR_CLKFB_90 ( DDR_CLKFB_90 ),
      .RSTPLB ( RSTPLB ),
      .RSTOPB ( RSTOPB ),
      .RSTCPU ( RSTCPU )
    );

endmodule

// synthesis attribute x_core_info of ap1000_bp_clock_reset_generation is ap1000_bp_clock_reset_generation_v1_00_a;

