# VSCode Look — Linux port

Exact visual copy of the Windows VSCode setup. **Looks only** — no language
servers, no tooling, no Windows paths.

## What it gives you
- **Color theme:** Dracula Theme Soft
- **Icon theme:** Material Icon Theme
- **Custom colors:** purple side bar / selection / terminal cursor
- **Font:** FiraCode Nerd Font Mono (ligatures on)
- **Minimal chrome:** no tabs, no minimap, no breadcrumbs, no git gutter,
  side bar on right, activity bar on top, custom activity-bar buttons.

## Extensions (3)
| ID | Purpose |
|----|---------|
| `dracula-theme.theme-dracula` | color theme |
| `pkief.material-icon-theme` | file icons |
| `gruntfuggly.activitusbar` | custom activity-bar buttons |

## Install (automatic)
```bash
chmod +x install.sh
./install.sh
```
Installs the 3 extensions, fetches FiraCode Nerd Font, backs up your old
`settings.json`, drops the new one in. Restart VSCode.

## Install (manual)
1. Install extensions:
   ```bash
   code --install-extension dracula-theme.theme-dracula
   code --install-extension pkief.material-icon-theme
   code --install-extension gruntfuggly.activitusbar
   ```
2. Install font (Arch: `pacman -S ttf-firacode-nerd`, Debian/Ubuntu: download
   `FiraCode.zip` from nerd-fonts releases into `~/.local/share/fonts/`, then
   `fc-cache -f`).
3. Copy `settings.json` → `~/.config/Code/User/settings.json`.
4. Restart VSCode.

## Notes
- Dropped from the original: a ChatGPT activity-bar button (needs the
  `openai.chatgpt` extension — not a "look" thing). Re-add if you want it.
- If you use the **Flatpak** VSCode, settings path is
  `~/.var/app/com.visualstudio.code/config/Code/User/settings.json`.
- `window.menuStyle: native` + `titleBarStyle: custom` work on Linux; if the
  title bar looks off on your DE, switch `titleBarStyle` to `native`.
