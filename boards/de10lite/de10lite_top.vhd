-------------------------------------------------------------------------------
-- de10lite_top.vhd  (Lab 7)
-- Terasic DE10-Lite wrapper around the board-independent soc.
--   KEY0 = reset (active low), KEY1 = buttons(0); SW9..0 = switches(9..0)
--   LEDR9..0 = leds(9..0); HEX5..HEX0 show hex_value(23..0), active low
-- Port names follow the Terasic golden top so the .qsf matches.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity de10lite_top is
  generic (
    IMEM_INIT : string := "";   -- simulation only
    DMEM_INIT : string := ""
  );
  port (
    MAX10_CLK1_50 : in  std_logic;
    KEY           : in  std_logic_vector(1 downto 0);
    SW            : in  std_logic_vector(9 downto 0);
    LEDR          : out std_logic_vector(9 downto 0);
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(7 downto 0);
    VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0);
    VGA_HS, VGA_VS      : out std_logic
  );
end entity de10lite_top;

architecture rtl of de10lite_top is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.7): DE10-Lite wrapper.
  --   * clkgen (CLK_IN_HZ => 50_000_000) makes the 25 MHz clock.
  --   * Reset: KEY0 (active low) or PLL not locked, through reset_sync.
  --   * soc: switches = SW (upper bits '0'), buttons(0) = not KEY(1).
  --   * LEDR = leds(9 downto 0).
  --   * HEX5..HEX0 show hex_value(23 downto 0): one sevenseg_dec per digit,
  --     active-low pins, decimal point (bit 7) off, honour hex_blank.
  --   * Leave the soc's trace outputs open.
  --   * Keep port-map actuals to plain signal names (no expressions).

end architecture rtl;
