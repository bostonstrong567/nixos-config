-- Hyprland Lua config (hand-corrected from hyprconf2lua output).
-- Bypasses home-manager's broken settings->Lua translator (HM issue #9341).
-- Injected verbatim via xdg.configFile."hypr/hyprland.lua" in home/boston.nix.
-- API ref: https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

---@module 'hl'

local mainMod = "SUPER"

-- ---------------------------------------------------------------------------
-- Environment — set IN the Hyprland session (environment.sessionVariables in
-- NixOS does NOT reach the UWSM-launched session, which is why opcode kept
-- lagging). hl.env sets these before any app launches → actually applies.
-- ---------------------------------------------------------------------------
hl.env("WEBKIT_DISABLE_DMABUF_RENDERER", "1")  -- fixes opcode/Tauri WebKit lag on NVIDIA
hl.env("WEBKIT_DISABLE_COMPOSITING_MODE", "1") -- extra: force-disable broken GPU compositing
hl.env("NIXOS_OZONE_WL", "1")                  -- Electron/Chromium → Wayland
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- ---------------------------------------------------------------------------
-- General + decoration + layout (single hl.config call per official API)
-- ---------------------------------------------------------------------------
hl.config({
    general = {
        -- ONE clean thin orange outline on the active window. No gradient, no
        -- glow stacking — just a single crisp gruvbox border.
        border_size = 2,
        col = {
            active_border   = "rgba(fe8019cc)",  -- single gruvbox orange
            inactive_border = "rgba(3c383655)",
        },
        gaps_in = 4,
        gaps_out = 6,
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
        -- Shadow OFF — was stacking with the border into a messy multi-layer glow.
        shadow = {
            enabled = false,
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
-- Keybinds — WOOTING 60HE friendly (no F-keys, no Print, no arrow/nav cluster).
-- Everything reachable on a 60% board: letters, numbers, Enter, Space.
-- ---------------------------------------------------------------------------
-- Apps / launchers
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))                       -- terminal
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd("wofi --show drun"))              -- app launcher
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("dolphin"))                       -- file manager
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("firefox"))                       -- browser
hl.bind(mainMod .. " + C",      hl.dsp.exec_cmd("code"))                          -- vscode
hl.bind(mainMod .. " + A",      hl.dsp.exec_cmd("ghostty --class=claude-term -e claude")) -- Claude AI terminal
hl.bind(mainMod .. " + O",      hl.dsp.exec_cmd("opcode"))                        -- opcode Claude GUI
hl.bind(mainMod .. " + G",      hl.dsp.exec_cmd("env DISPLAY=:0 glava"))          -- glava audio visualizer (needs XWayland DISPLAY)

-- Window control
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())                            -- close window
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())                       -- fullscreen
hl.bind(mainMod .. " + T",      hl.dsp.window.float())                            -- toggle float (T=Tile/floaT)
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())                           -- pseudotile

-- Screenshots (NO Print key on 60% → use SUPER+S region, SUPER+SHIFT+S full)
-- Screenshots auto-copy to clipboard + save a dated file in ~/Pictures.
-- SUPER+S = region (drag), SUPER+SHIFT+S = whole screen, SUPER+CTRL+S = annotate.
hl.bind(mainMod .. " + S",          hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots; f=~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png; grim -g \"$(slurp)\" \"$f\" && wl-copy < \"$f\" && notify-send 'Screenshot' 'Region copied to clipboard'"))
hl.bind(mainMod .. " + SHIFT + S",  hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots; f=~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png; grim \"$f\" && wl-copy < \"$f\" && notify-send 'Screenshot' 'Full screen copied to clipboard'"))
hl.bind(mainMod .. " + CTRL + S",   hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))  -- region → annotate editor

-- Utilities
hl.bind(mainMod .. " + V",          hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy")) -- clipboard history
hl.bind(mainMod .. " + Escape",     hl.dsp.exec_cmd("hyprlock"))                  -- lock screen
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("wlogout"))              -- power menu

-- Workspaces 1-4 by number
hl.bind(mainMod .. " + 1",      hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2",      hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3",      hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4",      hl.dsp.focus({ workspace = 4 }))
-- Move active window to workspace N (SHIFT)
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))

-- Focus move WITHOUT arrows: SUPER + H/J/K/L (vim-style, all on 60%)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- scroll wheel over desktop = switch workspace (pure mouse)
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- mouse drag move/resize (also: grab hyprbars titlebar to move, no key)
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
            bar_height = 32,                    -- taller, easier to grab
            bar_color = "rgb(1d2021)",          -- gruvbox dark bg
            ["col.text"] = "rgb(fe8019)",       -- gruvbox ORANGE title (pops)
            bar_text_size = 15,                 -- bigger
            bar_text_font = "CaskaydiaCove Nerd Font",  -- family name (bold via weight)
            bar_title_enabled = true,
            bar_part_of_window = true,
            bar_precedence_over_border = true,
            bar_padding = 12,
        },
    },
})

-- No buttons — just a clean draggable bar. (Window control is on keybinds:
-- SUPER+Q close, SUPER+F fullscreen, SUPER+T float.)
-- ALL apps get the bar now (no per-app no_bar rules) — you like it everywhere.

-- Claude terminal (SUPER+A) opens as a floating centered window.
hl.window_rule({ name = "float",        match = { class = "claude-term" } })
hl.window_rule({ name = "size 1100 700", match = { class = "claude-term" } })
hl.window_rule({ name = "center",       match = { class = "claude-term" } })

-- Preset workspaces: 1 Home · 2 Music · 3 Chat.
-- Music apps → ws2, chat apps → ws3. Everything else stays on Home (ws1).
hl.window_rule({ name = "workspace 2 silent", match = { class = "Spotify" } })   -- music
hl.window_rule({ name = "workspace 2 silent", match = { class = "spotify" } })
hl.window_rule({ name = "workspace 3 silent", match = { class = "vesktop" } })   -- discord/chat
hl.window_rule({ name = "workspace 3 silent", match = { class = "discord" } })

-- ---------------------------------------------------------------------------
-- Autostart
-- ---------------------------------------------------------------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    -- Wallpaper (static gruvbox image, safe + Wayland-native via awww).
    hl.exec_cmd("awww-daemon & sleep 1.5; awww img ~/.config/wallpaper.png --transition-type grow --transition-fps 60")
    -- (glava-as-background removed — the hyprwinwrap plugin crashed Hyprland at
    --  boot. Audio waves can run as a normal window via cava in a terminal, or
    --  we add mpvpaper video wallpaper later — neither risks the session.)
end)
