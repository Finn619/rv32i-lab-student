-------------------------------------------------------------------------------
-- alu_control.vhd  (Lab 3)
-- Second-level decode: chooses the ALU operation from the ALU class supplied
-- by the main decoder and the instruction's funct3 / funct7[5] bits.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity alu_control is
  port (
    alu_class : in  std_logic_vector(1 downto 0);  -- ALUC_ADD/REG/IMM from decoder
    funct3    : in  std_logic_vector(2 downto 0);  -- instr[14:12]
    funct7_5  : in  std_logic;                     -- instr[30]
    alu_op    : out std_logic_vector(3 downto 0)   -- ALU_* to the ALU
  );
end entity alu_control;

architecture rtl of alu_control is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 3, Task 3.5): choose alu_op from alu_class, funct3 and funct7_5.
  --   * Derive this second-level table yourself from the spec's encoding
  --     tables.
  --   * Careful: for one I-type instruction, instr(30) is an immediate bit,
  --     not an operation selector. Which one, and why does it matter?
  --   * Purely combinational.

end architecture rtl;
