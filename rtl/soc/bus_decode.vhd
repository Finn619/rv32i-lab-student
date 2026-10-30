-------------------------------------------------------------------------------
-- bus_decode.vhd  (Lab 5/7)
-- Data-bus address decoder and read-data multiplexer.
-- Region = addr[31:28]. The read multiplexer uses the region registered in the
-- previous cycle, because every target returns read data one cycle late.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity bus_decode is
  port (
    clk        : in  std_logic;
    addr       : in  std_logic_vector(31 downto 0);
    re         : in  std_logic;
    we         : in  std_logic_vector(3 downto 0);
    dmem_we    : out std_logic_vector(3 downto 0);
    fb_we      : out std_logic_vector(3 downto 0);
    mmio_sel   : out std_logic;
    mmio_we    : out std_logic_vector(3 downto 0);
    dmem_rdata : in  std_logic_vector(31 downto 0);
    fb_rdata   : in  std_logic_vector(31 downto 0);
    mmio_rdata : in  std_logic_vector(31 downto 0);
    rdata      : out std_logic_vector(31 downto 0)
  );
end entity bus_decode;

architecture rtl of bus_decode is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.5): address decoder and read multiplexer.
  --   * Region = addr(31 downto 28) (memory-map appendix).
  --   * Pass the byte-lane write enables only to the selected target.
  --   * The read-data multiplexer must select the target that was accessed
  --     in the PREVIOUS cycle, because every target answers one cycle late.
  --   * Accesses to unmapped addresses read zero and write nothing.

end architecture rtl;
