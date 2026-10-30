# create_lab0.tcl - Quartus project for the Lab 0 counter on the DE10-Lite
#   quartus_sh -t scripts/quartus/create_lab0.tcl [compile]
# STATUS: NOT SYNTHESISED IN AUTHORING ENVIRONMENT.
package require ::quartus::project
package require ::quartus::flow

set root [file normalize [file join [file dirname [info script]] .. ..]]
set proj_dir "$root/build/quartus_lab0"
file mkdir $proj_dir
cd $proj_dir
project_new lab0_counter -revision lab0_counter -overwrite
set_global_assignment -name FAMILY "MAX 10"
set_global_assignment -name DEVICE 10M50DAF484C7G
set_global_assignment -name TOP_LEVEL_ENTITY de10lite_counter
set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name VHDL_FILE "$root/lab0/counter.vhd"
set_global_assignment -name VHDL_FILE "$root/lab0/de10lite_counter.vhd"
set_global_assignment -name SDC_FILE  "$root/lab0/de10lite_counter.sdc"
# The full board pin file also names pins this design does not use; Quartus
# ignores those assignments with a warning.
source "$root/boards/de10lite/de10lite.qsf"
export_assignments
if {$argc >= 1 && [lindex $argv 0] eq "compile"} {
    execute_flow -compile
}
project_close
