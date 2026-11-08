# The WATCH handshake by hand

Outcome: the gpsd protocol spoken by hand, over a raw socket
— the greeting, the three questions every client asks, the
reports, and the polite goodbye — so no client program ever
looks like magic again.

## Why by hand

Every client in this guide — gpspipe, cgps, the Python
library — does the same small ceremony when it connects.
Doing it once yourself, with nothing between you and the
socket but a few lines of Python, turns the ceremony into
knowledge: you will know what a client *can* ask, what the
daemon answers unasked, and where a stalled client is
actually stuck. The lab's instrument is
`gpsd-lab/watch_by_hand.py`: a plain TCP socket to
127.0.0.1:2947, no gps library at all. Its transcript is
`gpsd-lab/transcripts/t05-watch-by-hand.txt`, against the
chapter 6 feeder.

## The greeting: VERSION arrives unasked

Connect, and before you send a byte, the daemon speaks:

```
<<< {"class":"VERSION","release":"3.26.1","rev":"3.26.1",
     "proto_major":3,"proto_minor":15}
```

That one line is chapter 3's version check, built into the
protocol: any client, however small, learns immediately
which daemon it has reached (3.26.1) and which dialect of
the protocol it speaks (3.15). A client library compares
the protocol version against its own and complains early
instead of misreading reports later. You can ask again with
`?VERSION;` — commands to gpsd are lines starting with `?`,
ending with `;` — and get the same object back.

## The questions: DEVICES, then WATCH

```
>>> ?DEVICES;
<<< {"class":"DEVICES","devices":[{"class":"DEVICE",
"path":"/dev/pts/2","driver":"NMEA0183","readonly":"true",
"activated":"2026-11-07T22:17:00.142Z","flags":1,"native":0,
"bps":4800,"parity":"N","stopbits":1,"cycle":1.00}]}
```

One device, at the pretend serial port, matched to the
NMEA0183 driver, running at 4800 baud (the fictional
receiver's rate, which gpsfake set), one-second cycle. In a
real installation this list is how a client discovers what
it may watch — and chapter 11 shows it with two entries,
and with none.

Then the request that starts the data flowing:

```
>>> ?WATCH={"enable":true,"json":true};
<<< {"class":"DEVICES", ...}
<<< {"class":"WATCH","enable":true,"json":true,
"nmea":false,"raw":0,"scaled":false,"timing":false,
"split24":false,"pps":false}
```

Note the *two* answers: a fresh DEVICES object first (the
daemon re-announces its devices to a new watcher), then the
**WATCH** object — the daemon's echo of your request as
understood, field by field. `json:true` is what you asked
for; `nmea:false, raw:0` are the views you did not. A client
that asked for the wrong thing can read its mistake right
here, in the echo, instead of wondering at the stream. From
this moment the daemon sends reports as they occur — in the
transcript, TPV and SKY objects identical to the ones
gpspipe printed, because they are the same stream:

```
<<< {"class":"TPV","device":"/dev/pts/2","mode":3,
"time":"2026-06-15T12:00:02.000Z", ... "speed":8.000, ...}
<<< {"class":"SKY","device":"/dev/pts/2", ... "uSat":9}
```

## The goodbye, and the other verb

Reports flow until you stop them. The polite stop is the
same command, disabled — and again the daemon echoes it:

```
>>> ?WATCH={"enable":false};
<<< {"class":"WATCH","enable":false,"json":true, ...}
```

One more verb completes the working set: `?POLL;` asks for
the daemon's current picture *once*, without a watch — a
snapshot instead of a subscription. The hand client does
not use it (a watch was the lesson), but chapter 11 does,
against a daemon with nothing to report, where its answer —
`"active":0,"tpv":[],"sky":[]` — is the protocol being
precisely as informative as reality allows.

Everything in this chapter fits on one screen because it
*is* the whole client protocol for reading: connect, read
the greeting, ask what exists, watch, read, unwatch. The
libraries add buffering, decoding, and manners; they do not
add mystery. When a client misbehaves, repeating its steps
by hand — this script takes thirty seconds to adapt — shows
which step the daemon answered differently than the client
expected.

Check: run `watch_by_hand.py` against the feeder and point
at each of the four objects in order: VERSION, DEVICES,
WATCH, TPV. Then say what changed in the WATCH echo when the
script asked to stop. If you can, you can debug any gpsd
client ever written.
