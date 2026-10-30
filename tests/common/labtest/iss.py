"""RV32I instruction-set simulator: the golden model for lockstep checking.

Models exactly the architectural behaviour the lab SoC promises:
  * RV32I only. ECALL, EBREAK, illegal encodings, misaligned loads/stores and
    taken jumps/branches to non-4-byte-aligned targets trap. A trap does not
    change any state and the hart halts.
  * FENCE is a no-op.
  * Harvard memory map (see the manual's memory-map appendix):
      0x0xxx_xxxx IMEM  - instruction fetch only (aliased modulo its size); data accesses read 0 and
                          writes are ignored
      0x1xxx_xxxx DMEM  - aliased modulo its size
      0x2xxx_xxxx FB    - first 19200 bytes; anything above reads 0
      0x3000_00xx MMIO  - loads take their value from a callback (in lockstep
                          the DUT's own read data, because switches and cycle
                          counters cannot be predicted)
"""
from dataclasses import dataclass, field

from .models import decode_imm, to_signed  # noqa: F401  (your Lab 2 model)

ALL_MNEMONICS = [
    "add", "sub", "sll", "slt", "sltu", "xor", "srl", "sra", "or", "and",
    "addi", "slti", "sltiu", "xori", "ori", "andi", "slli", "srli", "srai",
    "lb", "lh", "lw", "lbu", "lhu", "sb", "sh", "sw",
    "beq", "bne", "blt", "bge", "bltu", "bgeu",
    "lui", "auipc", "jal", "jalr", "fence", "ecall", "ebreak",
]


def mnemonic(word):
    """Return the mnemonic (a member of ALL_MNEMONICS) of a 32-bit RV32I
    instruction word, or None if the word is not a legal RV32I encoding."""
    # TODO (Lab 6, Task 6.2): decode opcode, funct3 and funct7 exactly as the
    # spec's instruction listing defines them. Reuse what you learnt in Lab 3,
    # but write it from the spec again: this is the golden model.
    raise NotImplementedError("mnemonic: Lab 6, Task 6.2")

MASK = 0xFFFF_FFFF
FB_BYTES = 160 * 120
MMIO_BASE = 0x3000_0000
SIM_PUTC, SIM_SIG, SIM_HALT = 0x3000_00F0, 0x3000_00F4, 0x3000_00FC


def s32(x):
    x &= MASK
    return x - (1 << 32) if x & 0x8000_0000 else x


@dataclass
class Retire:
    """One retired instruction, in the same form as the RVFI trace port."""
    order: int
    pc: int
    insn: int
    next_pc: int
    trap: bool = False
    rd: int = 0
    rd_wdata: int = 0
    mem_addr: int = 0      # word aligned
    rmask: int = 0
    wmask: int = 0
    mem_wdata: int = 0     # bus lanes
    mem_rdata: int = 0     # bus lanes (only meaningful under rmask)
    mnemonic: str = ""

    def describe(self):
        s = f"#{self.order} pc=0x{self.pc:08x} insn=0x{self.insn:08x} ({self.mnemonic or '?'})"
        if self.trap:
            return s + " TRAP"
        if self.rd:
            s += f" x{self.rd}<=0x{self.rd_wdata:08x}"
        if self.wmask:
            s += f" mem[0x{self.mem_addr:08x}] wmask={self.wmask:04b} wdata=0x{self.mem_wdata:08x}"
        if self.rmask:
            s += f" mem[0x{self.mem_addr:08x}] rmask={self.rmask:04b}"
        return s + f" -> pc=0x{self.next_pc:08x}"


