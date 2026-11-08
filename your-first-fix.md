# Your first fix

Outcome: the fixture sky replayed through a real gpsd, and
your first **TPV** report in hand — with a time, a position,
a speed, and a heading, each traced back to the sentence it
came from.

## gpsfake, in one paragraph

**gpsfake** is gpsd's own testing partner. It creates a
pretend serial port (a **pseudo-terminal**, which appears as
a path like `/dev/pts/2`), starts a real gpsd with that port
as its device, and feeds a log file down the wire at a
controlled pace. Nothing about the daemon is simulated: it
parses, merges, and reports exactly as it would for
hardware. In **pipe mode** (`-p`) gpsfake also acts as a
client itself, printing everything a watching client would
receive — the fastest route from zero to a fix. Two flags
shape this run: `-1` plays the log **once** instead of
looping it forever, and `-c 0.02` sets a short delay between
sentences so the run takes seconds, not a minute and a
half. (And recall chapter 3: gpsfake starts the `gpsd` it
finds on `PATH`. The lab's prefix is first on `PATH` for
every run in this guide.)

```
gpsfake -p -1 -c 0.02 fixture-sky.nmea
```

## Reading the run

The full run (transcript
`gpsd-lab/transcripts/t02-gpsfake-pipe.txt`, driver
`gpsd-lab/drivers/t02_gpsfake_pipe.sh`) produced **888
lines**, and the driver counts them by kind:

```
lines total: 888
TPV lines:   82
SKY lines:   320
raw NMEA lines echoed: 480
```

480 is every sentence in the log, echoed back because pipe
mode asks the daemon for the NMEA stream as well as JSON —
the raw material flowing past the reports it fed. The
handshake lines come first (VERSION, DEVICES, WATCH —
chapter 8 takes them one at a time), and then, from the very
first epoch, reports begin. Watch the first fix assemble
itself. From the GGA sentence alone, gpsd can already say
where and how high, but not when or how fast:

```
{"class":"TPV","device":"/dev/pts/2","mode":3,"lat":39.500000000,
"lon":-98.500000000,"altHAE":305.0000,"altMSL":320.0000,
"alt":320.0000,"magvar":4.1,"geoidSep":-15.000,"eph":17.100}
```

`mode` is already 3 — GGA claims a three-dimensional fix —
and the altitude appears twice over: `altMSL` is the 320.0 m
the sentence carried, and `altHAE` is that value restated
against a different reference surface (320.0 − the 15.0 m
geoid separation = 305.0). Then the epoch's RMC sentence
arrives, and the *same second's* report gains the fields
only RMC carries:

```
{"class":"TPV","device":"/dev/pts/2","mode":3,
"time":"2026-06-15T12:00:00.000Z","ept":0.005,
"lat":39.500000000,"lon":-98.500000000,"altHAE":305.0000,
"altMSL":320.0000,"alt":320.0000,"epx":10.231,"epy":11.734,
"epv":29.900,"track":90.0000,"magtrack":88.5000,
"magvar":-1.5,"speed":8.000,"geoidSep":-15.000,
"eph":17.100,"sep":30.400}
```

Now it is complete for a moving receiver: time (the
fictional 15 June 2026, noon, exactly as the generator wrote
it), `speed` **8.000** m/s — the generator's 15.55 knots in
the daemon's metric units — and `track` **90.0000**, due
east, the rectangle's first leg. The error fields (`ept`,
`epx`, `epy`, `epv`, `eph`) arrived with the fuller report
too; chapter 10 reads them properly, but note now that the
daemon never hands you a position without its doubts
attached. 82 TPVs for 80 epochs is the same assembly effect:
two early reports were partial, from GGA before RMC landed.

Between TPVs come **SKY** reports — 320 of them, because
each of GGA, GSA, and the GSV group updates the daemon's sky
picture a little. Chapter 10 reads one in full; for now the
headline numbers are `"nSat":11,"uSat":9` — eleven satellites
seen, the right nine used — which is the generator's cast
list, correctly understood by the daemon.

## What you have, and what you have not

You have proved the whole chain with no hardware: written
sentences → a pretend serial port → the real daemon → JSON
reports a program can consume, with the values matching the
log to the last decimal. You have *not* proved anything
about receivers, antennas, or the actual sky — the daemon
reported a fictional receiver's beliefs, beautifully. Keep
both halves of that sentence; the guide will.

The daemon in this chapter belonged to gpsfake and died
with it. The next chapter keeps the same feeder but turns
the arrangement into one other programs can connect to.

Check: re-run the pipe command and count with the driver.
82 TPV, 320 SKY, 480 NMEA lines — and find the first TPV
carrying `"speed":8.000` and say which sentence in the log
supplied it. (RMC. If you said GGA, re-read the assembly
above — that distinction runs the next three chapters.)
