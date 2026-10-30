/*
 * mmio.h - memory map of the RV32I lab SoC (Lab 5).
 */
#ifndef MMIO_H
#define MMIO_H

#include <stdint.h>

#define REG32(addr) (*(volatile uint32_t *)(addr))

#define DMEM_BASE       0x10000000u
#define FB_BASE         0x20000000u
#define MMIO_BASE       0x30000000u

/* Board I/O */
#define LEDS            REG32(MMIO_BASE + 0x00)  /* RW  [15:0] (DE10-Lite shows 9:0) */
#define SWITCHES        REG32(MMIO_BASE + 0x04)  /* RO  [15:0] (DE10-Lite has 9:0)   */
#define BUTTONS         REG32(MMIO_BASE + 0x08)  /* RO  [3:0], 1 = pressed           */
#define HEX             REG32(MMIO_BASE + 0x0C)  /* RW  8 hex digits, digit 0 = [3:0] */
#define HEX_BLANK       REG32(MMIO_BASE + 0x10)  /* RW  [7:0], 1 = digit off         */
#define CYCLE_LO        REG32(MMIO_BASE + 0x20)  /* RO  cycle counter [31:0]         */
#define CYCLE_HI        REG32(MMIO_BASE + 0x24)  /* RO  cycle counter [63:32]        */
#define VGA_CTRL        REG32(MMIO_BASE + 0x30)  /* RW  bit 0 = enable output        */
#define VGA_STATUS      REG32(MMIO_BASE + 0x34)  /* RO  bit 0 = in vblank, [31:16] frames */

/* Simulation only (writes are ignored in hardware) */
#define SIM_PUTC        REG32(MMIO_BASE + 0xF0)
#define SIM_SIGNATURE   REG32(MMIO_BASE + 0xF4)
#define SIM_HALT        REG32(MMIO_BASE + 0xFC)

/* Framebuffer: 160 x 120 pixels, one RGB332 byte each, row-major. */
#define FB_WIDTH        160
#define FB_HEIGHT       120
#define FB              ((volatile uint8_t *)FB_BASE)
#define RGB332(r, g, b) ((uint8_t)(((r) & 7) << 5 | ((g) & 7) << 2 | ((b) & 3)))

/* Read the 64-bit cycle counter consistently (hi-lo-hi). */
static inline uint64_t read_cycles(void)
{
    uint32_t hi, lo, hi2;
    do {
        hi  = CYCLE_HI;
        lo  = CYCLE_LO;
        hi2 = CYCLE_HI;
    } while (hi != hi2);
    return ((uint64_t)hi << 32) | lo;
}

#endif
