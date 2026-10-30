"""Checking a DUT against a recorded reference trace (provided).

A trace is a list of retirement records [pc, insn, rd, rd_wdata, wmask,
mem_addr, mem_wdata, trap], one per retired instruction, recorded from the
instructor's reference model. The checker compares the DUT's RVFI output
with it, one instruction at a time, and stops at the first difference.
"""
import json

from .iss import Retire


def record(r: Retire):
    lanes = sum(0xFF << 8 * k for k in range(4) if r.wmask >> k & 1)
    return [r.pc, r.insn, r.rd, r.rd_wdata, r.wmask,
            r.mem_addr if (r.wmask or r.rmask) else 0, r.mem_wdata & lanes, int(r.trap)]


FIELDS = ["pc", "insn", "rd", "rd_wdata", "wmask", "mem_addr", "mem_wdata (written lanes)", "trap"]


class TraceChecker:
    def __init__(self, expected):
        self.expected = expected
        self.count = 0

    def __call__(self, r: Retire):
        if self.count >= len(self.expected):
            last = self.expected[-1]
            if last[4] and last[5] == 0x300000FC:
                return        # the program already halted; the core keeps running
            raise AssertionError(f"the core retired more instructions than expected "
                                 f"({len(self.expected)}); extra: {r.describe()}")
        exp = list(self.expected[self.count])
        got = record(r)
        if exp[1] is None:          # instruction word withheld (hand-assembly answers)
            got[1] = None
        if r.trap or exp[7]:
            got, exp = got[:2] + got[7:], exp[:2] + exp[7:]
            names = FIELDS[:2] + FIELDS[7:]
        else:
            names = FIELDS
        if got != exp:
            diffs = [f"{n}: expected 0x{e:x}, got 0x{g:x}" for n, e, g in zip(names, exp, got)
                     if e != g and e is not None]
            raise AssertionError(
                f"instruction #{self.count} (pc 0x{exp[0]:08x}) differs from the reference"
                + (" - check its encoding: " if exp[1] is None else ": ")
                + "; ".join(diffs) + f"\n  DUT retired: {r.describe()}")
        self.count += 1

    def finished(self):
        return self.count == len(self.expected)


def load(path):
    with open(path) as f:
        return json.load(f)
