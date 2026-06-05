# Post-install upgrades (add LIVE once it boots, on real hardware)

These are great but carry version-coupling risk, so we add them AFTER the system
is up and I can test on the real 4080 — not baked into the first install. Keeps
the install bulletproof.

## Hyprland plugins (the extra "wow")
Adding these means switching Hyprland from the nixpkgs build to the **source
Hyprland flake** (`github:hyprwm/Hyprland`) so plugin ABIs match. Worth it, but
do it live + verify the desktop still comes up, with a known-good generation to
roll back to.

- **hyprexpo** — mouse/gesture workspace overview grid (live previews, click to
  switch). Bind to a corner or a waybar click. The big one.
- **hyprbars** — clickable titlebar buttons (close / maximize / minimize) =
  Windows-like, fully mouse.
- **hyprtrails** — smooth motion trails when windows move (pure eye candy).

Flake pattern (when we do it):
```nix
inputs.hyprland.url = "github:hyprwm/Hyprland";
inputs.hyprland-plugins = {
  url = "github:hyprwm/hyprland-plugins";
  inputs.hyprland.follows = "hyprland";
};
# home: wayland.windowManager.hyprland.plugins =
#   [ inputs.hyprland-plugins.packages.${system}.hyprexpo ];
```
Use the Hyprland cachix so it doesn't compile from source for an hour:
`cachix use hyprland`.

## Notification center upgrade (optional)
- **swaync** instead of dunst → a clickable notification center + quick-toggle
  panel (wifi/bt/DND/brightness sliders). More "clean widget", more mouse. dunst
  works fine now; swap only if you want the panel.

## Animated wallpaper
- Drop a video/gif at `~/Videos/wallpaper.mp4` and uncomment the `mpvpaper` line
  in `home/boston.nix` exec-once for a living gruvbox background. Or use `swww img`
  with a still you like.

## The BIG 2026 shell upgrades (jaw-drop tier — pick one, add live)

### HyprPanel — all-in-one clickable panel (recommended first)
Clock, CPU/GPU/RAM/temp, media controls, bluetooth, network, notification center
+ dashboard, color picker — all mouse. Replaces waybar + eww HUD with one cohesive
bar. Input `github:Jas-SinghFSU/HyprPanel`; `programs.hyprpanel.enable`.
Caveat: occasional HM rebuild restart bug (#727) → exactly why it's a live add.

### Caelestia (Quickshell) — "is this even Linux??" tier
QML shell: wallpaper→accent auto-color, fluid mobile-OS animations, Super+Tab
overview w/ live previews + workspace drag, unified launcher/dashboard. The most
jaw-dropping 2026 rice. Heavier; add once base is proven. `github:caelestia-dots/shell`.

### matugen — wallpaper-driven theming
Generates the whole palette FROM your wallpaper → recolors Stylix/everything to
match any wallpaper. Set a galaxy pic → whole OS goes those colors. Very wow.

## Why not now
First install must JUST WORK. All of the above are safe to add once you're booted,
because every change is a new generation — if a plugin breaks the session, reboot
→ pick the previous generation → back to working. We add them with that safety net
live, not blind on a USB. hyprsunset + the eww glass HUD ARE in the base (safe).
