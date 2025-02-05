puts  "  ▒▓█▓▒        ▒▓████████▓▒ ▒▓██████▓▒   " 
puts  "  ▒▓█▓▒        ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒  " 
puts  "  ▒▓█▓▒        ▒▓█▓▒       ▒▓█▓▒         " 
puts  "  ▒▓█▓▒        ▒▓██████▓▒  ▒▓█▓▒         " 
puts  "  ▒▓█▓▒        ▒▓█▓▒       ▒▓█▓▒         " 
puts  "  ▒▓█▓▒        ▒▓█▓▒       ▒▓█▓▒  ▒▓█▓▒  " 
puts  "  ▒▓████████▓▒ ▒▓████████▓▒ ▒▓██████▓▒   " 




# Get paths from environment variables
set DESIGN_NAME $::env(DESIGN_NAME)
set RTL_PATH $::env(RTL_PATH)
set LIB_PATH $::env(LIB_PATH)
set SDC_PATH $::env(SDC_PATH)
set REPORT_PATH $::env(REPORT_PATH)
set OUTPUT_PATH $::env(OUTPUT_PATH)
set LOG_PATH $::env(LOG_PATH)
set SCRIPTS_PATH $::env(SCRIPTS_PATH)

# Proper logging
set logFile [open "$LOG_PATH/lec.log" "a"]
puts $logFile "Starting LECs for $DESIGN_NAME."

lec -nogui -do ${SCRIPTS_PATH}/${DESIGN_NAME}_rtl_to_final.lec.do


set_screen_display -noprogress


set share_dp_analysis true

set lec_version_required "19.10100"
if {$lec_version >= $lec_version_required &&
    $wlec_analyze_dp_flowgraph} {
    set DATAPATH_SOLVER_OPTION "-flowgraph"
} elseif {$share_dp_analysis} {
    set DATAPATH_SOLVER_OPTION "-share"
} else {
    set DATAPATH_SOLVER_OPTION ""
}

proc is_pass {} {
    redirect -variable compare_result {report_verification}
    foreach i [split $compare_result "\n"] {
        if {[regexp {Compare Results:\s+PASS} $i]} {
            return true
        }
    }
    return false
}

tcl_set_command_name_echo on

set logfile ../LEC/logs/rtl_to_final.lec.log ;# user can modify this name for succeeding runs

set_log_file $logfile -replace

usage -auto -elapse

set_mapping_method -sensitive


set_verification_information fv_map_UDP_netlistv_db

read_implementation_information fv/UDP -golden fv_map -revised UDP_netlistv

set_parallel_option -threads 1,4 -norelease_license
set_compare_options -threads 1,4

set env(RC_VERSION)     "21.18-s082_1"
set env(CDN_SYNTH_ROOT) "/opt/cadence/installs/Genus_21_18/tools.lnx86"
set CDN_SYNTH_ROOT      "/opt/cadence/installs/Genus_21_18/tools.lnx86"
set env(CW_DIR) "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware"
set CW_DIR      "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware"
set lec_version_required "21.20249"
if { ($lec_version < $lec_version_required) &&
    [file exists /opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/old_encrypt_sim]} {
    set env(CW_DIR_SIM) "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/old_encrypt_sim"
    set CW_DIR_SIM      "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/old_encrypt_sim"
} else {
    set env(CW_DIR_SIM) "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/sim"
    set CW_DIR_SIM      "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/sim"
}
set_multiplier_implementation boothrca -both

set_undefined_cell black_box -noascend -both


add_search_path . /opt/cadence/installs/Genus_21_18/tools.lnx86/lib/tech -library -both
read_library -liberty -both \
    /mnt/c2s/sanjay/sanju/manju/UDP/genus/../LIB/slow_vdd1v0_basicCells.lib

read_design -verilog95   -golden -lastmod -noelab fv/UDP/fv_map.v.gz
elaborate_design -golden -root {UDP}

read_design -verilog95   -revised -lastmod -noelab outputs/UDP_netlist.v
elaborate_design -revised -root {UDP}

#set_mapping_method -alias -golden

report_design_data
report_black_box

set_flatten_model -seq_constant
set_flatten_model -seq_constant_x_to 0
set_flatten_model -nodff_to_dlat_zero
set_flatten_model -nodff_to_dlat_feedback
set_flatten_model -hier_seq_merge


