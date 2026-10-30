-------------------------------------------------------------------------------
-- clkgen_max10.vhd  (Quartus only - DE10-Lite)
-- 50 MHz -> 25 MHz using the MAX 10 PLL (altpll megafunction).
-- Status: NOT SYNTHESISED IN AUTHORING ENVIRONMENT (no Quartus available).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.all;

architecture max10 of clkgen is

  component altpll
    generic (
      bandwidth_type          : string;
      clk0_divide_by          : natural;
      clk0_duty_cycle         : natural;
      clk0_multiply_by        : natural;
      clk0_phase_shift        : string;
      compensate_clock        : string;
      inclk0_input_frequency  : natural;   -- picoseconds
      intended_device_family  : string;
      lpm_type                : string;
      operation_mode          : string;
      pll_type                : string;
      port_areset             : string;
      port_inclk0             : string;
      port_locked             : string;
      port_clk0               : string;
      self_reset_on_loss_lock : string;
      width_clock             : natural
    );
    port (
      areset : in  std_logic;
      inclk  : in  std_logic_vector(1 downto 0);
      clk    : out std_logic_vector(4 downto 0);
      locked : out std_logic
    );
  end component;

  signal clks   : std_logic_vector(4 downto 0);
  signal inclks : std_logic_vector(1 downto 0);
begin

  assert CLK_IN_HZ = 50_000_000
    report "clkgen(max10): PLL settings assume a 50 MHz input" severity failure;

  inclks <= '0' & clk_in;

  u_pll : altpll
    generic map (
      bandwidth_type          => "AUTO",
      clk0_divide_by          => 2,
      clk0_duty_cycle         => 50,
      clk0_multiply_by        => 1,
      clk0_phase_shift        => "0",
      compensate_clock        => "CLK0",
      inclk0_input_frequency  => 20000,
      intended_device_family  => "MAX 10",
      lpm_type                => "altpll",
      operation_mode          => "NORMAL",
      pll_type                => "AUTO",
      port_areset             => "PORT_USED",
      port_inclk0             => "PORT_USED",
      port_locked             => "PORT_USED",
      port_clk0               => "PORT_USED",
      self_reset_on_loss_lock => "OFF",
      width_clock             => 5
    )
    port map (
      areset => areset,
      inclk  => inclks,
      clk    => clks,
      locked => locked
    );

  clk_out <= clks(0);

end architecture max10;
