# Ensure the YAML package is installed
package require yaml

# Load the YAML file into a variable
set yaml_file "../../asic_config.yaml"
set yaml_data [yaml::loadfile $yaml_file]

# Extracting the paths from the YAML data
set udp_data [dict get $yaml_data udp]
set asic_flow_data [dict get $udp_data asic_flow]
set synthesis_data [dict get $asic_flow_data synthesis]

# Extract paths
set script_path [dict get $synthesis_data script]
set rtl_path [dict get $synthesis_data rtl_path]
set lib_path [dict get $synthesis_data lib_path]
set sdc_path [dict get $synthesis_data sdc_path]
set report_path [dict get $synthesis_data report_path]
set output_path [dict get $synthesis_data output_path]
set log_path [dict get $synthesis_data log_path]
set scripts_path [dict get $synthesis_data scripts_path]

# Print paths to verify they are loaded
puts "Script Path: $script_path"
puts "RTL Path: $rtl_path"
puts "Lib Path: $lib_path"
puts "SDC Path: $sdc_path"
puts "Report Path: $report_path"
puts "Output Path: $output_path"
puts "Log Path: $log_path"
puts "Scripts Path: $scripts_path"

# Now you can use these paths in your TCL script as needed
