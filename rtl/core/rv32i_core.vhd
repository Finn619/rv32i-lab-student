-------------------------------------------------------------------------------
-- rv32i_core.vhd  (Lab 4)
-- RV32I core: fetch-ahead single-cycle datapath with a one-cycle load stall.
--
-- Memory timing contract (both buses are synchronous-read, like FPGA BRAM):
--   * imem_rdata during cycle n+1 is the word at the imem_addr presented
--     during cycle n. The core presents pc_next, so imem_rdata is the
--     instruction at pc.
--   * dmem_rdata during cycle n+1 is the word at the dmem_addr presented
--     during cycle n (when dmem_re = '1').
--   * dmem_we is a byte-lane write enable, written on the rising edge.
--
-- RVFI-style trace port: combinational outputs. In the cycle an instruction
-- retires, rvfi_valid is '1' and the other rvfi_* outputs describe it (the
-- testbench samples them mid-cycle, on the falling edge, when they have
-- settled). 'trap' is registered: it rises at the clock edge that ends the
-- cycle in which the trapping instruction is reported with rvfi_trap = '1'.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity rv32i_core is
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;                       -- synchronous, active high

    -- Instruction bus
    imem_addr  : out std_logic_vector(31 downto 0);   -- byte address
    imem_rdata : in  std_logic_vector(31 downto 0);

    -- Data bus
    dmem_addr  : out std_logic_vector(31 downto 0);   -- byte address (lanes via dmem_we/byte enables)
    dmem_re    : out std_logic;                       -- read request
    dmem_we    : out std_logic_vector(3 downto 0);    -- byte-lane write enables
    dmem_wdata : out std_logic_vector(31 downto 0);
    dmem_rdata : in  std_logic_vector(31 downto 0);

    -- Status
    trap       : out std_logic;                       -- '1' once the core has halted on a trap

    -- RVFI-style trace port
    rvfi_valid     : out std_logic;
    rvfi_order     : out std_logic_vector(63 downto 0);
    rvfi_insn      : out std_logic_vector(31 downto 0);
    rvfi_trap      : out std_logic;
    rvfi_pc_rdata  : out std_logic_vector(31 downto 0);
    rvfi_pc_wdata  : out std_logic_vector(31 downto 0);
    rvfi_rs1_addr  : out std_logic_vector(4 downto 0);
    rvfi_rs2_addr  : out std_logic_vector(4 downto 0);
    rvfi_rs1_rdata : out std_logic_vector(31 downto 0);
    rvfi_rs2_rdata : out std_logic_vector(31 downto 0);
    rvfi_rd_addr   : out std_logic_vector(4 downto 0);
    rvfi_rd_wdata  : out std_logic_vector(31 downto 0);
    rvfi_mem_addr  : out std_logic_vector(31 downto 0);  -- word-aligned
    rvfi_mem_rmask : out std_logic_vector(3 downto 0);
    rvfi_mem_wmask : out std_logic_vector(3 downto 0);
    rvfi_mem_rdata : out std_logic_vector(31 downto 0);  -- raw bus lanes
    rvfi_mem_wdata : out std_logic_vector(31 downto 0)   -- raw bus lanes
  );
end entity rv32i_core;

architecture rtl of rv32i_core is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 4, Tasks 4.4-4.7): integrate the core.
  --   Instantiate decoder, alu_control, immgen, regfile, alu, branch_unit
  --   and lsu, and add:
  --   * the PC register and next-PC logic. imem_addr must be the address of
  --     the NEXT instruction (pc_next), so that imem_rdata is the instruction
  --     at pc. During reset pc_next must be RESET_VECTOR.
  --   * the operand multiplexers and the write-back multiplexer.
  --   * the load sequencer: a load spends one extra cycle (the data memory
  --     has a synchronous read). Draw your state diagram first and check it
  --     against the load timing diagram in the lab sheet.
  --   * trap handling: illegal instructions, misaligned loads/stores and
  --     taken jumps/branches to a non-4-byte-aligned target stop the core
  --     (trap = '1') without changing any state.
  --   * the RVFI outputs. Each retired instruction asserts rvfi_valid for
  --     exactly one cycle; see the RVFI table in the lab sheet for what each
  --     field must contain.
  --   * Design rules: one driver per signal; all state changes on the
  --     rising edge; do not read an output port inside the architecture.

end architecture rtl;
