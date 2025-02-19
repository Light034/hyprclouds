#!/bin/bash
# Query the current position of the media player and return it as a JSON string.
# Depends on playerctl and jq.

pctlFf="playerctl metadata -F -f"
pctlf="playerctl metadata -f"


$pctlFf '{{position}} {{mpris:length}}' | while read -r line;
do
    position_raw=$($pctlf "{{position}}" 2>/dev/null)
    # Check if the first query returned an error or No players found, if so then skip this loop and further queries.
    if [[ -z "$position_raw" || "$position_raw" == "No players found" ]]; then
        continue
    fi

    length_raw=$($pctlf "{{mpris:length}}" 2>/dev/null)
    player=$($pctlf "{{playerName}}" 2>/dev/null)

    # Convert position to seconds, since bash doesn't compute floats by default this will always get rounded appropiately.
    (( position = position_raw / 1000000 ))
    positionStr=$($pctlf "{{duration(position)}}" 2>/dev/null)

    # Construct JSON safely
    JSON_STRING=$( jq -n \
                --arg position "$position" \
                --arg length "$length_raw" \
                --arg positionStr "$positionStr" \
                --arg player "$player" \
                '{$player: {position: $position, positionStr: $positionStr}}' )
    # Print out the json in an unbuffered stream.
    stdbuf -o0 printf "%s" $JSON_STRING
    stdbuf -o0 printf "\n"
done
