# What gpsd is

By the end of this chapter you can say, in one sentence, what
gpsd takes off your hands — and state the one rule that
decides whether your programs share a receiver peacefully or
fight over it.

## The receiver nobody can share

A GPS **receiver** — the small puck, board, or USB stick that
listens to the satellites — talks on a **serial port**: one
wire, one conversation. About once a second it sends a burst
of text sentences. Each sentence carries one kind of fact:
this is the position, this is the time, these are the
satellites in view, this is the speed and heading. The most
common dialect for those sentences is called **NMEA 0183**,
and chapter 4 takes one apart.

One conversation is the problem. A serial port can be opened
by programs that then share the incoming bytes unpredictably:
each reader may get some sentences and miss others, and any
program that wants to *configure* the receiver — change its
rate, switch a sentence on — writes into the same stream the
others are reading. Meanwhile every program that wants the
position must learn the dialect itself: NMEA today, a binary
protocol from the receiver's maker tomorrow. Write three
programs that use a receiver and you have built three parsers
and a custody dispute.

## The daemon in the middle

**gpsd** is a **daemon** — a program that runs in the
background, started once, and stays — whose whole job is to
sit in that conversation so nothing else has to. It opens the
receiver, learns which protocol it speaks (it knows NMEA and
most makers' binary protocols), and translates everything the
receiver says into one published form: **JSON** reports —
small text objects with named fields — sent over a **TCP
socket**, a network connection on the same machine, at the
port gpsd has used for decades: **2947**. Any program that
connects and asks politely (chapter 8 shows the asking, which
is one line of text) receives the reports as they happen: a
**TPV** report for time, position, and velocity; a **SKY**
report for the satellites; and a handful of others chapter 2
maps.

Now three programs read the same receiver without touching
it. A map, a logger, and a clock each hold their own socket
to gpsd, and gpsd holds the one serial port. Adding a fourth
reader costs gpsd nothing. That is the whole product.

## The rule: one talker, everyone else a listener

> **One daemon talks to the receiver, and every other
> program listens to the daemon.**

gpsd speaks for the receiver so everything else can just
listen. The daemon owns the device and is the single source
of truth about what the receiver currently believes — where
it is, what time it thinks it is, which satellites it used.
Clients that trust the daemon's JSON never open the serial
port, never parse a sentence, and never reconfigure a device
other clients are depending on.

The rule cuts both ways, and the guide will keep showing it.
A client that goes around the daemon — chapter 9 watches one
try to read a log file as if it were a device — is not being
clever; it has left the arrangement that makes sharing work.
And the daemon itself is a listener's tool, not an oracle:
it republishes what the *receiver* believes, with the
receiver's errors attached. Chapter 10 reads those error
fields, and chapter 15 is blunt about the difference between
a daemon faithfully reporting a bad fix and the world
actually being where the fix says.

## Where it comes from, and what this guide ran

gpsd is a free, open-source project with a long history; its
home is gpsd.io and its source lives on GitLab. It runs on
Linux and the other Unix-like systems, and a great deal of
software — map programs, navigation tools, time servers —
already knows how to be its client. This guide's lab built
**gpsd 3.26.1** from the project's official source tarball
and, having no GPS hardware at all, fed it a *written* sky:
a fictional NMEA log replayed by gpsd's own testing tool,
**gpsfake**. Every fix in this guide is therefore real
gpsd behaviour and a fictional position — the plumbing was
tested for real, the sky was not, and chapter 4 explains
exactly how the sky was written.

Check: say what owns the serial port in a gpsd setup, what
port the daemon serves, and the rule, out loud once. If you
can, every later chapter has somewhere to hang.
