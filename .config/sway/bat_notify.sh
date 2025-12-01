#!/bin/bash

# Low battery notifier

script_name="$(basename -- "$0")"

# Kill already running processes
already_running="$(pgrep -c "$script_name")"
if [[ $already_running -gt 1 ]]; then
    pkill -f --older 1 "$script_name"
fi

while true; do
    battery_status="$(cat /sys/class/power_supply/BAT0/status)"
    battery_charge="$(cat /sys/class/power_supply/BAT0/capacity)"

    if [[ $battery_status == 'Discharging' && $battery_charge -le 25 ]]; then
        if [[ $battery_charge -le 15 ]]; then
            notify-send \
                "Battery critically low" "${battery_charge}%" \
                --urgency=critical \
                --app-name="$script_name" \
                --hint=string:x-canonical-private-synchronous:"$script_name"
            sleep 180
        else
            notify-send \
                "Battery low" "${battery_charge}%" \
                --urgency=critical \
                --app-name="$script_name" \
                --hint=string:x-canonical-private-synchronous:"$script_name"
            sleep 300
        fi
    elif [[ $battery_status == 'Charging' && $battery_charge -ge 80 ]]; then
        if [[ $battery_charge -ge 95 ]]; then
            notify-send \
                "Battery full" "${battery_charge}%" \
                --urgency=critical \
                --app-name="$script_name" \
                --hint=string:x-canonical-private-synchronous:"$script_name"
            sleep 180
        else
            notify-send \
                "Battery high" "${battery_charge}%" \
                --urgency=normal \
                --app-name="$script_name" \
                --hint=string:x-canonical-private-synchronous:"$script_name"
            sleep 300
        fi
    else
        sleep 600
    fi
done
