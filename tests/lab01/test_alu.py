"""Lab 1 - ALU tests.

Provided: alu_directed (fixed vectors from alu_vectors.json).
Yours:    alu_random - constrained-random operands checked against YOUR
          alu_model in labtest/models.py (Task 4), and any edge-case tests
          you add (Task 5).

    make test LAB=1                  # all of them
    make test LAB=1 TESTCASE=alu_directed
"""
import json
import os

import cocotb
from cocotb.triggers import Timer

from labtest.checks import check
from labtest.models import ALU_OPS, alu_model  # noqa: F401
from labtest.runner import run

HERE = os.path.dirname(os.path.abspath(__file__))


async def apply(dut, op, a, b):
    """Drive one operation and wait for the combinational result."""
    dut.op.value = ALU_OPS[op]
    dut.a.value = a
    dut.b.value = b
    await Timer(1, unit="ns")


@cocotb.test()
async def alu_directed(dut):
    """Fixed vectors: every operation on a few operand pairs."""
    with open(os.path.join(HERE, "alu_vectors.json")) as f:
        vectors = json.load(f)
    for v in vectors:
        await apply(dut, v["op"], v["a"], v["b"])
        check(dut.y, v["y"], f"alu {v['op']}", f"a=0x{v['a']:08x} b=0x{v['b']:08x}")


@cocotb.test()
async def alu_random(dut):
    """TODO (Lab 1, Task 1.4): at least 2000 random operations, compared with
    alu_model(). Bias the operands towards interesting values (which ones,
    and why?). Use a fixed seed so failures can be reproduced."""
    raise NotImplementedError("alu_random: Lab 1, Task 1.4")


def test_alu():
    run("alu", "test_alu", testcase=os.environ.get("TESTCASE"))
