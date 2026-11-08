# Sky, errors and fix modes

Outcome: a SKY report read as confidently as a TPV, the
error fields given their proper weight, and the mode number
understood for what it is — the daemon grading its own fix,
in public.

## The SKY report

Where TPV answers "where", **SKY** answers "on the evidence
of what". One full report from the fixture stream
(transcripts t02 and t03):

```
{"class":"SKY","device":"/dev/pts/2","gdop":2.68,
"hdop":0.90,"pdop":1.60,"tdop":1.48,"xdop":0.68,
"ydop":0.78,"vdop":1.30,"nSat":11,"uSat":9,
"satellites":[{"PRN":5,"gnssid":0,"svid":5,"az":60.0,
"el":43.0,"ss":42.0,"used":true}, ... ]}
```

- **nSat 11, uSat 9** — seen versus used. A satellite is
  *seen* when the receiver hears it well enough to report
  its position and signal strength; it is *used* when the
  fix's arithmetic actually included it. The generator
  wrote exactly this situation — nine in the GSA cast list,
  two more (14, 27) visible in GSV but unused — and the
  daemon preserved the distinction faithfully: in the full
  satellite list, precisely the nine carry `"used":true`.
  A receiver under a roof often shows the same shape for
  real: plenty seen through a window, few usable.
- **The DOP numbers** — dilution of precision. Geometry,
  in one figure: satellites spread across the sky pin a
  position down tightly (DOP near 1); satellites clustered
  in one corner let it slide (DOP large). `hdop` is the
  horizontal figure, `vdop` vertical, `pdop` the combined
  three-dimensional one, `gdop` the grand total including
  time. The fixture wrote HDOP 0.9 into its sentences and
  the daemon reported the family computed from the same
  cast: hdop 0.90, pdop 1.60, gdop 2.68 — an unrealistically
  *good* geometry, because the generator spread its
  satellites generously. A real sky is rarely this tidy.
- **Each satellite** carries its PRN (its number), azimuth
  and elevation (where it sits), `ss` (signal strength),
  and the used flag.

Not every SKY is complete: the stream also carries short
SKY reports with only a DOP or two and no satellite list,
sent as each source sentence lands — GGA updates one piece,
GSA another, GSV the list. A client that needs the full
picture waits for a SKY that has one; a client that prints
every SKY, like gpspipe in t03, shows the assembly in
progress. That is not noise; it is the daemon publishing
early and often rather than hoarding a finished picture.

## The errors are part of the fix

Return to chapter 5's full TPV and read the fields most
summaries skip: `"ept":0.005, "epx":10.231, "epy":11.734,
"epv":29.900, "eph":17.100, "sep":30.400`. These are the
daemon's **error estimates**, in seconds and metres: the
fix's time is believed good to 5 milliseconds; the position
to roughly ten metres east-west and twelve north-south; the
altitude to about thirty metres — vertical is nearly
always the weakest, in every receiver, because all the
satellites are above you and none below. `sep` is the
estimated three-dimensional sphere of doubt. gpsd did not
invent these numbers to decorate the report: it computed
them from the DOPs and the receiver's own quality figures.
A consumer that reads `lat` and `lon` and throws the rest
away has taken a measurement *with stated uncertainty* and
turned it into a false certainty. The guide's position,
stated once and applied everywhere: **the error fields are
part of the fix**.

## Modes: the daemon grading itself

The `mode` field is the summary grade:

- **0** — unknown: no data yet, or data too old to grade.
- **1** — **no fix**: the receiver is talking but cannot
  place itself (too few satellites, no valid solution).
- **2** — **2D fix**: latitude and longitude, no trustworthy
  altitude; the receiver is working with the minimum cast
  or poor geometry.
- **3** — **3D fix**: position and altitude both solved.

Every TPV in this guide's lab says 3, because the written
sky was written healthy — nine satellites, good geometry,
fix quality 1 in every GGA. That uniformity is the fixture
talking, not the world. In the field, a receiver warming up
walks 1 → 2 → 3 over its first minute, and drops back under
bridges and in cuttings; software that treats any non-3 TPV
as an error will report errors all day in exactly the
places a human would say "of course, we're under a bridge".
Software that treats mode 1 as a position will place you at
0, 0 or at the last fix, which is worse. The grade exists
so a client can decide *how much to believe* — and chapter
11's empty daemon shows the honest end of the scale: no
TPV at all, because there was nothing to grade.

One more honesty note, earned in this lab: when the
generator's first GSA draft carried eleven satellite slots
instead of twelve, gpsd read the DOP fields from the wrong
columns and reported `uSat 0` in its GSV-built SKY — a
written sky lying about its own cast, and the daemon
faithfully reporting the lie's consequences. The fixture
was fixed, not the daemon, and the re-run agreed to the
satellite. That is the whole relationship in miniature.

Check: from a live SKY, state nSat, uSat, and hdop, and
name one satellite that is seen but not used. From a TPV,
state the mode and the `epv`, and say in one sentence what
the two together claim.
