#!/usr/bin/env bash

## Wait 10 seconds
sleep 10

## Run conky
conky -c /home/mattia/.config/bspwm/conky/sidepane.conf &
conky -c /home/mattia/.config/bspwm/conky/calendar.conf &
conky -c /home/mattia/.config/bspwm/conky/sidepane_HDMI.conf &
conky -c /home/mattia/.config/bspwm/conky/calendar_HDMI.conf &
