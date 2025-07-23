#!/bin/bash

function run {
    if ! pgrep $1 > /dev/null ;
    then
        $@&
    fi
}

xrandr -s 1920x1080
picom --config ~/.config/picom/picom.conf