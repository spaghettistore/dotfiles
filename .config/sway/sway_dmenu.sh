#!/bin/bash

BROWSER="firefox"
SEARCH_ENGINE="https://duckduckgo.com/?q="
POWER_MENU="$HOME/.config/sway/wofi_power_menu.sh"
GET_MONITOR_NAME="$HOME/.config/sway/get_monitor_name.py"
WIFI_MENU="$HOME/.config/sway/wofi_wifi_menu.py"

main() {
    local options=(
        " suspend"
        " poweroff"
        " reboot"
        " logout"
        " lock"
        " performance"
        " balanced"
        " power-saver"
        " wifi"
        " rotate"
        " unrotate"
    )
    local prompt
    prompt="$(basename "$0")"
    local input
    input="$(
        for option in "${options[@]}"; do
            echo "$option"
        done |
            wofi --matching="fuzzy" -ip "$prompt" --show dmenu
    )"

    case "$input" in
        " suspend" | "suspend")
            $POWER_MENU "suspend"
            ;;
        " poweroff" | "poweroff")
            $POWER_MENU "poweroff"
            ;;
        " reboot" | "reboot")
            $POWER_MENU "reboot"
            ;;
        " logout" | "logout")
            $POWER_MENU "logout"
            ;;
        " lock" | "lock")
            $POWER_MENU "lock"
            ;;
        " performance" | "performance")
            powerprofilesctl set performance
            ;;
        " balanced" | "balanced")
            powerprofilesctl set balanced
            ;;
        " power-saver" | "power-saver")
            powerprofilesctl set power-saver
            ;;
        " wifi" | "wifi")
            $WIFI_MENU
            ;;
        " rotate" | " unrotate")
            local monitor_name
            monitor_name="$($GET_MONITOR_NAME)"
            ;;&
        " rotate")
            swaymsg output "$monitor_name" transform 90, mode "default"
            #swaymsg output "HDMI-A-1" transform 90, mode "default"
            #swaymsg output "eDP-1" transform 90, mode "default"
            ;;
        " unrotate")
            swaymsg output "$monitor_name" transform 0, mode "default"
            #swaymsg output "HDMI-A-1" transform 0, mode "default"
            #swaymsg output "eDP-1" transform 0, mode "default"
            ;;
        "")
            exit 1
            ;;
        *)
            $BROWSER "${SEARCH_ENGINE}${input}" &
            ;;
    esac
}


main "$@"
