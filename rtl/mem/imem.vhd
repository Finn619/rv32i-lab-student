-------------------------------------------------------------------------------
-- imem.vhd  (Lab 4)
-- Instruction memory: synchronous-read ROM. rdata in cycle n+1 is the word at
-- the address presented in cycle n (FPGA block RAM behaviour).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.prog_image_pkg.all;

entity imem is
  generic (
    WORDS     : positive := 8192;   -- size in 32-bit words; must be a power of two
    INIT_FILE : string   := ""      -- simulation only: hex image to load
  );
  port (
    clk   : in  std_logic;
    addr  : in  std_logic_vector(31 downto 0);  -- byte address; bits 1..0 ignored
    rdata : out std_logic_vector(31 downto 0)
  );
end entity imem;

architecture rtl of imem is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 4, Task 4.1): instruction memory as a synchronous-read ROM.
  --   * Initialise a constant (or signal) array from
  --     region_image(REGION_IMEM_ID, WORDS, INIT_FILE).
  --   * Register the read data on the rising edge (block-RAM behaviour).
  --   * Index with word address bits only (addr is a byte address).
  --   * Follow your vendor's ROM inference template; the lab sheet lists
  --     where to find it for Vivado and Quartus.

end architecture rtl;
