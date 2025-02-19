#!/bin/bash
# This script provides information about the current network connection.
# @TODO: Add support for wired connections.
# @TODO: Add support for VPN connections.
# @TODO: Improve json output using jq.
# Depends on nmcli and rg.

#active_interface=$(nmcli -t -f DEVICE,STATE d | grep ":connected$" | cut -d: -f1)
#type=$(nmcli -t -f DEVICE,TYPE d | grep "^$active_interface:" | cut -d: -f2)
#signal=$(nmcli -f in-use,signal dev wifi | rg "\*" | awk '{ print $2 }')
#essid=$(nmcli -t -f NAME connection show --active | head -n1 | sed 's/\"/\\"/g')
#echo '{"essid": "'"$essid"'", "signal": "'"$signal"'"}'
#stdbuf -o0 printf '{"essid": "%s", "signal": "%s", "active": "%s", "type": "%s"}' $essid $signal $active_interface $type
#stdbuf -o0 printf "\n"

nmcli monitor | while read -r line; do
    active_interface=$(nmcli -t -f DEVICE,STATE d | grep ":connected$" | cut -d: -f1 | head -1)
    type=$(nmcli -t -f DEVICE,TYPE d | grep "^$active_interface:" | cut -d: -f2)
    if [[ $type == "bridge" || $type == "ethernet" ]]; then
        signal="wired"
    else
        signal=$(nmcli -f in-use,signal dev wifi | rg "\*" | awk '{ print $2 }')
    fi
    essid=$(nmcli -t -f NAME connection show --active | head -n1 | sed 's/\"/\\"/g')
    #JSON_STRING=$( jq -n \
    #            --arg essid "$essid" \
    #            --arg signal "$signal" \
    #            --arg active "$active_interface" \
    #            --arg type "$type" \
    #            '{essid: $essid, signal: $signal, active: $active_interface, type: $type}' )
    #echo '{"essid": "'"$essid"'", "signal": "'"$signal"'"}'
    stdbuf -o0 printf '{"essid": "%s", "signal": "%s", "active": "%s", "type": "%s"}' $essid $signal $active_interface $type
    #stdbuf -o0 printf "%s" $JSON_STRING
    stdbuf -o0 printf "\n"
    sleep 0.5
done
