# Troubleshooting

Outcome: the failures this lab actually met — plus the
standard ones its transcripts explain — each with the check
that separates it from its look-alikes.

## The daemon answers, but it is the wrong daemon

**Symptom:** clients work, but behaviour or versions are
not what you installed. **Check the VERSION line** — the
greeting on any connection, or the first line of any
gpspipe run. This lab met the real case: gpsfake found the
system gpsd **3.25** on `PATH` while the lab believed it was
testing its **3.26.1** build, and only the VERSION report
(`"release":"3.25"`) told the truth. Any machine with a
package *and* a build, or an old service still running, can
do this. Fix the `PATH`, the service, or the port — and
re-run; results from the wrong daemon are not results.

## The port answers, the fix never comes

**Check `?DEVICES;` before anything else.** Three different
worlds hide behind "no data":

- `"devices":[]` — the daemon has no device at all. Its log
  will say why (chapter 11 kept the exact lines: the device
  failed to open and was freed). The receiver is unplugged,
  the path is wrong, or the device was never added.
- A device is listed but never *activated* — it exists and
  has not spoken, or no client has asked and nowait is off.
  Start a watch, wait a cycle or two, and read the daemon's
  log at debug level before blaming the sky.
- TPVs arrive with `"mode":1` — the receiver talks but
  cannot fix: too few satellites in view. That is a sky and
  antenna problem, faithfully reported; SKY's nSat will
  show how little it has to work with.

## Reports arrive, but fields are missing

A TPV without `time` or `speed` is usually **assembly, not
failure** (chapter 5): the epoch's GGA has landed, its RMC
has not. Wait an epoch before diagnosing. A TPV permanently
missing altitude with mode 2 is the receiver's honest
grade — accept it or improve its sky. And a SKY report
without a satellite list is one of the short, partial SKYs
the daemon publishes mid-assembly; wait for one carrying
`"satellites"`. If fields vanish *mid-stream*, suspect the
log or wire instead: sentences with failed checksums are
dropped by design, which in a written sky means re-running
chapter 4's checker before suspecting the daemon — the lab's
own `uSat 0` surprise was a malformed GSA in the fixture,
found in the fixture.

## cgps paints nothing, or "unknown terminal"

cgps is a curses program: it needs a real terminal and a
sane `TERM`. In scripts and scrapers it fails with terminal
errors — the lab's first attempt answered `Error opening
terminal: unknown` until run under `script(1)` with `TERM`
set. For non-interactive checks, do not fight it: gpspipe
or the by-hand socket (chapter 8) answer the same questions
in plain text. Similarly, `xgps` failing with `DISPLAY not
set` is information, not a crash: there is no display.
Do not "fix" either by installing a desktop on a server;
switch to the client that fits the environment.

## Two programs, and the receiver changed under both

A rate or mode change made by one tool — `gpsctl`, a
vendor utility run directly against the device — rewrites
the stream every watcher is reading. If reports change
character for all clients at once, ask who touched the
device; chapter 1's rule exists precisely to make that a
short list. The daemon's own reconfiguration is in its log;
a foreign program's is not.

## The feeder stalls, loops, or ends early

With gpsfake: a client connecting to silence usually means
the feeder was started *without* `-n` and is waiting, or
with `-1` and already finished — check for the "log cycle
begins" line that distinguishes looping from done. A
`SHM: shmctl ... Operation not permitted` line at shutdown
in a sandboxed environment is cleanup noise (chapter 6);
the test is whether clients were served, and in this lab
they were. Finally, if two feeders or daemons contend for
2947, the second cannot bind the port — find the first
(`ss -tlnp | grep 2947`) and decide which one owns the
number; the protocol has no sharing arrangement for its
own socket.

Check: for any gpsd problem you meet this week, perform the
three opening moves in order — read the VERSION greeting,
ask `?DEVICES;`, ask `?POLL;` — and write down what each
said before changing anything. Most entries above are
diagnosed by the time the third answer arrives.
