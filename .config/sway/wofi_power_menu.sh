#!/bin/bash

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
            wofi --matching="fuzzy" -ip "$prompt" --show dmenu
    )"

    if [[ "$response" == "yes" ]]; then
        return 0
    else
        return 1
    fi
}


main() {
    local selected_option

    if [[ $# -eq 0 ]]; then
        local options=(
            " suspend"
            " poweroff"
            " reboot"
            " logout"
            " lock"
        )
        local prompt="Select power option"
        selected_option="$(
            for option in "${options[@]}"; do
                echo "$option"
            done |
                wofi -p "$prompt" --show dmenu
        )"
    else
        selected_option="$1"
    fi

    # Clear icons if used by wofi, and make get_confirmation easier
    case "$selected_option" in
        " suspend" | "suspend")
            selected_option="suspend"
            ;;
        " poweroff" | "poweroff")
            selected_option="poweroff"
            ;;
        " reboot" | "reboot")
            selected_option="reboot"
            ;;
        " logout" | "logout")
            selected_option="logout"
            ;;
        " lock" | "lock")
            selected_option="lock"
            ;;
        *)
            exit 1
            ;;
    esac

    if ! get_confirmation "Would you like to ${selected_option}?"; then
        exit 1
    fi

    case "$selected_option" in
        "poweroff")
            systemctl poweroff
            ;;
        "reboot")
            systemctl reboot
            ;;
        "suspend")
            systemctl suspend
            swaylock
            ;;
        "logout")
            swaymsg exit
            ;;
        "lock")
            swaylock
            ;;
        *)
            exit 1
            ;;
    esac
}


main "$@"
