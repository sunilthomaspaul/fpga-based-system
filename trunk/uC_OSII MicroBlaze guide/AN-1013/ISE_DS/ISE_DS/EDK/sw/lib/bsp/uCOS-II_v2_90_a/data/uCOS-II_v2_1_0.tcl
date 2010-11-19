################################################################################
#                             uC/OS-II Tcl File
################################################################################

# uses xillib.tcl

proc ucosii_drc {os_handle} {
    puts "uC/OS-II DRC ..."

    set sw_proc_handle [xget_libgen_proc_handle]
    set hw_proc_handle [xget_handle $sw_proc_handle "IPINST"]
    set proctype [xget_value $hw_proc_handle "OPTION" "IPNAME"]

    set source_path [xget_value $os_handle "PARAMETER" "OS_SOURCE_LOCATION"]
    set core_name [file join $source_path os_core.c]
    if {[file exists $core_name] == 0} {
        error "Unable to find uC/OS-II source file, os_core.c. Be sure to check that the 'OS_SOURCE_LOCATION' value in the 'FILE LOCATION' name under the BSP settings is correct" "" "libgen_error" 
    }
    set flag_name [file join $source_path os_flag.c]
    if {[file exists $flag_name] == 0} {
        error "Unable to find uC/OS-II source file, os_flag.c" "" "libgen_error" 
    }
    set mbox_name [file join $source_path os_mbox.c]
    if {[file exists $mbox_name] == 0} {
        error "Unable to find uC/OS-II source file, os_mbox.c" "" "libgen_error" 
    }
    set mem_name [file join $source_path os_mem.c]
    if {[file exists $mem_name] == 0} {
        error "Unable to find uC/OS-II source file, os_mem.c" "" "libgen_error" 
    }
    set mutex_name [file join $source_path os_mutex.c]
    if {[file exists $mutex_name] == 0} {
        error "Unable to find uC/OS-II source file, os_mutex.c" "" "libgen_error" 
    }
    set q_name [file join $source_path os_q.c]
    if {[file exists $q_name] == 0} {
        error "Unable to find uC/OS-II source file, os_q.c" "" "libgen_error" 
    }
    set sem_name [file join $source_path os_sem.c]
    if {[file exists $sem_name] == 0} {
        error "Unable to find uC/OS-II source file, os_sem.c" "" "libgen_error"
    }
    set task_name [file join $source_path os_task.c]
    if {[file exists $task_name] == 0} {
        error "Unable to find uC/OS-II source file, os_task.c" "" "libgen_error"
    }
    set time_name [file join $source_path os_time.c]
    if {[file exists $time_name] == 0} {
        error "Unable to find uC/OS-II source file, os_time.c" "" "libgen_error"
    }
    set tmr_name [file join $source_path os_tmr.c]
    if {[file exists $tmr_name] == 0} {
        error "Unable to find uC/OS-II source file, os_tmr.c" "" "libgen_error"
    }
    set ucosii_name [file join $source_path ucos_ii.h]
    if {[file exists $ucosii_name] == 0} {
       error "Unable to find uC/OS-II header file, ucos_ii.h" "" "libgen_error"
    }
    if { $proctype == "microblaze" } {
         set dbg_name [file join $source_path/Microblaze os_dbg.c]
         if {[file exists $dbg_name] == 0} {
             error "Unable to find uC/OS-II port file, os_dbg.c" "" "libgen_error"
         }
         set cpus_name [file join $source_path/Microblaze os_cpu_a.s]
         if {[file exists $cpus_name] == 0} {
             error "Unable to find uC/OS-II port file, os_cpu_a.s" "" "libgen_error"
         }
         set cpuc_name [file join $source_path/Microblaze os_cpu_c.c]
         if {[file exists $cpuc_name] == 0} {
             error "Unable to find uC/OS-II port file, os_cpu_c.c" "" "libgen_error"
         }
         set cpuh_name [file join $source_path/Microblaze os_cpu.h]
         if {[file exists $cpuh_name] == 0} {
             error "Unable to find uC/OS-II port file os_cpu.h" "" "libgen_error"
         }
    } else {
        set dbg_name [file join $source_path/PPC405 os_dbg.c]
        if {[file exists $dbg_name] == 0} {
            error "Unable to find uC/OS-II port file, os_dbg.c" "" "libgen_error"
        }
        set cpus_name [file join $source_path/PPC405 os_cpu_a.S]
        if {[file exists $cpus_name] == 0} {
            error "Unable to find uC/OS-II port file, os_cpu_a.s" "" "libgen_error"
        }
        set cpuc_name [file join $source_path/PPC405 os_cpu_c.c]
        if {[file exists $cpuc_name] == 0} {
            error "Unable to find uC/OS-II port file, os_cpu_c.c" "" "libgen_error"
        }
        set cpuh_name [file join $source_path/PPC405 os_cpu.h]
        if {[file exists $cpuh_name] == 0} {
            error "Unable to find uC/OS-II port file os_cpu.h" "" "libgen_error"
        }
    }
    set app_cfg_file [file join $source_path app_cfg.h]
    if {[file exists $app_cfg_file] == 0} {
        error "Unable to locate app_cfg.h" "" "libgen_error"
    }
    set cpu_def [file join $source_path cpu_def.h]
    if {[file exists $cpu_def] == 0} {
        error "Unable to locate uC/CPU file, cpu_def.h" "" "libgen error"
    }
    set cpu_cfg [file join $source_path cpu_cfg.h]
    if {[file exists $cpu_cfg] == 0} {
        error "Unable to locate uC/CPU file, cpu_cfg.h" "" "libgen error"
    }
    set cpu_coreh [file join $source_path cpu_core.h]
    if {[file exists $cpu_coreh] == 0} {
        error "Unable to locate uC/CPU file, cpu_core.h" "" "libgen error"
    }
    set cpu_corec [file join $source_path cpu_core.c]
    if {[file exists $cpu_corec] == 0} {
        error "Unable to locate uC/CPU file, cpu_core.c" "" "libgen error"
    }
    if { $proctype == "microblaze" } {
        
         set cpuasm [file join $source_path MicroBlaze/cpu_a.s]
         if {[file exists $cpuasm] == 0} {
             error "Unable to locate uC/CPU file, cpu_a.s" "" "libgen_error"
         }
         set cpuh [file join $source_path MicroBlaze/cpu.h]
	   if {[file exists $cpuh] == 0} {
	       error "Unable to locate uC/CPU file, cpu.h" "" "libgen_error"
	   }
         
    } else {
        
          set cpuasm [file join $source_path PPC405/cpu_a.s]
	    if {[file exists $cpuasm] == 0} {
		  error "Unable to locate uC/CPU file, cpu_a.s" "" "libgen_error"
	    }
	    set cpuh [file join $source_path PPC405/cpu.h]
	    if {[file exists $cpuh] == 0} {
		  error "Unable to locate uC/CPU file, cpu.h" "" "libgen_error"
	    }
    }
    set lib_ascii [file join $source_path lib_ascii.c]
    if {[file exists $lib_ascii] == 0} {
        error "Unable to locate uC/LIB file, lib_ascii.c" "" "libgen error"
    }
    set lib_asciih [file join $source_path lib_ascii.h]
    if {[file exists $lib_asciih] == 0} {
	  error "Unable to locate uC/LIB file, lib_ascii.h" "" "libgen error"
    }
    set lib_math [file join $source_path lib_math.c]
    if {[file exists $lib_math] == 0} {
         error "Unable to locate uC/LIB file, lib_math.c" "" "libgen error"
    }
    set lib_mathh [file join $source_path lib_math.h]
    if {[file exists $lib_mathh] == 0} {
         error "Unable to locate uC/LIB file, lib_math.h" "" "libgen error"
    }
    set lib_mem [file join $source_path lib_mem.c]
    if {[file exists $lib_mem] == 0} {
        error "Unable to locate uC/LIB file, lib_mem.c" "" "libgen error"
    }
    set lib_str [file join $source_path lib_str.c]
    if {[file exists $lib_str] == 0} {
	  error "Unable to locate uC/LIB file, lib_str.c" "" "libgen error"
    }
    set lib_memh [file join $source_path lib_mem.h]
    if {[file exists $lib_memh] == 0} {
         error "Unable to locate uC/LIB file, lib_mem.h" "" "libgen error"
    }
    set lib_strh [file join $source_path lib_str.h]
    if {[file exists $lib_strh] == 0} {
         error "Unable to locate uC/LIB file, lib_str.h" "" "libgen error"
    }
    set lib_defh [file join $source_path lib_def.h]
    if {[file exists $lib_defh] == 0} {
         error "Unable to locate uC/LIB file, lib_def.h" "" "libgen error"
    }
    
    if {[xget_value $os_handle "PARAMETER" "PROBE_EN"] == 1} {
	     
        set genericc_name [file join $source_path Communication/Generic/Source/probe_com.c]
        if {[file exists $genericc_name] == 0} {
            error "Unable to find uC/Probe source file, probe_com.c" "" "libgen_error"
        }
		  
        set generich_name [file join $source_path Communication/Generic/Source/probe_com.h]
        if {[file exists $generich_name] == 0} {
            error "Unable to find uC/Probe source file, probe_com.h" "" "libgen_error"
        }
		  
		  set generic_os_name [file join $source_path Communication/Generic/OS/uCOS-II/probe_com_os.c]
		  if {[file exists $generic_os_name] == 0} {
		      error "Unable to find uC/Probe source file, probe_com_os.c" "" "libgen_error"
		  }

        set rs232c_name [file join $source_path Communication/Generic/RS-232/Source/probe_rs232.c]
		  if {[file exists $rs232c_name] == 0} {
		      error "Unable to find uC/Probe source file, probe_rs232.c" "" "libgen_error"
	     }
		  
		  set rs232h_name [file join $source_path Communication/Generic/RS-232/Source/probe_rs232.h]
		  if {[file exists $rs232h_name] == 0} {
		      error "Unable to find uC/Probe source file, probe_rs232.h" "" "libgen_error"
		  }
		  
		  set rs232_os_name [file join $source_path Communication/Generic/RS-232/OS/uCOS-II/probe_rs232_os.c]
		  if {[file exists $rs232_os_name] == 0} {
		      error "Unable to find uC/Probe source file, probe_rs232_os.c" "" "libgen_error"
		  }
        set portc_name [file join $source_path probe_rs232c.c]
        if {[file exists $portc_name] == 0} {
            error "Unable to find uC/Probe port file, probe_rs232c.c" "" "libgen_error"
        }
        set porth_name [file join $source_path probe_rs232c.h]
        if {[file exists $porth_name] == 0} {
            error "Unable to find uC/Probe port file, probe_rs232c.h" "" "libgen_error"
        }
		  
		  if {[xget_value $os_handle "PARAMETER" "PROBE_OS_EN"] == 1} {
		      
		      set pluginc_name [file join $source_path Plugins/uCOS-II/os_probe.c]
				if {[file exists $pluginc_name] == 0} {
				    error "Unable to find uC/Probe plug-in file, os_probe.c" "" "libgen_error"
				}
			set pluginh_name [file join $source_path Plugins/uCOS-II/os_probe.h]
				if {[file exists $pluginh_name] == 0} {
				    error "Unable to find uC/Probe plug-in file, os_probe.h" "" "libgen_error"
				}
        }		  
    }
}

