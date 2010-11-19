-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    fpga_rst_n : in std_logic;
    fpga_opb_clk : in std_logic;
    fpga_plb_clk : in std_logic;
    fpga_test_led : out std_logic_vector(0 to 7);
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
    fpga_therm : in std_logic
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      fpga_rst_n : in std_logic;
      fpga_opb_clk : in std_logic;
      fpga_plb_clk : in std_logic;
      fpga_test_led : out std_logic_vector(0 to 7);
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
      fpga_therm : in std_logic
    );
  end component;

begin

  system_i : system
    port map (
      fpga_rst_n => fpga_rst_n,
      fpga_opb_clk => fpga_opb_clk,
      fpga_plb_clk => fpga_plb_clk,
      fpga_test_led => fpga_test_led,
      fpga_test_switch_0 => fpga_test_switch_0,
      fpga_test_switch_1 => fpga_test_switch_1,
      fpga_test_switch_2 => fpga_test_switch_2,
      fpga_test_switch_3 => fpga_test_switch_3,
      fpga_test_switch_4 => fpga_test_switch_4,
      fpga_test_switch_5 => fpga_test_switch_5,
      fpga_test_switch_6 => fpga_test_switch_6,
      fpga_test_switch_7 => fpga_test_switch_7,
      lbus_addr => lbus_addr,
      lbus_data => lbus_data,
      lbus_oe_n => lbus_oe_n,
      lbus_we_n => lbus_we_n,
      flash_cs_n => flash_cs_n,
      fpga_config_flash_cs_n => fpga_config_flash_cs_n,
      cpld_br_n => cpld_br_n,
      cpld_bg_n => cpld_bg_n,
      cpld_cs_n => cpld_cs_n,
      sysace_irq => sysace_irq,
      sysace_cs_n => sysace_cs_n,
      uart1_sin => uart1_sin,
      uart1_sout => uart1_sout,
      ddr1_clk_fb => ddr1_clk_fb,
      ddr1_clk => ddr1_clk,
      ddr1_clk_n => ddr1_clk_n,
      ddr1_addr => ddr1_addr,
      ddr1_ba => ddr1_ba,
      ddr1_ras_n => ddr1_ras_n,
      ddr1_cas_n => ddr1_cas_n,
      ddr1_we_n => ddr1_we_n,
      ddr1_cs_n => ddr1_cs_n,
      ddr1_cke => ddr1_cke,
      ddr1_dm => ddr1_dm,
      ddr1_dqs => ddr1_dqs,
      ddr1_dq => ddr1_dq,
      psb_bg_n => psb_bg_n,
      psb_dbg_n => psb_dbg_n,
      ps2_int0_n => ps2_int0_n,
      ps2_int1_n => ps2_int1_n,
      ps2_int2_n => ps2_int2_n,
      ps2_int3_n => ps2_int3_n,
      ps2_int4_n => ps2_int4_n,
      ps2_int5_n => ps2_int5_n,
      psb_br_n => psb_br_n,
      psb_a => psb_a,
      psb_abb_n => psb_abb_n,
      psb_artry_n => psb_artry_n,
      psb_aack_n => psb_aack_n,
      psb_tbst_n => psb_tbst_n,
      psb_dbb_n => psb_dbb_n,
      psb_ts_n => psb_ts_n,
      psb_ta_n => psb_ta_n,
      psb_tea_n => psb_tea_n,
      psb_tsiz => psb_tsiz,
      psb_tt => psb_tt,
      psb_data => psb_data,
      pmc_inta_n => pmc_inta_n,
      pmc_intb_n => pmc_intb_n,
      pmc_intc_n => pmc_intc_n,
      pmc_intd_n => pmc_intd_n,
      fpga_therm => fpga_therm
    );

end architecture STRUCTURE;

