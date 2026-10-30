"""Lab 4 - whole-core integration tests.

Each program (assembled in advance; source listing in programs.json) runs on
core_tb, and every retired instruction reported on the RVFI port is compared
with the reference trace. The 'hand' test runs YOUR hand-assembled
sw/lab04/hand.hex.
"""
import os
import re

import cocotb
import pytest

from labtest import trace
from labtest.runner import REPO, build_dir_for, run
from labtest.soc import CORE_TB_SOURCES, SocHarness, program_parameters

HERE = os.path.dirname(os.path.abspath(__file__))
PROGRAMS = trace.load(os.path.join(HERE, "programs.json"))


@cocotb.test()
async def run_program(dut):
    name = os.environ["PROGRAM"]
    prog = PROGRAMS[name]
    checker = trace.TraceChecker(prog["trace"])
    res = await SocHarness(dut).run(max_cycles=20000, on_retire=checker)
    assert not res.timed_out, f"{name}: {res.summary()} after {checker.count} matching instructions"
    if prog["expect_trap"]:
        assert res.trapped, f"{name}: expected the core to trap, but it {res.summary()}"
    else:
        assert not res.trapped, f"{name}: unexpected trap after {checker.count} instructions"
        assert res.exit_code == 0, f"{name}: {res.summary()}"
    assert checker.finished(), f"{name}: stopped after {checker.count} of {len(prog['trace'])} instructions"
    dut._log.info(f"{name}: all {checker.count} instructions match the reference trace")


def _run(name):
    prog = PROGRAMS[name]
    if prog["imem"] is None:
        hexfile = REPO / "sw" / "lab04" / "hand.hex"
        words = [ln.strip() for ln in hexfile.read_text().splitlines()
                 if ln.strip() and not ln.lstrip().startswith("#")]
        bad = [w for w in words if not re.fullmatch(r"[0-9a-fA-F]{8}", w)]
        assert not bad, f"sw/lab04/hand.hex: {len(bad)} line(s) are not 8 hex digits (first: {bad[0]!r})"
        code = [re.sub(r"^\s*\w+:", "", ln.split("#")[0]).strip()
                for ln in (REPO / "sw" / "lab04" / "hand.S").read_text().splitlines()]
        n_insn = sum(1 for c in code if c)
        assert len(words) == n_insn, \
            f"sw/lab04/hand.hex has {len(words)} words; hand.S has {n_insn} instructions"
    else:
        hexfile = build_dir_for("core_tb") / f"{name}.imem.hex"
        hexfile.write_text("".join(f"{w:08x}\n" for w in prog["imem"]))
    run("core_tb", "test_core", parameters=program_parameters(hexfile),
        extra_sources=CORE_TB_SOURCES, extra_env={"PROGRAM": name})


@pytest.mark.parametrize("name", ["alu", "branches", "loadstore", "sum_array"])
def test_program(name):
    _run(name)


@pytest.mark.parametrize("name", sorted(k for k, v in PROGRAMS.items() if v["expect_trap"]))
def test_trap(name):
    _run(name)


def test_hand_assembled():
    _run("hand")
