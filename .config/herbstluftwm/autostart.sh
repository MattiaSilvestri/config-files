#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}
run "xinput set-prop "SYNA7DB5:00 06CB:CD41 Touchpad" "libinput Tapping Enabled" 1"
# run "conky -c /home/mattia/.config/conky/conky_sidepane2.conf"
# run "conky -c /home/mattia/.config/conky/calendar.conf"
# run "conky -c /home/mattia/.config/conky/conkyKeys.conf"
# run "pamac-tray"
run "xfce4-power-manager"
run "blueman-applet"
run "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
run "numlockx off"
# run "volumeicon"
run "nitrogen --restore"
run "nz.mega.MEGAsync"
run "redshift-gtk"
run "dropbox"
#run "conky -c /home/mattia/.config/conky/WO-conky-system-lua-v3.conkyrc"
# run "conky -c /home/mattia/.config/conky/conkyDate.conf"
#run "conky -c /home/mattia/.config/conky/conkyCPU2.conf"
# run "conky -c /home/mattia/.config/conky/calendar.conf"
run "nm-applet"
# run "emacs --daemon"
run "picom --experimental-backends --config  /home/mattia/.config/herbstluftwm/picom.conf"
run "flashfocus"
