-------------------------------------------------------------------------------
-- cycle_counter.vhd  (Lab 7/8)
-- Free-running 64-bit clock-cycle counter.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cycle_counter is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    count : out std_logic_vector(63 downto 0)
  );
end entity cycle_counter;

architecture rtl of cycle_counter is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.4): a free-running 64-bit cycle counter, cleared by
  -- the synchronous reset.

end architecture rtl;
