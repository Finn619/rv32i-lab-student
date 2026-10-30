"""Lab 7 - MMIO through the SoC, and both board wrappers in simulation
Runs sw/lab07/board_test. Switch values use only the digits 0, 1 and 8,
whose segment patterns are given in test_periph.py."""
import os

import cocotb
import pytest
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, ValueChange, with_timeout

from labtest import sw
from labtest.checks import resolved
from labtest.runner import run
from labtest.soc import SOC_TB_SOURCES, SocHarness, program_parameters
from test_periph import SEGMENTS


@pytest.fixture(scope="module", autouse=True)
def built():
    sw.build("lab07")


def images():
    return sw.images("lab07", "board_test")


@cocotb.test()
async def mmio_soc(dut):
    """Switches -> LEDs and HEX; button presses are counted."""
    SocHarness(dut)                 # starts the clock; the testbench applies reset
    dut.switches.value = 0x8101
    dut.buttons.value = 0
    await ClockCycles(dut.clk, 300)
    assert resolved(dut.leds) == 0x8101, f"LEDs = {resolved(dut.leds):04x}"
    assert resolved(dut.hex_value) == 0x00008101
    for presses in (1, 2, 3):
        dut.buttons.value = 1
        await ClockCycles(dut.clk, 100)
        dut.buttons.value = 0
        await ClockCycles(dut.clk, 100)
        assert resolved(dut.hex_value) >> 16 == presses, f"HEX = {resolved(dut.hex_value):08x}"
    dut.switches.value = 0x0001
    await ClockCycles(dut.clk, 100)
    assert resolved(dut.leds) == 1
    assert resolved(dut.hex_blank) == 0


def test_mmio():
    imem, dmem = images()
    run("soc_tb", "test_board", testcase="mmio_soc",
        parameters=program_parameters(imem, dmem), extra_sources=SOC_TB_SOURCES)


def hex_digit(seg_n):
    v = (~seg_n) & 0x7F
    inv = {p: d for d, p in SEGMENTS.items()}
    assert v in inv, f"segment pattern {v:07b} is not the pattern for 0, 1 or 8"
    return inv[v]


@cocotb.test()
async def de10lite(dut):
    cocotb.start_soon(Clock(dut.MAX10_CLK1_50, 20, unit="ns").start())
    dut.KEY.value = 0b10           # KEY0 pressed = reset
    dut.SW.value = 0x081
    await ClockCycles(dut.MAX10_CLK1_50, 20)
    dut.KEY.value = 0b11
    await ClockCycles(dut.MAX10_CLK1_50, 1000)
    assert resolved(dut.LEDR) == 0x081, f"LEDR = {resolved(dut.LEDR):03x}"
    shown = [hex_digit(resolved(getattr(dut, f"HEX{i}")) & 0x7F) for i in range(4)]
    assert shown == [0x1, 0x8, 0x0, 0x0], f"HEX3..0 show {shown[::-1]}"
    for i in range(6):
        assert resolved(getattr(dut, f"HEX{i}")) >> 7 == 1, f"HEX{i} decimal point lit"
    dut.KEY.value = 0b01           # press KEY1 (active low)
    await ClockCycles(dut.MAX10_CLK1_50, 200)
    dut.KEY.value = 0b11
    await ClockCycles(dut.MAX10_CLK1_50, 200)
    assert hex_digit(resolved(dut.HEX4) & 0x7F) == 1, "button press not counted on HEX4"
    assert resolved(dut.VGA_HS) in (0, 1)


def test_de10lite_top():
    imem, dmem = images()
    run("de10lite_top", "test_board", testcase="de10lite",
        parameters=program_parameters(imem, dmem),
        extra_sources=["boards/de10lite/de10lite_top.vhd"])


@cocotb.test()
async def basys3(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    for b in ("btnU", "btnL", "btnR", "btnD"):
        getattr(dut, b).value = 0
    dut.btnC.value = 1
    dut.sw.value = 0x8011
    await ClockCycles(dut.clk, 40)
    dut.btnC.value = 0
    await ClockCycles(dut.clk, 2000)
    assert resolved(dut.led) == 0x8011, f"led = {resolved(dut.led):04x}"
    assert resolved(dut.dp) == 1
    seen = {}
    while len(seen) < 4:           # one full scan (~4 ms of simulated time)
        try:
            await with_timeout(ValueChange(dut.an), 3, "ms")
        except Exception:
            raise AssertionError(f"an did not change within 3 ms; digits seen so far: {seen}") from None
        await ClockCycles(dut.clk, 8)
        an = resolved(dut.an)
        if an != 0xF:
            seen[(~an & 0xF).bit_length() - 1] = hex_digit(resolved(dut.seg))
    assert [seen[i] for i in range(4)] == [0x1, 0x1, 0x0, 0x8], f"digits {seen}"


def test_basys3_top():
    imem, dmem = images()
    run("basys3_top", "test_board", testcase="basys3",
        parameters=program_parameters(imem, dmem),
        extra_sources=["boards/basys3/basys3_top.vhd"])
