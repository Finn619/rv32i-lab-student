"""Functional coverage of retired instructions (Lab 6, Task 6.6) - YOURS.

sample() is called by the lockstep checker for every retired instruction
(r is a labtest.iss.Retire; hart is your ISS after executing it). goals()
lists every bin you intend to hit; report() returns (text, missed bins).
Choose bins that would expose real bugs (lab sheet: "What to cover").
"""
from collections import Counter


class Coverage:
    def __init__(self):
        self.hits = Counter()      # keys: (mnemonic, bin name) tuples

    def sample(self, r, hart):
        # TODO (Lab 6, Task 6.6): record which bins this instruction hits,
        # e.g. self.hits[(r.mnemonic, "hit")] += 1
        raise NotImplementedError("Coverage.sample: Lab 6, Task 6.6")

    @staticmethod
    def goals():
        # TODO (Lab 6, Task 6.6): return a list of (mnemonic, bin name) tuples
        raise NotImplementedError("Coverage.goals: Lab 6, Task 6.6")

    def report(self):
        goals = self.goals()
        missed = [g for g in goals if self.hits[g] == 0]
        text = [f"Functional coverage: {len(goals) - len(missed)}/{len(goals)} bins"]
        text += [f"  missed: {m} {b}" for m, b in missed]
        return "\n".join(text), missed
