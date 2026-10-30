-------------------------------------------------------------------------------
-- counter.vhd  (Lab 0 - provided complete)
-- Free-running up-counter with synchronous reset and count enable.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  generic (WIDTH : positive := 26);
  port (
    clk : in  std_logic;
    rst : in  std_logic;                            -- synchronous, active high
    en  : in  std_logic;                            -- count when '1'
    q   : out std_logic_vector(WIDTH - 1 downto 0)
  );
end entity counter;

architecture rtl of counter is
  signal count : unsigned(WIDTH - 1 downto 0) := (others => '0');
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        count <= (others => '0');
      elsif en = '1' then
        count <= count + 1;
      end if;
    end if;
  end process;
  q <= std_logic_vector(count);
end architecture rtl;
