-------------------------------------------------------------------------------
-- alu.vhd  (Lab 1)
-- 32-bit combinational ALU for RV32I.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity alu is
  port (
    a  : in  std_logic_vector(31 downto 0);  -- operand A
    b  : in  std_logic_vector(31 downto 0);  -- operand B (shift amount in b[4:0])
    op : in  std_logic_vector(3 downto 0);   -- operation, one of ALU_* in cpu_pkg
    y  : out std_logic_vector(31 downto 0)   -- result
  );
end entity alu;

architecture rtl of alu is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 1, Task 1.3): implement every operation listed under "ALU
  -- operation select" in cpu_pkg.
  --   * Use numeric_std only: convert with unsigned()/signed().
  --   * Shifts use only b(4 downto 0). Your spec lookup answers say why.
  --   * SLT/SLTU produce 0 or 1 in a 32-bit result.
  --   * Decide (and document) what y is for an encoding that is not listed:
  --     y must never be left undriven.
  --   * Design rule: this block is purely combinational - no clock, and
  --     every output assigned on every path through the process.

end architecture rtl;
