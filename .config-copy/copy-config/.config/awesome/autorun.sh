#!/bin/bash

function run {
    if ! pgrep $1 > /dev/null ;
    then
        $@&
    fi
}

xrandr --output Virtual-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
       --output Virtual-2 --mode 1920x1080 --pos 0x0 --rotate normal --left-of Virtual-1
picom --config ~/.config/picom/picom.conf