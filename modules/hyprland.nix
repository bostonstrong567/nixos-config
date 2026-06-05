{ config, lib, pkgs, ... }:

###############################################################################
# Hyprland — the "holy shit" showpiece session, ALONGSIDE Plasma.
#
# Pick it at the SDDM login screen (Plasma stays your default mouse-friendly
# daily driver). Hyprland here is configured MOUSE-FIRST:
#   * Super + left-drag  = move window
#   * Super + right-drag = resize window
#   * waybar / wofi / eww = clickable (no keybinds needed to launch/switch)
# Your Wooting 65% only needs the Super key for drag — everything else clicks.
#
# Visuals: full blur, rounded corners, animations, video/shader wallpaper, eww
# glass widgets. Colors come from Stylix (gruvbox) like everything else.
###############################################################################

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;       # modern session manager (recommended)
    xwayland.enable = true; # run X11 apps (Steam games etc.) under Hyprland
  };

  # NVIDIA + Hyprland environment (4080, Wayland-safe).
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";           # Electron/Chromium apps go Wayland
    # Explicit-sync is default in current drivers; these help edge cases:
    __GL_GSYNC_ALLOWED = "1";
    # If you ever see cursor flicker on Hyprland+NVIDIA, uncomment:
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Showpiece toolset (system-wide so the session always has them).
  environment.systemPackages = with pkgs; [
    waybar          # status bar (CSS-styled, clickable)
    eww             # widgets (glass HUD tiles)
    wofi            # mouse-driven app launcher
    rofi-wayland    # alt launcher (also mouse-driven)
    dunst           # notifications
    swww            # animated wallpaper daemon (GPU transitions)
    mpvpaper        # video wallpaper (galaxy/matrix loop behind desktop)
    hyprpaper       # simple static wallpaper fallback
    hyprlock        # lockscreen (blurred, themed)
    hypridle        # idle daemon
    hyprpicker      # color picker
    wl-clipboard    # clipboard
    grim slurp      # screenshots (region select w/ mouse)
    brightnessctl   # brightness keys
    pavucontrol     # click volume control
    networkmanagerapplet # click wifi menu
  ];

  # XDG portal for screenshare/file dialogs under Hyprland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
