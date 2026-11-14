-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples


-- KDE Meta+P style display menu (SUPER+P is taken by "pin window")
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/custom/scripts/display_menu.sh"), { description = "System: Display mode menu" })
