#!/bin/bash
# t07: one gpsfake, two logs, two devices in one daemon.
. "$(dirname "$0")/common.sh"
cd "$LAB" || exit 1
echo '$ gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea fixture-sky-2.nmea &'
start_fake fixture-sky.nmea fixture-sky-2.nmea
echo '$ timeout 15 gpspipe -w -n 20 127.0.0.1:2947 | grep DEVICES/TPV (first 7)'
timeout 15 gpspipe -w -n 20 127.0.0.1:2947 2>&1 \
    | grep -E '"class":"DEVICES"|"class":"TPV"' | head -7
stop_fake
echo '$ gpsfake log'
cat "$RUN/gpsfake.log"
