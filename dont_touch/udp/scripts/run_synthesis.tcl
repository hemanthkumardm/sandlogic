puts " ░▒▓███████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░░▒▓███████▓▒░▒▓█▓▒░░▒▓███████▓▒░ "
puts "░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░        "
puts "░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░        "
puts " ░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓████████▓▒░▒▓██████▓▒░  ░▒▓██████▓▒░░▒▓█▓▒░░▒▓██████▓▒░  "
puts "       ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░ "
puts "       ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░ "
puts "░▒▓███████▓▒░   ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░▒▓███████▓▒░  "



# Get paths from environment variables
set DESIGN_NAME $::env(DESIGN_NAME)
set RTL_PATH $::env(RTL_PATH)
set LIB_PATH $::env(LIB_PATH)
set SDC_PATH $::env(SDC_PATH)
set REPORT_PATH $::env(REPORT_PATH)
set OUTPUT_PATH $::env(OUTPUT_PATH)
set LOG_PATH $::env(LOG_PATH)
set SCRIPTS_PATH $::env(SCRIPTS_PATH)
set EFFORT_LEVEL $::env(EFFORT_LEVEL)

# Debugging - Print paths to ensure they are correct
puts "RTL_PATH: $RTL_PATH" 

# Proper logging
set logFile [open "$LOG_PATH/synthesis.log" "a"]
puts $logFile "Starting synthesis for $DESIGN_NAME."
close $logFile


# # Load libraries
# read_lib $LIB_PATH/*.lib

# # Read RTL files
# read_verilog $RTL_PATH/*.v
# read_verilog $RTL_PATH/*.sv

# # Apply constraints
# read_sdc $SDC_PATH/*.sdc

# # Elaborate the design
# elaborate $DESIGN_NAME

# # Set up synthesis options (you can customize these)
# set_attribute -design_style area
# set_attribute -target_cell_library "your_cell_library"
# set_attribute -optimize_power true

# # Run the synthesis process
# synthesize -top $DESIGN_NAME

# # Report synthesis results
# report_timing -path $REPORT_PATH/timing_report.txt
# report_area -path $REPORT_PATH/area_report.txt
# report_power -path $REPORT_PATH/power_report.txt

# # Save the output
# write_verilog -output $OUTPUT_PATH/$DESIGN_NAME.synthesized.v

# # Clean up
# exit
