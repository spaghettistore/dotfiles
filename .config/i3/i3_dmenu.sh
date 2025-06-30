#!/bin/bash

# Required packages:
# - i3
# - rofi
# - fonts-font-awesome (for icons)

browser="firefox"
search_engine="https://duckduckgo.com/?q="
terminal="alacritty"

get_confirmation() {
    local prompt="$1"
    local options=(
        "yes"
        "no"
    )
    local response
    response="$(
        for option in "${options[@]}"; do
            echo "$option"
        done |
            rofi -matching "fuzzy" -p "$prompt" -dmenu -i
    )"

    if [[ "$response" == "yes" ]]; then
        return 0
    else
        return 1
    fi
}


main() {
    local options=(
        " suspend"
        " poweroff"
        " reboot"
        " logout"
        " lock"
        " wifi"
        " enable"
        " disable"
    )
    local prompt
    prompt="$(basename "$0")"
    local input
    input="$(
        for option in "${options[@]}"; do
            echo "$option"
        done |
            rofi -matching "fuzzy" -p "$prompt" -dmenu -i
    )"

    case "$input" in
        " suspend" | "suspend")
            if get_confirmation "Would you like to ${input}?"; then
                systemctl suspend
                i3lock
            fi
            ;;
        " poweroff" | "poweroff")
            if get_confirmation "Would you like to ${input}?"; then
                systemctl poweroff
            fi
            ;;
        " reboot" | "reboot")
            if get_confirmation "Would you like to ${input}?"; then
                systemctl reboot
            fi
            ;;
        " logout" | "logout")
            if get_confirmation "Would you like to ${input}?"; then
                i3-msg exit
            fi
            ;;
        " lock" | "lock")
            if get_confirmation "Would you like to ${input}?"; then
                i3lock
            fi
            ;;
        " wifi" | "wifi")
            $terminal -e "nmtui"
            ;;
        " enable" | "enable")
            xrandr --output "DVI-I-0" --mode 1920x1080 --right-of "HDMI-0"
            ;;
        " disable" | "disable")
            xrandr --output "DVI-I-0" --off
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
