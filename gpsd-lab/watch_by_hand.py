#!/usr/bin/env python3
"""watch_by_hand.py - speak gpsd's JSON protocol over a raw socket.

No gps library. Opens a TCP socket to 127.0.0.1:2947, reads the
VERSION greeting gpsd sends on connect, then sends, one at a
time, the same commands a real client sends:

    ?VERSION;  ?DEVICES;  ?WATCH={"enable":true,"json":true};

and prints a few of the report lines that come back (VERSION,
DEVICE, TPV, SKY) before sending ?WATCH={"enable":false}; and
closing. Usage: python3 watch_by_hand.py [seconds]
"""
import json
import socket
import sys
import time

HOST, PORT = "127.0.0.1", 2947
seconds = float(sys.argv[1]) if len(sys.argv) > 1 else 6.0


def main():
    sock = socket.create_connection((HOST, PORT), timeout=10)
    fh = sock.makefile("r", encoding="utf-8", newline="\n")

    def send(cmd):
        print(f">>> {cmd}")
        sock.sendall((cmd + "\r\n").encode())

    print("<<< " + fh.readline().strip())  # greeting VERSION
    send("?VERSION;")
    print("<<< " + fh.readline().strip())
    send("?DEVICES;")
    print("<<< " + fh.readline().strip())
    send('?WATCH={"enable":true,"json":true};')
    # gpsd answers a watch request with a DEVICES object and then
    # the WATCH object itself, before the reports start.
    for _ in range(3):
        line = fh.readline().strip()
        print("<<< " + line)
        if '"class":"WATCH"' in line:
            break

    deadline = time.time() + seconds
    shown = {"TPV": 0, "SKY": 0}
    while time.time() < deadline:
        line = fh.readline()
        if not line:
            break
        try:
            obj = json.loads(line)
        except ValueError:
            continue
        cls = obj.get("class")
        if cls in shown and shown[cls] < 2:
            shown[cls] += 1
            print("<<< " + line.strip())
    send('?WATCH={"enable":false};')
    for _ in range(3):
        line = fh.readline().strip()
        print("<<< " + line)
        if '"class":"WATCH"' in line:
            break
    sock.close()
    print(f"shown: {shown['TPV']} TPV, {shown['SKY']} SKY reports")


if __name__ == "__main__":
    main()
