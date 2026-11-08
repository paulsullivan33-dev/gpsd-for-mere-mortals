#!/usr/bin/env python3
"""make_nmea.py - write a plausible, checksum-correct NMEA 0183 log.

The log is a fictional receiver on a fictional route: a slow
rectangular loop over open farmland, invented coordinates, no
real person, vehicle, or address. One epoch per second. Each
epoch emits GGA, GSA, GSV (three sentences), and RMC, in the
order a typical small receiver sends them.

Checksums are computed here, not typed: the checksum is the
XOR of every character between '$' and '*', printed as two
hex digits, exactly as the NMEA 0183 standard defines it.

Usage:
    python3 make_nmea.py [--seconds N] [--out FILE]
                         [--lat DEG] [--lon DEG] [--speed MS]
                         [--alt M] [--date DDMMYY] [--start HHMMSS]

Defaults write an 80-second loop starting at 39.5000, -98.5000.
"""

import argparse
import math


def checksum(body: str) -> str:
    value = 0
    for ch in body:
        value ^= ord(ch)
    return f"{value:02X}"


def sentence(body: str) -> str:
    return f"${body}*{checksum(body)}"


def fmt_lat(lat: float) -> tuple[str, str]:
    hemi = "N" if lat >= 0 else "S"
    lat = abs(lat)
    deg = int(lat)
    minutes = (lat - deg) * 60.0
    return f"{deg:02d}{minutes:07.4f}", hemi


def fmt_lon(lon: float) -> tuple[str, str]:
    hemi = "E" if lon >= 0 else "W"
    lon = abs(lon)
    deg = int(lon)
    minutes = (lon - deg) * 60.0
    return f"{deg:03d}{minutes:07.4f}", hemi


def fmt_time(total_seconds: int) -> str:
    total_seconds %= 24 * 3600
    h, rest = divmod(total_seconds, 3600)
    m, s = divmod(rest, 60)
    return f"{h:02d}{m:02d}{s:02d}.00"


# Satellites the fictional receiver claims to use for the fix.
USED = [5, 7, 9, 12, 15, 18, 21, 24, 30]
# Satellites it claims to see (used ones plus two more).
SEEN = [
    # prn, base elevation, base azimuth, base SNR
    (5, 45, 60, 42), (7, 62, 110, 44), (9, 31, 155, 38),
    (12, 55, 200, 41), (15, 70, 250, 45), (18, 28, 295, 36),
    (21, 48, 330, 40), (24, 66, 20, 43), (30, 38, 85, 39),
    (14, 18, 175, 32), (27, 22, 270, 33),
]


def epoch_lines(t, lat, lon, speed_ms, track, alt, date, start):
    stamp = fmt_time(start + t)
    lat_s, lat_h = fmt_lat(lat)
    lon_s, lon_h = fmt_lon(lon)
    knots = speed_ms * 1.943844
    lines = []
    # GGA: fix, 9 satellites, HDOP 0.9, altitude, geoid height  -15.0
    lines.append(sentence(
        f"GPGGA,{stamp},{lat_s},{lat_h},{lon_s},{lon_h},1,"
        f"{len(USED):02d},0.9,{alt:.1f},M,-15.0,M,,"))
    # GSA: auto, 3D fix, the used PRNs, PDOP/HDOP/VDOP
    prns = ",".join(str(p) for p in USED)
    lines.append(sentence(f"GPGSA,A,3,{prns},,,,1.6,0.9,1.3"))
    # GSV: three sentences, 11 satellites in view
    groups = [SEEN[i:i + 4] for i in range(0, len(SEEN), 4)]
    for gi, group in enumerate(groups, start=1):
        fields = []
        for prn, elev, azim, snr in group:
            elev2 = max(5, min(85, elev + int(3 * math.sin(t / 9.0 + prn))))
            azim2 = (azim + t // 10) % 360
            snr2 = max(25, min(48, snr + int(2 * math.cos(t / 7.0 + prn))))
            fields.append(f"{prn:02d},{elev2:02d},{azim2:03d},{snr2:02d}")
        lines.append(sentence(
            f"GPGSV,{len(groups)},{gi},{len(SEEN):02d}," + ",".join(fields)))
    # RMC: recommended minimum, status A (valid), magnetic variation
    lines.append(sentence(
        f"GPRMC,{stamp},A,{lat_s},{lat_h},{lon_s},{lon_h},"
        f"{knots:.2f},{track:.1f},{date},1.5,W,A"))
    return lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seconds", type=int, default=80)
    ap.add_argument("--out", default="-")
    ap.add_argument("--lat", type=float, default=39.5000)
    ap.add_argument("--lon", type=float, default=-98.5000)
    ap.add_argument("--speed", type=float, default=8.0, help="metres/second")
    ap.add_argument("--alt", type=float, default=320.0)
    ap.add_argument("--date", default="150626")
    ap.add_argument("--start", type=int, default=12 * 3600,
                    help="start time as seconds after midnight UTC")
    args = ap.parse_args()

    # Four equal legs of a rectangle: east, north, west, south.
    headings = [90.0, 0.0, 270.0, 180.0]
    leg = max(1, args.seconds // 4)
    lat, lon = args.lat, args.lon
    out_lines = []
    for t in range(args.seconds):
        track = headings[min(3, t // leg)]
        out_lines.extend(epoch_lines(
            t, lat, lon, args.speed, track, args.alt, args.date, args.start))
        # Advance one second along the current heading.
        north = args.speed * math.cos(math.radians(track))
        east = args.speed * math.sin(math.radians(track))
        lat += north / 111_320.0
        lon += east / (111_320.0 * math.cos(math.radians(lat)))

    text = "\r\n".join(out_lines) + "\r\n"
    if args.out == "-":
        print(text, end="")
    else:
        with open(args.out, "w", newline="") as fh:
            fh.write(text)
        print(f"wrote {args.out}: {args.seconds} epochs, "
              f"{len(out_lines)} sentences")


if __name__ == "__main__":
    main()
