{ config, lib, pkgs, ... }:

###############################################################################
# Unified "sick dark futuristic" theme — single source of truth.
#
# Stylix takes ONE palette (Catppuccin Mocha) and fans it out to:
#   GTK apps · Qt/KDE apps · terminals (ghostty/kitty) · VSCode · Firefox ·
#   console (TTY) · GRUB · cursors · fonts.
#
# plasma-manager (in home/boston.nix) handles LAYOUT/behavior; Stylix handles
# COLOR. We deliberately don't set colors in both → no fighting.
#
# NOTE: Kvantum is intentionally NOT used — it breaks Stylix on Plasma 6
# (stylix issue #835). Stylix's native KDE target themes Qt instead.
###############################################################################

{
  stylix = {
    enable = true;

    # The palette. Swap this one file path to re-theme the ENTIRE system.
    # Other options: catppuccin-macchiato, tokyo-night-dark, gruvbox-dark-hard,
    # nord, rose-pine, dracula — all in pkgs.base16-schemes.
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Auto-theme everything it can detect.
    autoEnable = true;

    polarity = "dark";

    # Fonts — modern, used across UI + terminal + docs.
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sizes = {
        applications = 11;
        terminal = 12;
        desktop = 11;
        popups = 11;
      };
    };

    # Global UI opacity → glassy/futuristic. 1.0 = opaque; lower = more glass.
    opacity = {
      applications = 0.95;
      terminal = 0.90;
      popups = 0.92;
      desktop = 1.0;
    };

    # Cursor — user's uploaded Windows_11_dark set, converted to XCursor
    # (pkgs.win11-dark-cursors overlay; CI builds it). User explicitly requested
    # this cursor. Prefer Bibata? package = pkgs.bibata-cursors; name = "Bibata-Modern-Classic";
    cursor = {
      package = pkgs.win11-dark-cursors;
      name = "Windows-11-dark";
      size = 24;
    };

    # A dark wallpaper is required by Stylix; this generates one from the
    # palette so first boot looks cohesive. Replace with your own image path.
    image = pkgs.runCommand "wallpaper.png" { } ''
      ${pkgs.imagemagick}/bin/magick -size 3840x2160 \
        gradient:'#1e1e2e'-'#11111b' $out
    '';
  };

  # Klassy — rounded, highly-customizable Plasma 6 window decorations
  # (rounded corners + custom titlebar). Available to select in
  # System Settings → Window Decorations after first boot.
  environment.systemPackages = with pkgs; [
    klassy
  ];

  # KWin: rounded corners on EVERYTHING (even apps that don't self-round),
  # plus the blur already enabled in home/boston.nix kwin effects.
  # (Plasma 6 rounds via the decoration + the 'Rounded corners' effect that
  # ships with recent KWin; Klassy gives finer control.)
}
