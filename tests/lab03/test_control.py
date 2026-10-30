"""Lab 3 - main decoder + ALU control.

The provided test feeds each instruction to tb_control (your decoder and ALU
control wired together), passes the control signals through
datapath_model.execute() (which knows only what each control signal MEANS),
and compares the architectural effect with the value given in
control_cases.json. Only the effect is checked - your control encodings and
table are your own.

Yours (Task 6): illegal_encodings, plus random legal instructions built with
your encode_imm and checked the same way.
"""
import json
import os

import cocotb
from cocotb.triggers import Timer

from datapath_model import LOAD_DATA, Controls, execute
from labtest.checks import resolved
from labtest.models import ALU_OPS, alu_model, decode_imm
from labtest.runner import run

HERE = os.path.dirname(os.path.abspath(__file__))
FIELDS = ["reg_write", "src_a", "src_b", "alu_class", "imm_sel", "res_src", "mem_read",
          "mem_write", "branch", "jump", "illegal", "alu_op"]
OP_NAME = {v: k for k, v in ALU_OPS.items()}
FMT = {0: "I", 1: "S", 2: "B", 3: "U", 4: "J"}


async def controls_for(dut, word):
    dut.instr.value = word
    await Timer(1, unit="ns")
    return Controls(**{f: resolved(getattr(dut, f), f) for f in FIELDS})


@cocotb.test()
async def directed_effects(dut):
    with open(os.path.join(HERE, "control_cases.json")) as f:
        cases = json.load(f)
    for c in cases:
        ctx = f"'{c['asm']}' (0x{c['word']:08x}), pc=0x{c['pc']:08x}, rs1=0x{c['rs1']:08x}, rs2=0x{c['rs2']:08x}"
        ctl = await controls_for(dut, c["word"])
        assert ctl.illegal == 0, f"illegal asserted for a legal instruction: {ctx}"
        assert ctl.alu_op in OP_NAME, f"alu_op {ctl.alu_op:04b} is not an ALU_* encoding: {ctx}"
        assert ctl.imm_sel in FMT or not ctl.src_b, f"imm_sel {ctl.imm_sel:03b} is not an IMM_* encoding: {ctx}"
        taken = c["next_pc"] != (c["pc"] + 4) & 0xFFFF_FFFF
        eff = execute(ctl, c["pc"], c["rs1"], c["rs2"],
                      lambda s: decode_imm(c["word"], FMT[s]) if s in FMT else 0,
                      lambda op, a, b: alu_model(OP_NAME[op], a, b), lambda: taken)
        assert eff.next_pc == c["next_pc"], \
            f"next pc 0x{eff.next_pc:08x}, expected 0x{c['next_pc']:08x}: {ctx}"
        if c["is_load"]:
            assert eff.mem_read_addr is not None and eff.mem_read_addr & ~3 == c["mem_word_addr"], \
                f"load: mem_read not asserted or wrong address: {ctx}"
            assert eff.rd_value == LOAD_DATA, f"load: result not taken from memory: {ctx}"
        else:
            assert eff.mem_read_addr is None, f"mem_read asserted for a non-load: {ctx}"
        if c["is_store"]:
            assert eff.mem_write_addr is not None and eff.mem_write_addr & ~3 == c["mem_word_addr"], \
                f"store: mem_write not asserted or wrong address: {ctx}"
        else:
            assert eff.mem_write_addr is None, f"mem_write asserted for a non-store: {ctx}"
        if not c["writes_rd"] and not c["is_load"]:
            assert eff.rd_value is None, f"reg_write asserted for an instruction that writes no register: {ctx}"
        elif not c["is_load"]:
            assert eff.rd_value == c["rd_value"], \
                f"rd = 0x{(eff.rd_value or 0):08x}, expected 0x{c['rd_value']:08x}: {ctx}"


@cocotb.test()
async def illegal_encodings(dut):
    """TODO (Lab 3, Task 3.6): list encodings that are NOT implemented RV32I
    instructions (think: ECALL/EBREAK, CSR instructions, M-extension ops,
    RV64-only loads/stores, reserved funct3/funct7 values, compressed
    encodings) and check that 'illegal' is 1 and that no state change is
    requested (reg_write, mem_read, mem_write, branch, jump all 0)."""
    raise NotImplementedError("illegal_encodings: Lab 3, Task 3.6")


def test_control():
    run("tb_control", "test_control", extra_sources=["sim/tb_control.vhd"],
        testcase=os.environ.get("TESTCASE"))
