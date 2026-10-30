/*
 * selftest.c - exercises the C run-time environment (Lab 5):
 * .data initialisation, .bss zeroing, .rodata, the stack, recursion,
 * libgcc multiply/divide, switch jump tables, signed/unsigned char and
 * short accesses. Prints one line per check; returns the number of failures.
 */
#include <stdint.h>
#include "lib.h"

static int32_t initialised = 0x1234;            /* .data (or .sdata)   */
static int32_t zeroed[64];                      /* .bss                */
static const char message[] = "rodata ok";      /* .rodata             */
static int8_t  sbytes[4] = {-1, -128, 127, 5};  /* signed bytes        */
static uint16_t halves[2] = {0xFFFE, 0x8001};

static int failures;

static void report(const char *what, int ok)
{
    sim_puts(ok ? "PASS " : "FAIL ");
    sim_puts(what);
    sim_puts("\n");
    failures += !ok;
}

static uint32_t fib(uint32_t n)
{
    return n < 2 ? n : fib(n - 1) + fib(n - 2);
}

static int classify(int x)
{
    switch (x) {            /* dense cases: GCC builds a jump table in .rodata */
    case 0: return 10;
    case 1: return 11;
    case 2: return 12;
    case 3: return 13;
    case 4: return 14;
    case 5: return 15;
    case 6: return 16;
    default: return -1;
    }
}

static void bubble_sort(int32_t *a, int n)
{
    for (int i = 0; i < n - 1; i++)
        for (int j = 0; j < n - 1 - i; j++)
            if (a[j] > a[j + 1]) {
                int32_t t = a[j];
                a[j] = a[j + 1];
                a[j + 1] = t;
            }
}

int main(void)
{
    int all_zero = 1;
    for (int i = 0; i < 64; i++)
        all_zero &= zeroed[i] == 0;
    report(".bss is zeroed", all_zero);
    report(".data is initialised", initialised == 0x1234);
    report(".rodata string", message[0] == 'r' && message[8] == 'k' && message[9] == 0);

    report("signed byte loads", sbytes[0] == -1 && sbytes[1] == -128 && sbytes[2] == 127);
    report("unsigned halfword loads", halves[0] == 0xFFFE && halves[1] == 0x8001);

    volatile int32_t a = -7, b = 3;
    report("multiply (libgcc)", a * b == -21);
    report("divide/remainder (libgcc)", a / b == -2 && a % b == -1);
    volatile uint32_t ua = 0xFFFFFFF0u;
    report("unsigned divide", ua / 16 == 0x0FFFFFFF);

    report("recursion fib(15) = 610", fib(15) == 610);

    int sum = 0;
    for (int i = -1; i <= 7; i++)
        sum += classify(i);
    report("switch jump table", sum == 10 + 11 + 12 + 13 + 14 + 15 + 16 - 2);

    int32_t arr[10] = {5, -3, 9, 0, 2, 2, -8, 100, 7, 1};
    bubble_sort(arr, 10);
    int sorted = 1;
    for (int i = 0; i < 9; i++)
        sorted &= arr[i] <= arr[i + 1];
    report("bubble sort on the stack", sorted && arr[0] == -8 && arr[9] == 100);

    zeroed[3] = 42;
    initialised += 1;
    report("writes to .bss/.data", zeroed[3] == 42 && initialised == 0x1235);

    sim_puts("failures: ");
    sim_putdec((uint32_t)failures);
    sim_puts("\n");
    return failures;
}
