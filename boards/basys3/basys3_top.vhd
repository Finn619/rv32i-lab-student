-------------------------------------------------------------------------------
-- basys3_top.vhd  (Lab 7)
-- Digilent Basys 3 wrapper around the board-independent soc.
--   btnC = reset; buttons(3..0) = btnD, btnR, btnL, btnU
--   sw15..0 = switches; led15..0 = leds
--   4-digit multiplexed display shows hex_value(15..0)
-- Port names follow the Digilent master XDC.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity basys3_top is
  generic (
    IMEM_INIT : string := "";   -- simulation only
    DMEM_INIT : string := ""
  );
  port (
    clk      : in  std_logic;                       -- 100 MHz
    sw       : in  std_logic_vector(15 downto 0);
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    led      : out std_logic_vector(15 downto 0);
    seg      : out std_logic_vector(6 downto 0);    -- active low, seg(0) = CA
    dp       : out std_logic;
    an       : out std_logic_vector(3 downto 0);    -- active low
    vgaRed, vgaGreen, vgaBlue : out std_logic_vector(3 downto 0);
    Hsync, Vsync : out std_logic
  );
end entity basys3_top;

architecture rtl of basys3_top is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.7): Basys 3 wrapper.
  --   * clkgen (CLK_IN_HZ => 100_000_000) makes the 25 MHz clock.
  --   * Reset: btnC or MMCM not locked, through reset_sync.
  --   * soc: switches = sw, buttons = btnD & btnR & btnL & btnU.
  --   * led = leds.
  --   * sevenseg_mux shows hex_value(15 downto 0) with hex_blank(3 downto 0);
  --     dp off.
  --   * Leave the soc's trace outputs open.
  --   * Keep port-map actuals to plain signal names (no expressions).

end architecture rtl;
