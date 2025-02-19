#!/bin/bash

state=$(eww get open_launcher)

open_launcher() {
    if eww list-windows | grep -q "launcher"; then
        sleep 0.1
        eww open launcher --arg monitor="0"
    fi
    sleep 0.1
    eww update open_launcher=true
    pkill -f "apps.py"  # Kill previous instances
    ~/.config/eww/scripts/apps.py &
    ~/.config/eww/scripts/taskbar_height.sh
}

close_launcher() {
    eww update open_launcher=false
    eww close launcher
    pkill -f "apps.py"  # Kill previous instances
    ~/.config/eww/scripts/apps.py &
    ~/.config/eww/scripts/taskbar_height.sh
}

case $1 in
    close)
        close_launcher
        exit 0;;
    open)
        open_launcher
        exit 0;;
    *)
        echo "Usage: $0 {open|close}"
        exit 1;;
esac

case $state in
    true)
        close_launcher
        exit 0;;
    false)
        open_launcher
        exit 0;;
esac