-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- White minimal cursor (overrides the dots' Bibata)
hl.on("hyprland.start", function ()
    hl.exec_cmd("hyprctl setcursor Breeze_Light 24")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme Breeze_Light")
end)
