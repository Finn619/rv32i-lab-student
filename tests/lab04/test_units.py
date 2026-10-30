"""Lab 4 - branch unit and load/store unit (provided fixed vectors; add your
own random tests against models you write)."""
import json
import os

import cocotb
from cocotb.triggers import Timer

from labtest.checks import check
from labtest.runner import run

HERE = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(HERE, "unit_vectors.json")) as f:
    VECTORS = json.load(f)


@cocotb.test()
async def branch_conditions(dut):
    for v in VECTORS["branch"]:
        dut.rs1.value, dut.rs2.value, dut.funct3.value = v["rs1"], v["rs2"], v["funct3"]
        await Timer(1, unit="ns")
        check(dut.taken, v["taken"], f"taken for {v['name']}", f"rs1=0x{v['rs1']:08x} rs2=0x{v['rs2']:08x}")


@cocotb.test()
async def lsu_sizes_and_offsets(dut):
    for v in VECTORS["lsu"]:
        dut.funct3.value, dut.addr_lo.value = v["funct3"], v["addr_lo"]
        dut.store_data.value, dut.mem_rdata.value = v["store_data"], v["mem_rdata"]
        await Timer(1, unit="ns")
        ctx = f"funct3={v['funct3']:03b} addr[1:0]={v['addr_lo']:02b}"
        check(dut.misaligned, v["misaligned"], "misaligned", ctx)
        if v["byte_en"] is not None:
            check(dut.byte_en, v["byte_en"], "byte_en", ctx)
            check(dut.load_data, v["load_data"], "load_data", ctx)
        if v["wdata_lanes"] is not None:
            lanes = sum(0xFF << 8 * k for k in range(4) if v["byte_en"] >> k & 1)
            got = int(dut.wdata.value) & lanes if dut.wdata.value.is_resolvable else None
            assert got == v["wdata_lanes"], f"wdata on the enabled lanes: {ctx}"


@cocotb.test()
async def branch_random(dut):
    """TODO (Lab 4, Task 4.2): random rs1/rs2 (biased towards equal values,
    sign boundaries and 0/-1) for every funct3, checked against a Python
    model of the branch conditions you write from the spec."""
    raise NotImplementedError("branch_random: Lab 4, Task 4.2")


@cocotb.test()
async def lsu_random(dut):
    """TODO (Lab 4, Task 4.2): random funct3 (loads and stores), addr_lo,
    store_data and mem_rdata, checked against your own LSU model: byte_en,
    wdata on the enabled lanes, load_data and misaligned."""
    raise NotImplementedError("lsu_random: Lab 4, Task 4.2")


# Each pytest function runs one toplevel; the cocotb tests for it are listed
# in 'testcase' (comma-separated names run in that order).
def test_branch_unit():
    run("branch_unit", "test_units", testcase="branch_conditions,branch_random")


def test_lsu():
    run("lsu", "test_units", testcase="lsu_sizes_and_offsets,lsu_random")
