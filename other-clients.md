# Other clients

Outcome: the same daemon read four more ways — decoded in
Python, painted on a terminal screen, taken raw by a
developer tool — plus an honest account of the two ways that
did not run in this lab, and why.

## The Python bindings: the stream, decoded

A program does not want JSON text; it wants fields. gpsd's
client library does chapter 8's ceremony and hands back
report objects one at a time. The lab's
`gpsd-lab/client_python.py` is twenty lines: connect with a
watch enabled, walk the reports, keep the TPVs, print three
(transcript `gpsd-lab/transcripts/t04-python-client.txt`):

```
$ python3 client_python.py 3
TPV 1: time=2026-06-15T12:00:02.000Z mode=3 lat=39.5
       lon=-98.499813333 altHAE=305.0 speed=8.0 m/s track=90.0 deg
TPV 2: time=2026-06-15T12:00:03.000Z mode=3 lat=39.5
       lon=-98.49972 altHAE=305.0 speed=8.0 m/s track=90.0 deg
TPV 3: time=2026-06-15T12:00:04.000Z mode=3 lat=39.5
       lon=-98.499626667 altHAE=305.0 speed=8.0 m/s track=90.0 deg
printed 3 TPV reports
```

Same daemon, same stream as gpspipe — the library simply
spared the program the parsing, and the filtering by class
that a pipeline would do with text tools happens here as an
ordinary `if`. This is the form almost every real consumer
takes: a long-running program iterating over reports,
reacting to the classes it cares about and ignoring the
rest. (Which `gps` package this is deserves its chapter 3
footnote: the one the source build installed, found at
`/usr/local/lib/python3.12/dist-packages/gps/`.)

## cgps: the screen

**cgps** is the client a person watches: a terminal screen
that repaints each second — time, position, altitude,
speed, track, the fix status, error estimates, and the
satellite table with a used/not-used flag per satellite.
It needs a real terminal, so the lab ran it under
`script(1)`, which provides one, and scraped the paint
(transcript `gpsd-lab/transcripts/t06-cgps-and-gpsmon.txt`).
A scrape of a repainting screen is ragged — the transcript
says so — but the settled screen is legible in it:

```
2026-06-15T12:00:02.000Z   39.50 N   98.49981333 W
Speed 17.90 (mph, the screen's default units)  Track 90.0
Status 3D    Seen 11 / Used 9
GP  5   Elev 43.0  Azim 60.0   SNR 43.0  Used Y
GP 14   Elev 20.0  Azim 175.0  SNR 32.0  Used N
```

(The chapter quotes the values the scrape carries, tidied
into columns; t06 keeps the raw paint.) Eleven seen, nine
used, PRN 14 visible and unused — the generator's cast and
chapter 10's SKY numbers, wearing a screen. At a real
terminal this is the fastest health check there is: sit the
receiver down, run `cgps`, and watch whether Used climbs
and the status reaches 3D. In the lab it also caught
nothing wrong — which, given the sky was written to be
healthy, is the correct result, not a weak one.

## gpsmon: the raw stream, with a warning label

**gpsmon** is the odd one, twice over. First, the tool
itself warns you off: 3.26.1's gpsmon prints, on every run,

```
gpsmon:WARN: gpsmon is  deprecated and long obsolete.
gpsmon:WARN: gpsmon is not a full gpsd client.
gpsmon:WARN: gpsmon is a poorly maintained developer tool
gpsmon:WARN: Only developers should use gpsmon.
```

The guide repeats that because a reader who finds gpsmon in
an old tutorial deserves to know its own authors have moved
on. Second, gpsmon's purpose was always different: it is a
*monitor for the device conversation*, happiest talking to a
receiver directly, showing each packet as it passes. Through
the daemon (its `gpsmon -a 127.0.0.1:2947` form, `-a` for
no-curses output) it takes a **raw** watch — the WATCH echo
in t06 says `"raw":2,"pps":true` where chapter 8's asked
for JSON — and prints the sentences themselves, each tagged
with its length:

```
(74) $GPRMC,120004.00,A,3930.0000,N,09829.9776,W,15.55,90.0,150626,1.5,W,A*01
(73) $GPGGA,120005.00,A,3930.0000,N,09829.9721,W,1,09,0.9,320.0,M,-15.0,M,,*5E
```

That is the level at which receiver problems live — a
sentence missing, a checksum failing, a rate wrong — and
the level chapter 1's rule says ordinary programs should
never need. gpsmon also printed lines beginning `TOFF=` —
its clock-offset bookkeeping — with values in the billions
of seconds, because its "real time" reference was the
fictional 2026 of the log rubbing against the sandbox
clock. Chapter 12 explains the honest part of that; the
numbers themselves are a replay artefact, quoted in t06 as
found and believed about nothing.

## The two that did not run

- **gpsmon direct-from-device.** Given the log file as its
  argument, gpsmon did not open it as a device: it parsed
  the name as a *server* spec — `tcp://fixture-sky.nmea:2947`
  — and reported a read error (transcript
  `gpsd-lab/transcripts/t09-gui-and-direct.txt`). A direct
  gpsmon session needs a real serial device to own, and
  this lab has none. It is recorded as not run, and it is
  also chapter 1's rule with the bark on: tools that bypass
  the daemon need custody of hardware; tools that use the
  daemon need only an address.
- **xgps and the graphical clients.** The build installed
  `xgps`, and running it answers immediately:
  `xgps: ERROR: DISPLAY not set`. This machine has no
  display, and the build had already warned that xgps's
  runtime libraries were missing. xgps is therefore
  documented-only in this guide: a sky-and-satellite window
  over the same socket protocol, described from the
  project's documentation in chapter 14's terms, never
  pictured as if it had run here.

Check: name one client per style — text stream (gpspipe),
decoded objects (the Python client), screen (cgps), raw
monitor (gpsmon) — and the two routes this lab could not
take, with the reason for each. If the reasons are "no
device to own" and "no display", you have the chapter.
