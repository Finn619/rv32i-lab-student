/* link.ld - riscv-arch-test layout for the lab SoC (Harvard: code in IMEM,
 * test data and signature in DMEM). Sized for the simulation memories. */
OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

MEMORY
{
  IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 2M  /* jal-01 tests +-1 MB jumps */
  DMEM (rw) : ORIGIN = 0x10000000, LENGTH = 64K
}

SECTIONS
{
  .text.init : { *(.text.init) } > IMEM
  .text      : { *(.text) }      > IMEM
  .data      : { *(.data) *(.data.string) *(.tohost) } > DMEM
  .bss       : { *(.bss) }       > DMEM
  _end = .;
}
