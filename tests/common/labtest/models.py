"""YOUR Python reference models (Labs 1, 2 and 6).

Write each model from the RISC-V specification, not from your VHDL: a model
that copies the design's mistakes cannot find them. Every function raises
NotImplementedError until you write it, so tests that depend on it fail
with a clear message.

All values are Python ints holding 32-bit patterns (0 .. 2**32-1) unless a
docstring says otherwise.
"""

MASK32 = 0xFFFF_FFFF

# ALU operation names -> encodings. These must match cpu_pkg.vhd.
ALU_OPS = {
    "ADD": 0b0000, "SUB": 0b0001, "AND": 0b0010, "OR": 0b0011, "XOR": 0b0100,
    "SLL": 0b0101, "SRL": 0b0110, "SRA": 0b0111, "SLT": 0b1000, "SLTU": 0b1001,
}


def to_signed(x, bits=32):
    """Interpret the low ``bits`` bits of x as two's complement."""
    x &= (1 << bits) - 1
    return x - (1 << bits) if x >> (bits - 1) else x


# ---------------------------------------------------------------- Lab 1
def alu_model(op, a, b):
    """Return the 32-bit result of ALU operation ``op`` (a key of ALU_OPS)
    applied to 32-bit operands a and b."""
    # TODO (Lab 1, Task 1.4): one case per operation. Hints: Python ints are
    # unbounded, so mask results with MASK32; use to_signed() where the
    # operation is signed; Python's >> on a negative int is arithmetic.
    raise NotImplementedError("alu_model: Lab 1, Task 1.4")


# ---------------------------------------------------------------- Lab 2
def decode_imm(word, fmt):
    """Return the sign-extended immediate (as a 32-bit pattern) of
    instruction ``word`` interpreted in format fmt ('I','S','B','U','J')."""
    # TODO (Lab 2, Task 2.5): from the spec figure in "Immediate Encoding
    # Variants". Extract fields with shifts and masks, reassemble them, then
    # sign-extend from the format's top bit.
    raise NotImplementedError("decode_imm: Lab 2, Task 2.5")


def encode_imm(fmt, imm, base_word=0):
    """Return ``base_word`` with the immediate fields of format fmt set to
    hold ``imm``, a Python int (signed, or an unsigned 32-bit pattern).
    For 'U', imm is the full 32-bit value, whose low 12 bits must be zero.
    Must be the exact inverse of decode_imm:
        decode_imm(encode_imm(fmt, v), fmt) == v & MASK32
    Raise ValueError if imm is not encodable in that format (out of range,
    odd for B/J, or low 12 bits non-zero for U)."""
    # TODO (Lab 2, Task 2.5): used to build instruction words for your tests.
    raise NotImplementedError("encode_imm: Lab 2, Task 2.5")
