/*
 * board_test.c - on-board test program (Lab 7).
 *   LEDs        mirror the switches
 *   HEX[3:0]    show the switch value in hexadecimal
 *   HEX[5:4]    count presses of button 0 (DE10-Lite KEY1, Basys 3 btnU);
 *               only visible on the six-digit DE10-Lite display
 * Buttons are not debounced here: a bouncy button may count several presses.
 * (Debouncing in software is an extension task.)
 */
#include <stdint.h>
#include "mmio.h"

int main(void)
{
    uint32_t presses = 0, prev = 0;

    HEX_BLANK = 0;
    for (;;) {
        uint32_t sw = SWITCHES;
        uint32_t b = BUTTONS;

        if ((b & 1) && !(prev & 1))
            presses++;
        prev = b;

        LEDS = sw;
        HEX = ((presses & 0xFF) << 16) | (sw & 0xFFFF);
    }
}
