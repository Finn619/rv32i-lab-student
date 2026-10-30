-------------------------------------------------------------------------------
-- prog_image_body_sim.vhd  (SIMULATION ONLY - never add to a synthesis project)
-- Reads a memory image from a text file: one 32-bit word per line, written as
-- 8 hexadecimal digits. Word i is the little-endian word at byte offset 4*i.
-- Lines starting with '#' are ignored. An empty file name gives all zeros.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package body prog_image_pkg is

  impure function region_image(region : natural; words : positive; init_file : string)
    return image_t is
    file     f    : text;
    variable r    : image_t(0 to words - 1) := (others => (others => '0'));
    variable l    : line;
    variable w    : std_logic_vector(31 downto 0);
    variable i    : natural := 0;
    variable ok   : boolean;
    variable stat : file_open_status;
  begin
    if init_file'length = 0 then
      return r;
    end if;
    file_open(stat, f, init_file, read_mode);
    assert stat = open_ok
      report "prog_image_pkg: cannot open memory image '" & init_file & "'"
      severity failure;
    while not endfile(f) loop
      readline(f, l);
      if l'length > 0 and l(l'left) /= '#' then
        hread(l, w, ok);
        assert ok report "prog_image_pkg: bad hex word in " & init_file severity failure;
        assert i < words
          report "prog_image_pkg: image " & init_file & " does not fit in memory"
          severity failure;
        r(i) := w;
        i := i + 1;
      end if;
    end loop;
    file_close(f);
    return r;
  end function;

end package body prog_image_pkg;
