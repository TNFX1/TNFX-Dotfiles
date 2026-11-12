#!/usr/bin/env bash
# Pop up a notification whenever the power profile changes (Fn+F4, sidebar, CLI...)
show() {
    case "$1" in
        power-saver) label="Güç tasarrufu" icon=battery-profile-powersave ;;
        balanced)    label="Dengeli"       icon=battery-profile-balanced ;;
        performance) label="Performans"    icon=battery-profile-performance ;;
        *) return ;;
    esac
    notify-send -a "Güç modu" -i "$icon" -h string:x-canonical-private-synchronous:power-profile "Güç modu değişti" "$label"
}
last=$(powerprofilesctl get)
gdbus monitor --system --dest org.freedesktop.UPower.PowerProfiles --object-path /org/freedesktop/UPower/PowerProfiles |
while read -r line; do
    [[ $line == *ActiveProfile* ]] || continue
    now=$(powerprofilesctl get)
    [[ $now != "$last" ]] && show "$now" && last=$now
done
