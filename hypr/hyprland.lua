-- Hyprland Lua config (hand-corrected from hyprconf2lua output).
-- Bypasses home-manager's broken settings->Lua translator (HM issue #9341).
-- Injected verbatim via xdg.configFile."hypr/hyprland.lua" in home/boston.nix.
-- API ref: https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

---@module 'hl'

local mainMod = "SUPER"

-- ---------------------------------------------------------------------------
-- General + decoration + layout (single hl.config call per official API)
-- ---------------------------------------------------------------------------
hl.config({
    general = {
        border_size = 2,
        -- gruvbox orange gradient active border + dim inactive
        col = {
            active_border   = { colors = { "rgba(fe8019ff)", "rgba(d65d0eff)" }, angle = 45 },
            inactive_border = "rgba(3c3836aa)",
        },
        gaps_in = 6,
        gaps_out = 14,
        layout = "dwindle",
        resize_on_border = true,
        extend_border_grab_area = 15,
        hover_icon_on_border = true,
    },
    decoration = {
        rounding = 14,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true,
            xray = true,
            ignore_opacity = true,
        },
        shadow = {
            enabled = true,
            range = 30,
            render_power = 3,
            color = "rgba(1d2021ee)",
        },
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

-- ---------------------------------------------------------------------------
-- Animations — beziers via hl.curve, per-leaf via hl.animation
-- ---------------------------------------------------------------------------
hl.curve("wind",      { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("overshot",  { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 6,  bezier = "wind",     style = "slide" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 6,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5,  bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })

-- ---------------------------------------------------------------------------
-- Monitor — Samsung Odyssey G7, 1440p @ 239.96Hz
-- ---------------------------------------------------------------------------
hl.monitor({ output = "DP-1", mode = "2560x1440@239.96", position = "0x0", scale = 1 })

-- ---------------------------------------------------------------------------
-- Keybinds (mouse-first)
-- ---------------------------------------------------------------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Space",  hl.dsp.window.float())
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + X",      hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + 1",      hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2",      hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3",      hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4",      hl.dsp.focus({ workspace = 4 }))
hl.bind("Print",                hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

-- scroll wheel over desktop = switch workspace
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- mouse drag move/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- media / volume / brightness (locked = fire even on lockscreen)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ---------------------------------------------------------------------------
-- Gestures (touchscreen + touchpad ready)
-- ---------------------------------------------------------------------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "pinch",      action = "float" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })

-- ---------------------------------------------------------------------------
-- hyprbars — clickable titlebars (grab bar with mouse to MOVE, no Super needed)
-- ---------------------------------------------------------------------------
hl.config({
    plugin = {
        hyprbars = {
            bar_height = 26,
            bar_color = "rgb(1d2021)",          -- gruvbox dark bg
            ["col.text"] = "rgb(ebdbb2)",       -- gruvbox fg
            bar_text_size = 11,
            bar_text_font = "JetBrainsMono Nerd Font",
            bar_part_of_window = true,
            bar_precedence_over_border = true,
        },
    },
})

-- Window buttons (right-aligned, added right-to-left): close, maximize, minimize
hl.plugin.hyprbars.add_button({ bg_color = "rgb(fb4934)", fg_color = "rgb(1d2021)", size = 13, icon = "", action = "hyprctl dispatch killactive" })
hl.plugin.hyprbars.add_button({ bg_color = "rgb(fabd2f)", fg_color = "rgb(1d2021)", size = 13, icon = "", action = "hyprctl dispatch fullscreen 1" })
hl.plugin.hyprbars.add_button({ bg_color = "rgb(b8bb26)", fg_color = "rgb(1d2021)", size = 13, icon = "", action = "hyprctl dispatch movetoworkspacesilent special" })

-- ---------------------------------------------------------------------------
-- Autostart
-- ---------------------------------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("dunst")
    hl.exec_cmd("eww daemon && eww open hud")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
end)
