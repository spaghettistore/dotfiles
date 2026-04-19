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
info_notifications_script="$HOME/.config/sway/info_notification.sh"
what_bin_day_script="$HOME/.local/bin/bin_day.py"

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
        " battery"
        " wifi"
        " wifi on"
        " wifi off"
        " wifi home"
        " wifi ext"
        " notifications"
        " audio laptop (Analog Stereo Duplex)"
        " audio hdmi (Digital Stereo (HDMI) Output)"
        " display switch to external screen"
        " display switch to laptop screen"
        " display extend to left"
        " display extend to right"
        " display enable laptop (eDP-1)"
        " display disable laptop (eDP-1)"
        " display enable external (HDMI-A-1)"
        " display disable external (HDMI-A-1)"
        " display rotate laptop (eDP-1)"
        " display unrotate laptop (eDP-1)"
        " display rotate external (HDMI-A-1)"
        " display unrotate external (HDMI-A-1)"
        " screenshot to clipboard"
        " screenshot to file"
        " datetime"
        "info"
        "what bin day"
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
        " battery")
            notify-send \
                --transient \
                "Battery" "$(cat /sys/class/power_supply/BAT0/capacity)% $(cat /sys/class/power_supply/BAT0/status)" \
                --app-name="battery_capacity_status" \
                --urgency=low \
                --hint=string:x-canonical-private-synchronous:"battery_capacity_status"
            ;;
        " powerprofiles" | "powerprofiles")
            $power_profiles_menu
            ;;
        " performance" | "performance")
            $power_profiles_menu "performance"
            ;;
        " balanced" | "balanced")
            $power_profiles_menu "balanced"
            ;;
        " power-saver" | "power-saver")
            $power_profiles_menu "power-saver"
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
        " notifications")
            swaync-client -t -sw
            ;;
        " audio laptop (Analog Stereo Duplex)")
            pacmd set-card-profile 0 output:analog-stereo+input:analog-stereo
            ;;
        " audio hdmi (Digital Stereo (HDMI) Output)")
            pacmd set-card-profile 0 output:hdmi-stereo
            ;;
        " display switch to external screen")
            swaymsg output HDMI-A-1 enable
            swaymsg output eDP-1 disable
            swaymsg output HDMI-A-1 position 0 0
            ;;
        " display switch to laptop screen")
            swaymsg output eDP-1 enable
            swaymsg output HDMI-A-1 disable
            swaymsg output eDP-1 position 0 0
            ;;
        " display extend to left")
            swaymsg output eDP-1 enable
            swaymsg output HDMI-A-1 enable
            swaymsg output eDP-1 position 1920 0
            swaymsg output HDMI-A-1 position 0 0
            ;;
        " display extend to right")
            swaymsg output eDP-1 enable
            swaymsg output HDMI-A-1 enable
            swaymsg output eDP-1 position 0 0
            swaymsg output HDMI-A-1 position 1920 0
            ;;
        " display enable laptop (eDP-1)")
            swaymsg output eDP-1 enable
            ;;
        " display disable laptop (eDP-1)")
            swaymsg output eDP-1 disable
            ;;
        " display enable external (HDMI-A-1)")
            swaymsg output HDMI-A-1 enable
            # Set external on left, laptop on right
            swaymsg output eDP-1 position 1920 0
            swaymsg output HDMI-A-1 position 0 0
            ;;
        " display disable external (HDMI-A-1)")
            swaymsg output HDMI-A-1 disable
            swaymsg output eDP-1 position 0 0
            ;;

        " display rotate laptop (eDP-1)")
            swaymsg output "eDP-1" transform 90
            ;;
        " display unrotate laptop (eDP-1)")
            swaymsg output "eDP-1" transform 0
            ;;
        " display rotate external (HDMI-A-1)")
            swaymsg output "HDMI-A-1" transform 90
            ;;
        " display unrotate external (HDMI-A-1)")
            swaymsg output "HDMI-A-1" transform 0
            ;;
        " screenshot to clipboard")
            grim /tmp/grim_temp_screenshot.png \
                && wl-copy < /tmp/grim_temp_screenshot.png \
                && rm /tmp/grim_temp_screenshot.png \
                && notify-send \
                    "Screenshot saved to clipboard" \
                    --urgency=low \
                    --app-name="screenshot_to_clipboard_notification" \
                    --hint=string:x-canonical-private-synchronous:"screenshot_to_clipboard_notification"
            ;;
        " screenshot to file")
            grim \
             && notify-send "Screenshot saved to file" \
                 --urgency=low \
                 --app-name="screenshot_saved_notification" \
                 --hint=string:x-canonical-private-synchronous:"screenshot_saved_notification"
            ;;
        " datetime")
            notify-send "$(date "+%a %d %b %H:%M")" \
                --transient \
                --urgency=low \
                --app-name="datetime_notification" \
                --hint=string:x-canonical-private-synchronous:"datetime_notification"
            ;;
        "info")
            $info_notifications_script "all"
            ;;
        "what bin day")
            [[ -e "$what_bin_day_script" ]] \
                && notify-send "$("$what_bin_day_script")" \
                    --transient \
                    --urgency=low \
                    --app-name="what_bin_day_notification" \
                    --hint=string:x-canonical-private-synchronous:"what_bin_day_notification"
            ;;
        *)
            exit 1
            ;;
    esac
}


[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"
