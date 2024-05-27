#!/bin/bash
# changeVolume

# Arbitrary but unique message tag
msgTag="myvolume"

# Change the volume using alsa(might differ if you use pulseaudio)
pamixer -t

# Query amixer for the current volume and whether or not the speaker is muted
volume="$(pamixer --get-volume)"
mute="$(pactl get-sink-mute @DEFAULT_SINK@)"
if [[ $volume == 0 || "$mute" == "Mute: yes" ]]; then
    # Show the sound muted notification
    icon_name="~/.icons/Controls/silent.png"
    dunstify -a "changeVolume" -u low -i audio-volume-muted -h string:x-dunst-stack-tag:$msgTag \
        -i $icon_name "Volume muted" 
else
    # Show the volume notification
	icon_name="~/.icons/Controls/volume-up.png"
    dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
    -i $icon_name -h int:value:"$volume" "${volume}%"
fi

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
