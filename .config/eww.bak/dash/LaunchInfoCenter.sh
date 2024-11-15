#!/bin/bash

# Author 	 -  z0mbi3
# Source 	 -  https://github.com/gh0stzk/dotfiles
# Maintainer -  z0mbi3.zk@protonmail.com

FILE="$HOME/.cache/eww_z0mbi3.dashboard"
ewwcfg="$HOME/.config/eww/dash"
EWW=`which eww`

if [[ ! `pidof eww` ]]; then
	${EWW} -c $HOME/.config/eww/dash &
	sleep 1
fi

launch_eww() {
	${EWW} --config "$ewwcfg" open dashboard
}


## Launch or close widgets accordingly
if [[ ! -f "$FILE" ]]; then
	touch "$FILE"
	launch_eww
else
	${EWW} --config "$ewwcfg" close dashboard
	rm "$FILE"
fi
