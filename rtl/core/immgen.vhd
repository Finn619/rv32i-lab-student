-------------------------------------------------------------------------------
-- immgen.vhd  (Lab 2)
-- Extracts and sign-extends the immediate for each RV32I instruction format.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity immgen is
  port (
    instr   : in  std_logic_vector(31 downto 0);  -- full instruction word
    imm_sel : in  std_logic_vector(2 downto 0);   -- IMM_I/S/B/U/J from cpu_pkg
    imm     : out std_logic_vector(31 downto 0)   -- sign-extended immediate
  );
end entity immgen;

architecture rtl of immgen is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 2, Task 2.4): build the immediate for each format.
  --   * Every format's bit positions are in the spec section "Immediate
  --     Encoding Variants". Copy nothing from memory - read the figure.
  --   * The sign bit is always instr(31).
  --   * Which formats have an implicit zero in bit 0? Which have twelve
  --     zero bits at the bottom?
  --   * Drive imm for every imm_sel value, including unused encodings.

end architecture rtl;
