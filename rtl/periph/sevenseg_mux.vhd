-------------------------------------------------------------------------------
-- sevenseg_mux.vhd  (Lab 7, Basys 3 only)
-- Time-multiplexes four digits onto a common-anode display. Each digit is lit
-- for 1/4 of the scan period. Outputs are active low, as on the Basys 3.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sevenseg_mux is
  generic (
    CLK_HZ   : positive := 25_000_000;
    DIGIT_HZ : positive := 1_000         -- per-digit switching rate
  );
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    value  : in  std_logic_vector(15 downto 0);  -- digit 3 = value(15:12)
    blank  : in  std_logic_vector(3 downto 0);   -- '1' turns that digit off
    seg_n  : out std_logic_vector(6 downto 0);   -- g..a, active low
    an_n   : out std_logic_vector(3 downto 0)    -- digit enables, active low
  );
end entity sevenseg_mux;

architecture rtl of sevenseg_mux is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.6, Basys 3 only): scan four digits.
  --   * Switch digits every CLK_HZ / DIGIT_HZ clock cycles.
  --   * Enable exactly one digit at a time (an_n active low); never enable
  --     a blanked digit.
  --   * Register the outputs so the pins do not glitch.

end architecture rtl;
