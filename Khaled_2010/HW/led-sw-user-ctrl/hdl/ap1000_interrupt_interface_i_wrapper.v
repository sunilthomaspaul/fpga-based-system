//-----------------------------------------------------------------------------
// ap1000_interrupt_interface_i_wrapper.v
//-----------------------------------------------------------------------------

module ap1000_interrupt_interface_i_wrapper
  (
    EXT_sysace_irq,
    PMC_inta_n,
    PMC_intb_n,
    PMC_intc_n,
    PMC_intd_n,
    PS2_int0_n,
    PS2_int1_n,
    PS2_int2_n,
    PS2_int3_n,
    PS2_int4_n,
    PS2_int5_n,
    EXT_sysace_irq_internal,
    PMC_inta_n_internal,
    PMC_intb_n_internal,
    PMC_intc_n_internal,
    PMC_intd_n_internal,
    PS2_int0_n_internal,
    PS2_int1_n_internal,
    PS2_int2_n_internal,
    PS2_int3_n_internal,
    PS2_int4_n_internal,
    PS2_int5_n_internal,
    dummy1_interrupt,
    dummy2_interrupt,
    dummy3_interrupt,
    dummy4_interrupt,
    dummy5_interrupt,
    dummy6_interrupt,
    dummy7_interrupt,
    dummy8_interrupt,
    dummy9_interrupt,
    dummy10_interrupt,
    dummy11_interrupt,
    dummy12_interrupt
  );
  input EXT_sysace_irq;
  input PMC_inta_n;
  input PMC_intb_n;
  input PMC_intc_n;
  input PMC_intd_n;
  input PS2_int0_n;
  input PS2_int1_n;
  input PS2_int2_n;
  input PS2_int3_n;
  input PS2_int4_n;
  input PS2_int5_n;
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

  ap1000_interrupt_interface
    ap1000_interrupt_interface_i (
      .EXT_sysace_irq ( EXT_sysace_irq ),
      .PMC_inta_n ( PMC_inta_n ),
      .PMC_intb_n ( PMC_intb_n ),
      .PMC_intc_n ( PMC_intc_n ),
      .PMC_intd_n ( PMC_intd_n ),
      .PS2_int0_n ( PS2_int0_n ),
      .PS2_int1_n ( PS2_int1_n ),
      .PS2_int2_n ( PS2_int2_n ),
      .PS2_int3_n ( PS2_int3_n ),
      .PS2_int4_n ( PS2_int4_n ),
      .PS2_int5_n ( PS2_int5_n ),
      .EXT_sysace_irq_internal ( EXT_sysace_irq_internal ),
      .PMC_inta_n_internal ( PMC_inta_n_internal ),
      .PMC_intb_n_internal ( PMC_intb_n_internal ),
      .PMC_intc_n_internal ( PMC_intc_n_internal ),
      .PMC_intd_n_internal ( PMC_intd_n_internal ),
      .PS2_int0_n_internal ( PS2_int0_n_internal ),
      .PS2_int1_n_internal ( PS2_int1_n_internal ),
      .PS2_int2_n_internal ( PS2_int2_n_internal ),
      .PS2_int3_n_internal ( PS2_int3_n_internal ),
      .PS2_int4_n_internal ( PS2_int4_n_internal ),
      .PS2_int5_n_internal ( PS2_int5_n_internal ),
      .dummy1_interrupt ( dummy1_interrupt ),
      .dummy2_interrupt ( dummy2_interrupt ),
      .dummy3_interrupt ( dummy3_interrupt ),
      .dummy4_interrupt ( dummy4_interrupt ),
      .dummy5_interrupt ( dummy5_interrupt ),
      .dummy6_interrupt ( dummy6_interrupt ),
      .dummy7_interrupt ( dummy7_interrupt ),
      .dummy8_interrupt ( dummy8_interrupt ),
      .dummy9_interrupt ( dummy9_interrupt ),
      .dummy10_interrupt ( dummy10_interrupt ),
      .dummy11_interrupt ( dummy11_interrupt ),
      .dummy12_interrupt ( dummy12_interrupt )
    );

endmodule

// synthesis attribute x_core_info of ap1000_interrupt_interface is ap1000_interrupt_interface_v1_00_a;

