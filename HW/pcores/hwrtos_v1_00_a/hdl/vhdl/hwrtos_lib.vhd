library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package hwrtos_lib is

type osunmap is array(0 to 255) of std_logic_vector(0 to 2);
  constant osunmaptbl: osunmap := 
	("000", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "110", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "111", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "110", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "101", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000",
	 "100", "000", "001", "000", "010", "000", "001", "000", "011", "000", "001", "000", "010", "000", "001", "000");

type rdy_tbl is array(0 to 7) of std_logic_vector(0 to 7);

	procedure add_to_list (variable atl_prio: 	 in integer;
						 variable atl_rdy_grp_v: inout std_logic_vector;
						 variable atl_rdy_tbl_v: inout rdy_tbl);
						 
   procedure remove_from_list (variable rfl_prio: 	  in integer;
							  variable rfl_rdy_grp_v: inout std_logic_vector;
							  variable rfl_rdy_tbl_v: inout rdy_tbl);
   
	procedure find_hi_prio (variable fhp_rdy_grp_v: in std_logic_vector;
						  variable fhp_rdy_tbl_v: in rdy_tbl;
						  variable fhp_prio_high: out std_logic_vector);

   procedure sched (variable sched_rdy_grp_v: 		in std_logic_vector;
				   variable sched_rdy_tbl_v: 		in rdy_tbl;
				   variable sched_prio_high: 		inout std_logic_vector;
				   variable sched_ctx_sw:  			out std_logic_vector;
				   variable sched_task_ctx_sw_cntr:	out std_logic_vector;
				   variable sched_osctx_sw_cntr:	out std_logic_vector;
				   variable sched_prio_current: 	out std_logic_vector);						  

end hwrtos_lib;




package body hwrtos_lib is

  procedure add_to_list (variable atl_prio: 	 in integer;
						 variable atl_rdy_grp_v: inout std_logic_vector;
						 variable atl_rdy_tbl_v: inout rdy_tbl) is
							
	variable temp_y_int	   	: integer range 0 to 255 := 0;			
  begin				
		temp_y_int 					:= CONV_INTEGER(ostcb(atl_prio).y);
		atl_rdy_grp_v 	   	   	 	:= atl_rdy_grp_v or ostcb(atl_prio).bity;
		atl_rdy_tbl_v(temp_y_int)  	:= atl_rdy_tbl_v(temp_y_int) or ostcb(atl_prio).bitx;		
  end procedure add_to_list;


  procedure remove_from_list (variable rfl_prio: 	  in integer;
							  variable rfl_rdy_grp_v: inout std_logic_vector;
							  variable rfl_rdy_tbl_v: inout rdy_tbl) is
							
	variable temp_y_int	   	: integer range 0 to 255 := 0;			
  begin				
		temp_y_int 					:= CONV_INTEGER(ostcb(rfl_prio).y);
		rfl_rdy_tbl_v(temp_y_int)  	:= rfl_rdy_tbl_v(temp_y_int) and (not ostcb(rfl_prio).bitx);
		if (rfl_rdy_tbl_v(temp_y_int) = X"00") then
				rfl_rdy_grp_v		:= rfl_rdy_grp_v and (not ostcb(rfl_prio).bity);
		end if;		
  end procedure remove_from_list;


		
  procedure find_hi_prio (variable fhp_rdy_grp_v: in std_logic_vector;
						  variable fhp_rdy_tbl_v: in rdy_tbl;
						  variable fhp_prio_high: out std_logic_vector) is
							
	variable temp_y_std	   	: std_logic_vector(0 to 7) := X"00";  
    variable temp_Hprio1   	: std_logic_vector(0 to 7) := X"00";
    variable temp_Hprio2    : std_logic_vector(0 to 7) := X"00";			
  begin				
		temp_y_std  	:= b"00000" & osunmaptbl(CONV_INTEGER(fhp_rdy_grp_v));			
		temp_Hprio1 	:= STD_LOGIC_VECTOR(shl(UNSIGNED(temp_y_std),CONV_UNSIGNED(3,2)));
		temp_Hprio2 	:= b"00000" & osunmaptbl(CONV_INTEGER(fhp_rdy_tbl_v(CONV_INTEGER(temp_y_std))));
		fhp_prio_high   := temp_Hprio1 + temp_Hprio2;	
  end procedure find_hi_prio;
		
			
			
  procedure sched (variable sched_rdy_grp_v: 		in std_logic_vector;
				   variable sched_rdy_tbl_v: 		in rdy_tbl;
				   variable sched_prio_high: 		inout std_logic_vector;
				   variable sched_ctx_sw:  			out std_logic_vector;
				   variable sched_task_ctx_sw_cntr:	out std_logic_vector;
				   variable sched_osctx_sw_cntr:	out std_logic_vector;
				   variable sched_prio_current: 	out std_logic_vector) is
							
	
	variable hindex   		: integer range 0 to 15 := 0;			
  begin				
		find_hi_prio (sched_rdy_grp_v, sched_rdy_tbl_v, sched_prio_high);			
		hindex 	    := CONV_INTEGER(sched_prio_high);			
		if (sched_prio_high /= osprio_current) then
			sched_ctx_sw      		:= X"01";
			sched_task_ctx_sw_cntr 	:= ostcb(hindex).ctx_sw_cntr + 1;
			sched_osctx_sw_cntr 	:= osctx_sw_cntr + 1;
			sched_prio_current      := sched_prio_high;			
		else 
			sched_ctx_sw      		:= X"02";
			sched_task_ctx_sw_cntr 	:= ostcb(hindex).ctx_sw_cntr;
			sched_osctx_sw_cntr 	:= osctx_sw_cntr;
			sched_prio_current      := osprio_current;
		end if;
  end procedure sched;
  
end hwrtos_lib;  