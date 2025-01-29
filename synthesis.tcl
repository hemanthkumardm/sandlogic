#------------------------------------------------------------------------------#
# Initialization
#------------------------------------------------------------------------------#

puts "Enter the design name:"
gets stdin DESIGN_NAME


set WORK_DIR [pwd]
file mkdir $LOGS

#------------------------- LIBRARY-------------------------------------#

puts "Enter the library type (fast or slow). Default is 'slow':"
gets stdin lib_type

if {$lib_type eq ""} {
    set lib_type "slow"
}

# Set the TARGET_LIBRARY based on the user's input
if {$lib_type eq "fast"} {
    set TARGET_LIBRARY "/lib/fast_vdd1v0_basicCells.lib"
    puts "Library type set to 'fast'. Using: $TARGET_LIBRARY"
} elseif {$lib_type eq "slow"} {
    set TARGET_LIBRARY "/lib/slow_vdd1v0_basicCells.lib"
    puts "Library type set to 'slow'. Using: $TARGET_LIBRARY"
} else {
    # Invalid input
    puts "Invalid library type. Defaulting to 'slow'."
    set TARGET_LIBRARY "/lib/slow_vdd1v0_basicCells.lib"
}

puts "TARGET_LIBRARY is set to: $TARGET_LIBRARY"

#--------------------- VERILOG ------------------------#

set verilog_folder "./verilog"

set HDL_FILES [glob $verilog_folder/*.sv]

# Check if any Verilog files are found
if {[llength $HDL_FILES] > 0} {
    puts "Using HDL files: $HDL_FILES"
} else {
    puts "Error: No Verilog files found in folder: $verilog_folder"
    exit 1
}

# Read HDL files
foreach file $HDL_FILES {
    read_hdl -language sv $file
}


# ------------ OUTPUT AND REPORT DIR ------------------------------#


set OUTPUT_NETLIST "/output/synthesis_netlist.v"
set OUTPUT_REPORT_DIR "/reports"


if {![file isdirectory $OUTPUT_REPORT_DIR]} {
    file mkdir $OUTPUT_REPORT_DIR
}

if {![file isdirectory $OUTPUT_NETLIST]} {
    file mkdir $OUTPUT_NETLIST
}


#------------------------------------------------------------------------------#




#------------------------------------------------------------------------------#
# Elaborate the Design
#------------------------------------------------------------------------------#

elaborate 

#=------------------- SDC constraints ---------------------------------------#


set sdc_folder "$WORK_DIR/sdc/"
set sdc_files [glob -nocomplain $sdc_folder/*.sdc]

if {[llength $sdc_files] > 0} {
    set SDC_FILE [lindex $sdc_files 0]
    puts "Using SDC file: $SDC_FILE"
    
    read_sdc $SDC_FILE
} else {
    puts "Error: No SDC files found in folder: $sdc_folder"
    exit 1
}

report timing -lint



#------------------------------------------------------------------------------#
# Perform Synthesis
#------------------------------------------------------------------------------#

# Prompt the user to enter the effort type
puts "Enter the effort type (low, medium, high). Default is 'medium':"
gets stdin effort_type

# Set the default effort type if none is provided
if {$effort_type eq ""} {
    set effort_type "medium"
}

# Print the selected effort type
puts "Effort type set to: $effort_type"

# Apply the effort type to synthesis stages
if {$effort_type eq "low"} {
    set_db syn_generic_efforts low
    set_db syn_map_efforts low
    set_db syn_opt_efforts low
    puts "Effort set to 'low' for all synthesis stages."
} elseif {$effort_type eq "high"} {
    set_db syn_generic_efforts high
    set_db syn_map_efforts high
    set_db syn_opt_efforts high
    puts "Effort set to 'high' for all synthesis stages."
} else {
    # Default to 'medium' if an invalid or no effort type is provided
    set_db syn_generic_efforts medium
    set_db syn_map_efforts medium
    set_db syn_opt_efforts medium
    puts "Effort set to 'medium' (default) for all synthesis stages."
}

# Run the synthesis commands
syn_generic
syn_map
syn_opt

check_library
check_design
check_timing 
#------------------------------------------------------------------------------#
# Generate Reports
#------------------------------------------------------------------------------#

# Timing report
report_timing > $OUTPUT_REPORT_DIR/timing.rpt

# Area report
report_area > $OUTPUT_REPORT_DIR/area.rpt

# Power report
report_power > $OUTPUT_REPORT_DIR/power.rpt

#------------------------------------------------------------------------------#
# Export the Synthesized Design
#------------------------------------------------------------------------------#

# Write the synthesized netlist
write_hdl -mapped "$OUTPUT_NETLIST/$DESIGN_NAME}_net.v"

# Write updated constraints
write_sdc "$OUTPUT_REPORT_DIR/${DESIGN_NAME}_constraints.sdc"

write_do_lec -golden_design "${WORK_DIR}/$LEC/}golden_netlist.sv" \
	     -revised_design "${OUTPUT_NETLIST/$DESIGN_NAME}_net.v" \
	     -logfile "${WORK_DIR/$LOGS}_rtl_to_final.lec.log"

puts "Synthesis completed successfully!"
