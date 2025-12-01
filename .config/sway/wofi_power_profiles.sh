#!/bin/bash

main() {
    local current_profile prompt selected_profile profile

    if [[ $# -eq 0 ]]; then
        declare -a options=(
            " performance"
            " balanced"
            " power-saver"
        )
        current_profile="$(powerprofilesctl |
            grep "^\*" |
            tr -d "* :"
        )"
        prompt="Current profile: $current_profile"
        selected_profile="$(
            printf "%s\n" "${options[@]}" \
                | wofi --matching="fuzzy" -ip "$prompt" --show dmenu
        )"
    else
        selected_profile="$1"
    fi

    case "$selected_profile" in
        " performance" | "performance")
            profile="performance"
            ;;
        " balanced" | "balanced")
            profile="balanced"
            ;;
        " power-saver" | "power-saver")
            profile="power-saver"
            ;;
        *)
            exit 1
            ;;
    esac

    powerprofilesctl set "$profile"
    notify-send \
        "Power Profile" "$profile" \
        --urgency=low \
        --app-name="current_power_profile_notification" \
        --hint=string:x-canonical-private-synchronous:"current_power_profile_notification"

}

main "$@"
