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
  # The Hyprland package ships TWO session files (hyprland + hyprland-uwsm).
  # tuigreet scans BOTH the --sessions dir AND XDG_DATA_DIRS/wayland-sessions,
  # so just passing --sessions wasn't enough → still showed a picker.
  #
  # Fix: a wrapper that BLANKS XDG_DATA_DIRS before launching tuigreet, and
  # points --sessions at a dir with ONLY the uwsm session. Now the single
  # session is all it can see → no "which Hyprland?" prompt, just the password.
  services.greetd =
    let
      # A data dir whose share/wayland-sessions has ONLY the uwsm session.
      sessionData = pkgs.runCommand "single-session-data" { } ''
        mkdir -p $out/share/wayland-sessions
        cp ${pkgs.hyprland}/share/wayland-sessions/hyprland-uwsm.desktop \
           $out/share/wayland-sessions/
      '';
      greeterCmd = pkgs.writeShellScript "tuigreet-launch" ''
        # Make tuigreet see ONLY our single session (it scans XDG_DATA_DIRS too).
        export XDG_DATA_DIRS="${sessionData}/share"
        # New York time, 12-hour clock on the login screen.
        export TZ="America/New_York"
        exec ${pkgs.tuigreet}/bin/tuigreet \
          --time --time-format '%a %b %d   %I:%M %p' \
          --remember --asterisks \
          --sessions ${sessionData}/share/wayland-sessions \
          --cmd start-hyprland
      '';
    in
    {
      enable = true;
      settings = {
        default_session = {
          command = "${greeterCmd}";
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
    kdePackages.qtwayland     # Qt Wayland support for KDE apps under Hyprland
    # (ark removed — peazip covers archives. yazi removed — dolphin covers files.)
  ];

  # Flameshot — configured as a home-manager service in home/boston.nix
  # (services.flameshot is a home-manager option, not a NixOS one).

  # XDG portals — the Hyprland portal is added in modules/hyprland.nix.
  xdg.portal.enable = true;

  # Flatpak (escape hatch for closed-source apps).
  services.flatpak.enable = true;
}
