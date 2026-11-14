#!/usr/bin/env python3
"""Keyboard backlight keys are handled inside the kernel (no input event reaches Hyprland),
so wait for the LED's sysfs change notification and show the keyboard OSD."""
import os, select, subprocess

LED = "/sys/class/leds/asus::kbd_backlight/"
SHOW = [os.path.expanduser("~/.config/hypr/custom/scripts/kbd_rgb_mode.sh"), "show"]

with open(LED + "brightness_hw_changed") as f:
    poller = select.poll()
    poller.register(f, select.POLLPRI | select.POLLERR)
    try:
        f.read()  # arm the notification; ENODATA until the first key press
    except OSError:
        pass
    while True:
        poller.poll()  # only fires on key presses, no busy loop
        f.seek(0)
        try:
            f.read()
        except OSError:
            pass
        subprocess.run(SHOW, check=False)
