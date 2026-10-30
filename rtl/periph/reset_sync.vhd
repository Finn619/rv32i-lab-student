-------------------------------------------------------------------------------
-- reset_sync.vhd  (Lab 7)
-- Reset synchroniser: asserts asynchronously, de-asserts synchronously to clk
-- after STAGES rising edges with arst_in inactive.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reset_sync is
  generic (STAGES : positive := 3);
  port (
    clk     : in  std_logic;
    arst_in : in  std_logic;   -- asynchronous reset request, active high
    rst_out : out std_logic    -- synchronous-release reset, active high
  );
end entity reset_sync;

architecture rtl of reset_sync is
  -- Declare your internal signals, types and constants here.
begin
  -- TODO (Lab 7, Task 7.2): reset synchroniser.
  --   * rst_out must assert as soon as arst_in asserts (asynchronously).
  --   * rst_out must de-assert synchronously, STAGES rising edges after
  --     arst_in de-asserts. Match the timing diagram in the lab sheet.

end architecture rtl;
