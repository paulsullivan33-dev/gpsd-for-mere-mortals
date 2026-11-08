#!/bin/bash
# t01: generate the fixture skies and prove their checksums.
cd "$(dirname "$0")/.." || exit 1
echo '$ python3 make_nmea.py --out fixture-sky.nmea'
python3 make_nmea.py --out fixture-sky.nmea
echo '$ python3 make_nmea.py --out fixture-sky-2.nmea --lat 39.5100 --lon -98.4900 --speed 4.0 --alt 318.0 --start 43260'
python3 make_nmea.py --out fixture-sky-2.nmea --lat 39.5100 --lon -98.4900 \
    --speed 4.0 --alt 318.0 --start 43260
echo '$ python3 check_checksums.py fixture-sky.nmea fixture-sky-2.nmea'
python3 check_checksums.py fixture-sky.nmea fixture-sky-2.nmea
echo '$ wc -l fixture-sky.nmea fixture-sky-2.nmea'
wc -l fixture-sky.nmea fixture-sky-2.nmea
echo '$ head -12 fixture-sky.nmea'
head -12 fixture-sky.nmea
