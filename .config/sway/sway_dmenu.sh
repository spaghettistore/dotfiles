#!/bin/bash

browser="firefox"
search_engine="https://duckduckgo.com/?q="
power_menu="$HOME/.config/sway/wofi_power_menu.sh"
get_monitor_name="$HOME/.config/sway/get_monitor_name.py"
wifi_menu="$HOME/.config/sway/wofi_wifi_menu.py"
power_profiles_menu="$HOME/.config/sway/wofi_power_profiles.sh"

main() {
    local options=(
        " suspend"
        " poweroff"
        " reboot"
        " logout"
        " lock"
        " powerprofiles"
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
        done \
            | wofi --matching="fuzzy" -ip "$prompt" --show dmenu
    )"

    case "$input" in
        " suspend" | "suspend")
            $power_menu "suspend"
            ;;
        " poweroff" | "poweroff")
            $power_menu "poweroff"
            ;;
        " reboot" | "reboot")
            $power_menu "reboot"
            ;;
        " logout" | "logout")
            $power_menu "logout"
            ;;
        " lock" | "lock")
            $power_menu "lock"
            ;;
        " powerprofiles" | "powerprofiles")
            $power_profiles_menu
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
            $wifi_menu
            ;;
        " rotate" | " unrotate")
            local monitor_name
            monitor_name="$($get_monitor_name)"
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
            $browser "${search_engine}${input}" &
            ;;
    esac
}


main "$@"
