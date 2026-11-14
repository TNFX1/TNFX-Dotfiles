#!/usr/bin/env python3
"""Fn+F5 (ASUS fan key) changes the kernel platform profile directly, but power-profiles-daemon only
notices ~2 s later, so the OSD lags. Wait for the kernel change and tell ppd at once."""
import select, subprocess, sys

PATH = "/sys/firmware/acpi/platform_profile"
PPD = {"quiet": "power-saver", "low-power": "power-saver", "balanced": "balanced", "performance": "performance"}


def ppd_name(kernel):
    return PPD.get(kernel)


if len(sys.argv) > 1 and sys.argv[1] == "--test":
    assert ppd_name("quiet") == "power-saver" and ppd_name("performance") == "performance" and ppd_name("x") is None
    sys.exit(print("ok"))

with open(PATH) as f:
    poller = select.poll()
    poller.register(f, select.POLLPRI | select.POLLERR)
    last = f.read().strip()
    while True:
        poller.poll()  # sysfs_notify wakes us on every change, no busy loop
        f.seek(0)
        now = f.read().strip()
        # shortcut: a second key press within the ~50 ms ppd call could be overwritten; fine for a hand-pressed key
        if now != last and ppd_name(now):
            subprocess.run(["powerprofilesctl", "set", ppd_name(now)], check=False)
        last = now
