# common.sh - shared setup for the gpsd lab drivers.
# The lab built gpsd 3.26.1 from the official source tarball into
# a scratch prefix (see examples/lab-notes.txt). Point
# GPSD_PREFIX at your own build/install prefix if yours differs.
PREFIX="${GPSD_PREFIX:-$HOME/workspace/.batch-351-363/scratch-gpsd/prefix}"
export PATH="$PREFIX/bin:$PREFIX/sbin:$PATH"
LAB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN="$HOME/workspace/.batch-351-363/scratch-gpsd/run"
mkdir -p "$RUN"

start_fake() {
    # start_fake LOG [LOG...] -- gpsfake feeding gpsd on 2947.
    # -n: start reading at once, do not wait for a client.
    # -c 0.1: 0.1 s between sentences, about 0.6 s per epoch.
    gpsfake -P 2947 -n -c 0.1 "$@" >"$RUN/gpsfake.log" 2>&1 &
    FAKE_PID=$!
    sleep 3
}

stop_fake() {
    kill "$FAKE_PID" 2>/dev/null
    wait "$FAKE_PID" 2>/dev/null
    sleep 1
}
