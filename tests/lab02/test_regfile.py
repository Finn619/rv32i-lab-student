"""Lab 2 - register file tests (provided)."""
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer

from labtest.checks import check
from labtest.runner import run


async def setup(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.we.value = 0
    dut.waddr.value = 0
    dut.wdata.value = 0
    dut.raddr1.value = 0
    dut.raddr2.value = 0
    await FallingEdge(dut.clk)


async def write(dut, reg, value):
    dut.we.value = 1
    dut.waddr.value = reg
    dut.wdata.value = value
    await FallingEdge(dut.clk)
    dut.we.value = 0


@cocotb.test()
async def x0_reads_zero(dut):
    """Writes to x0 are discarded; x0 always reads as zero on both ports."""
    await setup(dut)
    await write(dut, 0, 0xDEADBEEF)
    dut.raddr1.value = 0
    dut.raddr2.value = 0
    await Timer(1, unit="ns")
    check(dut.rdata1, 0, "rdata1 for x0")
    check(dut.rdata2, 0, "rdata2 for x0")


@cocotb.test()
async def write_then_read_all(dut):
    """Each register holds its own value, readable on both ports."""
    await setup(dut)
    for r in range(1, 32):
        await write(dut, r, (0x0101_0000 * r + r))
    for r in range(1, 32):
        dut.raddr1.value = r
        dut.raddr2.value = 32 - r
        await Timer(1, unit="ns")
        check(dut.rdata1, (0x0101_0000 * r + r), f"rdata1 x{r}")
        check(dut.rdata2, (0x0101_0000 * (32 - r) + (32 - r)), f"rdata2 x{32 - r}")


@cocotb.test()
async def read_is_combinational(dut):
    """The read ports follow the read address within the same cycle."""
    await setup(dut)
    await write(dut, 7, 0x77)
    await write(dut, 9, 0x99)
    dut.raddr1.value = 7
    await Timer(1, unit="ns")
    check(dut.rdata1, 0x77, "rdata1 after changing raddr1 to x7")
    dut.raddr1.value = 9
    await Timer(1, unit="ns")
    check(dut.rdata1, 0x99, "rdata1 after changing raddr1 to x9 (no clock edge)")


@cocotb.test()
async def write_takes_effect_at_edge(dut):
    """A read in the same cycle as a write still sees the old value; the new
    value appears after the rising edge (what a single-cycle CPU needs)."""
    await setup(dut)
    await write(dut, 5, 0x1234)
    dut.raddr1.value = 5
    dut.we.value = 1
    dut.waddr.value = 5
    dut.wdata.value = 0x5678
    await Timer(1, unit="ns")
    check(dut.rdata1, 0x1234, "rdata1 before the write edge")
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    check(dut.rdata1, 0x5678, "rdata1 after the write edge")
    dut.we.value = 0


@cocotb.test()
async def no_write_without_enable(dut):
    await setup(dut)
    await write(dut, 3, 0xAAAA)
    dut.we.value = 0
    dut.waddr.value = 3
    dut.wdata.value = 0x5555
    await FallingEdge(dut.clk)
    dut.raddr1.value = 3
    await Timer(1, unit="ns")
    check(dut.rdata1, 0xAAAA, "x3 after a cycle with we=0")


@cocotb.test()
async def random_against_model(dut):
    await setup(dut)
    rng = random.Random(2)
    model = [0] * 32
    for r in range(1, 32):     # earlier tests left values behind
        await write(dut, r, 0)
    for _ in range(2000):
        we = rng.random() < 0.6
        wa, wd = rng.randrange(32), rng.getrandbits(32)
        ra1, ra2 = rng.randrange(32), rng.randrange(32)
        dut.we.value = int(we)
        dut.waddr.value = wa
        dut.wdata.value = wd
        dut.raddr1.value = ra1
        dut.raddr2.value = ra2
        await Timer(1, unit="ns")
        check(dut.rdata1, model[ra1], f"rdata1 x{ra1}")
        check(dut.rdata2, model[ra2], f"rdata2 x{ra2}")
        await FallingEdge(dut.clk)
        if we and wa != 0:
            model[wa] = wd


def test_regfile():
    run("regfile", "test_regfile")
