"""Building the lab software from the tests (needs riscv-none-elf-gcc on PATH)."""
import shutil
import subprocess

from .runner import REPO

SW = REPO / "sw"


def build(lab_dir, makefile="Makefile", target="all", extra=()):
    """Run make in sw/<lab_dir>. Fails the test with the compiler output if
    the build fails."""
    if shutil.which("riscv-none-elf-gcc") is None:
        raise AssertionError("riscv-none-elf-gcc is not on PATH (see README: toolchain install)")
    cmd = ["make", "--no-print-directory", "-f", makefile, target, *extra]
    p = subprocess.run(cmd, cwd=SW / lab_dir, capture_output=True, text=True)
    if p.returncode != 0:
        raise AssertionError(f"build failed in sw/{lab_dir}:\n{p.stdout}\n{p.stderr}")
    return p.stdout


def images(lab_dir, prog, build_dir=None):
    """Paths of the IMEM and DMEM hex images of a built program."""
    d = SW / lab_dir / (build_dir or f"build/{prog}")
    return d / f"{prog}.imem.hex", d / f"{prog}.dmem.hex"
