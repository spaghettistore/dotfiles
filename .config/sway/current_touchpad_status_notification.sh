#!/bin/bash

# Dependencies: jq

status="$(swaymsg -t get_inputs --raw \
    | jq -r '.[] | "\(.type) \(.libinput.send_events)"' \
    | grep "touchpad" \
    | awk '{print $2}')"

notify-send \
    "Touchpad" "$status" \
    --urgency=low \
    --app-name="current_touchpad_status_notification.sh" \
    --hint=string:x-canonical-private-synchronous:"current_touchpad_status_notification.sh"