set lec_version_required "20.10100"
if {$lec_version >= $lec_version_required} {
    check_verification_information -verbose
}

set_analyze_option -auto -report_map

set_system_mode lec
report_mapped_points
report_unmapped_points -summary
report_unmapped_points -notmapped
report_unmapped_points -extra -unreachable
add_compared_points -all
report_compared_points
compare

report_compare_data
report_compare_data -class nonequivalent -class abort -class notcompared
report_verification -verbose
report_statistics

write_compared_points noneq.compared_points.UDP.fv_map.UDP_netlistv.tcl -class noneq -tclmode -replace
set lec_version_required "21.10100"
if {$lec_version >= $lec_version_required} {
    analyze_nonequivalent -source_diagnosis
    report_nonequivalent_analysis > noneq.source_diag.UDP.fv_map.UDP_netlistv.rpt
}
report_test_vector -noneq > noneq.test_vector.UDP.fv_map.UDP_netlistv.rpt
if {![is_pass]} {
    error "// ERROR: Compare was not equivalent."
}

write_verification_information
report_verification_information

set lec_version_required "18.20330"
if {$lec_version >= $lec_version_required} {
    report_implementation_information -verbose
}

checkpoint m2f.outputs/UDP_check_point.ckp -replace

reset

set_mapping_method -sensitive


set_verification_information rtl_fv_map_db

read_implementation_information fv/UDP -revised fv_map

set_parallel_option -threads 1,4 -norelease_license
set_compare_options -threads 1,4

set env(RC_VERSION)     "21.18-s082_1"
set env(CDN_SYNTH_ROOT) "/opt/cadence/installs/Genus_21_18/tools.lnx86"
set CDN_SYNTH_ROOT      "/opt/cadence/installs/Genus_21_18/tools.lnx86"
set env(CW_DIR) "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware"
set CW_DIR      "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware"
set lec_version_required "21.20249"
if { ($lec_version < $lec_version_required) &&
    [file exists /opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/old_encrypt_sim]} {
    set env(CW_DIR_SIM) "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/old_encrypt_sim"
    set CW_DIR_SIM      "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/old_encrypt_sim"
} else {
    set env(CW_DIR_SIM) "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/sim"
    set CW_DIR_SIM      "/opt/cadence/installs/Genus_21_18/tools.lnx86/lib/chipware/sim"
}
set_multiplier_implementation boothrca -both

set_undefined_cell black_box -noascend -both


add_search_path . /opt/cadence/installs/Genus_21_18/tools.lnx86/lib/tech -library -both
read_library -liberty -both \
    /mnt/c2s/sanjay/sanju/manju/UDP/genus/../LIB/slow_vdd1v0_basicCells.lib

set_undriven_signal 0 -golden
set lec_version_required "16.20100"
if {$lec_version >= $lec_version_required} {
    set_naming_style genus -golden
} else {
    set_naming_style rc -golden
}
set_naming_rule "%s\[%d\]" -instance_array -golden
set_naming_rule "%s_reg" -register -golden
set_naming_rule "%L.%s" "%L\[%d\].%s" "%s" -instance -golden
set_naming_rule "%L.%s" "%L\[%d\].%s" "%s" -variable -golden
set lec_version_required "17.10200"
if {$lec_version >= $lec_version_required} {
    set_naming_rule -ungroup_separator {_} -golden
}

set lec_version_required "17.20301"
if {$lec_version >= $lec_version_required} {
    set_hdl_options -const_port_extend
}
set_hdl_options -unsigned_conversion_overflow on
set_hdl_option -v_to_vd on

