#!/bin/python3

# This script is designed for a single monitor setup, so it will only return
# the first monitor it finds.

# This script is used by '~/.config/sway/sway_dmenu.sh' to rotate the display.

import subprocess
import json

def get_monitor_name() -> str:
    # Get json dictionary of swaymsg output
    command = ["swaymsg", "-t", "get_outputs"]
    process = subprocess.check_output(command)
    # This is a list containing dictionaries
    data = json.loads(process)

    monitor_name = ""

    for item in data:
        if "name" in item.keys():
            monitor_name = item["name"]
            break

    return monitor_name


def main():
    monitor_name = get_monitor_name()

    if monitor_name == "":
        exit(1)

    print(monitor_name)


if __name__ == "__main__":
    main()
