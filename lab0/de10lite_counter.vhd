-------------------------------------------------------------------------------
-- de10lite_counter.vhd  (Lab 0) - counter on the DE10-Lite LEDs.
-- KEY0 = reset (active low), SW0 = enable. LEDR shows the top 10 bits of a
-- 26-bit counter clocked at 50 MHz (the top bit toggles about every 0.67 s).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity de10lite_counter is
  port (
    MAX10_CLK1_50 : in  std_logic;
    KEY           : in  std_logic_vector(1 downto 0);
    SW            : in  std_logic_vector(9 downto 0);
    LEDR          : out std_logic_vector(9 downto 0)
  );
end entity de10lite_counter;

architecture rtl of de10lite_counter is
  signal rst : std_logic;
  signal q   : std_logic_vector(25 downto 0);
begin
  rst <= not KEY(0);   -- Lab 0 shortcut: Lab 7 explains why a reset synchroniser is needed
  u_cnt : entity work.counter
    generic map (WIDTH => 26)
    port map (clk => MAX10_CLK1_50, rst => rst, en => SW(0), q => q);
  LEDR <= q(25 downto 16);
end architecture rtl;
