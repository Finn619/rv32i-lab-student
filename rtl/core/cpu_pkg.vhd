-------------------------------------------------------------------------------
-- cpu_pkg.vhd
-- Shared types and interface encodings for the RV32I lab CPU.
--
-- Every encoding below is an *interface* between blocks. The values are
-- arbitrary labels; what each instruction needs is yours to derive in Lab 3.
--
-- VHDL subset: VHDL-2008 compiled, but restricted to constructs supported by
-- both Vivado and Quartus Prime Lite (see the manual's appendix).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cpu_pkg is

  subtype word_t   is std_logic_vector(31 downto 0);
  subtype regaddr_t is std_logic_vector(4 downto 0);

  constant RESET_VECTOR : word_t := x"00000000";

  -- ALU operation select (Lab 1). Deliberately not aligned with funct3.
  subtype alu_op_t is std_logic_vector(3 downto 0);
  constant ALU_ADD  : alu_op_t := "0000";  -- a + b
  constant ALU_SUB  : alu_op_t := "0001";  -- a - b
  constant ALU_AND  : alu_op_t := "0010";  -- a and b
  constant ALU_OR   : alu_op_t := "0011";  -- a or b
  constant ALU_XOR  : alu_op_t := "0100";  -- a xor b
  constant ALU_SLL  : alu_op_t := "0101";  -- a << b[4:0]
  constant ALU_SRL  : alu_op_t := "0110";  -- a >> b[4:0], zero fill
  constant ALU_SRA  : alu_op_t := "0111";  -- a >> b[4:0], sign fill
  constant ALU_SLT  : alu_op_t := "1000";  -- 1 if signed(a) < signed(b) else 0
  constant ALU_SLTU : alu_op_t := "1001";  -- 1 if unsigned(a) < unsigned(b) else 0

  -- Immediate format select (Lab 2)
  subtype imm_sel_t is std_logic_vector(2 downto 0);
  constant IMM_I : imm_sel_t := "000";
  constant IMM_S : imm_sel_t := "001";
  constant IMM_B : imm_sel_t := "010";
  constant IMM_U : imm_sel_t := "011";
  constant IMM_J : imm_sel_t := "100";

  -- ALU operand A source (Lab 3)
  subtype src_a_t is std_logic_vector(1 downto 0);
  constant SRC_A_RS1  : src_a_t := "00";
  constant SRC_A_PC   : src_a_t := "01";
  constant SRC_A_ZERO : src_a_t := "10";

  -- ALU operand B source (Lab 3)
  constant SRC_B_RS2 : std_logic := '0';
  constant SRC_B_IMM : std_logic := '1';

  -- ALU class: tells alu_control how to choose the ALU operation (Lab 3)
  subtype alu_class_t is std_logic_vector(1 downto 0);
  constant ALUC_ADD   : alu_class_t := "00";  -- always add
  constant ALUC_REG   : alu_class_t := "01";  -- register-register: use funct3/funct7
  constant ALUC_IMM   : alu_class_t := "10";  -- register-immediate: use funct3 (+ funct7 for shifts)

  -- Register write-back source (Lab 3)
  subtype res_src_t is std_logic_vector(1 downto 0);
  constant RES_ALU : res_src_t := "00";  -- ALU result
  constant RES_MEM : res_src_t := "01";  -- load data from the LSU
  constant RES_PC4 : res_src_t := "10";  -- address of the next sequential instruction

  -- Memory-map region selection (Lab 5/7): address bits 31..28
  constant REGION_IMEM : std_logic_vector(3 downto 0) := x"0";
  constant REGION_DMEM : std_logic_vector(3 downto 0) := x"1";
  constant REGION_FB   : std_logic_vector(3 downto 0) := x"2";
  constant REGION_MMIO : std_logic_vector(3 downto 0) := x"3";

  constant DMEM_BASE : word_t := x"10000000";
  constant FB_BASE   : word_t := x"20000000";
  constant MMIO_BASE : word_t := x"30000000";

  -- MMIO register offsets (byte offsets from MMIO_BASE, bits 7..0)
  constant MMIO_LEDS      : std_logic_vector(7 downto 0) := x"00";
  constant MMIO_SWITCHES  : std_logic_vector(7 downto 0) := x"04";
  constant MMIO_BUTTONS   : std_logic_vector(7 downto 0) := x"08";
  constant MMIO_HEX       : std_logic_vector(7 downto 0) := x"0C";
  constant MMIO_HEX_BLANK : std_logic_vector(7 downto 0) := x"10";
  constant MMIO_CYCLE_LO  : std_logic_vector(7 downto 0) := x"20";
  constant MMIO_CYCLE_HI  : std_logic_vector(7 downto 0) := x"24";
  constant MMIO_VGA_CTRL  : std_logic_vector(7 downto 0) := x"30";
  constant MMIO_VGA_STAT  : std_logic_vector(7 downto 0) := x"34";
  constant MMIO_SIM_PUTC  : std_logic_vector(7 downto 0) := x"F0";
  constant MMIO_SIM_SIG   : std_logic_vector(7 downto 0) := x"F4";
  constant MMIO_SIM_HALT  : std_logic_vector(7 downto 0) := x"FC";

  -- Framebuffer geometry (Lab 8)
  constant FB_WIDTH  : natural := 160;
  constant FB_HEIGHT : natural := 120;
  constant FB_WORDS  : natural := FB_WIDTH * FB_HEIGHT / 4;  -- 4800

end package cpu_pkg;
