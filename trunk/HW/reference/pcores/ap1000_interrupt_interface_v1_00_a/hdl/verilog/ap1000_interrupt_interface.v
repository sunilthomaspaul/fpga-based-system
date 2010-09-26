//----------------------------------------------------------------------------
// Filename:        ap1000_interrupt_interface.v
// 
// Description:
//   This module is used to bring the interrupts into the FPGA before they 
//   go to the interrupt controller (which is a piece of Xilinx IP). This
//   file is needed so that PlatGen creates the baseline_platform.vhd file
//   properly (so that the external interrupts don't bypass the IOBs).    
//   
//-----------------------------------------------------------------------------
// Structure:   
// 
//            -- top.v
//                 -- PPC405.v
//                 -- ap1000_interrupt_interface.v
//
//-----------------------------------------------------------------------------
// Author: JTK
//-----------------------------------------------------------------------------


`timescale 1ns/1ps

///////////////////////////////////////////////////////////////////////////////
// Module Declaration
///////////////////////////////////////////////////////////////////////////////

module ap1000_interrupt_interface (
                      EXT_sysace_irq,           // I
					  PMC_inta_n,               // I
					  PMC_intb_n,               // I
					  PMC_intc_n,               // I
					  PMC_intd_n,               // I
					  PS2_int0_n,               // I
					  PS2_int1_n,               // I
					  PS2_int2_n,               // I
					  PS2_int3_n,               // I
					  PS2_int4_n,               // I
					  PS2_int5_n,               // I

                      EXT_sysace_irq_internal,  // O
                      PMC_inta_n_internal,      // O
                      PMC_intb_n_internal,      // O
					  PMC_intc_n_internal,      // O
					  PMC_intd_n_internal,      // O
					  PS2_int0_n_internal,      // O
					  PS2_int1_n_internal,      // O
					  PS2_int2_n_internal,      // O
					  PS2_int3_n_internal,      // O
					  PS2_int4_n_internal,      // O
					  PS2_int5_n_internal,      // O
					  dummy1_interrupt,			// O
					  dummy2_interrupt,			// O
					  dummy3_interrupt,			// O
					  dummy4_interrupt,			// O
					  dummy5_interrupt,			// O
					  dummy6_interrupt,			// O
					  dummy7_interrupt,			// O
					  dummy8_interrupt,			// O
					  dummy9_interrupt,			// O
					  dummy10_interrupt,		// O
					  dummy11_interrupt,		// O
					  dummy12_interrupt 		// O
                     );


///////////////////////////////////////////////////////////////////////////////
// Port Declarations
///////////////////////////////////////////////////////////////////////////////

  input  EXT_sysace_irq;
  input  PMC_inta_n;
  input  PMC_intb_n;
  input  PMC_intc_n;
  input  PMC_intd_n;
  input  PS2_int0_n;
  input  PS2_int1_n;
  input  PS2_int2_n;
  input  PS2_int3_n;
  input  PS2_int4_n;
  input  PS2_int5_n;

  output EXT_sysace_irq_internal;
  output PMC_inta_n_internal;
  output PMC_intb_n_internal;
  output PMC_intc_n_internal;
  output PMC_intd_n_internal;
  output PS2_int0_n_internal;
  output PS2_int1_n_internal;
  output PS2_int2_n_internal;
  output PS2_int3_n_internal;
  output PS2_int4_n_internal;
  output PS2_int5_n_internal;
  output dummy1_interrupt;	
  output dummy2_interrupt;	
  output dummy3_interrupt;	
  output dummy4_interrupt;	
  output dummy5_interrupt;	
  output dummy6_interrupt;	
  output dummy7_interrupt;	
  output dummy8_interrupt;	
  output dummy9_interrupt;	
  output dummy10_interrupt;
  output dummy11_interrupt;
  output dummy12_interrupt;

  wire   EXT_sysace_irq_internal;
  wire   PMC_inta_n_internal;
  wire   PMC_intb_n_internal;
  wire   PMC_intc_n_internal;
  wire   PMC_intd_n_internal;
  wire   PS2_int0_n_internal;
  wire   PS2_int1_n_internal;
  wire   PS2_int2_n_internal;
  wire   PS2_int3_n_internal;
  wire   PS2_int4_n_internal;
  wire   PS2_int5_n_internal;
  wire   dummy1_interrupt;	
  wire   dummy2_interrupt;	
  wire   dummy3_interrupt;	
  wire   dummy4_interrupt;	
  wire   dummy5_interrupt;	
  wire   dummy6_interrupt;	
  wire   dummy7_interrupt;	
  wire   dummy8_interrupt;	
  wire   dummy9_interrupt;	
  wire   dummy10_interrupt;
  wire   dummy11_interrupt;
  wire   dummy12_interrupt;


///////////////////////////////////////////////////////////////////////////////
// Internal Wire Declarations
///////////////////////////////////////////////////////////////////////////////
assign EXT_sysace_irq_internal = EXT_sysace_irq;
assign PMC_inta_n_internal     = PMC_inta_n;
assign PMC_intb_n_internal     = PMC_intb_n;
assign PMC_intc_n_internal     = PMC_intc_n;
assign PMC_intd_n_internal     = PMC_intd_n;
assign PS2_int0_n_internal     = PS2_int0_n;
assign PS2_int1_n_internal     = PS2_int1_n;
assign PS2_int2_n_internal     = PS2_int2_n;
assign PS2_int3_n_internal     = PS2_int3_n;
assign PS2_int4_n_internal     = PS2_int4_n;
assign PS2_int5_n_internal     = PS2_int5_n;
assign dummy1_interrupt        = 1;	
assign dummy2_interrupt        = 1;
assign dummy3_interrupt        = 1;
assign dummy4_interrupt        = 1;
assign dummy5_interrupt        = 1;
assign dummy6_interrupt        = 1;
assign dummy7_interrupt        = 1;
assign dummy8_interrupt        = 1;
assign dummy9_interrupt        = 1;
assign dummy10_interrupt       = 1;
assign dummy11_interrupt       = 1;
assign dummy12_interrupt       = 1;


endmodule
