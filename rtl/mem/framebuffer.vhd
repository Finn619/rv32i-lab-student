-------------------------------------------------------------------------------
-- framebuffer.vhd  (Lab 8)
-- 160x120 RGB332 framebuffer, 4800 words of 4 pixels (pixel x at lane x mod 4).
-- Every byte lane is stored twice: one copy serves CPU reads, the other serves
-- the VGA scan-out. Both copies share the CPU write port, so they always hold
-- the same data. This uses only simple dual-port RAMs (portable inference).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity framebuffer is
  port (
    clk       : in  std_logic;
    -- CPU port (word index into the framebuffer)
    cpu_addr  : in  std_logic_vector(12 downto 0);   -- word index 0..4799
    cpu_we    : in  std_logic_vector(3 downto 0);    -- byte-lane write enables
    cpu_wdata : in  std_logic_vector(31 downto 0);
    cpu_rdata : out std_logic_vector(31 downto 0);   -- valid one cycle after cpu_addr
    -- VGA port
    vga_addr  : in  std_logic_vector(12 downto 0);   -- word index 0..4799
    vga_rdata : out std_logic_vector(31 downto 0)    -- valid one cycle after vga_addr
  );
end entity framebuffer;

architecture rtl of framebuffer is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 8, Task 8.3): the framebuffer.
  --   * 4800 words of four RGB332 pixels; pixel x of a row sits in lane
  --     x mod 4.
  --   * The CPU needs a read port (for blending) and the VGA scan-out needs
  --     another read port, while both see the same writes. Build this from
  --     ram_sdp instances only (no true dual-port RAM); the lab sheet
  --     explains the trade-off.
  --   * Ignore CPU writes to word indices >= 4800 and never index a RAM out
  --     of range, even for a delta cycle.

end architecture rtl;
