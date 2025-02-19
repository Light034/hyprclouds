#!/bin/bash

eww open powermenu --toggle --arg monitor=0
eww open powercorner-left --toggle --arg monitor=0
eww open powercorner-right --toggle --arg monitor=0

# Unecesary logic
#
#if [[ -z $(eww list-windows | grep '*powermenu') ]]; then
#    eww open powermenu --arg monitor="0"
#    eww open powercorner-left --arg monitor="0"
#    eww open powercorner-left --arg monitor="0"
#elif [[ -n $(eww list-windows | grep '*powermenu') ]];then
#    eww close powermenu
#    eww close powercorner-left
#    eww close powercorner-left
#fi
