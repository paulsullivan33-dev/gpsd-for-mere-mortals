#!/bin/bash
# t04: the small Python client, using the gps bindings.
. "$(dirname "$0")/common.sh"
cd "$LAB" || exit 1
echo '$ gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea &'
start_fake fixture-sky.nmea
echo '$ python3 client_python.py 3'
timeout 20 python3 client_python.py 3
stop_fake
