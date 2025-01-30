package require json

set json_file "../../asic_config.json"
set json_data [json::json2dict [read [open $json_file]]]

set design_name [lindex [dict keys $json_data] 0]

set design_data [dict get $json_data udp]
set asic_flow_data [dict get $design_data asic_flow]
set synthesis_data [dict get $asic_flow_data synthesis]

set script [dict get $synthesis_data script]
set rtl_path [dict get $synthesis_data rtl_path]
set lib_path [dict get $synthesis_data lib_path]
set sdc_path [dict get $synthesis_data sdc_path]
set report_path [dict get $synthesis_data report_path]
set output_path [dict get $synthesis_data output_path]
set log_path [dict get $synthesis_data log_path]
set scripts_path [dict get $synthesis_data scripts_path]

foreach DIR "$rtl_path $lib_path $sdc_path" {
    if {![file exists $DIR]} {
        puts "ERROR: Directory does not exist: $DIR"
        exit 1
    }

    set files [glob -nocomplain -directory $DIR *]
    if {[llength $files] == 0} {
        puts "ERROR: No files found in directory: $DIR"
        # exit 1
    } else {
        puts "Found [llength $files] file(s) in directory: $DIR"
    }
}

set lib_files [glob -nocomplain -directory $lib_path *.lib]
if {[llength $lib_files] == 0} {
    puts "ERROR: No library files found in directory: $lib_path"
    exit 1
} else {
    puts "Found [llength $lib_files] library file(s) in directory: $lib_path"
    foreach lib $lib_files {
        puts "Library: $lib"
    }
}


set_attribute lib_search_path "$lib_path"
read_libs $lib_files

set target_library [lindex $lib_files 0]
set_attribute library $target_library
puts "Target library set to: $target_library"

read_hdl -sv [glob $rtl_path/*.sv $rtl_path/*.v]

elaborate

set sdc_file [lindex $sdc_path 0]
read_sdc $sdc_file

# synthesize -to_mapped

# # Save the synthesized netlist
# write_hdl > $output_path/synthesized_netlist.v

# # Generate reports
# report timing > $report_path/timing_report.txt
# report area > $report_path/area_report.txt

# read_libs $lib_path

# # Read RTL files
# read_hdl $RTL_PATH/*.v

# # Read constraints
# read_sdc $SDC_PATH/*.sdc

# # Synthesis
# synthesize -to_mapped

# # Save results
# write_design -out $OUT_PATH/netlist.v
# write_sdc $SDC_PATH/constraints.sdc
# write_reports -out $RPT_PATH/synthesis_report.rpt

# puts "Synthesis completed successfully. Logs stored in $LOG_PATH"