###############################################################################
#                            Tcl procedure generate
###############################################################################

proc generate {os_handle} {
    
    global env

    set need_config_file "false"

    # Copy over the right set of files as src based on processor type
    set sw_proc_handle [xget_libgen_proc_handle]
    set hw_proc_handle [xget_handle $sw_proc_handle "IPINST"]

    set proctype [xget_value $hw_proc_handle "OPTION" "IPNAME"]
    set procver [xget_value $hw_proc_handle "PARAMETER" "HW_VER"]
    set enable_sw_profile [xget_value $os_handle "PARAMETER" "enable_sw_intrusive_profiling"]
    set mb_exceptions false

    # proctype should be "microblaze" or "ppc405" or "ppc405_virtex4" or "ppc440" or "ppc440_virtex5"
    set mbsrcdir "./src/microblaze"
    set ppcsrcdir "./src/ppc405"
    set ppc440srcdir "./src/ppc440"
    set commonsrcdir "./src/common"

    foreach entry [glob -nocomplain [file join $commonsrcdir *]] {
        file copy -force $entry "./src"
    }

    switch $proctype {
	"microblaze" { 
            foreach entry [glob -nocomplain [file join $mbsrcdir *]] {
		if { [string first "exception" $entry] == -1 || [mb_has_exceptions $hw_proc_handle] } {
		    # Copy over only files that are not related to exception handling. All such files have exception in their names
		    file copy -force $entry "./src/"
		}
            }
	    set need_config_file "true"
	    set mb_exceptions [mb_has_exceptions $hw_proc_handle]
	}
	"ppc405"  {
	    foreach entry [glob -nocomplain [file join $ppcsrcdir *]] {
		file copy -force $entry "./src/"
	    }
	}
	"ppc405_virtex4"  {
	    foreach entry [glob -nocomplain [file join $ppcsrcdir *]] {
		file copy -force $entry "./src/"
	    }
	}
	
	"ppc440"  {
	    foreach entry [glob -nocomplain [file join $ppc440srcdir *]] {
		file copy -force $entry "./src/"
	    }
	}
	"ppc440_virtex5"  {
	    foreach entry [glob -nocomplain [file join $ppc440srcdir *]] {
		file copy -force $entry "./src/"
	    }
	}
	"default" {puts "unknown processor type $proctype\n"}
    }

    # Write the Config.make file
    set makeconfig [open "./src/config.make" w]
#    xprint_generated_header_tcl $makeconfig "Configuration parameters for Standalone Makefile"
    if { $proctype == "microblaze" } {
        puts $makeconfig "LIBSOURCES = *.c *.s *.S"
	puts $makeconfig "PROFILE_ARCH_OBJS = profile_mcount_mb.o"
    } else {
	puts $makeconfig "PROFILE_ARCH_OBJS = profile_mcount_ppc.o"
    }
    if { $enable_sw_profile == "true" } {
	puts $makeconfig "LIBS = standalone_libs profile_libs"
    } else {
	puts $makeconfig "LIBS = standalone_libs"
    }
    close $makeconfig
    
    # Remove microblaze , ppc405 and ppc440 directories...
    file delete -force $mbsrcdir
    file delete -force $ppcsrcdir
    file delete -force $ppc440srcdir
    
    # Handle stdin and stdout
    xhandle_stdin $os_handle
    xhandle_stdout $os_handle
    
    #Handle Profile configuration
    if { $enable_sw_profile == "true" } {
	handle_profile $os_handle $proctype	
    }
    
    set file_handle [xopen_include_file "xparameters.h"]
    puts $file_handle "\n/******************************************************************/\n"
    close $file_handle

    # Generate xil_malloc.h if required
    set xil_malloc [xget_value $os_handle "PARAMETER" "need_xil_malloc"]
    if {[string compare -nocase $xil_malloc "true"] == 0} {
	xcreate_xil_malloc_config_file 
    }

    # Create config files for Microblaze exception handling
    if { $proctype == "microblaze" && [mb_has_exceptions $hw_proc_handle] } {
        set extable [xget_handle $os_handle "ARRAY" "microblaze_exception_vectors"]
        xcreate_mb_exc_config_file $extable $os_handle
    } 

    # Create bspconfig file
    set bspcfg_fn [file join "src" "bspconfig.h"] 
    file delete $bspcfg_fn
    set bspcfg_fh [open $bspcfg_fn w]
    xprint_generated_header $bspcfg_fh "Configurations for Standalone BSP"

    if { $proctype == "microblaze" && [mb_has_pvr $hw_proc_handle] } {
        
        set pvr [xget_value $hw_proc_handle "PARAMETER" "C_PVR"]
        
        switch $pvr {
            "0" {
                puts $bspcfg_fh "#define MICROBLAZE_PVR_NONE"
            }
            "1" {
                puts $bspcfg_fh "#define MICROBLAZE_PVR_BASIC"
            }
            "2" {
                puts $bspcfg_fh "#define MICROBLAZE_PVR_FULL"
            }
            "default" {
                puts $bspcfg_fh "#define MICROBLAZE_PVR_NONE"
            }
        }    
    } else {
        puts $bspcfg_fh "#define MICROBLAZE_PVR_NONE"
    }

    close $bspcfg_fh

    copy_os_files $os_handle

    create_os_config_file $os_handle
}

