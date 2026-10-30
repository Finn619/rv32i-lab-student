-------------------------------------------------------------------------------
-- basys3_counter.vhd  (Lab 0) - counter on the Basys 3 LEDs.
-- btnC = reset, sw0 = enable. led shows the top 16 bits of a 27-bit counter
-- clocked at 100 MHz (the top bit toggles about every 0.67 s).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity basys3_counter is
  port (
    clk  : in  std_logic;
    btnC : in  std_logic;
    sw   : in  std_logic_vector(15 downto 0);
    led  : out std_logic_vector(15 downto 0)
  );
end entity basys3_counter;

architecture rtl of basys3_counter is
  signal q : std_logic_vector(26 downto 0);
begin
  u_cnt : entity work.counter
    generic map (WIDTH => 27)
    port map (clk => clk, rst => btnC, en => sw(0), q => q);
  led <= q(26 downto 11);
end architecture rtl;
