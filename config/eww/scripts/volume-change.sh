#!/bin/bash

# idk
lock_file="$HOME/.cache/osd.lock"

close_widgets() {
    eww update open_osd=false
    sleep 0.5
    eww close osd
}

handle_volume () {
    touch "$lock_file"

    vol=$(eww get volume)
    eww open osd --arg monitor="0"
    eww update open_osd=true

    case "$1" in
    up)
        pulsemixer --max-volume 100 --change-volume +1
        ;;
    down)
        pulsemixer --max-volume 100 --change-volume -1
        ;;
    esac 

    while [ -f "$lock_file" ]; do
        new_vol=$(eww get volume)

        if [ "$vol" != "$new_vol" ]; then
            vol="$new_vol"
            touch "$lock_file"
        else
            sleep 2
            newest_vol=$(eww get volume)
            if [ "$vol" == "$newest_vol" ]; then
                close_widgets
                rm "$lock_file"
                exit 0
            fi
        fi
    done
}

if [ -f "$lock_file" ]; then
    touch "$lock_file"
    case "$1" in
        up)
           pulsemixer --max-volume 100 --change-volume +1
           ;;
        down)
            pulsemixer --max-volume 100 --change-volume -1
            ;;
    esac 
    exit 0
else
    handle_volume "$1"
fi