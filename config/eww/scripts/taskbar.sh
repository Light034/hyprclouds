#!/bin/bash
# Gets the number of apps that are currently pinned.
pinned_apps=(`eww get apps | jq -r '.pinned | length'`)

# This calculates the height of the taskbar based on how many apps are pinned.
# 24 is the height increase for each icon added
# 102 seems to be a constant value that is added to the total height.
(( size = pinned_apps * 24 + 140 + 1 ))

# Get the current display height in pixels
height=(`wlr-randr | grep "current" | awk '{ print $1 }' | cut -f2 -d"x"`)

# Calculate the offset necessary to align with the taskbar edge.
# The +1 is to avoid a gap that might form with certain sizes.
(( offset = (height[1]/2 - size)))

case $(eww get open_taskbar) in
    true)
        eww update open_taskbar=false
        sleep 0.5
        eww open taskbar-left --toggle --arg monitor="0"
        eww open taskbar_corner_top --toggle --arg taskbar_offset="$offset" --arg monitor="0"
        eww open taskbar_corner_bottom --toggle --arg taskbar_offset="$offset" --arg monitor="0"
        ;;
    false)
        eww open taskbar-left --toggle --arg monitor="0"
        eww open taskbar_corner_top --toggle --arg taskbar_offset="$offset" --arg monitor="0"
        eww open taskbar_corner_bottom --toggle --arg taskbar_offset="$offset" --arg monitor="0"
        eww update open_taskbar=true
        ;;
esac

# Function to toggle eww widgets
#toggle_widget() {
#    local widget="$1"
#    eww open "$widget" --toggle
#}

# Widgets to toggle
#widgets=("taskbar_corner_top" "taskbar_corner_bottom" "taskbar-left")

# Toggle each widget
#for widget in "${widgets[@]}"; do
#    toggle_widget "$widget"
#done
