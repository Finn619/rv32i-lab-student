# create_lab0.tcl - Vivado project for the Lab 0 counter on the Basys 3
#   vivado -mode batch -source scripts/vivado/create_lab0.tcl [-tclargs build]
# STATUS: NOT SYNTHESISED IN AUTHORING ENVIRONMENT.
set root [file normalize [file join [file dirname [info script]] .. ..]]
set proj_dir "$root/build/vivado_lab0"
create_project lab0_counter $proj_dir -part xc7a35tcpg236-1 -force
add_files -norecurse [list "$root/lab0/counter.vhd" "$root/lab0/basys3_counter.vhd"]
set_property file_type {VHDL 2008} [get_files -of_objects [get_filesets sources_1]]
add_files -fileset constrs_1 -norecurse "$root/lab0/basys3_counter.xdc"
set_property top basys3_counter [current_fileset]
if {$argc >= 1 && [lindex $argv 0] eq "build"} {
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
}
