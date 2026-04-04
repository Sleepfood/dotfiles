#!/bin/bash

setxkbmap -layout us,ua -option grp:caps_toggle
xinput set-prop 10 "libinput Tapping Enabled" 1
xrandr --output DP-2 --primary --auto --output DVI-D-0 --auto --left-of DP-2 --output HDMI-0 --auto --right-of DP-2
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
xset r rate 300 50
xset s off
xset s noblank
xset -dpms
kdeconnect-cli
nm-applet &
dunst &
blueman-applet &
firefox &
Telegram &
picom &
copyq &
