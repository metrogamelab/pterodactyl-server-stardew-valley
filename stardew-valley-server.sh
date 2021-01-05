#!/bin/bash

if [ -f /tmp/.X10-lock ]; then rm /tmp/.X10-lock; fi
Xvfb :10 -screen 0 884x515x24 -ac &

while [ ! -z "`xdpyinfo -display :10 2>&1 | grep 'unable to open display'`" ]; do
  echo Waiting for display;
  sleep 5;
done

export DISPLAY=:10.0
x11vnc -display :10 -rfbport 5900 -rfbportv6 -1 -no6 -noipv6 -httpportv6 -1 -forever -ncache 10 -desktop StardewValley -cursor arrow -passwd $VNC_PASS -shared & 
sleep 5
i3 &
export XAUTHORITY=~/.Xauthority
TERM=xterm
/home/container/StardewValley/StardewValley
