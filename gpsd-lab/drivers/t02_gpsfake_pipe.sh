#!/bin/bash
# t02: gpsfake pipe mode - gpsfake starts its own gpsd, replays
# the log once (-1), and dumps what a watching client would see.
# NOTE: gpsfake finds the gpsd binary on PATH. common.sh puts the
# lab build first; without that, gpsfake silently used the system
# gpsd 3.25 and the VERSION line below said 3.25. The lab caught
# that and kept the corrected run.
. "$(dirname "$0")/common.sh"
cd "$LAB" || exit 1
echo '$ gpsfake -p -1 -c 0.02 fixture-sky.nmea  (full output counted, head shown)'
gpsfake -p -1 -c 0.02 fixture-sky.nmea 2>"$RUN/gpsfake-pipe.err" \
    > "$RUN/gpsfake-pipe.out"
echo "lines total: $(wc -l < "$RUN/gpsfake-pipe.out")"
echo "TPV lines:   $(grep -c '"class":"TPV"' "$RUN/gpsfake-pipe.out")"
echo "SKY lines:   $(grep -c '"class":"SKY"' "$RUN/gpsfake-pipe.out")"
echo "raw NMEA lines echoed: $(grep -c '^\$' "$RUN/gpsfake-pipe.out")"
echo '--- first 14 lines'
head -14 "$RUN/gpsfake-pipe.out"
echo '--- the first TPV line that carries a time, speed and track'
grep -m1 '"speed"' "$RUN/gpsfake-pipe.out"
echo '--- gpsfake stderr'
cat "$RUN/gpsfake-pipe.err"
