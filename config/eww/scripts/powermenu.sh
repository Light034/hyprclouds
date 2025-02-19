#!/bin/bash

# Function to toggle eww widgets
toggle_widget() {
    local widget="$1"
    eww open "$widget" --toggle --arg monitor="0"
}

# Widgets to toggle
widgets=("powercorner-right" "powercorner-left" "powermenu")

# Toggle each widget


case $(eww get open_powermenu) in
    true)
        eww update open_powermenu=false
        sleep 0.5
        for widget in "${widgets[@]}"; do
        toggle_widget "$widget"
        done
        ;;
    false)
        for widget in "${widgets[@]}"; do
        toggle_widget "$widget"
        done
        eww update open_powermenu=true
        ;;
esac
