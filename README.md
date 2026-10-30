## Preamble

As an EE student that hasn't been able to take any in-depth computer architecture classes, I wanted to explore the world of CPU architecture through my own project. With the help of my lovely friend Claude, I was able to break down the basic development process of CPU using the RISC-V ISA into a 9 lab program to give some further structure to the development process. This lab series was designed to be written in VHDL. The automated tests use CocoTB and the final deploy is aimed at the Basys-3 or DE-10 Lite FPGAs. The labs are helping me learn with a more focussed approach compared to my typical distraction marathon of jumping down rabbit holes on the internet. I hope these prove useful to anyone who stumbles across them. The lab guide is in PDF form in this repo, and all materials were designed for development on either Windows or Rocky Linux.

# RV32I in VHDL – student repository

You will design a 32-bit RISC-V CPU (RV32I) in VHDL, verify it with cocotb and
run it on a Terasic DE10-Lite or a Digilent Basys 3. The lab manual
(`lab-manual.pdf`) tells you what to build in each lab. This README tells you how
to install the tools and run things.

## Contents

| Path | What it is |
|---|---|
| `rtl/core/`, `rtl/mem/`, `rtl/periph/`, `rtl/soc/` | VHDL design. Entities are given: **do not change any port**. Architectures marked `TODO` are yours. `cpu_pkg.vhd`, `prog_image_pkg.vhd`, `clkgen.vhd` and `soc.vhd` are provided complete. |
| `rtl/sources.f` | compile order of the synthesisable files (used by the tests and the vendor scripts) |
| `boards/de10lite/`, `boards/basys3/` | board wrapper skeletons (yours), PLL/MMCM wrappers (provided) and constraint files with every pin filled in (`.qsf`/`.sdc`, `.xdc`) |
| `sim/` | **simulation-only** VHDL: testbench tops, a behavioural clock model, a package body that loads programs from hex files. Never add these to a synthesis project. |
| `lab0/` | the Lab 0 counter and its board tops (complete) |
| `tests/` | cocotb tests, one folder per lab; `tests/common/labtest/` holds shared helpers and the Python models you write (`models.py`, `iss.py`, `randgen.py`, `coverage.py`) |
| `sw/` | software: `common/` (linker script, `crt0.S`, `mmio.h`), one folder per lab |
| `arch-test/` | riscv-arch-test integration and the reference signatures (Lab 6) |
| `golden/` | golden images for the Lab 8 VGA tests |
| `scripts/` | Vivado and Quartus project-creation scripts |
| `tools/` | `gen_mem.py` (ELF → memory images), `vhdl_lint.py` (checks the portable VHDL subset) |

## Installation

You need:

* Python 3.10 or later, with the packages in `requirements.txt` (cocotb 2.0)
* GHDL (LLVM or mcode backend) **and** NVC (version 1.11 or later)
* GNU Make and Git
* the xPack GNU RISC-V embedded GCC, `riscv-none-elf-gcc` (version 14 or 15)
* a waveform viewer: GTKWave or Surfer
* for your board: AMD Vivado 2024.1 or 2026.1 (Basys 3), or Intel Quartus Prime
  Lite (DE10-Lite), with the MAX 10 device support

Vivado's own simulator and Questa are **not** used for the tests: cocotb does
not support xsim. Intel users may use Questa for debugging if they like.

### Rocky Linux 9

```bash
sudo dnf install -y epel-release
sudo dnf config-manager --set-enabled crb
sudo dnf install -y git make gcc gcc-c++ python3.12 python3.12-pip gtkwave
```

**GHDL and Yosys:** the simplest route is the OSS CAD Suite, a prebuilt bundle
that includes GHDL:

```bash
mkdir -p ~/opt && cd ~/opt
# download oss-cad-suite-linux-x64-<date>.tgz from
# https://github.com/YosysHQ/oss-cad-suite-build/releases, then:
tar xzf oss-cad-suite-linux-x64-*.tgz
echo 'export PATH="$HOME/opt/oss-cad-suite/bin:$PATH"' >> ~/.bashrc
```

