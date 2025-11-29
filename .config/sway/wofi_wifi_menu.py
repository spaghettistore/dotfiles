#!/bin/python3

import os
import json
import subprocess
import sys

HOME = os.environ.get("HOME")
FILE_NAME=f"{HOME}/.config/wofi_wifi_menu/ssid_list.json"

def check_if_ssid_file_exists() -> None:
    # If file containing ssids does not exist, use nmtui instead
    if not os.path.exists(FILE_NAME):
        print(f"wofi_wifi_menu.py: os.path.exists: '{FILE_NAME}': No such file or directory")
        print("Using 'nmtui' instead")
        subprocess.run("nmtui")
        exit()


def get_wifi_status() -> str:
    # This function returns 'enabled' or 'disabled'
    process = subprocess.run(
        ["nmcli", "--fields", "WIFI", "g"],
        text=True,
        capture_output=True
    )
    # Remove line 1 containing word 'WIFI'
    status = process.stdout.split()[-1]

    return status


def get_wifi_name() -> str:
    # This function returns the name of the currently connected SSID.
    # This function expects wifi to be enabled, else it  will reutrn the
    # otherwise trailing line 'lo'.
    process = subprocess.run(
        ["nmcli", "-t", "-f", "NAME", "c", "show", "--active"],
        text=True,
        capture_output=True
    )

    # Remove trailing line 'lo'
    name = process.stdout.split()[0]

    return name


def get_status_prompt() -> str:
    # Will return a str to be used as the prompt for wofi.
    # E.g. 'enabled: SSID_NAME'
    prompt = get_wifi_status()

    if prompt == "enabled":
        name = get_wifi_name()
        prompt = f"{prompt}: {name}"

    return prompt


def get_wofi_response(bash_list: str, prompt: str) -> str:
    # This function calls wofi and returns the response, or exits if wofi is
    # quit without selecting anything.
    command = f'printf -- "{bash_list}" | wofi --matching="fuzzy" -ip "{prompt}" --show dmenu'

    try:
        response = subprocess.check_output(command, shell=True, encoding="UTF-8")
        response = response.strip()
    except subprocess.CalledProcessError:
        # This happens if escaping wofi without selecting anything.
        # We want to quit immediately if this happens.
        exit(1)

    return response


def main():
    all_args = sys.argv[1:]
    check_if_ssid_file_exists()

    # Read file containing json dictionary of saved ssids. With the value being
    # the SSID to connect to, and the key being the nickname (e.g. "home" and
    # "ext") that will be displayed in wofi menu.
    with open(FILE_NAME, "r") as file:
        data = json.load(file)

    # If no external arguments provided, read selection with wofi, else use
    # provided arg.
    if len(all_args) == 0:
        # Convert python list of ssid nicknames to bash list, and append 'on'
        # and 'off' for options to toggle wifi.
        bash_list = "\n".join(data.keys())
        bash_list += "\non\noff"

        prompt = get_status_prompt()
        response = get_wofi_response(bash_list, prompt)
    else:
        response = all_args[0]

    if response in data.keys():
        selected_ssid = data[response]
        # Enable wifi
        subprocess.run("nmcli radio wifi on", shell=True)
        # Connect to established SSID connection
        subprocess.run(f"nmcli connection up {selected_ssid}", shell=True)
    elif response in ["on", "off"]:
        # Enable / disable wifi
        subprocess.run(f"nmcli radio wifi {response}", shell=True)
    else:
        print(f"wofi_wifi_menu: '{response}': Invalid option")
        exit(1)


if __name__ == "__main__":
    main()
