-------------------------------------------------------------------------------
-- soc.vhd  (Lab 5/7/8)
-- Board-independent system: core, instruction and data memories, framebuffer
-- and VGA scan-out, MMIO peripherals. Board wrappers add clocking, reset
-- synchronisation, pin polarity and the seven-segment drivers.
--
-- Single clock domain: clk is the 25 MHz CPU and VGA pixel clock.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity soc is
  generic (
    IMEM_WORDS : positive := 8192;   -- 32 KB
    DMEM_WORDS : positive := 8192;   -- 32 KB
    IMEM_INIT  : string   := "";     -- simulation only: hex image files
    DMEM_INIT  : string   := ""
  );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;                      -- synchronous, active high
    -- board I/O (board-independent form)
    switches   : in  std_logic_vector(15 downto 0);  -- raw (synchronised inside)
    buttons    : in  std_logic_vector(3 downto 0);   -- raw, active high
    leds       : out std_logic_vector(15 downto 0);
    hex_value  : out std_logic_vector(31 downto 0);  -- 8 hex digits, digit 0 = bits 3..0
    hex_blank  : out std_logic_vector(7 downto 0);   -- '1' blanks a digit
    vga_r      : out std_logic_vector(3 downto 0);
    vga_g      : out std_logic_vector(3 downto 0);
    vga_b      : out std_logic_vector(3 downto 0);
    vga_hs     : out std_logic;
    vga_vs     : out std_logic;
    -- status and trace (left open on the boards; used by testbenches)
    trap           : out std_logic;
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
    rvfi_mem_addr  : out std_logic_vector(31 downto 0);
    rvfi_mem_rmask : out std_logic_vector(3 downto 0);
    rvfi_mem_wmask : out std_logic_vector(3 downto 0);
    rvfi_mem_rdata : out std_logic_vector(31 downto 0);
    rvfi_mem_wdata : out std_logic_vector(31 downto 0)
  );
end entity soc;

architecture rtl of soc is
  signal imem_addr, imem_rdata : word_t;
  signal d_addr, d_wdata, d_rdata : word_t;
  signal d_re : std_logic;
  signal d_we : std_logic_vector(3 downto 0);

  signal dmem_we, fb_we, mmio_we : std_logic_vector(3 downto 0);
  signal dmem_rdata, fb_rdata, mmio_rdata : word_t;
  signal mmio_sel : std_logic;

  signal fb_vga_addr : std_logic_vector(12 downto 0);
  signal fb_vga_data : word_t;

  signal sw_sync  : std_logic_vector(15 downto 0);
  signal btn_sync : std_logic_vector(3 downto 0);
  signal cycles   : std_logic_vector(63 downto 0);
  signal vga_en, vga_vblank : std_logic;
  signal vga_frames : std_logic_vector(15 downto 0);
begin

  u_core : entity work.rv32i_core
    port map (
      clk => clk, rst => rst,
      imem_addr => imem_addr, imem_rdata => imem_rdata,
      dmem_addr => d_addr, dmem_re => d_re, dmem_we => d_we,
      dmem_wdata => d_wdata, dmem_rdata => d_rdata,
      trap => trap,
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

  u_bus : entity work.bus_decode
    port map (clk => clk, addr => d_addr, re => d_re, we => d_we,
              dmem_we => dmem_we, fb_we => fb_we, mmio_sel => mmio_sel,
              mmio_we => mmio_we, dmem_rdata => dmem_rdata, fb_rdata => fb_rdata,
              mmio_rdata => mmio_rdata, rdata => d_rdata);

  u_dmem : entity work.dmem
    generic map (WORDS => DMEM_WORDS, INIT_FILE => DMEM_INIT)
    port map (clk => clk, addr => d_addr, we => dmem_we, wdata => d_wdata,
              rdata => dmem_rdata);

  u_fb : entity work.framebuffer
    port map (clk => clk, cpu_addr => d_addr(14 downto 2), cpu_we => fb_we,
              cpu_wdata => d_wdata, cpu_rdata => fb_rdata,
              vga_addr => fb_vga_addr, vga_rdata => fb_vga_data);

  u_vga : entity work.vga_ctrl
    port map (clk => clk, rst => rst, enable => vga_en,
              fb_addr => fb_vga_addr, fb_rdata => fb_vga_data,
              vga_r => vga_r, vga_g => vga_g, vga_b => vga_b,
              vga_hs => vga_hs, vga_vs => vga_vs,
              in_vblank => vga_vblank, frame_count => vga_frames);

  u_sw_sync : entity work.sync_ff
    generic map (WIDTH => 16) port map (clk => clk, din => switches, dout => sw_sync);
  u_btn_sync : entity work.sync_ff
    generic map (WIDTH => 4) port map (clk => clk, din => buttons, dout => btn_sync);

  u_cycles : entity work.cycle_counter
    port map (clk => clk, rst => rst, count => cycles);

  u_mmio : entity work.mmio
    port map (clk => clk, rst => rst, sel => mmio_sel, addr => d_addr(7 downto 0),
              we => mmio_we, wdata => d_wdata, rdata => mmio_rdata,
              switches => sw_sync, buttons => btn_sync, cycles => cycles,
              vga_vblank => vga_vblank, vga_frames => vga_frames,
              leds => leds, hex_value => hex_value, hex_blank => hex_blank,
              vga_enable => vga_en);

end architecture rtl;