# -------------------------------------------
# Tcl procedure xcreate_mb_exc_config file
# -------------------------------------------
proc xcreate_mb_exc_config_file {extable os_handle} {
    
    set mb_table "MB_ExceptionVectorTable"

    set filename [file join "src" "microblaze_exceptions_g.c"] 
    set hfilename [file join "src" "microblaze_exceptions_g.h"] 

    file delete $filename
    file delete $hfilename
    set config_file [open $filename w]
    set hconfig_file [open $hfilename w]

    xprint_generated_header $config_file "Exception Handler Table for MicroBlaze Processor"
    xprint_generated_header $hconfig_file "Exception Handling Header for MicroBlaze Processor"
    
    puts $config_file "#include \"microblaze_exceptions_i.h\""
    puts $config_file "#include \"xparameters.h\""
    puts $config_file "\n"

    set sw_proc_handle [xget_libgen_proc_handle]
    set hw_proc_handle [xget_handle $sw_proc_handle "IPINST"]
    set procver [xget_value $hw_proc_handle "PARAMETER" "HW_VER"]
    

    set interconnect [xget_value $hw_proc_handle "PARAMETER" "C_INTERCONNECT"]
    if { $interconnect == "" || $interconnect == 0 } {
        set ibus_ee [xget_value $hw_proc_handle "PARAMETER" "C_IOPB_BUS_EXCEPTION"]
        set dbus_ee [xget_value $hw_proc_handle "PARAMETER" "C_DOPB_BUS_EXCEPTION"]
    } else {
        set ibus_ee [xget_value $hw_proc_handle "PARAMETER" "C_IPLB_BUS_EXCEPTION"]
        set dbus_ee [xget_value $hw_proc_handle "PARAMETER" "C_DPLB_BUS_EXCEPTION"]
    }

    set ill_ee [xget_value $hw_proc_handle "PARAMETER" "C_ILL_OPCODE_EXCEPTION"]
    set unalign_ee [xget_value $hw_proc_handle "PARAMETER" "C_UNALIGNED_EXCEPTIONS"]
    set div0_ee [xget_value $hw_proc_handle "PARAMETER" "C_DIV_ZERO_EXCEPTION"]
    set mmu_ee [xget_value $hw_proc_handle "PARAMETER" "C_USE_MMU"]
    if { $mmu_ee == "" } {
        set mmu_ee 0
    }

    set fsl_ee [xget_value $hw_proc_handle "PARAMETER" "C_USE_FSL"]
    if { $fsl_ee == "" } {
        set fsl_ee 0
    }

    if { [mb_has_fpu_exceptions $hw_proc_handle] } {
        set fpu_ee [xget_value $hw_proc_handle "PARAMETER" "C_FPU_EXCEPTION"]
    } else {
        set fpu_ee 0
    }

    if { $ibus_ee == 0 && $dbus_ee == 0 && $ill_ee == 0 && $unalign_ee == 0 && $div0_ee == 0 && $fpu_ee == 0 && $mmu_ee == 0 && $fsl_ee == 0} { ;# NO exceptions are enabled
        close $config_file              ;# Do not generate any info in either the header or the C file
        close $hconfig_file
        return
    } 

    puts $hconfig_file "\#define MICROBLAZE_EXCEPTIONS_ENABLED 1"
    if { [mb_can_handle_exceptions_in_delay_slots $procver] } {
        puts $hconfig_file "#define MICROBLAZE_CAN_HANDLE_EXCEPTIONS_IN_DELAY_SLOTS"
    }
    
    if { $unalign_ee == 0 } {
        puts $hconfig_file "\#define NO_UNALIGNED_EXCEPTIONS 1"
    }
    if { $ibus_ee == 0 && $dbus_ee == 0 && $ill_ee == 0 && $div0_ee == 0 && $fpu_ee == 0 && $mmu_ee == 0 && $fsl_ee == 0 } { ;# NO other exceptions are enabled
        puts $hconfig_file "\#define NO_OTHER_EXCEPTIONS 1"
    }
        
    if { $fpu_ee != 0 } {
        puts $hconfig_file "\#define MICROBLAZE_FP_EXCEPTION_ENABLED 1"        
        set predecode_fpu_exceptions [xget_value $os_handle "PARAMETER" "predecode_fpu_exceptions"]
        if {$predecode_fpu_exceptions != false } {
            puts $hconfig_file "\#define MICROBLAZE_FP_EXCEPTION_DECODE 1"        
        }   
    }

    set elements [xget_handle $extable "ELEMENTS" "*"]  
    set ehlen [llength $elements]
    
    #
    # Put in extern declarations for handlers
    #
    puts $config_file "\n/*"
    puts $config_file "* Extern declarations"
    puts $config_file "*/\n"

   
    # Routinely handle other exceptions
    for {set x 0} {$x < $ehlen} {incr x} {
        set entry [lindex $elements $x]
        set eh [xget_value $entry "PARAMETER" "handler"]
        if {$eh != "XNullHandler"} {		   
	    if { ![info exists handler_array($eh)]} {
		   set handler_array($eh) 1
		  puts $config_file [format "extern void %s (void *);" $eh]
	    } 
	    
        }
    }
    
    #
    # Form the exception handler table
    #
    puts $config_file "\n/*"
    puts $config_file "* The exception handler table for microblaze processor"
    puts $config_file "*/\n"
    puts $config_file "void microblaze_register_exception_handlers()"
    
    # Routinely handle other exceptions
    puts $config_file "\{"
    for {set x 0} {$x < $ehlen } {incr x} {
        set entry [lindex $elements $x]
        set eh [xget_value $entry "PARAMETER" "handler"]
        set eec [xget_value $entry "PARAMETER" "callback"]
	if {$eh != "XNullHandler"} {	
		puts $config_file [format "\tmicroblaze_register_exception_handler(%s, (XExceptionHandler)&%s, (void *)%s);" $x $eh $eec] 
	}
    }
    
    puts $config_file "\n\};"

    puts $config_file "\n"
    puts $hconfig_file "\n"

    close $config_file
    close $hconfig_file
}

###############################################################################
#               Tcl procedure xcreate_xil_malloc_config_file
###############################################################################

proc xcreate_xil_malloc_config_file {} {
    
    set filename [file join "src" "xil_malloc.h"] 
    file delete $filename
    set config_file [open $filename w]
    
    xprint_generated_header $config_file "Xilinx Malloc Definition file"
    puts $config_file "#define malloc xil_malloc"
    puts $config_file "\n"
    close $config_file
    
}

###############################################################################
#                      Tcl procedure copy_os_files
###############################################################################

