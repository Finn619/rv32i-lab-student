/*
 * gfx_test.c - deterministic scene used for the golden-image test (Lab 8).
 * Exercises every primitive, including clipping, unaligned rectangle edges,
 * all eight line octants and read-modify-write blending, then halts.
 */
#include "cube.h"
#include "gfx.h"

static const int8_t star[16][2] = {   /* end points around (80, 60) */
    {50, 0}, {46, 19}, {35, 35}, {19, 46}, {0, 50}, {-19, 46}, {-35, 35}, {-46, 19},
    {-50, 0}, {-46, -19}, {-35, -35}, {-19, -46}, {0, -50}, {19, -46}, {35, -35}, {46, -19},
};

int main(void)
{
    fb_clear(RGB332(0, 0, 1));
    fill_rect(10, 10, 50, 30, RGB332(7, 0, 0));
    fill_rect(3, 50, 37, 21, RGB332(0, 7, 0));        /* unaligned left and right edges */
    fill_rect(150, 110, 30, 30, RGB332(7, 7, 0));     /* clipped at the bottom-right    */
    fill_rect(-5, 100, 12, 30, RGB332(0, 7, 3));      /* clipped at the left and bottom */
    for (int i = 0; i < 16; i++)
        draw_line(80, 60, 80 + star[i][0], 60 + star[i][1], RGB332(7, 3 + (i & 3), i & 3));
    draw_line(0, 119, 159, 0, RGB332(7, 7, 3));      /* full-screen diagonal */
    draw_line(-20, 5, 200, 5, RGB332(3, 3, 3));      /* clipped horizontal  */
    blend_rect(30, 20, 60, 40, RGB332(7, 7, 3), 3);
    draw_cube(20, 35, 125, 40, 20, RGB332(7, 7, 3));
    put_pixel(0, 0, RGB332(7, 0, 3));
    put_pixel(159, 0, RGB332(0, 7, 3));
    put_pixel(0, 119, RGB332(7, 7, 0));
    put_pixel(159, 119, RGB332(7, 7, 3));
    VGA_CTRL = 1;
    return 0;
}
