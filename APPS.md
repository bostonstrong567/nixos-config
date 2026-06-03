# App triage — what got added, swapped, or cut

Your wishlist, sorted. TL;DR: almost everything works; a few got better modern swaps; piracy tooling declined; a couple need a hash/manual step.

## ✅ Added natively (in nixpkgs)
vesktop · firefox · steam¹ · prismlauncher · peazip · vscode · claude-code² · haruna · flameshot · oculante · heroic¹ · lutris¹ · bottles · protonplus · fsearch · collector · zoxide · easyeffects · stremio · ghostty · waydroid · corectrl · steamtinkerlaunch · fastfetch · spicetify³ · fonts (FiraCode, Cascadia, Maple Mono, Nerd Fonts, OpenDyslexic) · nh · nix-output-monitor · cachix · git

¹ system-level in `modules/gaming.nix`  ² always-fresh via `sadjow/claude-code-nix` overlay  ³ via `Gerg-L/spicetify-nix` fork

## 📦 Packaged from upstream (not in nixpkgs, pinned + hash-verified)
- **cliamp** v1.56.0 — terminal music player ("Winamp for shell"); Go binary, SHA256-pinned in `overlays/default.nix`.
- **opcode** v0.2.0 — Claude Code GUI; AppImage-wrapped. Hash **verified** against upstream's published `.sha256` (`sha256-LsE9gweAOaru7J01r68V1aDblQ06t4qeCXp6mu1Ig3E=`). Builds clean, no manual step.

## 🔊 Hardware / audio (modules/hardware.nix)
Your devices, all driver-free on Linux:
- **Focusrite Scarlett (USB)** → class-compliant USB audio, PipeWire, zero driver
- **Fifine USB mic** → class-compliant, works out of box
- **Realtek onboard** → snd_hda_intel, auto-loaded
- **NVIDIA HDMI/DP audio** → ships with nvidia driver
- Tools added: pavucontrol, pwvucontrol, helvum (patchbay), alsa-utils
- Windows-only apps with no Linux port: NVIDIA Broadcast (→ use easyeffects RNNoise), FxSound (→ easyeffects EQ), AudioRelay
- Also: all-firmware, bluetooth+blueman, fwupd, printing (CUPS+avahi), openrgb

## ⚖️ Decisions I made for you
| Your "you pick" | Chosen | Reason |
|---|---|---|
| Haruna **vs** Celluloid | **Haruna** | Qt/KDE-native, matches Plasma 6 (Celluloid is GTK). Same mpv core. |
| archey4 **vs** fastfetch | **fastfetch** | Faster, actively developed. archey4 dropped (dupe). |
| qimgv **vs** oculante | **oculante** | Rust, GPU-accelerated, modern HDR support. |
| ProtonPlus **vs** ProtonUp-Qt | **ProtonPlus** | GTK4/libadwaita, modern UI. Replaced protonup-qt in gaming.nix. |
| NoiseTorch | **easyeffects** | You're on PipeWire; easyeffects = RNNoise denoise **+** full EQ. NoiseTorch is PulseAudio-era. |
| angrysearch | **fsearch** | angrysearch not in nixpkgs; fsearch = same Everything-like instant search, packaged + maintained. |
| discord | **vesktop** | Per your request. Better Wayland screenshare + audio than official Discord. |

## 🔑 opcode & API keys — non-issue
opcode (and **every** Claude Code GUI: Nimbalyst, OpenCovibe, Yume) is just a **wrapper around the `claude` CLI**. It does NOT do its own auth — it uses whatever `claude-code` is logged into = your **native Claude sign-in (Max OAuth)**. **No API key anywhere.** opcode stays as the pick (best + simplest); alternatives offer parallel sessions / kanban but none are in nixpkgs (all need the same AppImage wrap), so opcode wins.
| only-terminal = "ghostty-like" | **ghostty** | Exactly what you described: GPU, fast, animated cursor shaders. Wired up + a working shader vendored in. |

## 🔁 Dupes you listed (already had them)
- steam, heroic, lutris, GE-Proton, gamemode, mangohud, vkbasalt → `modules/gaming.nix`
- vscode, fastfetch, spotify(→spicetify), git → home/system
- home-manager, nix-flakes → `flake.nix`
- **archey4** == fastfetch role → cut

## 🛠️ Needs a manual step (flagged in config)
| App | Why | What to do |
|---|---|---|
| **opcode** (winfunc) | Not packaged; AppImage only | `modules/apps.nix` has an `appimageTools` wrapper w/ a placeholder hash. Get the real hash (`nix store prefetch-file <release-url>`), paste it, uncomment `opcode`. |
| **stremio glass theme** (Fxy6969) | Theme mod, not a package | stremio installed; apply the Stremio-Glass-Theme manually, or run `stremio-enhanced` via Flatpak if you want the prepatched build. |
| **ghostty cursor shaders** (sahaj-b) | Config files, not a pkg | One animated shader vendored at `~/.config/ghostty/shaders/`. Drop more `.glsl` from the repo for fancier effects. |

## 🧰 Nix stack upgrades applied
- **Lix** → replaces CppNix as the daemon (`lix-module` in flake). Modern, faster, friendlier errors.
- **nh** + **nom** + **nvd** → nicer rebuilds, pretty output, version diffs. Alias `rebuild` = `nh os switch`.
- **flakes + home-manager** → already core to this repo.
- **cachix** → binary cache (faster installs; add caches as needed).

## 🌐 These are websites, not installable apps (bookmark them)
ProtonDB · Are We Anti-Cheat Yet · Linux Gaming Wiki · LVRA Wiki · Typewolf · Typ.io · DXVK/D7VK (ship inside Proton/Wine already) · winesapOS · UMU/Luxtorpeda/Boxtron (Steam compat tools, install per-game via STL if needed).

## ❌ Cut as redundant on NixOS
| Item | Why |
|---|---|
| **pearl** (pearl-core) | Shell framework — home-manager does this declaratively, better. |
| **rcm** (dotfile mgr) | Same — home-manager *is* your dotfile manager. |
| dark-theme Dolphin | Dolphin ships with Plasma; theme via Plasma, not a separate pkg. |

## 🚫 Declined — piracy / DLC-unlock / cracked-game sources
CreamLinux, SLSsteam (DLC unlockers) · Online-Fix · CS.RIN.RU, RuTracker, johncena141, Kapital Sin, Torrminatorr (cracked-game sources). The legit launchers (Steam/Heroic/Lutris/Bottles) cover your real libraries.

## ❓ Need clarification
- **"customized cliamp.stream"** — typo? If you meant a **clipboard manager**, KDE's **Klipper** is built in. If you meant something else, tell me.
- **clipboard/clamp/clip?** — confirm and I'll wire the right tool.

## Optional extras worth considering (say the word)
- **gamemode kernel**: `linuxPackages_xanmod` or `_zen` for lower-latency gaming kernel.
- **WiVRn/Monado** if you do PC-VR.
- **vesktop** instead of discord (better screenshare audio on Linux/Wayland).
