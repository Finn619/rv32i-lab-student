-------------------------------------------------------------------------------
-- vga_timing.vhd  (Lab 8)
-- 640x480 @ 60 Hz timing generator for a 25 MHz pixel clock.
--   Horizontal: 640 visible, 16 front porch, 96 sync, 48 back porch = 800
--   Vertical:   480 visible, 10 front porch,  2 sync, 33 back porch = 525
-- Both sync pulses are active low. All outputs are registered together, so
-- they describe the same pixel.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_timing is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    hcount    : out std_logic_vector(9 downto 0);  -- 0..799
    vcount    : out std_logic_vector(9 downto 0);  -- 0..524
    active    : out std_logic;                     -- '1' inside the 640x480 area
    hsync     : out std_logic;                     -- active low
    vsync     : out std_logic;                     -- active low
    in_vblank : out std_logic;                     -- '1' when vcount >= 480
    frame_end : out std_logic                      -- one-cycle pulse at the last pixel of a frame
  );
end entity vga_timing;

architecture rtl of vga_timing is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 8, Task 8.1): 640x480 @ 60 Hz timing generator (constants in
  -- the header comment above). hcount counts pixels 0..799 and vcount
  -- lines 0..524. Derive active, hsync, vsync, in_vblank and frame_end from
  -- the counters so that all outputs describe the same pixel.

end architecture rtl;
