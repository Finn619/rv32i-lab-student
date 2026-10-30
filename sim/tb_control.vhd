-------------------------------------------------------------------------------
-- tb_control.vhd  (SIMULATION ONLY)
-- Lab 3 test wrapper: the main decoder and ALU control, wired as in the core,
-- so one test can check the complete control path for an instruction.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_control is
  port (
    instr     : in  std_logic_vector(31 downto 0);
    reg_write : out std_logic;
    src_a     : out std_logic_vector(1 downto 0);
    src_b     : out std_logic;
    alu_class : out std_logic_vector(1 downto 0);
    imm_sel   : out std_logic_vector(2 downto 0);
    res_src   : out std_logic_vector(1 downto 0);
    mem_read  : out std_logic;
    mem_write : out std_logic;
    branch    : out std_logic;
    jump      : out std_logic;
    illegal   : out std_logic;
    alu_op    : out std_logic_vector(3 downto 0)
  );
end entity tb_control;

architecture sim of tb_control is
  signal alu_class_i : std_logic_vector(1 downto 0);
begin
  u_dec : entity work.decoder
    port map (instr => instr, reg_write => reg_write, src_a => src_a, src_b => src_b,
              alu_class => alu_class_i, imm_sel => imm_sel, res_src => res_src,
              mem_read => mem_read, mem_write => mem_write, branch => branch,
              jump => jump, illegal => illegal);
  u_aluctl : entity work.alu_control
    port map (alu_class => alu_class_i, funct3 => instr(14 downto 12),
              funct7_5 => instr(30), alu_op => alu_op);
  alu_class <= alu_class_i;
end architecture sim;