proc copy_os_files {ucos_handle} {

    set sw_proc_handle [xget_libgen_proc_handle]
    set hw_proc_handle [xget_handle $sw_proc_handle "IPINST"]
    set proctype [xget_value $hw_proc_handle "OPTION" "IPNAME"]
    set msr_instr [xget_value $hw_proc_handle "PARAMETER" "C_USE_MSR_INSTR"]

    set source_path [xget_value $ucos_handle "PARAMETER" "OS_SOURCE_LOCATION"]
    set core_name [file join $source_path os_core.c]
    set flag_name [file join $source_path os_flag.c]
    set mbox_name [file join $source_path os_mbox.c]
    set mem_name [file join $source_path os_mem.c]
    set mutex_name [file join $source_path os_mutex.c]
    set q_name [file join $source_path os_q.c]
    set sem_name [file join $source_path os_sem.c]
    set task_name [file join $source_path os_task.c]
    set time_name [file join $source_path os_time.c]
    set tmr_name [file join $source_path os_tmr.c]
    set ucosii_name [file join $source_path ucos_ii.h]

    file copy -force $core_name $flag_name $mbox_name $mem_name $mutex_name $q_name $sem_name $task_name $time_name $tmr_name $ucosii_name ./src/
    file copy -force $ucosii_name ../../include/

    set port_path [xget_value $ucos_handle "PARAMETER" "OS_SOURCE_LOCATION"]
    if { $proctype == "microblaze" } {
        set dbg_name [file join $port_path/Microblaze os_dbg.c]
        if { $msr_instr != 1 } {
            set cpus_name [file join $port_path/Microblaze os_cpu_a.s]
        } else {
            set cpus_name [file join $port_path/Microblaze/USE_MSR_INSTR/os_cpu_a.s]
        }
        set cpus_name [file join $port_path/Microblaze os_cpu_a.S]
        set cpuc_name [file join $port_path/Microblaze os_cpu_c.c]
        set cpuh_name [file join $port_path/Microblaze os_cpu.h]
    } else {
        set dbg_name [file join $port_path/PPC405 os_dbg.c]
        set cpus_name [file join $port_path/PPC405 os_cpu_a.S]
        set cpuc_name [file join $port_path/PPC405 os_cpu_c.c]
        set cpuh_name [file join $port_path/PPC405 os_cpu.h]
    } 
    file copy -force $dbg_name $cpus_name $cpuc_name $cpuh_name ./src/
    file copy -force $cpuh_name ../../include/

    set uclib_path [xget_value $ucos_handle "PARAMETER" "OS_SOURCE_LOCATION"]
    set lib_mem [file join $uclib_path lib_mem.c]
    set lib_str [file join $uclib_path lib_str.c]
    set lib_memh [file join $uclib_path lib_mem.h]
    set lib_strh [file join $uclib_path lib_str.h]
    set lib_def [file join $uclib_path lib_def.h]
    set lib_ascii [file join $uclib_path lib_ascii.c]
    set lib_asciih [file join $uclib_path lib_ascii.h]
    set lib_math [file join $uclib_path lib_math.c]
    set lib_mathh [file join $uclib_path lib_math.h]

    file copy -force $lib_mem $lib_str $lib_memh $lib_strh $lib_def $lib_ascii $lib_math ./src/
    file copy -force $lib_memh $lib_strh $lib_def $lib_asciih $lib_mathh ../../include/

    set uccpu_path [xget_value $ucos_handle "PARAMETER" "OS_SOURCE_LOCATION"]
    set cpu_def [file join $uccpu_path cpu_def.h]
    set cpu_cfg [file join $uccpu_path cpu_cfg.h]
    set cpu_coreh [file join $uccpu_path cpu_core.h]
    set cpu_corec [file join $uccpu_path cpu_core.c]

        if { $proctype == "microblaze" } {
            set cpu_h [file join $uccpu_path MicroBlaze/cpu.h]
            set cpu_a [file join $uccpu_path MicroBlaze/cpu_a.s]
        } else {
            set cpu_h [file join $uccpu_path PPC405/cpu.h]
            set cpu_a [file join $uccpu_path PPC405/cpu_a.s]
        }
  
    file copy -force $cpu_def $cpu_h $cpu_a $cpu_corec ./src/
    file copy -force $cpu_def $cpu_h $cpu_cfg $cpu_coreh ../../include/

    if {[xget_value $ucos_handle "PARAMETER" "PROBE_EN"] == 1} {
	 
        set probe_source [xget_value $ucos_handle "PARAMETER" "OS_SOURCE_LOCATION"]
        set genericc_name [file join $probe_source Communication/Generic/Source/probe_com.c]
        set generich_name [file join $probe_source Communication/Generic/Source/probe_com.h]
		  
		  set generic_os_name [file join $probe_source Communication/Generic/OS/uCOS-II/probe_com_os.c]
		  
		  set rs232c_name [file join $probe_source Communication/Generic/RS-232/Source/probe_rs232.c]
		  set rs232h_name [file join $probe_source Communication/Generic/RS-232/Source/probe_rs232.h]
		  set rs232_os_name [file join $probe_source Communication/Generic/RS-232/OS/uCOS-II/probe_rs232_os.c]
		  
        file copy -force $genericc_name $generic_os_name $rs232c_name $rs232_os_name $generich_name $rs232h_name ./src/
        file copy -force $generich_name $rs232h_name ../../include/

        set probe_port [xget_value $ucos_handle "PARAMETER" "OS_SOURCE_LOCATION"]
        set portc_name [file join $probe_port probe_rs232c.c]
        set porth_name [file join $probe_port probe_rs232c.h]

        file copy -force $portc_name $porth_name ./src/
        file copy -force $porth_name ../../include/
		  
        if {[xget_value $ucos_handle "PARAMETER" "PROBE_OS_EN"] == 1} {	
            set pluginc_name [file join $probe_source Plugins/uCOS-II/os_probe.c]
            set pluginh_name [file join $probe_source Plugins/uCOS-II/os_probe.h]   

            file copy -force $pluginc_name $pluginh_name ./src/
            file copy -force $pluginh_name ../../include/				
        }		  
    }

    set app_path [xget_value $ucos_handle "PARAMETER" "OS_SOURCE_LOCATION"]
    set app_cfg_file [file join $app_path app_cfg.h]
    file copy -force $app_cfg_file ../../include/
}

###############################################################################
#                 Tcl procedure create_os_config_file
###############################################################################

