#!/bin/bash
# This queries the currently playing song and sends the information to eww.
# Depends on playerctl and jq.

base_dir="$HOME/.config/eww/"
pctlf="playerctl metadata -f"

playerctl metadata -F -f '{{playerName}} {{title}} {{artist}} {{mpris:artUrl}} {{status}} {{mpris:length}}' | while read -r line;
do
    name=$($pctlf "{{playerName}}" 2>/dev/null)
    # This checks if playerctl returns empty or No players found on the first query, if so it skips this loop iteration.
    if [[ -z "$name" || "$name" == "No players found" ]]; then
        continue
    fi
    # Query the rest of the variables
    title=$($pctlf "{{title}}" 2>/dev/null | sed 's/&/\&amp;/g')
    artist=$($pctlf "{{artist}}")
    artUrl=$($pctlf "{{mpris:artUrl}}" 2>/dev/null)
    status=$($pctlf "{{status}}" 2>/dev/null)
    length_raw=$($pctlf "{{mpris:length}}" 2>/dev/null)

    # If the length is not empty then it divides it by a million to return a value in seconds. Otherwise it makes length 0
    if [[ $length_raw != "" ]]; then
        (( length = length_raw / 1000000 ))
    else
        length="0"
    fi

    # Delete the image of the previously playing song
    rm -f "${base_dir}image.jpg" 1>&- 2>&-

    # Download the album art for the current song as "image.jpg"
    wget -q -O "${base_dir}image.jpg" "$artUrl" 1>&- 2>&-  &
    lengthStr=$($pctlf "{{duration(mpris:length)}}")

    # Print out the variables in json format.
    JSON_STRING=$( jq -n \
        --arg name "$name" \
        --arg title "$(printf "%s" "$title" | jq -R -r @html)" \
        --arg artist "$(printf "%s" "$artist" | jq -R -r @html)" \
        --arg artUrl "${base_dir}image.jpg" \
        --arg status "$status" \
        --arg length "$length" \
        --arg lengthStr "$lengthStr" \
        '{name: $name, title: $title, artist: $artist, artUrl: $artUrl, status: $status, length: $length, lengthStr: $lengthStr}' )


    # Using stdbuf and printf to print out and unbuffered stream, otherwise eww might not update.
    stdbuf -o0 printf "%s" $JSON_STRING
    # New line because if we do it with the previous printf it puts it after every json value. If not here then eww doesn't update all the time.
    stdbuf -o0 printf "\n"
done

