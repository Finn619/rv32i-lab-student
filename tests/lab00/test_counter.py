"""Lab 0 - the provided counter and its test (complete, given to students).

Run it with:   make test LAB=0         (or: SIM=nvc make test LAB=0)
"""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

from labtest.checks import check
from labtest.runner import run


@cocotb.test()
async def counts_when_enabled(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    dut.en.value = 0
    await ClockCycles(dut.clk, 2)
    await FallingEdge(dut.clk)
    check(dut.q, 0, "q after reset")
    dut.rst.value = 0
    dut.en.value = 1
    for expected in range(1, 20):
        await FallingEdge(dut.clk)
        check(dut.q, expected, "q while counting")


@cocotb.test()
async def holds_when_disabled(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    await FallingEdge(dut.clk)
    dut.rst.value = 0
    dut.en.value = 1
    await ClockCycles(dut.clk, 5)
    await FallingEdge(dut.clk)
    dut.en.value = 0
    held = int(dut.q.value)
    for _ in range(10):
        await FallingEdge(dut.clk)
        check(dut.q, held, "q with en = 0")


@cocotb.test()
async def wraps_around(dut):
    """With WIDTH = 4 the counter wraps from 15 to 0."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.rst.value = 1
    await FallingEdge(dut.clk)
    dut.rst.value = 0
    dut.en.value = 1
    for i in range(1, 40):
        await FallingEdge(dut.clk)
        check(dut.q, i % 16, "q (4-bit counter)")


def test_counter():
    run("counter", "test_counter", parameters={"WIDTH": 4}, extra_sources=["lab0/counter.vhd"])
