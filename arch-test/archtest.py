#!/usr/bin/env python3
"""archtest.py - build riscv-arch-test RV32I tests for the lab SoC (Lab 6).

  python3 archtest.py fetch               clone the pinned riscv-arch-test release
  python3 archtest.py build [TEST ...]    compile tests for the SoC -> build/<test>.{imem,dmem}.hex
  python3 archtest.py refs  [TEST ...]    (instructor) regenerate reference signatures
                                          with the Sail model; needs sail_riscv_sim on PATH

The reference signatures in references/ were produced by Sail; students do
not need Sail. Signatures are position-independent by design, so the Sail
build (linked at 0x80000000) and the SoC build give comparable results.
"""
import os
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TAG = "3.10.0"
URL = "https://github.com/riscv/riscv-arch-test.git"
SUITE = Path(os.environ.get("ARCH_TEST_DIR", HERE / f"riscv-arch-test-{TAG}"))
SRC = SUITE / "riscv-test-suite" / "rv32i_m" / "I" / "src"
BUILD = HERE / "build"
REFS = HERE / "references"
TOOLS = HERE.parent / "tools"

ARCH_IMEM_BYTES = 2 * 1024 * 1024   # simulation IMEM for arch tests (jal-01 is ~1.75 MB)
ARCH_DMEM_BYTES = 64 * 1024

CC = "riscv-none-elf-gcc"
CFLAGS = ["-march=rv32i_zicsr", "-mabi=ilp32", "-static", "-mcmodel=medany",
          "-fvisibility=hidden", "-nostdlib", "-nostartfiles",
          "-DXLEN=32", "-DFLEN=32", "-DTEST_CASE_1=True"]

# Tests that are not run, with the reason (none are excluded at present).
EXCLUDED = {}

# riscv-arch-test 3.10.0 aligns code with ".option rvc" + ".align", which pads
# with compressed c.nop instructions - illegal on a core without the C
# extension. We build from a copy of arch_test.h with every ".option rvc"
# changed to ".option norvc": padding then uses 4-byte NOPs. Only padding
# changes; no test operation does. Both the SoC and the Sail builds use it.
PATCHED_ENV = BUILD / "env_patched"


def patch_env():
    PATCHED_ENV.mkdir(parents=True, exist_ok=True)
    src = (SUITE / "riscv-test-suite" / "env" / "arch_test.h").read_text()
    n = src.count(".option rvc")
    (PATCHED_ENV / "arch_test.h").write_text(src.replace(".option rvc", ".option norvc"))
    return n


def all_tests():
    return sorted(p.stem for p in SRC.glob("*.S") if p.stem not in EXCLUDED)


def fetch():
    if SUITE.exists():
        print(f"{SUITE} already exists")
        return
    subprocess.run(["git", "clone", "--depth", "1", "--branch", TAG, URL, str(SUITE)], check=True)


def compile_test(test, env, out):
    out.parent.mkdir(parents=True, exist_ok=True)
    cmd = [CC, *CFLAGS, "-T", str(HERE / env / "link.ld"), "-I", str(HERE / env),
           "-I", str(PATCHED_ENV), "-I", str(SUITE / "riscv-test-suite" / "env"),
           str(SRC / f"{test}.S"), "-o", str(out)]
    subprocess.run(cmd, check=True)


def build(tests):
    for t in tests:
        elf = BUILD / t / f"{t}.elf"
        compile_test(t, "env_soc", elf)
        subprocess.run([sys.executable, str(TOOLS / "gen_mem.py"), str(elf), "--out-dir", str(elf.parent),
                        "--name", t, "--imem-bytes", str(ARCH_IMEM_BYTES), "--dmem-bytes", str(ARCH_DMEM_BYTES)],
                       check=True, stdout=subprocess.DEVNULL)
        print(f"built {t}")


def refs(tests):
    sail = shutil.which("sail_riscv_sim")
    if not sail:
        sys.exit("sail_riscv_sim not on PATH")
    REFS.mkdir(exist_ok=True)
    for t in tests:
        elf = BUILD / "sail" / f"{t}.elf"
        compile_test(t, "env_sail", elf)
        sig = REFS / f"{t}.reference_output"
        subprocess.run([sail, "--rv32", "--test-signature", str(sig), "--signature-granularity", "4",
                        "--inst-limit", "2000000", str(elf)], check=True, stdout=subprocess.DEVNULL)
        print(f"reference {t}: {len(sig.read_text().split())} words")


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("fetch", "build", "refs"):
        sys.exit(__doc__)
    if sys.argv[1] == "fetch":
        return fetch()
    tests = sys.argv[2:] or all_tests()
    patch_env()
    (build if sys.argv[1] == "build" else refs)(tests)


if __name__ == "__main__":
    main()
