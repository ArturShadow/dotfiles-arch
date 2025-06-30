#!/bin/bash

chosen=$(echo -e "󰐥\n󰜉\n󰒲\n󰋊\n󰍃\n󰌾" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi -p "")

case "$chosen" in
    "󰐥") systemctl poweroff ;;
    "󰜉") systemctl reboot ;;
    "󰒲") systemctl suspend ;;
    "󰋊") systemctl hibernate ;;
    "󰍃") pkill -KILL -u $USER ;;
    "󰌾") betterlockscreen -l ;;
esac

# Move to  .local/bin and chmod +x .local/bin/rofi-powermenu.sh

=