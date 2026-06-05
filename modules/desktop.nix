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

  # greetd + tuigreet — minimal Wayland greeter. Launches Hyprland directly.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd Hyprland";
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

  # Polkit authentication agent (Plasma used to provide one; Hyprland needs its
  # own so GUI apps can request privileges, mount drives, etc.).
  security.polkit.enable = true;
  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
  };

  # File manager + a few standalone KDE apps that are nice to keep (work fine
  # without full Plasma).
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin       # file manager (mouse-driven, dark-themed)
    kdePackages.ark           # archive GUI (pairs with peazip)
    kdePackages.qtwayland     # Qt Wayland support for KDE apps under Hyprland
    hyprpolkitagent
  ];

  # XDG portals — the Hyprland portal is added in modules/hyprland.nix.
  xdg.portal.enable = true;

  # Flatpak (escape hatch for closed-source apps).
  services.flatpak.enable = true;
}
