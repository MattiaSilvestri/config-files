#!/bin/bash
# changeVolume

# Arbitrary but unique message tag
msgTag="myvolume"

# Change the volume using alsa(might differ if you use pulseaudio)
# amixer -c 0 set Master "$@" > /dev/null
# pactl set-sink-volume alsa_output.pci-0000_00_1f.3.analog-stereo +5% 
~/.local/bin/alloutput_up.sh

# Query amixer for the current volume and whether or not the speaker is muted
volume="$(amixer -D pulse get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1)"
mute="$(amixer -D pulse get Master | grep '%' | grep -oE '[^ ]+$' | grep off > /dev/null)"
if [[ $volume == 0 || "$mute" == "off" ]]; then
    # Show the sound muted notification
    dunstify -a "changeVolume" -u low -i audio-volume-muted -h string:x-dunst-stack-tag:$msgTag "Volume muted" 
else
    # Show the volume notification
		icon_name="/usr/share/icons/Faba/48x48/notifications/notification-audio-volume-high.svg"
    dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
    -i "$icon_name" -h int:value:"$volume" "Volume: ${volume}%"
fi

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
