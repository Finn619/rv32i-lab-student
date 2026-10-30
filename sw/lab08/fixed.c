/* fixed.c - shift-and-add multiplication (Lab 8, path b) - YOURS.
 * See fixed.h for what each function must return. RV32I has no multiply
 * instruction: build the products from shifts and adds. Do not use '*' on
 * variables (GCC would call a libgcc routine instead - which is itself a
 * shift-and-add loop; measuring your own is part of the lab). */
#include "fixed.h"

uint64_t umul32x32(uint32_t a, uint32_t b)
{
    /* TODO (Lab 8, Task 8.7) */
    (void)a; (void)b;
    return 0;
}

q16_t q16_mul(q16_t a, q16_t b)
{
    /* TODO (Lab 8, Task 8.7): sign-magnitude, truncate the magnitude towards
     * zero (the golden images were made with that rounding rule). */
    (void)a; (void)b;
    return 0;
}

uint32_t mul_small(uint32_t a, uint32_t b)
{
    /* TODO (Lab 8, Task 8.7) */
    (void)a; (void)b;
    return 0;
}
