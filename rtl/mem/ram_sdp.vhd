-------------------------------------------------------------------------------
-- ram_sdp.vhd  (Lab 8)
-- Simple dual-port RAM, one clock: one write port, one independent read port.
-- Synchronous read; a read of the address being written returns the old data.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_sdp is
  generic (
    DEPTH : positive := 4800;
    WIDTH : positive := 8
  );
  port (
    clk   : in  std_logic;
    we    : in  std_logic;
    waddr : in  natural range 0 to DEPTH - 1;
    wdata : in  std_logic_vector(WIDTH - 1 downto 0);
    raddr : in  natural range 0 to DEPTH - 1;
    rdata : out std_logic_vector(WIDTH - 1 downto 0)
  );
end entity ram_sdp;

architecture rtl of ram_sdp is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 8, Task 8.2): simple dual-port RAM (one write port, one
  -- independent read port, one clock, registered read).
  --   * Use your vendor's simple dual-port inference template.
  --   * Check that your template really gives the read-during-write
  --     behaviour stated in the header, and say why the framebuffer
  --     never depends on it.

end architecture rtl;
