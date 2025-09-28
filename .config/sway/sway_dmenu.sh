#!/bin/bash

power_menu="$HOME/.config/sway/wofi_power_menu.sh"
wifi_menu="$HOME/.config/sway/wofi_wifi_menu.py"
power_profiles_menu="$HOME/.config/sway/wofi_power_profiles.sh"

main() {
    declare -a options=(
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
        " wifi on"
        " wifi off"
        " wifi home"
        " wifi ext"
        " enable laptop screen (eDP-1)"
        " disable laptop screen (eDP-1)"
        " enable external screen (HDMI-A-1)"
        " disable external screen (HDMI-A-1)"
        " rotate laptop screen (eDP-1)"
        " unrotate laptop screen (eDP-1)"
        " rotate external screen (HDMI-A-1)"
        " unrotate external screen (HDMI-A-1)"
    )
    local prompt
    prompt="$(basename -- "$0")"

    local input
    input="$(
        printf "%s\n" "${options[@]}" \
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
        " wifi on")
            $wifi_menu "on"
            ;;
        " wifi off")
            $wifi_menu "off"
            ;;
        " wifi home")
            $wifi_menu "home"
            ;;
        " wifi ext")
            $wifi_menu "ext"
            ;;
        " enable laptop screen (eDP-1)")
            swaymsg output eDP-1 enable
            ;;
        " disable laptop screen (eDP-1)")
            swaymsg output eDP-1 disable
            ;;
        " enable external screen (HDMI-A-1)")
            swaymsg output HDMI-A-1 enable
            ;;
        " disable external screen (HDMI-A-1)")
            swaymsg output HDMI-A-1 disable
            ;;
        " rotate laptop screen (eDP-1)")
            swaymsg output "eDP-1" transform 90
            ;;
        " unrotate laptop screen (eDP-1)")
            swaymsg output "eDP-1" transform 0
            ;;
        " rotate external screen (HDMI-A-1)")
            swaymsg output "HDMI-A-1" transform 90
            ;;
        " unrotate external screen (HDMI-A-1)")
            swaymsg output "HDMI-A-1" transform 0
            ;;
        *)
            exit 1
            ;;
    esac
}


[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
