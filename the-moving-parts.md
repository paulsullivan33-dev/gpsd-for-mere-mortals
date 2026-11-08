# The moving parts

Outcome: a map of the parts inside every gpsd setup — the
receiver, the daemon, the device record, the reports, and
the clients — so that when a later chapter names a behaviour
you know which part produced it.

## The receiver and its sentences

At the bottom is the receiver itself, sending sentences
about once a second (its **cycle**). gpsd identifies the
protocol from the bytes: plain NMEA 0183 text, or one of the
binary protocols from receiver makers — the lab's build
lists 30-odd compiled-in drivers in its help text, from
u-blox and SiRF to Garmin and Trimble (transcript
`gpsd-lab/transcripts/t00-system-and-versions.txt`). You do
not pick the driver in ordinary use; gpsd recognises the
stream. In this guide's lab the "receiver" is a file and
gpsfake's pretend serial port, and the sentences are NMEA,
because NMEA is the dialect a reader can take apart by eye —
chapter 4 does.

## The daemon

gpsd proper. It opens each **device** it is told about — a
serial path like `/dev/ttyUSB0`, a network feed, or, in the
lab, a pseudo-terminal gpsfake created — reads its sentences,
merges them into a single current picture per device, and
serves that picture to clients. Two switches matter early:
**-n** (**nowait**) tells gpsd to poll devices even when no
client is connected, instead of waiting for a watcher before
it starts listening to the receiver; and **-N** keeps it in
the foreground, which is how you watch a new setup behave.
Its listening port is set with **-S** and defaults to 2947.

gpsd also keeps a **control socket** — a private socket file,
separate from the client port — through which tools like
`gpsdctl` can tell a running daemon to add or remove a device
without restarting it. The lab's absent-device run (chapter
11) names one with `-F`; hotplug in real installs is
documented-only here, and criteria.md says so.

## The device record

For each device, gpsd maintains what it knows: the path, the
driver it matched, the speed it is running at, when it was
**activated**, and its cycle. Clients meet this record in the
**DEVICE** and **DEVICES** reports (chapter 8). A device with
no data yet is not an error — it is a receiver that has not
spoken, or has not been asked. The daemon distinguishes
"no device", "device present but silent", and "device
reporting" carefully, and chapter 11 shows all the honest
answers it gives in the first case.

## The reports

The daemon's output is a small family of JSON objects, each
with a `"class"` field naming its kind:

- **TPV** — time-position-velocity: the fix. Time, latitude,
  longitude, altitude, speed, track (heading), climb, a
  **mode** (0 unknown, 1 no fix, 2 two-dimensional,
  3 three-dimensional), and error estimates. Chapter 7 reads
  one field by field.
- **SKY** — the satellite view: how many satellites are seen
  (**nSat**) and used in the fix (**uSat**), each satellite's
  position and signal strength, and the **DOP** values —
  dilution of precision, the geometry quality numbers.
  Chapter 10.
- **DEVICE / DEVICES** — the device records, above.
- **VERSION** — the daemon's release and the protocol
  version it speaks; the greeting every connection begins
  with. Chapter 8.
- **WATCH** — the echo of a client's own watch request: what
  it will and will not be sent.
- **ERROR** and **POLL** — an error message, and the answer
  to "tell me everything you currently know" without a
  watch, respectively. Both appear in chapter 11.
- A few more (GST, PPS, TOFF, AIS) belong to error detail,
  timing, and marine traffic; chapter 12 meets the timing
  pair, and the rest are named in the glossary.

Reports are *merged views*, not the raw stream with braces
around it: one TPV may be assembled from two different
sentences of the same second, as chapter 5 watches happen.

## The clients

Anything that connects to port 2947 and asks for a watch.
The project ships several: **gpspipe** (dumb pipe: reports
out as text, chapter 7), **cgps** (a terminal screen,
chapter 9), **gpsmon** (a developer tool that prefers the
raw stream, chapter 9), **xgps** (a graphical sky view —
documented-only in this lab, which has no display), plus
loggers and feeders named in chapter 13. Under them all is a
client library — the lab uses its Python form in chapter 9 —
and under that, as chapter 8 proves, a plain text protocol
any program can speak with a socket and one line of JSON.

Check: name the five parts in order — receiver, daemon,
device record, reports, clients — and say which report class
carries the fix. If you can, the rest of the guide has
somewhere to hang.
