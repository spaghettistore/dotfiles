#!/bin/bash

if [[ "$(pactl get-sink-mute @DEFAULT_SINK@)" == "Mute: yes" ]]; then
    volume="Muted"
else
    #volume="$(pactl list sinks | grep "Volume" | head -n1 | awk '{print $5}')"
    volume="$(pactl get-sink-volume @DEFAULT_SINK@ \
        | head -n1 \
        | awk '{print $5}')"
fi

notify-send \
    --transient \
    "Volume" "$volume" \
    --urgency=low \
    --app-name="current_volume_notification.sh" \
    --hint=string:x-canonical-private-synchronous:"current_volume_notification.sh"
