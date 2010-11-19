//----------------------------------------------------------------------------
// Filename:        bp_clock_generation.v
// 
// Description:
//   This module accepts the FPGA external clocks and generates internal
//   clocks for the FPGA.
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

module ap1000_bp_clock_generation (
                      fpga_plb_clk,     // I
					  fpga_opb_clk,     // I
					  ddr_clk_fb,       // I
					  plb_dcm_rst,      // I
                      
                      CLKPLB,           // O
                      CLKOPB,           // O
                      CLKCPU,           // O
                      DDR_CLKPLB_90,    // O
					  DDR_CLKFB_90,     // O

					  plb_dcm_locked,   // O
					  opb_dcm_locked,   // O
					  ddr_fb_dcm_locked	// O
                     );


///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////

  input  fpga_plb_clk;
  input  fpga_opb_clk;
  input  ddr_clk_fb;
  input  plb_dcm_rst;

  output CLKPLB;
  output CLKOPB;
  output CLKCPU;
  output DDR_CLKPLB_90;
  output DDR_CLKFB_90;

  output plb_dcm_locked;
  wire   plb_dcm_locked;
  output opb_dcm_locked;
  output ddr_fb_dcm_locked;

///////////////////////////////////////////////////////////////////////////////
// Internal Wire Declarations
///////////////////////////////////////////////////////////////////////////////

  wire   fpga_plb_clk_in;
  wire   fpga_opb_clk_in;
  wire   clkplb_i;
  wire   clkopb_i;
  wire   clkcpu_i;
  wire   ddr_clkplb_90_i;

  wire	 ddr_clk_fb_in;
  wire	 ddr_clk_fb_i;

///////////////////////////////////////////////////////////////////////////////
// Instantiate DCM #1 to generate the PLB, CPU, OCM and ddr_clkplb_90 Clocks (LF Mode)
///////////////////////////////////////////////////////////////////////////////
// Input Buffer for reference clock
IBUFG clkibufg_plb   (.I(fpga_plb_clk), .O(fpga_plb_clk_in));

/* synthesis translate_off */
// Set the clock multiplier and clock divide ratio for the CPU and OPB Clocks
defparam plb_dcm.CLKFX_MULTIPLY = 3;
/* synthesis translate_on */
DCM plb_dcm (
             .CLKIN       (fpga_plb_clk_in), // I
             .CLKFB       (CLKPLB),          // I
             .DSSEN       (1'b0),            // I
             .PSCLK       (1'b0),            // I
             .PSEN        (1'b0),            // I
             .PSINCDEC    (1'b0),            // I
             .RST         (plb_dcm_rst),     // I
					      
             .CLK0        (clkplb_i),        // O
             .CLK2X       (),                // O
             .CLKDV       (),                // O
             .CLKFX       (clkcpu_i),        // O
             .LOCKED      (plb_dcm_locked),  // O
					      
             .CLK90       (ddr_clkplb_90_i), // O
             .CLK180      (),                // O
             .CLK270      (),                // O
             .CLK2X180    (),                // O
             .CLKFX180    (),                // O
             .PSDONE      (),                // O
             .STATUS      ()                 // O
            ) /* synthesis xc_props = "CLKFX_MULTIPLY=3" */;

// Global Buffers to drive clock outputs from DCM
BUFG clkplb_bufg     (.I(clkplb_i),           .O(CLKPLB));
BUFG clkcpu_bufg     (.I(clkcpu_i),           .O(CLKCPU));
BUFG clkddr90_bufg   (.I(ddr_clkplb_90_i),    .O(DDR_CLKPLB_90));

///////////////////////////////////////////////////////////////////////////////
// Instantiate DCM #2 to generate the OPB clock (LF Mode)
///////////////////////////////////////////////////////////////////////////////
// Input Buffer for reference clock
IBUFG clkibufg_opb   (.I(fpga_opb_clk), .O(fpga_opb_clk_in));

DCM opb_dcm (
             .CLKIN       (fpga_opb_clk_in), // I
             .CLKFB       (CLKOPB),          // I
             .DSSEN       (1'b0),            // I
             .PSCLK       (1'b0),            // I
             .PSEN        (1'b0),            // I
             .PSINCDEC    (1'b0),            // I
             .RST         (plb_dcm_rst),     // I
					      
             .CLK0        (clkopb_i),        // O
             .CLK2X       (),                // O
             .CLKDV       (),                // O
             .CLKFX       (),                // O
             .LOCKED      (opb_dcm_locked),  // O
					      
             .CLK90       (),                // O
             .CLK180      (),                // O
             .CLK270      (),                // O
             .CLK2X180    (),                // O
             .CLKFX180    (),                // O
             .PSDONE      (),                // O
             .STATUS      ()                 // O
            );

// Global Buffers to drive clock outputs from DCM
BUFG clkopb_bufg     (.I(clkopb_i),           .O(CLKOPB));


///////////////////////////////////////////////////////////////////////////////
// Instantiate DCM #3 to generate the DDR SDRAM feedback clock.
///////////////////////////////////////////////////////////////////////////////
// Input Buffer for reference clock
IBUFG clkibufg_ddrfb   (.I(ddr_clk_fb), .O(ddr_clk_fb_in));

DCM ddrfb_dcm (
             .CLKIN       (ddr_clk_fb_in),     // I
             .CLKFB       (DDR_CLKFB),         // I
             .DSSEN       (1'b0),              // I
             .PSCLK       (1'b0),              // I
             .PSEN        (1'b0),              // I
             .PSINCDEC    (1'b0),              // I
             .RST         (~plb_dcm_locked),   // I
					      					   
             .CLK0        (ddr_clk_fb_i),      // O					   
             .CLK2X       (),                  // O					   
             .CLKDV       (),                  // O					   
             .CLKFX       (),                  // O					   
             .LOCKED      (ddr_fb_dcm_locked), // O
					      
             .CLK90       (),                  // O
             .CLK180      (),                  // O
             .CLK270      (),                  // O
             .CLK2X180    (),                  // O
             .CLKFX180    (),                  // O
             .PSDONE      (),                  // O
             .STATUS      ()                   // O
            );

// Global Buffers to drive clock outputs from DCM
BUFG ddr_clk_fb_bufg   (.I(ddr_clk_fb_i),   .O(DDR_CLKFB));  // just for DCM fb
assign DDR_CLKFB_90 = DDR_CLKFB;

endmodule
