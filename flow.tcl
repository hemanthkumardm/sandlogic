#! /bin/env tclsh

puts "Set your technology using variable \"tech_name\""
set tech_name 45nm
puts "Setting technology to $tech_name"

puts "This is the place where all scripts are located"
set scripts scripts
puts "Setting variable 'proc_dir' to $scripts\n" 

puts "tcl_precision specifies the number of digits to generate when converting floating point values to strings"
set tcl_precision 3
puts "Setting variable 'tcl_precision' to $tcl_precision\n"


#read -p "Set generate_sdc to '1' if you want to generate sdc: " SDC
#set generate_sdc $SDC
#puts "Setting variable 'generate_sdc' to $generate_sdc\n"

#read -p "Set generate_report to '1' if you want to generate area, power and timing reports of your design. Else, set this variable to '0'" REPORTS
#set generate_report $REPORTS
#puts "Setting variable 'generate_report' to $generate_report\n"

#-----------------------------------------------------------#

set working_dir [exec pwd]
set vsd_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $vsd_array_length-1]

if {![regexp {^csv} $input] || $argc!=1 } {
	puts "Error in usage"
	puts "Usage: ./vsdsynth <.csv>"
	puts "where <.csv> file has below inputs"
	exit
} else {
	set filename [lindex $argv 0]
	package require csv
	package require struct::matrix
	struct::matrix m
	set f [open $filename]
	csv::read2matrix $f m , auto
	close $f
	set columns [m columns]
	m add columns $columns
	m link my_arr
	set num_of_rows [m rows]
	set i 0
	while {$i < $num_of_rows} {
		 puts "\nInfo: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
		 if {$i == 0} {
			 set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
		 } else {
			 set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
		 }
		  set i [expr {$i+1}]
	}
} 

puts "\nInfo: Below are the list of initial variables and their values. User can use these variables for further debug. Use 'puts <variable name>' command to query value of below variables"
puts "ModuleName = $module_name"
puts "Verilog = $verilog"
puts "Netlist = $netlist"
puts "SDC = $sdc"
puts "Library = $library"
puts "Reports = $reports"
puts "Outputs = $outputs"
puts "Logs = $logs"

#-------------------------------------------------------------------------------------------#
#-----Below script checks if directories and files mentioned in csv file, exists or not-----#
#-------------------------------------------------------------------------------------------#

if {! [file exists $verilog] } {
	puts "\nError: Cannot find verilog dir in path $verilog. Exiting... "
	exit
} else {
	puts "\nInfo: verilog dir found in path $verilog"
}

if {! [file exists $library] } {
	puts "\nError: Cannot find library dir in path $library. Exiting... "
	exit
} else {
	puts "\nInfo: verilog file found in path $library"
}

if {! [file exists $logs]} {
        puts "\nError: Cannot find logs dir in path $logs. Creating $logs"
	file mkdir $logs
} else {
	puts "\nInfo: logs file found in path $logs"
}

if {![file isdirectory $outputs]} {
	puts "\nInfo: Cannot find output directory $outputs. Creating $outputs"
	file mkdir $outputs
} else {
	puts "\nInfo: output directory found in path $outputs"
}

if {![file isdirectory $reports]} {
	puts "\nInfo: Cannot find report directory $reports. Creating $reports"
	file mkdir $reports
} else {
	puts "\nInfo: output directory found in path $reports"
}

if {! [file isdirectory $netlist]} {
	puts "\nError: Cannot find RTL netlist directory in path $netlist. Exiting..."
	exit	
} else {
	puts "\nInfo: RTL netlist directory found in path $netlist"
}

if {! [file exists $sdc] } {
        puts "\nError: Cannot find constraints file in path $sdc. Exiting... "
        exit
} else {
        puts "\nInfo: Constraints file found in path $sdc"
}



#----------------------------------------------------------------------------#
#-------------Hierarchy check and synthesis using ---------------------------#
#----------------------------------------------------------------------------#
puts "which flow you want to run type 1 for synthesis, 2 for floorplanning, 3 for placement, 4 for sta, 5 for pnr"
gets stdin CHOICE
set SYNTHESIS $CHOICE

puts "\nStarting synthesis using genus"
if {$SYNTHESIS == 1} {
	set SYNTH_SCRIPT "$scripts/synth.sh"
	exec bash $SYNTH_SCRIPT
}







#if {![file isdirectory $outputs/source]} {
#file mkdir $outputs/source
#}

#if {![file isdirectory $outputs/synthesis]} {
#file mkdir $outputs/synthesis
#}

#if {![file isdirectory $outputs/layout]} {
#file mkdir $outputs/layout
#}
#
#set netlist [glob -dir $NetlistDirectory *.v]
#foreach f $netlist {
#	set qverilog [file tail $f]
#	if {![file exists $OutputDirectory/source/$qverilog]} {
#	file link -symbolic $OutputDirectory/source/$qverilog $f
#	}
#}

#cd $working_dir

#if {[file exists $outputs/$module_name.synth.v]} {
#	file delete -force $outputs/$module_name.synth.v
#}


#if {$run_synthesis == 1} {
#	if {$err == 1} { 
#		puts "\nSynthesis finished with errors"
#		} else {
#		puts "\nSynthesis finished without errors"
#	}

#	puts "\nPlease review log file \"$logs/log/synth.log\" for errors/warnings "
#}

#puts "\nInfo: Please find the synthesized netlist for $module_name at below path."
#puts "\n$netlist/${DesignName}_synth.v" 
# source $scripts/read_sdc.tcl
#read_sdc $sdc/$module_name.sdc

