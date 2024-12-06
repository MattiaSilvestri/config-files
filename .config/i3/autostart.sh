#!/usr/bin/bash

# Launch theme
launch_theme() {

	# Launch dunst notification daemon
	dunst -config "${HOME}"/.config/bspwm/src/config/dunstrc &

	# Launch polybar
	sleep 0.1
	for mon in $(polybar --list-monitors | cut -d":" -f1); do
		MONITOR=$mon polybar -q dani -c "${HOME}"/.config/bspwm/rices/daniela/config.ini &
	done
}


picom --config /home/mattia/.config/bspwm/src/config/picom.conf &
nitrogen --restore &
# polybar -q dani -c /home/mattia/.config/bspwm/rices/daniela/config.ini &
# dunst -config /home/mattia/.config/bspwm/src/config/dunstrc &
launch_theme &
