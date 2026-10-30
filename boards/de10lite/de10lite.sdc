# de10lite.sdc - timing constraints for the DE10-Lite build
# Status: NOT SYNTHESISED IN AUTHORING ENVIRONMENT (no Quartus available).

# 50 MHz board oscillator
create_clock -name MAX10_CLK1_50 -period 20.000 [get_ports {MAX10_CLK1_50}]

# The PLL output clock (25 MHz) is derived automatically from the PLL settings.
derive_pll_clocks
derive_clock_uncertainty

# Switches and keys are asynchronous to every clock; they pass through
# synchronisers, so there is no meaningful input timing to check.
set_false_path -from [get_ports {KEY[*] SW[*]}]

# LEDs and seven-segment displays are viewed by humans.
set_false_path -to [get_ports {LEDR[*] HEX0[*] HEX1[*] HEX2[*] HEX3[*] HEX4[*] HEX5[*]}]

# VGA outputs come straight from registers; the DAC/monitor tolerate tens of
# nanoseconds of skew at 25 MHz, so they are not constrained further here.
set_false_path -to [get_ports {VGA_R[*] VGA_G[*] VGA_B[*] VGA_HS VGA_VS}]
