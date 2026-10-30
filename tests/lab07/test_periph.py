"""Lab 7 - reset synchroniser and seven-segment drivers.

The seven-segment tests check only digits 0, 1 and 8; extend
sevenseg_patterns with the rest of YOUR table (Task 3)."""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer, ValueChange, with_timeout

from labtest.checks import check, resolved
from labtest.runner import run

# Active-high segment patterns (bit 0 = a ... bit 6 = g) for the digits the
# provided tests use. The other thirteen are yours to derive.
SEGMENTS = {0x0: 0x3F, 0x1: 0x06, 0x8: 0x7F}


@cocotb.test()
async def reset_sync_behaviour(dut):
    cocotb.start_soon(Clock(dut.clk, 40, unit="ns").start())
    dut.arst_in.value = 1
    await ClockCycles(dut.clk, 2)
    check(dut.rst_out, 1, "rst_out while arst_in is asserted")
    dut.arst_in.value = 0
    # release must take exactly STAGES (=3) rising edges, aligned to the clock
    edges = 0
    while resolved(dut.rst_out, "rst_out") == 1:
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        edges += 1
        assert edges <= 10, "rst_out never released"
    assert edges == 3, f"rst_out released after {edges} edges, expected 3"
    # assertion must be immediate, without waiting for a clock edge
    await FallingEdge(dut.clk)
    await Timer(5, unit="ns")
    dut.arst_in.value = 1
    await Timer(1, unit="ns")
    check(dut.rst_out, 1, "rst_out 1 ns after arst_in asserted mid-cycle (asynchronous assertion)")
    dut.arst_in.value = 0


def test_reset_sync():
    run("reset_sync", "test_periph", testcase="reset_sync_behaviour")


@cocotb.test()
async def sevenseg_patterns(dut):
    for d, pattern in SEGMENTS.items():
        dut.digit.value = d
        await Timer(1, unit="ns")
        check(dut.segs, pattern, f"segments for digit {d:X}")


def test_sevenseg_dec():
    run("sevenseg_dec", "test_periph", testcase="sevenseg_patterns")


@cocotb.test()
async def sevenseg_scan(dut):
    """Every digit is enabled in turn, one at a time, showing its nibble;
    blanked digits are never enabled."""
    cocotb.start_soon(Clock(dut.clk, 40, unit="ns").start())
    dut.rst.value = 1
    dut.value.value = 0x8010
    dut.blank.value = 0b0100
    await ClockCycles(dut.clk, 3)
    dut.rst.value = 0
    seen = {}
    for _ in range(12):
        try:
            await with_timeout(ValueChange(dut.an_n), 2, "ms")
        except Exception:
            raise AssertionError("an_n did not change within 2 ms of simulated time: "
                                 "the display is not being scanned") from None
        await ClockCycles(dut.clk, 2)
        an = resolved(dut.an_n, "an_n")
        if an == 0xF:
            continue
        assert bin(~an & 0xF).count("1") == 1, f"more than one digit enabled: an_n={an:04b}"
        digit = (~an & 0xF).bit_length() - 1
        seen[digit] = (~resolved(dut.seg_n, "seg_n")) & 0x7F
    assert set(seen) == {0, 1, 3}, f"digits enabled: {sorted(seen)} (digit 2 is blanked)"
    for digit, nib in ((0, 0x0), (1, 0x1), (3, 0x8)):
        assert seen[digit] == SEGMENTS[nib], f"digit {digit} shows {seen[digit]:07b}"


def test_sevenseg_mux():
    run("sevenseg_mux", "test_periph", testcase="sevenseg_scan",
        parameters={"CLK_HZ": 1_000_000, "DIGIT_HZ": 50_000})
