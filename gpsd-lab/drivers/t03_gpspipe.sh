#!/bin/bash
# t03: gpsfake replaying into a real gpsd on 2947, gpspipe reading it.
. "$(dirname "$0")/common.sh"
cd "$LAB" || exit 1
echo '$ gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea &   (starts a gpsd on 2947)'
start_fake fixture-sky.nmea
echo '$ timeout 15 gpspipe -w -n 12 127.0.0.1:2947'
timeout 15 gpspipe -w -n 12 127.0.0.1:2947 2>&1
echo '$ gpspipe -r (pseudo-NMEA out of the daemon), 8 packets'
timeout 15 gpspipe -r -n 8 127.0.0.1:2947 2>&1
stop_fake
echo '$ gpsfake log'
cat "$RUN/gpsfake.log"