proc create_os_config_file {ucos_handle} {


    set filename "./src/os_cfg.h"
    file delete $filename
    set config_file [open $filename w]

    puts $config_file "/*"
    puts $config_file "**********************************************************************************************************"
    puts $config_file "* This is the uC/OS-II configuration file created by the LibGen generate procedure.  The constants in    *"
    puts $config_file "* this file can be modified through your project's Software Platform Settings.                           *"  
    puts $config_file "*                                                                                                        *"
    puts $config_file "**********************************************************************************************************"
    puts $config_file "*/\n\n"           

    puts $config_file "#ifndef OS_CFG_H"
    puts $config_file "#define OS_CFG_H\n"

    puts $config_file "                                         /* ------------------------ uC/OS-View ------------------------ */"
    set view_en [xget_value $ucos_handle "PARAMETER" "OS_VIEW_MODULE"]
    puts $config_file [format "#define OS_VIEW_MODULE            %s      /* When 1, indicates that uC/OS-View is present                 */\n" $view_en]

    puts $config_file "                                         /* --------------------- TASK STACK SIZE ---------------------- */"
    set task_tmr_stk_size [xget_value $ucos_handle "PARAMETER" "OS_TASK_TMR_STK_SIZE"]
    puts $config_file [format "#define OS_TASK_TMR_STK_SIZE      %s    /* Timer task stack size (# of OS_STK wide entries)             */" $task_tmr_stk_size]
    set task_stat_stk_size [xget_value $ucos_handle "PARAMETER" "OS_TASK_STAT_STK_SIZE"]
    puts $config_file [format "#define OS_TASK_STAT_STK_SIZE     %s    /* Statistics task stack size (# of OS_STK wide entries)        */" $task_stat_stk_size]
    set task_idle_stk_size [xget_value $ucos_handle "PARAMETER" "OS_TASK_IDLE_STK_SIZE"]
    puts $config_file [format "#define OS_TASK_IDLE_STK_SIZE     %s    /* Idle task stack size (# of OS_STK wide entries)              */\n" $task_idle_stk_size]


    puts $config_file "                                         /* ---------------------- MISCELLANEOUS ----------------------- */"
	 set app_hooks_en [xget_value $ucos_handle "PARAMETER" "OS_APP_HOOKS_EN"]
	 puts $config_file [format "#define OS_APP_HOOKS_EN           %s      /* Application-defined hooks are called from the uC/OS-II hooks */" $app_hooks_en]
    set arg_chk_en [xget_value $ucos_handle "PARAMETER" "OS_ARG_CHK_EN"]
    puts $config_file [format "#define OS_ARG_CHK_EN             %s      /* Enable (1) or Disable (0) argument checking                  */" $arg_chk_en]
    set cpu_hooks_en [xget_value $ucos_handle "PARAMETER" "OS_CPU_HOOKS_EN"]
    puts $config_file [format "#define OS_CPU_HOOKS_EN           %s      /* uC/OS-II hooks are found in the processor port files         */\n" $cpu_hooks_en]

    set debug_en [xget_value $ucos_handle "PARAMETER" "OS_DEBUG_EN"]
    puts $config_file [format "#define OS_DEBUG_EN               %s      /* Enable(1) debug variables                                    */\n" $debug_en]

    set event_multi_en [xget_value $ucos_handle "PARAMETER" "OS_EVENT_MULTI_EN"]
	 puts $config_file [format "#define OS_EVENT_MULTI_EN         %s      /* Include code for OSEventPendMulti()                          */" $event_multi_en]
    set event_name_size [xget_value $ucos_handle "PARAMETER" "OS_EVENT_NAME_EN"]
    puts $config_file [format "#define OS_EVENT_NAME_EN        %s     /* Enable names for Sem, Mutex, Mbox and Q    */\n" $event_name_size]

    set lowest_prio [xget_value $ucos_handle "PARAMETER" "OS_LOWEST_PRIO"]
    puts $config_file [format "#define OS_LOWEST_PRIO            %s     /* Defines the lowest priority that can be assigned ...         */" $lowest_prio]
    puts $config_file "                                         /* ... MUST NEVER be higher than 63                             */\n"

    set max_events [xget_value $ucos_handle "PARAMETER" "OS_MAX_EVENTS"]
    puts $config_file [format "#define OS_MAX_EVENTS             %s    /* Max. number of event control blocks in your application      */" $max_events]
    set max_flags [xget_value $ucos_handle "PARAMETER" "OS_MAX_FLAGS"]
    puts $config_file [format "#define OS_MAX_FLAGS              %s      /* Max. number of Event Flag Groups    in your application      */" $max_flags]
    set max_mem_part [xget_value $ucos_handle "PARAMETER" "OS_MAX_MEM_PART"]
    puts $config_file [format "#define OS_MAX_MEM_PART           %s      /* Max. number of memory partitions                             */" $max_mem_part]
    set max_qs [xget_value $ucos_handle "PARAMETER" "OS_MAX_QS"]
    puts $config_file [format "#define OS_MAX_QS                 %s      /* Max. number of queue control blocks in your application      */" $max_qs]
    set max_tasks [xget_value $ucos_handle "PARAMETER" "OS_MAX_TASKS"]
    puts $config_file [format "#define OS_MAX_TASKS              %s      /* Max. number of tasks in your application, MUST be >= 2       */\n" $max_tasks]

    set sched_lock_en [xget_value $ucos_handle "PARAMETER" "OS_SCHED_LOCK_EN"]
    puts $config_file [format "#define OS_SCHED_LOCK_EN          %s      /* Include code for OSSchedLock() and OSSchedUnlock() when 1    */\n" $sched_lock_en]

    set task_stat_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_STAT_EN"]
    puts $config_file [format "#define OS_TASK_STAT_EN           %s      /* Enable (1) or Disable(0) the statistics task                 */" $task_stat_en]
    set task_stat_stk_chk_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_STAT_STK_CHK_EN"]
    puts $config_file [format "#define OS_TASK_STAT_STK_CHK_EN   %s      /* Check task stacks from statistic task                        */\n" $task_stat_stk_chk_en]

    set tick_step_en [xget_value $ucos_handle "PARAMETER" "OS_TICK_STEP_EN"]
    puts $config_file [format "#define OS_TICK_STEP_EN           %s      /* Enable tick stepping feature for uC/OS-View                  */" $tick_step_en]
    set ticks_per_sec [xget_value $ucos_handle "PARAMETER" "OS_TICKS_PER_SEC"]
    puts $config_file [format "#define OS_TICKS_PER_SEC          %s    /* Set the number of ticks in one second                        */\n" $ticks_per_sec]

    puts $config_file "                                         /* ----------------------- EVENT FLAGS -------------------------*/"
    set flag_en [xget_value $ucos_handle "PARAMETER" "OS_FLAG_EN"]
    puts $config_file [format "#define OS_FLAG_EN                %s      /* Enable (1) or Disable (0) code generation for EVENT FLAGS    */" $flag_en]
    set flag_wait_clr_en [xget_value $ucos_handle "PARAMETER" "OS_FLAG_WAIT_CLR_EN"]
    puts $config_file [format "#define OS_FLAG_WAIT_CLR_EN       %s      /* Include code for Wait on Clear EVENT FLAGS                   */" $flag_wait_clr_en]
    set flag_accept_en [xget_value $ucos_handle "PARAMETER" "OS_FLAG_ACCEPT_EN"]
    puts $config_file [format "#define OS_FLAG_ACCEPT_EN         %s      /*     Include code for OSFlagAccept()                          */" $flag_accept_en]
    set flag_del_en [xget_value $ucos_handle "PARAMETER" "OS_FLAG_DEL_EN"]
    puts $config_file [format "#define OS_FLAG_DEL_EN            %s      /*     Include code for OSFlagDel()                             */" $flag_del_en]
    set flag_name_size [xget_value $ucos_handle "PARAMETER" "OS_FLAG_NAME_EN"]
    puts $config_file [format "#define OS_FLAG_NAME_EN         %s     /*     Enable names for event flag group    */" $flag_name_size]
    set flag_query_en [xget_value $ucos_handle "PARAMETER" "OS_FLAG_QUERY_EN"]
    puts $config_file [format "#define OS_FLAG_QUERY_EN          %s      /*     Include code for OSFlagQuery()                           */\n" $flag_query_en]
    set flag_nbits [xget_value $ucos_handle "PARAMETER" "OS_FLAGS_NBITS"]
    puts $config_file "#if     OS_VERSION >= 280"
    puts $config_file [format "#define OS_FLAGS_NBITS             %s    /*     Size in #bits of OS_FLAGS data type (8, 16 or 32)        */" $flag_nbits]
    puts $config_file "#endif\n"

    puts $config_file "                                         /* -------------------- MESSAGE MAILBOXES --------------------- */"
    set mbox_en [xget_value $ucos_handle "PARAMETER" "OS_MBOX_EN"]
    puts $config_file [format "#define OS_MBOX_EN                %s      /* Enable (1) or Disable (0) code generation for MAILBOXES      */" $mbox_en]
    set mbox_accept_en [xget_value $ucos_handle "PARAMETER" "OS_MBOX_ACCEPT_EN"]
    puts $config_file [format "#define OS_MBOX_ACCEPT_EN         %s      /*     Include code for OSMboxAccept()                          */" $mbox_accept_en]
    set mbox_del_en [xget_value $ucos_handle "PARAMETER" "OS_MBOX_DEL_EN"]
    puts $config_file [format "#define OS_MBOX_DEL_EN            %s      /*     Include code for OSMboxDel()                             */" $mbox_del_en]
	 set mbox_pend_abort_en [xget_value $ucos_handle "PARAMETER" "OS_MBOX_PEND_ABORT_EN"]
	 puts $config_file [format "#define OS_MBOX_PEND_ABORT_EN     %s      /*     Include code for OSMboxPendAbort()                       */" $mbox_pend_abort_en]
    set mbox_post_en [xget_value $ucos_handle "PARAMETER" "OS_MBOX_POST_EN"]
    puts $config_file [format "#define OS_MBOX_POST_EN           %s      /*     Include code for OSMboxPost()                            */" $mbox_post_en]
    set mbox_post_opt_en [xget_value $ucos_handle "PARAMETER" "OS_MBOX_POST_OPT_EN"]
    puts $config_file [format "#define OS_MBOX_POST_OPT_EN       %s      /*     Include code for OSMboxPostOpt()                         */" $mbox_post_opt_en]
    set mbox_query_en [xget_value $ucos_handle "PARAMETER" "OS_MBOX_QUERY_EN"]
    puts $config_file [format "#define OS_MBOX_QUERY_EN          %s      /*     Include code for OSMboxQuery()                           */\n" $mbox_query_en]

    puts $config_file "                                         /* --------------------- MEMORY MANAGEMENT -------------------- */"
    set mem_en [xget_value $ucos_handle "PARAMETER" "OS_MEM_EN"]
    puts $config_file [format "#define OS_MEM_EN                 %s      /* Enable (1) or Disable (0) code generation for MEMORY MANAGER */" $mem_en]
    set mem_query_en [xget_value $ucos_handle "PARAMETER" "OS_MEM_QUERY_EN"]
    puts $config_file [format "#define OS_MEM_QUERY_EN           %s      /*     Include code for OSMemQuery()                            */" $mem_query_en]
    set mem_name_size [xget_value $ucos_handle "PARAMETER" "OS_MEM_NAME_EN"]
    puts $config_file [format "#define OS_MEM_NAME_EN          %s     /*     Enable memory partition names            */\n" $mem_name_size]

    puts $config_file "                                         /* ---------------- MUTUAL EXCLUSION SEMAPHORES --------------- */" 
    set mutex_en [xget_value $ucos_handle "PARAMETER" "OS_MUTEX_EN"]
    puts $config_file [format "#define OS_MUTEX_EN               %s      /* Enable (1) or Disable (0) code generation for MUTEX          */" $mutex_en]
    set mutex_accept_en [xget_value $ucos_handle "PARAMETER" "OS_MUTEX_ACCEPT_EN"]
    puts $config_file [format "#define OS_MUTEX_ACCEPT_EN        %s      /*     Include code for OSMutexAccept()                         */" $mutex_accept_en]
    set mutex_del_en [xget_value $ucos_handle "PARAMETER" "OS_MUTEX_DEL_EN"]
    puts $config_file [format "#define OS_MUTEX_DEL_EN           %s      /*     Include code for OSMutexDel()                            */" $mutex_del_en]
    set mutex_query_en [xget_value $ucos_handle "PARAMETER" "OS_MUTEX_QUERY_EN"]
    puts $config_file [format "#define OS_MUTEX_QUERY_EN         %s      /*     Include code for OSMutexQuery()                          */\n" $mutex_query_en]

    puts $config_file "                                         /* ---------------------- MESSAGE QUEUES ---------------------- */"
    set q_en [xget_value $ucos_handle "PARAMETER" "OS_Q_EN"]
    puts $config_file [format "#define OS_Q_EN                   %s      /* Enable (1) or Disable (0) code generation for QUEUES         */" $q_en]
    set q_accept_en [xget_value $ucos_handle "PARAMETER" "OS_Q_ACCEPT_EN"]
    puts $config_file [format "#define OS_Q_ACCEPT_EN            %s      /*     Include code for OSQAccept()                             */" $q_accept_en]
    set q_del_en [xget_value $ucos_handle "PARAMETER" "OS_Q_DEL_EN"]
    puts $config_file [format "#define OS_Q_DEL_EN               %s      /*     Include code for OSQDel()                                */" $q_del_en]
    set q_flush_en [xget_value $ucos_handle "PARAMETER" "OS_Q_FLUSH_EN"]
    puts $config_file [format "#define OS_Q_FLUSH_EN             %s      /*     Include code for OSQFlush()   	                          */" $q_flush_en]
    set q_pend_abort_en [xget_value $ucos_handle "PARAMETER" "OS_Q_PEND_ABORT_EN"]
	 puts $config_file [format "#define OS_Q_PEND_ABORT_EN        %s      /*     Include code for OSQPendAbort()                          */" $q_pend_abort_en]
    set q_post_en [xget_value $ucos_handle "PARAMETER" "OS_Q_POST_EN"]
    puts $config_file [format "#define OS_Q_POST_EN              %s      /*     Include code for OSQPost()                               */" $q_post_en]
    set q_post_front_en [xget_value $ucos_handle "PARAMETER" "OS_Q_POST_FRONT_EN"]
    puts $config_file [format "#define OS_Q_POST_FRONT_EN        %s      /*     Include code for OSQPostFront()                          */" $q_post_front_en]
    set q_post_opt_en [xget_value $ucos_handle "PARAMETER" "OS_Q_POST_OPT_EN"]
    puts $config_file [format "#define OS_Q_POST_OPT_EN          %s      /*     Include code for OSQPostOpt()                            */" $q_post_opt_en]
    set q_query_en [xget_value $ucos_handle "PARAMETER" "OS_Q_QUERY_EN"]
    puts $config_file [format "#define OS_Q_QUERY_EN             %s      /*     Include code for OSQQuery()                              */\n" $q_query_en]

    puts $config_file "                                         /* ------------------------ SEMAPHORES ------------------------ */"
    set sem_en [xget_value $ucos_handle "PARAMETER" "OS_SEM_EN"]
    puts $config_file [format "#define OS_SEM_EN                 %s      /* Enable (1) or Disable (0) code generation for SEMAPHORES     */" $sem_en]
    set sem_accept_en [xget_value $ucos_handle "PARAMETER" "OS_SEM_ACCEPT_EN"]
    puts $config_file [format "#define OS_SEM_ACCEPT_EN          %s      /*    Include code for OSSemAccept()                            */" $sem_accept_en]
    set sem_del_en [xget_value $ucos_handle "PARAMETER" "OS_SEM_DEL_EN"]
    puts $config_file [format "#define OS_SEM_DEL_EN             %s      /*    Include code for OSSemDel()                               */" $sem_del_en]
	 set sem_pend_abort_en [xget_value $ucos_handle "PARAMETER" "OS_SEM_PEND_ABORT_EN"]
    puts $config_file [format "#define OS_SEM_PEND_ABORT_EN      %s      /*    Include code for OSSemPendAbort()                         */" $sem_pend_abort_en]
    set sem_query_en [xget_value $ucos_handle "PARAMETER" "OS_SEM_QUERY_EN"]
    puts $config_file [format "#define OS_SEM_QUERY_EN           %s      /*    Include code for OSSemQuery()                             */" $sem_query_en]
    set sem_set_en [xget_value $ucos_handle "PARAMETER" "OS_SEM_SET_EN"]
    puts $config_file [format "#define OS_SEM_SET_EN             %s      /*    Include code for OSSemSet()        RRW - New in V2.76     */\n" $sem_set_en]

    puts $config_file "                                         /* --------------------- TASK MANAGEMENT ---------------------- */"
    set task_change_prio_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_CHANGE_PRIO_EN"]
    puts $config_file [format "#define OS_TASK_CHANGE_PRIO_EN    %s      /*     Include code for OSTaskChangePrio()                      */" $task_change_prio_en]
    set task_create_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_CREATE_EN"]
    puts $config_file [format "#define OS_TASK_CREATE_EN         %s      /*     Include code for OSTaskCreate()                          */" $task_create_en]
    set task_create_ext_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_CREATE_EXT_EN"]
    puts $config_file [format "#define OS_TASK_CREATE_EXT_EN     %s      /*     Include code for OSTaskCreateExt()                       */" $task_create_ext_en]
    set task_del_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_DEL_EN"]
    puts $config_file [format "#define OS_TASK_DEL_EN            %s      /*     Include code for OSTaskDel()                             */" $task_del_en]
    set task_name_size [xget_value $ucos_handle "PARAMETER" "OS_TASK_NAME_EN"]
    puts $config_file [format "#define OS_TASK_NAME_EN         %s     /*     Enable task names                        */" $task_name_size]
    set task_profile_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_PROFILE_EN"]
    puts $config_file [format "#define OS_TASK_PROFILE_EN        %s      /*     Include variables in OS_TCB for profiling                */" $task_profile_en]
    set task_query_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_QUERY_EN"]
    puts $config_file [format "#define OS_TASK_QUERY_EN          %s      /*     Include code for OSTaskQuery()                           */" $task_query_en]
    set task_suspend_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_SUSPEND_EN"]
    puts $config_file [format "#define OS_TASK_SUSPEND_EN        %s      /*     Include code for OSTaskSuspend() and OSTaskResume()      */" $task_suspend_en]
    set task_sw_hook_en [xget_value $ucos_handle "PARAMETER" "OS_TASK_SW_HOOK_EN"]
    puts $config_file [format "#define OS_TASK_SW_HOOK_EN        %s      /*     Include code for OSTaskSwHook()                          */" $task_sw_hook_en]   
    set  task_reg_tbl_size [xget_value $ucos_handle "PARAMETER" "OS_TASK_REG_TBL_SIZE"]
    puts $config_file [format "#define OS_TASK_REG_TBL_SIZE        %s      /*     size of task variables array                        */\n" $task_reg_tbl_size]

    puts $config_file "                                         /* --------------------- TIME MANAGEMENT ---------------------- */"
    set time_dly_hmsm_en [xget_value $ucos_handle "PARAMETER" "OS_TIME_DLY_HMSM_EN"]
    puts $config_file [format "#define OS_TIME_DLY_HMSM_EN       %s      /*     Include code for OSTimeDlyHMSM()                         */" $time_dly_hmsm_en]
    set time_dly_resume_en [xget_value $ucos_handle "PARAMETER" "OS_TIME_DLY_RESUME_EN"]
    puts $config_file [format "#define OS_TIME_DLY_RESUME_EN     %s      /*     Include code for OSTimeDlyResume()                       */" $time_dly_resume_en]
    set time_get_set_en [xget_value $ucos_handle "PARAMETER" "OS_TIME_GET_SET_EN"]
    puts $config_file [format "#define OS_TIME_GET_SET_EN        %s      /*     Include code for OSTimeGet() and OSTimeSet()             */" $time_get_set_en]
    set time_tick_hook_en [xget_value $ucos_handle "PARAMETER" "OS_TIME_TICK_HOOK_EN"]
    puts $config_file [format "#define OS_TIME_TICK_HOOK_EN      %s      /*     Include code for OSTimeTickHook()                        */\n" $time_tick_hook_en]

    puts $config_file "#if     OS_VERSION >= 281"
    puts $config_file "                                         /* -------------------- TIMER MANAGEMENT ---------------------- */"
    set tmr_en [xget_value $ucos_handle "PARAMETER" "OS_TMR_EN"]
    puts $config_file [format "#define OS_TMR_EN                 %s      /* Enable (1) or disable (0) code generation for TIMERS         */" $tmr_en]
    set tmr_cfg_max [xget_value $ucos_handle "PARAMETER" "OS_TMR_CFG_MAX"]
    puts $config_file [format "#define OS_TMR_CFG_MAX            %s     /*     Maximum number of timers                                 */" $tmr_cfg_max]
    set tmr_cfg_name_size [xget_value $ucos_handle "PARAMETER" "OS_TMR_CFG_NAME_EN"]
    puts $config_file [format "#define OS_TMR_CFG_NAME_EN      %s     /*     Determine the size of a timer name                       */" $tmr_cfg_name_size]
    set tmr_cfg_wheel_size [xget_value $ucos_handle "PARAMETER" "OS_TMR_CFG_WHEEL_SIZE"]
    puts $config_file [format "#define OS_TMR_CFG_WHEEL_SIZE     %s      /*     Size of timer wheel (#Entries)                           */" $tmr_cfg_wheel_size]
    set tmr_cfg_ticks_per_sec [xget_value $ucos_handle "PARAMETER" "OS_TMR_CFG_TICKS_PER_SEC"]
    puts $config_file [format "#define OS_TMR_CFG_TICKS_PER_SEC  %s     /*     Rate at which timer management task runs (Hz)            */\n" $tmr_cfg_ticks_per_sec]
    puts $config_file "#endif\n"

    set flags_value [xget_value $ucos_handle "PARAMETER" "OS_FLAGS_NBITS"]
    set flags_type "INT8U"
    if {$flags_value == "16"} {
        set flags_type "INT16U"
    }
    if {$flags_value == "32"} {
        set flags_type "INT32U"
    }
    puts $config_file "#if     OS_VERSION < 280"
    puts $config_file [format "typedef %s OS_FLAGS;                 /* Data type for event flag bits (8, 16 or 32 bits)             */" $flags_type]
    puts $config_file "#endif\n"

    puts $config_file "#endif\n"


    close $config_file

    file copy -force $filename ../../include/
	 
    if {[xget_value $ucos_handle "PARAMETER" "PROBE_EN"] == 1} {
        set probe_filename "./src/probe_com_cfg.h"
        file delete $probe_filename
        set probe_config_file [open $probe_filename w]

        puts $probe_config_file "/*"
        puts $probe_config_file "**********************************************************************************************************"
        puts $probe_config_file "* This is the uC/OS-II configuration file created by the LibGen generate procedure.  The constants in    *"
        puts $probe_config_file "* this file can be modified through your project's Software Platform Settings.                           *"  
        puts $probe_config_file "*                                                                                                        *"
        puts $probe_config_file "**********************************************************************************************************"
        puts $probe_config_file "*/\n\n"   
		  
		  puts $probe_config_file "#define  PROBE_EN  1"
		  set os_en [xget_value $ucos_handle "PARAMETER" "PROBE_OS_EN"]
		  if {$os_en == "0"} {
		      puts $probe_config_file "#define  PROBE_OS_EN  0\n"
		  } else {
		      puts $probe_config_file "#define  PROBE_OS_EN  1\n"
		  }

        puts $probe_config_file "                                         /* --------------- Choose Communication Method ---------------- */"
		  puts $probe_config_file "#define  PROBE_COM_CFG_RS232_EN    DEF_TRUE"
		  puts $probe_config_file "#define  PROBE_COM_CFG_TCPIP_EN    DEF_FALSE\n"
		  
		  puts $probe_config_file "                                         /* --------- Configure General Communication Parameters ------- */"
		  set com_rx_max_size [xget_value $ucos_handle "PARAMETER" "PROBE_COM_CFG_RX_MAX_SIZE"]
		  puts $probe_config_file [format "#define PROBE_COM_CFG_RX_MAX_SIZE         %s \n" $com_rx_max_size]
		  set com_tx_max_size [xget_value $ucos_handle "PARAMETER" "PROBE_COM_CFG_TX_MAX_SIZE"]
		  puts $probe_config_file [format "#define PROBE_COM_CFG_TX_MAX_SIZE         %s \n\n" $com_tx_max_size]
		  puts $probe_config_file "#define PROBE_COM_SUPPORT_WR  DEF_FALSE"
		  set com_support_str [xget_value $ucos_handle "PARAMETER" "PROBE_COM_SUPPORT_STR"]
		  if {$com_support_str == "true"} {
		      puts $probe_config_file "#define  PROBE_COM_SUPPORT_STR  DEF_TRUE\n"
				set com_str_buf_size [xget_value $ucos_handle "PARAMETER" "PROBE_COM_STR_BUF_SIZE"]
				puts $probe_config_file [format "#define PROBE_COM_STR_BUF_SIZE    %s \n\n" $com_str_buf_size]
		  } else {
		      puts $probe_config_file "#define  PROBE_COM_SUPPORT_STR  DEF_FALSE\n"
		  }
		  
		  puts $probe_config_file "                                         /* ---------- Configure Statistics and Counters --------------- */"
		  set com_stat_en [xget_value $ucos_handle "PARAMETER" "PROBE_COM_CFG_STAT_EN"]
		  puts $probe_config_file [format "#define PROBE_COM_CFG_STAT_EN          %s \n\n" $com_stat_en]
		  
		  puts $probe_config_file "                                         /* --------- Configure RS-232 Specific Parameters ------------- */"
		  set rs232_parse_task [xget_value $ucos_handle "PARAMETER" "PROBE_RS232_CFG_PARSE_TASK_EN"]
		  if {$rs232_parse_task == "true"} {
		      puts $probe_config_file "#define  PROBE_RS232_CFG_PARSE_TASK_EN  DEF_TRUE\n"
				set rs232_task_prio [xget_value $ucos_handle "PARAMETER" "PROBE_RS232_CFG_TASK_PRIO"]
				puts $probe_config_file [format "#define  PROBE_RS232_CFG_TASK_PRIO    %s \n" $rs232_task_prio]
				set rs232_task_stk_size [xget_value $ucos_handle "PARAMETER" "PROBE_RS232_CFG_TASK_STK_SIZE"]
				puts $probe_config_file [format "#define  PROBE_RS232_CFG_TASK_STK_SIZE  %s \n\n" $rs232_task_stk_size]
		  } else {
			   puts $probe_config_file "#define  PROBE_RS232_CFG_PARSE_TASK_EN  DEF_TRUE\n"
		  }
		  puts $probe_config_file "#define  PROBE_RS232_CFG_RX_BUF_SIZE  PROBE_COM_CFG_RX_MAX_SIZE"
		  puts $probe_config_file "#define  PROBE_RS232_CFG_TX_BUF_SIZE  PROBE_COM_CFG_TX_MAX_SIZE\n"
		  
		  puts $probe_config_file "#define  PROBE_RS232_CFG_COMM_SEL  0\n"
		  
		  set probe_com_cfg_wr_req_en  [xget_value $ucos_handle "PARAMETER" "PROBE_COM_CFG_WR_REQ_EN"]
		  if {$probe_com_cfg_wr_req_en == "true"} {
			puts $probe_config_file "#define  PROBE_COM_CFG_WR_REQ_EN          DEF_ENABLED\n"
		  } else {
			puts $probe_config_file "#define  PROBE_COM_CFG_WR_REQ_EN          DEF_DISABLED\n"
		  }
		  
		   set probe_com_cfg_terminal_req_en  [xget_value $ucos_handle "PARAMETER" "PROBE_COM_CFG_TERMINAL_REQ_EN"]
		  if {$probe_com_cfg_terminal_req_en == "true"} {
			puts $probe_config_file "#define  PROBE_COM_CFG_TERMINAL_REQ_EN          DEF_ENABLED\n"
		  } else {
			puts $probe_config_file "#define  PROBE_COM_CFG_TERMINAL_REQ_EN          DEF_DISABLED\n"
		  }
		  
		    set probe_com_cfg_str_req_en  [xget_value $ucos_handle "PARAMETER" "PROBE_COM_CFG_STR_REQ_EN"]
		  if {$probe_com_cfg_str_req_en == "true"} {
			puts $probe_config_file "#define  PROBE_COM_CFG_STR_REQ_EN          DEF_ENABLED\n"
		  } else {
			puts $probe_config_file "#define  PROBE_COM_CFG_STR_REQ_EN          DEF_DISABLED\n"
		  }
		  
        close $probe_config_file

        file copy -force $probe_filename ../../include/	 
    }	 
}

