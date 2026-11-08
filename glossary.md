# Glossary

Outcome: every term the guide uses, in one place, in the
guide's own words.

**Activated** — a device gpsd has opened and heard from;
the state its DEVICE record reports with a timestamp.
A listed device that is not activated has not spoken yet.

**Checksum** — in NMEA, the two hex digits after `*`: the
XOR of every character between `$` and `*`. Sentences that
fail it are dropped. Chapter 4's checker recomputes them.

**Client** — any program that connects to gpsd's socket and
asks for reports. gpspipe, cgps, your own twenty lines of
Python: all clients, all equal.

**Control socket** — gpsd's private socket file, separate
from the client port, used by management tools to add or
remove devices in a running daemon.

**Cycle** — the interval at which a receiver emits its
burst of sentences; one second for most receivers, and for
this guide's fixture.

**Daemon** — a program that runs in the background,
started once and staying up, serving others. gpsd is one;
the word names a habit, not a kind of magic.

**Device** — one input gpsd owns: a serial path, a network
feed, or (in the lab) a pseudo-terminal from gpsfake. Each
has its own record and its own report stream.

**DOP (dilution of precision)** — a family of numbers
(HDOP, VDOP, PDOP, GDOP, TDOP) grading how satellite
geometry affects the fix's certainty. Near 1 is good;
the fixture's tidy sky produced 0.90–2.68.

**Epoch** — one complete burst of sentences for one moment:
in the fixture, GGA, GSA, three GSV, and RMC for the same
second.

**Error estimates** — the TPV fields `ept`, `epx`, `epy`,
`epv`, `eph`, `sep`: the daemon's stated uncertainty for
time, position, and altitude, in seconds and metres.
Part of the fix, not fine print.

**Fix** — a receiver's solved position (with its time and
motion), graded by mode: 1 none, 2 two-dimensional,
3 three-dimensional. An estimate, always.

**GGA / GSA / GSV / RMC** — the four NMEA sentence types in
the fixture: the fix; the mode and used-satellite list;
satellites in view; and the "recommended minimum" carrying
date, speed, and track.

**gpsfake** — gpsd's test partner: creates a pretend serial
device, starts a real gpsd on it, and replays a log file at
a controlled pace, once (`-1`) or looping.

**gpsmon** — a developer monitor for the device
conversation; deprecated in 3.26.1 by its own warnings.
Via the daemon it shows the raw sentence stream.

**gpspipe** — the simplest client: connects, watches, and
prints reports as text lines, JSON (`-w`) or pseudo-NMEA
(`-r`).

**JSON** — the text format of gpsd's reports: objects with
named fields, one per line, each carrying a `"class"`.

**Mode** — see **Fix**. In a TPV, the grade of the fix it
carries, 0 (unknown) to 3.

**NMEA 0183** — the standard text dialect of marine and GPS
devices: one-line, comma-separated `$` sentences with
checksums. The fixture's dialect, chosen because a reader
can take it apart by eye.

**Nowait (`-n`)** — gpsd switch: poll devices even with no
client connected, instead of waiting for a watcher.

**POLL** — the `?POLL;` command: "your current picture,
once", answered with a snapshot object — empty lists when
there is nothing, which is also an answer.

**Port 2947** — gpsd's listening port for clients, its
default for decades. This lab connected only as
127.0.0.1:2947, plus one extra instance on 18092.

**PPS (pulse per second)** — a timing receiver's electrical
edge at the top of each second. The sharp half of GPS time;
documented-only in this guide, which has no such hardware.

**Pseudo-NMEA** — NMEA sentences gpsd regenerates from its
current picture for clients that ask (`gpspipe -r`).
Faithful, normalised, and not a bit-copy of the wire.

**Pseudo-terminal (pty)** — a pretend serial port created
by software, appearing as `/dev/pts/N`; gpsfake's device,
and the path in this guide's DEVICE records.

**Receiver** — the hardware that listens to the satellites
and speaks sentences. Absent from this lab; simulated by a
file and gpsfake.

**Report** — one JSON object from the daemon: TPV, SKY,
DEVICE, DEVICES, VERSION, WATCH, ERROR, PPS, TOFF, and kin.

**SCons** — the Python-based build tool gpsd uses; the lab
installed version 4.11.1 in a virtual environment.

**SKY** — the report class for the satellite view: nSat
seen, uSat used, per-satellite detail, and the DOPs.

**TOFF** — time-offset report: the difference between a
PPS pulse's arrival by the system clock and the true top
of its second. Seen here only in gpsmon's replay output.

**TPV** — the report class for the fix: time, position,
velocity — with mode and error estimates. The report the
whole guide is about.

**Used / seen** — a satellite is *seen* if the receiver
hears and locates it, *used* if the fix included it.
The fixture wrote eleven seen, nine used, on purpose.

**WATCH** — the command (`?WATCH={...};`) that starts and
stops the report stream on a connection, and the report
class of the daemon's echo of it. Chapter 8 speaks it by
hand.

Check: pick any three terms you met in a chapter and
explain them without looking — then look, and correct
yourself out loud. The glossary has done its job if the
corrections are small.
