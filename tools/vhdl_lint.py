#!/usr/bin/env python3
"""vhdl_lint.py - flag VHDL constructs outside the course's portable subset
(manual, appendix "The portable VHDL subset").

    python3 tools/vhdl_lint.py rtl boards        (directories or files)

This is a simple line-based check, not a parser: it catches the common
problems and may very rarely give a false alarm. Simulation-only regions
(-- synthesis translate_off ... translate_on) are skipped.
"""
import re
import sys
from pathlib import Path

RULES = [
    (r"\bstd_logic_(arith|unsigned|signed)\b", "use ieee.numeric_std only"),
    (r"\?(=|/=|<|<=|>|>=)", "matching operators: not needed, avoid"),
    (r"\?\?", "condition operator ??: avoid"),
    (r"\bcase\s*\?", "matching case?: avoid"),
    (r"<<\s*signal\b", "external names are not supported by Quartus Lite"),
    (r"\bshared\s+variable\b", "shared variables need a protected type in VHDL-2008"),
    (r"\bgeneric\s*\(\s*type\b", "generic types are not supported by Quartus Lite"),
    (r"\bpackage\s+\w+\s+is\s+new\b", "generic package instances are not supported"),
    (r"\bforce\b", "force/release is simulation only"),
    (r"\bto_hstring\b|'image\b|\btextio\b|\bfile_open\b", "simulation-only feature in synthesisable code"),
    (r"\bclk'event\b|'event\s+and", "use rising_edge()"),
]
PORTMAP_EXPR = re.compile(r"=>\s*[^,;()]*\b(and|or|xor|not|nand|nor)\b|=>\s*[^,;()]*&")


def lint(path):
    problems = []
    skipping = False
    in_portmap = False
    in_process = False
    for n, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.split("--")[0]
        low = raw.lower()
        if "translate_off" in low:
            skipping = True
        if "translate_on" in low:
            skipping = False
            continue
        if skipping:
            continue
        for pat, msg in RULES:
            if re.search(pat, line, re.I):
                problems.append((n, msg, raw.strip()))
        l = line.lower()
        if re.search(r"\bport\s+map\b", l):
            in_portmap = True
        if in_portmap and PORTMAP_EXPR.search(l):
            problems.append((n, "expression as a port-map actual: assign it to a signal first", raw.strip()))
        if in_portmap and ");" in l:
            in_portmap = False
        if re.search(r"^\s*(\w+\s*:\s*)?process\b", l):
            in_process = True
        if re.search(r"\bend\s+process\b", l):
            in_process = False
        if in_process and re.search(r"<=.*\bwhen\b.*\belse\b", l):
            problems.append((n, "conditional assignment inside a process (VHDL-2008 only)", raw.strip()))
    return problems


def main():
    files = []
    for a in sys.argv[1:] or ["rtl", "boards"]:
        p = Path(a)
        files += sorted(p.rglob("*.vhd")) if p.is_dir() else [p]
    total = 0
    for f in files:
        for n, msg, text in lint(f):
            print(f"{f}:{n}: {msg}\n    {text}")
            total += 1
    print(f"{len(files)} file(s) checked, {total} problem(s)")
    sys.exit(1 if total else 0)


if __name__ == "__main__":
    main()
