#!/bin/bash

main() {
    local selected_profile

    if [[ $# -eq 0 ]]; then
        local options=(
            " performance"
            " balanced"
            " power-saver"
        )
        local current_profile
        current_profile="$(powerprofilesctl |
            grep "^\*" |
            tr -d "* :"
        )"
        local prompt="Current profile: $current_profile"
        selected_profile="$(
            for option in "${options[@]}"; do
                echo "$option"
            done |
                wofi --matching="fuzzy" -ip "$prompt" --show dmenu
        )"
    else
        selected_profile="$1"
    fi

    case "$selected_profile" in
        " performance" | "performance")
            powerprofilesctl set performance
            ;;
        " balanced" | "balanced")
            powerprofilesctl set balanced
            ;;
        " power-saver" | "power-saver")
            powerprofilesctl set power-saver
            ;;
        *)
            exit 1
            ;;
    esac
}

main "$@"
