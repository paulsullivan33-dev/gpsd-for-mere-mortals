#!/bin/bash
# t05: the ?WATCH handshake by hand, over a raw socket.
. "$(dirname "$0")/common.sh"
cd "$LAB" || exit 1
echo '$ gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea &'
start_fake fixture-sky.nmea
echo '$ python3 watch_by_hand.py 5'
timeout 25 python3 watch_by_hand.py 5
stop_fake
