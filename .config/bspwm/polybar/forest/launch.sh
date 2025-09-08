#!/usr/bin/env bash

# Add this script to your wm startup file.

DIR="$HOME/.config/bspwm/polybar/forest"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
# polybar -q main -c "$DIR"/config.ini &
MONITOR=HDMI-0 polybar -q main -c "$DIR"/config_HDMI-0.ini &
MONITOR=DVI-D-0 polybar -q main -c "$DIR"/config_DVI-D-0.ini &

