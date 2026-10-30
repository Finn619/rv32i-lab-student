"""Lab 6 - constrained-random programs (your randgen) in lockstep with your
ISS, with your functional coverage model. Provided harness."""
import os

import cocotb
import pytest

from labtest.coverage import Coverage
from labtest.iss import Hart, Memory
from labtest.lockstep import Lockstep
from labtest.randgen import RandomProgram
from labtest.runner import build_dir_for, run
from labtest.soc import CORE_TB_SOURCES, SocHarness, program_parameters

SEEDS = list(range(int(os.environ.get("RANDOM_SEEDS", "20"))))
COVERAGE_FILE = "coverage_seed{}.txt"


@cocotb.test()
async def random_lockstep(dut):
    seed = int(os.environ["SEED"])
    mem = Memory()
    mem.load_hex("imem", os.environ["PROGRAM_HEX"])
    cov = Coverage()
    try:
        cov.goals()
    except NotImplementedError:      # Task 6 not done yet: run without coverage
        cov = None
    checker = Lockstep(Hart(mem), coverage=cov)
    res = await SocHarness(dut).run(max_cycles=50_000, on_retire=checker)
    assert res.exit_code is not None, f"seed {seed}: {res.summary()}"
    if cov is not None:
        text, _ = cov.report()
        with open(COVERAGE_FILE.format(seed), "w") as f:
            f.write(repr(dict(cov.hits)))
        dut._log.info(f"seed {seed}: {checker.count} instructions matched\n{text.splitlines()[0]}")
    else:
        dut._log.info(f"seed {seed}: {checker.count} instructions matched (no coverage model yet)")


@pytest.mark.parametrize("seed", SEEDS)
def test_random_program(seed):
    words = RandomProgram(seed, length=600).generate()
    d = build_dir_for("core_tb")
    hexfile = d / f"random_{seed}.imem.hex"
    hexfile.write_text("".join(f"{w & 0xFFFFFFFF:08x}\n" for w in words))
    run("core_tb", "test_random", parameters=program_parameters(hexfile),
        extra_sources=CORE_TB_SOURCES,
        extra_env={"SEED": str(seed), "PROGRAM_HEX": str(hexfile)})


def test_coverage_closure():
    """Merge the coverage of all seeds; every bin must have been hit."""
    import ast
    cov = Coverage()
    d = build_dir_for("core_tb")
    for seed in SEEDS:
        f = d / COVERAGE_FILE.format(seed)
        assert f.exists(), f"no coverage data for seed {seed} (run the random tests first)"
        for k, v in ast.literal_eval(f.read_text()).items():
            cov.hits[k] += v
    text, missed = cov.report()
    (d / "coverage_report.txt").write_text(text + "\n")
    print(text)
    assert not missed, f"{len(missed)} coverage bins not hit:\n{text}"
