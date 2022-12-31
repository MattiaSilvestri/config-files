#!/bin/sh

# NOTE: This is only for the live demo, not needed for your configuration!
# spice-vdagent

# Run the screen compositor
picom &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

xfce4-power-manager &

redshift-gtk &

# Fire it up
exec dbus-launch --exit-with-session emacs -mm --debug-init
