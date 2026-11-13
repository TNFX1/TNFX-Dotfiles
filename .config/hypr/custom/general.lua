-- Display mode from SUPER+ALT+P (scripts/display_menu.sh writes it, then reloads).
-- Applied via reload because a monitor disabled with `hyprctl eval` can't be re-enabled by eval.
local MODE_FILE = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-display-mode"  -- tmpfs: reboot resets to extend

local function external_output()
    local p = io.popen("grep -lx connected /sys/class/drm/card*-*/status 2>/dev/null | grep -v eDP | head -1")
    local path = p:read("l"); p:close()
    return path and path:match("card%d+%-(.+)/status$")
end

local function display_mode()
    local f = io.open(MODE_FILE)
    local mode = f and f:read("l") or "extend"
    if f then f:close() end
    return mode
end

local ext = external_output()
local mode = ext and display_mode() or "extend"  -- never turn the panel off with nothing else plugged in

-- Laptop panel at its full 144 Hz (Hyprland's "preferred" may pick 60 Hz)
local laptop = { output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = 1 }  -- 1.2 was too big
if mode == "external" then laptop.disabled = true end
hl.monitor(laptop)

if ext then
    -- 1080p60: "preferred" picks 50 Hz on the Grundig TV, "highrr" picks 1024x768@75
    local m = { output = ext, mode = "1920x1080@60", position = "auto-right", scale = 1 }
    if mode == "external" then m.position = "0x0" end
    if mode == "mirror" then m.mirror = "eDP-1" end
    if mode == "laptop" then m.disabled = true end
    hl.monitor(m)
end

-- External unplugged while the panel is off -> turn the panel back on
hl.on("monitor.removed", function()
    if display_mode() ~= "extend" and not external_output() then
        os.remove(MODE_FILE)
        hl.exec_cmd("hyprctl reload")
    end
end)

-- Turkish Q keyboard
hl.config({ input = { kb_layout = "tr" } })

-- Mouse speed copied from KDE (kcminputrc); same libinput scale
hl.device({ name = "compx-2.4g-wireless-receiver-1", sensitivity = -0.4, accel_profile = "flat" })
hl.device({ name = "compx-2.4g-dual-mode-mouse", sensitivity = -0.8 })

-- Screen saturation shader (edit SATURATION in the .frag file)
hl.config({ decoration = { screen_shader = os.getenv("HOME") .. "/.config/hypr/custom/shaders/saturation.frag" } })