@dataclass
class Memory:
    imem_bytes: int = 256 * 1024   # must match soc_tb's IMEM_WORDS * 4
    dmem_bytes: int = 64 * 1024    # must match soc_tb's DMEM_WORDS * 4
    imem: bytearray = field(default=None)
    dmem: bytearray = field(default=None)
    fb: bytearray = field(default=None)
    mmio_read: object = None   # callable(addr) -> 32-bit word

    def __post_init__(self):
        self.imem = self.imem or bytearray(self.imem_bytes)
        self.dmem = self.dmem or bytearray(self.dmem_bytes)
        self.fb = self.fb or bytearray(FB_BYTES)
        self.mmio_regs = {}

    # -- loading ------------------------------------------------------------
    def load_words(self, region, words):
        buf = self.imem if region == "imem" else self.dmem
        for i, w in enumerate(words):
            buf[4 * i:4 * i + 4] = (w & MASK).to_bytes(4, "little")

    def load_hex(self, region, path):
        words = []
        with open(path) as f:
            for ln in f:
                ln = ln.strip()
                if ln and not ln.startswith("#"):
                    words.append(int(ln, 16))
        self.load_words(region, words)

    # -- access -------------------------------------------------------------
    def fetch(self, addr):
        a = (addr & MASK) % self.imem_bytes
        return int.from_bytes(self.imem[a & ~3:(a & ~3) + 4], "little")

    def read_word(self, waddr):
        region = waddr >> 28
        if region == 1:
            a = (waddr & 0x0FFF_FFFF) % self.dmem_bytes
            return int.from_bytes(self.dmem[a:a + 4], "little")
        if region == 2:
            a = waddr & 0x0FFF_FFFF
            return int.from_bytes(self.fb[a:a + 4], "little") if a < FB_BYTES else 0
        if region == 3 and (waddr & 0x0FFF_FF00) == 0:
            if self.mmio_read is not None:
                return self.mmio_read(waddr) & MASK
            return self.mmio_regs.get(waddr, 0)
        return 0

    def write_word(self, waddr, wdata, wmask):
        region = waddr >> 28
        if region == 1:
            buf, a = self.dmem, (waddr & 0x0FFF_FFFF) % self.dmem_bytes
        elif region == 2 and (waddr & 0x0FFF_FFFF) < FB_BYTES:
            buf, a = self.fb, waddr & 0x0FFF_FFFF
        elif region == 3 and (waddr & 0x0FFF_FF00) == 0:
            old = self.mmio_regs.get(waddr, 0)
            for k in range(4):
                if wmask >> k & 1:
                    old = (old & ~(0xFF << 8 * k)) | (wdata & (0xFF << 8 * k))
            self.mmio_regs[waddr] = old
            return
        else:
            return
        for k in range(4):
            if wmask >> k & 1:
                buf[a + k] = (wdata >> 8 * k) & 0xFF


class Hart:
    def __init__(self, mem=None, reset_pc=0):
        self.mem = mem or Memory()
        self.x = [0] * 32
        self.pc = reset_pc
        self.order = 0
        self.halted = False
        self.counts = {m: 0 for m in ALL_MNEMONICS}

    def step(self, mmio_rdata=None):
        """Execute one instruction and return its :class:`Retire` record.
        ``mmio_rdata`` overrides the value of an MMIO load (lockstep mode)."""
        if self.halted:
            raise RuntimeError("hart is halted")
        pc = self.pc
        w = self.mem.fetch(pc)
        mn = mnemonic(w)
        r = Retire(order=self.order, pc=pc, insn=w, next_pc=pc, mnemonic=mn or "")
        self.order += 1
        if mn is None or mn in ("ecall", "ebreak"):
            return self._trap(r)
        # TODO (Lab 6, Task 6.3): execute instruction 'mn'.
        #   * Read rs1/rs2 from self.x; never write x0.
        #   * Compute the next pc; a taken branch/jump to a target that is
        #     not 4-byte aligned traps (return self._trap(r)) - check the spec.
        #   * Loads/stores: check alignment (trap if misaligned), access memory
        #     through self.mem.read_word()/write_word() with WORD addresses and
        #     byte-lane masks, and fill r.mem_addr, r.rmask/r.wmask,
        #     r.mem_wdata/r.mem_rdata exactly as the RVFI port reports them
        #     (lab sheet, RVFI table). Use mmio_rdata for MMIO loads if given.
        #   * Fill r.rd / r.rd_wdata for register writes (rd = 0: leave 0).
        #   * Set self.pc = r.next_pc and count self.counts[mn] += 1.
        raise NotImplementedError("Hart.step: Lab 6, Task 6.3")

    def _trap(self, r):
        r.trap = True
        r.next_pc = r.pc
        self.halted = True
        return r

    def run(self, max_steps=1_000_000):
        """Run until a SIM_HALT store, a trap or ``max_steps``. Returns
        (exit_code or None, console text, signature words, retire list length)."""
        console, sig = [], []
        for _ in range(max_steps):
            r = self.step()
            if r.trap:
                return None, "".join(console), sig
            if r.wmask and r.mem_addr in (SIM_PUTC, SIM_SIG, SIM_HALT):
                if r.mem_addr == SIM_PUTC:
                    console.append(chr(r.mem_wdata & 0xFF))
                elif r.mem_addr == SIM_SIG:
                    sig.append(r.mem_wdata)
                else:
                    return r.mem_wdata, "".join(console), sig
        raise TimeoutError(f"ISS did not halt within {max_steps} steps (pc=0x{self.pc:08x})")
