#!/usr/bin/env bash

theme="cyberpunk"

lock="  Lock"
suspend="  Suspend"
hibernate="  Hibernate"
logout="  Logout"
reboot="  Reboot"
shutdown="  Shutdown"

options="$lock\n$suspend\n$hibernate\n$logout\n$reboot\n$shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -theme "$theme" -p "power" -l 6)

case "$chosen" in
    "$lock")
        swaylock -f
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$hibernate")
        systemctl hibernate
        ;;
    "$logout")
        swaymsg exit
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac
