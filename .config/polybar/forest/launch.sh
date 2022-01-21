#!/usr/bin/env bash

# Add this script to your wm startup file.

DIR="$HOME/.config/polybar/forest"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
MONITOR=eDP-1 polybar -q main -c "$DIR"/config_eDP-1.ini &
MONITOR=HDMI-1 polybar -q main -c "$DIR"/config_HDMI.ini &

