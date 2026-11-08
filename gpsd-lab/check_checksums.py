#!/usr/bin/env python3
"""check_checksums.py - verify every NMEA checksum in a log file.

Recomputes the XOR checksum of each `$...*XX` line and reports
how many lines were checked and how many failed. Exits 1 if any
line fails, so it can gate a driver script.
Usage: python3 check_checksums.py FILE [FILE ...]
"""
import sys


def check(path):
    total = bad = 0
    with open(path, "rb") as fh:
        for raw in fh:
            line = raw.strip().decode("ascii", "replace")
            if not line.startswith("$") or "*" not in line:
                continue
            total += 1
            body, _, given = line[1:].partition("*")
            value = 0
            for ch in body:
                value ^= ord(ch)
            if f"{value:02X}" != given[:2].upper():
                bad += 1
                print(f"BAD {path}: {line}")
    print(f"{path}: {total} sentences checked, {bad} bad checksums")
    return bad


if __name__ == "__main__":
    sys.exit(1 if any(check(p) for p in sys.argv[1:]) else 0)
