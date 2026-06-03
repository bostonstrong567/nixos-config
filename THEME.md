# The "sick dark futuristic" look — how it works

One palette → every app. Rounded, glassy, dark, modern font. All declarative.

## Architecture (who controls what)

| Layer | Tool | Controls |
|---|---|---|
| **Color** (everything) | **Stylix** (`modules/theme.nix`) | GTK + Qt/KDE + ghostty + VSCode + Firefox + console + GRUB + cursor + fonts |
| **Layout / behavior** | **plasma-manager** (`home/rob.nix`) | panels, virtual desktops, click-to-focus, double-click, window-decoration choice |
| **Window frames** | **Klassy** | rounded corners, custom titlebars (Plasma 6) |
| **Blur / transparency** | **KWin effects** + Stylix `opacity` | glassy windows + panels |

**Golden rule:** color is set in **one** place (Stylix). plasma-manager deliberately does **not** set `colorScheme` → no two tools fighting over the same setting.

## The palette
**Catppuccin Mocha** — dark, futuristic, the most-ported theme in existence (official KDE/GTK/VSCode/Firefox/Spotify/Discord ports all exist, so everything matches).

**Re-theme the WHOLE system** by changing one line in `modules/theme.nix`:
```nix
base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
```
Swap to: `tokyo-night-dark`, `gruvbox-dark-hard`, `nord`, `rose-pine`, `dracula`,
`catppuccin-macchiato` — any file in `pkgs.base16-schemes`. Rebuild → everything
changes at once.

## Rounded corners + drag/resize
- **Klassy** decoration = rounded window corners + modern titlebar. Selected via
  `programs.plasma.workspace.windowDecorations` (already set to Klassy).
- Drag/resize/snap = standard Plasma (mouse-native): drag titlebar to move, drag
  edges to resize, drag to screen edge to tile-snap. Nothing to configure.
- Tune corner radius + titlebar in **System Settings → Window Decorations → Klassy → Configure**.

## Glass / transparency
- Stylix `opacity` block: apps `0.95`, terminal `0.90`, popups `0.92`.
- KWin **Blur** + **Translucency** effects on (in `home/rob.nix` kwin.effects).
- Ghostty: `background-blur-radius = 20` for a frosted terminal.
- Want more glass? Lower the opacity numbers in `modules/theme.nix`.

## Fonts
- UI/desktop: **Inter** (clean, modern sans).
- Mono/terminal/code: **JetBrainsMono Nerd Font** (icons + ligatures).
- Also installed: Cascadia, Maple Mono, FiraCode, OpenDyslexic — switch in
  `modules/theme.nix` `fonts.monospace.name`.

## cliamp as background music (the Winamp-in-shell flow)
- cliamp runs **headless** via `--daemon` (systemd user service in
  `modules/cliamp-daemon.nix`, opt-in).
- It publishes **MPRIS**, so:
  - **Panel media widget** controls it (play/pause/skip from the taskbar).
  - **Hardware media keys** work (Play/Pause/Next/Prev → `playerctl` → cliamp).
  - Sources: Spotify, YouTube Music, Jellyfin/Plex/Navidrome, SoundCloud, 30k+
    radio, local files.
- Enable it once your sources are configured:
  ```bash
  systemctl --user enable --now cliamp
  ```
- Force media keys at cliamp specifically:
  ```bash
  playerctl --player=cliamp play-pause
  ```

## Known conflict avoided
**Kvantum is NOT used.** It breaks Stylix on Plasma 6 (stylix issue #835). Stylix's
native KDE/Qt target themes Qt apps instead — same result, no breakage.

## Tweak cheat-sheet
| Want | Edit |
|---|---|
| Different color theme | `modules/theme.nix` → `base16Scheme` |
| More/less glass | `modules/theme.nix` → `opacity.*` |
| Different mono font | `modules/theme.nix` → `fonts.monospace` |
| Corner radius | System Settings → Window Decorations → Klassy |
| Custom wallpaper | `modules/theme.nix` → `image = /path/to/img;` |
| Fancier terminal cursor | drop a `.glsl` in `~/.config/ghostty/shaders/` |
