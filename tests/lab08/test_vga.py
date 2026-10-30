"""Lab 8 - VGA timing generator and full-system frame capture.

The frame tests run a program on soc_tb, capture one frame at the VGA pins
(using only the sync pulses to find the picture) and compare it, pixel for
pixel, with an image in golden/. A mismatching capture is saved as
<scene>.capture.png in the simulation directory for you to inspect.
  path (b): gfx_test, cube_demo     path (a): switch_demo_outline, switch_demo_filled
"""
import os
from pathlib import Path

import cocotb
import pytest
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, First, RisingEdge
from PIL import Image, ImageChops

from labtest import sw
from labtest.checks import resolved
from labtest.runner import REPO, build_dir_for, run
from labtest.soc import SOC_TB_SOURCES, SocHarness, program_parameters

GOLDEN = REPO / "golden"


@cocotb.test()
async def timing_640x480(dut):
    """Check line and frame structure over one full frame."""
    cocotb.start_soon(Clock(dut.clk, 40, unit="ns").start())
    dut.rst.value = 1
    await ClockCycles(dut.clk, 3)
    dut.rst.value = 0
    lines = []          # per line: (hsync low run start, length, active pixels, vsync low)
    for line in range(525):
        hs_start, hs_len, active, vs_low = None, 0, 0, 0
        for px in range(800):
            await FallingEdge(dut.clk)
            h, v = resolved(dut.hcount, "hcount"), resolved(dut.vcount, "vcount")
            assert (h, v) == (px, line), f"counters at ({h},{v}), expected ({px},{line})"
            if resolved(dut.hsync, "hsync") == 0:
                hs_start = px if hs_start is None else hs_start
                hs_len += 1
            active += resolved(dut.active, "active")
            vs_low += resolved(dut.vsync, "vsync") == 0
            assert resolved(dut.in_vblank, "in_vblank") == (line >= 480)
            assert resolved(dut.frame_end, "frame_end") == (px == 799 and line == 524)
        lines.append((hs_start, hs_len, active, vs_low))
    for n, (s, length, act, vs) in enumerate(lines):
        assert (s, length) == (656, 96), f"line {n}: hsync low from {s} for {length} pixels"
        assert act == (640 if n < 480 else 0), f"line {n}: {act} active pixels"
        assert vs == (800 if n in (490, 491) else 0), f"line {n}: vsync low for {vs} pixels"


def test_vga_timing():
    run("vga_timing", "test_vga", testcase="timing_640x480")


# ---------------------------------------------------------------------------
# Whole system: run a program, capture one frame at the VGA pins, compare
# ---------------------------------------------------------------------------

def ppm_to_image(path):
    tokens = Path(path).read_text().split()
    assert tokens[:4] == ["P3", "640", "480", "15"], "bad capture header"
    vals = [int(t) * 17 for t in tokens[4:]]
    assert len(vals) == 640 * 480 * 3, f"capture has {len(vals) // 3} pixels"
    return Image.frombytes("RGB", (640, 480), bytes(vals))


@cocotb.test()
async def capture_frame(dut):
    name = os.environ["SCENE"]
    dut.switches.value = int(os.environ.get("SWITCHES", "0"))
    h = SocHarness(dut)
    res = await h.run(max_cycles=3_000_000)
    assert res.exit_code == 0, f"{name}: {res.summary()}"
    # one frame is 420 000 cycles; allow up to two to start and one to capture
    timeout = ClockCycles(dut.clk, 3 * 420_000)
    if await First(RisingEdge(dut.capture_done), timeout) is timeout:
        raise AssertionError(f"{name}: no complete frame was captured - check that vga_hs and "
                             "vga_vs toggle with the 640x480 timing (test_vga_timing)")
    got = ppm_to_image(os.environ["CAPTURE"])
    got.save(f"{name}.capture.png")
    golden = Image.open(GOLDEN / f"{name}.png").convert("RGB")
    diff = ImageChops.difference(got, golden).getbbox()
    assert diff is None, f"{name}: VGA output differs from golden image in region {diff} " \
                         f"(see {Path.cwd() / (name + '.capture.png')})"
    dut._log.info(f"{name}: frame matches golden image ({res.cycles} cycles to draw)")


@pytest.fixture(scope="module")
def built():
    sw.build("lab08")


CASES = {  # scene: (program, build dir, switches)
    "gfx_test": ("gfx_test", "build/gfx_test", 0),
    "cube_demo": ("cube_demo", "build/cube_demo_sim", 0),
    "switch_demo_outline": ("switch_demo", "build/switch_demo_sim", 0x100 | 0xE3),
    "switch_demo_filled": ("switch_demo", "build/switch_demo_sim", 0x000 | 0x1C),
}


@pytest.mark.parametrize("scene", sorted(CASES))
def test_frame(built, scene):
    prog, bdir, switches = CASES[scene]
    imem, dmem = sw.images("lab08", prog, bdir)
    cap = build_dir_for("soc_tb") / f"{scene}.ppm"
    run("soc_tb", "test_vga", testcase="capture_frame",
        parameters=program_parameters(imem, dmem, CAPTURE_FILE=str(cap)),
        extra_sources=SOC_TB_SOURCES,
        extra_env={"SCENE": scene, "CAPTURE": str(cap), "SWITCHES": str(switches)})
