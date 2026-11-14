-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples


-- KDE Meta+P style display menu (SUPER+P is taken by "pin window")
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/custom/scripts/display_menu.sh"), { description = "System: Display mode menu" })

-- Fn+F4 (Asus WMI KEY_PROG4): cycle keyboard RGB mode like Armoury Crate
hl.bind("code:211", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/custom/scripts/kbd_rgb_mode.sh"), { description = "System: Keyboard RGB mode" })
hl.bind("SHIFT + code:211", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/custom/scripts/kbd_rgb_mode.sh color"), { description = "System: Keyboard RGB color" })
