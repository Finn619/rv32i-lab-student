# create_project.tcl - Vivado project for the Basys 3 (Lab 7/8)
#
#   cd <repo root>
#   vivado -mode batch -source scripts/vivado/create_project.tcl -tclargs [path/to/prog_image_body.vhd] [build]
#
# The memory image defaults to the Lab 7 board test; build it first with
#   make -C sw/lab07
# With "build", synthesis, implementation and bitstream generation run and
# timing/utilisation reports are written to build/vivado/reports/.
#
# STATUS: NOT SYNTHESISED IN AUTHORING ENVIRONMENT (Vivado was not available
# where this lab was written). Report problems to your instructor.

set root [file normalize [file join [file dirname [info script]] .. ..]]
if {$argc >= 1} {
    set image [file normalize [lindex $argv 0]]
} else {
    set image "$root/sw/lab07/build/board_test/prog_image_body.vhd"
}
if {![file exists $image]} {
    error "memory image '$image' not found - build the program first (e.g. make -C sw/lab07)"
}

set proj_dir "$root/build/vivado"
create_project basys3_rv32i $proj_dir -part xc7a35tcpg236-1 -force

set srcs {}
set fh [open "$root/rtl/sources.f"]
foreach line [split [read $fh] "\n"] {
    set f [string trim $line]
    if {$f eq "" || [string index $f 0] eq "#"} { continue }
    lappend srcs "$root/$f"
}
close $fh
lappend srcs $image "$root/boards/basys3/clkgen_artix7.vhd" "$root/boards/basys3/basys3_top.vhd"
add_files -norecurse $srcs
set_property file_type {VHDL 2008} [get_files -of_objects [get_filesets sources_1]]
add_files -fileset constrs_1 -norecurse "$root/boards/basys3/basys3.xdc"
set_property top basys3_top [current_fileset]
update_compile_order -fileset sources_1

if {$argc >= 2 && [lindex $argv 1] eq "build"} {
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    open_run impl_1
    file mkdir "$proj_dir/reports"
    report_timing_summary -file "$proj_dir/reports/timing_summary.rpt"
    report_utilization    -file "$proj_dir/reports/utilisation.rpt"
    puts "Bitstream: [get_property DIRECTORY [get_runs impl_1]]/basys3_top.bit"
}
