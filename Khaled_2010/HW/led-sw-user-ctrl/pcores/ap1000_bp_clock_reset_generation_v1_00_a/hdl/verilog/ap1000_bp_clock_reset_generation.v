//----------------------------------------------------------------------------
// Filename:        bp_clock_reset_generation.v
// 
// Description:
//   This is the top level of the module that generates the internal clocks
//   for the baseline platform FPGA. Also, this module produces the internal
//   resets based on the external async reset input and the locking of the 
//   various DCMs.
//   
//   
//-----------------------------------------------------------------------------
// Structure:   
// 
//            -- top.v
//                 -- PPC405.v
//                 -- ap1000_bp_clock_reset_generation.v
//                      -- ap1000_bp_clock_generation.v
//                      -- ap1000_bp_reset_generation.v
//
//-----------------------------------------------------------------------------
// Author: JTK
//-----------------------------------------------------------------------------


`timescale 1ns/1ps

///////////////////////////////////////////////////////////////////////////////
// Module Declaration
///////////////////////////////////////////////////////////////////////////////

module ap1000_bp_clock_reset_generation (
                      fpga_plb_clk,     // I
					  fpga_opb_clk,     // I
					  ddr_clk_fb,       // I
					  async_fpga_rst_n, // I
                      
                      CLKPLB,           // O
                      CLKOPB,           // O
                      CLKCPU,           // O
                      DDR_CLKPLB_90,    // O
					  DDR_CLKFB_90,     // O

                      RSTPLB,           // O
                      RSTOPB,           // O
					  RSTCPU            // O
                     );


///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////

  input  fpga_plb_clk;
  input  fpga_opb_clk;
  input  ddr_clk_fb;
  input  async_fpga_rst_n;

  output CLKPLB;
  output CLKOPB;
  output CLKCPU;
  output DDR_CLKPLB_90;
  output DDR_CLKFB_90;

  output RSTPLB;
  output RSTOPB;
  output RSTCPU;

///////////////////////////////////////////////////////////////////////////////
// Internal Wire Declarations
///////////////////////////////////////////////////////////////////////////////
  wire   plb_dcm_locked;
  wire   ddr_fb_dcm_locked;
  wire   opb_dcm_locked;
  wire   plb_dcm_rst;

///////////////////////////////////////////////////////////////////////////////
// Instantiate clock_generation module
///////////////////////////////////////////////////////////////////////////////
ap1000_bp_clock_generation ap1000_bp_clock_generation (
                                 // INPUTS
								   .fpga_plb_clk       (fpga_plb_clk),
								   .fpga_opb_clk       (fpga_opb_clk),
								   .ddr_clk_fb         (ddr_clk_fb),
								   .plb_dcm_rst        (plb_dcm_rst),

                                 // OUTPUTS
								   .CLKPLB             (CLKPLB),
								   .CLKOPB		       (CLKOPB),
								   .CLKCPU		       (CLKCPU),
								   .DDR_CLKPLB_90      (DDR_CLKPLB_90),
								   .DDR_CLKFB_90       (DDR_CLKFB_90),

                                   .plb_dcm_locked     (plb_dcm_locked),
								   .opb_dcm_locked     (opb_dcm_locked),
								   .ddr_fb_dcm_locked  (ddr_fb_dcm_locked)
								  );


///////////////////////////////////////////////////////////////////////////////
// Instantiate reset_generation module
///////////////////////////////////////////////////////////////////////////////
ap1000_bp_reset_generation ap1000_bp_reset_generation (
                                 // INPUTS
								   .async_fpga_rst_n   (async_fpga_rst_n),
								   .plb_clk            (CLKPLB),
								   .opb_clk		       (CLKOPB),
								   .plb_dcm_locked     (plb_dcm_locked),
								   .opb_dcm_locked     (opb_dcm_locked),
								   .ddr_fb_dcm_locked  (ddr_fb_dcm_locked),

                                 // OUTPUTS
								   .plb_dcm_rst        (plb_dcm_rst),
								   .RSTPLB             (RSTPLB),
								   .RSTOPB			   (RSTOPB),
								   .RSTCPU			   (RSTCPU)
								  );
endmodule
