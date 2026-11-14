#!/usr/bin/env bash
# ASUS TUF keyboard light, Armoury Crate style:
#   kbd_rgb_mode.sh        -> next mode  (Fn+F4):       static -> breathing -> color cycle -> strobe
#   kbd_rgb_mode.sh color  -> next color (Shift+Fn+F4)
#   kbd_rgb_mode.sh show   -> only show the OSD (kbd_brightness_osd.py, on brightness keys)
# kbd_rgb_mode is write-only, so the current mode/color live in a state file.
# Write access comes from /etc/udev/rules.d/90-asus-kbd-rgb.rules. Shows the quickshell OSD.
SPEED=1                     # 0 slow, 1 medium, 2 fast
modes=(0 1 2 10)
colors=("#ff0000 Kırmızı" "#ff5500 Turuncu" "#ffcc00 Sarı" "#00ff40 Yeşil" "#0050ff Mavi" "#8000ff Mor" "#ffffff Beyaz")
state="${XDG_STATE_HOME:-$HOME/.local/state}/kbd_rgb_mode"
read -r m c < "$state" 2>/dev/null
m=${m:--1}; c=${c:-0}
if [[ $1 == show ]]; then
    (( m < 0 )) && m=0
elif [[ $1 == color ]]; then
    c=$(( (c + 1) % ${#colors[@]} )); (( m < 0 )) && m=0
else
    m=$(( (m + 1) % ${#modes[@]} ))
fi
read -r hex cname <<< "${colors[c]}"
printf -v rgb '%d %d %d' "0x${hex:1:2}" "0x${hex:3:2}" "0x${hex:5:2}"
led=/sys/class/leds/asus::kbd_backlight
if [[ $1 != show ]]; then
    echo "1 ${modes[m]} $rgb $SPEED" > $led/kbd_rgb_mode || exit 1
    echo "$m $c" > "$state"
fi
qs -c ii ipc call osdKeyboard update "$m" "$hex" "$cname" "$(cat $led/brightness)" >/dev/null 2>&1 \
    || notify-send -a Klavye -t 1500 "Klavye ışığı" "$cname"
