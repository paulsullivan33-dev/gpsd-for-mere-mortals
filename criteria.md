# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** gpsd reports what the receiver
   believes, and a fix is an estimate, not a measurement of
   truth: a mode 3 report claims a three-dimensional fix, and
   the error fields beside it (in this lab `epx` 10.231 m,
   `epy` 11.734 m, `epv` 29.900 m) are part of the report, not
   fine print — mode 2 versus mode 3 is the daemon being
   honest about how much of a fix it has, and mode 1 is no
   fix at all. gpsd cannot invent satellites: a replayed log
   is a test sky, not the sky, and a perfect replay only
   proves the plumbing works. A consumer USB receiver and a
   timing-grade receiver with a PPS output are different
   worlds, and this lab lives entirely in the first one — it
   has no GPS hardware at all. And JSON clients get the
   daemon's view, which is merged, filtered, and a step
   behind the raw stream: in the lab, a TPV assembled from a
   GGA alone carried no time or speed until the RMC sentence
   of the same epoch arrived.
8. **The one rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *one daemon talks to the
   receiver, and every other program listens to the daemon* —
   before any procedure depends on it, and later chapters point
   back to it where the rule bites: the client that tried to
   read a device directly, the second receiver that became a
   second device instead of a second daemon, and the question
   of who may reconfigure a receiver everyone else is reading.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is an Ubuntu 24.04 sandbox with **no GPS
hardware**. The machine already carried an Ubuntu gpsd package,
**3.25** (`/usr/sbin/gpsd`, plus `cgps` and `gpsmon`), but
`gpsfake`, `gpspipe`, and `xgps` were missing from it
(transcript `gpsd-lab/transcripts/t00-system-and-versions.txt`).
The lab therefore built the full suite from the official source
release **`gpsd-3.26.1.tar.gz`** (5,909,502 bytes, sha256
`dc7e465968c1540e61bc57c7586d6a57a0047212a014efdad348f907bc2e0990`),
downloaded from gpsd's official Savannah mirror. SCons
**4.11.1** was installed with pip into a Python venv in the
scratch folder (never `/tmp`); the build used
`scons prefix=<scratch-prefix> python_shebang=/usr/bin/python3`
and installed into that scratch prefix, not system-wide — with
one exception the guide states openly: `scons install` placed
the Python `gps` package in
`/usr/local/lib/python3.12/dist-packages/gps/`. The build's
warnings are recorded, not hidden: `xgps` and `xgpsspeed`
missing runtime dependencies, `ubxtool` and `zerk` missing the
optional Python `serial` module, and AsciiDoctor not found, so
the project's HTML documentation was not built. The ncurses
clients did build — the build log links `cgps` and `gpsmon`
with `-lncurses` — and both ran. The lab is in `gpsd-lab/`:
`make_nmea.py` (the fixture generator), `check_checksums.py`,
`client_python.py`, `watch_by_hand.py`, driver scripts in
`drivers/`, and the transcripts they produced. The daemon under
test listened on gpsd's own port, **2947** (the protocol's port,
used by the specific-port exemption in the series' builder
notes); the lab only ever connected to it at 127.0.0.1. One
standalone extra instance used 127.0.0.1 port **18092**.

Run for real, with transcripts as evidence:

- System-versus-built versions (t00): every built tool —
  `gpsd`, `gpspipe`, `cgps`, `gpsmon` — reports **3.26.1**;
  `gpsfake` reports "Version 3.26.1"; the Python `gps` module
  imports and resolves to the build's installed package.
- The fixture sky (t01): `make_nmea.py` wrote two logs of 80
  epochs and 480 sentences each (GGA, GSA, three GSV, and RMC
  per epoch, fictional route from 39.5000, -98.5000 at
  8.0 m/s, second log from 39.5100, -98.4900 at 4.0 m/s);
  `check_checksums.py` re-verified every checksum: **480
  checked, 0 bad**, per file.
- gpsfake pipe mode, single-shot (t02): **888 lines** in
  total — **82 TPV** reports, **320 SKY** reports, and all
  **480** raw NMEA sentences echoed. The first full TPV reads
  `"time":"2026-06-15T12:00:00.000Z"`, `"mode":3`,
  `"lat":39.500000000`, `"lon":-98.500000000`,
  `"speed":8.000`, `"track":90.0000`. One finding is kept in
  the driver: gpsfake finds `gpsd` on `PATH`, and the lab's
  first attempt silently used the system 3.25 — the VERSION
  line exposed it, and the kept run reports 3.26.1.
