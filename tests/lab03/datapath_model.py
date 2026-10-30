"""Abstract model of the single-cycle datapath *wiring* (Lab 3).

Given the control signals a decoder produced, this computes what the datapath
would do with them. It encodes only what each control signal *means* (the
interface in cpu_pkg), not which instructions need which values - that is the
table you derive.
"""
from dataclasses import dataclass

SRC_A = {0b00: "rs1", 0b01: "pc", 0b10: "zero"}
RES = {0b00: "alu", 0b01: "mem", 0b10: "pc4"}
LOAD_DATA = 0x10AD_DA7A   # stands in for whatever the memory returns


@dataclass
class Controls:
    reg_write: int
    src_a: int
    src_b: int
    alu_class: int
    imm_sel: int
    res_src: int
    mem_read: int
    mem_write: int
    branch: int
    jump: int
    illegal: int
    alu_op: int


@dataclass
class Effect:
    rd_value: int = None     # None: no register written
    next_pc: int = 0
    mem_read_addr: int = None
    mem_write_addr: int = None
    mem_write_data: int = None


def execute(c, pc, rs1, rs2, imm_of, alu_of, branch_cond):
    """imm_of(imm_sel) -> immediate; alu_of(op, a, b) -> result;
    branch_cond() -> True if this instruction's branch condition holds."""
    imm = imm_of(c.imm_sel)
    a = {"rs1": rs1, "pc": pc, "zero": 0}[SRC_A.get(c.src_a, "rs1")]
    b = imm if c.src_b else rs2
    y = alu_of(c.alu_op, a, b) & 0xFFFF_FFFF
    e = Effect()
    taken = c.jump or (c.branch and branch_cond())
    # Clearing bit 0 is what JALR requires; for branch and JAL targets bit 0 is
    # already 0, so applying it to every taken target is harmless here.
    e.next_pc = (y & ~1) if taken else (pc + 4) & 0xFFFF_FFFF
    if c.mem_read:
        e.mem_read_addr = y
    if c.mem_write:
        e.mem_write_addr, e.mem_write_data = y, rs2
    if c.reg_write:
        e.rd_value = {"alu": y, "mem": LOAD_DATA, "pc4": (pc + 4) & 0xFFFF_FFFF}[RES.get(c.res_src, "alu")]
    return e
