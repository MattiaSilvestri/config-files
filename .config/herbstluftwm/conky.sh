#!/usr/bin/env bash

## Wait 10 seconds
sleep 10

## Run conky
conky -c /home/mattia/.config/conky/Actual_conky/sidepane.conf &
conky -c /home/mattia/.config/conky/Actual_conky/calendar.conf &
conky -c /home/mattia/.config/conky/Actual_conky/sidepane_HDMI.conf &
conky -c /home/mattia/.config/conky/Actual_conky/calendar_HDMI.conf &
