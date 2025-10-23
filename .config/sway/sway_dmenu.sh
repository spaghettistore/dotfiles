#!/bin/bash

# Kill already running processes
already_running="$(pgrep -c 'wofi')"
if [[ $already_running -gt 0 ]]; then
    pkill 'wofi'
    exit 0
fi

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
        " audio laptop (Analog Stereo Duplex)"
        " audio hdmi (Digital Stereo (HDMI) Output)"
        " enable laptop display (eDP-1)"
        " disable laptop display (eDP-1)"
        " enable external display (HDMI-A-1)"
        " disable external display (HDMI-A-1)"
        " rotate laptop display (eDP-1)"
        " unrotate laptop display (eDP-1)"
        " rotate external display (HDMI-A-1)"
        " unrotate external display (HDMI-A-1)"
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
        " audio laptop (Analog Stereo Duplex)")
            pacmd set-card-profile 0 output:analog-stereo+input:analog-stereo
            ;;
        " audio hdmi (Digital Stereo (HDMI) Output)")
            pacmd set-card-profile 0 output:hdmi-stereo
            ;;
        " enable laptop display (eDP-1)")
            swaymsg output eDP-1 enable
            ;;
        " disable laptop display (eDP-1)")
            swaymsg output eDP-1 disable
            ;;
        " enable external display (HDMI-A-1)")
            swaymsg output HDMI-A-1 enable
            ;;
        " disable external display (HDMI-A-1)")
            swaymsg output HDMI-A-1 disable
            ;;
        " rotate laptop display (eDP-1)")
            swaymsg output "eDP-1" transform 90
            ;;
        " unrotate laptop display (eDP-1)")
            swaymsg output "eDP-1" transform 0
            ;;
        " rotate external display (HDMI-A-1)")
            swaymsg output "HDMI-A-1" transform 90
            ;;
        " unrotate external display (HDMI-A-1)")
            swaymsg output "HDMI-A-1" transform 0
            ;;
        *)
            exit 1
            ;;
    esac
}


[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
