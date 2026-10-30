-------------------------------------------------------------------------------
-- soc_tb.vhd  (SIMULATION ONLY)
-- cocotb top level for whole-system tests (Labs 4-8).
--   * clk is driven by the cocotb test (25 MHz, period 40 ns), so the
--     simulation ends as soon as the Python tests finish; the testbench
--     applies a 5-cycle reset
--   * decodes the simulation-only MMIO registers from the RVFI trace into
--     simple strobes, so Python only wakes up on events:
--       SIM_PUTC write      -> putc_toggle flips, putc_char
--       SIM_SIGNATURE write -> sig_toggle flips,  sig_word
--     (toggles rather than strobes, so back-to-back events are never merged)
--       SIM_HALT write      -> halted = '1', exit_code
--   * optionally captures one VGA frame, timed only from the sync pulses, to a
--     text PPM file (generic CAPTURE_FILE): the first complete frame that
--     starts after the program has written SIM_HALT
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity soc_tb is
  generic (
    IMEM_WORDS    : positive := 65536;   -- 256 KB (a constant: cheap to simulate)
    DMEM_WORDS    : positive := 16384;   -- 64 KB (RAM signals cost ~400 bytes per bit in GHDL)
    IMEM_INIT     : string   := "";
    DMEM_INIT     : string   := "";
    CAPTURE_FILE  : string   := ""       -- empty: no capture
  );
end entity soc_tb;

architecture sim of soc_tb is
  signal clk : std_logic := '0';
  signal rst : std_logic := '1';

  -- Board-side I/O; switches and buttons are driven from Python.
  signal switches  : std_logic_vector(15 downto 0) := (others => '0');
  signal buttons   : std_logic_vector(3 downto 0) := (others => '0');
  signal leds      : std_logic_vector(15 downto 0);
  signal hex_value : std_logic_vector(31 downto 0);
  signal hex_blank : std_logic_vector(7 downto 0);
  signal vga_r, vga_g, vga_b : std_logic_vector(3 downto 0);
  signal vga_hs, vga_vs : std_logic;
  signal trap : std_logic;

  -- RVFI
  signal rvfi_valid, rvfi_trap : std_logic;
  signal rvfi_order : std_logic_vector(63 downto 0);
  signal rvfi_insn, rvfi_pc_rdata, rvfi_pc_wdata : std_logic_vector(31 downto 0);
  signal rvfi_rs1_addr, rvfi_rs2_addr, rvfi_rd_addr : std_logic_vector(4 downto 0);
  signal rvfi_rs1_rdata, rvfi_rs2_rdata, rvfi_rd_wdata : std_logic_vector(31 downto 0);
  signal rvfi_mem_addr, rvfi_mem_rdata, rvfi_mem_wdata : std_logic_vector(31 downto 0);
  signal rvfi_mem_rmask, rvfi_mem_wmask : std_logic_vector(3 downto 0);

  -- Simulation event strobes
  signal putc_toggle : std_logic := '0';
  signal putc_char   : std_logic_vector(7 downto 0) := (others => '0');
  signal sig_toggle  : std_logic := '0';
  signal sig_word    : std_logic_vector(31 downto 0) := (others => '0');
  signal halted      : std_logic := '0';
  signal exit_code   : std_logic_vector(31 downto 0) := (others => '0');
  signal capture_done : std_logic := '0';
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

  dut : entity work.soc
    generic map (IMEM_WORDS => IMEM_WORDS, DMEM_WORDS => DMEM_WORDS,
                 IMEM_INIT => IMEM_INIT, DMEM_INIT => DMEM_INIT)
    port map (
      clk => clk, rst => rst, switches => switches, buttons => buttons,
      leds => leds, hex_value => hex_value, hex_blank => hex_blank,
      vga_r => vga_r, vga_g => vga_g, vga_b => vga_b,
      vga_hs => vga_hs, vga_vs => vga_vs, trap => trap,
      rvfi_valid => rvfi_valid, rvfi_order => rvfi_order, rvfi_insn => rvfi_insn,
      rvfi_trap => rvfi_trap, rvfi_pc_rdata => rvfi_pc_rdata,
      rvfi_pc_wdata => rvfi_pc_wdata, rvfi_rs1_addr => rvfi_rs1_addr,
      rvfi_rs2_addr => rvfi_rs2_addr, rvfi_rs1_rdata => rvfi_rs1_rdata,
      rvfi_rs2_rdata => rvfi_rs2_rdata, rvfi_rd_addr => rvfi_rd_addr,
      rvfi_rd_wdata => rvfi_rd_wdata, rvfi_mem_addr => rvfi_mem_addr,
      rvfi_mem_rmask => rvfi_mem_rmask, rvfi_mem_wmask => rvfi_mem_wmask,
      rvfi_mem_rdata => rvfi_mem_rdata, rvfi_mem_wdata => rvfi_mem_wdata);

  -- Decode simulation-only MMIO writes from the trace.
  process(clk)
  begin
    if rising_edge(clk) then
      cycle       <= cycle + 1;
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

  -- Frame capture, using only the sync outputs to find the visible area.
  -- The pixels that follow an hsync pulse (after the 48-pixel back porch)
  -- belong to the *next* line. The vsync pulse ends at the start of a line,
  -- and 33 back-porch lines follow, so the hsync pulse in the 33rd of those
  -- lines (the 33rd pulse after vsync ends) precedes visible line 0.
  capture : if CAPTURE_FILE'length > 0 generate
    process
      file     f       : text;
      variable l       : line;
      variable r, g, b : natural;
    begin
      file_open(f, CAPTURE_FILE, write_mode);
      write(l, string'("P3"));
      writeline(f, l);
      write(l, string'("640 480"));
      writeline(f, l);
      write(l, string'("15"));
      writeline(f, l);
      -- wait for the program to finish drawing, then for the end of the next
      -- vsync pulse (rising edge: sync is active low)
      if halted /= '1' then
        wait until halted = '1';
      end if;
      wait until rising_edge(vga_vs);
      -- skip the first 32 back-porch lines
      for i in 1 to 32 loop
        wait until rising_edge(vga_hs);
      end loop;
      for y in 0 to 479 loop
        wait until rising_edge(vga_hs);
        for i in 1 to 48 loop
          wait until rising_edge(clk);
        end loop;
        for x in 0 to 639 loop
          wait until rising_edge(clk);
          r := to_integer(unsigned(vga_r));
          g := to_integer(unsigned(vga_g));
          b := to_integer(unsigned(vga_b));
          write(l, integer'image(r) & " " & integer'image(g) & " " & integer'image(b));
          writeline(f, l);
        end loop;
      end loop;
      file_close(f);
      capture_done <= '1';
      wait;
    end process;
  end generate;

end architecture sim;
