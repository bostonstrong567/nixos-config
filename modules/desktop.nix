{ config, lib, pkgs, ... }:

###############################################################################
# Desktop — Hyprland-ONLY (no Plasma). Wayland showpiece.
#
# Login greeter: greetd + tuigreet (lightweight, themable, Hyprland-friendly).
# It auto-launches the Hyprland session for `boston`. Mouse-driven daily use;
# the only daily key is SUPER (drag move/resize). Everything else is clickable
# via waybar / wofi. The full Hyprland rice lives in modules/hyprland.nix +
# home/boston.nix.
###############################################################################

{
  # XWayland glue + driver plumbing (Steam games, X11 apps under Hyprland).
  services.xserver.enable = true;

  # greetd + tuigreet — minimal Wayland greeter.
  # `--cmd start-hyprland` is the ONLY session (start-hyprland is the proper
  # UWSM-aware entrypoint). We do NOT pass --sessions, so tuigreet shows no
  # session picker at all — just the password prompt → straight into Hyprland.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  # Fonts for a modern look + ricing
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove   # Cascadia Code (Nerd-patched)
    fira-code
    cascadia-code
    maple-mono.truetype         # Maple Mono — modern, rounded coding font
    open-dyslexic               # OpenDyslexic
    inter
    noto-fonts
    noto-fonts-color-emoji      # renamed from noto-fonts-emoji
  ];

  # Polkit (so GUI apps can request privileges, mount drives, etc.).
  # The hyprpolkitagent USER SERVICE is enabled in home/boston.nix via
  # `services.hyprpolkitagent.enable` (ships its own unit — no hand-rolled path).
  security.polkit.enable = true;

  # File manager + a few standalone KDE apps that are nice to keep (work fine
  # without full Plasma).
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin       # file manager (mouse-driven, dark-themed)
    kdePackages.ark           # archive GUI (pairs with peazip)
    kdePackages.qtwayland     # Qt Wayland support for KDE apps under Hyprland
  ];

  # XDG portals — the Hyprland portal is added in modules/hyprland.nix.
  xdg.portal.enable = true;

  # Flatpak (escape hatch for closed-source apps).
  services.flatpak.enable = true;
}
