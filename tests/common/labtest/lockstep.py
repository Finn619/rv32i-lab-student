"""Lockstep comparison of the DUT's RVFI trace against the ISS."""
from collections import deque

from .iss import Hart

MMIO_REGION = 3


class LockstepError(AssertionError):
    pass


class Lockstep:
    """Callable used as ``SocHarness.run(on_retire=...)``. Every retirement
    reported by the DUT is checked against one ISS step."""

    def __init__(self, hart: Hart, history=8, coverage=None):
        self.hart = hart
        self.history = deque(maxlen=history)
        self.count = 0
        self.coverage = coverage

    def __call__(self, dut):
        # Values read from MMIO cannot be predicted (switches, cycle counter):
        # the ISS is told what the DUT read.
        mmio = dut.mem_rdata if dut.rmask and (dut.mem_addr >> 28) == MMIO_REGION else None
        if self.hart.halted:
            raise LockstepError(f"DUT retired an instruction after the ISS trapped:\n  dut {dut.describe()}")
        ref = self.hart.step(mmio_rdata=mmio)
        dut.mnemonic = ref.mnemonic
        problems = self.compare(dut, ref)
        if problems:
            past = "\n".join("  " + r.describe() for r in self.history) or "  (none)"
            raise LockstepError(
                f"Lockstep mismatch at instruction {self.count}: {', '.join(problems)}\n"
                f"  expected (ISS): {ref.describe()}\n"
                f"  actual   (DUT): {dut.describe()}\n"
                f"previous instructions:\n{past}")
        self.history.append(ref)
        self.count += 1
        if self.coverage is not None:
            self.coverage.sample(ref, self.hart)

    @staticmethod
    def compare(d, r):
        p = []
        if d.order != r.order:
            p.append(f"order {d.order} != {r.order}")
        if d.pc != r.pc:
            p.append("pc")
        if d.insn != r.insn:
            p.append("insn")
        if d.trap != r.trap:
            p.append("trap")
        if r.trap:
            return p
        if d.next_pc != r.next_pc:
            p.append("next pc")
        if (d.rd, d.rd_wdata) != (r.rd, r.rd_wdata):
            p.append("rd write")
        if d.wmask != r.wmask or d.rmask != r.rmask:
            p.append("memory masks")
        if (d.wmask or d.rmask) and d.mem_addr != r.mem_addr:
            p.append("memory address")
        if d.wmask:
            lanes = sum(0xFF << 8 * k for k in range(4) if d.wmask >> k & 1)
            if d.mem_wdata & lanes != r.mem_wdata & lanes:
                p.append("store data")
        return p
