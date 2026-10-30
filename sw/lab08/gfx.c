/* gfx.c - software graphics primitives (Lab 8, path b) - YOURS.
 * gfx.h documents each function. The lab sheet gives the exact algorithms
 * (Bresenham with err = dx + dy; blend = (dst*(8-alpha) + src*alpha) >> 3
 * per channel); the golden images depend on following them exactly. */
#include "gfx.h"
#include "fixed.h"

void fb_clear(uint8_t colour)
{
    /* TODO (Lab 8, Task 8.5): use word stores - four pixels at a time. */
    (void)colour;
}

void put_pixel(int x, int y, uint8_t colour)
{
    /* TODO (Lab 8, Task 8.5): clip, then one byte store at fb_row(y) + x. */
    (void)x; (void)y; (void)colour;
}

void fill_rect(int x, int y, int w, int h, uint8_t colour)
{
    /* TODO (Lab 8, Task 8.6): clip to the screen; per row, byte stores up to a
     * word boundary, word stores in the middle, byte stores at the end. */
    (void)x; (void)y; (void)w; (void)h; (void)colour;
}

void draw_line(int x0, int y0, int x1, int y1, uint8_t colour)
{
    /* TODO (Lab 8, Task 8.6): Bresenham, all octants, integer only. */
    (void)x0; (void)y0; (void)x1; (void)y1; (void)colour;
}

uint8_t blend332(uint8_t dst, uint8_t src, uint32_t alpha)
{
    /* TODO (Lab 8, Task 8.8) */
    (void)src; (void)alpha;
    return dst;
}

void blend_rect(int x, int y, int w, int h, uint8_t colour, uint32_t alpha)
{
    /* TODO (Lab 8, Task 8.8): read-modify-write every pixel (clipped). */
    (void)x; (void)y; (void)w; (void)h; (void)colour; (void)alpha;
}

void wait_frame(void)
{
    /* TODO (Lab 8, Task 8.9): wait until the frame counter in VGA_STATUS
     * changes. */
}
