#!/bin/bash

# This script aims to automatically calculate the height of the taskbar widgets top and bottom edges,

# Gets the number of apps that are currently pinned.
pinned_apps=(`eww get apps | jq -r '.pinned | length'`)

# This calculates the height of the taskbar based on how many apps are pinned.
# 24 is the height increase for each icon added
# 102 seems to be a constant value that is added to the total height.
(( size = pinned_apps * 24 + 140 + 1 ))
echo "$size"

# Get the current display height in pixels
height=(`wlr-randr | grep "current" | awk '{ print $1 }' | cut -f2 -d"x"`)
echo "$height"

# Calculate the offset necessary to align with the taskbar edge.
# The +1 is to avoid a gap that might form with certain sizes.
(( offset = (height[0]/2 - size)))

# Opens the corner widgets with the updated offsets.
# eww doesn't seem to support dynamic changes in the widget geometry.
#eww open taskbar-left --arg monitor="0"
eww open taskbar_corner_top --arg taskbar_offset="$offset" --arg monitor="0"
eww open taskbar_corner_bottom --arg taskbar_offset="$offset" --arg monitor="0"
echo "$offset"