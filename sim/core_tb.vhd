-------------------------------------------------------------------------------
-- core_tb.vhd  (SIMULATION ONLY - provided)
-- cocotb top level for Labs 4-6: the core with its instruction and data
-- memories, without the SoC's peripherals.
--   * clk is driven by the cocotb test (25 MHz); a 5-cycle reset is applied
--   * data accesses reach DMEM only when address bits 31..28 = x"1";
--     all other data reads return 0 (one cycle later, like a memory)
--   * the simulation-only MMIO registers are decoded from the RVFI trace:
--       SIM_PUTC write      -> putc_toggle flips, putc_char
--       SIM_SIGNATURE write -> sig_toggle flips,  sig_word
--       SIM_HALT write      -> halted = '1', exit_code
-- Signal names match soc_tb, so the same Python harness drives both.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_tb is
  generic (
    IMEM_WORDS : positive := 65536;   -- 256 KB
    DMEM_WORDS : positive := 16384;   -- 64 KB
    IMEM_INIT  : string   := "";
    DMEM_INIT  : string   := ""
  );
end entity core_tb;

architecture sim of core_tb is
  signal clk : std_logic := '0';
  signal rst : std_logic := '1';

  signal imem_addr, imem_rdata : std_logic_vector(31 downto 0);
  signal d_addr, d_wdata, d_rdata, dmem_rdata : std_logic_vector(31 downto 0);
  signal d_re : std_logic;
  signal d_we, dmem_we : std_logic_vector(3 downto 0);
  signal d_is_dmem_q : std_logic := '0';
  signal trap : std_logic;

  signal rvfi_valid, rvfi_trap : std_logic;
  signal rvfi_order : std_logic_vector(63 downto 0);
  signal rvfi_insn, rvfi_pc_rdata, rvfi_pc_wdata : std_logic_vector(31 downto 0);
  signal rvfi_rs1_addr, rvfi_rs2_addr, rvfi_rd_addr : std_logic_vector(4 downto 0);
  signal rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_rd_wdata : std_logic_vector(31 downto 0);
  signal rvfi_mem_addr, rvfi_mem_rdata, rvfi_mem_wdata : std_logic_vector(31 downto 0);
  signal rvfi_mem_rmask, rvfi_mem_wmask : std_logic_vector(3 downto 0);

  signal putc_toggle : std_logic := '0';
  signal putc_char   : std_logic_vector(7 downto 0) := (others => '0');
  signal sig_toggle  : std_logic := '0';
  signal sig_word    : std_logic_vector(31 downto 0) := (others => '0');
  signal halted      : std_logic := '0';
  signal exit_code   : std_logic_vector(31 downto 0) := (others => '0');
  signal cycle       : natural := 0;
begin

  process
  begin
    rst <= '1';
    for i in 1 to 5 loop
      wait until rising_edge(clk);
    end loop;
    rst <= '0';
    wait;
  end process;

  u_core : entity work.rv32i_core
    port map (
      clk => clk, rst => rst,
      imem_addr => imem_addr, imem_rdata => imem_rdata,
      dmem_addr => d_addr, dmem_re => d_re, dmem_we => d_we,
      dmem_wdata => d_wdata, dmem_rdata => d_rdata, trap => trap,
      rvfi_valid => rvfi_valid, rvfi_order => rvfi_order, rvfi_insn => rvfi_insn,
      rvfi_trap => rvfi_trap, rvfi_pc_rdata => rvfi_pc_rdata,
      rvfi_pc_wdata => rvfi_pc_wdata, rvfi_rs1_addr => rvfi_rs1_addr,
      rvfi_rs2_addr => rvfi_rs2_addr, rvfi_rs1_rdata => rvfi_rs1_rdata,
      rvfi_rs2_rdata => rvfi_rs2_rdata, rvfi_rd_addr => rvfi_rd_addr,
      rvfi_rd_wdata => rvfi_rd_wdata, rvfi_mem_addr => rvfi_mem_addr,
      rvfi_mem_rmask => rvfi_mem_rmask, rvfi_mem_wmask => rvfi_mem_wmask,
      rvfi_mem_rdata => rvfi_mem_rdata, rvfi_mem_wdata => rvfi_mem_wdata);

  u_imem : entity work.imem
    generic map (WORDS => IMEM_WORDS, INIT_FILE => IMEM_INIT)
    port map (clk => clk, addr => imem_addr, rdata => imem_rdata);

  dmem_we <= d_we when d_addr(31 downto 28) = x"1" else "0000";

  u_dmem : entity work.dmem
    generic map (WORDS => DMEM_WORDS, INIT_FILE => DMEM_INIT)
    port map (clk => clk, addr => d_addr, we => dmem_we, wdata => d_wdata,
              rdata => dmem_rdata);

  process(clk)
  begin
    if rising_edge(clk) then
      if d_addr(31 downto 28) = x"1" then
        d_is_dmem_q <= '1';
      else
        d_is_dmem_q <= '0';
      end if;
    end if;
  end process;
  d_rdata <= dmem_rdata when d_is_dmem_q = '1' else (others => '0');

  process(clk)
  begin
    if rising_edge(clk) then
      cycle <= cycle + 1;
      if rvfi_valid = '1' and rvfi_mem_wmask /= "0000" then
        case rvfi_mem_addr is
          when x"300000F0" =>
            putc_toggle <= not putc_toggle;
            putc_char   <= rvfi_mem_wdata(7 downto 0);
          when x"300000F4" =>
            sig_toggle <= not sig_toggle;
            sig_word   <= rvfi_mem_wdata;
          when x"300000FC" =>
            halted    <= '1';
            exit_code <= rvfi_mem_wdata;
          when others => null;
        end case;
      end if;
    end if;
  end process;

end architecture sim;
