#!/bin/bash
# changeVolume

# Arbitrary but unique message tag
msgTag="myvolume"

# pactl set-sink-volume @DEFAULT_SINK@ +5%
pamixer -i 5 --allow-boost

# Increase volume
volume="$(pamixer --get-volume)"

# Show the volume notification
# icon_name="~/.icons/Controls/high-volume.png"
#
# dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
# -i "$icon_name" -h int:value:"$volume" "Volume: ${volume}%"

# Play the volume changed sound
# canberra-gtk-play -i audio-volume-change -d "changeVolume"
