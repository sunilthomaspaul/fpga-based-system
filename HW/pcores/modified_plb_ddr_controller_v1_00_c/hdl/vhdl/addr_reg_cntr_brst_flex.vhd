-------------------------------------------------------------------------------
-- $Id: addr_reg_cntr_brst_flex.vhd,v 1.1 2005/08/23 19:22:55 kuehner Exp $
-------------------------------------------------------------------------------
-- addr_reg_cntr_brst_flex.vhd - vhdl design file for the entity and architecture
--                            of the Mauna Loa IPIF Bus to IPIF Bus Address
--                            multiplexer.
-------------------------------------------------------------------------------
--
--                  ****************************
--                  ** Copyright Xilinx, Inc. **
--                  ** All rights reserved.   **
--                  ****************************
--
-------------------------------------------------------------------------------
-- Filename:        addr_reg_cntr_brst_flex.vhd
--
-- Description:     This vhdl design file is for the entity and architecture  
--                  of the Mauna Loa IPIF Bus to IPIF Bus Address Bus Output 
--                  multiplexer.        
--
-------------------------------------------------------------------------------
-- Structure:   
--              
--
--              addr_reg_cntr_brst_flex.vhd
--
-------------------------------------------------------------------------------
-- Author:      D. Thorpe
-- History:
--
--      DET        Feb-5-02
-- ~~~~~~
--      First version
-- ^^^^^^
--
--      DET        Mar-4-02
-- ~~~~~~
--      - Corrected a problem with the cacheline address counting mechanism
-- ^^^^^^
--
--     DET     3/29/2002     v1_00_b
-- ~~~~~~
--     - Added burst mode support to the address reg/counter.
-- ^^^^^^
--
--
--     DET     8/11/2003     v1_00_e (PCI and DDR)
-- ~~~~~~
--     - Corrected a timing problem found with DDR integration. The signal
--       'clr_addr_be' needed to be inhibited when a new address load cycle
--       was being initiated coming out of a 'Wait' condition.
-- ^^^^^^
--
--
---------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
--
-- Library definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; -- need the unsigned functions


--library plb_ipif_v1_00_d;
--Use plb_ipif_v1_00_d.all;


library unisim;
Use unisim.all;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
entity addr_reg_cntr_brst_flex is
  Generic (
           C_NUM_ADDR_BITS      : Integer := 32;   -- bits
           C_PLB_DWIDTH         : Integer := 64    -- bits
          ); 
    port (
       -- Clock and Reset
         Bus_reset          : In  std_logic;
         Bus_clk            : In  std_logic;
       
       
       -- Inputs from Slave Attachment
         Single             : In  std_logic;
         Cacheln            : In  std_logic;
         Burst              : In  std_logic;
         S_H_Qualifiers     : In  std_logic;
         Xfer_done          : In  std_logic;
         Addr_Load          : In  std_logic;
         Addr_Cnt_en        : In  std_logic;
         Addr_Cnt_Size      : In  Std_logic_vector(0 to 3);
         Address_In         : in  std_logic_vector(0 to C_NUM_ADDR_BITS-1);
         BE_in              : In  Std_logic_vector(0 to (C_PLB_DWIDTH/8)-1);
    
         
       -- BE Outputs
         BE_out             : Out Std_logic_vector(0 to (C_PLB_DWIDTH/8)-1);                                                                
                                                                       
       -- IPIF & IP address bus source (AMUX output)
         Address_Out        : out std_logic_vector(0 to C_NUM_ADDR_BITS-1)

         );
end addr_reg_cntr_brst_flex;




architecture implementation of addr_reg_cntr_brst_flex is


    
-- COMPONENTS

  component flex_addr_cntr is
    Generic (
       C_AWIDTH : integer := 32
       );
      
    port (
      Clk            : in  std_logic;
      Rst            : in  std_logic;
      Load_Enable    : in  std_logic;
      Load_addr      : in  std_logic_vector(C_AWIDTH-1 downto 0);
      Cnt_by_1       : in  std_logic;
      Cnt_by_2       : in  std_logic;
      Cnt_by_4       : in  std_logic;
      Cnt_by_8       : in  std_logic;
      Cnt_by_16      : in  std_logic;
      Cnt_by_32      : in  std_logic;
      Cnt_by_64      : in  std_logic;
      Cnt_by_128     : in  std_logic;
      Clk_En_0       : in  std_logic;
      Clk_En_1       : in  std_logic;
      Clk_En_2       : in  std_logic;
      Clk_En_3       : in  std_logic;
      Clk_En_4       : in  std_logic;
      Clk_En_5       : in  std_logic;
      Clk_En_6       : in  std_logic;
      Clk_En_7       : in  std_logic;
      Addr_out       : out std_logic_vector(C_AWIDTH-1 downto 0);
      Carry_Out      : out std_logic;
      Single_beat    : In  std_logic;
      Cacheline      : In  std_logic;
      burst_bytes    : In  std_logic;
      burst_hwrds    : In  std_logic;
      burst_words    : In  std_logic;
      burst_dblwrds  : In  std_logic;
      BE_clk_en      : in  std_logic;
      BE_in          : In  std_logic_vector(0 to 7);
      BE_out         : Out std_logic_vector(0 to 7)
     );

  end component flex_addr_cntr;

  
  component FDRE is
    port (
      Q  : out std_logic;
      C  : in  std_logic;
      CE : in  std_logic;
      D  : in  std_logic;
      R  : in  std_logic
    );
  end component FDRE;