set lec_version_required "20.20226"
if {$lec_version >= $lec_version_required} {
    set_hdl_options -VERILOG_INCLUDE_DIR "sep:src"
} else {
    set_hdl_options -VERILOG_INCLUDE_DIR "sep:src:cwd"
}
add_search_path . -design -golden
read_design -enumconstraint -define SYNTHESIS  -merge bbox -golden -lastmod -noelab  -sv09 ../RTL_Sources/relu.sv
add_search_path . -design -golden
read_design -enumconstraint -define SYNTHESIS  -merge bbox -golden -lastmod -noelab  -sv09 ../RTL_Sources/UDP.sv
add_search_path . -design -golden
read_design -enumconstraint -define SYNTHESIS  -merge bbox -golden -lastmod -noelab  -sv09 ../RTL_Sources/prelu.sv
add_search_path . -design -golden
read_design -enumconstraint -define SYNTHESIS  -merge bbox -golden -lastmod -noelab  -sv09 ../RTL_Sources/quant.sv
add_search_path . -design -golden
read_design -enumconstraint -define SYNTHESIS  -merge bbox -golden -lastmod -noelab  -sv09 ../RTL_Sources/bias_controller.sv
add_search_path . -design -golden
read_design -enumconstraint -define SYNTHESIS  -merge bbox -golden -lastmod -noelab  -sv09 ../RTL_Sources/bias_fifo.sv
add_search_path . -design -golden
read_design -enumconstraint -define SYNTHESIS  -merge bbox -golden -lastmod -noelab  -sv09 ../RTL_Sources/bias_add.sv
elaborate_design -golden -root {UDP} -rootonly -rootonly  

read_design -verilog95   -revised -lastmod -noelab fv/UDP/fv_map.v.gz
elaborate_design -revised -root {UDP}

uniquify -all -nolib -golden

report_design_data
report_black_box

set_flatten_model -seq_constant
set_flatten_model -seq_constant_x_to 0
set_flatten_model -nodff_to_dlat_zero
set_flatten_model -nodff_to_dlat_feedback
set_flatten_model -hier_seq_merge

set_flatten_model -balanced_modeling


set lec_version_required "20.10100"
if {$lec_version >= $lec_version_required} {
    check_verification_information -verbose
}

set_analyze_option -auto -report_map

write_hier_compare_dofile hier_tmp3.lec.do -verbose -noexact_pin_match -constraint -usage \
-replace -balanced_extraction -input_output_pin_equivalence \
-prepend_string "report_design_data; report_unmapped_points -summary; report_unmapped_points -notmapped; report_unmapped_points -extra -unreachable; analyze_datapath -module -verbose; eval analyze_datapath $DATAPATH_SOLVER_OPTION -verbose" \
-append_string "report_compare_data -class nonequivalent -class abort -class notcompared; report_verification -verbose"
run_hier_compare hier_tmp3.lec.do -dynamic_hierarchy -verbose

report_hier_compare_result -dynamicflattened

report_verification -hier -verbose

set_system_mode lec
write_compared_points noneq.compared_points.UDP.rtl.fv_map.tcl -class noneq -tclmode -replace
set lec_version_required "21.10100"
if {$lec_version >= $lec_version_required} {
    analyze_nonequivalent -source_diagnosis
    report_nonequivalent_analysis > noneq.source_diag.UDP.rtl.fv_map.rpt
}
report_test_vector -noneq > noneq.test_vector.UDP.rtl.fv_map.rpt
set_system_mode setup
write_verification_information
report_verification_information

set lec_version_required "18.20330"
if {$lec_version >= $lec_version_required} {
    report_implementation_information -verbose
}

set_system_mode lec

puts "No of compare points = [get_compare_points -count]"
puts "No of diff points    = [get_compare_points -NONequivalent -count]"
puts "No of abort points   = [get_compare_points -abort -count]"
puts "No of unknown points = [get_compare_points -unknown -count]"
if {[get_compare_points -count] == 0} {
    puts "---------------------------------"
    puts "ERROR: No compare points detected"
    puts "---------------------------------"
}
if {[get_compare_points -NONequivalent -count] > 0} {
    puts "------------------------------------"
    puts "ERROR: Different Key Points detected"
    puts "------------------------------------"
}
if {[get_compare_points -abort -count] > 0} {
    puts "-----------------------------"
    puts "ERROR: Abort Points detected "
    puts "-----------------------------"
}
if {[get_compare_points -unknown -count] > 0} {
    puts "----------------------------------"
    puts "ERROR: Unknown Key Points detected"
    puts "----------------------------------"
}

# This command is available with LEC 19.10-p100 or later.
set lec_version_required "19.10100"
if {$lec_version >= $lec_version_required} {
    analyze_results -logfiles $logfile
}


# # Clean up
exit




close $logFile

