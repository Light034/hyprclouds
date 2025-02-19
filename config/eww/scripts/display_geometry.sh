#!/bin/bash

# This script aims to create a css file that will be used to dynamically change the sice of some css items.

height=(`wlr-randr | grep "current" | awk '{ print $1 }' | cut -f2 -d"x"`)
width=(`wlr-randr | grep "current" | awk '{ print $1 }' | cut -f1 -d"x"`)

# Clears the file for new data.
printf "" > $XDG_CONFIG_HOME/eww/scss/screensize.scss

# Writes the data to the file.
for displays in "${!height[@]}"; do

    printf "\$screen-width-%d: %s;\n" "$displays" "${width["$displays"]}" >> $XDG_CONFIG_HOME/eww/scss/screensize.scss
    printf "\$screen-height-%d: %s;\n" "$displays" "${height["$displays"]}" >> $XDG_CONFIG_HOME/eww/scss/screensize.scss

done