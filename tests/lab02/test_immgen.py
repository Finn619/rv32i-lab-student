"""Lab 2 - immediate generator tests.

Provided: imm_directed (fixed words from imm_vectors.json).
Yours:    imm_encoded_extremes and imm_random (Tasks 5 and 6), using YOUR
          encode_imm/decode_imm in labtest/models.py.
"""
import json
import os

import cocotb
from cocotb.triggers import Timer

from labtest.checks import check
from labtest.models import decode_imm, encode_imm  # noqa: F401
from labtest.runner import run

HERE = os.path.dirname(os.path.abspath(__file__))
SEL = {"I": 0b000, "S": 0b001, "B": 0b010, "U": 0b011, "J": 0b100}


async def apply(dut, fmt, word):
    dut.instr.value = word
    dut.imm_sel.value = SEL[fmt]
    await Timer(1, unit="ns")


@cocotb.test()
async def imm_directed(dut):
    with open(os.path.join(HERE, "imm_vectors.json")) as f:
        vectors = json.load(f)
    for v in vectors:
        await apply(dut, v["format"], v["word"])
        check(dut.imm, v["imm"], f"imm ({v['format']}-type)", f"instr=0x{v['word']:08x}")


@cocotb.test()
async def imm_encoded_extremes(dut):
    """TODO (Lab 2, Task 2.5): for every format, encode the largest and
    smallest legal immediates (and a few patterns such as alternating bits)
    with encode_imm, drive the word, and check the generator returns them."""
    raise NotImplementedError("imm_encoded_extremes: Lab 2, Task 2.5")


@cocotb.test()
async def imm_random(dut):
    """TODO (Lab 2, Task 2.6): random 32-bit words in every format, compared
    with decode_imm. Also check decode_imm(encode_imm(...)) round-trips."""
    raise NotImplementedError("imm_random: Lab 2, Task 2.6")


def test_immgen():
    run("immgen", "test_immgen", testcase=os.environ.get("TESTCASE"))
