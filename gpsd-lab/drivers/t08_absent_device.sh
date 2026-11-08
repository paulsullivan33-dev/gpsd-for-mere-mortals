#!/bin/bash
# t08: a standalone gpsd on 127.0.0.1:18092 told to open a device
# that does not exist. The daemon stays up, logs the failure, and
# answers clients with empty lists. Nothing here is faked
# hardware: the point is exactly that there is none.
. "$(dirname "$0")/common.sh"
echo '$ gpsd -N -n -D 2 -S 18092 -F <scratch>/run/ctl.sock /dev/no-such-receiver-xyz &'
timeout 7 gpsd -N -n -D 2 -S 18092 -F "$RUN/ctl.sock" \
    /dev/no-such-receiver-xyz >"$RUN/gpsd-absent.log" 2>&1 &
GPSD_PID=$!
sleep 2
echo '$ raw socket to 127.0.0.1:18092 - greeting, ?DEVICES;, ?POLL;'
python3 - <<'PY'
import socket
s = socket.create_connection(("127.0.0.1", 18092), timeout=5)
f = s.makefile("r")
print("greeting:", f.readline().strip())
for cmd in ("?DEVICES;", "?POLL;"):
    s.sendall((cmd + "\r\n").encode())
    print(cmd, "->", f.readline().strip())
s.close()
PY
wait $GPSD_PID 2>/dev/null
echo '$ gpsd log (that run, in full)'
cat "$RUN/gpsd-absent.log"
