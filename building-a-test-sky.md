# Building a test sky

Outcome: a written NMEA log you fully understand — every
sentence type, every field that matters, and a checksum you
can prove — ready to be replayed through the real daemon in
the next two chapters.

## Why a written sky at all

This lab has no GPS receiver, and no chapter will pretend
otherwise. But gpsd does not care whether the bytes on its
device came from an antenna or from a file replayed at the
same pace: its parsing, merging, and reporting are identical.
gpsd's own project works this way — its regression tests are
log files — and it ships **gpsfake** precisely to replay a
log through a real daemon over a pretend serial port.

So the lab wrote its sky. **Writing** it, rather than
downloading a stranger's recording, buys three things: the
coordinates are invented and nobody's (a slow rectangle over
open farmland, starting at 39.5000, -98.5000 — a point chosen
because it is farmland in every direction, not because
anyone lives or works there); every value in it is known in
advance, so a wrong report is recognisably wrong; and its
faults are the lab's own, one of which chapter 10 will meet.

## The sentences

NMEA 0183 sentences are one-line, comma-separated text,
starting with `$`, ending with `*` and a two-digit
**checksum**: the XOR of every character between the `$` and
the `*`, in hex. A receiver sends a **burst** of them about
once a second; one burst is an **epoch**. The lab's
generator, `gpsd-lab/make_nmea.py`, emits six sentences per
epoch, in the order a small receiver typically sends them:

- **GGA** — the fix itself: time, latitude, longitude, fix
  quality, satellites used (09), horizontal dilution (0.9),
  altitude (320.0 m), and the geoid separation (-15.0 m).
- **GSA** — the fix mode and the cast list: automatic mode,
  **3** (three-dimensional fix), the twelve satellite slots
  — nine filled with the used satellites' numbers, three
  empty — then PDOP 1.6, HDOP 0.9, VDOP 1.3.
- **GSV** ×3 — satellites **in view**: eleven of them, four
  to a sentence, each with elevation, azimuth, and signal
  strength. Nine are the used nine from GSA; two (14 and 27)
  are visible but unused, so chapters can tell "seen" from
  "used" without squinting.
- **RMC** — the "recommended minimum": time *and date*, the
  position again, and the two fields GGA does not carry —
  **speed** over ground (15.55 knots, which is 8.0 m/s) and
  **track**, the heading, rotating with the route's legs:
  90° east, then 0° north, 270° west, 180° south, twenty
  seconds a leg, 80 epochs in all.

The generator computes each line's checksum itself, in code
— nobody typed a hex digit — and formats latitude and
longitude the NMEA way (`3930.0000,N` is 39 degrees,
30.0000 minutes north). Its first seconds (transcript
`gpsd-lab/transcripts/t01-fixture.txt`):

```
$GPGGA,120000.00,3930.0000,N,09830.0000,W,1,09,0.9,320.0,M,-15.0,M,,*5E
$GPGSA,A,3,5,7,9,12,15,18,21,24,30,,,,1.6,0.9,1.3*0D
$GPGSV,3,1,11,05,43,060,42,07,63,110,45,09,32,155,37,12,54,200,42*71
$GPRMC,120000.00,A,3930.0000,N,09830.0000,W,15.55,90.0,150626,1.5,W,A*02
```

(The three GSV lines are shown shortened to one here; the
transcript has them all.) The date, 150626, and the noon
start are fictional like everything else in the file: the
receiver in this sky believes it is 15 June 2026, and the
daemon will faithfully report that belief — keep the
distinction in mind when chapter 5's TPV carries that date.

## Proving the log before trusting it

A log with a bad checksum is worse than no log: gpsd will
drop the sentence, silently, and a missing report downstream
looks like a daemon bug. So the lab re-verifies, with an
independent little checker that recomputes every checksum
from the file as written (`gpsd-lab/check_checksums.py`):

```
$ python3 check_checksums.py fixture-sky.nmea fixture-sky-2.nmea
fixture-sky.nmea: 480 sentences checked, 0 bad checksums
fixture-sky-2.nmea: 480 sentences checked, 0 bad checksums
```

480 sentences is 80 epochs × 6. The second file is the same
sky told twice as slowly from a point a short distance
north-east — same script, different starting flags
(39.5100, -98.4900, 4.0 m/s, altitude 318 m, start time a
minute later) — kept in reserve for chapter 11, where one
daemon listens to both at once. Generate both now, exactly
as `examples/commands.txt` lists, and your counts should
match the lab's to the sentence.

One caution this chapter insists on, because later chapters
will test it: a written sky can only contain what its author
thought to put in it. This one has no signal dropouts, no
multipath errors, no sentences the generator's author did
not know about, and a receiver that never loses its fix.
It is a test sky, not the sky — a tool for proving the
plumbing, labelled every time the guide leans on it.

Check: run the generator and the checker. You should have
two files, 480 lines each, 0 bad checksums, and be able to
point at the GGA line and name its latitude, longitude, and
altitude without help.
