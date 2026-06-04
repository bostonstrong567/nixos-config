#!/usr/bin/env bash
# Replicate VSCode look/style on Linux. Themes + icons only.
set -e

echo ">> Installing look extensions..."
code --install-extension dracula-theme.theme-dracula
code --install-extension pkief.material-icon-theme
code --install-extension gruntfuggly.activitusbar   # custom activity-bar buttons

echo ">> Installing FiraCode Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
TMP="$(mktemp -d)"
# Nerd Fonts FiraCode (Mono variant included)
curl -fL -o "$TMP/FiraCode.zip" \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip -o "$TMP/FiraCode.zip" -d "$FONT_DIR" >/dev/null
fc-cache -f "$FONT_DIR" >/dev/null
rm -rf "$TMP"
echo ">> Font installed."

# Copy settings (back up existing first)
DEST="$HOME/.config/Code/User/settings.json"
mkdir -p "$(dirname "$DEST")"
if [ -f "$DEST" ]; then
  cp "$DEST" "$DEST.bak.$(date +%s)"
  echo ">> Backed up existing settings.json to $DEST.bak.*"
fi
cp "$(dirname "$0")/settings.json" "$DEST"
echo ">> settings.json installed to $DEST"

echo
echo "DONE. Restart VSCode. Theme=Dracula Soft, Icons=Material, Font=FiraCode Nerd Font Mono."
