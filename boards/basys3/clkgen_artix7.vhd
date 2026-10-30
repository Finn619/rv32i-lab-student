-------------------------------------------------------------------------------
-- clkgen_artix7.vhd  (Vivado only - Basys 3)
-- 100 MHz -> 25 MHz using an Artix-7 MMCME2_BASE.
--   VCO = 100 MHz * 10 / 1 = 1000 MHz (legal range 600..1200 MHz, -1 grade)
--   CLKOUT0 = 1000 MHz / 40 = 25 MHz
-- Status: NOT SYNTHESISED IN AUTHORING ENVIRONMENT (no Vivado available).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

architecture artix7 of clkgen is
  signal clkfb_raw, clkfb_buf, clk0_raw : std_logic;
begin

  assert CLK_IN_HZ = 100_000_000
    report "clkgen(artix7): MMCM settings assume a 100 MHz input" severity failure;

  u_mmcm : MMCME2_BASE
    generic map (
      BANDWIDTH        => "OPTIMIZED",
      CLKIN1_PERIOD    => 10.0,
      DIVCLK_DIVIDE    => 1,
      CLKFBOUT_MULT_F  => 10.0,
      CLKOUT0_DIVIDE_F => 40.0,
      CLKOUT0_PHASE    => 0.0,
      STARTUP_WAIT     => FALSE
    )
    port map (
      CLKIN1   => clk_in,
      CLKFBIN  => clkfb_buf,
      CLKFBOUT => clkfb_raw,
      CLKOUT0  => clk0_raw,
      LOCKED   => locked,
      PWRDWN   => '0',
      RST      => areset
    );

  u_fb_buf  : BUFG port map (I => clkfb_raw, O => clkfb_buf);
  u_clk_buf : BUFG port map (I => clk0_raw,  O => clk_out);

end architecture artix7;
