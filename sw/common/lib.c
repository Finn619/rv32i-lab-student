/*
 * lib.c - the few C library routines GCC may call implicitly even in
 * freestanding code (struct copies, array initialisers), plus tiny
 * simulation-console helpers.
 */
#include <stddef.h>
#include <stdint.h>
#include "mmio.h"
#include "lib.h"

void *memset(void *dst, int c, size_t n)
{
    uint8_t *d = dst;
    while (n--)
        *d++ = (uint8_t)c;
    return dst;
}

void *memcpy(void *dst, const void *src, size_t n)
{
    uint8_t *d = dst;
    const uint8_t *s = src;
    while (n--)
        *d++ = *s++;
    return dst;
}

int memcmp(const void *a, const void *b, size_t n)
{
    const uint8_t *p = a, *q = b;
    for (; n; n--, p++, q++)
        if (*p != *q)
            return *p - *q;
    return 0;
}

void sim_puts(const char *s)
{
    while (*s)
        SIM_PUTC = (uint8_t)*s++;
}

void sim_puthex(uint32_t v)
{
    for (int i = 28; i >= 0; i -= 4)
        SIM_PUTC = "0123456789abcdef"[(v >> i) & 15];
}

void sim_putdec(uint32_t v)
{
    char buf[11];
    int i = 10;
    buf[i] = 0;
    do {
        /* divide by 10 without a divide instruction: libgcc does it */
        buf[--i] = (char)('0' + v % 10);
        v /= 10;
    } while (v);
    sim_puts(&buf[i]);
}
