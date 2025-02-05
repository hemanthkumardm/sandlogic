puts " ▒▓█▓▒        ▒▓█▓▒ ▒▓███████▓▒  ▒▓█████████▓▒ ▒▓█▓▒ ▒▓███████▓▒   ▒▓██████▓▒  "  
puts " ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ " 
puts " ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒        "
puts " ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒▒▓███▓▒ " 
puts " ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ " 
puts " ▒▓█▓▒        ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ " 
puts " ▒▓████████▓▒ ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒     ▒▓█▓▒     ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  ▒▓██████▓▒  " 
                                                                              



set DESIGN_NAME $::env(DESIGN_NAME)
set RTL_PATH $::env(RTL_PATH)
set LIB_PATH $::env(LIB_PATH)
set SDC_PATH $::env(SDC_PATH)
set REPORT_PATH $::env(REPORT_PATH)
set OUTPUT_PATH $::env(OUTPUT_PATH)
set LOG_PATH $::env(LOG_PATH)
set SCRIPTS_PATH $::env(SCRIPTS_PATH)

check_superlint -init

config_rtlds -rule -load ${LIB_PATH}/superlint.def

set RTL_PATH $RTL_PATH

analyze -clear

set HDL_FILES [glob $RTL_PATH/*.sv]
if {[llength $HDL_FILES] > 0} {
    puts "Using HDL files: $HDL_FILES"
} else {
    puts "Error: No Verilog files found in folder: $RTL_PATH"
    exit 1
}
foreach file $HDL_FILES {
    analyze -sv $file
}

elaborate -bbox_a 1024

clock axi_aclk

reset {axi_aresetn == 1'b0}

check_superlint -extract 

check_superlint -report


# Proper logging
set logFile [open "$LOG_PATH/linting.log" "a"]
puts $logFile "Starting LECs for $DESIGN_NAME."
close $logFile

                                                                              

