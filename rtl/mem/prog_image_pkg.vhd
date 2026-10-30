-------------------------------------------------------------------------------
-- prog_image_pkg.vhd  (declaration only)
-- Initial memory contents. Two package bodies exist with this declaration:
--   * a generated body (tools/gen_mem.py -> build/prog_image_body.vhd) that
--     holds the program as constants; this is the only one synthesis sees.
--   * sim/prog_image_body_sim.vhd, which reads a hex file named by a generic
--     so simulations can swap programs without regenerating VHDL.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package prog_image_pkg is
  type image_t is array (natural range <>) of std_logic_vector(31 downto 0);

  constant REGION_IMEM_ID : natural := 0;
  constant REGION_DMEM_ID : natural := 1;

  -- Initial contents of one memory region as 'words' 32-bit words.
  -- init_file is only used by the simulation body; synthesis ignores it.
  impure function region_image(region : natural; words : positive; init_file : string)
    return image_t;
end package prog_image_pkg;
