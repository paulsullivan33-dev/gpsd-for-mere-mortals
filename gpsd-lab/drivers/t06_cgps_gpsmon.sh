#!/bin/bash
# t06: cgps (a curses screen, scraped under script(1)) and
# gpsmon -a (no-curses mode) talking to the same daemon.
. "$(dirname "$0")/common.sh"
cd "$LAB" || exit 1
echo '$ gpsfake -P 2947 -n -c 0.1 fixture-sky.nmea &'
start_fake fixture-sky.nmea
echo '$ TERM=xterm-256color timeout 8 script -qec "cgps -s 127.0.0.1:2947" /dev/null'
echo '  (screen scrape, escape sequences stripped; the final painted screen)'
TERM=xterm-256color timeout 8 script -qec "cgps -s 127.0.0.1:2947" /dev/null 2>&1 \
    | sed 's/\x1b\[[0-9;?]*[A-Za-z]//g; s/\x1b[()][AB0]//g; s/\r//g' \
    | tr -s ' \n' ' \n' | grep -a -E 'Time|Latitude|Status|Seen|2026-06-15' | head -12
echo '$ timeout 6 gpsmon -a 127.0.0.1:2947  (via the daemon: raw watch)'
timeout 6 gpsmon -a 127.0.0.1:2947 2>&1 | head -22
stop_fake
