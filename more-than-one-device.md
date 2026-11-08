# More than one device

Outcome: one daemon serving two receivers at once, their
reports told apart at a glance — and the same daemon, given
a receiver that does not exist, answering honestly with
nothing. Both halves were run; neither is tidied up.

## Two skies, one daemon

A daemon is not limited to one device. Real setups pair a
fixed receiver with a portable one, or a primary with a
backup. The lab's version uses gpsfake's other trick: give
it **two log files** and it builds two pretend devices and
starts one daemon over both:

```
gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea fixture-sky-2.nmea &
```

The handshake reports the arrangement plainly (transcript
`gpsd-lab/transcripts/t07-two-devices.txt`): DEVICES now
lists **two** DEVICE objects, `/dev/pts/2` and `/dev/pts/3`,
both driver `NMEA0183`, both activated a tenth of a second
apart. And the report stream interleaves the two routes,
each report carrying the name of its device:

```
{"class":"TPV","device":"/dev/pts/2","mode":3,
"time":"2026-06-15T12:00:00.000Z","lat":39.500000000,
"lon":-98.500000000, ... "speed":8.000, ...}
{"class":"TPV","device":"/dev/pts/3","mode":3,
"time":"2026-06-15T12:01:00.000Z","lat":39.510000000,
"lon":-98.490000000, ... "speed":4.002, ...}
```

Sky 1 at 8 metres a second, sky 2 at 4 — the second log's
4.0 m/s, surfacing as 4.002 after the knots round-trip in
its RMC sentences, a detail the transcripts keep because it
teaches the general lesson: values pass through the
receiver's dialect on the way in, and the dialect's
rounding comes with them. A client that cares about one
receiver filters or watches by `device` — the WATCH request
can name a device, and POLL answers per device — while a
client that watches everything receives both streams on one
connection, which is how a monitoring program watches a
whole site through a single socket. Chapter 1's rule
scales without changing shape: the daemon talks to *each*
receiver; everyone else still just listens.

## No sky at all

Now remove the receiver entirely. The lab started the built
daemon by hand — the production shape from chapter 6 — on
the lab's extra-instance port, 127.0.0.1:**18092**, pointed
at a device path that does not exist:

```
gpsd -N -n -D 2 -S 18092 -F <scratch>/run/ctl.sock \
     /dev/no-such-receiver-xyz
```

(transcript `gpsd-lab/transcripts/t08-absent-device.txt`).
Three facts, all worth more than a success would be:

1. **The daemon stays up and says what happened.** Its log
   carries the failure in plain terms:
   `ERROR: SER: stat(/dev/no-such-receiver-xyz) failed`,
   `ERROR: initial GPS device /dev/no-such-receiver-xyz
   open failed`, and finally "device activation failed,
   freeing device". A daemon that cannot open its device
   does not crash, does not invent a position, and does not
   hide the reason.
2. **Clients get empty answers, not errors about errors.**
   The greeting is a normal VERSION — the *daemon* is fine.
   `?DEVICES;` answers `{"class":"DEVICES","devices":[]}`.
   `?POLL;` answers
   `{"class":"POLL","time":..., "active":0,"tpv":[],
   "gst":[],"sky":[]}` — a snapshot of nothing, precisely
   itemised.
3. **"Daemon up" and "receiver working" are separate
   facts**, and the protocol keeps them separate if you
   read what it sends. Every troubleshooting path in
   chapter 16 that ends at "the port answers but there is
   no fix" is standing on this transcript.

Nothing here was faked: there is no pretend missing
receiver, just a path that is not there and a daemon
declining to lie about it. The same behaviour is what a
real installation shows in the minutes before an unplugged
receiver is noticed — the socket green, the device list
empty, the log already explaining why.

Check: with two feeders running, take a gpspipe sample and
sort the TPVs by their `device` field; you should find both
routes present. Then ask any daemon `?POLL;` and read the
`active` count before you read anything else — it is the
fastest truthful sentence the protocol speaks.
