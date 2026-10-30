#ifndef CUBE_H
#define CUBE_H
#include <stdint.h>
/* Draw a wireframe cube rotated by angles ay (about Y) and ax (about X),
 * in 1/256 turn units, centred at (cx, cy) with half-size 'scale' pixels. */
void draw_cube(uint32_t ay, uint32_t ax, int cx, int cy, int scale, uint8_t colour);
#endif
