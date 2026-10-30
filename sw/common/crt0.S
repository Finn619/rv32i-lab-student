/*
 * crt0.S - C runtime start-up for the RV32I lab SoC (Lab 5).
 *
 * Runs from the reset vector (0x00000000):
 *   1. set up gp (for gp-relative small-data accesses) and sp
 *   2. zero .bss, as C requires for uninitialised statics
 *   3. call main()
 *   4. report main's return value to SIM_HALT, then spin forever
 */
    .section .text.init, "ax", @progbits
    .globl  _start
_start:
    .option push
    .option norelax              /* gp must not be used to compute itself */
    la      gp, __global_pointer$
    .option pop
    la      sp, __stack_top

    /* TODO (Lab 5, Task 5.3): zero .bss here, one word at a time, from
     * __bss_start up to (not including) __bss_end. The linker script
     * defines both symbols and aligns them to 4 bytes. Use only t0-t6:
     * nothing else has been saved. Until you do this, the selftest
     * program's ".bss is zeroed" check may fail.
     * End your code just before the label 2 below (or jump to it). */
2:
    li      a0, 0                /* argc = 0, argv = NULL */
    li      a1, 0
    call    main

    /* Exit: ignored by hardware, ends the simulation. */
    li      t0, 0x300000FC       /* SIM_HALT */
    sw      a0, 0(t0)
3:  j       3b
