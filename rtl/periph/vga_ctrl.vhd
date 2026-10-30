-------------------------------------------------------------------------------
-- vga_ctrl.vhd  (Lab 8)
-- Scans the 160x120 framebuffer out as 640x480 (each pixel repeated 4x4) and
-- expands RGB332 to 4 bits per channel.
--
-- Pipeline (one stage per clock):
--   0: counters -> framebuffer word address (registered inside the RAM)
--   1: RAM data valid; lane select and colour expansion
--   2: output registers drive the pins
-- Sync and blanking are delayed by the same two cycles so they stay aligned
-- with the pixel data.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_ctrl is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    enable      : in  std_logic;                      -- '0' forces black output (syncs keep running)
    fb_addr     : out std_logic_vector(12 downto 0);  -- word index to the framebuffer VGA port
    fb_rdata    : in  std_logic_vector(31 downto 0);  -- word at fb_addr, one cycle later
    vga_r       : out std_logic_vector(3 downto 0);
    vga_g       : out std_logic_vector(3 downto 0);
    vga_b       : out std_logic_vector(3 downto 0);
    vga_hs      : out std_logic;
    vga_vs      : out std_logic;
    in_vblank   : out std_logic;
    frame_count : out std_logic_vector(15 downto 0)   -- increments once per frame
  );
end entity vga_ctrl;

architecture rtl of vga_ctrl is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 8, Task 8.4): scan-out pipeline.
  --   * From hcount/vcount compute the framebuffer word index
  --     (y * 160 + x) / 4 with x = hcount / 4, y = vcount / 4 - without a
  --     multiplier (shifts and adds).
  --   * The RAM returns data one cycle later: delay the lane select, the
  --     blanking and both syncs so that everything reaching the pins in the
  --     same cycle describes the same pixel.
  --   * Expand RGB332 to 4 bits per channel by bit replication (lab sheet).
  --   * Output black outside the visible area or when enable = '0'.
  --   * Count frames on frame_end.

end architecture rtl;
