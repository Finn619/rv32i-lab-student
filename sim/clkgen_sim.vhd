-------------------------------------------------------------------------------
-- clkgen_sim.vhd  (SIMULATION ONLY)
-- Behavioural stand-in for the PLL/MMCM: divides the board clock down to
-- 25 MHz and raises 'locked' after a short delay.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

architecture sim of clkgen is
  constant HALF : positive := CLK_IN_HZ / 50_000_000;  -- input cycles per output half-period
  signal cnt     : natural range 0 to HALF - 1 := 0;
  signal clk_i   : std_logic := '0';
  signal lockcnt : natural range 0 to 15 := 0;
begin

  assert CLK_IN_HZ mod 50_000_000 = 0
    report "clkgen(sim): CLK_IN_HZ must be a multiple of 50 MHz" severity failure;

  process(clk_in)
  begin
    if rising_edge(clk_in) then
      if cnt = HALF - 1 then
        cnt   <= 0;
        clk_i <= not clk_i;
      else
        cnt <= cnt + 1;
      end if;
    end if;
  end process;

  process(clk_i, areset)
  begin
    if areset = '1' then
      lockcnt <= 0;
    elsif rising_edge(clk_i) then
      if lockcnt /= 15 then
        lockcnt <= lockcnt + 1;
      end if;
    end if;
  end process;

  clk_out <= clk_i;
  locked  <= '1' when lockcnt = 15 else '0';

end architecture sim;
