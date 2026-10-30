"""Program-running harness for the ``core_tb`` (Labs 4-6) and ``soc_tb``
(Labs 7-8) simulation top levels, which share their signal names.

``SocHarness.run()`` waits for the program to halt (SIM_HALT store), trap or
time out, while collecting console characters and signature words. When a
``on_retire`` callback is given, every retired instruction is read from the
RVFI port and passed to it as a :class:`labtest.iss.Retire` record.
"""
from dataclasses import dataclass, field
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, First, RisingEdge, ValueChange

from .checks import resolved
from .iss import Retire

SOC_TB_SOURCES = ["sim/soc_tb.vhd"]
CORE_TB_SOURCES = ["sim/core_tb.vhd"]


@dataclass
class RunResult:
    exit_code: int = None
    trapped: bool = False
    timed_out: bool = False
    console: str = ""
    signature: list = field(default_factory=list)
    cycles: int = 0
    retired: int = 0

    def summary(self):
        if self.timed_out:
            return f"timed out after {self.cycles} cycles"
        if self.trapped:
            return f"trapped after {self.cycles} cycles"
        return f"halted with exit code {self.exit_code} after {self.cycles} cycles"


def program_parameters(imem_hex, dmem_hex=None, **extra):
    """Generics for soc_tb that load the given hex images."""
    p = {"IMEM_INIT": str(Path(imem_hex).resolve())}
    if dmem_hex:
        p["DMEM_INIT"] = str(Path(dmem_hex).resolve())
    p.update(extra)
    return p


def read_retire(dut):
    """Read the RVFI port of soc_tb into a Retire record."""
    return Retire(
        order=resolved(dut.rvfi_order, "rvfi_order"),
        pc=resolved(dut.rvfi_pc_rdata, "rvfi_pc_rdata"),
        insn=resolved(dut.rvfi_insn, "rvfi_insn"),
        next_pc=resolved(dut.rvfi_pc_wdata, "rvfi_pc_wdata"),
        trap=bool(resolved(dut.rvfi_trap, "rvfi_trap")),
        rd=resolved(dut.rvfi_rd_addr, "rvfi_rd_addr"),
        rd_wdata=resolved(dut.rvfi_rd_wdata, "rvfi_rd_wdata"),
        mem_addr=resolved(dut.rvfi_mem_addr, "rvfi_mem_addr"),
        rmask=resolved(dut.rvfi_mem_rmask, "rvfi_mem_rmask"),
        wmask=resolved(dut.rvfi_mem_wmask, "rvfi_mem_wmask"),
        mem_wdata=resolved(dut.rvfi_mem_wdata, "rvfi_mem_wdata"),
        mem_rdata=int(dut.rvfi_mem_rdata.value) if dut.rvfi_mem_rdata.value.is_resolvable else 0,
    )


CLK_PERIOD_NS = 40   # 25 MHz


class SocHarness:
    """Starts the clock as soon as it is created."""

    def __init__(self, dut):
        self.dut = dut
        self._console = []
        self._signature = []
        cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, unit="ns").start())

    async def _watch_putc(self):
        while True:
            await ValueChange(self.dut.putc_toggle)
            self._console.append(chr(int(self.dut.putc_char.value)))

    async def _watch_sig(self):
        while True:
            await ValueChange(self.dut.sig_toggle)
            self._signature.append(int(self.dut.sig_word.value))

    async def _watch_trace(self, on_retire, counter):
        dut = self.dut
        while True:
            await FallingEdge(dut.clk)
            if dut.rst.value == 1:
                continue
            v = dut.rvfi_valid.value
            if not v.is_resolvable:
                raise AssertionError("rvfi_valid is not 0/1 after reset - is it driven?")
            if v == 1:
                counter[0] += 1
                on_retire(read_retire(dut))

    async def run(self, max_cycles=2_000_000, on_retire=None):
        """Call once per simulation, at the start of the test (the trace
        monitor must be running before reset is released)."""
        dut = self.dut
        tasks = [cocotb.start_soon(self._watch_putc()), cocotb.start_soon(self._watch_sig())]
        counter = [0]
        if on_retire is not None:
            tasks.append(cocotb.start_soon(self._watch_trace(on_retire, counter)))
        start = 0
        timeout = ClockCycles(dut.clk, max_cycles)
        fired = await First(RisingEdge(dut.halted), RisingEdge(dut.trap), timeout)
        # let the trace monitor see the final retirement
        await FallingEdge(dut.clk)
        await RisingEdge(dut.clk)
        for t in tasks:
            t.cancel()
        res = RunResult(console="".join(self._console), signature=list(self._signature),
                        cycles=int(dut.cycle.value) - start, retired=counter[0])
        if fired is timeout:
            res.timed_out = True
        elif dut.trap.value == 1:
            res.trapped = True
        else:
            res.exit_code = int(dut.exit_code.value)
        return res
