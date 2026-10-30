"""Lab 5 - C programs on the CPU.

Builds sw/lab05, runs each program on core_tb and checks the console output
and exit code. After Lab 6, run with LOCKSTEP=1 to also compare every
instruction with your ISS.
"""
import os

import cocotb
import pytest

from labtest import sw
from labtest.iss import Hart, Memory
from labtest.lockstep import Lockstep
from labtest.runner import run
from labtest.soc import CORE_TB_SOURCES, SocHarness, program_parameters

EXPECT = {
    "hello": "Hello from RV32I!\n",
    "selftest": "failures: 0\n",
}


@cocotb.test()
async def run_c_program(dut):
    name = os.environ["PROGRAM"]
    checker = None
    if os.environ.get("LOCKSTEP", "0") == "1":     # after Lab 6: compare with your ISS
        mem = Memory()
        mem.load_hex("imem", os.environ["IMEM_HEX"])
        mem.load_hex("dmem", os.environ["DMEM_HEX"])
        checker = Lockstep(Hart(mem))
    res = await SocHarness(dut).run(max_cycles=200_000, on_retire=checker)
    dut._log.info(f"{name} console output:\n{res.console}")
    assert res.exit_code == 0, f"{name}: {res.summary()}"
    assert res.console.endswith(EXPECT[name]), f"{name}: unexpected output {res.console!r}"
    dut._log.info(f"{name}: halted after {res.cycles} cycles")


@pytest.fixture(scope="module", autouse=True)
def built():
    sw.build("lab05")


@pytest.mark.parametrize("prog", sorted(EXPECT))
def test_c_program(prog):
    imem, dmem = sw.images("lab05", prog)
    run("core_tb", "test_programs", parameters=program_parameters(imem, dmem),
        extra_sources=CORE_TB_SOURCES,
        extra_env={"PROGRAM": prog, "IMEM_HEX": str(imem), "DMEM_HEX": str(dmem)})
