/* cube.c - rotating wireframe cube with Q16.16 maths (Lab 8, path b) - YOURS.
 * The golden images need exactly this maths (corner numbering and the order
 * in which you draw the 12 edges are up to you - they do not change pixels):
 *   corners (+-1, +-1, +-1) as Q16.16 values;
 *   rotate about Y by ay:  x1 = x cos(ay) + z sin(ay),  z1 = z cos(ay) - x sin(ay)
 *   then about X by ax:    y1 = y cos(ax) - z1 sin(ax)
 *   where each product is one q16_mul, and sin/cos come from q16_sin/q16_cos;
 *   project: px = cx + Q16_INT(q16_mul(x1, Q16(scale))), likewise py with y1, cy;
 *   draw every cube edge with draw_line.
 */
#include "cube.h"
#include "fixed.h"
#include "gfx.h"

void draw_cube(uint32_t ay, uint32_t ax, int cx, int cy, int scale, uint8_t colour)
{
    /* TODO (Lab 8, Task 8.9) */
    (void)ay; (void)ax; (void)cx; (void)cy; (void)scale; (void)colour;
}
