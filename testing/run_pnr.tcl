# ASCII Art (prints some stylized graphics)
puts "  ▓███████▓▒  ▒▓███████▓▒  ▒▓███████▓▒   " 
puts "  ▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts "  ▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts "  ▓███████▓▒  ▒▓█▓▒  ▒▓█▓▒ ▒▓███████▓   " 
puts "  ▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts "  ▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts "  ▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts "                                         " 

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
set logFile [open "$LOG_PATH/pnr.log" "a"]
puts $logFile "Starting PNR for $DESIGN_NAME."

#Updated by awarrier
set init_assign_buffer 1
set init_design_settop 0
set init_pwr_net VDD
set init_gnd_net VSS
setImportMode -keepEmptyModule 1 -treatUndefinedCellAsBbox 0 -useLefDef56 1
set init_import_mode { -keepEmptyModule 1 -treatUndefinedCellAsBbox 0 -useLefDef56 1}

# set init_io_file DATA/asic_entity.io


set LEF_FILES [glob $LIB_PATH/*.lef]

if {[llength $LEF_FILES] > 0} {
    puts "Using LIB files: $LEF_FILES"
} else {
    puts "Error: No LEF files found in folder: $LEF_PATH"
    exit 1
}
foreach file $LEF_FILES {
    set init_lef_file {$file}
}

# set init_lef_file {libs/lef/gsclib045.fixed2.lef libs/lef/pdkIO.lef libs/lef/MEM2_4096X32.lef libs/lef/MEM2_2048X32.lef libs/lef/MEM2_1024X32.lef libs/lef/MEM2_512X32.lef libs/lef/MEM2_136X32.lef libs/lef/MEM2_128X32.lef libs/lef/MEM2_128X16.lef libs/lef/MEM1_4096X32.lef libs/lef/MEM1_1024X32.lef libs/lef/MEM1_256X32.lef DATA/leon.partition.lef DATA/periph1.partition.lef}


set init_mmmc_file $SCRIPTS/viewDefinition.tcl
set init_top_cell $DESIGN_NAME
set init_verilog ${OUTPUT_PATH}/${DESIGN_NAME}_netlist.v
set_timing_derate -delay_corner fast_min  -cell_delay -early 0.97 
set_timing_derate -delay_corner fast_min  -cell_delay -late 1.03 
set_timing_derate -delay_corner fast_min  -net_delay -early 0.97 
set_timing_derate -delay_corner fast_min  -net_delay -late 1.03 
set_timing_derate -delay_corner slow_max  -cell_delay -early 0.97 
set_timing_derate -delay_corner slow_max  -cell_delay -late 1.03 
set_timing_derate -delay_corner slow_max  -net_delay -early 0.97 
set_timing_derate -delay_corner slow_max  -net_delay -late 1.03 

init_design

setIoFlowFlag 0


puts "Design initialization complete."
close $logFile