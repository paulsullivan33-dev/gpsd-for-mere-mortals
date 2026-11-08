# Limits

Outcome: the honest boundaries of what gpsd — and this
guide — can claim, in one place, so nothing earlier has to
be re-read with suspicion.

## gpsd reports what the receiver believes

The daemon is a translator and a publisher, not a surveyor.
If the receiver's fix is wrong — antenna in a poor place,
signals bouncing off a building into a confident error —
gpsd publishes the wrong position faithfully, with its
error estimates attached. Those estimates are the receiver
and geometry speaking, not a guarantee: `"epx":10.231` is a
model's belief about its own error, and real errors can sit
outside it. A fix is an **estimate**. The mode field grades
how much of a fix exists (chapter 10: mode 2 is a
two-dimensional claim, mode 3 the full claim, mode 1 is the
daemon relaying "the receiver cannot place itself"); it
does not certify that a mode 3 position is *true*. Software,
and readers, that need truth must add their own checks —
reasonableness over time, agreement between sources, a
human looking at the map.

## It cannot invent satellites

gpsd merges and interprets; it does not create signal. A
receiver that sees four satellites gets the fix four
satellites support. In this guide's lab the point is
sharper: the sky was **written**. A replayed log is a test
sky, not the sky — it contains no dropouts the author did
not write, no interference, no weather, no antenna, and its
perfect health (mode 3 from the first epoch, DOPs a real
roof would envy) is the fixture's, not the world's.
Everything verified here is verified about *plumbing*:
parsing, merging, reporting, sharing. Claims about
receivers — sensitivity, time-to-first-fix, behaviour under
trees — are outside this guide's evidence entirely, and the
text has labelled them documented-only wherever they appear.

## The daemon's view lags and filters the raw stream

A JSON client does not see the wire. It sees the daemon's
current picture, assembled sentence by sentence (chapter 5:
the TPV that gained its time and speed only when RMC
landed), re-published as reports several times per epoch,
and stamped with the fix's time — which is earlier than the
moment your program reads it, by the serial delay, the
parse, and the socket. For logging, mapping, and sharing,
that is the right trade and you will never feel it. For
packet forensics it is the wrong layer — the raw and
pseudo-NMEA views exist (chapters 7 and 9) precisely
because the daemon knows its JSON is a digest. Similarly
the daemon *decides things* on the device's behalf: which
driver a stream is, when a device is activated, how a
receiver is configured. Usually invisible; occasionally —
a misidentified stream, a device freed after activation
failed, chapter 11 — the decision is the story.

## Two different worlds of receiver

Nothing in software bridges the gap between a consumer USB
receiver and a timing-grade one. The first gives position
and sentence time, perhaps no PPS at all; the second is
built around the pulse and a surveyed antenna. Chapter 12's
timing pipeline needs the second. This lab has neither —
it stands outside both worlds, borrowing the first's
dialect for its fixture. A reader planning a purchase
should decide which world their job lives in before
choosing hardware, because gpsd will serve either
faithfully and promote neither.

## The rest of the boundary

One daemon per machine's receivers is the design; the
protocol has no authentication and no encryption — port
2947 is a local, trusted-network service, and exposing it
beyond that is a decision to make deliberately, not by
default. gpsd configures receivers it owns, which makes it
the wrong tool for a device another system is mid-session
with. And this guide's own limits ride along: the source
build was one version on one system; the GUI clients, real
hardware, PPS, netfeeds, and a dozen shipped tools are
documented-only, listed in criteria.md, and any sentence in
these chapters that sounds like a hardware claim traces
back to that list, not to a measurement.

Check: state the four limits in your own words — a fix is
an estimate; no invented satellites, and a replay is not
the sky; the JSON view lags and filters the stream;
consumer and timing receivers are different worlds. If one
of them surprises you, the chapter it came from is the one
to re-read before you build on this guide.