- A real daemon on 2947 with gpspipe (t03): `gpspipe -w -n 12`
  printed VERSION, DEVICES (one device, `/dev/pts/2`, driver
  `NMEA0183`), WATCH, and TPV reports with mode 3, speed
  8.000 m/s, and track 90.0; `gpspipe -r` turned the same
  daemon's reports back into pseudo-NMEA sentences.
- SKY reports (t02, t03): `"nSat":11,"uSat":9`, with
  `"gdop":2.68,"hdop":0.90,"pdop":1.60`, and exactly the nine
  used satellites marked `"used":true`. That agreement exists
  because the generator's first GSA draft was short one
  satellite slot and the SKY report said `uSat 0` until the
  fixture — not the daemon — was fixed.
- The Python client (t04): `client_python.py` printed **3**
  decoded TPV reports, lat 39.5, lon moving from
  -98.499813333 eastward at 8.0 m/s, track 90.0.
- The WATCH handshake by hand (t05): over a raw socket, the
  greeting VERSION (release 3.26.1, protocol 3.15), answers
  to `?VERSION;` and `?DEVICES;`, then
  `?WATCH={"enable":true,"json":true};` answered by a DEVICES
  object and a WATCH object, TPV and SKY reports, and
  `?WATCH={"enable":false};` answered by a WATCH object with
  `"enable":false`.
- cgps and gpsmon (t06): `cgps -s` under a scraped terminal
  showed the fixture time `2026-06-15T12:00:02.000Z`,
  39.50 N 98.49981333 W, and "Seen 11/Used 9" with the
  satellite table. `gpsmon -a` through the daemon printed its
  four deprecation warnings, took a raw watch
  (`"raw":2,"pps":true`), and echoed the raw NMEA sentences
  with their lengths. gpsmon is deprecated in 3.26.1; the
  guide says so where it uses it.
- Two devices in one daemon (t07): gpsfake with both logs
  produced a DEVICES list with **two** devices
  (`/dev/pts/2` and `/dev/pts/3`), and gpspipe showed their
  TPV reports interleaved — lat 39.50 at 8.000 m/s and lat
  39.51 at 4.002 m/s, told apart by the `device` field.
- A daemon with no receiver (t08): a standalone built gpsd on
  127.0.0.1:18092, given `/dev/no-such-receiver-xyz`, logged
  `ERROR: initial GPS device /dev/no-such-receiver-xyz open
  failed` and "device activation failed", stayed up, and
  answered `?DEVICES;` with `"devices":[]` and `?POLL;` with
  `"active":0,"tpv":[],"sky":[]`. No hardware was faked: the
  point of the test is the absence.
- The GUI and direct routes that failed (t09): `xgps` printed
  `xgps: ERROR: DISPLAY not set`, and `gpsmon` given the log
  file parsed it as a server spec (`tcp://fixture-sky.nmea:2947`)
  and reported a read error. Both failures are transcripts,
  not asides.

Documented only — described from the project's documentation
and help text, not run, and the text does not claim otherwise:

- Everything involving real GPS hardware: serial and USB
  receivers, baud-rate and mode switching with `gpsctl`,
  hotplug via the control socket, and antenna or signal
  behaviour. This lab has no receiver.
- PPS (pulse per second) and precision timing: PPS reports,
  TOFF/PPS report handling beyond the TOFF lines gpsmon
  printed in t06, the shared-memory time export, KPPS (the
  build reports it disabled), and using gpsd to discipline a
  system clock with chrony or NTPsec.
- `xgps`, `xgpsspeed`, and the other graphical clients, which
  need a display and, per the build warnings, runtime
  libraries this machine does not have.
- `gpsmon` direct-from-device, which needs a real serial
  device to open; its via-daemon form was run.
- The other clients and feeders: `gpxlogger`, `gps2udp`,
  `lcdgps`, `gpscsv`, `gpsprof`, `ubxtool`, `zerk`, netfeed
  and NTRIP/DGPS inputs, AIS reports, and the D-Bus and
  shared-memory client interfaces.
- Distribution package installation routes other than noting
  that this machine's Ubuntu package existed and was missing
  `gpsfake` and `gpspipe`; the source build was run in full.
- The neighbouring tools in chapter 14 are characterised, not
  benchmarked.

Fixtures are this guide's own and deliberately generic: two
written NMEA logs for a fictional receiver on a fictional
rectangular route over invented farmland coordinates, on a
fictional date. No example is modelled on any real person,
vehicle, network, service, or organisation. One accident is
kept in the record: the lab's first gpsfake run tested the
wrong daemon (the system 3.25, found on `PATH`) and its
output was discarded — the transcripts in this guide are all
from the built 3.26.1, and chapter 3 teaches the VERSION
check that caught it.
