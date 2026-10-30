-------------------------------------------------------------------------------
-- decoder.vhd  (Lab 3)
-- Main control unit: decodes the opcode (and the funct fields needed for
-- legality) into datapath control signals.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity decoder is
  port (
    instr     : in  std_logic_vector(31 downto 0);  -- full instruction word
    reg_write : out std_logic;                      -- '1': write the result to rd
    src_a     : out std_logic_vector(1 downto 0);   -- ALU operand A: SRC_A_RS1/PC/ZERO
    src_b     : out std_logic;                      -- ALU operand B: SRC_B_RS2/IMM
    alu_class : out std_logic_vector(1 downto 0);   -- ALUC_ADD/REG/IMM for alu_control
    imm_sel   : out std_logic_vector(2 downto 0);   -- IMM_I/S/B/U/J for immgen
    res_src   : out std_logic_vector(1 downto 0);   -- write-back source RES_ALU/MEM/PC4
    mem_read  : out std_logic;                      -- '1': instruction is a load
    mem_write : out std_logic;                      -- '1': instruction is a store
    branch    : out std_logic;                      -- '1': conditional branch
    jump      : out std_logic;                      -- '1': unconditional jump
    illegal   : out std_logic                       -- '1': not an implemented RV32I
                                                    --      instruction (also ECALL/EBREAK)
  );
end entity decoder;

architecture rtl of decoder is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 3, Tasks 3.2-3.4): decode the instruction into control signals.
  --   * Start from the main control table you derived in the pre-lab.
  --   * Begin the process with safe defaults: an instruction that changes
  --     no architectural state.
  --   * Decide on the opcode first, then check funct3/funct7 for legality.
  --   * 'illegal' must be '1' for any encoding that is not an RV32I
  --     instruction this core implements (ECALL and EBREAK included), and
  --     an illegal instruction must not request any state change.
  --   * Purely combinational.

end architecture rtl;
