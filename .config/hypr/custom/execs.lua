-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- White minimal cursor (overrides the dots' Bibata)
hl.on("hyprland.start", function ()
    -- sleep: the dots set Bibata at start too; run after them so ours wins
    hl.exec_cmd("sleep 1 && hyprctl setcursor Breeze_Light 24")
    hl.exec_cmd("sleep 1 && gsettings set org.gnome.desktop.interface cursor-theme Breeze_Light")
end)

-- Fn+F5: push kernel profile changes to power-profiles-daemon at once (otherwise the OSD lags ~2 s)
hl.on("hyprland.start", function ()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/custom/scripts/profile_sync.py")
end)
