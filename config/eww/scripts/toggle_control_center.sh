#!/bin/bash
state=$(eww get open_cc)

case $1 in
    close)
        eww update open_cc=false
        eww close control_center
        eww close corner-right
        eww close topcorner-right
        exit 0
        ;;
esac

case $state in
    true)
        eww update open_cc=false
        sleep 0.5
        eww close control_center
        eww close corner-right
        eww close topcorner-right
        ;;
    false)
        eww open control_center --arg monitor="0"
        eww open corner-right --arg monitor="0"
        eww open topcorner-right --arg monitor="0"
        eww update open_cc=true
        ;;
esac
