-------------------------------------------------------------------------------
-- clkgen.vhd  (Lab 7) - entity only
-- Board clock -> 25 MHz system clock. Exactly one architecture is compiled
-- per flow:
--   sim/clkgen_sim.vhd               behavioural model (GHDL/NVC)
--   boards/de10lite/clkgen_max10.vhd MAX 10 PLL (altpll), Quartus only
--   boards/basys3/clkgen_artix7.vhd  Artix-7 MMCME2_BASE, Vivado only
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity clkgen is
  generic (
    CLK_IN_HZ : positive := 50_000_000   -- board oscillator frequency
  );
  port (
    clk_in  : in  std_logic;
    areset  : in  std_logic;    -- active-high reset of the PLL/MMCM
    clk_out : out std_logic;    -- 25 MHz
    locked  : out std_logic     -- '1' once clk_out is stable
  );
end entity clkgen;
