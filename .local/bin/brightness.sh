#!/usr/bin/bash

# Brightness notification: dunst


icon_path=/usr/share/icons/Faba/symbolic/status/
notify_id=817


function get_brightness {
    # xbacklight -get
    lumeus
}

function brightness_notification {
    brightness=`get_brightness`
    printf -v br_int %.0f "$brightness"
    echo $br_int
    # bar=$(seq -s "─" $(($br_int / 5)) | sed 's/[0-9]//g')
    dunstify -r $notify_id -u low -i ${icon_path}display-brightness-symbolic.svg \
						-h int:value:"$brightness" "Brightness: ${brightness}" # Draw bar
}

case $1 in
    up)
        brightnessctl s +5%
        brightness_notification
        ;;
    down)
        brightnessctl s 5%-
        brightness_notification
	    ;;
    *)
        echo "Usage: $0 up | down "
        ;;
esac
