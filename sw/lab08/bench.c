/*
 * bench.c - cycle cost of each graphics primitive (Lab 8).
 * Prints "<name> <cycles>" lines on the simulation console and shows the
 * last result on the seven-segment displays.
 */
#include "cube.h"
#include "fixed.h"
#include "gfx.h"
#include "lib.h"

static uint32_t t0;
static void start(void) { t0 = CYCLE_LO; }
static void stop(const char *name)
{
    uint32_t c = CYCLE_LO - t0;
    sim_puts(name);
    sim_puts(" ");
    sim_putdec(c);
    sim_puts("\n");
    HEX = c;
}

volatile q16_t sink;

int main(void)
{
    start(); stop("empty");
    start(); fb_clear(0); stop("fb_clear");
    start(); for (int i = 0; i < 100; i++) put_pixel(i, i & 63, 0xFF); stop("put_pixel_x100");
    start(); fill_rect(0, 0, 160, 120, 0x1C); stop("fill_rect_160x120");
    start(); fill_rect(3, 3, 40, 30, 0xE0); stop("fill_rect_40x30");
    start(); draw_line(0, 0, 159, 119, 0xFF); stop("draw_line_diag");
    start(); draw_line(0, 60, 159, 60, 0xFF); stop("draw_line_horiz");
    start(); blend_rect(10, 10, 40, 30, 0xFF, 4); stop("blend_rect_40x30");
    start();
    for (int i = 0; i < 100; i++)
        sink = q16_mul(Q16(3) + i, -Q16(2) - 12345);
    stop("q16_mul_x100");
    start(); draw_cube(10, 20, 80, 60, 30, 0xFF); stop("draw_cube");
    VGA_CTRL = 1;
    return 0;
}
