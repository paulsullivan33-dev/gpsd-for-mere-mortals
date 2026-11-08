#!/usr/bin/env python3
"""client_python.py - a small client using gpsd's own Python bindings.

Uses the `gps` package that the gpsd source build installs.
Connects to 127.0.0.1:2947, asks for a watch, and prints the
first few TPV (time-position-velocity) reports it receives --
decoded into fields, not raw JSON. That decoding step is the
whole difference between this client and gpspipe -w.

Usage: python3 client_python.py [count]
"""
import sys

import gps

count = int(sys.argv[1]) if len(sys.argv) > 1 else 3


def main():
    session = gps.gps(host="127.0.0.1", port=2947, mode=gps.WATCH_ENABLE)
    seen = 0
    for report in session:
        if report.get("class") != "TPV":
            continue
        seen += 1
        print(
            f"TPV {seen}: time={report.get('time')} "
            f"mode={report.get('mode')} "
            f"lat={report.get('lat')} lon={report.get('lon')} "
            f"altHAE={report.get('altHAE')} "
            f"speed={report.get('speed')} m/s "
            f"track={report.get('track')} deg"
        )
        if seen >= count:
            break
    print(f"printed {seen} TPV reports")


if __name__ == "__main__":
    main()
