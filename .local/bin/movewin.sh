#!/bin/bash
#++++++++++++++++
# Monitor Switch
#
# Moves currently focused window from one monitor to the other.
# Designed for a system with two monitors.
# Script should be triggered using a keyboard shortcut.
# If the window is maximized it should remain maximized after being moved.
# If the window is not maximized it should retain its current size, unless
# height is too large for the destination monitor, when it will be trimmed.
#++++++++++++++++

# resolution of left monitor
w_l_monitor=1920
h_l_monitor=1080
# resolution of right monitor
w_r_monitor=1920
h_r_monitor=1200

# window title bar height (default title bar height in Gnome)
h_tbar=0

# focus on active window
window=`xdotool getactivewindow`

# get active window size and position
x=`xwininfo -id $window | grep "Absolute upper-left X" | awk '{print $4}'`
y=`xwininfo -id $window | grep "Absolute upper-left Y" | awk '{print $4}'`
w=`xwininfo -id $window | grep "Width" | awk '{print $2}'`
h=`xwininfo -id $window | grep "Height" | awk '{print $2}'`

# window on left monitor
if [ "$x" -lt "$w_l_monitor" ]; then
	new_x=$(($x+$w_l_monitor))
	new_y=$(($y-$h_tbar))
	xdotool windowmove $window $new_x $new_y
	# retain maximization
	if [ "$w" -eq "$w_l_monitor" ]; then
		xdotool windowsize $window 100% 100%
	# adjust height
	elif [ "$h" -gt $(($h_r_monitor-$h_tbar)) ]; then
		xdotool windowsize $window $w $(($h_r_monitor-$h_tbar))
	fi

# window on right monitor
else
	new_x=$(($x-$w_l_monitor))
	new_y=$(($y-$h_tbar))
	xdotool windowmove $window $new_x $new_y
	# retain maximization
	if [ "$w" -eq "$w_r_monitor" ]; then
	  	xdotool windowsize $window 100% 100%
	# adjust height
	elif [ "$h" -gt $(($h_l_monitor-$h_tbar)) ]; then
		xdotool windowsize $window $w $(($h_l_monitor-$h_tbar))
	fi
fi
