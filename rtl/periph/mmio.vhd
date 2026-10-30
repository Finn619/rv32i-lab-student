-------------------------------------------------------------------------------
-- mmio.vhd  (Lab 7)
-- Memory-mapped I/O registers at MMIO_BASE (see cpu_pkg and the memory map).
-- Writes honour byte-lane enables. Reads are registered (one-cycle latency),
-- matching the block-RAM regions so the core sees one uniform bus timing.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity mmio is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    -- bus side
    sel         : in  std_logic;                      -- '1': this cycle's access targets MMIO
    addr        : in  std_logic_vector(7 downto 0);   -- byte offset within the MMIO page
    we          : in  std_logic_vector(3 downto 0);   -- byte-lane write enables (already gated by sel)
    wdata       : in  std_logic_vector(31 downto 0);
    rdata       : out std_logic_vector(31 downto 0);  -- valid one cycle after the read
    -- device side
    switches    : in  std_logic_vector(15 downto 0);  -- synchronised
    buttons     : in  std_logic_vector(3 downto 0);   -- synchronised, active high
    cycles      : in  std_logic_vector(63 downto 0);
    vga_vblank  : in  std_logic;
    vga_frames  : in  std_logic_vector(15 downto 0);
    leds        : out std_logic_vector(15 downto 0);
    hex_value   : out std_logic_vector(31 downto 0);
    hex_blank   : out std_logic_vector(7 downto 0);
    vga_enable  : out std_logic
  );
end entity mmio;

architecture rtl of mmio is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.4): the memory-mapped registers in the memory map
  -- (lab sheet appendix and cpu_pkg MMIO_* constants).
  --   * Writes honour the byte-lane enables.
  --   * Reads are registered: rdata is valid one cycle after the access,
  --     like block RAM, so the core sees one uniform bus timing.
  --   * Unused offsets read as zero; writes to read-only registers are
  --     ignored.

end architecture rtl;
