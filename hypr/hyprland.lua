-- Converted from hyprland.conf (hyprlang) to hyprland.lua
-- Hyprland 0.55+ Lua config — see https://wiki.hypr.land/Configuring/Start/
-- Save this as ~/.config/hypr/hyprland.lua (Hyprland reads .lua over .conf
-- if both exist, but only checks once at startup — restart, don't just reload)

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal     = "kitty"
local terminalWarp  = "warp-terminal"
local fileManager   = "nautilus"
local menu          = "rofi -show drun -show-icons"
local runner        = "rofi -show run"
local browser       = "brave-origin-nightly"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper & swaync & hypridle & pypr")
    hl.exec_cmd("wl-paste --watch cliphist store &")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("qs -c noctalia-shell")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a, -- was rgba(1a1a1aee); color is now a hex int, not a string
        },

        blur = {
            enabled = false,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = false,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod   = "SUPER"
local secondMod = "SUPER + ALT"

-- Launch programs
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprvoice toggle"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminalWarp))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(secondMod .. " + space", hl.dsp.exec_cmd(runner))


local ohw = "/home/shaharyarshakir/.local/bin/ohw"

hl.bind(
    mainMod .. " + V",
    hl.dsp.exec_cmd(ohw .. " toggle"),
    { description = "Dictation: toggle" }
)

hl.bind(
    mainMod .. " + SHIFT + V",
    hl.dsp.exec_cmd(ohw .. " cancel"),
    { description = "Dictation: cancel" }
)

-- layoutmsg -> layout dispatcher (dwindle-only, same as example config)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/dotfiles/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pypr toggle term"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("sh -c 'cliphist list | wofi --dmenu | cliphist decode | wl-copy'"))

-- close vs force-close: hl.dsp.window.close() is graceful (was killactive),
-- hl.dsp.window.kill() force-kills (was forcekillactive)
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.kill())

hl.bind("SUPER + M", hl.dsp.exit())

-- Move focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces / move window to workspace
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true })

-- Resize active window with arrow keys
-- window.resize() takes x/y directly (pixel delta), not a nested table —
-- confirmed by the runtime error: "Expected positions (x & y) or keep_aspect_ratio"
hl.bind(mainMod .. " + left", hl.dsp.window.resize({ x = -10, y = 0 }))
hl.bind(mainMod .. " + right", hl.dsp.window.resize({ x = 10, y = 0 }))
hl.bind(mainMod .. " + up", hl.dsp.window.resize({ x = 0, y = -20 }))
hl.bind(mainMod .. " + down", hl.dsp.window.resize({ x = 0, y = 20 }))

-- Media keys
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

------------------------
---- SOURCED FILES ----
------------------------

-- The old config sourced two extra .conf files. Lua uses require() instead,
-- and it expects .lua modules, not raw hyprlang — so hyprland-gui.conf and
-- theme.conf need converting too before this will work as-is.
-- Once converted (e.g. to hyprland-gui.lua / theme.lua in the same dir):
-- require("hyprland-gui")
-- require("theme")
