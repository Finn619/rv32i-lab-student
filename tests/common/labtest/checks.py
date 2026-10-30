"""Assertion helpers that turn unresolved ('U'/'X'/'Z') values into clear
test failures instead of Python exceptions deep inside cocotb."""


def resolved(sig, what=None):
    """Return the value of ``sig`` as an unsigned int, or fail the test with a
    readable message if any bit is not a clean '0' or '1'."""
    v = sig.value
    if not v.is_resolvable:
        name = what or getattr(sig, "_path", None) or getattr(sig, "_name", "signal")
        raise AssertionError(
            f"{name} = '{v}' is not a valid 0/1 value. "
            "Is the architecture implemented and is every output driven on every path?"
        )
    return int(v)


def resolved_signed(sig, width, what=None):
    """As :func:`resolved`, interpreting the value as two's complement."""
    u = resolved(sig, what)
    return u - (1 << width) if u >> (width - 1) else u


def check(sig, expected, what, context=""):
    """Assert that ``sig`` holds ``expected`` (an int)."""
    got = resolved(sig, what)
    width = len(sig)
    mask = (1 << width) - 1
    exp = expected & mask
    digits = (width + 3) // 4
    assert got == exp, (
        f"{what}: expected 0x{exp:0{digits}x}, got 0x{got:0{digits}x}"
        + (f"  [{context}]" if context else "")
    )


def u32(x):
    return x & 0xFFFF_FFFF


def s32(x):
    x &= 0xFFFF_FFFF
    return x - (1 << 32) if x & 0x8000_0000 else x
