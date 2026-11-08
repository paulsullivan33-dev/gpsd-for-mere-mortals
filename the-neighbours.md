# The neighbours

Outcome: gpsd placed among its neighbours — the programs
and approaches that touch the same receiver — characterised
plainly, so you can say what each is for and why gpsd is,
or is not, the layer you want. Characterised, not
benchmarked: only gpsd was run in this lab.

## Reading the serial port yourself

The neighbour at zero distance: open `/dev/ttyUSB0` in your
program and parse. For one program, on one machine, with a
receiver whose dialect you know, this honestly works — the
sentences in chapter 4 are plain text, and a page of code
reads RMC and GGA. The costs arrive with the second program
(custody of the port), the second dialect (a binary
protocol, a firmware quirk), and the first surprise
sentences (the ones your parser did not expect at 3 a.m.).
gpsd is what this approach grows into when it is done
properly and shared. Reach for the direct read for a
throwaway experiment; reach for the daemon the moment
anything else — a logger, a screen, a second experiment —
wants the same sky.

## gpsfake and the other simulators

gpsfake is this guide's feeder and the project's test tool:
a log in, a daemon out. Its neighbours aim at the wire
instead or beyond it — serial-device emulators that present
a programmable port, and full GNSS signal simulators that
generate actual radio for a receiver to lock onto. The
levels answer different questions. gpsfake tests *software
above the daemon*: clients, parsers of reports, this whole
guide. A signal simulator tests the *receiver itself*.
Confusing the levels produces a classic false result: a
client "verified against GPS" that has only ever seen a
text file. Chapter 15 keeps the vocabulary for that:
a test sky, not the sky.

## Clocks: chrony and NTPsec

Time's neighbours are time servers. **Chrony** and
**NTPsec** discipline a machine's clock from network time
sources — and both can also take a reference-clock feed
from gpsd (over its shared-memory or PPS interfaces) when
a timing receiver is attached, making the machine a
stratum-1 time source for its network. The relationship is
a handoff, not a rivalry: gpsd turns receiver output into
reports and a clean time feed; the time server decides what
the *system clock* should believe, weighing sources and
slewing gently. That handoff is documented-only in this
guide (chapter 12 explains why: no pulse here), but the
shape matters for planning — if precise time is the goal,
gpsd is the middle of the pipeline, not the end of it.

## Maps and navigation programs

The consumers most readers meet first: chart and map
applications — OpenCPN on the marine side, QGIS and
navigation programs on land, and a long tail of loggers,
trackers, and instrument displays — are gpsd clients in the
chapter 9 sense. They connect to 2947 (or read a library
that does), watch, and draw. Their existence is the
practical argument for the daemon: a receiver bought once
appears, through gpsd, inside every one of them at once,
and a program that predates your receiver's dialect still
works, because speaking dialects is the daemon's job, not
theirs. One caution from chapter 7 applies to them all:
what they draw is the daemon's picture — merged, a step
behind the wire — which is the right trade for a moving map
and the wrong one for packet-level debugging, where
gpsmon's raw view (warts and deprecation warnings and all)
remains the tool that shows the sentences themselves.

Check: for each neighbour, say the job it owns: direct
serial reading (one program, one dialect, no sharing),
signal simulation (testing receivers, not software),
chrony/NTPsec (deciding what the clock believes), map
programs (drawing the daemon's picture). If you can also
say which neighbour this guide actually *ran* — none; the
running was all gpsd and its own clients — you have the
chapter and its honesty rule together.
