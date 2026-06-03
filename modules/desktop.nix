{ config, lib, pkgs, ... }:

###############################################################################
# Desktop — KDE Plasma 6 on Wayland.
# Mouse-native, most NVIDIA-safe Wayland desktop, rices into a showpiece.
###############################################################################

{
  services.xserver.enable = true; # provides XWayland + drivers glue

  # SDDM display manager on Wayland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Plasma 6 desktop
  services.desktopManager.plasma6.enable = true;

  # Default the session to Wayland
  services.displayManager.defaultSession = "plasma";

  # Strip a few KDE apps you can reinstall per-user if wanted (keeps it lean)
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
  ];

  # Fonts for a modern look + ricing
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove   # Cascadia Code (Nerd-patched)
    fira-code
    cascadia-code
    maple-mono.TTF              # Maple Mono — modern, rounded coding font
    open-dyslexic               # OpenDyslexic
    inter
    noto-fonts
    noto-fonts-emoji
  ];

  # XDG portals for screen-share / file dialogs under Wayland
  xdg.portal.enable = true;

  # Flatpak (handy escape hatch for closed-source apps on NixOS)
  services.flatpak.enable = true;
}
