/*
 * model_test.h - riscv-arch-test target definitions for the lab SoC (Lab 6).
 *
 * At the end of a test, RVMODEL_HALT streams every signature word to the
 * simulation-only SIM_SIGNATURE register (the testbench records them from
 * the RVFI trace), then writes SIM_HALT to end the simulation.
 */
#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H

#define RVMODEL_DATA_SECTION

#define RVMODEL_HALT                     ;\
    la    t0, begin_signature            ;\
    la    t1, end_signature              ;\
    li    t2, 0x300000F4  /* SIM_SIGNATURE */ ;\
1:  bgeu  t0, t1, 2f                     ;\
    lw    t3, 0(t0)                      ;\
    sw    t3, 0(t2)                      ;\
    addi  t0, t0, 4                      ;\
    j     1b                             ;\
2:  li    t2, 0x300000FC  /* SIM_HALT */ ;\
    sw    x0, 0(t2)                      ;\
3:  j     3b                             ;

#define RVMODEL_BOOT

#define RVMODEL_DATA_BEGIN               \
    .align 4                            ;\
    .global begin_signature             ;\
    begin_signature:

#define RVMODEL_DATA_END                 \
    .global end_signature               ;\
    end_signature:

#define RVMODEL_IO_INIT
#define RVMODEL_IO_WRITE_STR(_R, _STR)
#define RVMODEL_IO_CHECK()
#define RVMODEL_IO_ASSERT_GPR_EQ(_S, _R, _I)
#define RVMODEL_IO_ASSERT_SFPR_EQ(_F, _R, _I)
#define RVMODEL_IO_ASSERT_DFPR_EQ(_D, _R, _I)
#define RVMODEL_SET_MSW_INT
#define RVMODEL_CLEAR_MSW_INT
#define RVMODEL_CLEAR_MTIMER_INT
#define RVMODEL_CLEAR_MEXT_INT

#endif
