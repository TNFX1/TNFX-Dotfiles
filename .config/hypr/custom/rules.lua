-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- Blur behind the see-through terminal (dots turn blur off for every window)
hl.window_rule({match = {class = "^(kitty)$" }, no_blur = false })
-- Blur behind Zen (Transparent Zen / Zen Internet mods)
hl.window_rule({match = {class = "^(zen)$" }, no_blur = false })
-- Blur behind Discord (Vencord transparent window + matugen theme with see-through surfaces)
hl.window_rule({match = {class = "^(discord)$" }, no_blur = false })

-- Blur behind every see-through window (GTK/Qt apps get alpha from matugen gtk.css + darklyrc).
-- Opaque windows are not blurred anyway, so this costs nothing for games/browsers.
hl.window_rule({match = {class = ".*" }, no_blur = false })
-- keep the dots exception: xwayland context menus without class/title
hl.window_rule({match = {class = "^()$", title = "^()$" }, no_blur = true })

-- Steam friends list always floats (title is localized: "Arkadaş Listesi" / "Friends List")
hl.window_rule({match = {class = "^(steam)$", title = "^(Arkadaş Listesi|Friends List)$" }, float = true })
