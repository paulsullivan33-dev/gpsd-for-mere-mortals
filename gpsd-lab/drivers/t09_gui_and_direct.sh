#!/bin/bash
# t09: the things that did NOT run in this headless lab, on record.
. "$(dirname "$0")/common.sh"
cd "$LAB" || exit 1
echo '$ xgps 127.0.0.1:2947   (no display in this sandbox)'
timeout 8 xgps 127.0.0.1:2947 2>&1 | head -3
echo '$ echo $DISPLAY'
echo "DISPLAY='${DISPLAY:-<unset>}'"
echo '$ gpsmon -a -n fixture-sky.nmea   (a log file is not a device)'
echo '  gpsmon parses a bare filename as a server spec, not a serial'
echo '  device; the lab has no real serial receiver to open directly,'
echo '  so gpsmon direct-from-device was NOT run. Its via-daemon form'
echo '  is transcript t06.'
timeout 6 gpsmon -a -n fixture-sky.nmea 2>&1 | head -8
echo '$ build-time warnings about the GUI clients (from the scons build log)'
echo 'WARNING: xgps and xgpsspeed are missing runtime dependencies'
echo 'WARNING: ubxtool and zerk are missing optional runtime module serial'
echo 'WARNING: AsciiDoctor not found. Some documentation and html will not be built.'
