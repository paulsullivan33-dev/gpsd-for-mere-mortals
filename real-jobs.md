# Real jobs

Outcome: three working jobs assembled from the parts the
earlier chapters proved — a fix logger, one receiver shared
by several programs, and a small client of your own that
reacts to fixes — each honest about which layer it stands
on.

## Job 1: log the fixes

The plain job: record where the receiver went, as it went
there. gpspipe is the whole tool:

```
gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea &   # the lab's stand-in receiver feed
gpspipe -w -o route.json 127.0.0.1:2947
```

In production the first line is a receiver and a standing
daemon instead of the feeder; the second line is unchanged.
The file fills with one JSON object per line — VERSION and
DEVICES at the top, TPV and SKY after — which later reading
can filter by class with ordinary text tools:

```
grep '"class":"TPV"' route.json | wc -l
```

One TPV per epoch is the expectation (chapter 5 counted 82
for 80 epochs, the extras being GGA's head start on RMC in
the first epochs — a logger that needs exactly one row per
second should key rows by the TPV's `time`, not count
lines). The project also ships `gpxlogger`, a client that
writes the track in GPX format for map tools directly; it
was not run in this lab and is named here as
documented-only — the gpspipe job above was run, in pieces,
in every chapter since chapter 6, which is why it is the
one this guide teaches.

## Job 2: one receiver, every program

The job gpsd was invented for. A machine with one receiver
runs the daemon once — started by the system, owning the
serial device, nowait on — and then every consumer simply
connects: the logger of job 1, a cgps screen on the console
for the human, a map program on the desktop, and the time
service reading over its own interface. The lab's running
demonstration is chapter 6 plus chapter 9: feeder up,
gpspipe in one terminal, the Python client in another, cgps
in a third — three readers, one device, no interference,
each disconnecting without disturbing the others. Adding a
reader never means re-wiring the receiver's day; removing
one never means a restart. The operational rules that keep
this job healthy are chapter 1's rule in work clothes:
consumers connect to the socket, full stop; anything that
wants to *change* the receiver — a `gpsctl` mode switch, a
rate change — is coordinated like the shared resource it
is, because every other reader's stream changes with it.

## Job 3: a client of your own

The step from reading fixes to *using* them is small, and
the lab's Python client is the seed: iterate reports, keep
a class, act. A realistic small shape — "tell me when the
receiver is actually moving, with a fix worth trusting":

```
for report in session:
    if report.get("class") != "TPV":
        continue
    if report.get("mode") != 3:
        continue                      # chapter 10: the grade
    if (report.get("speed") or 0) > 0.5:
        print("under way:", report.get("time"),
              report.get("lat"), report.get("lon"))
```

Every line of that filter is a chapter: the class test
(chapter 9), the mode grade (chapter 10), the speed field
in metres per second (chapter 7). What the lab ran printed
three decoded TPVs (t04); this moving-detector variant is
the same loop with conditions the guide has already
verified field by field, and is offered as a pattern to
adapt, not as a fourth transcript. Keep the error fields in
any real version: "under way at eph 17 m" and "under way at
eph 400 m" are different claims, and your future self,
reading the log in a dispute about where something was,
will want to know which one you made.

Check: assemble job 1 against the feeder and produce a
`route.json` whose TPV count you can explain to within the
chapter 5 assembly effect. Then open a second connection —
any client — while it logs, and confirm the log never
pauses. Sharing without disturbance is the deliverable.
