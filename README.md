# GPSD for Mere Mortals

A GPS receiver is a talkative serial
device. Once a second it pours out
sentences — position, time, speed, the
satellites it can see — in its own
dialect, and it expects exactly one
program to be listening. The moment two
programs want the position — a map, a
logger, a clock — they start fighting
over one serial port, and each of them
has to learn the dialect for itself.
**gpsd** ends the fight: it is a
**daemon**, a background program, that
owns the receiver, understands every
dialect it speaks, and republishes
what it hears as plain JSON over a
network socket that any number of
programs can read at once.

One rule governs everything it does,
and this guide states it in chapter 1
and keeps pointing back to it: **one
daemon talks to the receiver, and every
other program listens to the daemon.**
gpsd speaks for the receiver so
everything else can just listen. The
daemon holds the serial port and is the
one source of truth about position,
time, and the sky; clients that trust
its JSON never open the device, never
parse a sentence, and never steal each
other's data. Almost every surprise in
this guide is that rule seen from a new
angle — the client that asked the
device directly and got a server
address instead, the second receiver
that simply became a second device in
the same daemon, the empty answer a
daemon gives, honestly, when its
receiver is not there at all.

The lab behind this guide ran the real
thing, and it is honest about how:
there is **no GPS hardware in the
lab**. gpsd **3.26.1** was built from
the project's official source tarball
(the machine's own package was missing
`gpsfake` and `gpspipe`), and the sky
it listened to was written, not
received: a small generator produced a
checksum-correct NMEA log — a fictional
receiver driving a slow rectangle over
invented farmland coordinates — and
**gpsfake** replayed that log through
a real gpsd on port **2947**. Against
that daemon the lab read real fixes
with `gpspipe` (TPV reports, mode 3,
latitude, longitude, speed, and track
all present); spoke the `?WATCH`
handshake by hand over a raw socket;
ran a second client in Python using
gpsd's own bindings; scraped the
`cgps` screen (11 satellites seen,
9 used); watched `gpsmon` take the raw
stream through the daemon; fed one
daemon **two** skies at once and
watched two devices interleave; and
started a daemon with a receiver that
does not exist, to record the error it
logs and the empty lists it answers
with. A replayed log is a test sky, not
the sky — chapter 15 keeps that
distinction sharp.

What the lab could not do, it did not
fake. `xgps` needs a display this
machine does not have; `gpsmon`
direct-from-device needs a real serial
receiver; PPS timing needs timing
hardware. Those are described from the
project's documentation, labelled
documented-only, and `criteria.md`
keeps the full ledger.

## What this guide covers

- [**What gpsd is**](what-gpsd-is.md) —
  the fight over the serial port, and
  the one rule that ends it
- [**The moving parts**](the-moving-parts.md) —
  the receiver, the daemon, the device,
  the reports, and the clients
- [**Installing gpsd**](installing-gpsd.md) —
  the package that was missing pieces,
  the source build the lab ran, and the
  warnings it printed
- [**Building a test sky**](building-a-test-sky.md) —
  NMEA sentences, checksums, and the
  written log the whole lab listens to
- [**Your first fix**](your-first-fix.md) —
  gpsfake pipe mode, and the first TPV
  with a time, a speed, and a track
- [**A real daemon on port 2947**](a-real-daemon.md) —
  gpsfake as the feeder, a daemon other
  programs can connect to, and who owns
  its lifetime
- [**Reading with gpspipe**](reading-with-gpspipe.md) —
  JSON out with `-w`, pseudo-NMEA back
  out with `-r`, and the fields of a TPV
- [**The WATCH handshake by hand**](the-watch-handshake.md) —
  VERSION, DEVICES, and WATCH over a raw
  socket, the protocol every client speaks
- [**Other clients**](other-clients.md) —
  the Python bindings, the cgps screen,
  gpsmon through the daemon, and the
  GUI client that could not run here
- [**Sky, errors and fix modes**](sky-errors-and-fix-modes.md) —
  the SKY report, seen versus used
  satellites, error estimates, and why
  mode 3 is a claim, not a promise
- [**More than one device**](more-than-one-device.md) —
  two skies in one daemon, and the
  daemon with no receiver at all
- [**Time and PPS**](time-and-pps.md) —
  the time in the reports, the pulse
  this lab does not have, and what is
  documented-only here
- [**Real jobs**](real-jobs.md) — logging
  fixes, sharing one receiver between
  programs, and a client of your own
- [**The neighbours**](the-neighbours.md) —
  reading the serial port yourself,
  simulators, clocks, and map programs
- [**Limits**](limits.md) — a fix is an
  estimate, a replay is not the sky,
  and the daemon's view lags the stream
- [**Troubleshooting**](troubleshooting.md) —
  the wrong gpsd, the empty device list,
  the fix that never gains a time, and
  the screen that will not paint
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Driving real receivers in depth —
antenna siting, receiver configuration
with `gpsctl` and vendor tools, RTK
corrections, and NTRIP are named where
they belong and left to the project's
documentation. Precise timekeeping
(using gpsd to discipline a system
clock) is covered only as far as the
lab could honestly go: no PPS source
exists here. Nothing here listens to
anyone else's receiver: every example
talks to a daemon on the reader's own
machine, fed by a written log.

## How to use this guide

Read chapter 1 for the rule and
chapter 2 for the map of parts.
Chapter 4 builds the test sky every
later chapter listens to; chapters 5
and 6 get a fix flowing, first inside
`gpsfake` and then from a daemon other
programs can reach. Chapter 8 is the
one to read slowly: once you have
spoken `?WATCH` by hand, every client
in every later chapter is a program
doing exactly that on your behalf. The
lab's scripts and logs live in
`gpsd-lab/` (`make_nmea.py` writes the
sky, `check_checksums.py` verifies it,
`client_python.py` and
`watch_by_hand.py` are the clients,
`drivers/` reproduces each test), its
evidence in `gpsd-lab/transcripts/`,
its distilled commands are
`examples/commands.txt` and its notes
`examples/lab-notes.txt`.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Text Processing for Mere Mortals](https://paulsullivan33-dev.github.io/text-processing-for-mere-mortals/)
- [Vim for Mere Mortals](https://paulsullivan33-dev.github.io/vim-for-mere-mortals/)
- [Markdown for Mere Mortals](https://paulsullivan33-dev.github.io/markdown-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/gpsd-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/gpsd-for-mere-mortals/blob/main/LICENSE-CODE).
