# de10lite_counter.sdc - Lab 0 timing constraints
# Status: NOT SYNTHESISED IN AUTHORING ENVIRONMENT (no Quartus available).
create_clock -name MAX10_CLK1_50 -period 20.000 [get_ports {MAX10_CLK1_50}]
derive_clock_uncertainty
set_false_path -from [get_ports {KEY[*] SW[*]}]
set_false_path -to [get_ports {LEDR[*]}]
