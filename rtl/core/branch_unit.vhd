-------------------------------------------------------------------------------
-- branch_unit.vhd  (Lab 4)
-- Evaluates the condition of a conditional branch.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_unit is
  port (
    rs1    : in  std_logic_vector(31 downto 0);
    rs2    : in  std_logic_vector(31 downto 0);
    funct3 : in  std_logic_vector(2 downto 0);  -- instr[14:12] of the branch
    taken  : out std_logic                      -- '1' if the condition holds
  );
end entity branch_unit;

architecture rtl of branch_unit is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 4, Task 4.2): decide whether a conditional branch is taken.
  --   * One comparison per funct3 value; read the spec's "Conditional
  --     Branches" section for signed versus unsigned comparisons.
  --   * taken must be '0' for funct3 values that are not branches.
  --   * Purely combinational.

end architecture rtl;
