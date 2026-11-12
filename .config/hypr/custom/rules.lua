-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- Blur behind the see-through terminal (dots turn blur off for every window)
hl.window_rule({match = {class = "^(kitty)$" }, no_blur = false })
