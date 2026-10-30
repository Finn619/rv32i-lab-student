/*
 * fixed.h - Q16.16 fixed-point arithmetic for a CPU without a multiplier
 * (Lab 8). A q16_t holds value * 65536.
 */
#ifndef FIXED_H
#define FIXED_H
#include <stdint.h>

typedef int32_t q16_t;

#define Q16_ONE        65536
#define Q16(i)         ((q16_t)((i) * Q16_ONE))
#define Q16_INT(q)     ((q) >> 16)          /* floor */

/* 32 x 32 -> 64-bit unsigned product by shift-and-add (RV32I has no MUL). */
uint64_t umul32x32(uint32_t a, uint32_t b);

/* Q16.16 product, truncated towards zero. */
q16_t q16_mul(q16_t a, q16_t b);

/* Small unsigned product (b < 256), shift-and-add. */
uint32_t mul_small(uint32_t a, uint32_t b);

extern const q16_t sin_table[256];      /* angle unit: 1/256 of a turn */
static inline q16_t q16_sin(uint32_t a) { return sin_table[a & 255]; }
static inline q16_t q16_cos(uint32_t a) { return sin_table[(a + 64) & 255]; }

#endif
