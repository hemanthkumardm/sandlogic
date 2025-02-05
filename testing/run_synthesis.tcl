puts "  ▒▓███████▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓███████▓▒  ▒▓█████████▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓████████▓▒  ▒▓███████▓▒ ▒▓█▓▒  ▒▓███████▓▒  "
puts " ▒▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒        ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒         "
puts " ▒▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒        ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒         "
puts "  ▒▓██████▓▒   ▒▓██████▓▒  ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓████████▓▒ ▒▓██████▓▒    ▒▓███████▓▒ ▒▓█▓▒  ▒▓██████▓▒   "
puts "        ▒▓█▓▒    ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒               ▒▓█▓▒ ▒▓█▓▒        ▒▓█▓▒  "
puts "        ▒▓█▓▒    ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒               ▒▓█▓▒ ▒▓█▓▒        ▒▓█▓▒  "
puts " ▒▓███████▓▒     ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒  ▒▓█▓▒ ▒▓████████▓▒ ▒▓███████▓▒  ▒▓█▓▒ ▒▓███████▓▒   "



# Get paths from environment variables
set DESIGN_NAME $::env(DESIGN_NAME)
set RTL_PATH $::env(RTL_PATH)
set LIB_PATH $::env(LIB_PATH)
set SDC_PATH $::env(SDC_PATH)
set NETLIST_PATH $::env(NELIST_PATH)
set REPORT_PATH $::env(REPORT_PATH)
set OUTPUT_PATH $::env(OUTPUT_PATH)
set LOG_PATH $::env(LOG_PATH)
set SCRIPTS_PATH $::env(SCRIPTS_PATH)
set EFFORT_LEVEL $::env(EFFORT_LEVEL)

set LIB_FILES [glob $LIB_PATH/*.lib]

set DATE [clock format [clock seconds] -format "%b%d-%T"] 

if {[llength $LIB_FILES] > 0} {
    puts "Using LIB files: $LIB_FILES"
} else {
    puts "Error: No library files found in folder: $LIB_PATH"
    exit 1
}
foreach file $LIB_FILES {
    read_libs  $file
}


set LEF_FILES [glob $LIB_PATH/*.lef]

if {[llength $LEF_FILES] > 0} {
    puts "Using LIB files: $LEF_FILES"
} else {
    puts "Error: No LEF files found in folder: $LEF_PATH"
    exit 1
}
foreach file $LEF_FILES {
    read_physical -lefs $file
}


set HDL_FILES [glob $RTL_PATH/*.sv]

if {[llength $HDL_FILES] > 0} {
    puts "Using HDL files: $HDL_FILES"
} else {
    puts "Error: No Verilog files found in folder: $HDL_FILES"
    exit 1
}

foreach file $HDL_FILES {
    read_hdl -language sv $file
}

elaborate 

# uniquify $DESIGN_NAME -verbose

set_db syn_generic_effort $EFFORT_LEVEL
syn_gen
puts "Runtime & Memory after 'syn_gen'"
time_info GENERIC



set_db syn_map_effort $EFFORT_LEVEL
syn_map
puts "Runtime & Memory after 'syn_map'"
time_info MAPPED



set_db syn_opt_effort $EFFORT_LEVEL
syn_opt
puts "Runtime & Memory after 'syn_opt'"
time_info OPT



write_hdl > ${OUTPUT_PATH}/${DESIGN_NAME}_netlist.v
write_sdc > ${OUTPUT_PATH}/${DESIGN_NAME}_netlist.sdc


check_design 
check_design -all > ${REPORT_PATH}/${DESIGN_NAME}_all.rpt
report timing -lint -verbose > ${REPORT_PATH}/${DESIGN_NAME}_timing.rpt


write_do_lec -golden_design rtl \
             -revised_design ${OUTPUT_\}/${DESIGN_NAME}_netlist.v \
             -no_exit \
             -verbose \
             -logfile ${LOG_PATH}/rtl_to_final.lec.log > ${SCRIPTS_PATH}/run_lec.do



puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

# move the tool's runtime log to the LOG_PATH directory
file rename genus.cmd ${LOG_PATH}/genus_${DATE}.cmd     
file rename genus.log ${LOG_PATH}/genus_${DATE}.log

set logFile [open "$LOG_PATH/synthesis.log" "a"]
puts $logFile "Starting synthesis for $DESIGN_NAME."
close $logFile

exit



