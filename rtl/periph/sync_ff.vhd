-------------------------------------------------------------------------------
-- sync_ff.vhd  (Lab 7)
-- Two-flip-flop synchroniser for slow asynchronous inputs (switches, buttons).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity sync_ff is
  generic (WIDTH : positive := 1);
  port (
    clk  : in  std_logic;
    din  : in  std_logic_vector(WIDTH - 1 downto 0);  -- asynchronous input
    dout : out std_logic_vector(WIDTH - 1 downto 0)   -- synchronised to clk
  );
end entity sync_ff;

architecture rtl of sync_ff is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.2): two-flip-flop synchroniser for slow asynchronous
  -- inputs. Why two flip-flops? Your theory answers should say.

end architecture rtl;