# --------------------------------------
# Tcl procedure post_generate
#
# This proc removes _interrupt_handler.o
# from libxil.a
# --------------------------------------
proc post_generate {os_handle} {
    
    set sw_proc_handle [xget_libgen_proc_handle]
    set hw_proc_handle [xget_handle $sw_proc_handle "IPINST"]

    set procname [xget_value $hw_proc_handle "NAME"]
    set proctype [xget_value $hw_proc_handle "OPTION" "IPNAME"]

    if {[string compare -nocase $proctype "microblaze"] == 0} {

 	set procdrv [xget_sw_driver_handle_for_ipinst $sw_proc_handle $procname]
	# Remove _interrupt_handler.o from libxil.a for mb-gcc
	set archiver [xget_value $procdrv "PARAMETER" "archiver"]
	exec bash -c "$archiver -d ../../lib/libxil.a _interrupt_handler.o"
	
        # Remove _hw_exception_handler.o from libxil.a for microblaze_v3_00_a
        set procver [xget_value $hw_proc_handle "PARAMETER" "HW_VER"]
        if {[mb_has_exceptions $hw_proc_handle]} {
            exec bash -c "$archiver -d ../../lib/libxil.a _hw_exception_handler.o"
        }
    }

}

# --------------------------------------
# Return true if this MB has 
# exception handling support
# --------------------------------------
proc mb_has_exceptions { hw_proc_handle } {
   
    # Check if the following parameters exist on this MicroBlaze's MPD
    set ee [xget_value $hw_proc_handle "PARAMETER" "C_UNALIGNED_EXCEPTIONS"]
    if { $ee != "" } {
        return true
    }

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_ILL_OPCODE_EXCEPTION"]
    if { $ee != "" } {
        return true
    }

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_IOPB_BUS_EXCEPTION"]
    if { $ee != "" } {
        return true
    }

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_DOPB_BUS_EXCEPTION"]
    if { $ee != "" } {
        return true
    }

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_DIV_BY_ZERO_EXCEPTION"]
    if { $ee != "" } {
        return true
    } 

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_DIV_ZERO_EXCEPTION"]
    if { $ee != "" } {
        return true
    } 

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_FPU_EXCEPTION"]
    if { $ee != "" } {
        return true
    } 

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_FSL_EXCEPTION"]
    if { $ee != "" } {
        return true
    } 

    set ee [xget_value $hw_proc_handle "PARAMETER" "C_USE_MMU"]
    if { $ee != ""} {
        return true
    } 

    return false
}

