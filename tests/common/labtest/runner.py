"""Build-and-run wrapper around cocotb's Python runner.

Every lab's pytest file calls :func:`run`. The simulator is chosen with the
SIM environment variable (``ghdl`` by default, or ``nvc``).
"""
import os
from pathlib import Path

from cocotb_tools.runner import get_runner

REPO = Path(__file__).resolve().parents[3]
TESTS = REPO / "tests"

SIM_SOURCES = ["sim/prog_image_body_sim.vhd", "sim/clkgen_sim.vhd"]


def rtl_sources():
    lines = (REPO / "rtl" / "sources.f").read_text().splitlines()
    return [ln.strip() for ln in lines if ln.strip() and not ln.startswith("#")]


def all_sources(extra=()):
    return [REPO / p for p in rtl_sources() + SIM_SOURCES + list(extra)]


def _raise_stack_limit():
    """GHDL places large objects (whole memory images) on the stack; the
    default 8 MB stack is too small for the 2 MB arch-test IMEM. Raise the
    soft limit as far as the hard limit allows (inherited by the simulator)."""
    try:
        import resource
    except ImportError:            # not POSIX (native Windows): nothing to do
        return
    soft, hard = resource.getrlimit(resource.RLIMIT_STACK)
    want = 256 * 1024 * 1024 if hard == resource.RLIM_INFINITY else min(hard, 256 * 1024 * 1024)
    if soft != resource.RLIM_INFINITY and soft < want:
        try:
            resource.setrlimit(resource.RLIMIT_STACK, (want, hard))
        except (ValueError, OSError):
            pass


def simulator():
    return os.environ.get("SIM", "ghdl").lower()


def run(toplevel, module, parameters=None, extra_sources=(),
        testcase=None, build_tag=None, waves=None, extra_env=None):
    """Compile all sources, elaborate ``toplevel`` and run the cocotb tests in
    ``module``. The module must be importable (pytest puts the calling test
    file's directory on sys.path, and the runner forwards sys.path).

    The simulation runs inside the build directory, which is where GHDL's
    LLVM backend leaves the elaborated executable; waveforms and any files the
    test writes end up there too."""
    sim = simulator()
    testcase = testcase or os.environ.get("TESTCASE") or None   # make test TESTCASE=...
    if sim not in ("ghdl", "nvc"):
        raise SystemExit(f"SIM must be ghdl or nvc, not {sim!r}")
    runner = get_runner(sim)
    build_dir = REPO / "sim_build" / sim / (build_tag or toplevel)
    # NVC: -H raises the simulation heap (the 2 MB arch-test IMEM image needs it).
    std = ["--std=08"] if sim == "ghdl" else ["--std=2008", "-H", "1g"]
    if waves is None:
        waves = os.environ.get("WAVES", "0") == "1"
    runner.build(
        sources=all_sources(extra_sources),
        hdl_toplevel=toplevel,
        build_dir=build_dir,
        build_args=std,
    )
    # GHDL limits stack objects to 128 kB by default; the memory-image
    # functions build whole memories as local variables.
    # (Runtime options follow the unit name, which is where plusargs go.)
    runtime_args = ["--max-stack-alloc=0"] if sim == "ghdl" else []
    if sim == "ghdl":
        _raise_stack_limit()
    runner.test(
        hdl_toplevel=toplevel,
        plusargs=runtime_args,
        test_module=module,
        build_dir=build_dir,
        test_dir=build_dir,
        parameters=parameters or {},
        testcase=testcase,
        waves=waves,
        extra_env=extra_env or {},
    )


def build_dir_for(toplevel, build_tag=None):
    """Directory the simulation of ``toplevel`` runs in (for generated files)."""
    d = REPO / "sim_build" / simulator() / (build_tag or toplevel)
    d.mkdir(parents=True, exist_ok=True)
    return d
