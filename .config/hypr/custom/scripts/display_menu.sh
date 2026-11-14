#!/usr/bin/env bash
# KDE Meta+P style display menu. Rules live in custom/general.lua; this only picks the mode and reloads.
MODE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-display-mode"

if ! grep -lx connected /sys/class/drm/card*-*/status 2>/dev/null | grep -qv eDP; then
    notify-send "Ekran" "Harici ekran bulunamadı"
    exit 0
fi

choice=$(printf '%s\n' "Genişlet" "Yansıt" "Sadece harici" "Sadece laptop" | fuzzel --dmenu --prompt "Ekran: " --dpi-aware=no --font "Google Sans Flex:weight=medium:size=16" --lines 4 --width 24) || exit 0
# dpi-aware=no: the TV reports a 1600mm wide panel, so DPI-based sizing made the menu tiny
case "$choice" in
    "Genişlet")      mode=extend ;;
    "Yansıt")        mode=mirror ;;
    "Sadece harici") mode=external ;;
    "Sadece laptop") mode=laptop ;;
    *) exit 0 ;;
esac
echo "$mode" > "$MODE_FILE"
hyprctl reload