# --------------------------------------
# Return true if this MB has 
# FPU exception handling support
# --------------------------------------
proc mb_has_fpu_exceptions { hw_proc_handle } {
    
    # Check if the following parameters exist on this MicroBlaze's MPD
    set ee [xget_value $hw_proc_handle "PARAMETER" "C_FPU_EXCEPTION"]
    if { $ee != "" } {
        return true
    } 

    return false
}

# --------------------------------------
# Return true if this MB has PVR support
# --------------------------------------
proc mb_has_pvr { hw_proc_handle } {
    
    # Check if the following parameters exist on this MicroBlaze's MPD
    set pvr [xget_value $hw_proc_handle "PARAMETER" "C_PVR"]
    if { $pvr != "" } {
        return true
    } 

    return false
}

# --------------------------------------
# Return true if MB ver 'procver' has 
# support for handling exceptions in 
# delay slots
# --------------------------------------
proc mb_can_handle_exceptions_in_delay_slots { procver } {
    
    if { [string compare -nocase $procver "5.00.a"] >= 0 } {
        return true
    } else {
        return false
    }
}

# --------------------------------------
# Generate Profile Configuration
# --------------------------------------
proc handle_profile { os_handle proctype } {
    global env

    set proc [xget_processor]

    set cpu_freq [xget_value $proc "PARAMETER" "CORE_CLOCK_FREQ_HZ"]
    if { [string compare -nocase $cpu_freq ""] == 0 } {
	puts "WARNING<profile> :: CPU Clk Frequency not specified, Assuming 100Mhz"
	set cpu_freq 100000000
    }

    set filename [file join "src" "profile" "profile_config.h"]     
    file delete -force $filename
    set config_file [open $filename w]

    xprint_generated_header $config_file "Profiling Configuration parameters"
    puts $config_file "#ifndef _PROFILE_CONFIG_H"
    puts $config_file "#define _PROFILE_CONFIG_H\n"
    
    puts $config_file "#define BINSIZE 4"
    puts $config_file "#define CPU_FREQ_HZ $cpu_freq"
    puts $config_file "#define SAMPLE_FREQ_HZ 100000"
    puts $config_file "#define TIMER_CLK_TICKS [expr $cpu_freq / 100000]"
    
    # proctype should be "microblaze" or "ppc405" or "ppc405_virtex4"
    switch $proctype {
	"microblaze" { 
	    # Microblaze Processor.

	    puts $config_file "#define PROC_MICROBLAZE 1"
	    set timer_inst [xget_value $os_handle "PARAMETER" "profile_timer"]
	    if { [string compare -nocase $timer_inst "none"] == 0 } {
		# Profile Timer Not Selected
		error "ERROR :: Timer for Profiling NOT selected.\nS/W Intrusive Profiling on MicroBlaze requires an xps_timer or an opb_timer." "" "mdt_error"
	    } else {
		handle_profile_opbtimer $config_file $timer_inst
	    }
	}
	"ppc405"  
	-
	"ppc405_virtex4" {
	    # PowerPC Processor
	    # - PIT Timer is used for Profiling by default

	    puts $config_file "#define PROC_PPC 1"
	    set timer_inst [xget_value $os_handle "PARAMETER" "profile_timer"]
	    if { [string compare -nocase $timer_inst "none"] == 0 } {
		# PIT Timer
		puts $config_file "#define PPC_PIT_INTERRUPT 1"
		puts $config_file "#define ENABLE_SYS_INTR 1"
	    } else {
		handle_profile_opbtimer $config_file $timer_inst
	    }
	}
	"default" {error "unknown processor type\n"}
    }

    puts $config_file "\n#endif"
    puts $config_file "\n/******************************************************************/\n"
    close $config_file
}

