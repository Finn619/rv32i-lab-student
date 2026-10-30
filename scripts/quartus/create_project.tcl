# create_project.tcl - Quartus Prime Lite project for the DE10-Lite (Lab 7/8)
#
#   cd <repo root>
#   quartus_sh -t scripts/quartus/create_project.tcl [path/to/prog_image_body.vhd] [compile]
#
# The memory image defaults to the Lab 7 board test; build it first with
#   make -C sw/lab07
# With the optional second argument "compile", the full flow is run and the
# timing summary is written to build/quartus/output_files/.
#
# STATUS: NOT SYNTHESISED IN AUTHORING ENVIRONMENT (Quartus was not available
# where this lab was written). Report problems to your instructor.

package require ::quartus::project
package require ::quartus::flow

set root [file normalize [file join [file dirname [info script]] .. ..]]
if {$argc >= 1} {
    set image [file normalize [lindex $argv 0]]
} else {
    set image "$root/sw/lab07/build/board_test/prog_image_body.vhd"
}
if {![file exists $image]} {
    error "memory image '$image' not found - build the program first (e.g. make -C sw/lab07)"
}

set proj_dir "$root/build/quartus"
file mkdir $proj_dir
cd $proj_dir

project_new de10lite_rv32i -revision de10lite_rv32i -overwrite

set_global_assignment -name FAMILY "MAX 10"
set_global_assignment -name DEVICE 10M50DAF484C7G
set_global_assignment -name TOP_LEVEL_ENTITY de10lite_top
set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
# MAX 10 block RAM can only start with initial contents in a configuration
# mode that includes memory initialisation (otherwise Error 14703).
set_global_assignment -name INTERNAL_FLASH_UPDATE_MODE "SINGLE COMP IMAGE WITH ERAM"
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL

# Board-independent sources, then the memory image and the board files.
set fh [open "$root/rtl/sources.f"]
foreach line [split [read $fh] "\n"] {
    set f [string trim $line]
    if {$f eq "" || [string index $f 0] eq "#"} { continue }
    set_global_assignment -name VHDL_FILE "$root/$f"
}
close $fh
set_global_assignment -name VHDL_FILE $image
set_global_assignment -name VHDL_FILE "$root/boards/de10lite/clkgen_max10.vhd"
set_global_assignment -name VHDL_FILE "$root/boards/de10lite/de10lite_top.vhd"
set_global_assignment -name SDC_FILE  "$root/boards/de10lite/de10lite.sdc"

# Pin locations and I/O standards
source "$root/boards/de10lite/de10lite.qsf"

export_assignments

if {$argc >= 2 && [lindex $argv 1] eq "compile"} {
    execute_flow -compile
    puts "Done. Bitstream: $proj_dir/output_files/de10lite_rv32i.sof"
    puts "Timing: see $proj_dir/output_files/de10lite_rv32i.sta.summary"
}
project_close
