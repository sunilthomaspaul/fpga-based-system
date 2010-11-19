##############################################################################
## Filename:          C:\Baseline_9_Working_Folder\K-new-base/drivers/hwrtos_v1_00_a/data/hwrtos_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Tue Jun 02 12:44:27 2009 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "hwrtos" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
