-------------------------------------------------------------------------------
-- regfile.vhd  (Lab 2)
-- 32 x 32-bit register file: two asynchronous read ports, one synchronous
-- write port. x0 always reads as zero.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port (
    clk    : in  std_logic;
    we     : in  std_logic;                      -- write enable, sampled on rising edge
    waddr  : in  std_logic_vector(4 downto 0);   -- destination register (rd)
    wdata  : in  std_logic_vector(31 downto 0);
    raddr1 : in  std_logic_vector(4 downto 0);   -- rs1
    raddr2 : in  std_logic_vector(4 downto 0);   -- rs2
    rdata1 : out std_logic_vector(31 downto 0);  -- combinational read of rs1
    rdata2 : out std_logic_vector(31 downto 0)   -- combinational read of rs2
  );
end entity regfile;

architecture rtl of regfile is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 2, Task 2.2): implement the register file.
  --   * 32 registers of 32 bits; x0 always reads as zero.
  --   * One write port: the write happens on the rising edge when we = '1'.
  --   * Two read ports that are combinational (asynchronous read). Your
  --     Lab 2 theory answers explain what this choice costs on each FPGA.
  --   * Decide where to enforce "x0 is zero" - on the write side, on the
  --     read side, or both - and justify it in your report.
  --   * Use an array signal so synthesis can map the storage to memory
  --     where the device allows it.

end architecture rtl;
