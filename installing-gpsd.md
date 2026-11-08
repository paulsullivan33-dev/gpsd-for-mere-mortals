# Installing gpsd

Outcome: gpsd and its full tool set on the machine, at a
version you have *verified* — and a clear record of what the
easy route was missing, which is why this lab built from
source.

## The package route, and its gap in this lab

Most readers should start with their system's package:
gpsd is in the ordinary repositories of the major Linux
distributions, and a package install also brings the system
service files this guide does not cover. This lab's machine
already had exactly that: an Ubuntu package providing
gpsd **3.25**, with `cgps` and `gpsmon` (transcript
`gpsd-lab/transcripts/t00-system-and-versions.txt`):

```
$ command -v gpsd gpsfake gpspipe cgps gpsmon xgps (system, before the build)
/usr/sbin/gpsd
MISSING gpsfake
MISSING gpspipe
/usr/bin/cgps
/usr/bin/gpsmon
MISSING xgps
```

Read that list carefully, because it decided this guide.
The daemon was present, but **gpsfake** — the replay tool
the whole lab depends on, since the lab has no receiver —
and **gpspipe**, the simplest client, were not. In the
project's packaging those tools live in companion packages
(the clients and Python packages are split out on
Debian-style systems); on this machine they simply were not
installed. A guide that needs the full tool set cannot
stop at a daemon-only install, so the lab took the source
route — and a reader following along should first check
whether their own package set includes `gpsfake` and
`gpspipe`, because with them present the package route is
the right one and this chapter's build is unnecessary.

## The source route the lab ran

The project publishes release tarballs on its official
download mirrors. The lab downloaded
**gpsd-3.26.1.tar.gz** from the Savannah mirror and recorded
the fingerprint before trusting it:

```
gpsd-3.26.1.tar.gz   5,909,502 bytes
sha256 dc7e465968c1540e61bc57c7586d6a57a0047212a014efdad348f907bc2e0990
```

gpsd builds with **SCons**, a build tool written in Python.
The lab installed SCons into a Python virtual environment
kept in the lab's scratch folder — never in `/tmp`, which is
small on this machine and wiped between sessions:

```
python3 -m venv <scratch>/venv
<scratch>/venv/bin/pip install scons        # SCons 4.11.1
```

Then, in the unpacked tarball, the build and the install,
both pointed at a **prefix** inside the scratch folder
rather than at the system directories:

```
scons prefix=<scratch>/prefix python_shebang=/usr/bin/python3 -j4
scons prefix=<scratch>/prefix python_shebang=/usr/bin/python3 install
```

Two honest details. First, `python_shebang` matters: the
Python tools (`gpsfake` is one) are installed with that
interpreter line, and pointing it at the system Python 3 is
what lets them use the `gps` package the same install lays
down. Second, that package is the one thing that did *not*
honour the prefix: the installer placed the Python `gps`
package in `/usr/local/lib/python3.12/dist-packages/gps/` —
the interpreter's own site directory — where `python3 -c
"import gps"` finds it (t00). The lab accepted that rather
than fighting the installer, and records it here.

## What the build said about itself

A trustworthy build reports what it could not do. This one
printed three warnings, and the guide repeats all three:

- `WARNING: xgps and xgpsspeed are missing runtime
  dependencies` — the graphical clients were installed but
  cannot run here (chapter 9 confirms: no display, and the
  GUI libraries are absent). They are documented-only.
- `WARNING: ubxtool and zerk are missing optional runtime
  module serial` — two vendor tools want the Python
  `serial` module (pyserial), which the lab did not install.
  Nothing in this guide uses them.
- `WARNING: AsciiDoctor not found` — the project's own HTML
  documentation was not built. This guide is not that
  documentation, and does not miss it.

Against those, one success worth naming because a different
machine might miss it: the **ncurses clients built**. The
build log links `cgps` and `gpsmon` with `-lncurses` — the
terminal-library headers were present — so both text clients
are real in this guide (chapters 6 and 9). If your build
drops them, missing ncurses development files are the usual
cause; treat that as a finding about your machine, as the
lab treated its own warnings.

## The version check that caught a wrong daemon

Install nothing on faith. The lab's closing check is the
one chapter 16 will lean on: with the prefix's `bin` and
`sbin` first on `PATH`, every tool answers with the same
release (t00):

```
gpsd: 3.26.1 (revision 3.26.1)
gpspipe: 3.26.1 (revision 3.26.1)
gpsfake: Version 3.26.1
cgps: 3.26.1 (revision 3.26.1)
gpsmon: 3.26.1 (revision 3.26.1)
```

Why so fussy? Because **gpsfake runs whatever `gpsd` it
finds on `PATH`**. The lab's first replay forgot the prefix,
gpsfake silently started the system 3.25, and the only sign
was the VERSION report saying `"release":"3.25"`. That run
was thrown away and re-done. Two daemons' worth of binaries
on one machine is normal — a package and a build, say — but
which one you are testing is a fact to establish, never to
assume. The check is one word long: the VERSION line, in
every transcript in this guide, says 3.26.1.

Check: run your tools' version flags and read the VERSION
report from a connection (chapter 8 shows how). If the
numbers disagree with each other or with what you installed,
stop — chapter 16 starts there too.
