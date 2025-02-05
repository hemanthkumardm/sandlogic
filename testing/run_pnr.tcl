puts  "  ▓███████▓▒  ▒▓███████▓▒  ▒▓███████▓▒   " 
puts  "  ▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts  "  ▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts  "  ▓███████▓▒  ▒▓█▓▒  ▒▓█▓▒ ▒▓███████▓   " 
puts  "  ▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts  "  ▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts  "  ▓█▓▒        ▒▓█▓▒  ▒▓█▓▒ ▒▓█▓▒  ▒▓█▓▒  " 
puts  "                                         " 
                                         


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
close $logFile

