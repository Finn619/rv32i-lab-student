/*
 * cube_demo.c - animated rotating wireframe cube (Lab 8, path b).
 * Erases the previous cube by redrawing it in the background colour, then
 * draws the next one, once per video frame. Switches 3..0 set the speed.
 * The seven-segment display shows the cycles spent drawing each frame.
 * Build with -DSIM_FRAMES=n to stop after n frames (simulation).
 */
#include "cube.h"
#include "gfx.h"

#define BG RGB332(0, 0, 1)

int main(void)
{
    uint32_t ay = 0, ax = 0;
    fb_clear(BG);
    VGA_CTRL = 1;
#ifdef SIM_FRAMES
    for (int n = 0; n < SIM_FRAMES; n++) {
#else
    for (;;) {
#endif
        uint32_t speed = (SWITCHES & 15) + 1;
        wait_frame();
        uint32_t t = CYCLE_LO;
        draw_cube(ay, ax, 80, 60, 40, BG);           /* erase */
        ay += speed;
        ax += speed >> 1;
        draw_cube(ay, ax, 80, 60, 40, RGB332(7, 7, 3));
        HEX = CYCLE_LO - t;
    }
    return 0;
}
