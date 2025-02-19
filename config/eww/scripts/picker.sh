#!/bin/bash
# This script allows the user to select a color using hyprpicker.
# To do: implement different color picker for different compositors.
# Depends on hyprpicker and wl-copy.

color=$(hyprpicker)

if [[ color == "" ]]; then
    echo Selection canceled
    exit 0
fi

notify-send $color
wl-copy $color