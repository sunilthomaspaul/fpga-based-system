-------------------------------------------------------------------------------
-- $Id: pf_dly1_mux.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- pf_dly1_mux.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
--                  ****************************
--                  ** Copyright Xilinx, Inc. **
--                  ** All rights reserved.   **
--                  ****************************
--
-------------------------------------------------------------------------------
-- Filename:        pf_dly1_mux.vhd
--
-- Description:     Implements a multiplexer and register combo that allows 
--                  selection of a registered or non-registered version of
--                  the input signal for output.
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--                  pf_dly1_mux.vhd
--
-------------------------------------------------------------------------------
-- Author:          B.L. Tise
-- Revision:        $Revision: 1.1 $
-- Date:            $Date: 2005/08/23 19:22:55 $
--
-- History:
--   D. Thorpe      2001-08-30    First Version
--                  - adapted from B Tise MicroBlaze counters
--
--   DET            2001-09-11   
--                  - Added the Rst input signal and connected it to the FDRE
--                    reset input.
--
--
--   DET            2002-02-24
--                  - Changed to call out proc_common_v1_00_b library.
--                  - Removed unused MUXCY_L and XORCY components.
--
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.all;

library modified_plb_ddr_controller_v1_00_c;
Use modified_plb_ddr_controller_v1_00_c.inferred_lut4;
                
-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity pf_dly1_mux is
  Generic (C_MUX_WIDTH : Integer := 12
       );
  port (
    Clk           : in  std_logic;
    Rst           : In  std_logic;
    dly_sel1      : in  std_logic;
    dly_sel2      : in  std_logic;
    Inputs        : in  std_logic_vector(0 to C_MUX_WIDTH-1);
    Y_out         : out std_logic_vector(0 to C_MUX_WIDTH-1)
    );

end pf_dly1_mux;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture implementation of pf_dly1_mux is
  
  --- xst wrk around  component LUT4 is
  --- xst wrk around    generic(
  --- xst wrk around    -- synthesis translate_off
  --- xst wrk around      Xon  : boolean;
  --- xst wrk around    -- synthesis translate_on    
  --- xst wrk around      INIT : bit_vector := X"0000"
  --- xst wrk around      );
  --- xst wrk around    port (
  --- xst wrk around      O  : out std_logic;
  --- xst wrk around      I0 : in  std_logic;
  --- xst wrk around      I1 : in  std_logic;
  --- xst wrk around      I2 : in  std_logic;
  --- xst wrk around      I3 : in  std_logic);
  --- xst wrk around  end component LUT4;

 
  
  component inferred_lut4 is 
   generic (INIT : bit_vector(15 downto 0)); 
   port ( 
     O  : out std_logic; 
     I0 : in std_logic; 
     I1 : in std_logic; 
     I2 : in std_logic; 
     I3 : in std_logic 
     );
  end component inferred_lut4;
  
 
   
  component FDRE is
    port (
      Q  : out std_logic;
      C  : in  std_logic;
      CE : in  std_logic;
      D  : in  std_logic;
      R  : in  std_logic
    );
  end component FDRE;
  
  signal    lut_out  : std_logic_vector(0 to C_MUX_WIDTH-1);
  signal    reg_out  : std_logic_vector(0 to C_MUX_WIDTH-1);
  signal    count_Result_Reg : std_logic;

  attribute INIT       : string;
  
begin  -- VHDL_RTL

        
        
   MAKE_DLY_MUX : for i in 0 to C_MUX_WIDTH-1 generate
     
     
     
        --- xst wrk around  I_SEL_LUT : LUT4
        --- xst wrk around    generic map(
        --- xst wrk around    -- synthesis translate_off
        --- xst wrk around      Xon  => false,
        --- xst wrk around    -- synthesis translate_on    
        --- xst wrk around      INIT => X"FE10"
        --- xst wrk around      )
        --- xst wrk around    port map (
        --- xst wrk around      O  => lut_out(i),               
        --- xst wrk around      I0 => dly_sel1,      
        --- xst wrk around      I1 => dly_sel2,      
        --- xst wrk around      I2 => Inputs(i),    
        --- xst wrk around      I3 => reg_out(i)
        --- xst wrk around     );          
        
        
        
        
        I_SEL_LUT : inferred_lut4
          generic map(
            INIT => X"FE10"
            )
          port map (
            O  => lut_out(i),               
            I0 => dly_sel1,      
            I1 => dly_sel2,      
            I2 => Inputs(i),    
            I3 => reg_out(i)
           );          
        
        
        
        FDRE_I: FDRE
          port map (
            Q  =>  reg_out(i),          
            C  =>  Clk,          
            CE =>  '1',          
            D  =>  Inputs(i),          
            R  =>  Rst          
          );      
       
   End generate MAKE_DLY_MUX; 
           
        
   Y_out <= lut_out;
        
                             
                             
end implementation;


