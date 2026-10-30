/*
 * link.ld - linker script for the RV32I lab SoC (Lab 5).
 *
 * Harvard memory map:
 *   IMEM 0x00000000  32 KB  instruction fetch only -> .text
 *   DMEM 0x10000000  32 KB  data                   -> .rodata .data .bss, stack
 *
 * The core cannot load from IMEM, so read-only data lives in DMEM too.
 * Both memories are initialised when the FPGA is configured (or when the
 * simulation starts), so .data is placed directly at its run address
 * (VMA = LMA) and crt0 does not copy it. Consequence: pressing reset does
 * NOT restore initialised variables - only reconfiguring the FPGA does.
 */
OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 32K
  DMEM (rw)  : ORIGIN = 0x10000000, LENGTH = 32K
}

SECTIONS
{
  .text : {
    KEEP(*(.text.init))          /* crt0 must be first: the reset vector is 0 */
    *(.text .text.*)
  } > IMEM

  .rodata : {
    *(.rodata .rodata.*)
    *(.srodata .srodata.*)
  } > DMEM

  .data : ALIGN(4) {
    *(.data .data.*)
    __global_pointer$ = . + 0x800;
    *(.sdata .sdata.*)
  } > DMEM

  .bss (NOLOAD) : ALIGN(4) {
    __bss_start = .;
    *(.sbss .sbss.*)
    *(.bss .bss.*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > DMEM

  __heap_start = __bss_end;
  __stack_top  = ORIGIN(DMEM) + LENGTH(DMEM);   /* stack grows down from here */

  /DISCARD/ : { *(.comment) *(.riscv.attributes) *(.note*) *(.eh_frame*) }
}
