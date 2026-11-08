#!/bin/bash
# t00: what was already on the machine, and what the lab built.
echo '$ command -v gpsd gpsfake gpspipe cgps gpsmon (system, before the build)'
for c in gpsd gpsfake gpspipe cgps gpsmon xgps; do
    command -v "$c" || echo "MISSING $c"
done
echo '$ /usr/sbin/gpsd -V   (the Ubuntu package that was already here)'
/usr/sbin/gpsd -V 2>&1
echo '$ ls of the source tarball the lab downloaded'
echo 'gpsd-3.26.1.tar.gz  from https://download-mirror.savannah.gnu.org/releases/gpsd/'
echo 'sha256 dc7e465968c1540e61bc57c7586d6a57a0047212a014efdad348f907bc2e0990'
echo '$ scons --version (scons installed in a Python venv in the scratch folder)'
"$HOME/workspace/.batch-351-363/scratch-gpsd/venv/bin/scons" --version 2>&1 | head -3
. "$(dirname "$0")/common.sh"
echo '$ built gpsd -V / gpspipe -V / gpsfake -V / cgps -V / gpsmon -V'
gpsd -V 2>&1; gpspipe -V 2>&1; gpsfake -V 2>&1; cgps -V 2>&1; gpsmon -V 2>&1
echo '$ python3 -c "import gps" (bindings the source build installed)'
python3 -c "import gps; print('gps module:', gps.__file__)"
echo '$ gpsd --help, first lines, and the compiled-in feature tail'
gpsd -h 2>&1 | head -8
gpsd -h 2>&1 | tail -8
