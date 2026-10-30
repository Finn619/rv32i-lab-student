-------------------------------------------------------------------------------
-- lsu.vhd  (Lab 4)
-- Load/store unit: places store data on the correct byte lanes and extracts
-- and extends load data. Purely combinational.
--
-- The data bus is 32 bits wide and little-endian: byte lane k carries the byte
-- at word address + k, on bits 8k+7 .. 8k.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lsu is
  port (
    funct3     : in  std_logic_vector(2 downto 0);   -- size and signedness, instr[14:12]
    addr_lo    : in  std_logic_vector(1 downto 0);   -- effective address bits 1..0
    store_data : in  std_logic_vector(31 downto 0);  -- rs2 value for stores
    mem_rdata  : in  std_logic_vector(31 downto 0);  -- raw word read from memory
    byte_en    : out std_logic_vector(3 downto 0);   -- lanes touched by this access
    wdata      : out std_logic_vector(31 downto 0);  -- store data moved onto its lanes
    load_data  : out std_logic_vector(31 downto 0);  -- extracted, extended load result
    misaligned : out std_logic                       -- '1' if the access is not naturally aligned
  );
end entity lsu;

architecture rtl of lsu is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 4, Task 4.3): the load/store unit.
  --   Store side: from funct3 and addr_lo, produce byte_en (the lanes the
  --   access touches) and wdata (the store data moved onto those lanes).
  --   Load side: from the raw memory word, pick the addressed byte or
  --   halfword and sign- or zero-extend it according to funct3.
  --   misaligned = '1' when the address is not a multiple of the access size.
  --   * The bus is little-endian: lane k holds the byte at word address + k.
  --   * Purely combinational. The timing diagram in the lab sheet shows
  --     when mem_rdata is valid relative to addr_lo.

end architecture rtl;
