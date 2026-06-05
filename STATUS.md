# Where everything stands (read this first)

## The setup, in one line
External 1TB SanDisk → NixOS, **Hyprland-only** desktop (no Plasma), gruvbox
orange/black theme on everything, all your apps, mouse-driven, Claude-maintainable.
Windows untouched (separate internal drives).

## Desktop = Hyprland only
- Mouse-first: drag titlebar = move, drag any edge = resize, scroll desktop =
  switch workspace. Only daily key = SUPER (for drag-move/resize).
- Clickable everything: **waybar** (top bar), **wofi** (app launcher),
  **wlogout** (power menu), tray icons (network/bluetooth/audio).
- **eww glass HUD** (top-right): live clock + CPU/RAM/disk, gruvbox glass tiles.
- Effects: 3-pass blur w/ xray (glassy), rounded corners, slide/overshoot
  animations, gruvbox-orange gradient borders, shadows.
- Theme: **Stylix gruvbox-dark-hard** → one palette themes EVERY app + future apps.
- Cursor: your **Windows_11_dark** set (converted to Linux XCursor).

## Your hardware (all handled)
- RTX 4080 → nvidia-open, Wayland-safe, Coolbits for later OC.
- Ryzen 7 3800X, 32GB, X570 no-wifi → wired ethernet, Zen kernel, perf governor.
- Wooting (wootility) · Logitech (Solaar) · gaming mice (piper) · Focusrite +
  Fifine (USB class-compliant, zero driver) · OpenRGB.

## The install (your 3 steps)
1. **Rufus** the ISO I give you → your 64GB Samsung USB.
2. Boot it on your PC with **ethernet plugged in**.
3. Screen shows an **IP** → text it to me.
Then I SSH in, confirm the SanDisk (by serial `25167F40S552` — can't hit Windows),
install everything live while you watch, reboot → done. Login: **boston / 1005**.

## Verification (so we don't fuck it up)
GitHub CI proves it before you flash:
- ✅ `check` job: whole config + installer eval + custom pkgs build (GREEN).
- ⏳ `build-iso` job: builds the actual bootable ISO + uploads it for download.
Repo: github.com/bostonstrong567/nixos-config (private). Every push re-verifies.

## What's BASE (on the ISO) vs LATER (live, safely)
**Base (now):** Hyprland + waybar + eww HUD + wofi + wlogout + all apps + gruvbox
+ cursor + animations + blur. Everything you need, verified.
**Later (live, rollback-safe):** Hyprland plugins (hyprexpo overview, hyprbars
titlebar buttons), or a big shell (HyprPanel / Caelestia), matugen wallpaper-
theming, animated video wallpaper. See POST-INSTALL-UPGRADES.md. Added once booted
so a bad one = just reboot to the last generation.

## Docs map
- `INSTALL-SIMPLE.md` — your 3 steps.
- `INSTALL-RUNBOOK.md` — my exact live-SSH install procedure (with disk safety).
- `POST-INSTALL-UPGRADES.md` — the jaw-drop extras to add after it boots.
- `APPS.md` / `apps-list.txt` — every app + what it does.
- `THEME.md` — how the one-palette theming works.
- `VERIFY.md` — how CI proves correctness.

## Only thing left before install
Wait for the `build-iso` job to go green → download the `.iso` from the CI run's
Artifacts → that's your Rufus file. I'll confirm when it's ready.
