#!/bin/bash

# Dependencies:
#   nmcli (wifi)
#   pactl (volume)
#   brightnessctl (brightness)
#   powerprofilesctl (battery)
#   jq (only used in get_current_touchpad_status)

script_name="$(basename -- "$0")"

show_usage() {
    echo "${script_name}: display info through notify-send

arguments:
    [{date,time}, battery, volume, brightness, wifi, touchpad, all]
        display this info
    [{low,normal,critical}]
        urgency to use for notify-send (default: low)

options:
    -h, --help
        show this help message and exit"
}


notify_send() {
    local header="$1"
    local body="$2"
    local urgency="$3"
    notify-send \
        --transient \
        "$header" \
        "$body" \
        --app-name="${script_name}" \
        --urgency="${urgency}" \
        --hint=string:x-canonical-private-synchronous:"${script_name}"
}


get_datetime_info() {
    local datetime
    datetime="$(date "+%a %d %b %H:%M")"
    echo "$datetime"
}


get_battery_info() {
    local capacity status profile
    capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
    status="$(cat /sys/class/power_supply/BAT0/status)"
    profile="$(powerprofilesctl | grep "^\*" | tr -d "* :")"
    echo "${capacity}% ${status} (${profile})"
}


get_volume_info() {
    local volume
    if [[ "$(pactl get-sink-mute @DEFAULT_SINK@)" == "Mute: yes" ]]; then
        volume="Muted"
    else
        #volume="$(pactl list sinks | grep "Volume" | head -n1 | awk '{print $5}')"
        volume="$(pactl get-sink-volume @DEFAULT_SINK@ \
            | head -n1 \
            | awk '{print $5}')"
    fi
    echo "$volume"
}


get_brightness_info() {
    local brightness
    brightness="$(brightnessctl \
        | grep "Current brightness:" \
        | awk -F ":" '{print $2}' \
        | awk '{print $2}' \
        | tr -d "()"
    )"
    echo "$brightness"
}


get_wifi_info() {
    local status info ssid_name signal

    # Get wifi status
    status="$(nmcli --colors="no" --terse --fields WIFI general)"  # Returns 'enabled' or 'disabled'

    info="$status"

    if [[ "$status" == "enabled" ]]; then
        # Get wifi name
        ssid_name="$(nmcli --colors="no" --terse --fields NAME connection show --active \
            | head -n 1)"  # We try to remove trailing line containing 'lo'.
        # If not connected to a network (wifi radio can be either on or off) we
        # use the 'lo' that wasn't removed to determine it has not connected.
        if [[ "$ssid_name" == "lo" ]]; then
            ssid_name="disconnected"
        fi

        if [[ ! "$ssid_name" == "disabled" ]]; then
            # Get wifi signal strength (this takes a long time to load)
            signal="$(nmcli --colors="no" --terse --fields IN-USE,SIGNAL device wifi list \
                | awk -F ":" '{if ($1 == "*") print $2}'
            )"
            info="${status}: ${ssid_name} (${signal}%)"
        else
            info="${status}: ${ssid_name}"
        fi
    fi

    echo "$info"
}


get_current_touchpad_status() {
    local touchpad_status
    touchpad_status="$(swaymsg -t get_inputs --raw \
        | jq -r '.[] | "\(.type) \(.libinput.send_events)"' \
        | grep "touchpad" \
        | awk '{print $2}')"
    echo "$touchpad_status"
}


get_all_info() {
    local all_info
    all_info=(
        "$(get_datetime_info)"
        "Battery: $(get_battery_info)"
        "Volume: $(get_volume_info)"
        "Brightness: $(get_brightness_info)"
        "Wifi: $(get_wifi_info)"
        "Touchpad: $(get_current_touchpad_status)"
    )
    printf "%s\n" "${all_info[@]}"
}


main() {
    local urgency header body_list arg body urgency

    urgency="low"
    header="info"
    body_list=()

    if [[ -z "$1" ]]; then
        notify_send "$header" "$(get_all_info)" "$urgency"
        exit 0
    fi

    for arg in "$@"; do
        case "$arg" in
            "date" | "time") body_list+=("$(get_datetime_info)") ;;
            "battery") body_list+=("Battery: $(get_battery_info)") ;;
            "volume") body_list+=("Volume: $(get_volume_info)") ;;
            "brightness") body_list+=("Brightness: $(get_brightness_info)") ;;
            "wifi") body_list+=("Wifi: $(get_wifi_info)") ;;
            "touchpad") body_list+=("Touchpad: $(get_current_touchpad_status)") ;;
            "all") body_list+=("$(get_all_info)") ;;
            "low" | "normal" | "critical") urgency="$arg" ;;
            "-h" | "--help")
                show_usage
                exit 0
                ;;
            *)
                echo "${script_name}: invalid option '$arg'"
                show_usage
                exit 1
                ;;
        esac
    done

    body="$(printf "%s\n" "${body_list[@]}")"

    notify_send "$header" "$body" "$urgency"
}


main "$@"
