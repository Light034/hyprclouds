#!/bin/bash

killall wf-getapps
killall eww
$XDG_CONFIG_HOME/eww/scripts/display_geometry.sh
$XDG_CONFIG_HOME/eww/scripts/taskbar.sh
#$XDG_CONFIG_HOME/eww/scripts/taskbar_height.sh
eww daemon
eww open bar --arg monitor="0"
#eww open topside-edge --arg monitor="0"
#eww open leftside-edge --arg monitor="0"
#eww open rightside-edge --arg monitor="0"
#eww open topbgcorner-left --arg monitor="0"
#eww open topbgcorner-right --arg monitor="0"
eww open notifications_popup --arg monitor="0"
#eww open taskbar-left --toggle --arg monitor="0"
python3 ~/.config/eww/scripts/notifications.py &
#eww open bgcorner-right --arg monitor="0"
#eww open bgcorner-left --arg monitor="0"
