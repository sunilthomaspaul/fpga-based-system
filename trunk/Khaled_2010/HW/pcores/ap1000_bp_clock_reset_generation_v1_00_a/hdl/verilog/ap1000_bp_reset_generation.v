//----------------------------------------------------------------------------
// Filename:        bp_reset_generation.v
// 
// Description:
//   This module uses the FPGA external asynch reset to generate the internal
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

module ap1000_bp_reset_generation (
					  async_fpga_rst_n,  // I
                      plb_clk,           // I
					  opb_clk,           // I
					  plb_dcm_locked,    // I 
					  opb_dcm_locked,    // I
					  ddr_fb_dcm_locked, // I 
                      
					  plb_dcm_rst,       // O
                      RSTPLB,            // O
                      RSTOPB,            // O
					  RSTCPU             // O
                     );


///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////
  input  async_fpga_rst_n;
  input  plb_clk;
  input  opb_clk;
  input  plb_dcm_locked;
  input  opb_dcm_locked;
  input  ddr_fb_dcm_locked;

  output plb_dcm_rst;
  output RSTPLB;
  output RSTOPB;
  output RSTCPU;

  wire   plb_dcm_rst;
  reg    RSTPLB;
  reg    RSTOPB;
  wire   RSTCPU;

///////////////////////////////////////////////////////////////////////////////
// Internal Wire and Register Declarations
///////////////////////////////////////////////////////////////////////////////
//  wire     async_FPGAi_rst_n;
  reg[2:0] startup_counter;
  reg      mff1_FPGA_rst;
  reg      mff2_FPGA_rst;
  reg      FPGA_rst_n;
  reg      mff1_RSTOPB;

///////////////////////////////////////////////////////////////////////////////
// Startup / RST Logic
///////////////////////////////////////////////////////////////////////////////
//IBUF  async_FPGA_rst_n_ibuf  (.I(async_fpga_rst_n),   .O(async_FPGAi_rst_n));


// Wait for 8 consecutive clocks with dcm_locked asserted before releasing RST
always @(posedge plb_clk)
begin
    if (!plb_dcm_locked || !ddr_fb_dcm_locked || !opb_dcm_locked)
        startup_counter <= 3'b0;
    else if (startup_counter != 3'b111)
        startup_counter <= startup_counter + 1;
    else
        startup_counter <= startup_counter;
end

// Produce a synchronous reset from the external asynchronous reset signal
// Also, reset the DCMs upon asynch reset getting asserted.
always @(posedge plb_clk or negedge async_fpga_rst_n)
begin
    if (!async_fpga_rst_n)
	begin
	    mff1_FPGA_rst <= 0;
		mff2_FPGA_rst <= 0;
	    FPGA_rst_n    <= 0;
	end

    else
	begin
	    mff1_FPGA_rst <= 1;
		mff2_FPGA_rst <= mff1_FPGA_rst;
	    FPGA_rst_n    <= mff2_FPGA_rst;
	end
end
assign plb_dcm_rst = ~async_fpga_rst_n;

// startup_counter will be 3'b111 if DCMs are all locked
always @(posedge plb_clk)
begin
    if ( (startup_counter != 3'b111) || (!FPGA_rst_n) )
	// Either the DCMs are not locked or the external reset is asserted
	// so assert PLB reset
        RSTPLB <= 1;
	// The DCMs are locked and the external reset is not asserted
	// so deassert PLB reset
	else
	    RSTPLB <= 0;
end

assign RSTCPU = RSTPLB;

// re-time reset to OPB clock
always @(posedge opb_clk)
begin
    mff1_RSTOPB <= RSTPLB;
    RSTOPB      <= mff1_RSTOPB;
end


endmodule
