#!/bin/bash
# changeVolume

# Arbitrary but unique message tag
msgTag="myvolume"

pamixer -d 5 --allow-boost

# Decrease volume
volume="$(pamixer --get-volume)"

# Show the volume notification
icon_name="~/.icons/Controls/volume-down.png"
dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
-i "$icon_name" -h int:value:"$volume" "Volume: ${volume}%"

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
