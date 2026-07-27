#!/bin/python3

import os
import json
import subprocess
import sys
import getopt

HOME = os.environ.get("HOME")
FILE_NAME = f"{HOME}/.config/wifi_menu_dmenu/ssid_list.json"
DEFAULT_MENU = "rofi"
SCRIPT_NAME = os.path.basename(sys.argv[0])

def usage() -> None:
    print(f"""{SCRIPT_NAME} - Wifi menu script

USAGE
  {SCRIPT_NAME} [-h] [-m <fzf|rofi>] [OPTION]

DESCRIPTION
  The json file '{FILE_NAME}'
  should contain a dictionary containing all connections to add to the list of
  options.
  The key is the name of the connection that will be used as an available OPTION.
  The value is the connection's SSID.

OPTIONS
  on
    turn off wifi
  off
    turn on wifi
  toggle
    toggle wifi
  NAME
    name of connection loaded from json file, attempt to connect to the SSID

FLAGS
  -h, --help
    show this help message and exit
  -m <fzf|rofi>
    use specified menu (default={DEFAULT_MENU})
    menu will be skipped if an OPTION argument is provided"""
    )


def check_if_ssid_file_exists() -> None:
    # If file containing ssids does not exist, use nmtui instead
    if not os.path.exists(FILE_NAME):
        print(f"wifi_menu_dmenu.py: os.path.exists: '{FILE_NAME}': No such file or directory")
        print("Using 'nmtui' instead")
        subprocess.run("nmtui")
        exit()


def get_wifi_status() -> str:
    # This function returns 'enabled' or 'disabled'
    process = subprocess.run(
        ["nmcli", "--colors=no", "--terse", "--fields", "WIFI", "general"],
        text=True,
        capture_output=True
    )
    status = process.stdout.strip()

    return status


def get_wifi_name() -> str:
    # This function returns the name of the currently connected SSID.
    # This function expects wifi to be enabled, else it  will reutrn the
    # otherwise trailing line 'lo'.
    process = subprocess.run(
        ["nmcli", "--colors=no", "--terse", "--fields", "NAME", "connection", "show", "--active"],
        text=True,
        capture_output=True
    )

    # Remove trailing line 'lo'
    name = process.stdout.split()[0]

    # If not connected to a network (wifi radio can be either on or off)
    if name == "lo":
        name = "disconnected"

    return name


def get_status_prompt() -> str:
    # Will return a str to be used as the prompt for rofi.
    # E.g. 'enabled: SSID_NAME'
    prompt = get_wifi_status()

    if prompt == "enabled":
        name = get_wifi_name()
        prompt = f"{prompt}: {name}"

    return prompt


def get_rofi_response(bash_list: str, prompt: str) -> str:
    # This function calls rofi and returns the response, or exits if rofi is
    # quit without selecting anything. It will return entered text even if it
    # is not an option, as long as enter is pressed.
    process = subprocess.run(
        ["rofi", "-matching", "fuzzy", "-p", prompt, "-dmenu", "-i"],
        input=bash_list,
        text=True,
        capture_output=True
    )

    # Check if the user made a selection
    if process.returncode == 0:
        selected_item = process.stdout.strip()
    else:
        exit(1)

    return selected_item


def get_fzf_response(bash_list: str, prompt: str) -> str:
    # This function calls rofi and returns the response, or exits if rofi is
    # quit without selecting anything. It will return entered text even if it
    # is not an option, as long as enter is pressed.
    process = subprocess.run(
        ["fzf", "--prompt", f"{prompt}: "],
        input=bash_list,
        text=True,
        capture_output=True
    )

    # Check if the user made a selection
    if process.returncode == 0:
        selected_item = process.stdout.strip()
    else:
        exit(1)

    return selected_item


def notify_send(body: str) -> None:
    subprocess.run([
        "notify-send",
        "Wifi",
        body,
        "--transient",
        "--urgency=low",
        "--app-name=wifi_menu_dmenu",
        "--hint=string:x-canonical-private-synchronous:'wifi_menu_dmenu'"])


def toggle_wifi() -> None:
    if get_wifi_status() == "enabled":
        subprocess.run(f"nmcli radio wifi off", shell=True)
        notify_send("Disabled")
    else:
        subprocess.run(f"nmcli radio wifi on", shell=True)
        notify_send("Enabled")


def main():
    menu = DEFAULT_MENU

    try:
        opts, args = getopt.getopt(sys.argv[1:], "m:h", ["help", "output="])
    except getopt.GetoptError as err:
        print(err)
        sys.exit(2)

    for opt, optarg in opts:
        if opt == "-m":
            if optarg in ("fzf", "rofi"):
                menu = optarg
            else:
                print(f"'{optarg}': Invalid option for menu. Expects: fzf, rofi")
                sys.exit(1)
        elif opt in ("-h", "--help"):
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"

    check_if_ssid_file_exists()

    # Read file containing json dictionary of saved ssids. With the value being
    # the SSID to connect to, and the key being the nickname (e.g. "home" and
    # "ext") that will be displayed in rofi menu.
    with open(FILE_NAME, "r") as file:
        data = json.load(file)

    # If no external arguments provided, read selection with rofi, else use
    # provided arg.
    if len(args) == 0:
        # Convert python list of ssid nicknames to bash list, and append extra
        # options to toggle wifi.
        bash_list = "\n".join(data.keys())
        bash_list += "\non\noff\ntoggle"

        prompt = get_status_prompt()
        if menu == "fzf":
            response = get_fzf_response(bash_list, prompt)
        else:
            response = get_rofi_response(bash_list, prompt)
    else:
        response = args[0]

    if response in data.keys():
        selected_ssid = data[response]
        # Enable wifi
        subprocess.run("nmcli radio wifi on", shell=True)
        # Connect to established SSID connection
        subprocess.run(f"nmcli connection up {selected_ssid}", shell=True)
        notify_send(f"Connected to {selected_ssid}")
    elif response == "on":
        subprocess.run(f"nmcli radio wifi {response}", shell=True)
        notify_send(f"Enabled")
    elif response == "off":
        subprocess.run(f"nmcli radio wifi {response}", shell=True)
        notify_send(f"Disabled")
    elif response == "toggle":
        toggle_wifi()
    else:
        print(f"wifi_menu_dmenu: '{response}': Invalid option")
        exit(1)


if __name__ == "__main__":
    main()
