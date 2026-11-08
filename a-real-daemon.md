# A real daemon on port 2947

Outcome: a gpsd that stays up on its own port, fed by
gpsfake, that *separate* programs connect to — the shape of
every real gpsd installation, with a feeder standing in for
the receiver.

## From pipe mode to a standing daemon

Chapter 5's daemon was gpsfake's private arrangement: it
lived inside the pipe run and served one built-in client.
Drop `-p` and say where the daemon should listen, and
gpsfake becomes purely a feeder:

```
gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea &
```

- **-P 2947** sets the daemon's listening port. 2947 is
  gpsd's own default — the port every gpsd client tries
  first, and the one this lab uses under the series' rule
  that a tool's own protocol port is a legitimate specific
  port. The lab only ever connects to it as 127.0.0.1:2947.
- **-n** is passed through to the daemon as its **nowait**
  behaviour: start reading the device at once, do not sit
  idle until the first client arrives. Without it, a
  daemon with no watchers lets its receiver sleep — correct
  on a boat, confusing in a lab, where the first client
  would connect to a device that has produced nothing yet.
- **-c 0.1** slows the feed to a tenth of a second between
  sentences — about 0.6 s per six-sentence epoch — so a
  human starting clients by hand catches the route near its
  beginning. The default pace would blast the whole log
  through in a blink, looping.
- Without **-1**, gpsfake **loops** the log: when the
  80 epochs end, the cycle begins again (its log says so —
  `gpsfake: log cycle of fixture-sky.nmea begins.`). A
  looping sky is why every client in the next chapters can
  start whenever it likes and still get a fix: the receiver
  in this lab never stops talking.

## Who owns what

Three lifetimes, kept separate in your head:

1. **gpsfake** owns the pretend device and the feeding. It
   created the pseudo-terminal (`/dev/pts/2` in the
   transcripts — the number is the machine's, yours will
   differ) and writes the log down it.
2. **The gpsd gpsfake started** owns port 2947 and the
   client connections. It is an ordinary daemon in every
   respect a client can detect: same greeting, same
   protocol, same reports as a daemon started by hand
   (chapter 8 proves it by hand; chapter 11 starts one by
   hand for contrast).
3. **Your clients** own only their connections. Any number
   may come and go; the daemon and the feed continue. That
   is chapter 1's rule in running form — one talker at the
   device end, everyone else listening at the socket end.

Stopping is the mirror image: stop gpsfake (the drivers use
its process ID) and its daemon and device go with it. One
sandbox quirk appears in the feeder's log at shutdown and
is recorded rather than tidied away:

```
SHM: shmctl(18) for IPC_RMID failed, Operation not permitted(1)
```

gpsd exports a shared-memory segment for one of its client
interfaces; this sandbox would not let it remove the
segment on exit. Clients over the socket were unaffected,
before and after — a warning about cleanup, not about data,
in *this* environment. On an ordinary machine you should
not see it.

## A standalone daemon, for contrast

gpsfake is a lab tool. The production shape is gpsd started
directly — by the system's service manager, or by hand for a
test — with devices named on its own command line:

```
gpsd -N -n -S 2947 /dev/ttyUSB0
```

reads as: stay in the foreground (-N, for testing), poll
without waiting for clients (-n), listen on 2947 (-S),
and own the receiver at that serial path. The lab runs
exactly that shape once, in chapter 11, on a second port
with a device that does not exist — where the difference
between "daemon up" and "receiver working" becomes
impossible to miss. Here, the feeder arrangement stands in
for it, and the chapters are careful to say which daemon
each client is talking to.

Check: start the feeder, then connect with any client from
chapter 7 or 8 in a second terminal. Then start a *second*
client while the first still runs. Both receive reports —
that, in one observation, is the whole reason gpsd exists.
