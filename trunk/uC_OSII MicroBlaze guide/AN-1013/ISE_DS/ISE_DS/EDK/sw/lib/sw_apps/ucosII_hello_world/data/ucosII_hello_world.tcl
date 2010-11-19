proc swapp_get_name {} {
    return "uC_OS-II Hello World";
}

proc swapp_get_description {} {
    return "Demonstrate multi-tasking by printing Hello World from two tasks";
}

proc get_os {} {
    set oslist [xget_sw_modules "type" "os"];
    set os [lindex $oslist 0];

    if { $os == "" } {
        error "No Operating System specified in the Board Support Package.";
    }
    
    return $os;
}

proc get_stdout {} {
    set os [get_os];
    set stdout [xget_sw_module_parameter $os "STDOUT"];
    return $stdout;
}

proc check_stdout_hw {} {
    set uartlites [xget_ips "type" "xps_uartlite"];
    if { [llength $uartlites] == 0 } {
        # we do not have an uartlite
	set uart16550s [xget_ips "type" "xps_uart16550"];
	if { [llength $uart16550s] == 0 } {      
	    error "This application requires a Uart IP (xps_uartlite or xps_uart16550) in the hardware."
	}
    }
}

proc check_stdout_sw {} {
    set stdout [get_stdout];
    if { $stdout == "none" } {
        error "The STDOUT parameter is not set on the OS. Hello World requires stdout to be set."
    }
}

proc swapp_is_supported_hw {} {
    # check for uart peripheral
    check_stdout_hw;

    return 1;
}

proc swapp_is_supported_sw {} {
    # check for stdout being set
    check_stdout_sw;

    return 1;
}

proc generate_stdout_config { fid } {
    set stdout [get_stdout];

    # if stdout is uartlite, we don't have to generate anything
    set stdout_type [xget_ip_attribute "type" $stdout];

    if { $stdout_type == "xps_uartlite"} {
        return;
    } elseif { $stdout_type == "xps_uart16550" } {
	# mention that we have a 16550
        puts $fid "#define STDOUT_IS_16550";

        # and note down its base address
	set prefix "XPAR_";
	set postfix "_BASEADDR";
	set stdout_baseaddr_macro $prefix$stdout$postfix;
	set stdout_baseaddr_macro [string toupper $stdout_baseaddr_macro];
	puts $fid "#define STDOUT_BASEADDR $stdout_baseaddr_macro";
    }
}

proc generate_cache_mask { fid } {
    set mask [format "0x%x" [xget_ppc_cache_mask]]
    puts $fid "#ifdef __PPC__"
    puts $fid "#define CACHEABLE_REGION_MASK $mask"
    puts $fid "#endif\n"
}

proc swapp_generate {} {
    set os [get_os];
    
    #cleanup this file for writing
    set fid [open "platform_config.h" "w+"];
    puts $fid "#ifndef __PLATFORM_CONFIG_H_";
    puts $fid "#define __PLATFORM_CONFIG_H_\n";

    # if we have a uart16550 as stdout, then generate some config for that
    generate_stdout_config $fid;

    # for ppc, generate cache mask string
    generate_cache_mask $fid;

    puts $fid "#endif";
    close $fid;
}

proc swapp_get_linker_constraints {} {
    return "";
}
