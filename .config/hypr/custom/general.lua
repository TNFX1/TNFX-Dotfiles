-- Laptop panel at its full 144 Hz (Hyprland's "preferred" may pick 60 Hz)
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@144",
    position = "auto",
    scale = 1  -- 1.2 was too big; apps scaled individually (gsettings text-scaling, kitty font)
})

-- Turkish Q keyboard
hl.config({ input = { kb_layout = "tr" } })

-- Mouse speed copied from KDE (kcminputrc); same libinput scale
hl.device({ name = "compx-2.4g-wireless-receiver-1", sensitivity = -0.4, accel_profile = "flat" })
hl.device({ name = "compx-2.4g-dual-mode-mouse", sensitivity = -0.8 })

-- Screen saturation shader (edit SATURATION in the .frag file)
hl.config({ decoration = { screen_shader = os.getenv("HOME") .. "/.config/hypr/custom/shaders/saturation.frag" } })