**NVC:** build it from a release tarball (https://github.com/nickg/nvc/releases):

```bash
sudo dnf install -y llvm-devel libffi-devel zlib-devel libzstd-devel flex \
                    automake autoconf check-devel elfutils-devel
tar xzf nvc-1.*.tar.gz && cd nvc-1.*/ && mkdir build && cd build
../configure && make -j$(nproc) && sudo make install
```

**RISC-V GCC:** download `xpack-riscv-none-elf-gcc-<version>-linux-x64.tar.gz`
from https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases, then:

```bash
tar xzf xpack-riscv-none-elf-gcc-*-linux-x64.tar.gz -C ~/opt
echo 'export PATH="$HOME/opt/xpack-riscv-none-elf-gcc-<version>/bin:$PATH"' >> ~/.bashrc
```

**Python packages**, in a virtual environment inside the repository:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Vendor tools and USB access.**

* Vivado: run the AMD unified installer, then install the cable drivers with
  `sudo <Vivado>/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers`.
* Quartus Prime Lite: run the installer, including MAX 10 device support. The
  DE10-Lite's on-board USB-Blaster then needs a udev rule:
  ```bash
  echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"' | \
    sudo tee /etc/udev/rules.d/51-usbblaster.rules
  sudo udevadm control --reload-rules
  ```
  Unplug the board and plug it back in.

### Windows 10/11

Use **WSL2** for simulation and the RISC-V toolchain, and native Windows for
the vendor tools and for programming the board.

1. In PowerShell (as administrator): `wsl --install -d Ubuntu-24.04`, then restart.
2. In the Ubuntu terminal:
   ```bash
   sudo apt update
   sudo apt install -y git make gcc python3-venv ghdl gtkwave
   ```
   Install NVC from the `.deb` on its releases page
   (`sudo apt install ./nvc_*.deb`). Install the xPack toolchain from its
   `linux-x64` tarball, as for Rocky Linux. Create the Python virtual
   environment as above.
3. Clone this repository **inside** the WSL file system (for example
   `~/rv32i-lab`); simulation is much slower on `/mnt/c`.
4. Install Vivado or Quartus Prime Lite on Windows, with their USB drivers. To
   build the FPGA project, either open the WSL folder from Windows
   (`\\wsl$\Ubuntu-24.04\home\<you>\rv32i-lab`; this works for Vivado), or keep
   a second clone on the Windows side and pull your changes with Git (this is
   safer for Quartus, which handles UNC paths poorly).

A native Windows set-up (MSYS2 UCRT64 packages `ghdl-llvm` and `python`, the
NVC Windows installer, and the xPack `win32-x64` zip) also works for many
students, but it is not supported by the lab staff.

### Check your installation

```bash
ghdl --version && nvc --version && riscv-none-elf-gcc --version
python3 -c "import cocotb; print(cocotb.__version__)"
make test LAB=0              # three passing tests
make test LAB=0 SIM=nvc
```

## Everyday commands

```bash
make test LAB=1                       # run Lab 1's tests with GHDL
make test LAB=1 SIM=nvc               # ... with NVC
make test LAB=3 TESTCASE=directed_effects   # one cocotb test
make test LAB=4 K=branch_unit         # only pytest cases whose name contains 'branch_unit'
make test LAB=2 WAVES=1               # also write waveforms (sim_build/<sim>/<toplevel>/)
make elab                             # analyse and elaborate everything (quick syntax check)
python3 tools/vhdl_lint.py rtl boards # check the portable VHDL subset
make sw                               # build all software
make arch-test-fetch                  # Lab 6: download riscv-arch-test 3.10.0
LOCKSTEP=1 make test LAB=5            # Lab 6 onwards: compare every instruction with your ISS
make vivado   # or: make quartus      # Lab 7: create the FPGA project for the board test
```

The tests print a clear message when they fail. A message saying that a signal
"is not a valid 0/1 value" means an output of your design is undriven (`'U'`)
or in conflict (`'X'`).

### Building the FPGA design

```bash
make -C sw/lab07                      # builds the program and its prog_image_body.vhd
vivado -mode batch -source scripts/vivado/create_project.tcl -tclargs \
       sw/lab07/build/board_test/prog_image_body.vhd build
quartus_sh -t scripts/quartus/create_project.tcl \
       sw/lab07/build/board_test/prog_image_body.vhd compile
```

To put a different program on the board, pass that program's
`prog_image_body.vhd` instead (for example
`sw/lab08/build/cube_demo/prog_image_body.vhd`).

> The project scripts and constraint files have not yet been run with the
> vendor tools by the lab authors (see the note from your instructor). Report
> any problem you find.

## Licence and credits

The licence for this repository is in [`LICENSE`](LICENSE). Some files contain
third-party material under their own licences. The notices are in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md):

* Basys 3 pin constraints from Digilent's
  [digilent-xdc](https://github.com/Digilent/digilent-xdc) (MIT).
* Target files and reference signatures for the
  [RISC-V architectural tests](https://github.com/riscv/riscv-arch-test)
  (BSD-3-Clause / Apache-2.0). The signatures were generated with the
  [Sail RISC-V model](https://github.com/riscv/sail-riscv).
* Diagram fonts Source Sans 3 and Source Code Pro (SIL Open Font Licence 1.1),
  embedded in the lab manual's diagrams.

The labs are written against *The RISC-V Instruction Set Manual, Volume I:
Unprivileged Architecture* (version 20250508), the RISC-V ELF psABI (v1.0) and
the RISC-V Assembly Programmer's Manual, all by RISC-V International and
contributors. The specifications are cited, not redistributed. DE10-Lite pin
assignments were checked against Terasic's DE10-Lite pin documentation and
schematic. cocotb, GHDL, NVC, Yosys and the xPack GNU RISC-V toolchain are
used as tools and are not included.
