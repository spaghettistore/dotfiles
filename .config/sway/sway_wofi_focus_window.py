#!/bin/python3

import json
import subprocess

class Window:
    def __init__(self, name: str, app_id: int, pid: int):
        self.name = name
        self.app_id = app_id
        self.pid = pid
        self.full_line = f"{pid} {app_id}"
        # Name has been removed from full line as it needs to be piped into
        # wofi, so if name contains weird characters then bash will explode.


def get_windows() -> list:
    list_of_window_classes = []

    # Get json dictionary of swaymsg output
    command = ["swaymsg", "-t", "get_tree"]
    process = subprocess.check_output(command)
    data = json.loads(process)


    # Loop through all windows (nodes) and floating windows (floating_nodes)
    # Extract name, app_id, pid to class, and put into a list
    list_of_nodes = data["nodes"]
    for item in list_of_nodes:
        sub_list_of_nodes = item["nodes"]
        for item in sub_list_of_nodes:
            sub_sub_nodes = item["nodes"]
            for item in sub_sub_nodes:
                if "app_id" in item.keys():
                    # This is for normal tiling windows
                    window = make_window_class(item)
                    list_of_window_classes.append(window)
                elif "nodes" in item.keys():
                    # This is for stacking and tabbed windows
                    sub_sub_sub_nodes = item["nodes"]
                    for item in sub_sub_sub_nodes:
                        window = make_window_class(item)
                        list_of_window_classes.append(window)
            sub_sub_floating_nodes = item["floating_nodes"]
            for item in sub_sub_floating_nodes:
                # This is for floating windows
                window = make_window_class(item)
                list_of_window_classes.append(window)

    return list_of_window_classes


def make_window_class(data: dict):
    # This function returns a class Window
    name = data["name"]
    app_id = data["app_id"]
    pid = data["pid"]
    window = Window(name, app_id, pid)

    return window


def get_wofi_response(windows: list):
    # This function returns a class Window

    # Make a bash new line separated string list
    bash_string_list = ""
    for window in windows:
        bash_string_list += f"{window.full_line}\n"
    bash_string_list = bash_string_list.strip()

    prompt = "Select a window"
    command = f'printf "{bash_string_list}" | wofi --matching="fuzzy" -ip "{prompt}" --show dmenu'
    try:
        response = subprocess.check_output(command, shell=True, encoding="UTF-8")
        response = response.strip()
    except subprocess.CalledProcessError:
        # This happens if escaping wofi without selecting anything.
        # We want to quit immediately if this happens.
        exit(1)

    for window in windows:
        if response == window.full_line:
            return window

    # If we can not match a window, we should exit immediately.
    exit(1)


def main():
    windows = get_windows()

    selection = get_wofi_response(windows)

    # Focus window
    command = ["swaymsg", f'[pid="{selection.pid}"]', "focus"]
    subprocess.run(command)


if __name__ == "__main__":
    main()
