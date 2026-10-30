-------------------------------------------------------------------------------
-- dmem.vhd  (Lab 4)
-- Data memory: four 8-bit single-port RAM lanes give byte-enabled writes using
-- only the most portable inference template. Synchronous read.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.prog_image_pkg.all;

entity dmem is
  generic (
    WORDS     : positive := 8192;   -- size in 32-bit words; must be a power of two
    INIT_FILE : string   := ""      -- simulation only: hex image to load
  );
  port (
    clk   : in  std_logic;
    addr  : in  std_logic_vector(31 downto 0);  -- byte address; bits 1..0 ignored
    we    : in  std_logic_vector(3 downto 0);   -- byte-lane write enables
    wdata : in  std_logic_vector(31 downto 0);
    rdata : out std_logic_vector(31 downto 0)
  );
end entity dmem;

architecture rtl of dmem is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 4, Task 4.1): data memory with byte-lane writes.
  --   * Use four 8-bit-wide single-port RAMs, one per byte lane, so that
  --     each one matches the simplest vendor RAM inference template.
  --   * Each lane is initialised from its byte of
  --     region_image(REGION_DMEM_ID, WORDS, INIT_FILE).
  --   * Write lane k when we(k) = '1'; read data is registered (one cycle
  --     of latency, like block RAM).

end architecture rtl;
