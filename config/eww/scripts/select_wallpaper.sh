#!/bin/bash

file=$(zenity --file-selection --filename $HOME/.wallpaper/)

if [[ $file == "" ]]; then
    exit 0
fi

# Material.py is missing.
~/.config/eww/scripts/material.py --image "$file"
