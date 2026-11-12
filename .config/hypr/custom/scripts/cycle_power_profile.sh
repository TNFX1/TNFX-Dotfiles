#!/usr/bin/env bash
# Fn+F4: power-saver -> balanced -> performance (the Quickshell OSD shows the change)
case "$(powerprofilesctl get)" in
    power-saver) powerprofilesctl set balanced ;;
    balanced)    powerprofilesctl set performance ;;
    *)           powerprofilesctl set power-saver ;;
esac
