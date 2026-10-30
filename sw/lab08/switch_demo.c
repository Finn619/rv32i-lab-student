/*
 * switch_demo.c - switch-driven graphics (Lab 8, path a) - YOURS.
 *   SW[7:0]  colour (RGB332)
 *   SW[9:8]  shape: 0 filled square, 1 outline square, 2 cross, 3 diagonal line
 *   button 0 each press grows the shape by 4 pixels (4 .. 56, then wraps to 4);
 *            the size starts at 20
 * The shape is centred on (80, 60) with half-size 'size':
 *   filled square: every pixel with |x-80| <= size and |y-60| <= size
 *   outline:       the four edges of that square
 *   cross:         the horizontal and vertical lines through (80, 60), length 2*size+1
 *   diagonal:      from (80-size, 60+size) to (80+size, 60-size)
 * The background is black (0). Redraw only when the switches or size change.
 * HEX shows (size << 8) | colour.
 * With -DSIM_ONE_SHOT (Makefile.switch_demo_sim) draw once and return 0.
 *
 * Path (a) may use the provided drawing functions in gfx.h only if you also
 * write them; otherwise write the drawing loops here.
 */
#include "mmio.h"

int main(void)
{
    /* TODO (Lab 8, path a) */
    VGA_CTRL = 1;
#ifndef SIM_ONE_SHOT
    for (;;) {
    }
#endif
    return 0;
}
