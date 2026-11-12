-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples


-- Fn+F4 (ASUS sends KEY_PROG4 = xkb code 211): cycle power profile
hl.bind("code:211", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/custom/scripts/cycle_power_profile.sh"), { locked = true, description = "System: Cycle power profile" })
