/*
 * gfx.h - software graphics primitives for the 160x120 RGB332 framebuffer
 * (Lab 8, path b). All drawing is clipped to the screen.
 */
#ifndef GFX_H
#define GFX_H
#include <stdint.h>
#include "mmio.h"

void fb_clear(uint8_t colour);
void put_pixel(int x, int y, uint8_t colour);
void fill_rect(int x, int y, int w, int h, uint8_t colour);
void draw_line(int x0, int y0, int x1, int y1, uint8_t colour);
uint8_t blend332(uint8_t dst, uint8_t src, uint32_t alpha);   /* alpha 0..8 */
void blend_rect(int x, int y, int w, int h, uint8_t colour, uint32_t alpha);
void wait_frame(void);

/* Row start address: y * 160 without a multiply = (y << 7) + (y << 5). */
static inline uint32_t fb_row(int y) { return ((uint32_t)y << 7) + ((uint32_t)y << 5); }

#endif