--TYPES
    
  -- no types
  
             
-- CONSTANTS
  
  
  

--INTERNAL SIGNALS
  Signal  Addr_Cnt_Size_reg : Std_logic_vector(0 to 3);
  Signal  Address_out_i     : std_logic_vector(0 to C_NUM_ADDR_BITS-1);
  Signal  BE_out_i          : std_logic_vector(0 to (C_PLB_DWIDTH/8)-1);
  signal  cken0             : std_logic;
  signal  cken1             : std_logic;
  signal  cken2             : std_logic;
  signal  cken3             : std_logic;
  signal  cken4             : std_logic;
  signal  cken5             : std_logic;
  signal  cken6             : std_logic;
  Signal  cntx1             : std_logic;
  Signal  cntx2             : std_logic;
  Signal  cntx4             : std_logic;
  Signal  cntx8             : std_logic;
  signal  BE_clk_en         : std_logic;
  Signal  clr_addr_be       : std_logic;
  --Signal  BE_clk_en         : std_logic;
  
  Signal  s_h_size          : std_logic_vector(0 to 3);
  Signal  s_h_sngle         : std_logic;
  Signal  s_h_cacheln       : std_logic;
  Signal  s_h_burst         : std_logic;
  
  Signal  bytes             : std_logic;
  Signal  hwrds             : std_logic;
  Signal  words             : std_logic;
  Signal  dblwrds           : std_logic;
    
  Signal  cacheln_4         : std_logic;
  Signal  cacheln_8         : std_logic;
  Signal  cacheln_16        : std_logic;
  
--------------------------------------------------------------------------------------------------------------
-------------------------------------- start of logic -------------------------------------------------
  
