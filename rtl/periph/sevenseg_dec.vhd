-------------------------------------------------------------------------------
-- sevenseg_dec.vhd  (Lab 7)
-- Hexadecimal digit to seven-segment pattern. Output is active high, bit 0 =
-- segment a ... bit 6 = segment g. Board wrappers invert for active-low pins.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity sevenseg_dec is
  port (
    digit : in  std_logic_vector(3 downto 0);
    segs  : out std_logic_vector(6 downto 0)   -- g f e d c b a
  );
end entity sevenseg_dec;

architecture rtl of sevenseg_dec is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.3): hexadecimal digit -> segments (active high,
  -- bit 0 = segment a ... bit 6 = segment g). Derive the table from your
  -- board's display diagram. Purely combinational.

end architecture rtl;
