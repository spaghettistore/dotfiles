#!/bin/python3

import os
import json
import subprocess

HOME = os.environ.get("HOME")
FILE_NAME=f"{HOME}/.config/wofi_wifi_menu/ssid_list.json"

def get_wifi_status() -> str:
    # Returns 'enabled' or 'disabled'
    return subprocess.check_output(
        'nmcli --fields "WIFI" g | sed 1d',
        shell=True,
        encoding="UTF-8"
    ).strip()


def get_wofi_response(bash_list: list) -> str:
    prompt = get_wifi_status()
    command = f'printf "{bash_list}" | wofi --matching="fuzzy" -ip "{prompt}" --show dmenu'

    try:
        response = subprocess.check_output(command, shell=True, encoding="UTF-8")
        response = response.strip()
    except subprocess.CalledProcessError:
        # This happens if escaping wofi without selecting anything.
        # We want to quit immediately if this happens.
        exit(1)

    return response


def main():
    # If file does not exist, use nmtui instead
    if not os.path.exists(FILE_NAME):
        print(f"os.path.exists: '{FILE_NAME}': No such file or directory")
        print("Using 'nmtui' instead.")
        subprocess.run("nmtui")
        exit()

    # Read json dictionary. key="nickname", value="SSID"
    with open(FILE_NAME, "r") as file:
        data = json.load(file)

    # Convert python list to bash list
    bash_list = "\n".join(data.keys())

    # Append options 'on' and 'off'
    bash_list += "\non\noff"

    response = get_wofi_response(bash_list)
    #print(f"DEBUG: {response=}")

    if response in data.keys():
        selected_ssid = data[response]
        #print(f"DEBUG: {selected_ssid=}")
        # Enable wifi
        subprocess.run("nmcli radio wifi on", shell=True)
        # Connect to established SSID connection
        subprocess.run(f"nmcli connection up {selected_ssid}", shell=True)
    elif response in ["on", "off"]:
        # Enable / disable wifi
        subprocess.run(f"nmcli radio wifi {response}", shell=True)
    else:
        exit(1)


if __name__ == "__main__":
    main()
