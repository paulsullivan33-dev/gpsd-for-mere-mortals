# Time and PPS

Outcome: what gpsd knows about *time* — the time riding in
every fix, the sharper signal this lab does not have, and a
clear line between what was run here and what is described
from the documentation.

## The time in the reports

GPS is, among other things, a clock: every receiver must
solve for time to solve for position at all. That time
rides through gpsd in plain sight. The fixture's RMC
sentences carried a time *and a date*; GGA carried the time
alone; the daemon merged them into the TPV's ISO timestamp,
`"time":"2026-06-15T12:00:00.000Z"` — the fictional noon of
the written sky, reported with an `"ept":0.005`, a claimed
time uncertainty of five milliseconds. The SKY report's DOP
family includes a `tdop`, time dilution, for the same
reason: the time solution has geometry too.

Two cautions belong here. First, **the daemon reports the
receiver's time, not the truth's**: a replay dated 15 June
2026 was believed completely, as chapter 5 saw. A client
that sets anything by gpsd time is trusting the receiver —
usually wisely, since GPS time is excellent, but the trust
is in the hardware and its sky view, not in the daemon.
Second, sentence time is *coarse* time: it says which second
the fix belongs to, delivered some hundreds of milliseconds
later over a serial wire, as chapter 15 notes. For
timestamps on data — logging when a reading was taken — it
is the right tool. For knowing the exact instant *now*, it
is not, and that gap is what PPS exists to close.

## PPS: the pulse this lab does not have

Better receivers expose a second output beside the data: a
**PPS** signal — pulse per second — an electrical edge that
arrives at the top of each second with microsecond-grade
honesty. Data says *which* second; the pulse says *when*,
exactly. gpsd can consume both: it matches each pulse to
the sentence that names its second and emits **PPS** and
**TOFF** reports (time offset: the difference between the
pulse's arrival by the system clock and the true top of the
second), and it can hand the result to a time server
through a shared-memory interface, so a machine can
discipline its clock from GPS. That pipeline — receiver,
gpsd, chrony or NTPsec, system clock — is the standard way
small machines keep excellent time without a network.

**None of that was run in this lab, and the text will not
pretend otherwise.** There is no receiver here, hence no
pulse; the build itself reports its kernel PPS support
disabled (`# KPPS DIS-abled.` in the help text, transcript
t00). The honest traces the lab *does* have are small ones:
gpsmon, reading through the daemon, printed `TOFF=` lines
(chapter 9) — its offset arithmetic running on a fixture,
producing absurd values because the "receiver time" was a
written June noon and the system clock a November evening.
Those lines are quoted as evidence that the machinery
exists and engages, and as a warning about believing offset
numbers from a replay — not as a timing measurement. PPS
reports, the shared-memory time export, `ntpshmmon`, and
clock disciplining are **documented-only** in this guide:
described here from the project's documentation, listed as
not run in criteria.md, and left for a lab with timing
hardware to verify.

## Which world are you in

The distinction that decides whether any of this matters:
a **consumer receiver** — a USB puck, a phone-grade chip —
offers position and sentence time, often with no PPS pin at
all, or one that is not wired out. A **timing receiver** is
built for the pulse: PPS out, a stationary surveyed
position, time as the product. Software cannot promote one
into the other; gpsd serves both faithfully and reports
what each actually provides, which is why this chapter's
lab section is short and its labelling long. If time is
your real goal, buy for the pulse first and read the
project's timing documentation with hardware in hand.

Check: from any TPV in your transcripts, quote the `time`
and the `ept`, and state where each came from (RMC and GGA;
the daemon's estimate). Then say, in one sentence, what PPS
would add — and whether the receiver you are imagining has
one.
