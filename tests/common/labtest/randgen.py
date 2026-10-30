"""Constrained-random RV32I program generator (Lab 6, Task 6.5) - YOURS.

Generate programs that are always legal and always terminate, yet exercise
as much of the ISA as possible. The provided test (tests/lab06/test_random.py)
runs each program on core_tb in lockstep with your ISS and collects your
coverage.

Constraints you must enforce (explain each one in your report):
  * a base register holding a DMEM address that random instructions never
    overwrite, used by every load and store, with offsets that keep each
    access naturally aligned and inside DMEM;
  * branches and jumps only go FORWARD to an instruction inside the program
    (no infinite loops), and never into the middle of a multi-instruction
    sequence you emit (e.g. the set-up of a JALR target);
  * the program ends by storing to SIM_HALT (0x300000FC).

Encode instructions with your encode_imm() from labtest.models.
"""
import random

from .models import encode_imm  # noqa: F401


class RandomProgram:
    def __init__(self, seed, length=400):
        self.rng = random.Random(seed)
        self.length = length

    def generate(self):
        """Return the program as a list of 32-bit instruction words, to be
        loaded at address 0."""
        # TODO (Lab 6, Task 6.5)
        raise NotImplementedError("RandomProgram.generate: Lab 6, Task 6.5")
