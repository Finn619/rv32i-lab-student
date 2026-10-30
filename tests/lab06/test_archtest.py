"""Lab 6 - riscv-arch-test RV32I suite on core_tb.

Needs the suite (python3 arch-test/archtest.py fetch, or ARCH_TEST_DIR) and
riscv-none-elf-gcc. Each test's signature, streamed out through
SIM_SIGNATURE, must equal the committed Sail reference signature.
LOCKSTEP=1 additionally compares every instruction with your ISS.
"""
import os
import subprocess
import sys

import cocotb
import pytest

from labtest.iss import Hart, Memory
from labtest.lockstep import Lockstep
from labtest.runner import REPO, run
from labtest.soc import CORE_TB_SOURCES, SocHarness, program_parameters

ARCH = REPO / "arch-test"
REFS = ARCH / "references"
TESTS = sorted(p.name.split(".")[0] for p in REFS.glob("*.reference_output"))
IMEM_BYTES = 2 * 1024 * 1024


@cocotb.test()
async def arch_test(dut):
    name = os.environ["ARCH_TEST"]
    build = ARCH / "build" / name
    expected = [int(x, 16) for x in (REFS / f"{name}.reference_output").read_text().split()]
    mem = Memory(imem_bytes=IMEM_BYTES)
    mem.load_hex("imem", build / f"{name}.imem.hex")
    mem.load_hex("dmem", build / f"{name}.dmem.hex")
    checker = Lockstep(Hart(mem)) if os.environ.get("LOCKSTEP", "0") == "1" else None
    res = await SocHarness(dut).run(max_cycles=200_000, on_retire=checker)
    assert res.exit_code is not None, f"{name}: {res.summary()}"
    got = res.signature
    assert len(got) == len(expected), f"{name}: signature has {len(got)} words, reference {len(expected)}"
    for i, (g, e) in enumerate(zip(got, expected)):
        assert g == e, f"{name}: signature word {i} is 0x{g:08x}, reference 0x{e:08x}"
    dut._log.info(f"{name}: {len(got)} signature words match ({res.cycles} cycles)")


@pytest.fixture(scope="module", autouse=True)
def built():
    subprocess.run([sys.executable, str(ARCH / "archtest.py"), "build"], check=True,
                   stdout=subprocess.DEVNULL)


@pytest.mark.parametrize("name", TESTS)
def test_arch(name):
    b = ARCH / "build" / name
    run("core_tb", "test_archtest", build_tag="core_tb_arch",
        parameters=program_parameters(b / f"{name}.imem.hex", b / f"{name}.dmem.hex",
                                      IMEM_WORDS=IMEM_BYTES // 4),
        extra_sources=CORE_TB_SOURCES, extra_env={"ARCH_TEST": name})
