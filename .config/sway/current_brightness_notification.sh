#!/bin/bash

brightness="$(brightnessctl \
    | grep "Current brightness:" \
    | awk -F ":" '{print $2}' \
    | awk '{print $2}' \
    | tr -d "()"
)"

notify-send \
    --transient \
    "Brightness" "$brightness" \
    --urgency=low \
    --app-name="current_brightness_notification.sh" \
    --hint=string:x-canonical-private-synchronous:"current_brightness_notification.sh"