# - The opb_timer can be connected directly to Microblaze External Intr Pin.
# - (OR) opb_timer can be connected to opb_intc
proc handle_profile_opbtimer { config_file timer_inst } {
    set timer_handle [xget_hwhandle $timer_inst]
    set timer_baseaddr [xget_value $timer_handle "PARAMETER" "C_BASEADDR"]
    puts $config_file "#define PROFILE_TIMER_BASEADDR [xformat_addr_string $timer_baseaddr "C_BASEADDR"]"

    # Figure out how Timer is connected.
    set timer_intr [xget_value $timer_handle "PORT" "Interrupt"]
    if { [string compare -nocase $timer_intr ""] == 0 } {
	error "ERROR<profile> :: Timer Interrupt PORT is not specified" "" "mdt_error"
    } 
    set mhs_handle [xget_handle $timer_handle "parent"]
    # CR 302300 - There can be multiple "sink" for the interrupt. So need to iterate through the list
    set intr_port_list [xget_connected_ports_handle $mhs_handle $timer_intr "sink"]
    set timer_connection 0
    foreach intr_port $intr_port_list {
	set intc_handle [xget_handle $intr_port "parent"]
	# Check if the Sink is a Global Port. If so, Skip the Port Connection
	if { $intc_handle == $mhs_handle } {
	    continue 
	}
	set iptype [xget_value $intc_handle "OPTION" "IPTYPE"]
	if { [string compare -nocase $iptype "PROCESSOR"] == 0 } {
	    # Timer Directly Connected to the Processor
	    puts $config_file "#define ENABLE_SYS_INTR 1"
	    set timer_connection 1
	    break
	}

	set ipsptype [xget_value $intc_handle "OPTION" "SPECIAL"]
	if { [string compare -nocase $iptype "PERIPHERAL"] == 0  &&
	     [string compare -nocase $ipsptype "INTERRUPT_CONTROLLER"] == 0 } {
	    # Timer connected to Interrupt controller
	    puts $config_file "#define TIMER_CONNECT_INTC 1"
	    puts $config_file "#define INTC_BASEADDR [xget_value $intc_handle "PARAMETER" "C_BASEADDR"]"
	    set num_intr_inputs [xget_value $intc_handle "PARAMETER" "C_NUM_INTR_INPUTS"]
	    if { $num_intr_inputs == 1 } {
		puts $config_file "#define ENABLE_SYS_INTR 1"
	    }

	    set signals [split [xget_value $intr_port "VALUE"] "&"]
	    set i 1
	    foreach signal $signals {
		set signal [string trim $signal]
		if {[string compare -nocase $signal $timer_intr] == 0} {
		    set timer_id [expr ($num_intr_inputs - $i)]
		    set timer_mask [expr 0x1 << $timer_id]
		    puts $config_file "#define PROFILE_TIMER_INTR_ID $timer_id"
		    puts $config_file "#define PROFILE_TIMER_INTR_MASK [format "0x%x" $timer_mask]"
		    break
		}
		incr i
	    }
	    set timer_connection 1
	    break
	} 
    }
    
    if { $timer_connection == 0 } {
	error "ERROR<profile> :: Profile Timer Interrupt Signal Not Connected Properly" 
    }
}