begin
  
    
    -- Output assignments
    --Address_out   <=  Address_out_i;  
    --BE_out        <=  BE_out_i;
    
    clr_addr_be   <=  (Xfer_done or Bus_reset) and
                       not(S_H_Qualifiers);
    
    BE_clk_en     <=  Addr_Load or (Addr_Cnt_en and s_h_burst); 
    
    
    
   -- Sample and Hold registers
   
     
      I_SNGL_S_H_REG : FDRE
        port map(
          Q  =>  s_h_sngle,
          C  =>  Bus_clk,
          CE =>  S_H_Qualifiers,
          D  =>  Single,  
          R  =>  clr_addr_be
        );
    
      I_CACHLN_S_H_REG : FDRE
        port map(
          Q  =>  s_h_cacheln,
          C  =>  Bus_clk,
          CE =>  S_H_Qualifiers,
          D  =>  Cacheln,  
          R  =>  clr_addr_be
        );
    
    
      I_BURST_S_H_REG : FDRE
        port map(
          Q  =>  s_h_burst,
          C  =>  Bus_clk,
          CE =>  S_H_Qualifiers,
          D  =>  Burst,  
          R  =>  clr_addr_be 
        );
    
    
      ------------------------------------------------------------
      -- For Generate
      --
      -- Label: GEN_S_H_SIZE_REG
      --
      -- For Generate Description:
      --
      --
      --
      --
      ------------------------------------------------------------
      GEN_S_H_SIZE_REG : for bit_index in 0 to 3 generate
      
      begin
      
        I_SIZE_S_H_REG : FDRE
          port map(
            Q  =>  s_h_size(bit_index),
            C  =>  Bus_clk,
            CE =>  S_H_Qualifiers,
            D  =>  Addr_Cnt_Size(bit_index),  
            R  =>  clr_addr_be 
          );
    
      end generate GEN_S_H_SIZE_REG;
  
    
   
   
   -- use size bits to detirmine cacheln count (if a cacheline xfer)
   
    cacheln_4     <=  s_h_cacheln and not(s_h_size(2)) and s_h_size(3); -- "01"
    
    cacheln_8     <=  s_h_cacheln and s_h_size(2) and not(s_h_size(3)); -- "10"
    
    cacheln_16    <=  s_h_cacheln and s_h_size(2) and s_h_size(3);      -- "11"
   
   
   
   -- use the size bits to detirmine tranfer size (if a burst)
    
    bytes         <=  s_h_burst and not(s_h_size(2)) and not(s_h_size(3)); -- "00"
                                    
    hwrds         <=  s_h_burst and not(s_h_size(2)) and s_h_size(3);      -- "01"
                                    
    words         <=  s_h_burst and s_h_size(2) and not(s_h_size(3));      -- "10"
    
    dblwrds       <=  s_h_burst and s_h_size(2) and s_h_size(3);           -- "11"
    
    
    
    
   -- Set the "count by' controls
   
    cntx1         <=  bytes and not(Addr_Load);
    
    cntx2         <=  hwrds and not(Addr_Load);
    
    cntx4         <=  words and not(Addr_Load);
    
    cntx8         <=  (s_h_cacheln or dblwrds) and not(Addr_Load);
    
    
  
   -- set the clock enables
                  
    cken0         <=  Addr_Load or (Addr_Cnt_en and s_h_burst);
                                                             
    cken1         <=  Addr_Load or (Addr_Cnt_en and s_h_burst);
                                                             
    cken2         <=  Addr_Load or (Addr_Cnt_en and s_h_burst);
    
    cken3         <=  Addr_Load or (Addr_Cnt_en and (s_h_burst or cacheln_4 or cacheln_8 or cacheln_16));
    
    cken4         <=  Addr_Load or (Addr_Cnt_en and (s_h_burst or cacheln_8 or cacheln_16));
    
    cken5         <=  Addr_Load or (Addr_Cnt_en and (s_h_burst or cacheln_16));
    
    cken6         <=  Addr_Load or (s_h_burst and Addr_Cnt_en);
    
    
    
  
  
  I_FLEX_ADDR_CNTR : flex_addr_cntr
    Generic map(
       C_AWIDTH      => C_NUM_ADDR_BITS
       )
      
    port map(
      Clk            =>  Bus_clk,  -- : in  std_logic;
      Rst            =>  clr_addr_be,  -- : in  std_logic;
      Load_Enable    =>  Addr_Load,  -- : in  std_logic;
      Load_addr      =>  Address_In,  -- : in  std_logic_vector(C_AWIDTH-1 downto 0);
      Cnt_by_1       =>  cntx1,  -- : in  std_logic;
      Cnt_by_2       =>  cntx2,  -- : in  std_logic;
      Cnt_by_4       =>  cntx4,  -- : in  std_logic;
      Cnt_by_8       =>  cntx8,  -- : in  std_logic;
      Cnt_by_16      =>  '0',  -- : in  std_logic;
      Cnt_by_32      =>  '0',  -- : in  std_logic;
      Cnt_by_64      =>  '0',  -- : in  std_logic;
      Cnt_by_128     =>  '0',  -- : in  std_logic;
      Clk_En_0       =>  cken0,  -- : in  std_logic;
      Clk_En_1       =>  cken1,  -- : in  std_logic;
      Clk_En_2       =>  cken2,  -- : in  std_logic;
      Clk_En_3       =>  cken3,  -- : in  std_logic;
      Clk_En_4       =>  cken4,  -- : in  std_logic;
      Clk_En_5       =>  cken5,  -- : in  std_logic;
      Clk_En_6       =>  cken6,  -- : in  std_logic;
      Clk_En_7       =>  cken6,  -- : in  std_logic;
      Addr_out       =>  Address_Out,  -- : out std_logic_vector(C_AWIDTH-1 downto 0);
      Carry_Out      =>  open,  -- : out std_logic;
      Single_beat    =>  s_h_sngle,
      Cacheline      =>  s_h_cacheln,
      burst_bytes    =>  bytes,
      burst_hwrds    =>  hwrds,
      burst_words    =>  words,
      burst_dblwrds  =>  dblwrds,
      BE_clk_en      =>  BE_clk_en,  -- : in  std_logic;
      BE_in          =>  BE_in,  -- : In  std_logic_vector(0 to 7);
      BE_out         =>  BE_out  -- : Out std_logic_vector(0 to 7)
     );



        
        
end implementation;
  




